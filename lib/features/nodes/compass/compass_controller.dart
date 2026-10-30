import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:precise_compass/precise_compass.dart';

import '../../../core/geo/geo.dart';

bool get supportsNodeCompass =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

enum CompassLocationAccess { allowed, denied, deniedForever, disabled }

typedef CompassFix = ({LatLon position, double accuracy, DateTime time});
typedef CompassHeading = ({double? degrees, bool calibrate, bool available});

/// Platform boundary kept separate so lifecycle and sensor errors can be tested.
abstract interface class CompassInputs {
  Future<CompassLocationAccess> access({required bool requestPermission});
  Stream<CompassFix> fixes();
  Stream<CompassHeading> headings();
  Future<void> openSettings({required bool permission});
}

class DeviceCompassInputs implements CompassInputs {
  @override
  Future<CompassLocationAccess> access({
    required bool requestPermission,
  }) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return CompassLocationAccess.disabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.denied => CompassLocationAccess.denied,
      LocationPermission.deniedForever => CompassLocationAccess.deniedForever,
      LocationPermission.unableToDetermine => CompassLocationAccess.denied,
      _ => CompassLocationAccess.allowed,
    };
  }

  @override
  Stream<CompassFix> fixes() =>
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).map(
        (p) => (
          position: (lat: p.latitude, lon: p.longitude),
          accuracy: p.accuracy,
          time: p.timestamp,
        ),
      );

  @override
  Stream<CompassHeading> headings() => PreciseCompass.headingStream().map(
    (reading) => (
      // Bearings are geographic. Never silently subtract magnetic heading.
      degrees: reading.headingTrue,
      calibrate:
          reading.shouldCalibrate ||
          reading.accuracy == CompassAccuracy.low ||
          reading.accuracy == CompassAccuracy.unreliable,
      available: reading.hasHeading,
    ),
  );

  @override
  Future<void> openSettings({required bool permission}) async {
    if (permission) {
      await Geolocator.openAppSettings();
    } else {
      await Geolocator.openLocationSettings();
    }
  }
}

/// Shortest signed rotation: crossing north must not spin the arrow a full turn.
double compassTurn(double from, double to) => (to - from + 540) % 360 - 180;

/// Combines position uncertainty with target precision, as in the Android client.
double? compassAngularError(double? radiusMeters, double distanceMeters) {
  if (radiusMeters == null) return null;
  if (distanceMeters <= 0) return 180;
  return math.atan2(radiusMeters, distanceMeters) * 180 / math.pi;
}

class NodeCompassController extends ChangeNotifier {
  NodeCompassController(this.inputs);

  final CompassInputs inputs;
  CompassLocationAccess? access;
  CompassFix? fix;
  CompassHeading? heading;
  bool locationError = false;
  bool headingError = false;
  bool running = false;
  int _generation = 0;
  StreamSubscription<CompassFix>? _location;
  StreamSubscription<CompassHeading>? _heading;
  Timer? _clock;
  bool _disposed = false;
  Future<void> _cancelling = Future.value();
  DateTime? _headingAt;

  Future<void> start({bool requestPermission = false}) async {
    final generation = ++_generation;
    running = true;
    fix = null;
    heading = null;
    access = null;
    locationError = false;
    headingError = false;
    _clock?.cancel();
    _headingAt = null;
    _notify();
    await _releaseSensors();
    if (!_current(generation)) return;
    try {
      final result = await inputs.access(requestPermission: requestPermission);
      if (!_current(generation)) return;
      access = result;
      _notify();
      if (result != CompassLocationAccess.allowed) return;
      _location = inputs.fixes().listen(
        (value) {
          if (!_current(generation)) return;
          if (!value.position.lat.isFinite ||
              !value.position.lon.isFinite ||
              value.position.lat.abs() > 90 ||
              value.position.lon.abs() > 180) {
            return;
          }
          fix = value;
          locationError = false;
          // Start heading after GPS has populated the platform location cache,
          // which Android uses to compute magnetic declination.
          if (hasFreshFix) {
            _heading ??= inputs.headings().listen(
              (value) {
                if (!_current(generation)) return;
                heading = value;
                _headingAt = DateTime.now();
                headingError = false;
                _notify();
              },
              onError: (Object error) {
                if (!_current(generation)) return;
                heading = null;
                headingError = true;
                _notify();
              },
            );
          }
          _notify();
        },
        onError: (Object error) {
          if (!_current(generation)) return;
          fix = null;
          locationError = true;
          _notify();
        },
      );
      _clock = Timer.periodic(const Duration(seconds: 1), (_) => _notify());
    } catch (_) {
      if (!_current(generation)) return;
      locationError = true;
      _notify();
    }
  }

  bool get hasFreshFix {
    final value = fix;
    if (value == null) return false;
    final age = DateTime.now().difference(value.time);
    return age >= const Duration(seconds: -10) &&
        age <= const Duration(seconds: 30);
  }

  double? get trueHeading {
    final at = _headingAt;
    if (at == null ||
        DateTime.now().difference(at) > const Duration(seconds: 5)) {
      return null;
    }
    final value = heading?.degrees;
    return value != null && value.isFinite && value >= 0 ? value % 360 : null;
  }

  bool _current(int generation) =>
      !_disposed && running && generation == _generation;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> stop() async {
    ++_generation;
    running = false;
    _clock?.cancel();
    _clock = null;
    await _releaseSensors();
  }

  Future<void> _releaseSensors() {
    final location = _location;
    final heading = _heading;
    _location = null;
    _heading = null;
    // Cancel both immediately. A slow GPS cancellation must not keep the
    // magnetometer running, and a new start waits for the previous cleanup.
    return _cancelling = Future.wait<void>([
      _cancelling,
      if (location != null) location.cancel(),
      if (heading != null) heading.cancel(),
    ]).then((_) {}).catchError((Object _) {});
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(stop());
    super.dispose();
  }
}
