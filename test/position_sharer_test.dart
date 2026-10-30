import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/core/radio/send_queue.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/position_sharer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late List<MeshPacket> sent;
  late PositionSharer s;
  final t0 = DateTime(2026, 10, 20, 12);

  Fix fix(double lat, int min) => (
    lat: lat,
    lon: 30.3,
    altitude: 12.4,
    time: t0.add(Duration(minutes: min)),
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.nodes)
        .insert(NodesCompanion.insert(num: const Value(0xAA)));
    sent = [];
    s = PositionSharer(
      db,
      (p) async {
        sent.add(p);
        return const DeliveryResult(DeliveryStatus.acked);
      },
      () => 0xAA,
      () => 1,
    );
  });
  tearDown(() => db.close());

  test(
    'позиция уходит своей ноде, без hop_limit, пишется в свою ноду',
    () async {
      expect(await s.onFix(fix(59.9, 0)), isTrue);
      final p = sent.single;
      expect(p.to, 0xAA);
      expect(p.hopLimit, 0);
      expect(p.decoded.portnum, PortNum.POSITION_APP);
      final pos = Position.fromBuffer(p.decoded.payload);
      expect(pos.latitudeI, 599000000);
      expect(pos.altitude, 12);
      final me = await db.select(db.nodes).getSingle();
      expect(me.latitude, 59.9);
    },
  );

  test('не чаще интервала; без сдвига — раз в 4 интервала', () async {
    await s.onFix(fix(59.9, 0));
    expect(await s.onFix(fix(59.95, 5)), isFalse); // рано
    expect(await s.onFix(fix(59.9, 20)), isFalse); // не сдвинулись
    expect(await s.onFix(fix(59.91, 20)), isTrue); // ~1 км
    expect(await s.onFix(fix(59.91, 81)), isTrue); // 4 интервала
    expect(sent, hasLength(3));
  });

  test('без соединения ничего не шлём', () async {
    final off = PositionSharer(
      db,
      (p) async {
        sent.add(p);
        return const DeliveryResult(DeliveryStatus.acked);
      },
      () => null,
      () => 1,
    );
    expect(await off.onFix(fix(59.9, 0)), isFalse);
    expect(sent, isEmpty);
  });
}
