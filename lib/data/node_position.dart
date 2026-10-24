import 'database.dart';

/// Положение ноды для показа. [corrected] — исправлено зеркалом по
/// соседям (рисуем фиолетовую рамку); [mirror] — взято из зеркала.
typedef NodePosition = ({double lat, double lon, bool corrected, bool mirror});

bool _valid(double? lat, double? lon) =>
    lat != null && lon != null && !(lat == 0 && lon == 0);

/// Какие координаты показывать — единое правило для всего приложения:
/// 1) [correction] включена и зеркало прислало исправленные — они;
/// 2) иначе координаты из эфира;
/// 3) иначе какие есть из зеркала (исправленные — с пометкой).
/// (0, 0) — «нет позиции».
NodePosition? nodePosition(Node n, {required bool correction}) {
  final mirror = _valid(n.mirrorLat, n.mirrorLon);
  if (correction && mirror && n.mirrorCorrected) {
    return (
      lat: n.mirrorLat!,
      lon: n.mirrorLon!,
      corrected: true,
      mirror: true,
    );
  }
  if (_valid(n.latitude, n.longitude)) {
    return (
      lat: n.latitude!,
      lon: n.longitude!,
      corrected: false,
      mirror: false,
    );
  }
  if (mirror) {
    return (
      lat: n.mirrorLat!,
      lon: n.mirrorLon!,
      corrected: n.mirrorCorrected,
      mirror: true,
    );
  }
  return null;
}
