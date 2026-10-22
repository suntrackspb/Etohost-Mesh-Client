import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/node_db_store.dart';
import '../../data/node_dbs.dart';
import '../../ui/kit/kit.dart';

/// Настройки → Данные: базы нод (у каждой своя), экспорт, импорт, удаление.
class DataSettingsPage extends ConsumerWidget {
  const DataSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbs = ref.watch(nodeDbListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Данные')),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          SectionCard(
            title: 'Базы нод',
            footer:
                'У каждой ноды своя база: ноды, каналы, сообщения и копия '
                'зеркала. Хранится до $nodeDbLimit баз, самая давно не '
                'использованная удаляется. Открытую базу удалить нельзя.',
            children: switch (dbs) {
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

  static void _snack(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

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
      case 'delete':
        await _delete(context, ref, db);
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
