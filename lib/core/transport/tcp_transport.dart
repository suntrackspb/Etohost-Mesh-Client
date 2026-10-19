import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'transport.dart';

/// TCP до ноды (порт 4403), кадры `0x94 0xC3 len`.
class TcpTransport implements Transport {
  TcpTransport(this.host, {this.port = 4403});

  final String host;
  final int port;
  Socket? _socket;
  final _from = StreamController<Uint8List>.broadcast();
  final _logs = StreamController<NodeLogChunk>.broadcast();
  final _closed = Completer<String>();
  late final _framer = StreamFramer(
    onFrame: _from.add,
    onText: (b) => _logs.add(NodeLogText(utf8.decode(b, allowMalformed: true))),
  );

  @override
  Stream<Uint8List> get fromRadio => _from.stream;
  @override
  Stream<NodeLogChunk> get logs => _logs.stream;
  @override
  Future<String> get closed => _closed.future;
  @override
  String get description => 'TCP $host:$port';

  @override
  Future<void> connect() async {
    final s = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 10),
    );
    s.setOption(SocketOption.tcpNoDelay, true);
    _socket = s;
    s.listen(
      _framer.add,
      onError: (e) => _finish('TCP ошибка: $e'),
      onDone: () => _finish('TCP: нода закрыла соединение'),
      cancelOnError: true,
    );
  }

  @override
  Future<void> send(Uint8List toRadio) async {
    final s = _socket;
    if (s == null) return;
    s.add(StreamFramer.frame(toRadio));
    await s.flush();
  }

  void _finish(String reason) {
    if (!_closed.isCompleted) _closed.complete(reason);
  }

  @override
  Future<void> close() async {
    _finish('отключено пользователем');
    await _socket?.close();
    _socket?.destroy();
  }
}
