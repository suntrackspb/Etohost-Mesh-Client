import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:usb_serial/usb_serial.dart';

import 'ansi_text.dart';
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
          title: fixAnsiText(p.productName ?? p.description ?? name),
          subtitle: [
            name,
            p.manufacturer,
          ].whereType<String>().map(fixAnsiText).join(' · '),
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

/// Десктоп (libserialport). Чтение — в своём изоляте, а не в
/// SerialPortReader: тот останавливает изолят `kill()` до следующего
/// события, а изолят крутится в синхронном цикле и не останавливается —
/// после `dispose()` он продолжал читать освобождённый sp_port, память
/// портилась, и приложение падало (macOS — при «Отключиться», Windows —
/// при отключении кабеля). Поэтому при закрытии: закрыть порт (чтение
/// получит ошибку и выйдет), дождаться выхода изолята и только потом
/// освободить sp_port.
class _DesktopLink implements _SerialLink {
  SerialPort? _port;
  final _input = StreamController<Uint8List>();
  ReceivePort? _data;
  ReceivePort? _exit;
  final _exited = Completer<void>();
  Isolate? _isolate;
  bool _closing = false;

  @override
  Stream<Uint8List> get input => _input.stream;

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
      ..setFlowControl(SerialPortFlowControl.none)
      // Как на Android: без DTR встроенный USB ESP32-S3 на Windows молчит
      // (порт открыт, но конфиг не приходит).
      ..dtr = SerialPortDtr.on
      ..rts = SerialPortRts.on;
    // Порт оставляет cfg себе и освобождает его в dispose(): свой
    // cfg.dispose() здесь — двойное освобождение и порча кучи (краш позже,
    // в случайном месте).
    p.config = cfg;
    _port = p;
    final data = _data = ReceivePort();
    final exit = _exit = ReceivePort();
    exit.first.then((_) {
      if (!_exited.isCompleted) _exited.complete();
    });
    data.listen((m) {
      if (_closing || _input.isClosed) return;
      if (m is Uint8List) {
        _input.add(m);
      } else {
        _input.addError(StateError('$m'));
      }
    });
    _isolate = await Isolate.spawn(
      _readLoop,
      (p.address, data.sendPort),
      onExit: exit.sendPort,
      debugName: 'serial $id',
    );
  }

  /// Изолят чтения: до ошибки (порт закрыт или кабель вынут).
  static void _readLoop((int, SendPort) a) {
    final p = SerialPort.fromAddress(a.$1);
    while (true) {
      try {
        final d = p.read(4096, timeout: 50);
        if (d.isNotEmpty) a.$2.send(d);
      } catch (e) {
        a.$2.send('$e');
        return;
      }
    }
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
    final p = _port;
    _port = null;
    if (p == null) return;
    _closing = true;
    p.close();
    var exited = await _exited.future
        .timeout(const Duration(seconds: 2))
        .then((_) => true, onError: (_) => false);
    if (!exited) {
      _isolate?.kill(priority: Isolate.immediate);
      exited = await _exited.future
          .timeout(const Duration(seconds: 1))
          .then((_) => true, onError: (_) => false);
    }
    // Изолят так и не вышел — лучше не освобождать sp_port (утечка),
    // чем освободить его под ним (краш).
    if (exited) p.dispose();
    _data?.close();
    _exit?.close();
    if (!_input.isClosed) await _input.close();
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
