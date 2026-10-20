import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/background/keep_alive.dart';
import '../mqtt/mqtt_proxy.dart';
import 'mqtt_providers.dart';
import 'providers.dart';

/// Текст уведомления службы: состояние радио и (если работает) MQTT-прокси.
final _keepAliveStatusProvider = Provider<KeepAliveStatus?>((ref) {
  final state = ref.watch(radioProvider.select((r) => r.state));
  final target = ref.watch(radioProvider.select((r) => r.target?.title));
  final mqtt = ref.watch(
    mqttProxyProvider.select(
      (p) => p.state == MqttProxyState.inactive ? null : p.statusText,
    ),
  );
  return keepAliveStatus(state, target, mqtt: mqtt);
});

/// Служба удержания связи (Android). Держится живой из корня приложения.
final keepAliveProvider = Provider<KeepAlive>((ref) {
  final k = KeepAlive.platform();
  ref.listen(
    _keepAliveStatusProvider,
    (_, s) => k.update(s),
    fireImmediately: true,
  );
  ref.onDispose(() => k.update(null));
  return k;
});
