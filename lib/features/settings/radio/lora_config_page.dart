import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../data/settings/lora_section.dart';
import '../../../data/settings/settings_form.dart';
import '../../../ui/kit/kit.dart';
import 'settings_form_view.dart';

/// Настройки LoRa своей ноды.
class LoraConfigPage extends ConsumerStatefulWidget {
  const LoraConfigPage({super.key});

  @override
  ConsumerState<LoraConfigPage> createState() => _LoraConfigPageState();
}

class _LoraConfigPageState extends ConsumerState<LoraConfigPage> {
  SettingsForm? _form;

  @override
  void dispose() {
    _form?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    final cfgAsync = ref.watch(configProvider('lora'));
    final device = ref.watch(ownDeviceProvider).value;
    final node = ref.watch(ownNodeProvider).value;
    final canSend = ref.watch(canSendProvider);
    final cfg = cfgAsync.value;

    Widget body;
    final problem = me == null
        ? 'Подключитесь к своей ноде'
        : cfgAsync.hasError
        ? 'Ошибка чтения конфигурации: ${cfgAsync.error}'
        : cfg == null && !cfgAsync.isLoading
        ? 'Нода ещё не прислала настройки LoRa'
        : null;
    if (problem != null) {
      body = EmptyState(icon: Icons.link_off, text: problem);
    } else if (cfg == null || device == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final data = LoraSection.read(cfg.lora);
      final form = _form ??= SettingsForm(
        LoraSection.fields(
          firmware: device.firmware,
          hwModel: node?.hwModel ?? 0,
        ),
        data,
        adjust: LoraSection.adjust,
        check: LoraSection.check,
      );
      if (!mapEquals(form.values, data) && !form.dirty && !form.saving) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) form.reload(data);
        });
      }
      body = ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          AbsorbPointer(
            absorbing: !canSend,
            child: SettingsFormView(form: form),
          ),
          SaveBar(
            form: form,
            confirm: LoraSection.saveConfirm,
            onSave: () async {
              final admin = ref.read(adminSettingsProvider);
              final db = ref.read(databaseProvider);
              final ok = await form.submit(
                (v, _) => LoraSection.save(admin, db, cfg.lora, v),
              );
              if (ok) ref.read(radioProvider).refreshNodes();
            },
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text(LoraSection.title)),
      body: body,
    );
  }
}
