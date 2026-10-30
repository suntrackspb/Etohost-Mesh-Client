import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/node_db_store.dart';
import 'package:meshex/data/node_dbs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  storeTests();
  group('useNodeDb', () {
    test('новая база — первой', () {
      expect(useNodeDb([1, 2], 3).list, [3, 1, 2]);
    });

    test('уже известная поднимается наверх без дублей', () {
      final r = useNodeDb([1, 2, 3], 3);
      expect(r.list, [3, 1, 2]);
      expect(r.evicted, isEmpty);
    });

    test('сверх лимита удаляются самые давние', () {
      final r = useNodeDb([1, 2, 3, 4, 5], 6);
      expect(r.list, [6, 1, 2, 3, 4]);
      expect(r.evicted, [5]);
    });
  });

  test('parseNodeDbs терпит мусор', () {
    expect(parseNodeDbs(null), isEmpty);
    expect(parseNodeDbs('oops'), isEmpty);
    expect(parseNodeDbs('[3, "x", 1]'), [3, 1]);
  });

  group('migrateToNodeDbs', () {
    late Directory dir;
    late AppDatabase app;
    String fileFor(int n) => '${dir.path}/node_$n.sqlite';

    setUp(() {
      dir = Directory.systemTemp.createTempSync('node_dbs');
      app = AppDatabase(NativeDatabase(File('${dir.path}/app.sqlite')));
    });
    tearDown(() async {
      await app.close();
      dir.deleteSync(recursive: true);
    });

    Future<void> seed() async {
      await app.setSetting(AppSettingKeys.theme, 'dark');
      await app.touchRecent('ble', 'AA', 'SUNs', 42);
      await app.into(app.myNode).insert(MyNodeCompanion.insert(myNodeNum: 42));
      await app
          .into(app.messages)
          .insert(
            MessagesCompanion.insert(
              packetId: 1,
              fromNum: 7,
              toNum: 0xffffffff,
              channelKey: const Value('longfast'),
              body: 'привет',
              rxTime: DateTime(2026, 10, 22),
            ),
          );
    }

    test('данные уходят в базу своей ноды, настройки остаются', () async {
      await seed();
      expect(await migrateToNodeDbs(app, fileFor), 42);

      expect(await app.select(app.messages).get(), isEmpty);
      expect(await app.select(app.myNode).get(), isEmpty);
      expect(await app.getSetting(AppSettingKeys.theme), 'dark');
      expect(await app.watchRecent().first, hasLength(1));
      expect(await app.getSetting(AppSettingKeys.nodeDbs), '[42]');

      // Копия открывается как обычная база и не пересоздаётся миграцией.
      final node = AppDatabase(NativeDatabase(File(fileFor(42))), app);
      final msgs = await node.select(node.messages).get();
      expect(msgs.single.body, 'привет');
      // Настройки — из общей базы.
      expect(await node.getSetting(AppSettingKeys.theme), 'dark');
      await node.close();
    });

    test('повторный запуск — без копирования, активна первая', () async {
      await seed();
      await migrateToNodeDbs(app, fileFor);
      await app.setSetting(AppSettingKeys.nodeDbs, '[5, 42]');
      expect(await migrateToNodeDbs(app, fileFor), 5);
    });

    test('пустая база — без файла, база без ноды', () async {
      expect(await migrateToNodeDbs(app, fileFor), noNodeDb);
      expect(File(fileFor(noNodeDb)).existsSync(), isFalse);
    });
  });
}

void storeTests() {
  group('insertImportedDb', () {
    test('сразу после активной', () {
      expect(insertImportedDb([1, 2], 9).list, [1, 9, 2]);
    });
    test('сверх лимита — самые давние', () {
      final r = insertImportedDb([1, 2, 3, 4, 5], 9);
      expect(r.list, [1, 9, 2, 3, 4]);
      expect(r.evicted, [5]);
    });
  });

  group('NodeDbStore', () {
    late Directory dir;
    late AppDatabase app;
    late NodeDbStore store;
    late AppDatabase active;

    Future<void> makeNode(int num, String name) async {
      final db = AppDatabase(NativeDatabase(File(store.path(num))), app);
      await db.into(db.myNode).insert(MyNodeCompanion.insert(myNodeNum: num));
      await db
          .into(db.nodes)
          .insert(
            NodesCompanion.insert(num: Value(num), longName: Value(name)),
          );
      await db.close();
    }

    setUp(() async {
      dir = Directory.systemTemp.createTempSync('node_store');
      app = AppDatabase(NativeDatabase(File('${dir.path}/app.sqlite')));
      store = NodeDbStore(dir.path, app);
      await makeNode(1, 'Первая');
      await makeNode(2, 'Вторая');
      await app.setSetting(AppSettingKeys.nodeDbs, '[1, 2]');
      active = AppDatabase(NativeDatabase(File(store.path(1))), app);
    });
    tearDown(() async {
      await active.close();
      await app.close();
      dir.deleteSync(recursive: true);
    });

    test('перенос: свой номер меняется, без дублей', () async {
      MessagesCompanion msg(int id, int from, int to) =>
          MessagesCompanion.insert(
            packetId: id,
            fromNum: from,
            toNum: to,
            body: 'm$id',
            rxTime: DateTime(2026),
          );
      final old = AppDatabase(NativeDatabase(File(store.path(2))), app);
      await old.batch((b) {
        b.insertAll(old.messages, [msg(10, 2, 7), msg(11, 7, 2)]);
        b.insert(
          old.nodes,
          NodesCompanion.insert(
            num: const Value(7),
            longName: const Value('Ч'),
          ),
        );
      });
      await old.close();
      await active.into(active.messages).insert(msg(10, 1, 7));
      expect(await store.transfer(2, 1, active), 1);
      final rows = await active.select(active.messages).get();
      expect(rows.map((m) => (m.packetId, m.fromNum, m.toNum)).toSet(), {
        (10, 1, 7),
        (11, 7, 1),
      });
      final nodes = await active.select(active.nodes).get();
      expect(nodes.map((n) => n.num).toSet(), {1, 7});
      expect(await store.transfer(2, 1, active), 0);
      expect(() => store.transfer(1, 1, active), throwsStateError);
    });

    test('ключ своей ноды: совпадает, разный, неизвестен', () async {
      expect(await store.sameOwnKey(2, 1, active), isNull);
      Future<void> key(AppDatabase db, int num, List<int> k) =>
          (db.update(db.nodes)..where((n) => n.num.equals(num))).write(
            NodesCompanion(publicKey: Value(Uint8List.fromList(k))),
          );
      final old = AppDatabase(NativeDatabase(File(store.path(2))), app);
      await key(old, 2, [1, 2]);
      await old.close();
      await key(active, 1, [1, 2]);
      expect(await store.sameOwnKey(2, 1, active), isTrue);
      await key(active, 1, [3]);
      expect(await store.sameOwnKey(2, 1, active), isFalse);
    });

    test('список с именами и отметкой открытой', () async {
      final l = await store.list(1, active);
      expect(l.map((d) => (d.num, d.active)), [(1, true), (2, false)]);
      expect(l.last.name, 'Вторая (!00000002)');
    });

    test('удалить можно только неоткрытую', () async {
      expect(() => store.delete(1, 1), throwsStateError);
      await store.delete(2, 1);
      expect(File(store.path(2)).existsSync(), isFalse);
      expect(await app.getSetting(AppSettingKeys.nodeDbs), '[1]');
    });

    test('экспорт → удаление → импорт возвращает базу', () async {
      final bytes = await store.export(2, 1, active);
      await store.delete(2, 1);
      final num = await store.import(
        bytes,
        active: 1,
        replace: (_) async => fail('заменять нечего'),
      );
      expect(num, 2);
      expect((await store.list(1, active)).last.name, 'Вторая (!00000002)');
    });

    test('импорт: имеющуюся — только с согласия', () async {
      final bytes = await store.export(2, 1, active);
      expect(
        await store.import(bytes, active: 1, replace: (_) async => false),
        isNull,
      );
    });

    test('база приложения: экспорт → импорт на месте', () async {
      await app.setSetting(AppSettingKeys.theme, 'dark');
      await app.touchRecent('ble', 'AA', 'SUNs', 1);
      final bytes = await store.exportApp();
      await app.setSetting(AppSettingKeys.theme, 'light');
      await app.forgetRecent('ble', 'AA');
      await app.setSetting(AppSettingKeys.nodeDbs, '[1]');

      await store.importApp(bytes);
      expect(await app.getSetting(AppSettingKeys.theme), 'dark');
      expect(await app.watchRecent().first, hasLength(1));
      // Список баз — свой, про файлы этого устройства.
      expect(await app.getSetting(AppSettingKeys.nodeDbs), '[1]');
    });

    test('база ноды как база приложения — отказ', () async {
      final bytes = await store.export(2, 1, active);
      expect(() => store.importApp(bytes), throwsFormatException);
    });

    test('импорт открытой и мусора — отказ', () async {
      final own = await store.export(1, 1, active);
      expect(
        () => store.import(own, active: 1, replace: (_) async => true),
        throwsFormatException,
      );
      expect(
        () =>
            store.import(Uint8List(200), active: 1, replace: (_) async => true),
        throwsFormatException,
      );
    });
  });

  test('лимит баз из настройки; 0 — без ограничения', () {
    expect(parseNodeDbLimit(null), nodeDbLimit);
    expect(parseNodeDbLimit('x'), nodeDbLimit);
    expect(parseNodeDbLimit('-1'), nodeDbLimit);
    expect(parseNodeDbLimit('0'), 0);
    expect(parseNodeDbLimit('12'), 12);
    final many = List.generate(30, (i) => i + 1);
    expect(useNodeDb(many, 99, limit: 0).evicted, isEmpty);
    expect(useNodeDb(many, 99, limit: 0).list.length, 31);
    final r = useNodeDb(many, 99, limit: 3);
    expect(r.list, [99, 1, 2]);
    expect(r.evicted.length, 28);
  });
}
