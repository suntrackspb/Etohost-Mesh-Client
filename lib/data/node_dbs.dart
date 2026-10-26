import 'dart:convert';
import 'dart:io';

import 'database.dart';

/// Сколько баз нод держим по умолчанию (как Device DB cache limit у
/// Meshtastic-Android); пользователь меняет в «Данных», 0 — без ограничения.
const nodeDbLimit = 5;

/// Лимит баз из настройки: пусто или мусор — [nodeDbLimit], 0 — без
/// ограничения.
int parseNodeDbLimit(String? s) {
  final n = int.tryParse(s ?? '');
  return n == null || n < 0 ? nodeDbLimit : n;
}

/// Обрезать [next] до [limit] (0 — не обрезать).
({List<int> list, List<int> evicted}) trimNodeDbs(List<int> next, int limit) =>
    limit == 0 || next.length <= limit
    ? (list: next, evicted: const [])
    : (list: next.sublist(0, limit), evicted: next.sublist(limit));

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
/// в [evicted] (самые давно неиспользованные), их файлы удаляются;
/// [limit] 0 — без ограничения.
({List<int> list, List<int> evicted}) useNodeDb(
  List<int> list,
  int num, {
  int limit = nodeDbLimit,
}) {
  return trimNodeDbs([num, ...list.where((n) => n != num)], limit);
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
    // Остаток прерванной прошлой попытки — с журналами SQLite.
    deleteDbFiles(path);
    // Копия целиком (со схемой и user_version) — без закрытия базы.
    // VACUUM INTO внутри транзакции нельзя; копия до неё безопасна:
    // упадём — следующий запуск скопирует заново.
    await app.customStatement('VACUUM INTO ?', [path]);
  }
  // Очистка и запись реестра вместе: иначе падение между ними оставит
  // файл с данными, о котором приложение не знает.
  await app.transaction(() async {
    if (hasData) {
      for (final t in tables) {
        await app.customStatement('DELETE FROM "$t"');
      }
    }
    await app.setSetting(AppSettingKeys.nodeDbs, encodeNodeDbs([num]));
  });
  return num;
}

/// Удалить файлы базы (вместе с журналами SQLite).
void deleteDbFiles(String path) {
  for (final suffix in const ['', '-wal', '-shm', '-journal']) {
    final f = File('$path$suffix');
    if (f.existsSync()) f.deleteSync();
  }
}
