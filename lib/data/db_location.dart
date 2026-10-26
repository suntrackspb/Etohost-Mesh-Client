import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Где лежат базы. На десктопе — папка данных приложения (`AppData\Roaming`,
/// `Application Support`, `~/.local/share`): в «Документы» на Windows не
/// пускают «Контролируемый доступ к папкам» и OneDrive — SqliteException(14).
/// На телефонах — «Документы», как было.
bool get dbInSupportDir =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

Future<Directory> dbDirectory() async {
  final dir = dbInSupportDir
      ? await getApplicationSupportDirectory()
      : await getApplicationDocumentsDirectory();
  await dir.create(recursive: true);
  return dir;
}

/// Наши файлы баз: общая `meshtastic.sqlite` и `node_<num>.sqlite`
/// со спутниками SQLite (-wal, -shm, -journal).
final _dbFile = RegExp(r'^(meshtastic|node_\d+)\.sqlite(-wal|-shm|-journal)?$');

/// Что переносить из старой папки: имя базы → её файлы. Базу, которая уже
/// есть в новой папке, не трогаем — не затираем новые данные старыми.
Map<String, List<String>> dbMovePlan(
  Iterable<String> oldFiles,
  Set<String> newFiles,
) {
  final plan = <String, List<String>>{};
  for (final f in oldFiles) {
    final m = _dbFile.firstMatch(f);
    if (m == null) continue;
    final base = '${m.group(1)}.sqlite';
    if (newFiles.contains(base)) continue;
    (plan[base] ??= []).add(f);
  }
  // Без самой базы спутники бесполезны.
  plan.removeWhere((base, files) => !files.contains(base));
  return plan;
}

/// Один раз на десктопе: базы из «Документов» — в папку данных приложения.
/// До открытия любой базы. Возвращает перенесённые базы.
Future<List<String>> moveDbsFromDocuments() async {
  if (!dbInSupportDir) return const [];
  final Directory old;
  try {
    old = await getApplicationDocumentsDirectory();
  } catch (_) {
    return const [];
  }
  final dest = await dbDirectory();
  if (old.absolute.path == dest.absolute.path || !await old.exists()) {
    return const [];
  }
  String name(FileSystemEntity e) => e.uri.pathSegments.last;
  final oldFiles = [
    await for (final e in old.list(followLinks: false))
      if (e is File) name(e),
  ];
  final newFiles = {
    await for (final e in dest.list(followLinks: false))
      if (e is File) name(e),
  };
  final plan = dbMovePlan(oldFiles, newFiles);
  for (final files in plan.values) {
    for (final f in files) {
      await _move(File('${old.path}/$f'), '${dest.path}/$f');
    }
  }
  return plan.keys.toList();
}

/// rename, а между дисками (Документы в OneDrive на D:) — копия и удаление.
Future<void> _move(File from, String to) async {
  try {
    await from.rename(to);
  } on FileSystemException {
    await from.copy(to);
    await from.delete();
  }
}
