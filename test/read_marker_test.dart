import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/read_marker.dart';
import 'package:flutter_test/flutter_test.dart';

final t0 = DateTime(2026, 10, 22, 12);
DateTime at(int minute) => t0.add(Duration(minutes: minute));

Message m(int minute, {bool out = false}) => Message(
  id: minute,
  packetId: minute,
  fromNum: out ? 1 : 2,
  toNum: broadcastNum,
  channel: 0,
  channelKey: 'mediumfast',
  body: 'x',
  rxTime: at(minute),
  isOutgoing: out,
  emoji: 0,
  viaMqtt: false,
  pkiEncrypted: false,
  xeddsaSigned: false,
  ackState: AckState.values.first,
  heardOnRadio: true,
  heardOnMirror: false,
  relayCount: 0,
  isBot: false,
);

void main() {
  // Лента от свежих: 5, 4 (своё), 3, 2, 1.
  final feed = [m(5), m(4, out: true), m(3), m(2), m(1)];

  group('firstUnreadIndex', () {
    test('самое старое входящее новее отметки', () {
      expect(firstUnreadIndex(feed, at(2)), 2);
    });
    test('своё сообщение границей не считается', () {
      expect(firstUnreadIndex(feed, at(3)), 0);
    });
    test('всё прочитано или чат не открывали — нет границы', () {
      expect(firstUnreadIndex(feed, at(5)), isNull);
      expect(firstUnreadIndex(feed, null), isNull);
    });
    test('все загруженные новые — самое старое из них', () {
      expect(firstUnreadIndex(feed, at(0)), 4);
    });
  });

  group('readUpTo', () {
    test('видно самое свежее — прочитано всё', () {
      expect(readUpTo(feed, 0), at(5));
    });
    test('сверху своё — берём входящее под ним', () {
      expect(readUpTo(feed, 1), at(3));
    });
    test('за пределами ленты — ничего', () {
      expect(readUpTo(feed, 9), isNull);
    });
  });

  test('advanceMark не двигает назад', () {
    expect(advanceMark(at(3), at(2)), at(3));
    expect(advanceMark(at(3), at(4)), at(4));
    expect(advanceMark(null, at(1)), at(1));
    expect(advanceMark(at(3), null), at(3));
  });

  test('feedLimitForUnread: с запасом, не больше предела, не уменьшает', () {
    expect(feedLimitForUnread(100, 10), 100);
    expect(feedLimitForUnread(100, 120), 170);
    expect(feedLimitForUnread(100, 5000), maxUnreadLoad);
    expect(feedLimitForUnread(800, 5000), 800);
  });
}
