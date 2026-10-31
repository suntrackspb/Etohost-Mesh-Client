import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/node_actions.dart';
import 'package:meshex/data/radio_stats.dart';
import 'package:meshex/features/home_widgets/widget_snapshot.dart';

Node node(int num, {bool ignored = false}) => Node(
  num: num,
  userId: '',
  longName: 'Node $num',
  shortName: 'N$num',
  hwModel: 0,
  role: 0,
  isUnmessagable: false,
  hasXeddsaSigned: false,
  mirrorCorrected: false,
  viaMqtt: false,
  isFavorite: false,
  isIgnored: ignored,
  onRadio: true,
  onMirror: false,
  publicKey: Uint8List.fromList([1, 2, 3]),
  batteryLevel: 101,
);
Message message(int to, {bool outgoing = false, String body = 'hello'}) =>
    Message(
      id: 1,
      packetId: 99,
      fromNum: 1,
      toNum: to,
      channelKey: 'a/b тест',
      body: body,
      rxTime: DateTime(2026),
      isOutgoing: outgoing,
      emoji: 0,
      viaMqtt: false,
      pkiEncrypted: false,
      xeddsaSigned: false,
      ackState: AckState.none,
      heardOnRadio: true,
      heardOnMirror: false,
      relayCount: 0,
      isBot: false,
    );
void main() {
  Map<String, Object?> snapshot({
    List<Node>? nodes,
    List<Message> messages = const [],
    TracerouteResult? trace,
  }) => widgetSnapshot(
    nodes: nodes ?? [node(1), node(2, ignored: true)],
    messages: messages,
    points: [],
    connected: true,
    me: 1,
    stats: const RadioStats(onRadio: 3, online: 2, channels: 1, battery: 101),
    unread: 4,
    language: 'ru',
    now: DateTime.utc(2026, 10, 31),
    trace: trace,
  );
  test(
    'bounded contract excludes ignored nodes, keys and raw packet payloads',
    () {
      final data = snapshot(nodes: [for (var i = 0; i < 1200; i++) node(i)]);
      expect((data['nodes'] as List).length, 1000);
      final encoded = encodeWidgetSnapshot(snapshot());
      expect(encoded, isNot(contains('publicKey')));
      expect(encoded, isNot(contains('packetId')));
      expect((jsonDecode(encoded)['nodes'] as List).map((n) => n['num']), [1]);
      expect(
        data['battery'],
        101,
      ); // external power stays distinct from percent
      expect(
        data['updated'],
        DateTime.utc(2026, 10, 31).millisecondsSinceEpoch,
      );
    },
  );
  test(
    'message links preserve channel identifiers and direct conversation peers',
    () {
      final data = snapshot(
        messages: [message(0xffffffff), message(7, outgoing: true), message(1)],
      );
      final list = data['messages'] as List;
      expect(list[0]['path'], '/chat/a%2Fb%20%D1%82%D0%B5%D1%81%D1%82');
      expect(list[1]['path'], '/chat/dm%3A7');
      expect(list[2]['path'], '/chat/dm%3A1');
    },
  );
  test('recent messages are bounded and traces link to their exact record', () {
    final data = snapshot(
      messages: List.generate(8, (_) => message(1, body: 'x' * 300)),
      trace: TracerouteResult(
        id: 42,
        target: 3,
        time: DateTime(2026),
        towards: [(num: 1, snr: null), (num: 3, snr: 2.0)],
        back: [],
      ),
    );
    final list = data['messages'] as List;
    expect(list.length, 5);
    expect((list.first['body'] as String).length, 181);
    expect((data['trace'] as Map)['path'], '/traceroute/42');
    expect((data['trace'] as Map)['summary'], 'N1 → !00000003');
  });
}
