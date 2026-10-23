import 'dart:io';

/// Сколько места на диске могут занять просмотренные тайлы карты.
const tileCacheLimitBytes = 300 * 1024 * 1024;

/// Без сети тайл берётся из кэша, даже устаревший — до года.
const tileCacheMaxStale = Duration(days: 365);

/// CARTO разрешает хранить их тайлы на устройстве не дольше 30 дней
/// (Basemap Terms, п. 9.c.ii).
const cartoCacheMaxAge = Duration(days: 30);

List<File> _files(Directory dir) => dir.existsSync()
    ? dir.listSync(recursive: true).whereType<File>().toList()
    : <File>[];

/// Размер кэша в байтах.
int tileCacheSize(Directory dir) =>
    _files(dir).fold(0, (s, f) => s + f.lengthSync());

/// Удалить самые давние по изменению файлы, пока кэш больше [maxBytes].
/// Возвращает, сколько байт освобождено.
int trimTileCache(Directory dir, int maxBytes) {
  final files = [for (final f in _files(dir)) (f: f, st: f.statSync())]
    ..sort((a, b) => a.st.modified.compareTo(b.st.modified));
  var total = files.fold(0, (s, e) => s + e.st.size);
  var freed = 0;
  for (final e in files) {
    if (total <= maxBytes) break;
    try {
      e.f.deleteSync();
    } on FileSystemException {
      continue;
    }
    total -= e.st.size;
    freed += e.st.size;
  }
  return freed;
}

/// Удалить файлы, изменённые раньше чем [maxAge] назад; вернуть,
/// сколько байт освобождено.
int dropOlderThan(Directory dir, Duration maxAge, [DateTime? now]) {
  final limit = (now ?? DateTime.now()).subtract(maxAge);
  var freed = 0;
  for (final f in _files(dir)) {
    final st = f.statSync();
    if (!st.modified.isBefore(limit)) continue;
    try {
      f.deleteSync();
      freed += st.size;
    } on FileSystemException {
      // Занят — удалим в следующий раз.
    }
  }
  return freed;
}

/// Человекочитаемый размер: «12,3 МБ».
String formatBytes(int b) {
  if (b < 1024 * 1024) return '${(b / 1024).round()} КБ';
  return '${(b / 1024 / 1024).toStringAsFixed(1).replaceAll('.', ',')} МБ';
}
