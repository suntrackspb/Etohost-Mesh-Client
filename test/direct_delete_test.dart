import 'package:drift/native.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('удаление лички — только переписка с этим собеседником', () async {
    final db = AppDatabase(NativeDatabase.memory());
    var id = 0;
    Future<void> msg(int from, int to) => db
        .into(db.messages)
        .insert(
          MessagesCompanion.insert(
            packetId: ++id,
            fromNum: from,
            toNum: to,
            body: 'm$id',
            rxTime: DateTime(2026),
          ),
        );
    await msg(5, 1); // от собеседника
    await msg(1, 5); // ему
    await msg(6, 1); // другой собеседник
    await msg(5, 0xffffffff); // его сообщение в канале
    expect(await db.deleteDirectChat(5), 2);
    final left = await db.select(db.messages).get();
    expect(left.map((m) => m.body), ['m3', 'm4']);
    await db.close();
  });
}
