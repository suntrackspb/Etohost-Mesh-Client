import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../core/proto/mesh.dart';
import '../../../data/settings/admin_settings.dart';
import '../../../data/database.dart';
import '../../../data/settings/fields.dart';
import '../../../data/settings/settings_form.dart';
import '../../../ui/kit/kit.dart';
import 'settings_form_view.dart';

/// Что нужно странице раздела Config: всё, кроме виджетов, — в разделе.
class ConfigSectionSpec {
  const ConfigSectionSpec({
    required this.name,
    required this.title,
    required this.confirm,
    required this.fields,
    required this.read,
    required this.save,
    this.adjust,
    this.check,
    this.afterSave,
    this.extra,
  });

  /// Вариант Config (`lora`, `device`…).
  final String name;
  final String title;
  final String confirm;
  final List<FieldSpec<Object?>> Function(OwnDevice d) fields;
  final Map<String, Object?> Function(Config c) read;
  final Future<bool> Function(
    AdminSettings admin,
    AppDatabase db,
    Config base,
    Map<String, Object?> v,
  )
  save;
  final void Function(Map<String, Object?> v)? adjust;
  final String? Function(Map<String, Object?> v)? check;
  final void Function(WidgetRef ref)? afterSave;

  /// Дополнительные элементы под формой (кнопки и т. п.).
  final List<Widget> Function(
    BuildContext context,
    WidgetRef ref,
    SettingsForm form,
    Config cfg,
  )?
  extra;
}

/// Своя нода для построения полей: прошивка и модель.
typedef OwnDevice = ({
  String firmware,
  int hwModel,
  int role,
  bool hasWifi,
  bool hasEthernet,
});

class ConfigSectionPage extends ConsumerStatefulWidget {
  const ConfigSectionPage(this.spec, {super.key});

  final ConfigSectionSpec spec;

  @override
  ConsumerState<ConfigSectionPage> createState() => _ConfigSectionPageState();
}

class _ConfigSectionPageState extends ConsumerState<ConfigSectionPage> {
  SettingsForm? _form;

  @override
  void dispose() {
    _form?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    final cfgAsync = ref.watch(configProvider(spec.name));
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
        ? 'Нода ещё не прислала эти настройки'
        : null;
    if (problem != null) {
      body = EmptyState(icon: Icons.link_off, text: problem);
    } else if (cfg == null || device == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final data = spec.read(cfg);
      final form = _form ??= SettingsForm(
        spec.fields((
          firmware: device.firmware,
          hwModel: node?.hwModel ?? 0,
          role: node?.role ?? 0,
          hasWifi: device.metadata?.hasWifi ?? false,
          hasEthernet: device.metadata?.hasEthernet ?? false,
        )),
        data,
        adjust: spec.adjust,
        check: spec.check,
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
          ...?spec.extra?.call(context, ref, form, cfg),
          SaveBar(
            form: form,
            confirm: spec.confirm,
            onSave: () async {
              final admin = ref.read(adminSettingsProvider);
              final db = ref.read(databaseProvider);
              final ok = await form.submit(
                (v, _) => spec.save(admin, db, cfg, v),
              );
              if (ok) spec.afterSave?.call(ref);
            },
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(spec.title)),
      body: body,
    );
  }
}
