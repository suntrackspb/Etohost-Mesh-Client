import 'package:meshex/l10n/l10n.dart';
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
      appBar: AppBar(
        title: Text(context.l10n.data_d8e5fd),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            title: context.l10n.nodeDatabases_1e2d9d,
            footer: context.l10n.eachNodeHasItsOwnDatabase_534196,
            children: [
              const _DbLimitTile(),
              ...switch (dbs) {
                AsyncData(:final value) => [
                  for (final db in value)
                    MeshTile(
                      title: db.name,
                      subtitle: db.active
                          ? context.l10n.open_0cdbe8(
                              (context.builtIn(_size(db.bytes))).toString(),
                            )
                          : context.builtIn(_size(db.bytes)),
                      leading: Icon(
                        db.active ? Icons.storage : Icons.storage_outlined,
                      ),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () => _menu(context, ref, db),
                    ),
                ],
                AsyncError(:final error) => [
                  MeshTile(
                    title: context.l10n.couldNotRead_35e132((error).toString()),
                  ),
                ],
                _ => [const LinearProgressIndicator()],
              },
            ],
          ),
          SectionCard(
            children: [
              MeshTile(
                title: context.l10n.importNodeDatabaseFromFile_7ff7a5,
                leading: const Icon(Icons.file_open_outlined),
                onTap: () => _import(context, ref),
              ),
            ],
          ),
          const SizedBox(height: Tokens.s16),
          const _PurgeStaleCard(),
          SectionCard(
            title: context.l10n.applicationDatabase_4d6431,
            footer:
                context.l10n.applicationSettingsAndRecentConnectionsFor_cab177,
            children: [
              MeshTile(
                title: context.l10n.exportToFile_5ba2da,
                leading: const Icon(Icons.save_alt),
                onTap: () => _exportApp(context, ref),
              ),
              MeshTile(
                title: context.l10n.importFromFile_f190b3,
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
    final strings = context.l10n;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(strings.exportToFile_5ba2da),
              onTap: () => Navigator.pop(context, 'export'),
            ),
            if (!db.active &&
                db.num != noNodeDb &&
                ref.read(activeNodeDbProvider) != noNodeDb)
              ListTile(
                leading: const Icon(Icons.move_down),
                title: Text(strings.transferToTheOpenDatabase_8042a9),
                onTap: () => Navigator.pop(context, 'transfer'),
              ),
            if (!db.active)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(strings.delete_86ea33),
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
    final strings = context.l10n;
    final actions = ref.read(nodeDbActionsProvider);
    final bool? same;
    try {
      same = await actions.sameOwnKey(db.num);
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotRead_35e132((e).toString()));
      }
      return;
    }
    if (!context.mounted) return;
    final ok = await _confirm(
      context,
      strings.transferMessages_f1f159,
      strings.messagesFromDatabaseWillBeAdded_47ae75(
        (db.name).toString(),
        (switch (same) {
          true => '',
          false =>
            '\n\nВнимание: ключ своей ноды в этих базах разный — '
                'похоже, это другая нода.',
          null =>
            '\n\nКлюч своей ноды неизвестен — проверить, что это '
                'та же нода, нельзя.',
        }).toString(),
      ),
      strings.transfer_081b1d,
    );
    if (!ok || !context.mounted) return;
    try {
      final n = await actions.transfer(db.num);
      if (context.mounted) {
        _snack(context, strings.messagesTransferred_4a0c59((n).toString()));
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotTransfer_613ff4((e).toString()));
      }
    }
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    NodeDbInfo db,
  ) async {
    final strings = context.l10n;
    try {
      final bytes = await ref.read(nodeDbActionsProvider).export(db.num);
      final uri = await FilePicker.saveFile(
        dialogTitle: strings.saveToFile_cdda1c,
        fileName: nodeDbExportName(db.num, DateTime.now()),
        bytes: bytes,
      );
      if (uri != null && context.mounted) {
        _snack(context, strings.databaseSaved_190541);
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotSave_6886a1((e).toString()));
      }
    }
  }

  Future<void> _exportApp(BuildContext context, WidgetRef ref) async {
    final strings = context.l10n;
    final ok = await _confirm(
      context,
      strings.exportConfiguration_af2d98,
      strings.theFileWillContainYourNode_2c8772,
      strings.save_486405,
    );
    if (!ok || !context.mounted) return;
    try {
      final bytes = await ref.read(nodeDbActionsProvider).exportApp();
      final uri = await FilePicker.saveFile(
        dialogTitle: strings.saveToFile_cdda1c,
        fileName: nodeDbExportName(null, DateTime.now()),
        bytes: bytes,
      );
      if (uri != null && context.mounted) {
        _snack(context, strings.settingsSaved_0c3942);
      }
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotSave_6886a1((e).toString()));
      }
    }
  }

  Future<void> _importApp(BuildContext context, WidgetRef ref) async {
    final strings = context.l10n;
    final ok = await _confirm(
      context,
      strings.importConfiguration_c776ef,
      strings.currentApplicationSettingsAndRecentConnections_ae2892,
      strings.chooseFile_2e31da,
    );
    if (!ok || !context.mounted) return;
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: strings.importFromFile_f190b3,
      );
      if (files.isEmpty || !context.mounted) return;
      final n = await ref
          .read(nodeDbActionsProvider)
          .importApp(await files.first.readAsBytes());
      if (context.mounted) {
        _snack(context, strings.settingsLoaded_66f8ee((n).toString()));
      }
    } on FormatException catch (e) {
      if (context.mounted) _snack(context, e.message);
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotLoad_9d91fc((e).toString()));
      }
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
              child: Text(context.l10n.cancel_0ec753),
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
    final strings = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteDatabase_97a78b),
        content: Text(
          strings.thisNodeDatabaseChannelsAndMessages_6599da(
            (db.name).toString(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel_0ec753),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.delete_86ea33),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(nodeDbActionsProvider).delete(db.num);
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotDelete_bacd63((e).toString()));
      }
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final strings = context.l10n;
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: strings.importDatabaseFromFile_81e7f3,
      );
      if (files.isEmpty || !context.mounted) return;
      final num = await ref.read(nodeDbActionsProvider).import(
        await files.first.readAsBytes(),
        (num) async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(strings.replaceDatabase_1a5ae6),
              content: Text(
                strings.databaseForNodeAlreadyExistsReplace_d59789(
                  (nodeIdString(num)).toString(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(strings.cancel_0ec753),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(strings.replace_d772cc),
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
          strings.databaseForNodeLoadedItWill_8f5c23(
            (nodeIdString(num)).toString(),
          ),
        );
      }
    } on FormatException catch (e) {
      if (context.mounted) _snack(context, e.message);
    } catch (e) {
      if (context.mounted) {
        _snack(context, strings.couldNotLoad_9d91fc((e).toString()));
      }
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
      footer: context.l10n.favoriteAndIgnoredNodesAreAlways_f2c698,
      children: [
        SwitchListTile(
          title: Text(context.l10n.clearStaleNodes_968b4f),
          value: days > 0,
          onChanged: (on) => _save(on ? 7 : 0),
        ),
        if (days > 0) ...[
          MeshTile(
            title: context.l10n.afterDays_00b005((shown.round()).toString()),
          ),
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
      title: context.l10n.numberOfDatabasesToKeep_dd8856,
      trailing: NumberField(
        value: limit,
        onSave: (n) => _save(context, ref, n),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref, int? n) async {
    final strings = context.l10n;
    if (n == null) return;
    final count = ref.read(nodeDbListProvider).value?.length ?? 0;
    final extra = n == 0 ? 0 : count - n;
    if (extra > 0) {
      // Экран уже закрыт — без подтверждения базы не удаляем.
      if (!context.mounted) return;
      final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(strings.deleteExtraDatabases_ff4d99),
          content: Text(
            strings.currentDatabasesTheLeastRecentlyUsed_0fb1b8(
              (count).toString(),
              (extra).toString(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(strings.cancel_0ec753),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: Text(strings.delete_86ea33),
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
