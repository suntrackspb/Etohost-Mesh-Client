import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../app/toasts.dart';
import '../../../core/proto/mesh.dart';
import '../../../data/settings/device_profile.dart';
import '../../../data/settings/profile_store.dart';
import '../../../ui/kit/kit.dart';
import '../../../app/link_badge.dart';

/// «Резервная копия и восстановление»: конфигурация ноды в файл `.cfg`
/// (DeviceProfile, совместим с iOS/Android) и обратно.
class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  bool _busy = false;
  String? _progress;

  @override
  Widget build(BuildContext context) {
    final canSend = ref.watch(canSendProvider);
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    final enabled = me != null && !_busy;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Резервная копия и восстановление'),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          if (me == null) const WarningNote('Подключитесь к своей ноде'),
          SectionCard(
            children: [
              MeshTile(
                title: 'Экспорт настроек',
                subtitle: 'Файл .cfg, как в официальных приложениях',
                leading: const Icon(Icons.upload_file),
                trailing: const SizedBox.shrink(),
                onTap: enabled ? _export : null,
              ),
              MeshTile(
                title: 'Импорт настроек',
                subtitle: 'Записать конфигурацию из файла в ноду',
                leading: const Icon(Icons.download),
                trailing: const SizedBox.shrink(),
                onTap: enabled && canSend ? _import : null,
              ),
            ],
          ),
          if (_busy) ...[
            const LinearProgressIndicator(),
            if (_progress != null)
              Padding(
                padding: const EdgeInsets.only(top: Tokens.s8),
                child: Text(_progress!),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _export() async {
    final me = ref.read(radioProvider).myNodeNum;
    if (me == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Экспорт настроек'),
        content: const Text(
          'В файле будут ключи ноды, ключи каналов и пароли Wi-Fi/MQTT. '
          'Не передавайте его посторонним.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final src = await loadProfileSource(ref.read(databaseProvider), me);
      final bytes = buildProfile(src).writeToBuffer();
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Сохранить в файл',
        fileName: profileFileName(src.shortName, DateTime.now()),
        bytes: bytes,
      );
      if (uri != null) toasts.success('Настройки сохранены');
    } catch (e) {
      toasts.error('Не удалось сохранить: $e');
    }
  }

  Future<void> _import() async {
    final me = ref.read(radioProvider).myNodeNum;
    if (me == null) return;
    final DeviceProfile profile;
    try {
      final files = await FilePicker.pickFiles(dialogTitle: 'Импорт настроек');
      if (files.isEmpty) return;
      profile = parseProfile(await files.first.readAsBytes());
    } on FormatException catch (e) {
      toasts.error(e.message);
      return;
    } catch (e) {
      toasts.error('Не удалось открыть файл: $e');
      return;
    }
    final src = await loadProfileSource(ref.read(databaseProvider), me);
    final plan = planProfile(
      profile,
      owner: User(
        longName: src.longName ?? '',
        shortName: src.shortName ?? '',
        isUnmessagable: src.isUnmessagable,
      ),
      security: src.configs['security']?.security,
      firmware: ref.read(ownDeviceProvider).value?.firmware ?? '',
      currentModules: src.modules,
    );
    if (plan.items.isEmpty) {
      toasts.error('В файле нет настроек');
      return;
    }
    if (!mounted) return;
    final on = await showDialog<Set<ProfileSection>>(
      context: context,
      builder: (_) => _ReviewDialog(plan),
    );
    if (on == null || on.isEmpty) return;
    final admin = ref.read(adminSettingsProvider);
    setState(() => _busy = true);
    final r = await applyProfile(
      plan.selected(on),
      send: admin.send,
      progress: (done, total, label) {
        if (mounted) setState(() => _progress = '$done / $total  $label');
      },
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _progress = null;
    });
    if (r.ok) {
      toasts.success('Настройки записаны, нода перезагрузится');
    } else {
      toasts.error(
        r.failed == null
            ? 'Основное записано. Не записано (нода перезагрузилась): '
                  '${r.pending.join(', ')} — задайте вручную'
            : 'Остановлено на «${r.failed}»'
                  '${r.committed ? ' (основное сохранено)' : ''}',
      );
    }
  }
}

/// Что из файла записать: группы с флажками, неподдерживаемое — списком.
class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog(this.plan);
  final ProfilePlan plan;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  late final Set<ProfileSection> _on = {
    for (final s in widget.plan.sections)
      if (s.defaultOn) s,
  };

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final muted = Theme.of(context).textTheme.bodySmall;
    return AlertDialog(
      title: const Text('Импорт настроек'),
      content: SizedBox(
        width: 420,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final s in ProfileSection.values)
              if (plan.sections.contains(s))
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _on.contains(s),
                  onChanged: (v) =>
                      setState(() => v == true ? _on.add(s) : _on.remove(s)),
                  title: Text(s.title),
                  subtitle: Text(
                    [
                      for (final i in plan.items)
                        if (i.section == s) i.label,
                    ].join(', '),
                    style: muted,
                  ),
                ),
            if (plan.sections.contains(ProfileSection.security))
              Text(
                'Безопасность меняет ключи и админ-доступ ноды — '
                'включайте, только если это копия этой же ноды.',
                style: muted,
              ),
            if (plan.items.any((i) => i.afterCommit && _on.contains(i.section)))
              Padding(
                padding: const EdgeInsets.only(top: Tokens.s8),
                child: Text(
                  'Последними записываются: '
                  '${[for (final i in plan.items)
                    if (i.afterCommit) i.label].join(', ')}. '
                  'После них нода перезагрузится, связь ненадолго прервётся.',
                  style: muted,
                ),
              ),
            if (plan.unsupported.isNotEmpty) ...[
              const SizedBox(height: Tokens.s8),
              Text('Пропущено: ${plan.unsupported.join('; ')}', style: muted),
            ],
            const SizedBox(height: Tokens.s8),
            Text(
              'После записи нода перезагрузится и подключение прервётся.',
              style: muted,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _on.isEmpty ? null : () => Navigator.pop(context, _on),
          child: const Text('Записать'),
        ),
      ],
    );
  }
}
