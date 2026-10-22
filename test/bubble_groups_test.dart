import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/bubble_groups.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

final t0 = DateTime(2026, 10, 22, 3, 30);

Message m(int from, int minute, {bool out = false, DateTime? at}) => Message(
  id: minute,
  packetId: minute,
  fromNum: from,
  toNum: broadcastNum,
  channel: 0,
  channelKey: 'mediumfast',
  body: 'x',
  rxTime: at ?? t0.add(Duration(minutes: minute)),
  isOutgoing: out,
  emoji: 0,
  viaMqtt: false,
  pkiEncrypted: false,
  xeddsaSigned: false,
  ackState: AckState.values.first,
  heardOnRadio: true,
  heardOnMirror: false,
  relayCount: 0,
  isBot: false,
);

void main() {
  test('серия одного автора: first / middle / last, лента от новых', () {
    // Хронологически: A0 A1 A2 B3 A4; лента — от новых к старым.
    final feed = [m(1, 4), m(2, 3), m(1, 2), m(1, 1), m(1, 0)];
    expect(bubblePositions(feed), [
      BubblePos.single,
      BubblePos.single,
      BubblePos.last,
      BubblePos.middle,
      BubblePos.first,
    ]);
  });

  test('пауза больше 5 минут и смена дня рвут серию', () {
    expect(sameBubbleGroup(m(1, 0), m(1, 5)), isTrue);
    expect(sameBubbleGroup(m(1, 0), m(1, 6)), isFalse);
    final late = DateTime(2026, 10, 21, 23, 59);
    final early = DateTime(2026, 10, 22, 0, 1);
    expect(sameBubbleGroup(m(1, 0, at: late), m(1, 0, at: early)), isFalse);
  });

  test('свои сообщения — одна серия, со чужими не склеиваются', () {
    expect(sameBubbleGroup(m(1, 0, out: true), m(1, 1, out: true)), isTrue);
    expect(sameBubbleGroup(m(1, 0, out: true), m(1, 1)), isFalse);
  });
}
