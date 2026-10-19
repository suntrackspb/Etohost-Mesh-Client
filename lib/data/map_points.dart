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
