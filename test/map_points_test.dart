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
}
