import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meshex/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> add(
    int id, {
    bool out = false,
    bool radio = false,
    bool mirror = false,
    required DateTime at,
  }) => db
      .into(db.messages)
      .insert(
        MessagesCompanion.insert(
          packetId: id,
          fromNum: out ? 1 : 2,
          toNum: 0xffffffff,
          channelKey: const Value('k'),
          body: '$id',
          rxTime: at,
          isOutgoing: Value(out),
          heardOnRadio: Value(radio),
          heardOnMirror: Value(mirror),
        ),
      );

  final t0 = DateTime(2026, 1, 1, 12);

  test('без зеркала видно эфир и своё исходящее', () async {
    await add(1, radio: true, at: t0);
    await add(2, out: true, at: t0);
    await add(3, mirror: true, at: t0);
    final ids = (await db.watchChannelMessages('k').first).map(
      (m) => m.packetId,
    );
    expect(ids, unorderedEquals([1, 2]));
    expect(await db.watchMessageChannelKeys().first, ['k']);
    final all = await db.watchChannelMessages('k', includeMirror: true).first;
    expect(all, hasLength(3));
  });

  test('непрочитанные: только входящие новее отметки', () async {
    await add(1, radio: true, at: t0);
    await add(2, radio: true, at: t0.add(const Duration(minutes: 5)));
    await add(3, out: true, at: t0.add(const Duration(minutes: 6)));
    expect(await db.watchUnreadCount('k', null).first, 2);
    expect(
      await db.watchUnreadCount('k', t0.add(const Duration(minutes: 1))).first,
      1,
    );
  });

  test('лимит ленты берёт самые свежие', () async {
    for (var i = 0; i < 5; i++) {
      await add(i, radio: true, at: t0.add(Duration(minutes: i)));
    }
    final page = await db.watchChannelMessages('k', limit: 2).first;
    expect(page.map((m) => m.packetId), [4, 3]);
  });
}
