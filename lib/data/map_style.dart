import 'package:flutter/widgets.dart' show Brightness;

/// Ключ CARTO (тёмная подложка); без него CARTO тайлы не отдаёт.
const cartoKey = String.fromEnvironment('CARTO_KEY');

/// Подложка карты: по теме приложения, светлая (OSM), тёмная (CARTO),
/// рельеф (OpenTopoMap).
enum MapStyle {
  auto('По теме приложения'),
  light('Светлая'),
  dark('Тёмная'),
  topo('Рельеф');

  const MapStyle(this.label);
  final String label;

  static MapStyle parse(String? v) =>
      values.where((s) => s.name == v).firstOrNull ?? auto;
}

/// Источник тайлов.
enum TileSource { osm, carto, topo }

/// Подложки в меню: без ключа CARTO — только светлая и рельеф.
List<MapStyle> availableMapStyles({String key = cartoKey}) =>
    key.isEmpty ? const [MapStyle.light, MapStyle.topo] : MapStyle.values;

/// Откуда брать тайлы; тёмные — только если в сборке есть ключ.
TileSource tileSource(
  MapStyle style,
  Brightness theme, {
  String key = cartoKey,
}) => switch (style) {
  MapStyle.topo => TileSource.topo,
  MapStyle.dark when key.isNotEmpty => TileSource.carto,
  MapStyle.auto when key.isNotEmpty && theme == Brightness.dark =>
    TileSource.carto,
  _ => TileSource.osm,
};
