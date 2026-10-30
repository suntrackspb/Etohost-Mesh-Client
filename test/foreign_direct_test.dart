import 'package:drift/native.dart';
import 'package:meshex/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('чужая личка из зеркала не попадает в «Личные»', () async {
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
            rxTime: DateTime(2026, 1, 1, 0, id),
          ),
        );
    const me = 0x75ffff00;
    await msg(0x0407d2ec, 0x123ab8e8); // R-TKK4-F4FD: обе ноды чужие
    await msg(5, me);
    await msg(me, 6);

    // Своя нода ещё неизвестна — показываем всё.
    expect(await db.watchAllDirect().first, hasLength(3));

    await db.into(db.myNode).insert(MyNodeCompanion.insert(myNodeNum: me));
    final all = await db.watchAllDirect().first;
    expect(all.map((m) => m.body), ['m3', 'm2']);
    expect(await db.watchDirectMessages(0x0407d2ec).first, isEmpty);
    expect(await db.watchDirectUnread(0x0407d2ec, null).first, 0);
    expect(await db.watchDirectMessages(5).first, hasLength(1));
    await db.close();
  });
}
