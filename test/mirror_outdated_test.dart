import 'dart:async';
import 'dart:io';

import 'package:etohost_mesh/mirror/mirror_realtime.dart';
import 'package:flutter_test/flutter_test.dart';

/// Локальный WS-сервер: принимает подключение и сразу закрывает с [code].
Future<(HttpServer, Uri, int Function())> _server(int code) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  var connects = 0;
  server.listen((req) async {
    connects++;
    final ws = await WebSocketTransformer.upgrade(req);
    await ws.close(code, 'client_outdated');
  });
  return (
    server,
    Uri.parse('ws://127.0.0.1:${server.port}/ws'),
    () => connects,
  );
}

void main() {
  test('4426 — устарело: без переподключений, onOutdated один раз', () async {
    final (server, url, connects) = await _server(wsCloseOutdated);
    final outdated = Completer<void>();
    var calls = 0;
    final rt = MirrorRealtime(
      url,
      (_) async {},
      onOutdated: () {
        calls++;
        if (!outdated.isCompleted) outdated.complete();
      },
    )..start();
    await outdated.future.timeout(const Duration(seconds: 5));
    expect(rt.state, MirrorState.outdated);
    // Обычный повтор был бы через 1 с — ждём дольше.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    expect(connects(), 1);
    expect(calls, 1);
    await rt.stop();
    await server.close(force: true);
  });

  test('другой код закрытия — обычный повтор', () async {
    final (server, url, connects) = await _server(WebSocketStatus.goingAway);
    var calls = 0;
    final rt = MirrorRealtime(url, (_) async {}, onOutdated: () => calls++)
      ..start();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    expect(connects(), greaterThanOrEqualTo(2));
    expect(calls, 0);
    await rt.stop();
    await server.close(force: true);
  });
}
