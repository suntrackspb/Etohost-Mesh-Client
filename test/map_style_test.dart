import 'package:etohost_mesh/data/map_style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('источник тайлов: тёмные — только с ключом, рельеф — всегда', () {
    TileSource src(MapStyle s, Brightness b, [String k = 'k']) =>
        tileSource(s, b, key: k);
    expect(src(MapStyle.auto, Brightness.dark), TileSource.carto);
    expect(src(MapStyle.auto, Brightness.light), TileSource.osm);
    expect(src(MapStyle.dark, Brightness.light), TileSource.carto);
    expect(src(MapStyle.light, Brightness.dark), TileSource.osm);
    expect(src(MapStyle.dark, Brightness.dark, ''), TileSource.osm);
    expect(src(MapStyle.topo, Brightness.dark, ''), TileSource.topo);
    expect(availableMapStyles(key: ''), [MapStyle.light, MapStyle.topo]);
    expect(availableMapStyles(key: 'k'), MapStyle.values);
  });

  test('неизвестное значение настройки — по теме', () {
    expect(MapStyle.parse(null), MapStyle.auto);
    expect(MapStyle.parse('dark'), MapStyle.dark);
    expect(MapStyle.parse('x'), MapStyle.auto);
  });
}
