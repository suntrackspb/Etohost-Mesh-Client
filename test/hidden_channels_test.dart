import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/mirror_ingest.dart';
import 'package:meshex/mirror/mirror_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  MirrorMessage mm(int id, String channel) => MirrorMessage(
    id: id,
    fromId: '!0000aaaa',
    packetId: id,
    text: 'msg $id',
    channel: channel,
    receivedAt: DateTime(2026, 10, 22),
  );

  Future<List<String>> bodies() async =>
      (await db.select(db.messages).get()).map((m) => m.body).toList()..sort();

  test(
    'скрытие: удаляет только сообщения из зеркала, не подтягивает снова',
    () async {
      await MirrorIngest(db).messages([mm(1, 'spam'), mm(2, 'MediumFast')]);
      // Услышанное в эфире в том же канале — остаётся.
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion.insert(
              packetId: 50,
              fromNum: 0xbbbb,
              toNum: broadcastNum,
              channelKey: const Value('spam'),
              body: 'radio',
              rxTime: DateTime(2026, 10, 22),
              heardOnRadio: const Value(true),
            ),
          );

      await db.hideChannel('spam');
      expect(await db.hiddenChannels(), {'spam'});
      expect(await bodies(), ['msg 2', 'radio']);

      await MirrorIngest(db).messages([mm(3, 'Spam')]);
      expect(await bodies(), ['msg 2', 'radio']);

      await db.unhideChannel('spam');
      await MirrorIngest(db).messages([mm(3, 'Spam')]);
      expect(await bodies(), ['msg 2', 'msg 3', 'radio']);
    },
  );

  test('битая настройка — пустой список', () {
    expect(parseHiddenChannels(null), isEmpty);
    expect(parseHiddenChannels('{oops'), isEmpty);
    expect(parseHiddenChannels('["a", 1]'), {'a'});
  });
}
