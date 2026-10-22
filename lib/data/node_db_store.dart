import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../core/proto/mesh.dart';
import 'database.dart';
import 'node_dbs.dart';

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
  final next = [...list.take(1), num, ...list.skip(1)];
  if (next.length <= limit) return (list: next, evicted: const []);
  return (list: next.sublist(0, limit), evicted: next.sublist(limit));
}

/// Файлы баз нод: список, экспорт, импорт, удаление. Активную базу
/// держит приложение, поэтому её не удаляем и не заменяем.
class NodeDbStore {
  NodeDbStore(this.dir, this.app);

  final String dir;
  final AppDatabase app;

  String path(int num) => '$dir/${AppDatabase.nodeDbName(num)}.sqlite';

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
      final r = insertImportedDb(order, num);
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
