import 'package:flutter/material.dart';

import '../../../app/providers.dart';
import '../../../core/proto/mesh.dart';
import '../../../data/settings/audio_section.dart';
import '../../../data/settings/bluetooth_section.dart';
import '../../../data/settings/canned_message_section.dart';
import '../../../data/settings/device_section.dart';
import '../../../data/settings/display_section.dart';
import '../../../data/settings/external_notification_section.dart';
import '../../../app/settings_providers.dart';
import '../../../data/settings/lora_section.dart';
import '../../../data/settings/mqtt_section.dart';
import '../../../data/settings/network_section.dart';
import '../../../data/settings/position_section.dart';
import '../../../data/settings/power_section.dart';
import '../../../data/settings/range_test_section.dart';
import '../../../data/settings/remote_hardware_section.dart';
import '../../../data/settings/security_section.dart';
import '../../../data/settings/serial_section.dart';
import '../../../data/settings/store_forward_section.dart';
import '../../../data/settings/telemetry_section.dart';
import '../../../ui/kit/kit.dart';
import 'config_section_page.dart';
import 'fixed_position_tile.dart';
import '../../../data/settings/node_text.dart';
import 'node_text_tile.dart';
import 'security_tiles.dart';

/// Разделы Config своей ноды: логика — в `lib/data/settings/*_section.dart`.
final loraSpec = ConfigSectionSpec<Config>(
  source: configProvider.call,
  name: 'lora',
  title: LoraSection.title,
  confirm: LoraSection.saveConfirm,
  fields: (d) => LoraSection.fields(firmware: d.firmware, hwModel: d.hwModel),
  read: (c) => LoraSection.read(c.lora),
  save: (admin, db, c, v, d) => LoraSection.save(admin, db, c.lora, v),
  adjust: LoraSection.adjust,
  check: LoraSection.check,
  // 2.8 применяет LoRa без перезагрузки — перечитать базу нод.
  afterSave: (ref) => ref.read(radioProvider).refreshNodes(),
);

final deviceSpec = ConfigSectionSpec<Config>(
  source: configProvider.call,
  name: 'device',
  title: DeviceSection.title,
  confirm: DeviceSection.saveConfirm,
  fields: (_) => DeviceSection.fields(),
  read: (c) => DeviceSection.read(c.device),
  save: (admin, db, c, v, d) => DeviceSection.save(admin, db, c.device, v),
  extra: (context, ref, form, cfg) => [
    SectionCard(
      children: [
        MeshTile(
          title: 'Использовать часовой пояс телефона',
          subtitle: 'Часовой пояс дат на экране и журнале устройства.',
          leading: const Icon(Icons.schedule),
          onTap: form.saving
              ? null
              : () => form.set('tzdef', DeviceSection.phoneTz()),
        ),
      ],
    ),
  ],
);

final positionSpec = ConfigSectionSpec<Config>(
  source: configProvider.call,
  name: 'position',
  title: PositionSection.title,
  confirm: PositionSection.saveConfirm,
  fields: (_) => PositionSection.fields(),
  read: (c) => PositionSection.read(c.position),
  save: (admin, db, c, v, d) => PositionSection.save(admin, db, c.position, v),
  extra: (context, ref, form, cfg) => [
    if (PositionSection.fixedAvailable(
      form.value<int>('gpsMode'),
      cfg.position.fixedPosition,
    ))
      FixedPositionTile(cfg: cfg.position),
  ],
);

final powerSpec = ConfigSectionSpec<Config>(
  source: configProvider.call,
  name: 'power',
  title: PowerSection.title,
  confirm: PowerSection.saveConfirm,
  fields: (d) => PowerSection.fields(hwModel: d.hwModel, role: d.role),
  read: (c) => PowerSection.read(c.power),
  save: (admin, db, c, v, d) => PowerSection.save(admin, db, c.power, v),
);

final networkSpec = ConfigSectionSpec<Config>(
  source: configProvider.call,
  name: 'network',
  title: NetworkSection.title,
  confirm: NetworkSection.saveConfirm,
  fields: (d) =>
      NetworkSection.fields(hasWifi: d.hasWifi, hasEthernet: d.hasEthernet),
  read: (c) => NetworkSection.read(c.network),
  save: (admin, db, c, v, d) => NetworkSection.save(admin, db, c.network, v),
  check: NetworkSection.check,
  extra: (context, ref, form, cfg) {
    final m = ref.watch(ownDeviceProvider).value?.metadata;
    final none = m != null && !m.hasWifi && !m.hasEthernet;
    return [
      if (none)
        const EmptyState(icon: Icons.wifi_off, text: NetworkSection.noNetwork),
    ];
  },
);

final bluetoothSpec = ConfigSectionSpec<Config>(
  source: configProvider.call,
  name: 'bluetooth',
  title: BluetoothSection.title,
  confirm: BluetoothSection.saveConfirm,
  fields: (_) => BluetoothSection.fields(),
  read: (c) => BluetoothSection.read(c.bluetooth),
  save: (admin, db, c, v, d) =>
      BluetoothSection.save(admin, db, c.bluetooth, v),
);

final displaySpec = ConfigSectionSpec<Config>(
  source: configProvider.call,
  name: 'display',
  title: DisplaySection.title,
  confirm: DisplaySection.saveConfirm,
  fields: (_) => DisplaySection.fields(),
  read: (c) => DisplaySection.read(c.display),
  save: (admin, db, c, v, d) => DisplaySection.save(admin, db, c.display, v),
);

final securitySpec = ConfigSectionSpec<Config>(
  source: configProvider.call,
  name: 'security',
  title: SecuritySection.title,
  confirm: SecuritySection.saveConfirm,
  fields: (d) => SecuritySection.fields(xeddsa: d.xeddsa),
  read: (c) => SecuritySection.read(c.security),
  save: (admin, db, c, v, d) => SecuritySection.save(admin, db, c.security, v),
  adjust: SecuritySection.adjust,
  extra: (context, ref, form, cfg) {
    final xeddsa = ref.watch(ownDeviceProvider).value?.metadata?.hasXeddsa;
    return [
      if (xeddsa == null) const WarningNote(SecuritySection.unknownXeddsa),
      SecurityKeyTiles(form: form),
      ListenableBuilder(
        listenable: form,
        builder: (_, _) => SecuritySection.hasAdminKey(form.values)
            ? const SizedBox.shrink()
            : const WarningNote(SecuritySection.managedNeedsAdmin),
      ),
    ];
  },
);

/// Модули (ModuleConfig).
final mqttSpec = ConfigSectionSpec<ModuleConfig>(
  source: moduleConfigProvider.call,
  name: 'mqtt',
  title: MqttSection.title,
  confirm: MqttSection.saveConfirm,
  fields: (d) => MqttSection.fields(firmware: d.firmware),
  read: (c) => MqttSection.read(c.mqtt),
  save: (admin, db, c, v, d) =>
      MqttSection.save(admin, db, c.mqtt, v, firmware: d.firmware),
  adjust: MqttSection.adjust,
  extra: (context, ref, form, cfg) {
    final region = ref.watch(configProvider('lora')).value?.lora.region.value;
    final duty = region == null ? null : LoraSection.dutyCycle(region);
    return [
      if (duty != null) WarningNote(MqttSection.dutyCycleWarning(duty)),
      ListenableBuilder(
        listenable: form,
        builder: (_, _) => form.value<bool>('proxyToClientEnabled')
            ? const WarningNote(MqttSection.proxyNote)
            : const SizedBox.shrink(),
      ),
      const Padding(
        padding: EdgeInsets.all(Tokens.s16),
        child: Text(MqttSection.channelsNote),
      ),
    ];
  },
);

final serialSpec = ConfigSectionSpec<ModuleConfig>(
  source: moduleConfigProvider.call,
  name: 'serial',
  title: SerialSection.title,
  confirm: SerialSection.saveConfirm,
  fields: (_) => SerialSection.fields(),
  read: (c) => SerialSection.read(c.serial),
  save: (admin, db, c, v, _) => SerialSection.save(admin, db, c.serial, v),
);

final externalNotificationSpec = ConfigSectionSpec<ModuleConfig>(
  source: moduleConfigProvider.call,
  name: 'externalNotification',
  title: ExternalNotificationSection.title,
  confirm: ExternalNotificationSection.saveConfirm,
  fields: (_) => ExternalNotificationSection.fields(),
  read: (c) => ExternalNotificationSection.read(c.externalNotification),
  save: (admin, db, c, v, _) =>
      ExternalNotificationSection.save(admin, db, c.externalNotification, v),
  extra: (context, ref, form, cfg) => [NodeTextTile(ringtone)],
);

final storeForwardSpec = ConfigSectionSpec<ModuleConfig>(
  source: moduleConfigProvider.call,
  name: 'storeForward',
  title: StoreForwardSection.title,
  confirm: StoreForwardSection.saveConfirm,
  fields: (_) => StoreForwardSection.fields(),
  read: (c) => StoreForwardSection.read(c.storeForward),
  save: (admin, db, c, v, _) =>
      StoreForwardSection.save(admin, db, c.storeForward, v),
  extra: (context, ref, form, cfg) => [
    ListenableBuilder(
      listenable: form,
      builder: (_, _) => StoreForwardSection.showServerNote(form.values)
          ? const WarningNote(StoreForwardSection.serverNote)
          : const SizedBox.shrink(),
    ),
  ],
);

final rangeTestSpec = ConfigSectionSpec<ModuleConfig>(
  source: moduleConfigProvider.call,
  name: 'rangeTest',
  title: RangeTestSection.title,
  confirm: RangeTestSection.saveConfirm,
  fields: (d) => RangeTestSection.fields(
    hasWifi: d.hasWifi,
    primaryPublic: d.primaryPublic,
  ),
  read: (c) => RangeTestSection.read(c.rangeTest),
  save: (admin, db, c, v, d) => RangeTestSection.save(
    admin,
    db,
    c.rangeTest,
    v,
    primaryPublic: d.primaryPublic,
  ),
  extra: (context, ref, form, cfg) {
    final primary = ref
        .watch(channelsProvider)
        .value
        ?.where((c) => c.index == 0)
        .firstOrNull;
    return [
      if (primary != null && isPublicPsk(primary.psk))
        const WarningNote(RangeTestSection.publicChannel),
    ];
  },
);

final telemetrySpec = ConfigSectionSpec<ModuleConfig>(
  source: moduleConfigProvider.call,
  name: 'telemetry',
  title: TelemetrySection.title,
  confirm: TelemetrySection.saveConfirm,
  fields: (d) => TelemetrySection.fields(firmware: d.firmware),
  read: (c) => TelemetrySection.read(c.telemetry),
  save: (admin, db, c, v, _) =>
      TelemetrySection.save(admin, db, c.telemetry, v),
);

final cannedMessageSpec = ConfigSectionSpec<ModuleConfig>(
  source: moduleConfigProvider.call,
  name: 'cannedMessage',
  title: CannedMessageSection.title,
  confirm: CannedMessageSection.saveConfirm,
  fields: (_) => CannedMessageSection.fields(),
  adjust: CannedMessageSection.adjust,
  read: (c) => CannedMessageSection.read(c.cannedMessage),
  save: (admin, db, c, v, _) =>
      CannedMessageSection.save(admin, db, c.cannedMessage, v),
  extra: (context, ref, form, cfg) => [NodeTextTile(cannedMessages)],
);

final audioSpec = ConfigSectionSpec<ModuleConfig>(
  source: moduleConfigProvider.call,
  name: 'audio',
  title: AudioSection.title,
  confirm: AudioSection.saveConfirm,
  fields: (_) => AudioSection.fields(),
  read: (c) => AudioSection.read(c.audio),
  save: (admin, db, c, v, _) => AudioSection.save(admin, db, c.audio, v),
);

final remoteHardwareSpec = ConfigSectionSpec<ModuleConfig>(
  source: moduleConfigProvider.call,
  name: 'remoteHardware',
  title: RemoteHardwareSection.title,
  confirm: RemoteHardwareSection.saveConfirm,
  fields: (_) => RemoteHardwareSection.fields(),
  read: (c) => RemoteHardwareSection.read(c.remoteHardware),
  save: (admin, db, c, v, _) =>
      RemoteHardwareSection.save(admin, db, c.remoteHardware, v),
);
