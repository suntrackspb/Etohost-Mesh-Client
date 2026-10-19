import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etohost_mesh/core/proto/channel_names.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/mirror_ingest.dart';
import 'package:etohost_mesh/data/packet_router.dart';
import 'package:etohost_mesh/mirror/mirror_config.dart';
import 'package:etohost_mesh/mirror/mirror_models.dart';

void main() {
  group('адрес зеркала', () {
    test('нормализация', () {
      expect(normalizeMirrorUrl(''), isNull);
      expect(
        normalizeMirrorUrl('m.example.org').toString(),
        'https://m.example.org',
      );
      expect(
        normalizeMirrorUrl(' https://m.example.org/some/path?x=1 ').toString(),
        'https://m.example.org',
      );
      expect(
        normalizeMirrorUrl('http://10.0.0.5:8000/').toString(),
        'http://10.0.0.5:8000',
      );
      expect(normalizeMirrorUrl('ftp://x'), isNull);
      expect(normalizeMirrorUrl('https://'), isNull);
    });

    test('WS-адрес выводится из основного', () {
      expect(
        const MirrorConfig(
          enabled: true,
          address: 'm.example.org',
        ).webSocketUrl.toString(),
        'wss://m.example.org/ws?history=1',
      );
      expect(
        const MirrorConfig(
          enabled: true,
          address: 'http://10.0.0.5:8000',
        ).webSocketUrl.toString(),
        'ws://10.0.0.5:8000/ws?history=1',
      );
    });

    test('по умолчанию выключено; без адреса не активно', () {
      expect(MirrorConfig.off.active, isFalse);
      expect(const MirrorConfig(enabled: true).active, isFalse);
      expect(const MirrorConfig(address: 'm.example.org').active, isFalse);
    });
  });

  group('разбор', () {
    test('даты бэкенда в обоих форматах', () {
      final a = parseMirrorDate('2026-10-09 19:20:32.127335+00:00')!.toUtc();
      final b = parseMirrorDate('2026-10-09T19:20:32.127335Z')!.toUtc();
      expect(a, b);
      expect(a.millisecond, 127);
      expect(parseMirrorDate('2026-10-09T19:20:32')!.toUtc().hour, 19);
    });

    test('init: записи без числового id пропускаются', () {
      final e = MirrorEvent.parse(
        jsonDecode('''
        {"type":"init","messages":[
          {"id":"nc-1","type":"name_change"},
          {"id":5,"from_id":"!0000abcd","packet_id":77,"text":"hi","channel":"LongFast",
           "relays":[{"node_id":"!1"},{"node_id":"!2"}]}
        ]}''')
            as Map<String, dynamic>,
      );
      final m = (e as MirrorInit).messages.single;
      expect(m.packetId, 77);
      expect(m.relays, hasLength(2));
      expect(nodeNumFromId(m.fromId), 0xabcd);
    });

    test('публичный ключ: hex и base64', () {
      final hex = List.filled(32, 'ab').join();
      expect(
        MirrorNode(nodeId: '!1', publicKey: hex).publicKeyBytes,
        hasLength(32),
      );
      final b64 = base64Encode(List.filled(32, 7));
      expect(
        MirrorNode(nodeId: '!1', publicKey: b64).publicKeyBytes,
        everyElement(7),
      );
      expect(
        const MirrorNode(nodeId: '!1', publicKey: 'xyz').publicKeyBytes,
        isNull,
      );
    });

    test('имена пресетов как в прошивке', () {
      String n(Config_LoRaConfig_ModemPreset p) =>
          modemPresetName(Config_LoRaConfig(usePreset: true, modemPreset: p));
      expect(n(Config_LoRaConfig_ModemPreset.LONG_FAST), 'LongFast');
      expect(n(Config_LoRaConfig_ModemPreset.LONG_MODERATE), 'LongMod');
      expect(n(Config_LoRaConfig_ModemPreset.VERY_LONG_SLOW), 'VLongSlow');
      expect(modemPresetName(Config_LoRaConfig(usePreset: false)), 'Custom');
    });
  });

  group('слияние с эфиром', () {
    late AppDatabase db;
    late PacketRouter radio;
    late MirrorIngest mirror;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      radio = PacketRouter(db);
      mirror = MirrorIngest(db);
      await radio.handle(
        FromRadio(
          channel: Channel(
            index: 0,
            role: Channel_Role.PRIMARY,
            settings: ChannelSettings(),
          ),
        ),
      );
    });
    tearDown(() => db.close());

    FromRadio text(int id, String body) => FromRadio(
      packet: MeshPacket(
        from: 0xabcd,
        to: broadcastNum,
        id: id,
        rxSnr: 6.5,
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: utf8.encode(body),
        ),
      ),
    );

    MirrorMessage mm(
      int mirrorId,
      int? packetId, {
      String channel = 'LongFast',
    }) => MirrorMessage(
      id: mirrorId,
      packetId: packetId,
      fromId: '!0000abcd',
      text: 'hi',
      channel: channel,
      snr: -3,
      receivedAt: DateTime(2020),
      relays: const [MirrorRelay(), MirrorRelay()],
    );

    test('эфир, затем зеркало — одна запись, данные эфира сохранены', () async {
      await radio.handle(text(77, 'hi'));
      await mirror.messages([mm(5, 77)]);
      final m =
          (await db.watchChannelMessages('longfast', includeMirror: true).first)
              .single;
      expect(m.heardOnRadio && m.heardOnMirror, isTrue);
      expect(m.rxSnr, 6.5);
      expect(m.rxTime.year, isNot(2020)); // время приёма своей нодой
      expect(m.relayCount, 2);
      expect(m.mirrorId, 5);
    });

    test('зеркало, затем эфир — одна запись с обоими источниками', () async {
      await mirror.messages([mm(5, 77)]);
      await radio.handle(text(77, 'hi'));
      final m =
          (await db.watchChannelMessages('longfast', includeMirror: true).first)
              .single;
      expect(m.heardOnRadio && m.heardOnMirror, isTrue);
      expect(m.rxSnr, 6.5);
      expect(m.channel, 0);
    });

    test('без packet_id не склеивается и не конфликтует', () async {
      await mirror.messages([mm(5, null), mm(6, null)]);
      final list = await db
          .watchChannelMessages('longfast', includeMirror: true)
          .first;
      expect(list, hasLength(2));
    });

    test('зеркало выключено — его сообщения, каналы и ноды скрыты', () async {
      await mirror.messages([mm(5, 1, channel: 'Services')]);
      await mirror.nodes([
        const MirrorNode(nodeId: '!00000042', longName: 'M'),
      ]);
      expect(await db.watchChannelMessages('services').first, isEmpty);
      expect(await db.watchMessageChannelKeys().first, isEmpty);
      expect(await db.watchMessageChannelKeys(includeMirror: true).first, [
        'services',
      ]);
      expect(await db.watchNodes().first, isEmpty);
      expect(await db.watchNodes(includeMirror: true).first, isNotEmpty);
    });

    test('relay_update увеличивает счётчик ретрансляций', () async {
      await mirror.messages([mm(5, 77)]);
      await mirror.relay(5, const MirrorRelay());
      final m =
          (await db.watchChannelMessages('longfast', includeMirror: true).first)
              .single;
      expect(m.relayCount, 3);
    });

    test('ноды: зеркало не затирает ключ и свежее время своей ноды', () async {
      final mine = List.filled(32, 1);
      final old = DateTime.now().subtract(const Duration(days: 1));
      await radio.handle(
        FromRadio(
          nodeInfo: NodeInfo(
            num: 0x42,
            user: User(longName: 'Radio', publicKey: mine),
            lastHeard: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ),
        ),
      );
      await mirror.nodes([
        MirrorNode(
          nodeId: '!00000042',
          longName: 'Mirror',
          lastSeenAt: old,
          publicKey: List.filled(32, '02').join(),
          lastLat: 59.9,
          lastLon: 30.3,
        ),
      ]);
      final n = (await db.watchNodes().first).single;
      expect(n.publicKey, mine);
      expect(n.lastHeard!.isAfter(old), isTrue);
      expect(n.longName, 'Mirror');
      expect(n.latitude, 59.9);
      expect(n.onRadio && n.onMirror, isTrue);
    });

    test('ноды: ключ с зеркала, если своего нет', () async {
      await mirror.nodes([
        MirrorNode(
          nodeId: '!00000042',
          publicKey: List.filled(32, '02').join(),
        ),
      ]);
      final n = (await db.watchNodes(includeMirror: true).first).single;
      expect(n.publicKey, List.filled(32, 2));
    });
  });
}
