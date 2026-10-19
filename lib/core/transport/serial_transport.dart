import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:usb_serial/usb_serial.dart';

import 'transport.dart';

/// Найденный последовательный порт.
class SerialPortInfo {
  const SerialPortInfo({
    required this.id,
    required this.title,
    this.subtitle = '',
  });

  /// Десктоп — имя порта (`/dev/cu.usbmodem…`, `COM3`); Android — deviceId.
  final String id;
  final String title;
  final String subtitle;
}

/// USB Serial есть на десктопе и Android; на iOS доступа к USB-serial нет.
bool get serialSupported =>
    Platform.isMacOS ||
    Platform.isWindows ||
    Platform.isLinux ||
    Platform.isAndroid;

Future<List<SerialPortInfo>> listSerialPorts() async {
  if (Platform.isAndroid) {
    final devices = await UsbSerial.listDevices();
    return [
      for (final d in devices)
        SerialPortInfo(
          id: '${d.deviceId}',
          title: d.productName ?? d.deviceName,
          subtitle: [
            d.manufacturerName,
            _vidPid(d.vid, d.pid),
          ].whereType<String>().join(' · '),
        ),
    ];
  }
  if (!serialSupported) return const [];
  final result = <SerialPortInfo>[];
  for (final name in SerialPort.availablePorts) {
    // На macOS каждый порт виден дважды: tty.* (ждёт DCD) и cu.* — берём cu.*.
    if (Platform.isMacOS && name.contains('/tty.')) continue;
    final p = SerialPort(name);
    try {
      result.add(
        SerialPortInfo(
          id: name,
          title: p.productName ?? p.description ?? name,
          subtitle: [name, p.manufacturer].whereType<String>().join(' · '),
        ),
      );
    } finally {
      p.dispose();
    }
  }
  return result;
}

String? _vidPid(int? vid, int? pid) => vid == null || pid == null
    ? null
    : '${vid.toRadixString(16).padLeft(4, '0')}:${pid.toRadixString(16).padLeft(4, '0')}';

/// USB Serial, 115200 8N1. Кадры такие же, как в TCP (`0x94 0xC3 len payload`),
/// байты вне кадров — текстовый отладочный вывод ноды.
class SerialTransport implements Transport {
  SerialTransport(this.port, {this.baudRate = 115200});

  static const _wakeBytes = 32;

  final SerialPortInfo port;
  final int baudRate;

  final _rx = StreamController<Uint8List>.broadcast();
  final _logs = StreamController<NodeLogChunk>.broadcast();
  final _closed = Completer<String>();
  late final _framer = StreamFramer(
    onFrame: _rx.add,
    onText: (t) => _logs.add(NodeLogText(utf8.decode(t, allowMalformed: true))),
  );

  _SerialLink? _link;

  @override
  Stream<Uint8List> get fromRadio => _rx.stream;
  @override
  Stream<NodeLogChunk> get logs => _logs.stream;
  @override
  Future<String> get closed => _closed.future;
  @override
  String get description => 'Serial ${port.title} (${port.id})';

  @override
  Future<void> connect() async {
    final link = Platform.isAndroid ? _AndroidLink() : _DesktopLink();
    await link.open(port.id, baudRate);
    _link = link;
    link.input.listen(
      _framer.add,
      onError: (Object e) => _close('ошибка порта: $e'),
      onDone: () => _close('порт закрыт (кабель отключён?)'),
    );
    // Как в официальных клиентах: серия START2 будит ноду, если она в спящем режиме.
    await link.write(Uint8List.fromList(List.filled(_wakeBytes, 0xC3)));
  }

  @override
  Future<void> send(Uint8List toRadio) async {
    final link = _link;
    if (link == null) throw StateError('порт не открыт');
    await link.write(StreamFramer.frame(toRadio));
  }

  @override
  Future<void> close() => _close('закрыто');

  Future<void> _close(String reason) async {
    if (_closed.isCompleted) return;
    _closed.complete(reason);
    final link = _link;
    _link = null;
    await link?.close();
  }
}

abstract class _SerialLink {
  Stream<Uint8List> get input;
  Future<void> open(String id, int baudRate);
  Future<void> write(Uint8List data);
  Future<void> close();
}

class _DesktopLink implements _SerialLink {
  SerialPort? _port;
  SerialPortReader? _reader;

  @override
  Stream<Uint8List> get input => _reader!.stream;

  @override
  Future<void> open(String id, int baudRate) async {
    final p = SerialPort(id);
    if (!p.openReadWrite()) {
      final err = SerialPort.lastError;
      p.dispose();
      throw StateError(
        'не удалось открыть $id: ${err?.message ?? 'неизвестная ошибка'}'
        '${Platform.isLinux ? ' (нужна группа dialout: sudo usermod -aG dialout \$USER, затем перелогиниться)' : ''}',
      );
    }
    final cfg = SerialPortConfig()
      ..baudRate = baudRate
      ..bits = 8
      ..parity = SerialPortParity.none
      ..stopBits = 1
      ..setFlowControl(SerialPortFlowControl.none);
    p.config = cfg;
    cfg.dispose();
    _port = p;
    _reader = SerialPortReader(p);
  }

  @override
  Future<void> write(Uint8List data) async {
    final p = _port;
    if (p == null) throw StateError('порт закрыт');
    var off = 0;
    while (off < data.length) {
      final n = p.write(Uint8List.sublistView(data, off), timeout: 1000);
      if (n <= 0) throw StateError('запись в порт не удалась');
      off += n;
    }
  }

  @override
  Future<void> close() async {
    _reader?.close();
    _reader = null;
    final p = _port;
    _port = null;
    if (p != null) {
      p.close();
      p.dispose();
    }
  }
}

class _AndroidLink implements _SerialLink {
  UsbPort? _port;

  @override
  Stream<Uint8List> get input => _port!.inputStream!;

  @override
  Future<void> open(String id, int baudRate) async {
    final p = await UsbSerial.createFromDeviceId(int.parse(id));
    if (p == null) throw StateError('устройство $id не найдено');
    if (!await p.open()) {
      throw StateError('нет доступа к USB-устройству (разрешение не выдано?)');
    }
    await p.setDTR(true);
    await p.setRTS(true);
    await p.setPortParameters(
      baudRate,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );
    _port = p;
  }

  @override
  Future<void> write(Uint8List data) async {
    final p = _port;
    if (p == null) throw StateError('порт закрыт');
    await p.write(data);
  }

  @override
  Future<void> close() async {
    final p = _port;
    _port = null;
    await p?.close();
  }
}
