import 'package:flutter/widgets.dart' show Brightness;

/// Ключ CARTO (тёмная подложка); без него CARTO тайлы не отдаёт.
const cartoKey = String.fromEnvironment('CARTO_KEY');

/// Есть ли выбор подложки в этой сборке.
const mapStylesAvailable = cartoKey != '';

/// Подложка карты: по теме приложения, светлая (OSM), тёмная (CARTO).
enum MapStyle {
  auto('По теме приложения'),
  light('Светлая'),
  dark('Тёмная');

  const MapStyle(this.label);
  final String label;

  static MapStyle parse(String? v) =>
      values.where((s) => s.name == v).firstOrNull ?? auto;
}

/// Тёмные тайлы — только если в сборке есть ключ.
bool darkTiles(MapStyle style, Brightness theme, {String key = cartoKey}) =>
    key.isNotEmpty &&
    (style == MapStyle.dark ||
        (style == MapStyle.auto && theme == Brightness.dark));
