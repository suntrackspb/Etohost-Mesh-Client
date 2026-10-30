import 'package:meshex/core/glyph_zip.dart';
import 'package:meshex/data/message_split.dart';
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

  test('самый слабый уровень, которым влезает в одно', () {
    expect(zipLevelToSend('привет', 3), 1);
    expect(zipLevelToSend('привет', 2), 1);
    expect(zipLevelToSend('привет', 1), 1);
    expect(zipLevelToSend('привет', 0), 0);
    final long = 'ш' * 150; // 300 байт на любом уровне до 3
    expect(zipLevelToSend(long, 2), 2);
    expect(zipLevelToSend(long, 3), 3);
    expect(zipLevelToSend('ттт', 3, max: 2), 3);
    expect(zipLevelToSend('ттт', 3, max: 6), 1);
    // 'тт' — 4 байта уровнем 1, 2 байта уровнем 2 ('mm').
    expect(zipLevelToSend('тт', 3, max: 3), 2);
    expect(zipLevelToSend('тт', 2, max: 3), 2);
  });
}
