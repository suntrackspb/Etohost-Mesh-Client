import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> add(int id, int minute, {int emoji = 0, bool radio = true}) => db
      .into(db.messages)
      .insert(
        MessagesCompanion.insert(
          packetId: id,
          fromNum: 0xaa,
          toNum: broadcastNum,
          channelKey: const Value('mediumfast'),
          body: 'm$id',
          rxTime: DateTime(2026, 10, 22, 4, minute),
          emoji: Value(emoji),
          heardOnRadio: Value(radio),
          heardOnMirror: Value(!radio),
        ),
      );

  test('поиск без реакций и зеркала (если выключено), счёт новее', () async {
    await add(1, 0);
    await add(2, 1, emoji: 1);
    await add(3, 2, radio: false);
    await add(4, 3);

    final radioOnly = await db.feedForSearch(channelKey: 'mediumfast');
    expect(radioOnly.map((m) => m.packetId), [4, 1]);
    final withMirror = await db.feedForSearch(
      channelKey: 'mediumfast',
      includeMirror: true,
    );
    expect(withMirror.map((m) => m.packetId), [4, 3, 1]);

    expect(
      await db.feedCountSince(
        DateTime(2026, 10, 22, 4, 1),
        channelKey: 'mediumfast',
        includeMirror: true,
      ),
      3,
    );
  });
}
