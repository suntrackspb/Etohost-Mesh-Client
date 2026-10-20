import 'package:flutter/material.dart';

import '../../../app/providers.dart';
import '../../../data/settings/bluetooth_section.dart';
import '../../../data/settings/device_section.dart';
import '../../../data/settings/display_section.dart';
import '../../../app/settings_providers.dart';
import '../../../data/settings/lora_section.dart';
import '../../../data/settings/network_section.dart';
import '../../../data/settings/position_section.dart';
import '../../../data/settings/power_section.dart';
import '../../../data/settings/security_section.dart';
import '../../../ui/kit/kit.dart';
import 'config_section_page.dart';
import 'fixed_position_tile.dart';
import 'security_tiles.dart';

/// Разделы Config своей ноды: логика — в `lib/data/settings/*_section.dart`.
final loraSpec = ConfigSectionSpec(
  name: 'lora',
  title: LoraSection.title,
  confirm: LoraSection.saveConfirm,
  fields: (d) => LoraSection.fields(firmware: d.firmware, hwModel: d.hwModel),
  read: (c) => LoraSection.read(c.lora),
  save: (admin, db, c, v) => LoraSection.save(admin, db, c.lora, v),
  adjust: LoraSection.adjust,
  check: LoraSection.check,
  // 2.8 применяет LoRa без перезагрузки — перечитать базу нод.
  afterSave: (ref) => ref.read(radioProvider).refreshNodes(),
);

final deviceSpec = ConfigSectionSpec(
  name: 'device',
  title: DeviceSection.title,
  confirm: DeviceSection.saveConfirm,
  fields: (_) => DeviceSection.fields(),
  read: (c) => DeviceSection.read(c.device),
  save: (admin, db, c, v) => DeviceSection.save(admin, db, c.device, v),
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

final positionSpec = ConfigSectionSpec(
  name: 'position',
  title: PositionSection.title,
  confirm: PositionSection.saveConfirm,
  fields: (_) => PositionSection.fields(),
  read: (c) => PositionSection.read(c.position),
  save: (admin, db, c, v) => PositionSection.save(admin, db, c.position, v),
  extra: (context, ref, form, cfg) => [
    if (PositionSection.fixedAvailable(
      form.value<int>('gpsMode'),
      cfg.position.fixedPosition,
    ))
      FixedPositionTile(cfg: cfg.position),
  ],
);

final powerSpec = ConfigSectionSpec(
  name: 'power',
  title: PowerSection.title,
  confirm: PowerSection.saveConfirm,
  fields: (d) => PowerSection.fields(hwModel: d.hwModel, role: d.role),
  read: (c) => PowerSection.read(c.power),
  save: (admin, db, c, v) => PowerSection.save(admin, db, c.power, v),
);

final networkSpec = ConfigSectionSpec(
  name: 'network',
  title: NetworkSection.title,
  confirm: NetworkSection.saveConfirm,
  fields: (d) =>
      NetworkSection.fields(hasWifi: d.hasWifi, hasEthernet: d.hasEthernet),
  read: (c) => NetworkSection.read(c.network),
  save: (admin, db, c, v) => NetworkSection.save(admin, db, c.network, v),
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

final bluetoothSpec = ConfigSectionSpec(
  name: 'bluetooth',
  title: BluetoothSection.title,
  confirm: BluetoothSection.saveConfirm,
  fields: (_) => BluetoothSection.fields(),
  read: (c) => BluetoothSection.read(c.bluetooth),
  save: (admin, db, c, v) => BluetoothSection.save(admin, db, c.bluetooth, v),
);

final displaySpec = ConfigSectionSpec(
  name: 'display',
  title: DisplaySection.title,
  confirm: DisplaySection.saveConfirm,
  fields: (_) => DisplaySection.fields(),
  read: (c) => DisplaySection.read(c.display),
  save: (admin, db, c, v) => DisplaySection.save(admin, db, c.display, v),
);

final securitySpec = ConfigSectionSpec(
  name: 'security',
  title: SecuritySection.title,
  confirm: SecuritySection.saveConfirm,
  fields: (d) => SecuritySection.fields(xeddsa: d.xeddsa),
  read: (c) => SecuritySection.read(c.security),
  save: (admin, db, c, v) => SecuritySection.save(admin, db, c.security, v),
  adjust: SecuritySection.adjust,
  extra: (context, ref, form, cfg) {
    final xeddsa = ref.watch(ownDeviceProvider).value?.metadata?.hasXeddsa;
    return [
      if (xeddsa == null) const SecurityNote(SecuritySection.unknownXeddsa),
      SecurityKeyTiles(form: form),
      ListenableBuilder(
        listenable: form,
        builder: (_, _) => SecuritySection.hasAdminKey(form.values)
            ? const SizedBox.shrink()
            : const SecurityNote(SecuritySection.managedNeedsAdmin),
      ),
    ];
  },
);
