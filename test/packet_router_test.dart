import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/jammer_zones.dart';
import 'package:etohost_mesh/data/packet_router.dart';

void main() {
  late AppDatabase db;
  late PacketRouter router;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    router = PacketRouter(db);
  });
  tearDown(() => db.close());

  test('NodeInfo сохраняется в nodes', () async {
    await router.handle(
      FromRadio(
        nodeInfo: NodeInfo(
          num: 0x1234,
          user: User(longName: 'Test node', shortName: 'TN'),
        ),
      ),
    );
    final nodes = await db.watchNodes().first;
    expect(nodes.single.longName, 'Test node');
  });

  test('NodeInfo без user не затирает известное имя', () async {
    await db
        .into(db.nodes)
        .insert(
          NodesCompanion.insert(
            num: const Value(0x1234),
            longName: const Value('enot 7afd'),
            shortName: const Value('7afd'),
          ),
        );
    await router.handle(
      FromRadio(nodeInfo: NodeInfo(num: 0x1234, lastHeard: 1700000000)),
    );
    final n = (await db.watchNodes().first).single;
    expect(n.longName, 'enot 7afd');
    expect(n.shortName, '7afd');
    expect(n.lastHeard, isNotNull);
  });

  test(
    'текстовое сообщение пишется один раз (дубликаты игнорируются)',
    () async {
      final f = FromRadio(
        packet: MeshPacket(
          from: 0x1234,
          to: broadcastNum,
          id: 42,
          channel: 0,
          decoded: Data(
            portnum: PortNum.TEXT_MESSAGE_APP,
            payload: utf8.encode('привет'),
          ),
        ),
      );
      // Безымянный основной канал — имя пресета (LongFast по умолчанию).
      await router.handle(
        FromRadio(
          channel: Channel(
            index: 0,
            role: Channel_Role.PRIMARY,
            settings: ChannelSettings(),
          ),
        ),
      );
      await router.handle(f);
      await router.handle(f);
      final msgs = await db.watchChannelMessages('longfast').first;
      expect(msgs.single.body, 'привет');
      expect(msgs.single.heardOnRadio, isTrue);
    },
  );

  FromRadio pkt(
    int from,
    PortNum port,
    List<int> payload, {
    int requestId = 0,
  }) => FromRadio(
    packet: MeshPacket(
      from: from,
      to: broadcastNum,
      id: 7,
      decoded: Data(portnum: port, payload: payload, requestId: requestId),
    ),
  );

  test('позиция: в историю и в карточку ноды', () async {
    await router.handle(
      pkt(
        5,
        PortNum.POSITION_APP,
        Position(latitudeI: 599000000, longitudeI: 303000000).writeToBuffer(),
      ),
    );
    final node = (await db.watchNodes().first).single;
    expect(node.latitude, closeTo(59.9, 1e-6));
    expect(await db.select(db.positions).get(), hasLength(1));
  });

  group('запасная точка на случай спуфинга', () {
    setUp(
      () => db.setSetting(
        AppSettingKeys.jammerZones,
        const JammerZones(
          zones: [(latMin: 60, latMax: 60.2, lonMin: 31.2, lonMax: 31.5)],
        ).encode(),
      ),
    );
    Future<Node> send(int lat, int lon, {int time = 0}) async {
      await router.handle(
        pkt(
          5,
          PortNum.POSITION_APP,
          Position(latitudeI: lat, longitudeI: lon, time: time).writeToBuffer(),
        ),
      );
      return (await db.watchNodes().first).single;
    }

    test('точка вне зон запоминается, в зоне — нет', () async {
      var n = await send(600047616, 302776320);
      expect(n.radioGoodLat, closeTo(60.0047616, 1e-6));
      final at = n.radioGoodAt;
      n = await send(601096192, 313786368);
      expect(n.latitude, closeTo(60.1096192, 1e-6)); // показываем как есть
      expect(n.radioGoodLat, closeTo(60.0047616, 1e-6));
      expect(n.radioGoodAt, at);
    });

    test('старая точка (NodeDB) не перетирает свежую', () async {
      await send(600047616, 302776320);
      await router.handle(
        FromRadio(
          nodeInfo: NodeInfo(
            num: 5,
            position: Position(
              latitudeI: 599000000,
              longitudeI: 303000000,
              time: 1700000000,
            ),
          ),
        ),
      );
      final n = (await db.watchNodes().first).single;
      expect(n.radioGoodLat, closeTo(60.0047616, 1e-6));
    });

    test('время из будущего не блокирует обновления', () async {
      final future = DateTime.now().add(const Duration(days: 30));
      var n = await send(
        599000000,
        303000000,
        time: future.millisecondsSinceEpoch ~/ 1000,
      );
      expect(n.radioGoodAt!.isAfter(DateTime.now()), isFalse);
      n = await send(
        600047616,
        302776320,
        time: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
      );
      expect(n.radioGoodLat, closeTo(60.0047616, 1e-6));
    });
  });

  test('телеметрия устройства обновляет батарею и пишется в журнал', () async {
    await router.handle(
      pkt(
        5,
        PortNum.TELEMETRY_APP,
        Telemetry(
          deviceMetrics: DeviceMetrics(
            batteryLevel: 77,
            channelUtilization: 12.5,
          ),
        ).writeToBuffer(),
      ),
    );
    final node = (await db.watchNodes().first).single;
    expect(node.batteryLevel, 77);
    expect(node.channelUtilization, 12.5);
    expect(
      (await db.select(db.telemetryLog).getSingle()).kind,
      'deviceMetrics',
    );
  });

  test(
    'Routing отмечает исходящее сообщение доставленным или с ошибкой',
    () async {
      for (final id in [100, 101]) {
        await db
            .into(db.messages)
            .insert(
              MessagesCompanion.insert(
                packetId: id,
                fromNum: 1,
                toNum: broadcastNum,
                body: 'x',
                rxTime: DateTime.now(),
                isOutgoing: const Value(true),
                ackState: const Value(AckState.pending),
              ),
            );
      }
      await router.handle(
        pkt(9, PortNum.ROUTING_APP, Routing().writeToBuffer(), requestId: 100),
      );
      await router.handle(
        pkt(
          9,
          PortNum.ROUTING_APP,
          Routing(errorReason: Routing_Error.MAX_RETRANSMIT).writeToBuffer(),
          requestId: 101,
        ),
      );
      final rows = await (db.select(
        db.messages,
      )..orderBy([(m) => OrderingTerm(expression: m.packetId)])).get();
      expect(rows[0].ackState, AckState.acked);
      expect(rows[1].ackState, AckState.failed);
      expect(rows[1].ackError, Routing_Error.MAX_RETRANSMIT.value);
    },
  );

  test('конфиг ноды сохраняется по имени раздела', () async {
    await router.handle(
      FromRadio(config: Config(lora: Config_LoRaConfig(hopLimit: 5))),
    );
    final row = await db.select(db.configBlobs).getSingle();
    expect(row.key, 'config.lora');
    expect(Config.fromBuffer(row.data).lora.hopLimit, 5);
  });

  test('NeighborInfo заменяет соседей ноды', () async {
    NeighborInfo info(List<int> ns) => NeighborInfo(
      nodeId: 5,
      neighbors: [for (final n in ns) Neighbor(nodeId: n, snr: 3)],
    );
    await router.handle(
      pkt(5, PortNum.NEIGHBORINFO_APP, info([1, 2]).writeToBuffer()),
    );
    await router.handle(
      pkt(5, PortNum.NEIGHBORINFO_APP, info([3]).writeToBuffer()),
    );
    final rows = await db.select(db.neighbors).get();
    expect(rows.map((r) => r.neighborNum), [3]);
  });

  test('NodeInfo из эфира не стирает позицию и избранное', () async {
    await router.handle(
      FromRadio(
        nodeInfo: NodeInfo(
          num: 5,
          isFavorite: true,
          user: User(longName: 'A', publicKey: List.filled(32, 1)),
          position: Position(latitudeI: 599000000, longitudeI: 303000000),
        ),
      ),
    );
    await router.handle(
      pkt(5, PortNum.NODEINFO_APP, User(longName: 'B').writeToBuffer()),
    );
    final n = (await db.watchNodes().first).single;
    expect(n.longName, 'B');
    expect(n.isFavorite, isTrue);
    expect(n.latitude, closeTo(59.9, 1e-6));
    expect(n.publicKey, hasLength(32)); // пустой ключ в пакете не стирает
  });

  test('другой ключ ноды не заменяет записанный, а отмечается', () async {
    final k1 = List.filled(32, 1), k2 = List.filled(32, 2);
    await router.handle(
      FromRadio(
        nodeInfo: NodeInfo(
          num: 5,
          user: User(longName: 'A', publicKey: k1),
        ),
      ),
    );
    await router.handle(
      pkt(
        5,
        PortNum.NODEINFO_APP,
        User(longName: 'A', publicKey: k2).writeToBuffer(),
      ),
    );
    final n = (await db.watchNodes().first).single;
    expect(n.publicKey, k1);
    expect(n.newPublicKey, k2);
  });

  test('ключ своей ноды заменяется без предупреждения', () async {
    await router.handle(FromRadio(myInfo: MyNodeInfo(myNodeNum: 7)));
    for (final k in [List.filled(32, 1), List.filled(32, 2)]) {
      await router.handle(
        FromRadio(
          nodeInfo: NodeInfo(
            num: 7,
            user: User(longName: 'me', publicKey: k),
          ),
        ),
      );
    }
    final n = (await db.watchNodes().first).single;
    expect(n.publicKey, List.filled(32, 2));
    expect(n.newPublicKey, equals(null));
  });

  test('прошивка своей ноды и первое обнаружение', () async {
    await router.handle(FromRadio(myInfo: MyNodeInfo(myNodeNum: 7)));
    await router.handle(
      FromRadio(
        nodeInfo: NodeInfo(
          num: 7,
          lastHeard: 1700000000,
          user: User(longName: 'me'),
        ),
      ),
    );
    await router.handle(
      FromRadio(metadata: DeviceMetadata(firmwareVersion: '2.7.15.567b8ea')),
    );
    await router.handle(
      FromRadio(
        nodeInfo: NodeInfo(
          num: 7,
          lastHeard: 1800000000,
          user: User(longName: 'me'),
        ),
      ),
    );
    final n = (await db.watchNodes().first).single;
    expect(n.firmwareVersion, '2.7.15.567b8ea');
    expect(n.firstHeard!.millisecondsSinceEpoch, 1700000000 * 1000);
  });

  test('входящее личное: без ключа канала, с флагом PKI', () async {
    await router.handle(
      FromRadio(
        packet: MeshPacket(
          from: 5,
          to: 1,
          id: 9,
          pkiEncrypted: true,
          decoded: Data(
            portnum: PortNum.TEXT_MESSAGE_APP,
            payload: utf8.encode('лично'),
          ),
        ),
      ),
    );
    final m = (await db.watchDirectMessages(5).first).single;
    expect(m.pkiEncrypted, isTrue);
    expect(m.channelKey, '');
    expect(await db.watchDirectUnread(5, null).first, 1);
  });

  test('подпись XEdDSA: флаг на сообщении и на ноде', () async {
    await router.handle(
      FromRadio(
        nodeInfo: NodeInfo(num: 7, user: User(longName: 'S')),
      ),
    );
    await router.handle(
      FromRadio(
        packet: MeshPacket(
          from: 7,
          to: broadcastNum,
          id: 9,
          xeddsaSigned: true,
          decoded: Data(
            portnum: PortNum.TEXT_MESSAGE_APP,
            payload: utf8.encode('hi'),
          ),
        ),
      ),
    );
    final m = await db.select(db.messages).getSingle();
    expect(m.xeddsaSigned, isTrue);
    final n = await db.select(db.nodes).getSingle();
    expect(n.hasXeddsaSigned, isTrue);
  });

  test('MyNode — одна строка, дубли чистятся, прошивка сохраняется', () async {
    await db.into(db.myNode).insert(MyNodeCompanion.insert(myNodeNum: 1));
    await db.into(db.myNode).insert(MyNodeCompanion.insert(myNodeNum: 1));
    for (var i = 0; i < 2; i++) {
      await router.handle(FromRadio(myInfo: MyNodeInfo(myNodeNum: 0x1234)));
      await router.handle(
        FromRadio(metadata: DeviceMetadata(firmwareVersion: '2.8.1')),
      );
    }
    final r = await db.select(db.myNode).getSingle();
    expect(r.id, 0);
    expect(r.myNodeNum, 0x1234);
    expect(r.firmwareVersion, '2.8.1');
  });
}
