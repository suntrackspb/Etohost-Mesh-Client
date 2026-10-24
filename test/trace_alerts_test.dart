import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/notify/trace_alerts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 24, 12);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.nodes)
        .insert(
          NodesCompanion.insert(
            num: const Value(0x42),
            longName: const Value('Hides'),
          ),
        );
  });
  tearDown(() => db.close());

  Future<TracerouteRecord> rec(DateTime time, {bool answered = true}) async {
    final id = await db
        .into(db.traceroutes)
        .insert(
          TraceroutesCompanion.insert(
            requestId: 7,
            targetNum: 0x42,
            time: time,
            data: answered
                ? RouteDiscovery(
                    route: [5],
                    snrTowards: [20, 24],
                  ).writeToBuffer()
                : Uint8List(0),
            answered: Value(answered),
          ),
        );
    return (db.select(
      db.traceroutes,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  TraceAlertWatcher watcher({bool on = true, List<TraceAlert>? out}) =>
      TraceAlertWatcher(
        db,
        me: () => 0xAA,
        enabled: () => on,
        onAlert: (a) => out?.add(a),
        now: () => now,
      );

  test('ответ пришёл — уведомление с именем и итогом', () async {
    final a = await watcher().check(await rec(now));
    expect(a!.title, 'Трассировка маршрута: Hides');
    expect(a.body, 'туда 1 хоп');
    expect(traceIdFromPayload(tracePayload(a.id)), a.id);
  });

  test('выключено или старое — молчим', () async {
    expect(await watcher(on: false).check(await rec(now)), isNull);
    final old = now.subtract(const Duration(hours: 1));
    expect(await watcher().check(await rec(old)), isNull);
  });

  test('без ответа не уведомляем; уведомляем, когда ответ записан', () async {
    final out = <TraceAlert>[];
    final w = watcher(out: out);
    final r = await rec(now, answered: false);
    await w.start();
    await pumpEventQueue();
    expect(out, isEmpty);
    // Ответ соседа без SNR — пустые байты, но ответ.
    await (db.update(db.traceroutes)..where((t) => t.id.equals(r.id))).write(
      TraceroutesCompanion(
        data: Value(Uint8List(0)),
        answered: const Value(true),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(out.single.body, 'туда напрямую');
    w.dispose();
  });

  test('payload сообщений — не трассировка', () {
    expect(traceIdFromPayload('dm:66'), isNull);
  });
}
