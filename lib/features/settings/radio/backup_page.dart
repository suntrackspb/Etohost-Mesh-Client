import 'package:meshex/l10n/l10n.dart';
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
        title: Text(context.l10n.backupRestore_e10c3e),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          if (me == null) WarningNote(context.l10n.connectToYourOwnNode_d2f276),
          SectionCard(
            children: [
              MeshTile(
                title: context.l10n.exportConfiguration_af2d98,
                subtitle: context.l10n.aCfgFileAsUsedBy_8cf2f0,
                leading: const Icon(Icons.upload_file),
                trailing: const SizedBox.shrink(),
                onTap: enabled ? _export : null,
              ),
              MeshTile(
                title: context.l10n.importConfiguration_c776ef,
                subtitle: context.l10n.writeConfigurationFromAFileTo_5b4b13,
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
                child: Text(context.builtIn(_progress!)),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _export() async {
    final strings = context.l10n;
    final me = ref.read(radioProvider).myNodeNum;
    if (me == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(strings.exportConfiguration_af2d98),
        content: Text(strings.theFileWillContainNodeKeys_7a17b9),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(strings.cancel_0ec753),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(strings.save_486405),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final src = await loadProfileSource(ref.read(databaseProvider), me);
      final bytes = buildProfile(src).writeToBuffer();
      final uri = await FilePicker.saveFile(
        dialogTitle: strings.saveToFile_cdda1c,
        fileName: profileFileName(src.shortName, DateTime.now()),
        bytes: bytes,
      );
      if (uri != null) toasts.success(strings.settingsSaved_0c3942);
    } catch (e) {
      toasts.error(strings.couldNotSave_6886a1((e).toString()));
    }
  }

  Future<void> _import() async {
    final strings = context.l10n;
    final me = ref.read(radioProvider).myNodeNum;
    if (me == null) return;
    final DeviceProfile profile;
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: strings.importConfiguration_c776ef,
      );
      if (files.isEmpty) return;
      profile = parseProfile(await files.first.readAsBytes());
    } on FormatException catch (e) {
      toasts.error(e.message);
      return;
    } catch (e) {
      toasts.error(strings.couldNotOpenFile_7fa8ac((e).toString()));
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
      toasts.error(strings.theFileContainsNoSettings_6865dd);
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
      toasts.success(strings.settingsWrittenTheNodeWillRestart_ce3279);
    } else {
      toasts.error(
        r.failed == null
            ? strings.mainSettingsWrittenNotWrittenNode_5d2582(
                (r.pending.join(', ')).toString(),
              )
            : strings.stoppedAt_546fe2(
                (r.failed).toString(),
                (r.committed ? context.l10n.mainSettingsSaved_00e02d : '')
                    .toString(),
              ),
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
      title: Text(context.l10n.importConfiguration_c776ef),
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
                  title: Text(context.builtIn(s.title)),
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
                context.l10n.securityChangesNodeKeysAndAdmin_a52c58,
                style: muted,
              ),
            if (plan.items.any((i) => i.afterCommit && _on.contains(i.section)))
              Padding(
                padding: const EdgeInsets.only(top: Tokens.s8),
                child: Text(
                  context.l10n.writtenLastTheNodeWillThen_35a22d(
                    ([
                      for (final i in plan.items)
                        if (i.afterCommit) i.label,
                    ].join(', ')).toString(),
                  ),
                  style: muted,
                ),
              ),
            if (plan.unsupported.isNotEmpty) ...[
              const SizedBox(height: Tokens.s8),
              Text(
                context.l10n.skipped_29ab80(
                  (plan.unsupported.join('; ')).toString(),
                ),
                style: muted,
              ),
            ],
            const SizedBox(height: Tokens.s8),
            Text(
              context.l10n.theNodeWillRestartAfterWriting_a91c98,
              style: muted,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel_0ec753),
        ),
        FilledButton(
          onPressed: _on.isEmpty ? null : () => Navigator.pop(context, _on),
          child: Text(context.l10n.write_4be730),
        ),
      ],
    );
  }
}
