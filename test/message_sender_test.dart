import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/core/radio/send_queue.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/message_sender.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late List<MeshPacket> sent;
  late Completer<DeliveryResult> result;
  var nextId = 100;

  MessageSender sender() => MessageSender(
    db,
    (p) {
      sent.add(p);
      return result.future;
    },
    () => 0xAA,
    () => nextId++,
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sent = [];
    result = Completer();
  });
  tearDown(() => db.close());

  Future<Message> only() => db.select(db.messages).getSingle();

  test(
    'сообщение сразу в ленте со статусом «ждём», затем доставлено',
    () async {
      final f = sender().sendToChannel(
        channel: 1,
        channelKey: 'test',
        text: 'привет',
        replyId: 7,
      );
      await pumpEventQueue();
      var m = await only();
      expect(m.ackState, AckState.pending);
      expect(m.isOutgoing, isTrue);
      expect(sent.single.channel, 1);
      expect(sent.single.wantAck, isTrue);
      expect(sent.single.decoded.replyId, 7);

      result.complete(const DeliveryResult(DeliveryStatus.acked));
      await f;
      m = await only();
      expect(m.ackState, AckState.acked);
    },
  );

  test('ошибка маршрутизации и повтор с новым id', () async {
    final s = sender();
    result.complete(
      const DeliveryResult(DeliveryStatus.failed, Routing_Error.NO_RESPONSE),
    );
    await s.sendToChannel(
      channel: 0,
      channelKey: 'k',
      text: '👍',
      replyId: 5,
      emoji: true,
    );
    var m = await only();
    expect(m.ackState, AckState.failed);
    expect(m.ackError, Routing_Error.NO_RESPONSE.value);
    expect(sent.single.decoded.emoji, 1);

    result = Completer()
      ..complete(const DeliveryResult(DeliveryStatus.disconnected));
    await s.retry(m);
    final again = await only();
    expect(again.packetId, isNot(m.packetId));
    expect(again.ackState, AckState.notSent);
    expect(again.ackError, isNull);
  });

  test('слишком длинный текст не отправляется', () async {
    expect(
      () =>
          sender().sendToChannel(channel: 0, channelKey: 'k', text: 'ы' * 101),
      throwsArgumentError,
    );
  });

  test('личное: без ключа не отправляется, с ключом — PKI', () async {
    final s = sender();
    expect(
      () => s.sendDirect(to: 0xBB, text: 'hi'),
      throwsA(isA<StateError>()),
    );
    await db
        .into(db.nodes)
        .insert(
          NodesCompanion.insert(
            num: const Value(0xBB),
            publicKey: Value(Uint8List.fromList(List.filled(32, 7))),
          ),
        );
    result.complete(const DeliveryResult(DeliveryStatus.acked));
    await s.sendDirect(to: 0xBB, text: 'hi');
    final p = sent.single;
    expect(p.to, 0xBB);
    expect(p.pkiEncrypted, isTrue);
    expect(p.publicKey, hasLength(32));
    final m = await only();
    expect(m.pkiEncrypted, isTrue);
    expect(m.channelKey, '');
    expect(await db.watchDirectMessages(0xBB).first, hasLength(1));
    expect(await db.watchChannelMessages('').first, isEmpty);
  });
}
