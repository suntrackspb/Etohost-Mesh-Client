import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/mirror_ingest.dart';
import 'package:meshex/mirror/mirror_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final now = DateTime(2026, 10, 25);
  DateTime ago(int d) => now.subtract(Duration(days: d));

  Future<void> node(
    int num,
    DateTime? heard, {
    bool radio = false,
    bool mirror = true,
    bool fav = false,
    bool ign = false,
    bool key = false,
  }) => db
      .into(db.nodes)
      .insert(
        NodesCompanion.insert(
          num: Value(num),
          lastHeard: Value(heard),
          onRadio: Value(radio),
          onMirror: Value(mirror),
          isFavorite: Value(fav),
          isIgnored: Value(ign),
          publicKey: Value(key ? Uint8List(32) : null),
        ),
      );

  Future<List<int>> nums() async =>
      (await db.select(db.nodes).get()).map((n) => n.num).toList()..sort();

  test('выключено — ничего не удаляет', () async {
    await node(1, ago(100));
    expect(await db.purgeStaleNodes(now: now), 0);
    expect(await nums(), [1]);
  });

  test('удаляет старые, кроме защищённых', () async {
    await db.setSetting(AppSettingKeys.purgeStaleNodeDays, '3');
    await db
        .into(db.myNode)
        .insert(MyNodeCompanion.insert(id: const Value(0), myNodeNum: 9));
    await node(1, ago(10)); // старая из зеркала — удалить
    await node(2, ago(1)); // свежая
    await node(3, ago(10), radio: true, mirror: false); // в базе радио
    await node(4, ago(10), fav: true);
    await node(5, ago(10), ign: true);
    await node(6, ago(5), key: true); // с ключом — минимум 7 дней
    await node(7, ago(10), key: true); // с ключом, старше 7 — удалить
    await node(8, null); // без «последний раз»
    await node(9, ago(10)); // своя
    await node(10, ago(10));
    await db.setSetting(AppSettingKeys.nodeNote(10), 'заметка');
    expect(await db.purgeStaleNodes(now: now), 2);
    expect(await nums(), [2, 3, 4, 5, 6, 8, 9, 10]);
  });

  test('удалённая вручную: зеркало не возвращает, пока не услышат', () async {
    MirrorNode mn(DateTime seen) =>
        MirrorNode(nodeId: '!15e58115', lastSeenAt: seen);
    const num = 0x15e58115;
    final ingest = MirrorIngest(db);
    await ingest.nodes([mn(ago(3))]);
    await db.forgetNode(num, now: ago(1));
    await ingest.nodes([mn(ago(3))]);
    expect(await nums(), isEmpty);
    expect((await db.forgottenNodes()).keys, [num]);
    await ingest.nodes([mn(now)]);
    expect(await nums(), [num]);
    expect(await db.forgottenNodes(), isEmpty);
  });
}
