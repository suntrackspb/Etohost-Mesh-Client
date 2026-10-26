import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/toasts.dart';
import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/node_db_store.dart';
import '../../data/node_dbs.dart';
import '../../ui/kit/kit.dart';
import '../../app/link_badge.dart';

/// Настройки → Данные: базы нод (у каждой своя), экспорт, импорт, удаление.
class DataSettingsPage extends ConsumerWidget {
  const DataSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbs = ref.watch(nodeDbListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Данные'), actions: const [LinkBadge()]),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            title: 'Базы нод',
            footer:
                'У каждой ноды своя база: ноды, каналы, сообщения и копия '
                'зеркала. Сверх заданного числа самая давно не '
                'использованная база удаляется вместе с перепиской; 0 — '
                'хранить все. Открытую базу удалить нельзя.',
            children: [
              const _DbLimitTile(),
              ...switch (dbs) {
                AsyncData(:final value) => [
                  for (final db in value)
                    MeshTile(
                      title: db.name,
                      subtitle: db.active
                          ? 'Открыта · ${_size(db.bytes)}'
                          : _size(db.bytes),
                      leading: Icon(
                        db.active ? Icons.storage : Icons.storage_outlined,
                      ),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () => _menu(context, ref, db),
                    ),
                ],
                AsyncError(:final error) => [
                  MeshTile(title: 'Не удалось прочитать: $error'),
                ],
                _ => [const LinearProgressIndicator()],
              },
            ],
          ),
          SectionCard(
            children: [
              MeshTile(
                title: 'Импорт базы ноды из файла',
                leading: const Icon(Icons.file_open_outlined),
                onTap: () => _import(context, ref),
              ),
            ],
          ),
          const SizedBox(height: Tokens.s16),
          const _PurgeStaleCard(),
          SectionCard(
            title: 'База приложения',
            footer:
                'Настройки приложения и недавние подключения — например, '
                'чтобы вернуть их после переустановки. В файле адреса '
                'ваших нод и зеркала: никому его не передавайте.',
            children: [
              MeshTile(
                title: 'Экспорт в файл',
                leading: const Icon(Icons.save_alt),
                onTap: () => _exportApp(context, ref),
              ),
              MeshTile(
                title: 'Импорт из файла',
                leading: const Icon(Icons.file_open_outlined),
                onTap: () => _importApp(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _size(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()} КБ';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} МБ';
  }

  static void _snack(BuildContext context, String text) => toasts.show(text);

  Future<void> _menu(BuildContext context, WidgetRef ref, NodeDbInfo db) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Экспорт в файл'),
              onTap: () => Navigator.pop(context, 'export'),
            ),
            if (!db.active &&
                db.num != noNodeDb &&
                ref.read(activeNodeDbProvider) != noNodeDb)
              ListTile(
                leading: const Icon(Icons.move_down),
                title: const Text('Перенести в открытую базу'),
                onTap: () => Navigator.pop(context, 'transfer'),
              ),
            if (!db.active)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Удалить'),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'export':
        await _export(context, ref, db);
      case 'transfer':
        await _transfer(context, ref, db);
      case 'delete':
        await _delete(context, ref, db);
    }
  }

  /// Нода сменила номер (ключ тот же): переписка старой базы — в текущую.
  Future<void> _transfer(
    BuildContext context,
    WidgetRef ref,
    NodeDbInfo db,
  ) async {
    final actions = ref.read(nodeDbActionsProvider);
    final bool? same;
    try {
      same = await actions.sameOwnKey(db.num);
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось прочитать: $e');
      return;
    }
    if (!context.mounted) return;
    final ok = await _confirm(
      context,
      'Перенести сообщения?',
      'Сообщения из базы ${db.name} будут добавлены в открытую базу, '
          'старый номер своей ноды заменится текущим. Старая база '
          'останется — её можно удалить потом.'
          '${switch (same) {
            true => '',
            false => '\n\nВнимание: ключ своей ноды в этих базах разный — '
                'похоже, это другая нода.',
            null => '\n\nКлюч своей ноды неизвестен — проверить, что это '
                'та же нода, нельзя.',
          }}',
      'Перенести',
    );
    if (!ok || !context.mounted) return;
    try {
      final n = await actions.transfer(db.num);
      if (context.mounted) _snack(context, 'Перенесено сообщений: $n');
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось перенести: $e');
    }
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    NodeDbInfo db,
  ) async {
    try {
      final bytes = await ref.read(nodeDbActionsProvider).export(db.num);
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Сохранить в файл',
        fileName: nodeDbExportName(db.num, DateTime.now()),
        bytes: bytes,
      );
      if (uri != null && context.mounted) _snack(context, 'База сохранена');
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось сохранить: $e');
    }
  }

  Future<void> _exportApp(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      'Экспорт настроек',
      'В файле будут адреса ваших нод и зеркала. Храните его у себя и '
          'никому не передавайте.',
      'Сохранить',
    );
    if (!ok || !context.mounted) return;
    try {
      final bytes = await ref.read(nodeDbActionsProvider).exportApp();
      final uri = await FilePicker.saveFile(
        dialogTitle: 'Сохранить в файл',
        fileName: nodeDbExportName(null, DateTime.now()),
        bytes: bytes,
      );
      if (uri != null && context.mounted) {
        _snack(context, 'Настройки сохранены');
      }
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось сохранить: $e');
    }
  }

  Future<void> _importApp(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      'Импорт настроек',
      'Текущие настройки приложения и недавние подключения будут заменены '
          'данными из файла. Базы нод не изменятся.',
      'Выбрать файл',
    );
    if (!ok || !context.mounted) return;
    try {
      final files = await FilePicker.pickFiles(dialogTitle: 'Импорт из файла');
      if (files.isEmpty || !context.mounted) return;
      final n = await ref
          .read(nodeDbActionsProvider)
          .importApp(await files.first.readAsBytes());
      if (context.mounted) _snack(context, 'Настройки загружены ($n)');
    } on FormatException catch (e) {
      if (context.mounted) _snack(context, e.message);
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось загрузить: $e');
    }
  }

  static Future<bool> _confirm(
    BuildContext context,
    String title,
    String text,
    String action,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ==
      true;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    NodeDbInfo db,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить базу?'),
        content: Text(
          '${db.name}: ноды, каналы и сообщения этой ноды будут удалены '
          'с устройства. Сама нода не изменится.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(nodeDbActionsProvider).delete(db.num);
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось удалить: $e');
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: 'Импорт базы из файла',
      );
      if (files.isEmpty || !context.mounted) return;
      final num = await ref.read(nodeDbActionsProvider).import(
        await files.first.readAsBytes(),
        (num) async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Заменить базу?'),
              content: Text(
                'База ноды ${nodeIdString(num)} уже есть. Заменить её '
                'данными из файла?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Заменить'),
                ),
              ],
            ),
          );
          return ok == true;
        },
      );
      if (num != null && context.mounted) {
        _snack(
          context,
          'База ноды ${nodeIdString(num)} загружена — откроется при '
          'подключении к этой ноде',
        );
      }
    } on FormatException catch (e) {
      if (context.mounted) _snack(context, e.message);
    } catch (e) {
      if (context.mounted) _snack(context, 'Не удалось загрузить: $e');
    }
  }
}

/// «Очистить устаревшие ноды» — как в iOS: переключатель и дни (1–180).
class _PurgeStaleCard extends ConsumerStatefulWidget {
  const _PurgeStaleCard();

  @override
  ConsumerState<_PurgeStaleCard> createState() => _PurgeStaleCardState();
}

class _PurgeStaleCardState extends ConsumerState<_PurgeStaleCard> {
  /// Пока тянут ползунок — значение здесь, сохраняем по отпусканию.
  double? _drag;

  void _save(int days) => saveSetting(
    ref,
    AppSettingKeys.purgeStaleNodeDays,
    '$days',
  ).then((_) => ref.read(databaseProvider).purgeStaleNodes());

  @override
  Widget build(BuildContext context) {
    final days = ref.watch(purgeStaleNodeDaysProvider).value ?? 0;
    final shown = (_drag ?? days.toDouble()).clamp(1, 180).toDouble();
    return SectionCard(
      footer:
          'Избранные и игнорируемые ноды всегда сохраняются. Другие ноды '
          'удаляются из базы данных приложения через заданное число дней. '
          '(Ноды с ключами PKC всегда сохраняются не менее 7 дней.) '
          'Удаляются только ноды, которых нет в базе нод устройства; '
          'своя нода и ноды с заметкой тоже сохраняются.',
      children: [
        SwitchListTile(
          title: const Text('Очистить устаревшие ноды'),
          value: days > 0,
          onChanged: (on) => _save(on ? 7 : 0),
        ),
        if (days > 0) ...[
          MeshTile(title: 'Через ${shown.round()} дн.'),
          Slider(
            value: shown,
            min: 1,
            max: 180,
            divisions: 179,
            label: '${shown.round()}',
            onChanged: (v) => setState(() => _drag = v),
            onChangeEnd: (v) {
              setState(() => _drag = null);
              _save(v.round());
            },
          ),
        ],
      ],
    );
  }
}

/// «Сколько баз хранить»: по умолчанию [nodeDbLimit], 0 — без ограничения.
/// Если баз больше нового лимита — спросить и удалить лишние сразу.
class _DbLimitTile extends ConsumerWidget {
  const _DbLimitTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limit = ref.watch(nodeDbLimitProvider).value ?? nodeDbLimit;
    return MeshTile(
      title: 'Сколько баз хранить',
      trailing: NumberField(
        value: limit,
        onSave: (n) => _save(context, ref, n),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref, int? n) async {
    if (n == null) return;
    final count = ref.read(nodeDbListProvider).value?.length ?? 0;
    final extra = n == 0 ? 0 : count - n;
    if (extra > 0) {
      // Экран уже закрыт — без подтверждения базы не удаляем.
      if (!context.mounted) return;
      final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Удалить лишние базы?'),
          content: Text(
            'Сейчас баз: $count. Самые давно не использованные ($extra) '
            'удалятся вместе с перепиской.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Удалить'),
            ),
          ],
        ),
      );
      if (yes != true) {
        ref.invalidate(nodeDbLimitProvider);
        return;
      }
    }
    await ref.read(nodeDbActionsProvider).setLimit(n);
  }
}
