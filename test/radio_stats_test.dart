import 'package:flutter_test/flutter_test.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/radio_stats.dart';

void main() {
  test('сводка: эфир, онлайн, каналы, своя нода', () {
    final now = DateTime(2026, 1, 1, 12);
    Node n(int num, {bool radio = true, DateTime? heard, int? bat}) => Node(
      num: num,
      userId: '',
      longName: '',
      shortName: '',
      hwModel: 0,
      role: 0,
      isUnmessagable: false,
      hasXeddsaSigned: false,
      lastHeard: heard,
      viaMqtt: false,
      isFavorite: false,
      isIgnored: false,
      batteryLevel: bat,
      channelUtilization: 0.6,
      airUtilTx: 0,
      onRadio: radio,
      onMirror: !radio,
    );
    final s = RadioStats.of(
      [
        n(1, heard: now, bat: 101),
        n(2, heard: now.subtract(const Duration(minutes: 30))),
        n(3, heard: now.subtract(const Duration(hours: 5))),
        n(4, radio: false, heard: now),
      ],
      const [
        MeshChannel(index: 0, name: '', role: 1),
        MeshChannel(index: 1, name: '', role: 0),
      ],
      me: 1,
      now: now,
    );
    expect(s.onRadio, 2);
    expect(s.online, 1);
    expect(s.channels, 1);
    expect(s.onPower, isTrue);
    expect(s.channelUtil, 0.6);
  });
}
