import 'dart:async';
import 'dart:typed_data';

import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/core/transport/transport.dart';

/// Транспорт-заглушка: всё отправленное копится в [sent], ответы ноды — через [reply].
class FakeTransport implements Transport {
  final sent = <ToRadio>[];
  final _rx = StreamController<Uint8List>.broadcast();
  final _logs = StreamController<NodeLogChunk>.broadcast();
  final _closed = Completer<String>();

  /// Вызывается на каждый отправленный ToRadio — тут тест «отвечает за ноду».
  void Function(ToRadio msg)? onSend;

  void reply(FromRadio f) => _rx.add(Uint8List.fromList(f.writeToBuffer()));

  void drop(String reason) {
    if (!_closed.isCompleted) _closed.complete(reason);
  }

  @override
  Stream<Uint8List> get fromRadio => _rx.stream;
  @override
  Stream<NodeLogChunk> get logs => _logs.stream;
  @override
  Future<String> get closed => _closed.future;
  @override
  String get description => 'fake';
  @override
  Future<void> connect() async {}
  @override
  Future<void> send(Uint8List data) async {
    final m = ToRadio.fromBuffer(data);
    sent.add(m);
    onSend?.call(m);
  }

  @override
  Future<void> close() async => drop('closed');
}
