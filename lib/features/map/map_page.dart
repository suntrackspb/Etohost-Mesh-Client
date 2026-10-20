import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../app/providers.dart';
import '../../data/map_points.dart';
import '../../ui/kit/kit.dart';
import '../nodes/node_filter_sheet.dart';
import 'map_tiles.dart';

/// Карта нод (OSM). Фильтр общий со списком нод.
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final _map = MapController();
  bool _ready = false;
  bool _fitted = false;

  /// Поворот карты, градусы (для кнопки «север сверху»).
  double _rotation = 0;

  void _fitAll(List<MapPoint> points) {
    if (!_ready || points.isEmpty) return;
    if (points.length == 1) {
      _map.move(LatLng(points.first.lat, points.first.lon), 13);
      return;
    }
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: [for (final p in points) LatLng(p.lat, p.lon)],
        padding: const EdgeInsets.all(48),
        maxZoom: 15,
      ),
    );
  }

  void _open(int num) {
    if (SplitView.isWide(context)) {
      context.go('/nodes/$num');
    } else {
      context.push('/node/$num');
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = ref.watch(mapPointsProvider);
    final filtered = ref.watch(nodeFilterProvider).active;
    final me = points.where((p) => p.isMe).firstOrNull;
    final rotate = ref.watch(mapRotateProvider).value ?? false;
    final area = ref.watch(nodeAreaProvider);
    final scheme = Theme.of(context).colorScheme;
    // Вращение выключили — вернуть север наверх.
    if (!rotate && _rotation != 0 && _ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _map.rotate(0));
    }
    // Первое появление точек — показать все.
    if (!_fitted && points.isNotEmpty && _ready) {
      _fitted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitAll(points));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Карта${points.isEmpty ? '' : ' (${points.length})'}'),
        actions: [
          IconButton(
            tooltip: 'Фильтры',
            icon: Badge(
              isLabelVisible: filtered,
              smallSize: 8,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => NodeFilterSheet.show(context),
          ),
          if (me != null)
            IconButton(
              tooltip: 'Моя нода',
              icon: const Icon(Icons.my_location),
              onPressed: () => _map.move(LatLng(me.lat, me.lon), 14),
            ),
          IconButton(
            tooltip: 'Показать все',
            icon: const Icon(Icons.zoom_out_map),
            onPressed: points.isEmpty ? null : () => _fitAll(points),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: defaultMapCenter,
              initialZoom: 9,
              interactionOptions: InteractionOptions(
                flags: rotate
                    ? InteractiveFlag.all
                    : InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onMapReady: () => setState(() => _ready = true),
              onPositionChanged: (cam, _) {
                if ((cam.rotation - _rotation).abs() > 0.5 ||
                    (cam.rotation == 0) != (_rotation == 0)) {
                  setState(() => _rotation = cam.rotation);
                }
              },
            ),
            children: [
              const OsmTiles(),
              if (area != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        for (final p in circlePoints(
                          area.center.lat,
                          area.center.lon,
                          area.km,
                        ))
                          LatLng(p.lat, p.lon),
                      ],
                      color: scheme.primary.withValues(alpha: 0.6),
                      strokeWidth: 2,
                    ),
                  ],
                ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  markers: [
                    for (final p in points)
                      Marker(
                        key: ValueKey(p.num),
                        point: LatLng(p.lat, p.lon),
                        width: 56,
                        height: 32,
                        child: _NodeMarker(p, onTap: () => _open(p.num)),
                      ),
                  ],
                  builder: (context, markers) => CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: Text('${markers.length}'),
                  ),
                ),
              ),
              const OsmAttribution(),
            ],
          ),
          if (_rotation % 360 != 0)
            Positioned(
              right: Tokens.s16,
              top: Tokens.s16,
              child: FloatingActionButton.small(
                heroTag: 'north',
                tooltip: 'Север сверху',
                onPressed: () => _map.rotate(0),
                child: Transform.rotate(
                  angle: _rotation * 3.141592653589793 / 180,
                  child: const Icon(Icons.navigation),
                ),
              ),
            ),
          if (points.isEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: Card(
                margin: const EdgeInsets.all(Tokens.s16),
                child: Padding(
                  padding: const EdgeInsets.all(Tokens.s16),
                  child: Text(
                    filtered
                        ? 'Под фильтр не подходит ни одна нода с координатами.'
                        : 'Нет нод с координатами.\n'
                              'Это нормально: начиная с прошивки 2.8 отправка '
                              'позиции по умолчанию выключена.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NodeMarker extends StatelessWidget {
  const _NodeMarker(this.p, {required this.onTap});

  final MapPoint p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = p.isMe
        ? scheme.tertiary
        : p.isFavorite
        ? scheme.secondary
        : scheme.primary;
    final fg = p.isMe
        ? scheme.onTertiary
        : p.isFavorite
        ? scheme.onSecondary
        : scheme.onPrimary;
    return Tooltip(
      message: p.mirrorOnly ? '${p.title} (зеркало)' : p.title,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: p.stale ? 0.5 : 1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.surface, width: 2),
            ),
            child: Text(
              p.label,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
