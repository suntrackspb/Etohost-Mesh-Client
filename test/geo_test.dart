import 'package:etohost_mesh/core/geo/geo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('расстояние и азимут', () {
    const spb = (lat: 59.9386, lon: 30.3141);
    const msk = (lat: 55.7558, lon: 37.6173);
    expect(distanceKm(spb, msk), closeTo(634, 3));
    expect(bearingDeg(spb, (lat: 60.9386, lon: 30.3141)), closeTo(0, 0.01));
    expect(bearingDeg(spb, msk), closeTo(134, 2));
  });

  test('текст и разбор координат', () {
    expect(distanceText(0.85), '850 м');
    expect(distanceText(12.44), '12,4 км');
    expect(distanceText(130.4), '130 км');
    expect(parseLatLon('59.9, 30.3'), (lat: 59.9, lon: 30.3));
    expect(parseLatLon('100, 0'), isNull);
    expect(parseLatLon(null), isNull);
  });
}
