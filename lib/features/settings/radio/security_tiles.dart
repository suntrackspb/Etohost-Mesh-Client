import 'package:meshex/l10n/l10n.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/toasts.dart';
import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../data/settings/key_backup.dart';

import '../../../data/settings/security_section.dart';
import '../../../data/settings/settings_form.dart';
import '../../../ui/kit/kit.dart';

/// Публичный ключ (выводится из закрытого в форме) с кнопкой «Копировать»
/// и пересоздание закрытого ключа.
class SecurityKeyTiles extends StatelessWidget {
  const SecurityKeyTiles({super.key, required this.form});

  final SettingsForm form;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: form,
    builder: (context, _) {
      final priv = SecurityKey.decode(form.value<String>('privateKey'));
      return SectionCard(
        children: [
          FutureBuilder(
            future: priv == null
                ? Future.value(null)
                : SecurityKey.publicFor(priv),
            builder: (context, snap) =>
                _PublicKey(SecurityKey.encode(snap.data ?? const [])),
          ),
          MeshTile(
            title: context.builtIn(SecuritySection.regenerateLabel),
            subtitle: context.builtIn(SecuritySection.regenerateHelp),
            leading: const Icon(Icons.autorenew),
            onTap: form.saving ? null : () => _regenerate(context),
          ),
        ],
      );
    },
  );

  Future<void> _regenerate(BuildContext context) async {
    final strings = context.l10n;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(strings.areYouSure_b0069b),
        content: Text(context.builtIn(SecuritySection.regenerateConfirm)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(strings.cancel_0ec753),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(strings.regenerate_9bf881),
          ),
        ],
      ),
    );
    if (yes == true) {
      form.set('privateKey', SecurityKey.encode(SecurityKey.generatePrivate()));
    }
  }
}

class _PublicKey extends StatelessWidget {
  const _PublicKey(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.s16,
        vertical: Tokens.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key, size: 18),
              const SizedBox(width: Tokens.s8),
              Expanded(
                child: Text(context.builtIn(SecuritySection.publicKeyLabel)),
              ),
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: Text(context.l10n.copy_4a05d8),
                onPressed: text.isEmpty
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: text));
                        toasts.success(context.l10n.copied_892254);
                      },
              ),
            ],
          ),
          SelectableText(
            text.isEmpty ? '—' : text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontFamilyFallback: const ['Menlo', 'Courier'],
            ),
          ),
          const SizedBox(height: Tokens.s4),
          Text(
            context.builtIn(SecuritySection.publicKeyHelp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// «Резервная копия ключа» (KeyBackupRow, iOS; SecurityKeyBackupActions,
/// Android). Восстановление подставляет ключ в форму — сохранить кнопкой
/// раздела, как в iOS.
class KeyBackupCard extends ConsumerWidget {
  const KeyBackupCard({super.key, required this.form});

  final SettingsForm form;

  static String get _help => Platform.isIOS
      ? 'Создать резервную копию приватного ключа в связку ключей iCloud.'
      : 'Сохранить публичные и приватные ключи в безопасном зашифрованном '
            'хранилище на этом устройстве.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) {
        final key = form.value<String>('privateKey');
        final enabled = me != null && !form.saving;
        return SectionCard(
          title: context.l10n.keyBackup_30f9f7,
          children: [
            MeshTile(
              title: context.l10n.backup_72f931,
              subtitle: context.builtIn(_help),
              leading: const Icon(Icons.backup_outlined),
              trailing: const SizedBox.shrink(),
              onTap: enabled && SecurityKey.decode(key) != null
                  ? () => _backup(context, ref, me, key)
                  : null,
            ),
            MeshTile(
              title: context.l10n.restore_29f3b2,
              leading: const Icon(Icons.settings_backup_restore),
              trailing: const SizedBox.shrink(),
              onTap: enabled ? () => _restore(context, ref, me) : null,
            ),
            MeshTile(
              title: context.l10n.saveToFile_cdda1c,
              leading: const Icon(Icons.file_download_outlined),
              trailing: const SizedBox.shrink(),
              onTap: enabled && SecurityKey.decode(key) != null
                  ? () => _toFile(context, ref, me, key)
                  : null,
            ),
            MeshTile(
              title: context.l10n.loadFromFile_e47fd3,
              leading: const Icon(Icons.file_upload_outlined),
              trailing: const SizedBox.shrink(),
              onTap: enabled ? () => _fromFile(context, me) : null,
            ),
            MeshTile(
              title: context.l10n.deleteKeyBackup_2b8633,
              leading: const Icon(Icons.delete_outline),
              trailing: const SizedBox.shrink(),
              onTap: enabled ? () => _delete(context, ref) : null,
            ),
          ],
        );
      },
    );
  }

  static void _snack(BuildContext context, String text) => toasts.show(text);

  Future<void> _backup(
    BuildContext context,
    WidgetRef ref,
    int me,
    String key,
  ) async {
    final strings = context.l10n;
    final name = ref.read(ownNodeProvider).value?.longName;
    try {
      await ref.read(keyBackupStoreProvider).save(me, key, longName: name);
      if (context.mounted) {
        _snack(context, strings.keysBackedUpSecurely_249b39);
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotSave_6886a1((e).toString()));
      }
    }
  }

  Future<KeyBackup?> _pick(
    BuildContext context,
    List<KeyBackup> all,
    String text,
  ) => showDialog<KeyBackup>(
    context: context,
    builder: (c) => SimpleDialog(
      title: Text(text),
      children: [
        for (final b in all)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(c, b),
            child: Text(
              context.l10n.backup_5f3ad8(
                (b.label).toString(),
                (MaterialLocalizations.of(
                  c,
                ).formatMediumDate(b.time)).toString(),
              ),
            ),
          ),
      ],
    ),
  );

  Future<void> _restore(BuildContext context, WidgetRef ref, int me) async {
    final strings = context.l10n;
    final List<KeyBackup> all;
    try {
      all = await ref.read(keyBackupStoreProvider).all();
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.failedToRestoreKeysFromBackup_89248f);
      }
      return;
    }
    if (!context.mounted) return;
    if (all.isEmpty) {
      _snack(context, strings.noKeyBackupFoundForThis_ce5803);
      return;
    }
    // Своя копия — сразу; иначе выбор (в 2.8 номер ноды меняется с ключом).
    final own = all.where((b) => b.nodeNum == me).firstOrNull;
    final b =
        own ??
        await _pick(context, all, strings.pickTheBackupToRestoreTo_92df2d);
    if (b == null || !context.mounted) return;
    form.set('privateKey', b.privateKey);
    _snack(context, strings.keyRestoredSaveTheSettings_92bb30);
  }

  Future<void> _toFile(
    BuildContext context,
    WidgetRef ref,
    int me,
    String key,
  ) async {
    final strings = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(strings.exportPrivateKey_8cfcb4),
        content: Text(strings.theJsonFileContainsTheUnencrypted_470e15),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(strings.cancel_0ec753),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(strings.saveFile_d10137),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final name = ref.read(ownNodeProvider).value?.longName;
    final b = await KeyBackup.make(me, key, longName: name);
    if (b == null) return;
    try {
      final uri = await FilePicker.saveFile(
        dialogTitle: strings.saveToFile_cdda1c,
        fileName: KeyBackupFile.fileName(me),
        bytes: KeyBackupFile.encode([b]),
        mimeType: 'application/json',
        type: FileType.custom,
        allowedExtensions: const [KeyBackupFile.extension],
      );
      if (uri != null && context.mounted) {
        _snack(context, strings.keysSavedToAFileKeep_32f5b4);
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotSave_6886a1((e).toString()));
      }
    }
  }

  Future<void> _fromFile(BuildContext context, int me) async {
    final strings = context.l10n;
    final List<KeyBackup> keys;
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: strings.loadFromFile_e47fd3,
      );
      if (files.isEmpty) return;
      keys = KeyBackupFile.decode(await files.first.readAsBytes());
    } on FormatException catch (e) {
      if (context.mounted) _snack(context, e.message);
      return;
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotReadFile_425230((e).toString()));
      }
      return;
    }
    if (!context.mounted) return;
    final own = keys.where((b) => b.nodeNum == me).firstOrNull;
    final b =
        own ??
        (keys.length == 1
            ? keys.single
            : await _pick(context, keys, strings.chooseAKeyToRestore_9fa859));
    if (b == null || !context.mounted) return;
    form.set('privateKey', b.privateKey);
    _snack(
      context,
      own == null
          ? strings.keySelectedSaveTheSettingsOnly_f2a281((b.label).toString())
          : strings.keyRestoredSaveTheSettings_92bb30,
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final strings = context.l10n;
    final store = ref.read(keyBackupStoreProvider);
    final all = await store.all();
    if (!context.mounted) return;
    if (all.isEmpty) {
      _snack(context, strings.noKeyBackupFoundForThis_ce5803);
      return;
    }
    final b = await _pick(
      context,
      all,
      strings.pickTheEncryptedKeyBackupTo_5e150c,
    );
    if (b == null) return;
    await store.delete(b.nodeNum);
    if (context.mounted) _snack(context, strings.keyBackupDeleted_2ed312);
  }
}
