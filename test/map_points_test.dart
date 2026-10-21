import 'package:etohost_mesh/data/map_points.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'node_filter_test.dart' show n;

void main() {
  test('точки только с координатами, (0,0) — нет позиции', () {
    final now = DateTime(2026, 10, 20, 12);
    final a = n(
      1,
      heard: now,
    ).copyWith(latitude: const Value(59.9), longitude: const Value(30.3));
    final b = n(
      2,
    ).copyWith(latitude: const Value(0.0), longitude: const Value(0.0));
    final c = n(
      3,
      heard: now.subtract(const Duration(hours: 5)),
    ).copyWith(latitude: const Value(60.0), longitude: const Value(30.0));
    final p = mapPoints([a, b, n(4), c], me: 1, now: now);
    expect(p.map((e) => e.num), [1, 3]);
    expect(p.first.isMe, isTrue);
    expect(p.first.stale, isFalse);
    expect(p.last.stale, isTrue);
    expect(p.last.label, '0003');
  });

  test('ноды под меткой: в радиусе на экране, сама — всегда', () {
    MapPoint pt(int num, double lat, double lon) => MapPoint(
      num: num,
      lat: lat,
      lon: lon,
      label: '$num',
      title: '$num',
      isMe: false,
      isFavorite: false,
      stale: false,
      mirrorOnly: false,
    );
    final a = pt(1, 0, 0), b = pt(2, 0, 0), c = pt(3, 0, 15), d = pt(4, 0, 30);
    // «Экран» — просто lon по x.
    ({double x, double y}) screen(MapPoint p) => (x: p.lon, y: p.lat);
    final all = [a, b, c, d];
    expect(overlappingPoints(all, a, screen).map((p) => p.num), [1, 2, 3]);
    expect(overlappingPoints(all, d, screen).map((p) => p.num), [3, 4]);
    expect(overlappingPoints(all, d, screen, radius: 0).map((p) => p.num), [4]);
  });

  test('поиск по имени, короткому имени и id', () {
    MapPoint pt(int num, String title, String label) => MapPoint(
      num: num,
      lat: 0,
      lon: 0,
      label: label,
      title: title,
      isMe: false,
      isFavorite: false,
      stale: false,
      mirrorOnly: false,
    );
    final all = [pt(0x9eeff120, 'SUNo Base', 'SUNo'), pt(0x1, 'Другая', 'DR')];
    expect(searchPoints(all, 'sunO').length, 1);
    expect(searchPoints(all, 'f120').single.num, 0x9eeff120);
    expect(searchPoints(all, '!9eef').single.num, 0x9eeff120);
    expect(searchPoints(all, 'друг').single.num, 1);
    expect(searchPoints(all, '  '), isEmpty);
  });
}
