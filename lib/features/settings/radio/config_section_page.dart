import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../data/settings/admin_settings.dart';
import '../../../data/database.dart';
import '../../../data/settings/fields.dart';
import '../../../data/settings/range_test_section.dart';
import '../../../data/settings/settings_form.dart';
import '../../../ui/kit/kit.dart';
import 'settings_form_view.dart';
import '../../../app/link_badge.dart';

/// Что нужно странице раздела Config или ModuleConfig ([C]): всё, кроме
/// виджетов, — в разделе.
class ConfigSectionSpec<C> {
  const ConfigSectionSpec({
    required this.source,
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
    this.after,
  });

  /// Сохранённый конфиг по имени: `configProvider` или `moduleConfigProvider`.
  final ProviderListenable<AsyncValue<C?>> Function(String name) source;

  /// Вариант Config / ModuleConfig (`lora`, `mqtt`…).
  final String name;
  final String title;
  final String confirm;
  final List<FieldSpec<Object?>> Function(OwnDevice d) fields;
  final Map<String, Object?> Function(C c) read;
  final Future<bool> Function(
    AdminSettings admin,
    AppDatabase db,
    C base,
    Map<String, Object?> v,
    OwnDevice device,
  )
  save;
  final void Function(Map<String, Object?> v)? adjust;
  final String? Function(Map<String, Object?> v)? check;
  final void Function(ProviderContainer c)? afterSave;

  /// Дополнительные элементы под формой (кнопки и т. п.).
  final List<Widget> Function(
    BuildContext context,
    WidgetRef ref,
    SettingsForm form,
    C cfg,
  )?
  extra;

  /// Свои блоки между группами: заголовок группы → блоки после неё.
  final Map<String, List<Widget>> Function(
    BuildContext context,
    WidgetRef ref,
    SettingsForm form,
    C cfg,
  )?
  after;
}

/// Своя нода для построения полей: прошивка и модель.
typedef OwnDevice = ({
  String firmware,
  int hwModel,
  int role,
  bool hasWifi,
  bool hasEthernet,

  /// Подпись XEdDSA (metadata.has_xeddsa); null — нода не сообщила.
  bool? xeddsa,

  /// Основной канал без ключа или с однобайтовым ключом по умолчанию.
  bool primaryPublic,
});

class ConfigSectionPage<C> extends ConsumerStatefulWidget {
  const ConfigSectionPage(this.spec, {super.key});

  final ConfigSectionSpec<C> spec;

  @override
  ConsumerState<ConfigSectionPage<C>> createState() =>
      _ConfigSectionPageState<C>();
}

class _ConfigSectionPageState<C> extends ConsumerState<ConfigSectionPage<C>> {
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
    final cfgAsync = ref.watch(spec.source(spec.name));
    final device = ref.watch(ownDeviceProvider).value;
    final node = ref.watch(ownNodeProvider).value;
    final canSend = ref.watch(canSendProvider);
    final channels = ref.watch(channelsProvider).value ?? const [];
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
      final own = (
        firmware: device.firmware,
        hwModel: node?.hwModel ?? 0,
        role: node?.role ?? 0,
        hasWifi: device.metadata?.hasWifi ?? false,
        hasEthernet: device.metadata?.hasEthernet ?? false,
        xeddsa: device.metadata?.hasXeddsa,
        primaryPublic: isPublicPsk(
          channels.where((c) => c.index == 0).firstOrNull?.psk,
        ),
      );
      final form = _form ??= SettingsForm(
        spec.fields(own),
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
            child: SettingsFormView(
              form: form,
              after: spec.after?.call(context, ref, form, cfg) ?? const {},
            ),
          ),
          ...?spec.extra?.call(context, ref, form, cfg),
          SaveBar(
            form: form,
            confirm: spec.confirm,
            onSave: () async {
              final admin = ref.read(adminSettingsProvider);
              final db = ref.read(databaseProvider);
              // Экран могут закрыть, пока ждём ноду: после await `ref`
              // уже нельзя трогать, контейнер провайдеров — можно.
              final container = ProviderScope.containerOf(
                context,
                listen: false,
              );
              final ok = await form.submit(
                (v, _) => spec.save(admin, db, cfg, v, own),
              );
              if (ok) spec.afterSave?.call(container);
            },
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(spec.title), actions: const [LinkBadge()]),
      body: body,
    );
  }
}
