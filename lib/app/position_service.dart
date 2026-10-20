import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../data/position_sharer.dart';

/// Состояние передачи позиции — для экрана настроек.
enum PositionShareStatus {
  /// Ждём соединения с нодой или первой точки.
  waiting,
  active,
  noPermission,
  serviceOff,
  error,
}

/// Берёт координаты GPS по таймеру и отдаёт их [PositionSharer].
/// Таймер вместо потока: стоя на месте поток молчит, а прошивке нужна
/// периодическая точка; заодно меньше расход батареи.
class PositionService extends ChangeNotifier {
  PositionService(this.sharer, {required Duration interval}) {
    sharer.interval = interval;
  }

  final PositionSharer sharer;

  PositionShareStatus status = PositionShareStatus.waiting;
  String? error;
  DateTime? lastSentAt;

  Timer? _timer;
  bool _disposed = false;

  Future<void> start() async {
    if (!await _permission()) return;
    unawaited(_tick());
    // Точку берём чаще интервала, решение о передаче — за PositionSharer.
    var every = sharer.interval ~/ 3;
    if (every < const Duration(minutes: 1)) every = const Duration(minutes: 1);
    _timer = Timer.periodic(every, (_) => _tick());
  }

  Future<bool> _permission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _set(PositionShareStatus.serviceOff);
        return false;
      }
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.denied ||
          p == LocationPermission.deniedForever) {
        _set(PositionShareStatus.noPermission);
        return false;
      }
      return true;
    } catch (e) {
      _set(PositionShareStatus.error, e);
      return false;
    }
  }

  Future<void> _tick() async {
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
      final sent = await sharer.onFix((
        lat: p.latitude,
        lon: p.longitude,
        altitude: p.altitude == 0 ? null : p.altitude,
        time: DateTime.now(),
      ));
      if (sent) lastSentAt = DateTime.now();
      _set(
        sharer.lastSent == null
            ? PositionShareStatus.waiting
            : PositionShareStatus.active,
      );
    } catch (e) {
      _set(PositionShareStatus.error, e);
    }
  }

  void _set(PositionShareStatus s, [Object? e]) {
    if (_disposed) return;
    status = s;
    error = e?.toString();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}

/// Разовая точка телефона (для фиксированной позиции ноды). Бросает
/// исключение с понятным текстом, если геолокация недоступна.
Future<Fix> phoneFix() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw StateError('геолокация на телефоне выключена');
  }
  var p = await Geolocator.checkPermission();
  if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
  if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
    throw StateError('нет доступа к геолокации');
  }
  final pos = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 30),
    ),
  );
  return (
    lat: pos.latitude,
    lon: pos.longitude,
    altitude: pos.altitude == 0 ? null : pos.altitude,
    time: DateTime.now(),
  );
}
