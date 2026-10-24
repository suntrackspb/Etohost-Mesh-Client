import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/message_filter.dart';
import 'package:flutter_test/flutter_test.dart';

final t0 = DateTime(2026, 10, 24);

Message m(int id, int from, {int emoji = 0, bool out = false}) => Message(
  id: id,
  packetId: id,
  fromNum: from,
  toNum: broadcastNum,
  channel: 0,
  channelKey: 'mediumfast',
  body: 'x',
  rxTime: t0.add(Duration(minutes: id)),
  replyId: emoji == 0 ? null : 1,
  isOutgoing: out,
  emoji: emoji,
  viaMqtt: false,
  pkiEncrypted: false,
  xeddsaSigned: false,
  ackState: AckState.values.first,
  heardOnRadio: false,
  heardOnMirror: true,
  relayCount: 0,
  isBot: false,
);

bool reaction(Message m) => m.emoji != 0;

void main() {
  final all = [m(1, 7), m(2, 9), m(3, 9, emoji: 1), m(4, 9, out: true)];

  test('по умолчанию сообщения и реакции игнорируемой ноды убираются', () {
    final r = hideIgnored(all, {9}, isReaction: reaction);
    expect(r.shown.map((x) => x.id), [1, 4]);
    expect(r.hidden, isEmpty);
  });

  test('показ скрытых: сообщение остаётся свёрнутым, реакция — нет', () {
    final r = hideIgnored(all, {9}, isReaction: reaction, showHidden: true);
    expect(r.shown.map((x) => x.id), [1, 2, 4]);
    expect(r.hidden.map((x) => x.id), [2]);
  });

  test('никого не игнорируем — лента как есть', () {
    expect(hideIgnored(all, {}, isReaction: reaction).shown, all);
  });
}
