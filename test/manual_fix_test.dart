import 'package:etohost_mesh/data/position_sharer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 22);

  test('запятая и точка, высота необязательна', () {
    final f = manualFix('59,94', ' 30.31 ', '', now)!;
    expect((f.lat, f.lon, f.altitude), (59.94, 30.31, null));
    expect(manualFix('59.94', '30.31', '15', now)!.altitude, 15);
  });

  test('неверные значения — null', () {
    expect(manualFix('', '30', '', now), isNull);
    expect(manualFix('91', '30', '', now), isNull);
    expect(manualFix('59', '181', '', now), isNull);
    expect(manualFix('59', '30', 'высоко', now), isNull);
  });

  test('positionOf: координаты в 1e-7', () {
    final p = positionOf(manualFix('59.94', '30.31', '15', now)!);
    expect((p.latitudeI, p.longitudeI, p.altitude), (599400000, 303100000, 15));
  });
}
