import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshex/core/geo/geo.dart';
import 'package:meshex/features/nodes/compass/compass_controller.dart';

class FakeCompassInputs implements CompassInputs {
  CompassLocationAccess result = CompassLocationAccess.allowed;
  Future<CompassLocationAccess>? pendingAccess;
  final location = StreamController<CompassFix>.broadcast(sync: true);
  final compass = StreamController<CompassHeading>.broadcast(sync: true);
  int locationStarts = 0, headingStarts = 0;

  @override
  Future<CompassLocationAccess> access({required bool requestPermission}) =>
      pendingAccess ?? Future.value(result);
  @override
  Stream<CompassFix> fixes() {
    locationStarts++;
    return location.stream;
  }

  @override
  Stream<CompassHeading> headings() {
    headingStarts++;
    return compass.stream;
  }

  @override
  Future<void> openSettings({required bool permission}) async {}
  Future<void> close() async {
    await location.close();
    await compass.close();
  }
}

void main() {
  test('geographic bearing and shortest turn across north', () {
    expect(bearingDeg((lat: 0, lon: 0), (lat: 0, lon: 1)), closeTo(90, 0.001));
    expect(compassTurn(359, 1), 2);
    expect(compassTurn(1, 359), -2);
    expect(compassAngularError(100, 100), closeTo(45, 0.001));
    expect(compassAngularError(100, 0), 180);
    expect(compassAngularError(null, 100), isNull);
  });

  test('denied permission starts no sensors and can be retried', () async {
    final input = FakeCompassInputs()..result = CompassLocationAccess.denied;
    final controller = NodeCompassController(input);
    await controller.start(requestPermission: true);
    expect(controller.access, CompassLocationAccess.denied);
    expect(input.locationStarts, 0);
    expect(input.headingStarts, 0);
    input.result = CompassLocationAccess.allowed;
    await controller.start();
    expect(input.locationStarts, 1);
    controller.dispose();
    await input.close();
  });

  test(
    'combines fresh fixes and true heading, releases both streams',
    () async {
      final input = FakeCompassInputs();
      final controller = NodeCompassController(input);
      await controller.start();
      input.location.add((
        position: (lat: 59.94, lon: 30.31),
        accuracy: 10,
        time: DateTime.now(),
      ));
      expect(controller.hasFreshFix, isTrue);
      expect(input.headingStarts, 1);
      input.compass.add((degrees: 361, calibrate: false, available: true));
      expect(controller.trueHeading, 1);
      input.compass.add((degrees: null, calibrate: true, available: true));
      expect(
        controller.trueHeading,
        isNull,
        reason: 'magnetic heading is not geographic heading',
      );
      await controller.stop();
      expect(input.location.hasListener, isFalse);
      expect(input.compass.hasListener, isFalse);
      await controller.start();
      expect(
        controller.fix,
        isNull,
        reason: 'resume must not show a stale location',
      );
      controller.dispose();
      await input.close();
    },
  );

  test(
    'closing during a permission request cannot attach sensors later',
    () async {
      final pending = Completer<CompassLocationAccess>();
      final input = FakeCompassInputs()..pendingAccess = pending.future;
      final controller = NodeCompassController(input);
      final start = controller.start();
      controller.dispose();
      pending.complete(CompassLocationAccess.allowed);
      await start;
      expect(input.locationStarts, 0);
      expect(input.headingStarts, 0);
      await input.close();
    },
  );

  test('stream errors clear the affected data and permit retry', () async {
    final input = FakeCompassInputs();
    final controller = NodeCompassController(input);
    await controller.start();
    input.location.add((
      position: (lat: 0, lon: 0),
      accuracy: 10,
      time: DateTime.now(),
    ));
    input.compass.addError(StateError('sensor unavailable'));
    expect(controller.headingError, isTrue);
    input.location.addError(StateError('location disabled'));
    expect(controller.locationError, isTrue);
    expect(controller.fix, isNull);
    await controller.start();
    expect(controller.headingError, isFalse);
    expect(controller.locationError, isFalse);
    controller.dispose();
    await input.close();
  });

  test(
    'stale cached GPS fixes cannot start a heading with old declination',
    () async {
      final input = FakeCompassInputs();
      final controller = NodeCompassController(input);
      await controller.start();
      input.location.add((
        position: (lat: 0, lon: 0),
        accuracy: 10,
        time: DateTime.now().subtract(const Duration(seconds: 31)),
      ));
      expect(controller.hasFreshFix, isFalse);
      expect(input.headingStarts, 0);
      input.location.add((
        position: (lat: 0, lon: 0),
        accuracy: 10,
        time: DateTime.now(),
      ));
      expect(controller.hasFreshFix, isTrue);
      expect(input.headingStarts, 1);
      controller.dispose();
      await input.close();
    },
  );
}
