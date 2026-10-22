import 'dart:convert';
import 'dart:io';

import 'database.dart';

/// Сколько баз нод держим (как Device DB cache limit у Meshtastic-Android).
const nodeDbLimit = 5;

/// Номер «базы без ноды»: ещё ни к одной не подключались (только зеркало).
const noNodeDb = 0;

/// Список баз нод из настройки: последняя использованная — первой.
List<int> parseNodeDbs(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];
    return [
      for (final v in list)
        if (v is int) v,
    ];
  } on FormatException {
    return const [];
  }
}

String encodeNodeDbs(List<int> list) => jsonEncode(list);

/// Переход на базу [num]: она становится первой; всё сверх [limit] —
/// в [evicted] (самые давно неиспользованные), их файлы удаляются.
({List<int> list, List<int> evicted}) useNodeDb(
  List<int> list,
  int num, {
  int limit = nodeDbLimit,
}) {
  final next = [num, ...list.where((n) => n != num)];
  if (next.length <= limit) return (list: next, evicted: const []);
  return (list: next.sublist(0, limit), evicted: next.sublist(limit));
}

/// Таблицы ноды. В общей базе остаются только настройки и недавние.
List<String> nodeTables(AppDatabase db) => [
  for (final t in db.allTables)
    if (t != db.appSettings && t != db.recentConnections) t.actualTableName,
];

/// Однократный переезд с одной базы на базы по нодам: данные из общей
/// базы копируются в файл своей ноды ([fileFor]), а в общей удаляются.
/// Возвращает номер активной базы.
Future<int> migrateToNodeDbs(
  AppDatabase app,
  String Function(int num) fileFor,
) async {
  final saved = await app.getSetting(AppSettingKeys.nodeDbs);
  if (saved != null) {
    final list = parseNodeDbs(saved);
    return list.isEmpty ? noNodeDb : list.first;
  }

  final my = await (app.select(app.myNode)..limit(1)).getSingleOrNull();
  final num = my?.myNodeNum ?? noNodeDb;
  final tables = nodeTables(app);
  var hasData = false;
  for (final t in tables) {
    final r = await app.customSelect('SELECT 1 FROM "$t" LIMIT 1').get();
    if (r.isNotEmpty) {
      hasData = true;
      break;
    }
  }

  if (hasData) {
    final path = fileFor(num);
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
    // Копия целиком (со схемой и user_version) — без закрытия базы.
    await app.customStatement('VACUUM INTO ?', [path]);
    await app.transaction(() async {
      for (final t in tables) {
        await app.customStatement('DELETE FROM "$t"');
      }
    });
  }
  await app.setSetting(AppSettingKeys.nodeDbs, encodeNodeDbs([num]));
  return num;
}

/// Удалить файлы базы (вместе с журналами SQLite).
void deleteDbFiles(String path) {
  for (final suffix in const ['', '-wal', '-shm', '-journal']) {
    final f = File('$path$suffix');
    if (f.existsSync()) f.deleteSync();
  }
}
