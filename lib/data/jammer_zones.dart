import 'dart:convert';

/// Прямоугольник зоны глушилки (границы включительно).
typedef JammerZone = ({
  double latMin,
  double latMax,
  double lonMin,
  double lonMax,
});

/// Зоны глушилок и правила «плохой» точки — с зеркала
/// (`GET /api/jammer-zones`). Точка плохая, если она в любой зоне, около
/// «нулевого острова» (|lat| < [nullLat] и |lon| < [nullLon]) или ровно
/// (0, 0) при [excludeZero].
class JammerZones {
  const JammerZones({
    this.zones = const [],
    this.nullLat,
    this.nullLon,
    this.excludeZero = false,
  });

  /// Зон нет (зеркало не настроено или ещё не отвечало) — все точки хорошие.
  static const none = JammerZones();

  final List<JammerZone> zones;
  final double? nullLat;
  final double? nullLon;
  final bool excludeZero;

  bool get isEmpty =>
      zones.isEmpty && (nullLat == null || nullLon == null) && !excludeZero;

  /// Точка похожа на подменённую (спуфинг GPS).
  bool isBad(double lat, double lon) {
    if (excludeZero && lat == 0 && lon == 0) return true;
    if (nullLat != null &&
        nullLon != null &&
        lat.abs() < nullLat! &&
        lon.abs() < nullLon!) {
      return true;
    }
    for (final z in zones) {
      if (lat >= z.latMin &&
          lat <= z.latMax &&
          lon >= z.lonMin &&
          lon <= z.lonMax) {
        return true;
      }
    }
    return false;
  }

  /// Ответ зеркала; null — формат не тот.
  static JammerZones? fromJson(Object? j) {
    if (j is! Map) return null;
    final list = j['zones'];
    if (list is! List) return null;
    double? d(Object? v) => v is num ? v.toDouble() : null;
    final zones = <JammerZone>[];
    for (final z in list) {
      if (z is! Map) return null;
      final (a, b, c, e) = (
        d(z['lat_min']),
        d(z['lat_max']),
        d(z['lon_min']),
        d(z['lon_max']),
      );
      if (a == null || b == null || c == null || e == null) return null;
      zones.add((latMin: a, latMax: b, lonMin: c, lonMax: e));
    }
    final ni = j['null_island'];
    return JammerZones(
      zones: zones,
      nullLat: ni is Map ? d(ni['abs_lat_lt']) : null,
      nullLon: ni is Map ? d(ni['abs_lon_lt']) : null,
      excludeZero: j['exclude_zero'] == true,
    );
  }

  Map<String, Object?> toJson() => {
    'zones': [
      for (final z in zones)
        {
          'lat_min': z.latMin,
          'lat_max': z.latMax,
          'lon_min': z.lonMin,
          'lon_max': z.lonMax,
        },
    ],
    if (nullLat != null && nullLon != null)
      'null_island': {'abs_lat_lt': nullLat, 'abs_lon_lt': nullLon},
    'exclude_zero': excludeZero,
  };

  /// Для хранения в настройках.
  String encode() => jsonEncode(toJson());

  /// Из настроек; пусто или испорчено — [none].
  static JammerZones decode(String? s) {
    if (s == null || s.isEmpty) return none;
    try {
      return fromJson(jsonDecode(s)) ?? none;
    } on FormatException {
      return none;
    }
  }
}
