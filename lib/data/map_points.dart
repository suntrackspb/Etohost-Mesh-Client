import 'dart:math' as math;

import '../core/proto/mesh.dart';
import 'database.dart';
import 'node_position.dart';

/// Точка на карте — нода с координатами и признаки для отрисовки.
class MapPoint {
  const MapPoint({
    required this.num,
    required this.lat,
    required this.lon,
    required this.label,
    required this.title,
    required this.isMe,
    required this.isFavorite,
    required this.stale,
    required this.mirrorOnly,
    this.corrected = false,
  });

  final int num;
  final double lat;
  final double lon;

  /// Короткое имя для маркера.
  final String label;
  final String title;
  final bool isMe;
  final bool isFavorite;

  /// Давно не слышали — рисуем бледнее.
  final bool stale;
  final bool mirrorOnly;

  /// Положение исправлено зеркалом по соседям — фиолетовая рамка.
  final bool corrected;
}

/// Сколько времени нода считается «свежей» на карте.
const mapStaleAfter = Duration(hours: 2);

List<MapPoint> mapPoints(
  List<Node> nodes, {
  int? me,
  DateTime? now,
  bool correction = false,
}) {
  final t = now ?? DateTime.now();
  return [
    for (final n in nodes)
      if (nodePosition(n, correction: correction) case final p?)
        MapPoint(
          num: n.num,
          lat: p.lat,
          lon: p.lon,
          corrected: p.corrected,
          label: n.shortName.isNotEmpty
              ? n.shortName
              : nodeIdString(n.num).substring(5),
          title: n.longName.isNotEmpty ? n.longName : nodeIdString(n.num),
          isMe: n.num == me,
          isFavorite: n.isFavorite,
          stale:
              n.num != me &&
              (n.lastHeard == null ||
                  t.difference(n.lastHeard!) > mapStaleAfter),
          mirrorOnly: !n.onRadio,
        ),
  ];
}

/// Окружность радиусом [km] вокруг точки как замкнутая ломаная (сферная
/// формула прямой геодезической задачи). Рисуем её линией, а не кругом
/// flutter_map: обводка большого круга на Linux (OpenGL) рисуется
/// неверно — заливается всё вокруг.
List<({double lat, double lon})> circlePoints(
  double lat,
  double lon,
  double km, {
  int segments = 128,
}) {
  const r = 6371.0;
  final d = km / r;
  final p1 = lat * math.pi / 180, l1 = lon * math.pi / 180;
  return [
    for (var i = 0; i <= segments; i++)
      () {
        final b = 2 * math.pi * i / segments;
        final p2 = math.asin(
          math.sin(p1) * math.cos(d) + math.cos(p1) * math.sin(d) * math.cos(b),
        );
        final l2 =
            l1 +
            math.atan2(
              math.sin(b) * math.sin(d) * math.cos(p1),
              math.cos(d) - math.sin(p1) * math.sin(p2),
            );
        return (lat: p2 * 180 / math.pi, lon: l2 * 180 / math.pi);
      }(),
  ];
}

/// Точки, чьи метки на экране перекрывают метку [tapped] (включая её саму):
/// [screen] переводит точку в экранные координаты, [radius] — в пикселях.
/// Без группировки ноды в одной точке иначе не достать.
List<MapPoint> overlappingPoints(
  List<MapPoint> points,
  MapPoint tapped,
  ({double x, double y}) Function(MapPoint p) screen, {
  double radius = 20,
}) {
  final c = screen(tapped);
  return [
    for (final p in points)
      if (p.num == tapped.num ||
          () {
            final s = screen(p);
            final dx = s.x - c.x, dy = s.y - c.y;
            return dx * dx + dy * dy <= radius * radius;
          }())
        p,
  ];
}

/// Поиск точки по имени, короткому имени и id (!9eeff120 или 9eeff120).
List<MapPoint> searchPoints(List<MapPoint> points, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return [
    for (final p in points)
      if (p.title.toLowerCase().contains(q) ||
          p.label.toLowerCase().contains(q) ||
          nodeIdString(p.num).contains(q))
        p,
  ];
}
