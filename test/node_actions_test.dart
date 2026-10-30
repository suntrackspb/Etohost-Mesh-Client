import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/core/radio/send_queue.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/node_actions.dart';
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
          .insert(
            NodesCompanion.insert(
              num: Value(n),
              longName: Value('n$n'),
              macaddr: Value(Uint8List.fromList([1, 2, 3, 4, 5, n])),
            ),
          );
    }
  });
  tearDown(() => db.close());

  Future<Node> node(int n) =>
      (db.select(db.nodes)..where((r) => r.num.equals(n))).getSingle();

  test('cooldowns isolate nodes/actions and keep pending commands locked', () {
    fakeAsync((clock) {
      final response = Completer<DeliveryResult>();
      var sends = 0;
      final a = NodeActions(
        db,
        (_) {
          sends++;
          return response.future;
        },
        () => 0xAA,
        () => nextId++,
      );
      final first = a.setFavorite(0x42, true);
      expect(a.blocked(0x42, NodeAction.favorite), isTrue);
      expect(a.blocked(0x43, NodeAction.favorite), isFalse);
      expect(a.blocked(0x42, NodeAction.ignored), isFalse);
      expect(a.setFavorite(0x42, false), throwsStateError);
      clock.flushMicrotasks();
      expect(sends, 1);
      clock.elapse(const Duration(seconds: 4));
      expect(a.blocked(0x42, NodeAction.favorite), isTrue);
      response.complete(const DeliveryResult(DeliveryStatus.timeout));
      first.then((_) {});
      clock.flushMicrotasks();
      expect(a.blocked(0x42, NodeAction.favorite), isFalse);
      a.dispose();
    });
  });

  test('failed commands retain the 3 and 30 second cooldowns', () {
    fakeAsync((clock) {
      final a = NodeActions(
        db,
        (_) async => const DeliveryResult(DeliveryStatus.timeout),
        () => null,
        () => nextId++,
      );
      expect(a.setFavorite(0x42, true), throwsStateError);
      expect(a.traceroute(0x42), throwsStateError);
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 2));
      expect(a.blocked(0x42, NodeAction.favorite), isTrue);
      clock.elapse(const Duration(seconds: 1));
      expect(a.blocked(0x42, NodeAction.favorite), isFalse);
      expect(a.blocked(0x42, NodeAction.traceroute), isTrue);
      clock.elapse(const Duration(seconds: 26));
      expect(a.blocked(0x42, NodeAction.traceroute), isTrue);
      clock.elapse(const Duration(seconds: 1));
      expect(a.blocked(0x42, NodeAction.traceroute), isFalse);
      a.dispose();
    });
  });

  test('mirror contact is imported once per connection and key', () async {
    await (db.update(db.nodes)..where((n) => n.num.equals(0x42))).write(
      NodesCompanion(
        onMirror: const Value(true),
        publicKey: Value(Uint8List.fromList(List.filled(32, 7))),
      ),
    );
    final a = actions();
    addTearDown(a.dispose);
    await a.prepareDirectContact(0x42);
    final contact = AdminMessage.fromBuffer(
      sent.single.decoded.payload,
    ).addContact;
    expect(contact.nodeNum, 0x42);
    expect(contact.user.publicKey, List.filled(32, 7));
    expect(sent.single.to, 0xAA);
    expect((await node(0x42)).onRadio, isFalse);
    await a.prepareDirectContact(0x42);
    expect(sent, hasLength(1));
    await (db.update(db.nodes)..where((n) => n.num.equals(0x42))).write(
      NodesCompanion(publicKey: Value(Uint8List.fromList(List.filled(32, 8)))),
    );
    await a.prepareDirectContact(0x42);
    expect(sent, hasLength(2));
  });

  test('failed contact import remains retryable', () async {
    await (db.update(db.nodes)..where((n) => n.num.equals(0x42))).write(
      NodesCompanion(
        onMirror: const Value(true),
        publicKey: Value(Uint8List.fromList(List.filled(32, 7))),
      ),
    );
    final a = actions();
    addTearDown(a.dispose);
    status = DeliveryStatus.timeout;
    await expectLater(a.prepareDirectContact(0x42), throwsStateError);
    status = DeliveryStatus.acked;
    await a.prepareDirectContact(0x42);
    expect(sent, hasLength(2));
  });

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

  test('своя NodeInfo — MAC от радио, имя из БД', () async {
    final a = NodeActions(
      db,
      (p) async {
        sent.add(p);
        return DeliveryResult(status);
      },
      () => 0xAA,
      () => nextId++,
      () => User(
        longName: 'старое',
        macaddr: [1, 2, 3, 4, 5, 6],
        hwModel: HardwareModel.HELTEC_V4,
      ),
    );
    await a.broadcastNodeInfo();
    final u = User.fromBuffer(sent.single.decoded.payload);
    expect(u.macaddr, [1, 2, 3, 4, 5, 6]);
    expect(u.hwModel, HardwareModel.HELTEC_V4);
    expect(u.longName, 'n170');
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

  test('своя NodeInfo без MAC не уходит — нода сменит номер', () async {
    await (db.update(db.nodes)..where((n) => n.num.equals(0xAA))).write(
      const NodesCompanion(macaddr: Value(null)),
    );
    await expectLater(actions().broadcastNodeInfo(), throwsStateError);
    await expectLater(actions().exchangeNodeInfo(0x42), throwsStateError);
    expect(sent, isEmpty);
  });

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

  SharedContact contact({List<int>? key, int num = 0x77}) => SharedContact(
    nodeNum: num,
    user: User(
      id: '!чужой',
      longName: 'Гость',
      shortName: 'GST',
      publicKey: key ?? List.filled(32, 7),
      macaddr: [1, 2, 3, 4, 5, 6],
    ),
  );

  test('ссылка контакта: наша же ссылка разбирается обратно', () async {
    await (db.update(db.nodes)..where((n) => n.num.equals(0x42))).write(
      NodesCompanion(publicKey: Value(Uint8List(32))),
    );
    final url = contactUrl(await node(0x42), own: false)!;
    expect(parseContactUrl(url)!.nodeNum, 0x42);
    expect(parseContactUrl(' ${url.substring(8)} ')!.user.longName, 'n66');
    expect(parseContactUrl('https://meshtastic.org/e/#abc'), isNull);
    expect(parseContactUrl('https://meshtastic.org/v/#!!!'), isNull);
    expect(parseContactUrl('https://meshtastic.org/v/#AAAA'), isNull);
  });

  test('проверка импорта: без ключа нельзя, смена ключа видна', () async {
    expect(contactImportCheck(contact(key: []), null).blocked, isTrue);
    expect(contactImportCheck(contact(), null), (
      blocked: false,
      known: false,
      keyChanged: false,
    ));
    await (db.update(db.nodes)..where((n) => n.num.equals(0x42))).write(
      NodesCompanion(publicKey: Value(Uint8List(32))),
    );
    final c = contactImportCheck(contact(num: 0x42), await node(0x42));
    expect(c.known, isTrue);
    expect(c.keyChanged, isTrue);
  });

  test('импорт: add_contact своей ноде без hop_limit, нода в БД', () async {
    expect(await actions().importContact(contact()), isTrue);
    final p = sent.single;
    expect(p.to, 0xAA);
    expect(p.hopLimit, 0);
    expect(AdminMessage.fromBuffer(p.decoded.payload).addContact.nodeNum, 0x77);
    final n = await node(0x77);
    expect(n.longName, 'Гость');
    expect(n.userId, '!00000077');
    expect(n.publicKey, hasLength(32));
    expect(n.macaddr, [1, 2, 3, 4, 5, 6]);
  });

  test('импорт без ключа — ошибка, ничего не отправлено', () async {
    await expectLater(
      actions().importContact(contact(key: [])),
      throwsStateError,
    );
    expect(sent, isEmpty);
  });
}
