import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mqtt_providers.dart';
import '../../../app/providers.dart';
import '../../../data/database.dart';
import '../../../data/settings/mqtt_section.dart';
import '../../../mqtt/mqtt_proxy.dart';
import '../../../ui/kit/kit.dart';

/// Прокси в этом приложении: выключатель и состояние подключения к брокеру.
class MqttProxyCard extends ConsumerWidget {
  const MqttProxyCard({super.key, required this.saved});

  /// Клиент-прокси уже сохранён в ноде.
  final bool saved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!saved) return const WarningNote(MqttSection.proxyUnsaved);
    final on = ref.watch(mqttProxyLocalProvider).value ?? true;
    final proxy = ref.watch(mqttProxyProvider);
    final scheme = Theme.of(context).colorScheme;
    final color = switch (proxy.state) {
      MqttProxyState.connected => scheme.primary,
      MqttProxyState.failed || MqttProxyState.reconnecting => scheme.error,
      _ => null,
    };
    return SectionCard(
      children: [
        SwitchListTile(
          title: Text(context.builtIn(MqttSection.proxyLocal)),
          secondary: const Icon(Icons.dns_outlined),
          subtitle: on
              ? Text(proxy.statusText, style: TextStyle(color: color))
              : null,
          value: on,
          onChanged: (v) =>
              saveSetting(ref, AppSettingKeys.mqttProxyLocal, '$v'),
        ),
        if (on && proxy.state == MqttProxyState.connected)
          MeshTile(
            title: context.l10n.traffic_6990f2,
            subtitle: context.l10n.toBrokerToNodeDropped_856a68(
              (proxy.published).toString(),
              (proxy.forwarded).toString(),
              (proxy.dropped).toString(),
            ),
            leading: const Icon(Icons.swap_vert),
            trailing: const SizedBox.shrink(),
          ),
      ],
    );
  }
}
