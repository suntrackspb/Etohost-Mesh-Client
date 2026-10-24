import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/node_row_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('роль по имени прошивки', () {
    expect(roleName(0), 'Client');
    expect(roleName(1), 'ClientMute');
    expect(roleName(999), '999');
  });

  test('SNR относительно пресета', () {
    expect(snrQuality(-10, 'LongFast'), SignalQuality.good);
    expect(snrQuality(-10, 'ShortFast'), SignalQuality.fair);
    expect(snrQuality(-16.5, 'ShortFast'), SignalQuality.none);
    expect(snrQuality(-24, 'LongFast'), SignalQuality.bad);
    expect(snrQuality(-10, null), SignalQuality.good);
  });

  test('RSSI по порогам', () {
    expect(rssiQuality(-90), SignalQuality.good);
    expect(rssiQuality(-118), SignalQuality.fair);
    expect(rssiQuality(-123), SignalQuality.bad);
    expect(rssiQuality(-130), SignalQuality.none);
  });

  test('недавно слышали', () {
    final now = DateTime(2026, 1, 1, 12);
    expect(heardRecently(DateTime(2026, 1, 1, 11), now), isTrue);
    expect(heardRecently(DateTime(2026, 1, 1, 9), now), isFalse);
    expect(heardRecently(null, now), isFalse);
  });
  test('ноды зеркала на чужом пресете скрываются', () {
    Node n({String? preset, bool radio = false}) => Node(
      num: 1,
      userId: '!00000001',
      longName: '',
      shortName: '',
      hwModel: 0,
      role: 0,
      isUnmessagable: false,
      hasXeddsaSigned: false,
      mirrorCorrected: false,
      viaMqtt: false,
      isFavorite: false,
      isIgnored: false,
      onRadio: radio,
      onMirror: true,
      modemPreset: preset,
    );
    expect(onOwnPreset(n(preset: 'LongFast'), 'MediumFast'), isFalse);
    expect(onOwnPreset(n(preset: 'MediumFast'), 'MediumFast'), isTrue);
    expect(onOwnPreset(n(), 'MediumFast'), isTrue);
    expect(
      onOwnPreset(n(preset: 'LongFast', radio: true), 'MediumFast'),
      isTrue,
    );
    expect(onOwnPreset(n(preset: 'LongFast'), null), isTrue);
  });
}
