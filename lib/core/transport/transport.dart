import 'dart:async';
import 'dart:typed_data';

/// Транспорт до ноды: отдаёт сырые FromRadio-пакеты и строки лога.
/// Протокол (protobuf) — забота [RadioSession], транспорт только доставляет байты.
abstract class Transport {
  /// Готовые FromRadio-пакеты.
  Stream<Uint8List> get fromRadio;

  /// Лог ноды: LogRecord (BLE logRadio) или текст вне кадров (TCP/Serial).
  Stream<NodeLogChunk> get logs;

  /// Завершается при разрыве связи (с причиной).
  Future<String> get closed;

  String get description;

  Future<void> connect();
  Future<void> send(Uint8List toRadio);
  Future<void> close();
}

/// Кусок лога ноды: либо protobuf LogRecord, либо обычный текст.
sealed class NodeLogChunk {}

class NodeLogRecord extends NodeLogChunk {
  NodeLogRecord(this.bytes);
  final Uint8List bytes;
}

class NodeLogText extends NodeLogChunk {
  NodeLogText(this.text);
  final String text;
}

/// Разбор потока кадров `0x94 0xC3 len_hi len_lo payload` (TCP и USB Serial).
/// Байты вне кадров — текстовый отладочный вывод ноды.
class StreamFramer {
  StreamFramer({required this.onFrame, required this.onText});

  static const maxPayload = 512;

  final void Function(Uint8List frame) onFrame;
  final void Function(List<int> text) onText;
  final _buf = BytesBuilder(copy: false);

  void add(List<int> chunk) {
    _buf.add(chunk);
    final data = _buf.takeBytes();
    var i = 0;
    while (true) {
      final start = _findHeader(data, i);
      if (start < 0) {
        // Последний байт может быть началом заголовка (0x94) — оставляем его.
        final keep = data.isNotEmpty && data.last == 0x94 ? 1 : 0;
        if (data.length - keep > i) onText(data.sublist(i, data.length - keep));
        i = data.length - keep;
        break;
      }
      if (start > i) onText(data.sublist(i, start));
      if (start + 4 > data.length) {
        i = start;
        break;
      }
      final len = (data[start + 2] << 8) | data[start + 3];
      if (len > maxPayload) {
        i = start + 1; // битый заголовок — ищем следующий
        continue;
      }
      if (start + 4 + len > data.length) {
        i = start;
        break;
      }
      onFrame(Uint8List.fromList(data.sublist(start + 4, start + 4 + len)));
      i = start + 4 + len;
    }
    if (i < data.length) _buf.add(data.sublist(i));
  }

  static int _findHeader(Uint8List d, int from) {
    for (var j = from; j + 1 < d.length; j++) {
      if (d[j] == 0x94 && d[j + 1] == 0xC3) return j;
    }
    return -1;
  }

  static Uint8List frame(List<int> payload) => Uint8List.fromList([
    0x94,
    0xC3,
    payload.length >> 8,
    payload.length & 0xff,
    ...payload,
  ]);
}
