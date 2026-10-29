import 'dart:async';

import 'package:etohost_mesh/core/transport/ble_pairing_hint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mac = 'AA:BB:CC:DD:EE:FF';
  test('Linux busy and timeout offer pairing commands for this device', () {
    for (final error in [
      Exception('org.bluez.Error.InProgress'),
      TimeoutException('write'),
    ]) {
      final hint = blePairingHint(error, mac, linux: true)!;
      expect(hint, contains('pair $mac'));
      expect(hint, contains('agent KeyboardOnly'));
      expect(hint, contains('trust $mac'));
    }
  });
  test('unrelated errors and other platforms do not suggest pairing', () {
    expect(
      blePairingHint(Exception('service not found'), mac, linux: true),
      isNull,
    );
    expect(blePairingHint(TimeoutException(''), mac, linux: false), isNull);
  });
  test('arbitrary device ID is not inserted into terminal commands', () {
    final hint = blePairingHint(
      TimeoutException(''),
      'bad; command',
      linux: true,
    )!;
    expect(hint, isNot(contains('bad; command')));
    expect(hint, contains('pair <MAC ноды>'));
  });
}
