import 'package:flutter/material.dart';

import '../../../app/providers.dart';
import '../../../data/settings/device_section.dart';
import '../../../data/settings/lora_section.dart';
import '../../../ui/kit/kit.dart';
import 'config_section_page.dart';

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
  extra: (context, form) => [
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
