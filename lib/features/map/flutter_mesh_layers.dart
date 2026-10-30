import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../data/map_points.dart';
import '../../data/map_scene.dart';
import '../../data/node_position.dart';
import '../../ui/kit/kit.dart';

/// Адаптер объектов приложения к flutter_map. Не выбирает подложку
/// и не читает провайдеры: ту же сцену сможет отрисовать нативная карта.
List<Widget> flutterMeshLayers(
  BuildContext context, {
  required MeshMapScene scene,
  required double zoom,
  required ValueChanged<MapPoint> onNodeTap,
}) {
  final markers = [
    for (final p in scene.points)
      Marker(
        key: ValueKey(p.num),
        point: LatLng(p.lat, p.lon),
        width: MeshNodeMarker.size,
        height: MeshNodeMarker.size,
        child: MeshNodeMarker(
          p,
          highlight: p.num == scene.highlightedNode,
          onTap: () => onNodeTap(p),
        ),
      ),
  ];

  return [
    if (scene.area != null)
      PolylineLayer(
        polylines: [
          Polyline(
            points: [
              for (final p in circlePoints(
                scene.area!.center.lat,
                scene.area!.center.lon,
                scene.area!.km,
              ))
                LatLng(p.lat, p.lon),
            ],
            // Красный с белой обводкой — виден и на светлых, и на
            // зелёных/водных участках OSM.
            color: Colors.red.shade700,
            strokeWidth: 3,
            borderColor: Colors.white,
            borderStrokeWidth: 1.5,
            pattern: StrokePattern.dashed(segments: const [12, 8]),
          ),
        ],
      ),
    if (scene.showPrecision && showPrecisionCircles(zoom))
      PolygonLayer(
        polygons: [
          for (final p in scene.points)
            if (p.precisionMeters case final m?)
              Polygon(
                points: [
                  for (final c in circlePoints(
                    p.lat,
                    p.lon,
                    m / 1000,
                    segments: 48,
                  ))
                    LatLng(c.lat, c.lon),
                ],
                color: Colors.blue.withValues(alpha: 0.12),
                borderColor: Colors.blue.withValues(alpha: 0.6),
                borderStrokeWidth: 1.5,
              ),
        ],
      ),
    if (scene.cluster)
      MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          maxClusterRadius: 45,
          disableClusteringAtZoom: meshFocusZoom.toInt(),
          size: const Size(40, 40),
          markers: markers,
          builder: (context, markers) => CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: Text('${markers.length}'),
          ),
        ),
      )
    else
      MarkerLayer(markers: markers),
  ];
}

/// Метка ноды: кружок в её цвет (как NodeAvatar в списке и чате). Своя —
/// с кольцом акцентного цвета, избранная — с кольцом и звёздочкой.
class MeshNodeMarker extends StatelessWidget {
  const MeshNodeMarker(
    this.p, {
    super.key,
    required this.onTap,
    this.highlight = false,
  });

  static const size = 40.0;

  final MapPoint p;
  final VoidCallback onTap;

  /// Найдена поиском: яркое кольцо и свечение.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ring = highlight
        ? Colors.red.shade600
        : p.isMe
        ? scheme.tertiary
        : p.isFavorite
        ? favoriteMarkerColor
        : p.spoofed
        ? spoofedMarkerColor
        : p.corrected
        ? correctedMarkerColor
        : scheme.surface;
    final thick =
        highlight || p.isMe || p.isFavorite || p.corrected || p.spoofed;
    return Tooltip(
      message: [
        p.title,
        if (p.mirrorOnly) '(зеркало)',
        if (p.corrected) '· скорректировано',
        if (p.spoofed) '· вероятно, подменённая точка',
      ].join(' '),
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: p.stale && !highlight ? 0.5 : 1,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ring, width: thick ? 3 : 2),
                  boxShadow: [
                    const BoxShadow(blurRadius: 3, color: Color(0x55000000)),
                    if (highlight)
                      BoxShadow(
                        blurRadius: 16,
                        spreadRadius: 6,
                        color: Colors.red.withValues(alpha: 0.6),
                      ),
                  ],
                ),
                child: NodeAvatar(
                  nodeNum: p.num,
                  shortName: p.label,
                  size: size - (thick ? 6 : 4),
                ),
              ),
              if (p.isFavorite)
                Positioned(
                  right: -4,
                  top: -4,
                  child: const Icon(
                    Icons.star,
                    size: 16,
                    color: favoriteMarkerColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Избранные — золотистым, как звёздочка в списке нод.
const favoriteMarkerColor = Colors.amber;

/// Положение исправлено зеркалом по соседям — фиолетовая рамка, как на
/// карте зеркала.
const correctedMarkerColor = Color(0xFF9C27B0);

/// Точка в зоне глушилки и заменить нечем — оранжевая рамка.
const spoofedMarkerColor = Colors.deepOrange;
