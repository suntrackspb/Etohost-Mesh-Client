import 'package:etohost_mesh/data/map_points.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('точки окружности лежат на заданном расстоянии и замкнуты', () {
    final pts = circlePoints(59.94, 30.31, 25);
    expect(pts.first.lat, closeTo(pts.last.lat, 1e-9));
    expect(pts.first.lon, closeTo(pts.last.lon, 1e-9));
    const dist = Distance();
    for (final p in pts) {
      final m = dist(const LatLng(59.94, 30.31), LatLng(p.lat, p.lon));
      expect(m, closeTo(25000, 100));
    }
  });
}
