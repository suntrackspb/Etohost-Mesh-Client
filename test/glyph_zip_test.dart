import 'package:etohost_mesh/core/glyph_zip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('уровень 0 не меняет текст', () {
    expect(GlyphZip.apply('Привет', 0), 'Привет');
  });

  test('уровни как в iOS-клиенте', () {
    expect(GlyphZip.apply('Сорок тысяч', 1), 'Copoк тыcяч');
    // «т» на уровне 3 — по-прежнему из группы 2 (как в Swift-версии).
    expect(GlyphZip.apply('тише', 2), 'muшe');
    expect(GlyphZip.apply('тише', 3), 'muwe');
    expect(GlyphZip.apply('ёж — Ok', 1), 'eж - Ok');
  });
}
