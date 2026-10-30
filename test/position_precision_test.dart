import 'package:meshex/data/node_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('радиус точности — таблица Android, вне 10..19 нет', () {
    expect(precisionRadiusMeters(null), isNull);
    expect(precisionRadiusMeters(0), isNull);
    expect(precisionRadiusMeters(9), isNull);
    expect(precisionRadiusMeters(32), isNull);
    expect(precisionRadiusMeters(10), closeTo(23345.48, 0.01));
    expect(precisionRadiusMeters(19), closeTo(45.59, 0.01));
  });

  test('подпись точности', () {
    expect(precisionText(15), 'точность ~730 м');
    expect(precisionText(11), 'точность ~12 км');
    expect(precisionText(32), isNull);
  });

  test('круги — только с порогового масштаба', () {
    expect(showPrecisionCircles(precisionCirclesMinZoom - 0.1), isFalse);
    expect(showPrecisionCircles(precisionCirclesMinZoom), isTrue);
  });
}
