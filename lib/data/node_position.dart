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
}) => (
  lat: lat,
  lon: lon,
  corrected: corrected,
  mirror: mirror,
  spoofed: spoofed,
  at: at,
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
        )
      : null;
  if (zones.isEmpty && correction && n.mirrorCorrected && mirrorPos != null) {
    return mirrorPos;
  }
  final main = _valid(n.latitude, n.longitude)
      ? _pos(n.latitude!, n.longitude!)
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
  return _pos(main.lat, main.lon, mirror: main.mirror, spoofed: true);
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
