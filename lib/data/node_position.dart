import 'database.dart';
import 'jammer_zones.dart';

/// Положение ноды для показа. [corrected] — исправлено зеркалом по
/// соседям (рисуем фиолетовую рамку); [mirror] — взято из зеркала;
/// [spoofed] — точка в зоне глушилки и заменить её нечем («вероятно,
/// спуфинг»); [at] — время запасной точки, которой заменили подменённую.
typedef NodePosition = ({
  double lat,
  double lon,
  bool corrected,
  bool mirror,
  bool spoofed,
  DateTime? at,
  int? precisionBits,
});

/// Настройки правила: корректировка включена и зоны глушилок.
typedef PositionRules = ({bool correction, JammerZones zones});

/// [nodePosition] по [PositionRules].
NodePosition? nodePositionBy(Node n, PositionRules r, {DateTime? now}) =>
    nodePosition(n, correction: r.correction, zones: r.zones, now: now);

/// Запасная точка старее — не верим: нода могла уехать.
const spoofFreshness = Duration(days: 5);

bool _valid(double? lat, double? lon) =>
    lat != null && lon != null && !(lat == 0 && lon == 0);

NodePosition _pos(
  double lat,
  double lon, {
  bool corrected = false,
  bool mirror = false,
  bool spoofed = false,
  DateTime? at,
  int? precisionBits,
}) => (
  lat: lat,
  lon: lon,
  corrected: corrected,
  mirror: mirror,
  spoofed: spoofed,
  at: at,
  precisionBits: precisionBits,
);

/// Какие координаты показывать — единое правило для всего приложения.
/// Основная точка — из эфира, нет её — из зеркала. (0, 0) — «нет позиции».
///
/// Основная точка в зоне глушилки ([zones]) и [correction] включена — ищем
/// замену: своя последняя точка вне зон не старше [spoofFreshness],
/// затем исправленная зеркалом по соседям, затем последняя точка зеркала
/// вне зон не старше [spoofFreshness]. Нечем заменить или [correction]
/// выключена — основная точка с пометкой [NodePosition.spoofed].
///
/// Зон нет (зеркало не отвечало) — как раньше: при [correction]
/// исправленная зеркалом точка важнее эфира.
NodePosition? nodePosition(
  Node n, {
  required bool correction,
  JammerZones zones = JammerZones.none,
  DateTime? now,
}) {
  final mirror = _valid(n.mirrorLat, n.mirrorLon);
  final mirrorPos = mirror
      ? _pos(
          n.mirrorLat!,
          n.mirrorLon!,
          corrected: n.mirrorCorrected,
          mirror: true,
          precisionBits: n.mirrorPrecisionBits,
        )
      : null;
  if (zones.isEmpty && correction && n.mirrorCorrected && mirrorPos != null) {
    return mirrorPos;
  }
  final main = _valid(n.latitude, n.longitude)
      ? _pos(n.latitude!, n.longitude!, precisionBits: n.precisionBits)
      : mirrorPos;
  if (main == null || main.corrected || !zones.isBad(main.lat, main.lon)) {
    return main;
  }
  if (correction) {
    final t = now ?? DateTime.now();
    bool good(double? lat, double? lon, DateTime? at) =>
        _valid(lat, lon) &&
        at != null &&
        t.difference(at) <= spoofFreshness &&
        !zones.isBad(lat!, lon!);
    if (good(n.radioGoodLat, n.radioGoodLon, n.radioGoodAt)) {
      return _pos(n.radioGoodLat!, n.radioGoodLon!, at: n.radioGoodAt);
    }
    if (n.mirrorCorrected && mirrorPos != null) return mirrorPos;
    if (good(n.mirrorGoodLat, n.mirrorGoodLon, n.mirrorGoodAt)) {
      return _pos(
        n.mirrorGoodLat!,
        n.mirrorGoodLon!,
        mirror: true,
        at: n.mirrorGoodAt,
      );
    }
  }
  return _pos(
    main.lat,
    main.lon,
    mirror: main.mirror,
    spoofed: true,
    precisionBits: main.precisionBits,
  );
}

/// Подпись к координатам в карточке ноды; null — без подписи.
/// [ago] — «3 ч назад» для времени запасной точки.
String? positionNote(NodePosition p, String Function(DateTime t) ago) =>
    p.spoofed
    ? 'вероятно, подменённая точка (зона глушилки)'
    : p.at != null
    ? 'последняя точка вне зоны глушилки, ${ago(p.at!)}'
    : p.corrected
    ? 'скорректировано по соседям'
    : null;

/// Радиус круга точности в метрах по precision_bits — таблица из
/// Android-клиента (PositionPrecision.kt); вне 10..19 круга нет.
double? precisionRadiusMeters(int? bits) => switch (bits) {
  10 => 23345.484932,
  11 => 11672.7369,
  12 => 5836.36288,
  13 => 2918.175876,
  14 => 1459.0823719999053,
  15 => 729.53562,
  16 => 364.7622,
  17 => 182.375556,
  18 => 91.182212,
  19 => 45.58554,
  _ => null,
};

/// С какого масштаба карты рисуем круги точности.
const precisionCirclesMinZoom = 12.0;

bool showPrecisionCircles(double zoom) => zoom >= precisionCirclesMinZoom;

/// «точность ~730 м» / «точность ~23 км»; null — круга точности нет.
String? precisionText(int? bits) {
  final m = precisionRadiusMeters(bits);
  if (m == null) return null;
  return m >= 1000
      ? 'точность ~${(m / 1000).round()} км'
      : 'точность ~${m.round()} м';
}

extension EmptyNull on String {
  String? get ifEmptyNull => isEmpty ? null : this;
}
