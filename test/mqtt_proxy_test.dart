import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/mqtt/mqtt_link.dart';
import 'package:meshex/mqtt/mqtt_proxy.dart';
import 'package:meshex/mqtt/mqtt_proxy_config.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

MeshChannel _ch(int i, String name, {int role = 2, bool downlink = true}) =>
    MeshChannel(
      index: i,
      name: name,
      role: role,
      settings: ChannelSettings(
        name: name,
        downlinkEnabled: downlink,
      ).writeToBuffer(),
    );

ModuleConfig_MQTTConfig _mqtt({
  String address = 'broker.example.com',
  bool tls = false,
  bool json = false,
  String root = '',
}) => ModuleConfig_MQTTConfig(
  enabled: true,
  proxyToClientEnabled: true,
  address: address,
  username: 'u',
  password: 'p',
  tlsEnabled: tls,
  jsonEnabled: json,
  root: root,
);

Uint8List _env({
  int from = 0x1234,
  String gateway = '!0000aaaa',
  String channel = 'LongFast',
  bool payload = true,
}) => ServiceEnvelope(
  channelId: channel,
  gatewayId: gateway,
  packet: MeshPacket(
    from: from,
    to: broadcastNum,
    hopLimit: 3,
    encrypted: payload ? [1, 2, 3] : null,
  ),
).writeToBuffer();

class _FakeLink implements MqttLink {
  final messagesCtl = StreamController<MqttInbound>.broadcast(sync: true);
  final lostCtl = StreamController<void>.broadcast(sync: true);
  final published = <(String, List<int>, bool)>[];
  List<String> subscribed = [];
  int connects = 0;
  int disconnects = 0;
  Object? failWith;

  @override
  Stream<MqttInbound> get messages => messagesCtl.stream;
  @override
  Stream<void> get lost => lostCtl.stream;

  @override
  Future<void> connect(MqttProxyConfig cfg, String clientId) async {
    connects++;
    final f = failWith;
    if (f != null) throw f;
  }

  @override
  void disconnect() => disconnects++;

  @override
  void publish(String topic, List<int> payload, {required bool retained}) =>
      published.add((topic, payload, retained));

  @override
  void subscribe(List<String> topics) => subscribed = topics;

  void inbound(String topic, List<int> payload) => messagesCtl.add((
    topic: topic,
    payload: Uint8List.fromList(payload),
    retained: false,
  ));
}

void main() {
  group('MqttProxyConfig', () {
    test('host:port and TLS default ports', () {
      var c = MqttProxyConfig.from(_mqtt(address: 'broker.example.com:1999'));
      expect((c.host, c.port, c.tls), ('broker.example.com', 1999, false));
      c = MqttProxyConfig.from(_mqtt(tls: true));
      expect((c.port, c.tls), (8883, true));
      c = MqttProxyConfig.from(_mqtt());
      expect(c.port, 1883);
    });

    test('public server forces TLS; empty address uses its credentials', () {
      var c = MqttProxyConfig.from(_mqtt(address: 'mqtt.meshtastic.org'));
      expect((c.port, c.tls), (8883, true));
      expect(c.username, 'u');
      c = MqttProxyConfig.from(_mqtt(address: ''));
      expect(c.host, 'mqtt.meshtastic.org');
      expect((c.username, c.password), ('meshdev', 'large4cats'));
    });

    test('scheme addresses', () {
      var c = MqttProxyConfig.from(_mqtt(address: 'ssl://b.example:9000'));
      expect(
        (c.host, c.port, c.tls, c.webSocket),
        ('b.example', 9000, true, false),
      );
      c = MqttProxyConfig.from(_mqtt(address: 'wss://b.example/mqtt'));
      expect(
        (c.host, c.port, c.webSocket),
        ('wss://b.example/mqtt', 443, true),
      );
    });

    test(
      'topics: downlink channels, preset for unnamed primary, json, PKI',
      () {
        final c = MqttProxyConfig.from(
          _mqtt(json: true, root: 'msh/RU'),
          lora: Config_LoRaConfig(
            usePreset: true,
            modemPreset: Config_LoRaConfig_ModemPreset.MEDIUM_FAST,
          ),
          channels: [
            _ch(0, '', role: 1),
            _ch(1, 'Off', downlink: false),
            _ch(2, 'Gone', role: 0),
            _ch(3, 'Town'),
          ],
        );
        expect(c.topics, [
          'msh/RU/2/e/MediumFast/+',
          'msh/RU/2/json/MediumFast/+',
          'msh/RU/2/e/Town/+',
          'msh/RU/2/json/Town/+',
          'msh/RU/2/e/PKI/+',
        ]);
      },
    );

    test('wanted needs MQTT and client proxy', () {
      expect(MqttProxyConfig.wanted(_mqtt()), isTrue);
      expect(
        MqttProxyConfig.wanted(_mqtt()..proxyToClientEnabled = false),
        isFalse,
      );
      expect(MqttProxyConfig.wanted(_mqtt()..enabled = false), isFalse);
    });
  });

  group('MqttDownlinkFilter', () {
    const me = 0x1234;
    const t = 'msh/2/e/LongFast/!0000aaaa';
    MqttDownlink d(List<int> p, [String topic = t]) =>
        MqttDownlinkFilter.decide(topic, p, me);

    test('ordinary packet and garbage are forwarded', () {
      expect(d(_env(from: 0x99)), MqttDownlink.forward);
      expect(d([0xff, 0xff, 0xff]), MqttDownlink.forward);
    });

    test('status topics are dropped', () {
      expect(d([1], 'msh/2/stat/!0000aaaa'), MqttDownlink.status);
    });

    test('self traffic', () {
      // Своё через свой шлюз — неявный ACK, пропускаем.
      expect(d(_env(from: me, gateway: '!00001234')), MqttDownlink.forward);
      expect(d(_env(from: me)), MqttDownlink.forgedSender);
      expect(
        d(_env(from: 0x99, gateway: '!00001234')),
        MqttDownlink.ownUplinkEcho,
      );
    });

    test('payload-less packet is dropped, except PKI', () {
      expect(d(_env(from: 0x99, payload: false)), MqttDownlink.noPayload);
      expect(
        d(_env(from: 0x99, payload: false, channel: 'PKI')),
        MqttDownlink.forward,
      );
    });

    test('json self traffic', () {
      List<int> j(int from, String sender) =>
          utf8.encode(jsonEncode({'from': from, 'sender': sender}));
      const jt = 'msh/2/json/LongFast/!0000aaaa';
      expect(d(j(me, '!0000aaaa'), jt), MqttDownlink.forgedSender);
      expect(d(j(0x99, '!0000aaaa'), jt), MqttDownlink.forward);
    });

    test('hop_limit is left as is', () {
      expect(ServiceEnvelope.fromBuffer(_env(from: 0x99)).packet.hopLimit, 3);
    });
  });

  group('MqttProxy', () {
    late _FakeLink link;
    late List<ToRadio> sent;
    late Completer<void> radio;
    final cfg = MqttProxyConfig.from(_mqtt());

    MqttProxy make() {
      link = _FakeLink();
      sent = [];
      radio = Completer<void>()..complete();
      return MqttProxy(
        link: link,
        sendToRadio: (m) {
          sent.add(m);
          return radio.future;
        },
      );
    }

    test('connects, subscribes, relays both ways', () async {
      final p = make()..start(cfg, myNodeNum: 0x1234);
      await pumpEventQueue();
      expect(p.state, MqttProxyState.connected);
      expect(link.subscribed, cfg.topics);

      p.publish(
        MqttClientProxyMessage(topic: 'msh/x', data: [7], retained: true),
      );
      final pub = link.published.single;
      expect((pub.$1, pub.$3), ('msh/x', true));
      expect(pub.$2, [7]);

      final raw = _env(from: 0x99);
      link.inbound('msh/2/e/LongFast/!0000aaaa', raw);
      final m = sent.single.mqttClientProxyMessage;
      expect(m.topic, 'msh/2/e/LongFast/!0000aaaa');
      expect(m.data, raw); // без изменений, hop_limit не трогаем
      p.dispose();
    });

    test('one write to the node at a time; filtered are counted', () async {
      final p = make()..start(cfg, myNodeNum: 0x1234);
      await pumpEventQueue();
      radio = Completer<void>();
      link.inbound('a', _env(from: 0x99));
      link.inbound('b', _env(from: 0x99));
      link.inbound('c', _env(from: 0x99, payload: false));
      expect(sent, hasLength(1));
      expect((p.forwarded, p.dropped), (1, 2));
      radio.complete();
      await pumpEventQueue();
      link.inbound('d', _env(from: 0x99));
      expect(sent, hasLength(2));
      p.dispose();
    });

    test('credential rejection stops, network error retries', () {
      fakeAsync((fa) {
        final p = make();
        link.failWith = const MqttRejected('bad', credentials: true);
        p.start(cfg);
        fa.flushMicrotasks();
        expect(p.state, MqttProxyState.failed);
        fa.elapse(const Duration(minutes: 1));
        expect(link.connects, 1);

        link.failWith = Exception('net');
        p.start(cfg); // после failed тот же конфиг — новая попытка
        fa.flushMicrotasks();
        expect(p.state, MqttProxyState.reconnecting);
        fa.elapse(const Duration(seconds: 1));
        expect(link.connects, 3);
        link.failWith = null;
        fa.elapse(const Duration(seconds: 2));
        expect(p.state, MqttProxyState.connected);
        p.dispose();
      });
    });

    test('lost connection reconnects; stop goes inactive', () {
      fakeAsync((fa) {
        final p = make()..start(cfg);
        fa.flushMicrotasks();
        link.lostCtl.add(null);
        expect(p.state, MqttProxyState.reconnecting);
        fa.elapse(const Duration(seconds: 1));
        expect(p.state, MqttProxyState.connected);
        p.stop();
        expect(p.state, MqttProxyState.inactive);
        p.publish(MqttClientProxyMessage(topic: 't', data: [1]));
        expect(link.published, isEmpty);
        p.dispose();
      });
    });

    test('same config does not reconnect', () async {
      final p = make()..start(cfg);
      await pumpEventQueue();
      p.start(MqttProxyConfig.from(_mqtt()));
      await pumpEventQueue();
      expect(link.connects, 1);
      p.dispose();
    });
  });
}
