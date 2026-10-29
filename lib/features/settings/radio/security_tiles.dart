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
            title: SecuritySection.regenerateLabel,
            subtitle: SecuritySection.regenerateHelp,
            leading: const Icon(Icons.autorenew),
            onTap: form.saving ? null : () => _regenerate(context),
          ),
        ],
      );
    },
  );

  Future<void> _regenerate(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Вы уверены?'),
        content: const Text(SecuritySection.regenerateConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Пересоздать'),
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
              const Expanded(child: Text(SecuritySection.publicKeyLabel)),
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Копировать'),
                onPressed: text.isEmpty
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: text));
                        toasts.success('Скопировано');
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
            SecuritySection.publicKeyHelp,
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
          title: 'Резервная копия ключа',
          children: [
            MeshTile(
              title: 'Резервная копия',
              subtitle: _help,
              leading: const Icon(Icons.backup_outlined),
              trailing: const SizedBox.shrink(),
              onTap: enabled && SecurityKey.decode(key) != null
                  ? () => _backup(context, ref, me, key)
                  : null,
            ),
            MeshTile(
              title: 'Восстановить',
              leading: const Icon(Icons.settings_backup_restore),
              trailing: const SizedBox.shrink(),
              onTap: enabled ? () => _restore(context, ref, me) : null,
            ),
            MeshTile(
              title: 'Сохранить в файл',
              leading: const Icon(Icons.file_download_outlined),
              trailing: const SizedBox.shrink(),
              onTap: enabled && SecurityKey.decode(key) != null
                  ? () => _toFile(context, ref, me, key)
                  : null,
            ),
            MeshTile(
              title: 'Загрузить из файла',
              leading: const Icon(Icons.file_upload_outlined),
              trailing: const SizedBox.shrink(),
              onTap: enabled ? () => _fromFile(context, me) : null,
            ),
            MeshTile(
              title: 'Удалить резервную копию ключа',
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
    final name = ref.read(ownNodeProvider).value?.longName;
    try {
      await ref.read(keyBackupStoreProvider).save(me, key, longName: name);
      if (context.mounted) _snack(context, 'Ключи надежно сохранены');
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось сохранить: $e');
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
              '${b.label}, резервное копирование '
              '${MaterialLocalizations.of(c).formatMediumDate(b.time)}',
            ),
          ),
      ],
    ),
  );

  Future<void> _restore(BuildContext context, WidgetRef ref, int me) async {
    final List<KeyBackup> all;
    try {
      all = await ref.read(keyBackupStoreProvider).all();
    } catch (e) {
      if (context.mounted) {
        _snack(context, 'Не удалось восстановить ключи из резервной копии');
      }
      return;
    }
    if (!context.mounted) return;
    if (all.isEmpty) {
      _snack(context, 'Для этой ноды не найдено резервной копии ключа');
      return;
    }
    // Своя копия — сразу; иначе выбор (в 2.8 номер ноды меняется с ключом).
    final own = all.where((b) => b.nodeNum == me).firstOrNull;
    final b =
        own ??
        await _pick(
          context,
          all,
          'Выбери резервную копию для восстановления этой ноды. Сброс '
          'настроек или новый ключ меняет ID узла, поэтому старые резервные '
          'копии остаются под старым ID. Восстанавливай только резервную '
          'копию, взятую с этого же устройства: другой ключ дает обеим '
          'радиоустройствам одинаковый идентификатор.',
        );
    if (b == null || !context.mounted) return;
    form.set('privateKey', b.privateKey);
    _snack(context, 'Ключ восстановлен — сохраните настройки');
  }

  Future<void> _toFile(
    BuildContext context,
    WidgetRef ref,
    int me,
    String key,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Экспорт приватного ключа'),
        content: const Text(
          'JSON-файл содержит незашифрованный приватный ключ ноды. '
          'Любой, у кого есть этот файл, сможет использовать ключ вашей ноды. '
          'Храните файл в защищённом месте и не передавайте посторонним.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Сохранить файл'),
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
        dialogTitle: 'Сохранить в файл',
        fileName: KeyBackupFile.fileName(me),
        bytes: KeyBackupFile.encode([b]),
        mimeType: 'application/json',
        type: FileType.custom,
        allowedExtensions: const [KeyBackupFile.extension],
      );
      if (uri != null && context.mounted) {
        _snack(context, 'Ключи сохранены в файл. Храните его в надёжном месте');
      }
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось сохранить: $e');
    }
  }

  Future<void> _fromFile(BuildContext context, int me) async {
    final List<KeyBackup> keys;
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: 'Загрузить из файла',
      );
      if (files.isEmpty) return;
      keys = KeyBackupFile.decode(await files.first.readAsBytes());
    } on FormatException catch (e) {
      if (context.mounted) _snack(context, e.message);
      return;
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось прочитать файл: $e');
      return;
    }
    if (!context.mounted) return;
    final own = keys.where((b) => b.nodeNum == me).firstOrNull;
    final b =
        own ??
        (keys.length == 1
            ? keys.single
            : await _pick(context, keys, 'Выбери ключ для восстановления'));
    if (b == null || !context.mounted) return;
    form.set('privateKey', b.privateKey);
    _snack(
      context,
      own == null
          ? 'Ключ ${b.label} подставлен — сохраните настройки. Ставьте ключ '
                'только на ту ноду, с которой он снят'
          : 'Ключ восстановлен — сохраните настройки',
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final store = ref.read(keyBackupStoreProvider);
    final all = await store.all();
    if (!context.mounted) return;
    if (all.isEmpty) {
      _snack(context, 'Для этой ноды не найдено резервной копии ключа');
      return;
    }
    final b = await _pick(
      context,
      all,
      'Выбери резервную копию зашифрованного ключа для удаления с этого '
      'устройства. Это не может быть отменено.',
    );
    if (b == null) return;
    await store.delete(b.nodeNum);
    if (context.mounted) _snack(context, 'Резервная копия ключа удалена');
  }
}
