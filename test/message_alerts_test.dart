import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/notify/alert_watcher.dart';
import 'package:etohost_mesh/data/notify/message_alerts.dart';
import 'package:flutter_test/flutter_test.dart';

const me = 0x1111;
const peer = 0x2222;
final now = DateTime(2026, 10, 21, 12);

Message msg({
  int id = 1,
  int packetId = 100,
  int from = peer,
  int to = broadcastNum,
  String body = 'привет',
  int? replyId,
  int emoji = 0,
  bool outgoing = false,
  String channelKey = 'longfast',
  int? channel = 0,
  DateTime? rxTime,
}) => Message(
  id: id,
  packetId: packetId,
  fromNum: from,
  toNum: to,
  channel: channel,
  channelKey: channelKey,
  body: body,
  rxTime: rxTime ?? now,
  isOutgoing: outgoing,
  replyId: replyId,
  emoji: emoji,
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
  group('classify', () {
    const c = AlertContext(me: me, myShortName: 'DU');
    AlertKind? k(Message m, [AlertContext ctx = c]) =>
        MessageAlerts.classify(m, ctx);

    test('direct message', () {
      expect(k(msg(to: me)), AlertKind.direct);
    });

    test('own and ignored are silent', () {
      expect(k(msg(to: me, outgoing: true)), isNull);
      expect(k(msg(to: me, from: me)), isNull);
      expect(
        k(msg(to: me), const AlertContext(me: me, senderIgnored: true)),
        isNull,
      );
    });

    test('reaction and reply only to my message', () {
      const mine = AlertContext(me: me, targetIsMine: true);
      expect(
        k(msg(emoji: 1, replyId: 5, body: '👍'), mine),
        AlertKind.reaction,
      );
      expect(k(msg(emoji: 1, replyId: 5, body: '👍')), isNull);
      expect(k(msg(replyId: 5), mine), AlertKind.reply);
      expect(k(msg(replyId: 5)), isNull);
      // Реакция в личке — тоже реакция, не «личное сообщение».
      expect(k(msg(to: me, emoji: 1, replyId: 5), mine), AlertKind.reaction);
    });

    test('mention by short name as a word', () {
      expect(k(msg(body: 'du, ты тут?')), AlertKind.mention);
      expect(k(msg(body: 'привет @DU!')), AlertKind.mention);
      expect(k(msg(body: 'duplex')), isNull);
      expect(k(msg(body: 'x_du')), isNull);
      expect(
        k(msg(body: 'du'), const AlertContext(me: me)), // имени нет
        isNull,
      );
    });

    test('muted channel is silent, direct is not', () {
      const muted = AlertContext(me: me, myShortName: 'DU', channelMuted: true);
      expect(k(msg(body: 'DU'), muted), isNull);
      expect(k(msg(to: me), muted), AlertKind.direct);
    });

    test('mentions handles cyrillic and emoji names', () {
      expect(MessageAlerts.mentions('Привет, ДЕН', 'ден'), isTrue);
      expect(MessageAlerts.mentions('Денис', 'ден'), isFalse);
      expect(MessageAlerts.mentions('эй 🐱 тут', '🐱'), isTrue);
    });

    test('content', () {
      final r = MessageAlerts.content(
        AlertKind.reaction,
        msg(body: '👍'),
        sender: 'Bob',
        channel: 'LongFast',
        target: 'очень длинный текст моего сообщения, который надо обрезать',
      );
      expect(r.title, 'Bob · #LongFast');
      expect(r.body, startsWith('👍 к «очень длинный'));
      expect(r.body, endsWith('…»'));
    });
  });

  group('AlertWatcher', () {
    late AppDatabase db;
    late List<MessageAlert> alerts;
    late AlertWatcher w;
    var settings = const AlertSettings();
    var visible = <String>{};

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      alerts = [];
      settings = const AlertSettings();
      visible = {};
      await db
          .into(db.nodes)
          .insert(
            NodesCompanion.insert(
              num: const Value(me),
              shortName: const Value('DU'),
            ),
          );
      await db
          .into(db.nodes)
          .insert(
            NodesCompanion.insert(
              num: const Value(peer),
              longName: const Value('Bob'),
            ),
          );
      // Старое сообщение — до запуска, не уведомляем.
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion.insert(
              packetId: 1,
              fromNum: peer,
              toNum: me,
              body: 'старое',
              rxTime: now,
            ),
          );
      w = AlertWatcher(
        db,
        me: () => me,
        settings: () => settings,
        isChatVisible: visible.contains,
        onAlert: alerts.add,
        now: () => now,
      );
      await w.start();
    });

    tearDown(() async {
      w.dispose();
      await db.close();
    });

    Future<void> insert(MessagesCompanion m) async {
      await db.into(db.messages).insert(m);
      await pumpEventQueue();
    }

    test('new direct message, once; existing ignored', () async {
      await insert(
        MessagesCompanion.insert(
          packetId: 2,
          fromNum: peer,
          toNum: me,
          body: 'привет',
          rxTime: now,
        ),
      );
      expect(alerts, hasLength(1));
      expect(alerts.single.kind, AlertKind.direct);
      expect(alerts.single.title, 'Bob');
      expect(alerts.single.chat, 'dm:$peer');
      // Зеркало прислало то же — конфликт, новой строки нет.
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion.insert(
              packetId: 2,
              fromNum: peer,
              toNum: me,
              body: 'привет',
              rxTime: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      await pumpEventQueue();
      expect(alerts, hasLength(1));
    });

    test('reply to my message in a channel', () async {
      await insert(
        MessagesCompanion.insert(
          packetId: 50,
          fromNum: me,
          toNum: broadcastNum,
          body: 'мой вопрос',
          rxTime: now,
          isOutgoing: const Value(true),
          channelKey: const Value('longfast'),
        ),
      );
      await insert(
        MessagesCompanion.insert(
          packetId: 51,
          fromNum: peer,
          toNum: broadcastNum,
          body: 'ответ',
          rxTime: now,
          replyId: const Value(50),
          channelKey: const Value('longfast'),
        ),
      );
      expect(alerts.single.kind, AlertKind.reply);
      expect(alerts.single.chat, 'longfast');
    });

    test('old, disabled and visible are skipped', () async {
      await insert(
        MessagesCompanion.insert(
          packetId: 3,
          fromNum: peer,
          toNum: me,
          body: 'история',
          rxTime: now.subtract(const Duration(hours: 1)),
        ),
      );
      settings = const AlertSettings(direct: false);
      await insert(
        MessagesCompanion.insert(
          packetId: 4,
          fromNum: peer,
          toNum: me,
          body: 'выкл',
          rxTime: now,
        ),
      );
      settings = const AlertSettings();
      visible.add('dm:$peer');
      await insert(
        MessagesCompanion.insert(
          packetId: 5,
          fromNum: peer,
          toNum: me,
          body: 'открыт',
          rxTime: now,
        ),
      );
      expect(alerts, isEmpty);
    });

    test('muted channel', () async {
      await db
          .into(db.channels)
          .insert(
            ChannelsCompanion.insert(
              index: const Value(0),
              name: const Value('LongFast'),
              role: const Value(1),
              settings: Value(
                ChannelSettings(
                  name: 'LongFast',
                  moduleSettings: ModuleSettings(isMuted: true),
                ).writeToBuffer(),
              ),
            ),
          );
      await insert(
        MessagesCompanion.insert(
          packetId: 6,
          fromNum: peer,
          toNum: broadcastNum,
          body: 'DU!',
          rxTime: now,
          channel: const Value(0),
          channelKey: const Value('longfast'),
        ),
      );
      expect(alerts, isEmpty);
    });
  });
}
