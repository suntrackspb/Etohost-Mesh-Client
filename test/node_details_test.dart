import 'package:etohost_mesh/data/node_details.dart';
import 'package:etohost_mesh/data/node_row_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('качество словом', () {
    expect(qualityText(SignalQuality.good), 'хороший');
    expect(qualityText(SignalQuality.none), 'на грани');
  });

  test('аптайм', () {
    expect(uptimeText(40 * 60), '40 мин');
    expect(uptimeText(5 * 3600 + 12 * 60), '5 ч 12 мин');
    expect(uptimeText(3 * 86400 + 4 * 3600), '3 д 4 ч');
  });

  test('азимут', () {
    expect(bearingText(0), 'С 0°');
    expect(bearingText(45), 'СВ 45°');
    expect(bearingText(350), 'С 350°');
    expect(bearingText(200), 'Ю 200°');
  });

  test('заметка обрезается', () {
    expect(
      normalizeNote('  ретранслятор на крыше \n\n'),
      'ретранслятор на крыше',
    );
    expect(normalizeNote('   '), '');
  });
}
