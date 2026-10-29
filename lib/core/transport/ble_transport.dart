import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:universal_ble/universal_ble.dart';

import 'transport.dart';
import 'ble_pairing_hint.dart';

/// UUID GATT-сервиса Meshtastic.
class MeshBle {
  static const service = '6ba1b218-15a8-461f-9fa8-5dcae273eafd';
  static const toRadio = 'f75c76d2-129e-4dad-a1dd-7866124401e7';
  static const fromRadio = '2c55e69e-4993-11ed-b878-0242ac120002';
  static const fromNum = 'ed9da18c-a800-4f66-a670-aa7547e34453';
  static const logRadio = '5a3d6e49-06e6-4423-9944-e9de8cdf9547';
}

/// Занят ли BlueZ прошлой операцией (`org.bluez.Error.InProgress`).
bool isBleBusy(Object e) => e.toString().contains('InProgress');

/// BLE до ноды: запись в toRadio, чтение fromRadio по уведомлению fromNum,
/// лог ноды — уведомления logRadio (LogRecord).
class BleTransport implements Transport {
  BleTransport(this.deviceId, this.name, this.log);

  final String deviceId;
  final String name;
  final void Function(String) log;

  final _from = StreamController<Uint8List>.broadcast();
  final _logs = StreamController<NodeLogChunk>.broadcast();
  final _closed = Completer<String>();
  final _subs = <StreamSubscription>[];
  bool _draining = false;
  bool _drainAgain = false;
  bool _hasLogRadio = false;

  @override
  Stream<Uint8List> get fromRadio => _from.stream;
  @override
  Stream<NodeLogChunk> get logs => _logs.stream;
  @override
  Future<String> get closed => _closed.future;
  @override
  String get description => 'BLE $name ($deviceId)';

  bool _sameUuid(String a, String b) => a.toLowerCase() == b.toLowerCase();

  @override
  Future<void> connect() async {
    _subs.add(
      UniversalBle.connectionStream(deviceId).listen((connected) {
        if (!connected) _finish('BLE: соединение разорвано');
      }),
    );

    log('BLE: подключение…');
    try {
      await UniversalBle.connect(deviceId).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      // BlueZ мог уже держать соединение (нода сопряжена) — тогда события о подключении не будет.
      if (!Platform.isLinux) rethrow;
      log(
        'BLE: нет события о подключении, пробую работать с уже открытым соединением',
      );
    } catch (e) {
      // BlueZ забывает несопряжённое устройство после остановки скана — находим его снова.
      if (!Platform.isLinux || !e.toString().contains('UnknownObject')) rethrow;
      await _waitForAdvertisement();
      log('BLE: подключение (повтор)…');
      try {
        await UniversalBle.connect(
          deviceId,
        ).timeout(const Duration(seconds: 20));
      } finally {
        await UniversalBle.stopScan();
      }
    }
    log('BLE: подключено, поиск сервисов…');

    final services = await _discoverWithRetry();
    final mesh = services
        .where((s) => _sameUuid(s.uuid, MeshBle.service))
        .firstOrNull;
    if (mesh == null) throw Exception('сервис Meshtastic не найден');
    _hasLogRadio = mesh.characteristics.any(
      (c) => _sameUuid(c.uuid, MeshBle.logRadio),
    );

    try {
      final mtu = await UniversalBle.requestMtu(deviceId, 512);
      log('BLE: MTU $mtu');
    } catch (e) {
      log('BLE: MTU не изменён ($e)');
    }

    // Android: высокий приоритет на загрузку конфига и базы нод, через 30 с —
    // обычный ради батареи (как BleRadioTransport в Meshtastic-Android).
    if (Platform.isAndroid) {
      unawaited(_priority(BleConnectionPriority.highPerformance));
      _priorityTimer = Timer(
        const Duration(seconds: 30),
        () => _priority(BleConnectionPriority.balanced),
      );
    }

    _subs.add(
      UniversalBle.characteristicValueStream(
        deviceId,
        MeshBle.fromNum,
      ).listen((_) => _drain()),
    );
    await UniversalBle.subscribeNotifications(
      deviceId,
      MeshBle.service,
      MeshBle.fromNum,
    );

    if (_hasLogRadio) {
      _subs.add(
        UniversalBle.characteristicValueStream(
          deviceId,
          MeshBle.logRadio,
        ).listen((v) => _logs.add(NodeLogRecord(v))),
      );
      await UniversalBle.subscribeNotifications(
        deviceId,
        MeshBle.service,
        MeshBle.logRadio,
      );
      log('BLE: подписка на logRadio');
    } else {
      log('BLE: logRadio нет (старая прошивка) — лог только через FromRadio');
    }
  }

  /// BlueZ разбирает GATT не сразу (особенно при первом сопряжении),
  /// а universal_ble на Linux ждёт недолго — повторяем.
  Future<List<BleService>> _discoverWithRetry() async {
    for (var i = 1; ; i++) {
      try {
        return await UniversalBle.discoverServices(deviceId);
      } catch (e) {
        if (i >= 8 || _closed.isCompleted) rethrow;
        log('BLE: сервисы ещё не готовы ($i/8), жду…');
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }
  }

  Future<void> _waitForAdvertisement() async {
    log('BLE: ищу ноду в эфире…');
    final found = UniversalBle.scanStream
        .firstWhere((d) => d.deviceId.toLowerCase() == deviceId.toLowerCase())
        .timeout(const Duration(seconds: 15));
    await UniversalBle.startScan(
      scanFilter: ScanFilter(withServices: [MeshBle.service]),
    );
    try {
      await found;
    } on TimeoutException {
      await UniversalBle.stopScan();
      throw Exception('нода не найдена в эфире за 15 с');
    }
  }

  /// Вычитывает fromRadio, пока нода не вернёт пустое значение.
  Future<void> _drain() async {
    if (_draining) {
      _drainAgain = true;
      return;
    }
    _draining = true;
    try {
      do {
        _drainAgain = false;
        while (!_closed.isCompleted) {
          final v = await _whenFree(
            () =>
                UniversalBle.read(deviceId, MeshBle.service, MeshBle.fromRadio),
          );
          if (v.isEmpty) break;
          _from.add(v);
        }
      } while (_drainAgain && !_closed.isCompleted);
    } catch (e) {
      log('BLE: ошибка чтения fromRadio: $e');
      if (blePairingHint(e, deviceId, linux: Platform.isLinux) != null) {
        _finish('BLE: ошибка чтения fromRadio: $e');
      }
    } finally {
      _draining = false;
    }
  }

  /// BlueZ отвечает InProgress, пока не закончена прошлая GATT-операция
  /// (подписка, чтение) — повторяем, а не падаем.
  Future<T> _whenFree<T>(Future<T> Function() op) async {
    for (var i = 1; ; i++) {
      try {
        return await op();
      } catch (e) {
        if (!isBleBusy(e) || i >= 20 || _closed.isCompleted) rethrow;
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  @override
  Future<void> send(Uint8List toRadio) async {
    await _whenFree(
      () => UniversalBle.write(
        deviceId,
        MeshBle.service,
        MeshBle.toRadio,
        toRadio,
      ),
    );
    // После want_config нода не всегда шлёт fromNum — читаем сами.
    unawaited(_drain());
  }

  void _finish(String reason) {
    _priorityTimer?.cancel();
    if (!_closed.isCompleted) _closed.complete(reason);
  }

  Timer? _priorityTimer;

  Future<void> _priority(BleConnectionPriority p) async {
    try {
      await UniversalBle.requestConnectionPriority(deviceId, p);
      log('BLE: приоритет ${p.name}');
    } catch (e) {
      log('BLE: приоритет не изменён ($e)');
    }
  }

  @override
  Future<void> close() async {
    _finish('отключено пользователем');
    for (final s in _subs) {
      await s.cancel();
    }
    try {
      await UniversalBle.disconnect(deviceId);
    } catch (_) {}
  }
}
