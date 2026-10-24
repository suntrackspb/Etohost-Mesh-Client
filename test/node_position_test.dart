import 'package:drift/drift.dart' show Value;
import 'package:etohost_mesh/data/map_points.dart';
import 'package:etohost_mesh/data/node_position.dart';
import 'package:etohost_mesh/mirror/mirror_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'node_filter_test.dart' show n;

void main() {
  // Радио: глушилка увела ноду; зеркало: исправило по соседям.
  final jammed = n(1).copyWith(
    latitude: const Value(60.1),
    longitude: const Value(31.3),
    mirrorLat: const Value(59.9),
    mirrorLon: const Value(30.3),
    mirrorCorrected: true,
  );

  test('корректировка выключена — радио важнее зеркала', () {
    final p = nodePosition(jammed, correction: false)!;
    expect((p.lat, p.corrected, p.mirror), (60.1, false, false));
  });

  test('корректировка включена — исправленные зеркалом важнее радио', () {
    final p = nodePosition(jammed, correction: true)!;
    expect((p.lat, p.corrected, p.mirror), (59.9, true, true));
  });

  test('неисправленные координаты зеркала радио не перебивают', () {
    final plain = jammed.copyWith(mirrorCorrected: false);
    expect(nodePosition(plain, correction: true)!.lat, 60.1);
  });

  test('нет радио — что есть из зеркала, исправленные с пометкой', () {
    final mirrorOnly = jammed.copyWith(
      latitude: const Value(null),
      longitude: const Value(null),
    );
    final p = nodePosition(mirrorOnly, correction: false)!;
    expect((p.lat, p.corrected), (59.9, true));
  });

  test('(0, 0) — нет позиции ни в одном источнике', () {
    final zero = n(2).copyWith(
      latitude: const Value(0.0),
      longitude: const Value(0.0),
      mirrorLat: const Value(0.0),
      mirrorLon: const Value(0.0),
    );
    expect(nodePosition(zero, correction: true), isNull);
  });

  test('точки карты — по тому же правилу, с признаком коррекции', () {
    final p = mapPoints([jammed], correction: true).single;
    expect((p.lat, p.corrected), (59.9, true));
    expect(mapPoints([jammed]).single.corrected, isFalse);
  });

  test('признак коррекции из ответа зеркала', () {
    final m = MirrorNode.tryParse({
      'node_id': '!00000001',
      'last_lat': 59.9,
      'last_lon': 30.3,
      'position_corrected': true,
    })!;
    expect(m.positionCorrected, isTrue);
    expect(MirrorNode.tryParse({'node_id': '!1'})!.positionCorrected, isFalse);
  });
}
