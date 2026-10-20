import 'dart:math' as math;

import '../core/proto/mesh.dart';
import 'database.dart';

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
}

/// Сколько времени нода считается «свежей» на карте.
const mapStaleAfter = Duration(hours: 2);

/// Координаты (0, 0) прошивка шлёт как «нет позиции» — их пропускаем.
bool hasPosition(Node n) =>
    n.latitude != null &&
    n.longitude != null &&
    !(n.latitude == 0 && n.longitude == 0);

List<MapPoint> mapPoints(List<Node> nodes, {int? me, DateTime? now}) {
  final t = now ?? DateTime.now();
  return [
    for (final n in nodes)
      if (hasPosition(n))
        MapPoint(
          num: n.num,
          lat: n.latitude!,
          lon: n.longitude!,
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
