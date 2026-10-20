import 'dart:async';
import 'dart:io';

import '../radio/journal.dart';

/// Файл журнала: строки пишутся пачками, при превышении [maxBytes] текущий
/// файл становится `journal.1.log` (предыдущий удаляется). Так в отчёт
/// попадает и прошлый запуск — например, перед падением.
class JournalFile {
  /// Каталог может появиться позже (path_provider асинхронный) — строки
  /// до этого копятся в памяти.
  JournalFile(this._dir, {this.maxBytes = 1024 * 1024});

  final Future<Directory> _dir;
  final int maxBytes;

  static const flushEvery = Duration(seconds: 2);

  Future<File> get _current async => File('${(await _dir).path}/journal.log');
  Future<File> get _previous async =>
      File('${(await _dir).path}/journal.1.log');

  final _pending = StringBuffer();
  Timer? _timer;
  Future<void> _writing = Future.value();

  void add(JournalLine line) {
    _pending.writeln(line.fileLine);
    _timer ??= Timer(flushEvery, flush);
  }

  /// Записать накопленное (и перед чтением журнала для отчёта).
  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    if (_pending.isEmpty) return _writing;
    final chunk = _pending.toString();
    _pending.clear();
    return _writing = _writing.then((_) => _write(chunk)).catchError((_) {});
  }

  Future<void> _write(String chunk) async {
    await (await _dir).create(recursive: true);
    final f = await _current;
    if (await f.exists() && await f.length() + chunk.length > maxBytes) {
      await f.rename((await _previous).path);
    }
    await f.writeAsString(chunk, mode: FileMode.append, flush: true);
  }

  /// Весь сохранённый журнал: прошлый файл, затем текущий.
  Future<String> readAll() async {
    await flush();
    final b = StringBuffer();
    for (final f in [await _previous, await _current]) {
      if (await f.exists()) b.write(await f.readAsString());
    }
    return b.toString();
  }

  Future<void> clear() async {
    await flush();
    for (final f in [await _previous, await _current]) {
      if (await f.exists()) await f.delete();
    }
  }
}
