import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show listEquals;

import '../core/proto/mesh.dart';
import 'database.dart';
import 'node_dbs.dart';

/// Копирование сообщений из присоединённой базы `src`: параметры —
/// старый и новый свой номер (для from_num, затем для to_num).
String transferMessagesSql(List<String> cols) {
  String col(String c) => c == 'from_num' || c == 'to_num'
      ? 'CASE WHEN $c = ? THEN ? ELSE $c END'
      : c;
  final from = cols.indexOf('from_num'), to = cols.indexOf('to_num');
  if (from < 0 || to < 0 || from > to) {
    throw ArgumentError('from_num должен идти раньше to_num');
  }
  return 'INSERT OR IGNORE INTO messages (${cols.join(', ')}) '
      'SELECT ${cols.map(col).join(', ')} FROM src.messages';
}

/// База ноды для экрана «Данные».
typedef NodeDbInfo = ({int num, String name, int bytes, bool active});

/// Импортированная база: сразу после активной (её не вытесняет), сверх
/// [limit] — самые давние в [evicted].
({List<int> list, List<int> evicted}) insertImportedDb(
  List<int> list,
  int num, {
  int limit = nodeDbLimit,
}) {
  if (list.contains(num)) return (list: list, evicted: const []);
  return trimNodeDbs([...list.take(1), num, ...list.skip(1)], limit);
}

/// Файлы баз нод: список, экспорт, импорт, удаление. Активную базу
/// держит приложение, поэтому её не удаляем и не заменяем.
class NodeDbStore {
  NodeDbStore(this.dir, this.app);

  final String dir;
  final AppDatabase app;

  String path(int num) => '$dir/${AppDatabase.nodeDbName(num)}.sqlite';

  Future<int> _limit() async =>
      parseNodeDbLimit(await app.getSetting(AppSettingKeys.nodeDbLimit));

  /// Новый лимит баз: сохранить и сразу удалить лишние, самые давние.
  /// Сколько удалено.
  Future<int> setLimit(int limit) async {
    await app.setSetting(AppSettingKeys.nodeDbLimit, '$limit');
    final r = trimNodeDbs(await _order(), limit);
    for (final n in r.evicted) {
      deleteDbFiles(path(n));
    }
    if (r.evicted.isNotEmpty) await _save(r.list);
    return r.evicted.length;
  }

  Future<List<int>> _order() async =>
      parseNodeDbs(await app.getSetting(AppSettingKeys.nodeDbs));

  Future<void> _save(List<int> list) =>
      app.setSetting(AppSettingKeys.nodeDbs, encodeNodeDbs(list));

  int _size(int num) {
    var total = 0;
    for (final s in const ['', '-wal']) {
      final f = File('${path(num)}$s');
      if (f.existsSync()) total += f.lengthSync();
    }
    return total;
  }

  /// Открыть неактивную базу на время [body].
  Future<T> _with<T>(int num, Future<T> Function(AppDatabase db) body) async {
    final db = AppDatabase(NativeDatabase(File(path(num))), app);
    try {
      return await body(db);
    } finally {
      await db.close();
    }
  }

  static Future<String> _name(AppDatabase db, int num) async {
    if (num == noNodeDb) return 'Без ноды (только зеркало)';
    final n = await (db.select(
      db.nodes,
    )..where((n) => n.num.equals(num))).getSingleOrNull();
    final long = n?.longName ?? '', short = n?.shortName ?? '';
    final id = nodeIdString(num);
    if (long.isEmpty && short.isEmpty) return id;
    return '${long.isNotEmpty ? long : short} ($id)';
  }

  /// Все базы, последняя использованная — первой. Строки без файла
  /// (удалили снаружи) из списка убираются.
  Future<List<NodeDbInfo>> list(int active, AppDatabase activeDb) async {
    final order = await _order();
    final kept = <int>[];
    final out = <NodeDbInfo>[];
    for (final num in order) {
      final isActive = num == active;
      if (!isActive && !File(path(num)).existsSync()) continue;
      kept.add(num);
      final name = isActive
          ? await _name(activeDb, num)
          : await _with(num, (db) => _name(db, num));
      out.add((num: num, name: name, bytes: _size(num), active: isActive));
    }
    if (kept.length != order.length) await _save(kept);
    return out;
  }

  /// Копия базы для экспорта (целостная, даже пока база открыта).
  Future<Uint8List> export(int num, int active, AppDatabase activeDb) async {
    final tmp = '$dir/export.tmp.sqlite';
    deleteDbFiles(tmp);
    try {
      if (num == active) {
        await activeDb.customStatement('VACUUM INTO ?', [tmp]);
      } else {
        await _with(num, (db) => db.customStatement('VACUUM INTO ?', [tmp]));
      }
      return await File(tmp).readAsBytes();
    } finally {
      deleteDbFiles(tmp);
    }
  }

  Future<void> delete(int num, int active) async {
    if (num == active) throw StateError('Открытую базу удалить нельзя');
    deleteDbFiles(path(num));
    await _save((await _order()).where((n) => n != num).toList());
  }

  /// Ключ своей ноды в её базе (null — неизвестен).
  static Future<List<int>?> _ownKey(AppDatabase db, int num) async {
    final n = await (db.select(
      db.nodes,
    )..where((n) => n.num.equals(num))).getSingleOrNull();
    final k = n?.publicKey;
    return k == null || k.isEmpty ? null : k;
  }

  /// Та же нода под новым номером: ключи совпадают. null — ключа нет
  /// в одной из баз, проверить нельзя.
  Future<bool?> sameOwnKey(int from, int active, AppDatabase activeDb) async {
    final a = await _ownKey(activeDb, active);
    final b = await _with(from, (db) => _ownKey(db, from));
    if (a == null || b == null) return null;
    return listEquals(a, b);
  }

  /// Перенести сообщения базы [from] в открытую базу [active]: свой
  /// старый номер в отправителе и получателе меняется на новый, уже
  /// имеющиеся сообщения не дублируются. Ноды — только недостающие.
  /// Старая база остаётся. Возвращает число перенесённых сообщений.
  Future<int> transfer(int from, int active, AppDatabase activeDb) async {
    if (from == active) throw StateError('Это открытая база');
    if (from == noNodeDb || active == noNodeDb) {
      throw StateError('Нужны базы двух нод');
    }
    if (!File(path(from)).existsSync()) throw StateError('Нет файла базы');
    // Открыть и закрыть — миграции до схемы приложения.
    await _with(from, (db) => db.select(db.myNode).get());
    final msgCols = [
      for (final c in activeDb.messages.$columns)
        if (c.name != 'id') c.name,
    ];
    final nodeCols = [for (final c in activeDb.nodes.$columns) c.name];
    final before = await _count(activeDb);
    await activeDb.customStatement('ATTACH DATABASE ? AS src', [path(from)]);
    try {
      await activeDb.transaction(() async {
        await activeDb.customStatement(transferMessagesSql(msgCols), [
          from,
          active,
          from,
          active,
        ]);
        await activeDb.customStatement(
          'INSERT OR IGNORE INTO nodes (${nodeCols.join(', ')}) '
          'SELECT ${nodeCols.join(', ')} FROM src.nodes WHERE num <> ?',
          [from],
        );
      });
    } finally {
      await activeDb.customStatement('DETACH DATABASE src');
    }
    activeDb.notifyUpdates({
      TableUpdate.onTable(activeDb.messages),
      TableUpdate.onTable(activeDb.nodes),
    });
    return await _count(activeDb) - before;
  }

  static Future<int> _count(AppDatabase db) async =>
      (await db.customSelect('SELECT COUNT(*) AS c FROM messages').getSingle())
          .read<int>('c');

  /// Номер ноды в файле базы, если это наша база с данными ноды.
  Future<int> _numOf(String file) async {
    final db = AppDatabase(NativeDatabase(File(file)));
    try {
      final my = await (db.select(db.myNode)..limit(1)).getSingleOrNull();
      if (my == null) {
        throw const FormatException('В файле нет данных ноды');
      }
      return my.myNodeNum;
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Это не база Etohost Mesh');
    } finally {
      await db.close();
    }
  }

  /// Импорт файла базы. Возвращает номер ноды; [replace] спрашивает,
  /// заменить ли уже имеющуюся базу этой ноды.
  Future<int?> import(
    Uint8List bytes, {
    required int active,
    required Future<bool> Function(int num) replace,
  }) async {
    _checkSqlite(bytes);
    final tmp = '$dir/import.tmp.sqlite';
    deleteDbFiles(tmp);
    try {
      await File(tmp).writeAsBytes(bytes, flush: true);
      final num = await _numOf(tmp);
      if (num == active) {
        throw const FormatException(
          'Это база открытой сейчас ноды — её заменить нельзя',
        );
      }
      final order = await _order();
      if ((order.contains(num) || File(path(num)).existsSync()) &&
          !await replace(num)) {
        return null;
      }
      deleteDbFiles(path(num));
      await File(tmp).rename(path(num));
      final r = insertImportedDb(order, num, limit: await _limit());
      await _save(r.list);
      for (final n in r.evicted) {
        deleteDbFiles(path(n));
      }
      return num;
    } finally {
      deleteDbFiles(tmp);
    }
  }

  /// Копия общей базы: настройки приложения и недавние подключения.
  Future<Uint8List> exportApp() async {
    final tmp = '$dir/export.tmp.sqlite';
    deleteDbFiles(tmp);
    try {
      await app.customStatement('VACUUM INTO ?', [tmp]);
      return await File(tmp).readAsBytes();
    } finally {
      deleteDbFiles(tmp);
    }
  }

  /// Загрузить настройки и недавние из файла общей базы — на месте, без
  /// перезапуска. Список баз нод остаётся свой: он про файлы этого
  /// устройства. Возвращает число загруженных настроек.
  Future<int> importApp(Uint8List bytes) async {
    _checkSqlite(bytes);
    final tmp = '$dir/import.tmp.sqlite';
    deleteDbFiles(tmp);
    final src = AppDatabase(NativeDatabase(File(tmp)));
    try {
      await File(tmp).writeAsBytes(bytes, flush: true);
      final List<AppSetting> settings;
      final List<RecentConnection> recent;
      try {
        settings = await src.select(src.appSettings).get();
        recent = await src.select(src.recentConnections).get();
      } catch (_) {
        throw const FormatException('Это не база Etohost Mesh');
      }
      final own = settings
          .where((s) => s.key != AppSettingKeys.nodeDbs)
          .toList();
      if (own.isEmpty && recent.isEmpty) {
        throw const FormatException('В файле нет настроек приложения');
      }
      await app.transaction(() async {
        await (app.delete(
          app.appSettings,
        )..where((s) => s.key.equals(AppSettingKeys.nodeDbs).not())).go();
        await app.delete(app.recentConnections).go();
        await app.batch((b) {
          b.insertAll(app.appSettings, own);
          b.insertAll(app.recentConnections, recent);
        });
      });
      return own.length;
    } finally {
      await src.close();
      deleteDbFiles(tmp);
    }
  }

  static void _checkSqlite(Uint8List bytes) {
    const magic = 'SQLite format 3';
    if (bytes.length < 100 ||
        String.fromCharCodes(bytes.sublist(0, magic.length)) != magic) {
      throw const FormatException('Это не файл базы SQLite');
    }
  }
}
