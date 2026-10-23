import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Один экземпляр приложения на Windows и Linux (на macOS это делает ОС).
///
/// Два процесса на одной базе и одной ноде мешают друг другу: «database is
/// locked», BLE «AccessDenied». Первый держит эксклюзивную блокировку
/// `instance.lock` и слушает порт на 127.0.0.1 (номер — в `instance.port`).
/// Второй блокировку не получает, просит первого показать окно и выходит.
/// Блокировку снимает ОС, когда процесс завершается (в том числе аварийно).
class SingleInstance {
  SingleInstance._(this._lock, this._server);

  final RandomAccessFile _lock;
  final ServerSocket _server;

  static const _show = 'show';

  /// Занять место первого экземпляра. null — уже запущен другой: его окно
  /// попросили показать, этому процессу надо выйти.
  static Future<SingleInstance?> claim(
    Directory dir, {
    required void Function() onActivate,
  }) async {
    await dir.create(recursive: true);
    final lock = await File(
      '${dir.path}/instance.lock',
    ).open(mode: FileMode.append);
    try {
      await lock.lock(FileLock.exclusive);
    } on FileSystemException {
      await lock.close();
      await activateExisting(dir);
      return null;
    }
    final server = await serve(dir, onActivate);
    return SingleInstance._(lock, server);
  }

  /// Слушать просьбы показать окно; номер порта — в `instance.port`.
  static Future<ServerSocket> serve(
    Directory dir,
    void Function() onActivate,
  ) async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    await File('${dir.path}/instance.port').writeAsString('${server.port}');
    server.listen((s) {
      utf8.decoder
          .bind(s)
          .join()
          .then((m) {
            if (m.trim() == _show) onActivate();
          })
          .catchError((Object _) {})
          .whenComplete(s.destroy);
    });
    return server;
  }

  /// Попросить запущенный экземпляр показать окно. false — не достучались.
  static Future<bool> activateExisting(Directory dir) async {
    try {
      final port = int.parse(
        (await File('${dir.path}/instance.port').readAsString()).trim(),
      );
      final s = await Socket.connect(
        InternetAddress.loopbackIPv4,
        port,
        timeout: const Duration(seconds: 2),
      );
      s.write(_show);
      await s.flush();
      await s.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() async {
    await _server.close();
    await _lock.close();
  }
}
