import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/core/radio/send_queue.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/node_actions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late List<MeshPacket> sent;
  var status = DeliveryStatus.acked;
  var nextId = 100;

  NodeActions actions() => NodeActions(
    db,
    (p) async {
      sent.add(p);
      return DeliveryResult(status);
    },
    () => 0xAA,
    () => nextId++,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    sent = [];
    status = DeliveryStatus.acked;
    for (final n in [0xAA, 0x42]) {
      await db
          .into(db.nodes)
          .insert(NodesCompanion.insert(num: Value(n), longName: Value('n$n')));
    }
  });
  tearDown(() => db.close());

  Future<Node> node(int n) =>
      (db.select(db.nodes)..where((r) => r.num.equals(n))).getSingle();

  test('избранное: админ-пакет своей ноде, флаг после подтверждения', () async {
    expect(await actions().setFavorite(0x42, true), isTrue);
    final p = sent.single;
    expect(p.to, 0xAA);
    expect(p.wantAck, isTrue);
    expect(p.hopLimit, 0);
    expect(AdminMessage.fromBuffer(p.decoded.payload).setFavoriteNode, 0x42);
    expect((await node(0x42)).isFavorite, isTrue);
  });

  test('игнор без радио — только наш флаг, пакетов нет', () async {
    expect(await actions().setIgnored(0x42, true, radio: false), isTrue);
    expect(sent, isEmpty);
    expect((await node(0x42)).isIgnored, isTrue);
  });

  test(
    'игнор по радио: команда своей ноде, флаг ставится и без ответа',
    () async {
      status = DeliveryStatus.timeout;
      expect(await actions().setIgnored(0x42, true, radio: true), isFalse);
      expect(
        AdminMessage.fromBuffer(sent.single.decoded.payload).setIgnoredNode,
        0x42,
      );
      expect((await node(0x42)).isIgnored, isTrue);
    },
  );

  test('удаление убирает ноду из базы', () async {
    expect(await actions().remove(0x42), isTrue);
    expect(
      AdminMessage.fromBuffer(sent.single.decoded.payload).removeByNodenum,
      0x42,
    );
    expect(await db.select(db.nodes).get(), hasLength(1));
  });

  test('трассировка и обмен NodeInfo — запрос ответа, без hop_limit', () async {
    await actions().traceroute(0x42);
    await actions().exchangeNodeInfo(0x42);
    for (final p in sent) {
      expect(p.to, 0x42);
      expect(p.decoded.wantResponse, isTrue);
      expect(p.hopLimit, 0);
    }
    expect(sent[0].decoded.portnum, PortNum.TRACEROUTE_APP);
    expect(User.fromBuffer(sent[1].decoded.payload).longName, 'n170');
  });

  test('трассировка сразу пишется в журнал без ответа', () async {
    final (id, _) = await actions().traceroute(0x42);
    final rec = (await db.select(db.traceroutes).get()).single;
    expect(rec.requestId, id);
    expect(rec.targetNum, 0x42);
    expect(TracerouteResult.parse(rec, 0xAA).answered, isFalse);
  });

  test('трассировка не ушла — записи нет', () async {
    final a = NodeActions(
      db,
      (p) => throw StateError('нет связи'),
      () => 0xAA,
      () => 1,
    );
    await expectLater(a.traceroute(0x42), throwsStateError);
    expect(await db.select(db.traceroutes).get(), isEmpty);
  });

  test('рассылка своей NodeInfo — всем, без ответа и hop_limit', () async {
    await actions().broadcastNodeInfo();
    final p = sent.single;
    expect(p.to, 0xffffffff);
    expect(p.wantAck, isFalse);
    expect(p.decoded.wantResponse, isFalse);
    expect(p.hopLimit, 0);
    expect(p.decoded.portnum, PortNum.NODEINFO_APP);
    expect(User.fromBuffer(p.decoded.payload).longName, 'n170');
  });

  test(
    'рассылка позиции — всем, без hop_limit; без координат — ошибка',
    () async {
      expect(actions().broadcastPosition(), throwsStateError);
      await (db.update(db.nodes)..where((n) => n.num.equals(0xAA))).write(
        const NodesCompanion(latitude: Value(59.9), longitude: Value(30.3)),
      );
      await actions().broadcastPosition();
      final p = sent.single;
      expect(p.to, 0xffffffff);
      expect(p.wantAck, isFalse);
      expect(p.hopLimit, 0);
      expect(p.decoded.portnum, PortNum.POSITION_APP);
      expect(Position.fromBuffer(p.decoded.payload).latitudeI, 599000000);
    },
  );

  test('разбор трассировки: SNR ×4, неизвестный — null', () {
    final rd = RouteDiscovery(
      route: [0x10],
      snrTowards: [20, -128],
      routeBack: [0x11],
      snrBack: [8, 4],
    );
    final r = TracerouteResult.parse(
      TracerouteRecord(
        id: 1,
        requestId: 5,
        targetNum: 0x42,
        time: DateTime(2026),
        data: rd.writeToBuffer(),
        answered: true,
      ),
      0xAA,
    );
    expect(r.towards.map((h) => h.num), [0xAA, 0x10, 0x42]);
    expect(r.towards.map((h) => h.snr), [null, 5.0, null]);
    expect(r.back.map((h) => h.num), [0x42, 0x11, 0xAA]);
    expect(r.back.last.snr, 1.0);
  });

  test('обмен позицией: своя позиция ноде с запросом ответа', () async {
    await (db.update(db.nodes)..where((n) => n.num.equals(0xAA))).write(
      const NodesCompanion(latitude: Value(59.9), longitude: Value(30.3)),
    );
    await actions().exchangePosition(0x42);
    final p = sent.single;
    expect(p.to, 0x42);
    expect(p.decoded.portnum, PortNum.POSITION_APP);
    expect(p.decoded.wantResponse, isTrue);
    expect(p.hopLimit, 0);
    expect(Position.fromBuffer(p.decoded.payload).latitudeI, 599000000);
  });

  test(
    'обмен позицией без своих координат — ошибка, ничего не отправлено',
    () async {
      expect(() => actions().exchangePosition(0x42), throwsStateError);
      expect(sent, isEmpty);
    },
  );

  test('QR контакта: ссылка официального формата, без ключа — нет', () async {
    expect(contactUrl(await node(0x42), own: false), isNull);
    await (db.update(db.nodes)..where((n) => n.num.equals(0x42))).write(
      NodesCompanion(publicKey: Value(Uint8List(32))),
    );
    final url = contactUrl(await node(0x42), own: false)!;
    expect(url, startsWith('https://meshtastic.org/v/#'));
    var b64 = url.split('#').last;
    expect(b64, isNot(contains('=')));
    b64 += '=' * ((4 - b64.length % 4) % 4);
    final c = SharedContact.fromBuffer(base64Url.decode(b64));
    expect(c.nodeNum, 0x42);
    expect(c.user.longName, 'n66');
    expect(c.user.publicKey, hasLength(32));
  });
}
