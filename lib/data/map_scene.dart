import 'map_points.dart';
import 'node_filter.dart';

/// Общая детализация фокуса и порог отключения кластеров.
const meshFocusZoom = 17.0;

/// Содержимое карты независимо от подложки и картографического SDK.
/// Координаты, фильтрация и признаки нод приходят из общего слоя данных.
class MeshMapScene {
  MeshMapScene({
    required List<MapPoint> points,
    this.area,
    this.cluster = true,
    this.showPrecision = false,
    this.highlightedNode,
  }) : points = List.unmodifiable(points);

  final List<MapPoint> points;
  final NodeArea? area;
  final bool cluster;
  final bool showPrecision;
  final int? highlightedNode;
}
