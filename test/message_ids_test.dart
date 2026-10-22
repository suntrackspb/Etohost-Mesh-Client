import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/message_meta.dart';
import 'package:flutter_test/flutter_test.dart';

Message m(int packetId, {int? mirrorId}) => Message(
  id: 1,
  packetId: packetId,
  fromNum: 0x9ef0caa0,
  toNum: broadcastNum,
  channel: 0,
  channelKey: 'mediumfast',
  body: 'x',
  rxTime: DateTime(2026, 10, 22),
  isOutgoing: false,
  emoji: 0,
  viaMqtt: false,
  pkiEncrypted: false,
  xeddsaSigned: false,
  ackState: AckState.values.first,
  heardOnRadio: false,
  heardOnMirror: true,
  mirrorId: mirrorId,
  relayCount: 0,
  isBot: false,
);

void main() {
  test('packet_id десятичный и hex, отправитель !id', () {
    expect(messageIds(m(255)), [
      ('ID пакета', '255'),
      ('ID пакета (hex)', '0x000000ff'),
      ('Отправитель', '!9ef0caa0'),
    ]);
  });

  test('из зеркала без packet_id — id в зеркале', () {
    expect(messageIds(m(-3485473, mirrorId: 3485473)), [
      ('ID в зеркале', '3485473'),
      ('Отправитель', '!9ef0caa0'),
    ]);
  });
}
