import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/settings/device_actions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('messages: oneof set even for false / defaults', () {
    final keep = DeviceActions.message(DeviceAction.nodeDbReset);
    final wipe = DeviceActions.message(
      DeviceAction.nodeDbReset,
      preserveFavorites: false,
    );
    final w = AdminMessage.fromBuffer(wipe.writeToBuffer());
    expect(w.hasNodedbReset(), isTrue);
    expect(w.nodedbReset, isFalse);
    expect(AdminMessage.fromBuffer(keep.writeToBuffer()).nodedbReset, isTrue);
    expect(DeviceActions.message(DeviceAction.reboot).rebootSeconds, 5);
    expect(DeviceActions.message(DeviceAction.shutdown).shutdownSeconds, 5);
    expect(
      DeviceActions.message(
        DeviceAction.factoryResetDevice,
      ).hasFactoryResetDevice(),
      isTrue,
    );
  });

  test('roles that always keep favorites', () {
    expect(
      DeviceActions.keepsFavorites(Config_DeviceConfig_Role.ROUTER.value),
      isTrue,
    );
    expect(
      DeviceActions.keepsFavorites(Config_DeviceConfig_Role.CLIENT.value),
      isFalse,
    );
  });

  group('resetRadioNodes', () {
    late AppDatabase db;
    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      Future<void> add(
        int n, {
        bool radio = true,
        bool mirror = false,
        bool fav = false,
      }) => db
          .into(db.nodes)
          .insert(
            NodesCompanion.insert(
              num: Value(n),
              onRadio: Value(radio),
              onMirror: Value(mirror),
              isFavorite: Value(fav),
            ),
          );
      await add(1); // своя
      await add(2);
      await add(3, fav: true);
      await add(4, mirror: true);
      await add(5, radio: false, mirror: true, fav: true);
    });
    tearDown(() => db.close());

    Future<Map<int, Node>> rows() async => {
      for (final n in await db.select(db.nodes).get()) n.num: n,
    };

    test('keep favorites', () async {
      await db.resetRadioNodes(1, keepFavorites: true);
      final r = await rows();
      expect(r.keys.toSet(), {1, 3, 4, 5});
      expect(r[3]!.isFavorite, isTrue);
      expect(r[4]!.onRadio, isFalse);
      expect(r[1]!.onRadio, isTrue);
    });

    test('wipe favorites, keep mirror nodes', () async {
      await db.resetRadioNodes(1, keepFavorites: false);
      final r = await rows();
      expect(r.keys.toSet(), {1, 4, 5});
      expect(r[5]!.isFavorite, isFalse);
    });
  });
}
