import 'package:etohost_mesh/data/map_style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('тёмные тайлы — только с ключом и по выбору/теме', () {
    expect(darkTiles(MapStyle.auto, Brightness.dark, key: 'k'), isTrue);
    expect(darkTiles(MapStyle.auto, Brightness.light, key: 'k'), isFalse);
    expect(darkTiles(MapStyle.dark, Brightness.light, key: 'k'), isTrue);
    expect(darkTiles(MapStyle.light, Brightness.dark, key: 'k'), isFalse);
    expect(darkTiles(MapStyle.dark, Brightness.dark, key: ''), isFalse);
  });

  test('неизвестное значение настройки — по теме', () {
    expect(MapStyle.parse(null), MapStyle.auto);
    expect(MapStyle.parse('dark'), MapStyle.dark);
    expect(MapStyle.parse('x'), MapStyle.auto);
  });
}
