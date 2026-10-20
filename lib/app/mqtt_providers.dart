import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/radio/journal.dart';
import '../core/radio/radio_session.dart';
import '../data/database.dart';
import '../mqtt/mqtt_link.dart';
import '../mqtt/mqtt_proxy.dart';
import '../mqtt/mqtt_proxy_config.dart';
import 'providers.dart';
import 'settings_providers.dart';

/// Локальный выключатель прокси (по умолчанию включён).
final mqttProxyLocalProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(databaseProvider)
      .watchSetting(AppSettingKeys.mqttProxyLocal)
      .map((v) => v != 'false'),
);

/// Что нужно прокси сейчас: null — выключить.
final _mqttProxyTargetProvider = Provider<MqttProxyConfig?>((ref) {
  final ready = ref.watch(
    radioProvider.select((r) => r.state == RadioState.ready),
  );
  if (!ready) return null;
  if (ref.watch(mqttProxyLocalProvider).value == false) return null;
  final mqtt = ref.watch(moduleConfigProvider('mqtt')).value?.mqtt;
  if (mqtt == null || !MqttProxyConfig.wanted(mqtt)) return null;
  return MqttProxyConfig.from(
    mqtt,
    lora: ref.watch(configProvider('lora')).value?.lora,
    channels: ref.watch(channelsProvider).value ?? const [],
  );
});

/// MQTT Client Proxy. Держится живым из корня приложения.
final mqttProxyProvider = ChangeNotifierProvider<MqttProxy>((ref) {
  final radio = ref.read(radioProvider);
  final journal = ref.read(journalProvider);
  final proxy = MqttProxy(
    link: MqttClientLink(),
    sendToRadio: radio.send,
    log: (s) => journal.add(JournalKind.app, s),
  );
  final sub = radio.packets
      .where((f) => f.hasMqttClientProxyMessage())
      .listen((f) => proxy.publish(f.mqttClientProxyMessage));

  void apply(MqttProxyConfig? cfg) {
    if (cfg == null) {
      proxy.stop();
    } else {
      proxy.start(cfg, myNodeNum: radio.myNodeNum);
    }
  }

  ref.listen(_mqttProxyTargetProvider, (_, cfg) => apply(cfg));
  apply(ref.read(_mqttProxyTargetProvider));
  ref.onDispose(() {
    sub.cancel();
    proxy.dispose();
  });
  return proxy;
});
