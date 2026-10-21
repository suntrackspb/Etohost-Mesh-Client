import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../data/map_points.dart';
import '../../data/map_style.dart';
import '../../core/proto/mesh.dart';
import '../../ui/kit/kit.dart';
import '../nodes/open_node.dart';
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

  /// Найденная поиском нода — подсвечена несколько секунд.
  int? _found;
  Timer? _foundTimer;

  /// Масштаб, с которого ноды не группируются; поиск приближает до него.
  static const _focusZoom = 17.0;

  @override
  void dispose() {
    _foundTimer?.cancel();
    super.dispose();
  }

  Future<void> _search(List<MapPoint> points) async {
    final p = await showModalBottomSheet<MapPoint>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SearchSheet(points),
    );
    if (p == null || !mounted) return;
    _map.move(LatLng(p.lat, p.lon), _focusZoom);
    _foundTimer?.cancel();
    setState(() => _found = p.num);
    _foundTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _found = null);
    });
  }

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

  void _open(int num) => openNode(context, num);

  /// Нажатие на метку: под ней другие ноды — выбрать из списка.
  void _tap(List<MapPoint> points, MapPoint p) {
    final cam = _map.camera;
    final here = overlappingPoints(points, p, (q) {
      final o = cam.latLngToScreenOffset(LatLng(q.lat, q.lon));
      return (x: o.dx, y: o.dy);
    }, radius: _NodeMarker.size / 2);
    if (here.length == 1) return _open(p.num);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Tokens.s16,
                0,
                Tokens.s16,
                Tokens.s8,
              ),
              child: Text(
                'Ноды в этом месте: ${here.length}',
                style: Theme.of(c).textTheme.titleMedium,
              ),
            ),
            for (final q in here)
              ListTile(
                leading: NodeAvatar(nodeNum: q.num, shortName: q.label),
                title: Text(q.title),
                subtitle: Text(nodeIdString(q.num)),
                onTap: () {
                  Navigator.pop(c);
                  _open(q.num);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = ref.watch(mapPointsProvider);
    final filtered = ref.watch(nodeFilterProvider).active;
    final me = points.where((p) => p.isMe).firstOrNull;
    final rotate = ref.watch(mapRotateProvider).value ?? false;
    final area = ref.watch(nodeAreaProvider);
    final cluster = ref.watch(mapClusterProvider).value ?? true;
    // Вращение выключили — вернуть север наверх.
    if (!rotate && _rotation != 0 && _ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _map.rotate(0));
    }
    // Первое появление точек — показать все.
    if (!_fitted && points.isNotEmpty && _ready) {
      _fitted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitAll(points));
    }

    final markers = [
      for (final p in points)
        Marker(
          key: ValueKey(p.num),
          point: LatLng(p.lat, p.lon),
          width: _NodeMarker.size,
          height: _NodeMarker.size,
          child: _NodeMarker(
            p,
            highlight: p.num == _found,
            onTap: () => _tap(points, p),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Карта${points.isEmpty ? '' : ' (${points.length})'}'),
        actions: [
          IconButton(
            tooltip: 'Найти ноду',
            icon: const Icon(Icons.search),
            onPressed: points.isEmpty ? null : () => _search(points),
          ),
          IconButton(
            tooltip: 'Фильтры',
            icon: Badge(
              isLabelVisible: filtered,
              smallSize: 8,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => NodeFilterSheet.show(context),
          ),
          if (mapStylesAvailable)
            PopupMenuButton<MapStyle>(
              tooltip: 'Подложка',
              icon: const Icon(Icons.layers_outlined),
              initialValue: ref.watch(mapStyleProvider).value ?? MapStyle.auto,
              onSelected: (v) => ref
                  .read(databaseProvider)
                  .setSetting(AppSettingKeys.mapStyle, v.name),
              itemBuilder: (_) => [
                for (final s in MapStyle.values)
                  PopupMenuItem(value: s, child: Text(s.label)),
              ],
            ),
          IconButton(
            tooltip: cluster ? 'Не группировать ноды' : 'Группировать ноды',
            icon: Icon(
              cluster ? Icons.workspaces : Icons.scatter_plot_outlined,
            ),
            onPressed: () => ref
                .read(databaseProvider)
                .setSetting(AppSettingKeys.mapCluster, '${!cluster}'),
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
              if (cluster)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    disableClusteringAtZoom: _focusZoom.toInt(),
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

/// Метка ноды: кружок в её цвет (как NodeAvatar в списке и чате). Своя —
/// с кольцом акцентного цвета, избранная — с кольцом и звёздочкой.
class _NodeMarker extends StatelessWidget {
  const _NodeMarker(this.p, {required this.onTap, this.highlight = false});

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
        ? scheme.secondary
        : scheme.surface;
    return Tooltip(
      message: p.mirrorOnly ? '${p.title} (зеркало)' : p.title,
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
                  border: Border.all(
                    color: ring,
                    width: highlight || p.isMe || p.isFavorite ? 3 : 2,
                  ),
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
                  size: size - (highlight || p.isMe || p.isFavorite ? 6 : 4),
                ),
              ),
              if (p.isFavorite)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Icon(Icons.star, size: 16, color: scheme.secondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Поиск ноды на карте; выбранная возвращается через Navigator.pop.
class _SearchSheet extends StatefulWidget {
  const _SearchSheet(this.points);

  final List<MapPoint> points;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final found = searchPoints(widget.points, _query);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tokens.s16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Имя или id ноды',
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: _query.trim().isEmpty
                  ? const SizedBox.shrink()
                  : found.isEmpty
                  ? const Center(child: Text('Не найдено среди нод на карте'))
                  : ListView(
                      children: [
                        for (final q in found)
                          ListTile(
                            leading: NodeAvatar(
                              nodeNum: q.num,
                              shortName: q.label,
                            ),
                            title: Text(q.title),
                            subtitle: Text(nodeIdString(q.num)),
                            onTap: () => Navigator.pop(context, q),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
