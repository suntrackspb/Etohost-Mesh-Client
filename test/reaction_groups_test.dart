import 'package:meshex/data/database.dart';
import 'package:meshex/data/reaction_groups.dart';
import 'package:flutter_test/flutter_test.dart';

Message r(
  int from,
  String emoji,
  int minute, {
  bool radio = false,
  bool mirror = true,
  bool out = false,
  int? hopStart,
  int? hopLimit,
  double? snr,
  int? rssi,
}) => Message(
  id: from * 100 + minute,
  packetId: from * 100 + minute,
  fromNum: from,
  toNum: 0xffffffff,
  channelKey: 'ch:0',
  body: emoji,
  rxTime: DateTime(2026, 10, 21, 22, minute),
  isOutgoing: out,
  emoji: 1,
  replyId: 42,
  viaMqtt: false,
  heardOnRadio: radio,
  heardOnMirror: mirror,
  relayCount: 0,
  isBot: false,
  pkiEncrypted: false,
  xeddsaSigned: false,
  ackState: AckState.none,
  hopStart: hopStart,
  hopLimit: hopLimit,
  rxSnr: snr,
  rxRssi: rssi,
);

void main() {
  test('группы по эмодзи в порядке первой реакции, без повторов от ноды', () {
    final groups = groupReactions([
      r(2, '👋', 26),
      r(1, '👋', 22),
      r(3, '🤝', 24),
      r(1, '👋', 23), // повтор той же ноды
      r(1, '🤝', 25), // та же нода, другой эмодзи — считается
    ]);
    expect([for (final g in groups) g.emoji], ['👋', '🤝']);
    expect([for (final m in groups[0].items) m.fromNum], [1, 2]);
    expect(groups[0].items.first.rxTime.minute, 22);
    expect([for (final m in groups[1].items) m.fromNum], [3, 1]);
    expect(allReactions(groups).map((m) => m.rxTime.minute), [22, 24, 25, 26]);
  });

  test('пустые реакции пропускаются', () {
    expect(groupReactions([r(1, '  ', 1)]), isEmpty);
  });

  test('источник реакции', () {
    expect(reactionSource(r(1, '👍', 1)), 'NET');
    expect(reactionSource(r(1, '👍', 1, out: true)), 'TX');
    expect(
      reactionSource(r(1, '👍', 1, radio: true, hopStart: 7, hopLimit: 5)),
      'RX · 2 хопа',
    );
    expect(
      reactionSource(r(1, '👍', 1, radio: true, hopStart: 7, hopLimit: 2)),
      'RX · 5 хопов',
    );
    expect(
      reactionSource(r(1, '👍', 1, radio: true, hopStart: 3, hopLimit: 2)),
      'RX · 1 хоп',
    );
    expect(
      reactionSource(
        r(
          1,
          '👍',
          1,
          radio: true,
          hopStart: 3,
          hopLimit: 3,
          snr: -5.5,
          rssi: -80,
        ),
      ),
      'RX · S -5.5 · R -80',
    );
    expect(reactionSource(r(1, '👍', 1, radio: true)), 'RX');
    expect(reactionSource(r(1, '👍', 1, mirror: false)), isNull);
  });
}
