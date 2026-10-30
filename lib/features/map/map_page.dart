import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../app/link_badge.dart';
import '../../app/providers.dart';
import '../../data/database.dart';
import '../../data/map_points.dart';
import '../../data/map_style.dart';
import '../../core/proto/mesh.dart';
import '../../ui/kit/kit.dart';
import '../nodes/open_node.dart';
import '../nodes/node_filter_sheet.dart';
import 'map_tiles.dart';
import 'offline/offline_map_controller.dart';
import 'offline/offline_map_widgets.dart';
import 'mesh_map.dart';
import 'flutter_mesh_layers.dart';
import '../../data/map_scene.dart';
import '../../data/node_position.dart';

/// Карта нод (OSM). Фильтр общий со списком нод.
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final _map = MapController();

  void _zoomBy(double delta) {
    final cam = _map.camera;
    _map.move(cam.center, (cam.zoom + delta).clamp(2, 19));
  }

  bool _ready = false;
  bool _fitted = false;

  /// Найденная поиском нода — подсвечена несколько секунд.
  int? _found;
  Timer? _foundTimer;

  /// Масштаб, с которого ноды не группируются; поиск приближает до него.
  static const _focusZoom = meshFocusZoom;

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
    _focus(p);
  }

  /// Показать точку крупно и подсветить на несколько секунд.
  void _focus(MapPoint p) {
    _map.move(LatLng(p.lat, p.lon), _focusZoom);
    _foundTimer?.cancel();
    setState(() => _found = p.num);
    _foundTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _found = null);
    });
  }

  /// Поворот карты, градусы (для кнопки «север сверху»).
  double _rotation = 0;
  bool _circles = false;

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
    }, radius: MeshNodeMarker.size / 2);
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
    // «Перейти к ноде» из карточки: центрируем, когда карта готова.
    final focus = ref.watch(mapFocusProvider);
    if (focus != null && _ready) {
      final p = points.where((p) => p.num == focus).firstOrNull;
      if (p != null) {
        // Иначе первый «показать все» ниже перебьёт приближение.
        _fitted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(mapFocusProvider.notifier).state = null;
          _focus(p);
        });
      }
    }
    final filter = ref.watch(nodeFilterProvider);
    final query = filter.query.trim();
    // Поиск из списка нод действует и на карте — значок и плашка об этом.
    final filtered = filter.active || query.isNotEmpty;
    final me = points.where((p) => p.isMe).firstOrNull;
    final rotate = ref.watch(mapRotateProvider).value ?? false;
    final area = ref.watch(nodeAreaProvider);
    final cluster = ref.watch(mapClusterProvider).value ?? true;
    final precision = ref.watch(mapPrecisionProvider).value ?? false;
    // Вращение выключили — вернуть север наверх.
    if (!rotate && _rotation != 0 && _ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _map.rotate(0));
    }
    // Первое появление точек — показать все.
    if (!_fitted && focus == null && points.isNotEmpty && _ready) {
      _fitted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitAll(points));
    }

    final scene = MeshMapScene(
      points: points,
      area: area,
      cluster: cluster,
      showPrecision: precision,
      highlightedNode: _found,
    );

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
          _LayersMenu(cluster: cluster),
          const LinkBadge(),
        ],
      ),
      body: Stack(
        children: [
          MeshMap(
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
                final circles = showPrecisionCircles(cam.zoom);
                if (circles != _circles) {
                  setState(() => _circles = circles);
                }
                if ((cam.rotation - _rotation).abs() > 0.5 ||
                    (cam.rotation == 0) != (_rotation == 0)) {
                  setState(() => _rotation = cam.rotation);
                }
              },
            ),
            children: [
              ...flutterMeshLayers(
                context,
                scene: scene,
                zoom: _ready ? _map.camera.zoom : 9,
                onNodeTap: (p) => _tap(points, p),
              ),
            ],
          ),
          // Запасной способ масштаба: одной рукой, с мыши, в симуляторе.
          Positioned(
            right: Tokens.s16,
            bottom: 56, // над строкой атрибуции OSM
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (me != null) ...[
                  FloatingActionButton.small(
                    heroTag: 'myNode',
                    tooltip: 'Моя нода',
                    onPressed: () => _map.move(LatLng(me.lat, me.lon), 14),
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: Tokens.s8),
                ],
                FloatingActionButton.small(
                  heroTag: 'fitAll',
                  tooltip: 'Показать все',
                  onPressed: points.isEmpty ? null : () => _fitAll(points),
                  child: const Icon(Icons.zoom_out_map),
                ),
                const SizedBox(height: Tokens.s16),
                FloatingActionButton.small(
                  heroTag: 'zoomIn',
                  tooltip: 'Приблизить',
                  onPressed: () => _zoomBy(1),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: Tokens.s8),
                FloatingActionButton.small(
                  heroTag: 'zoomOut',
                  tooltip: 'Отдалить',
                  onPressed: () => _zoomBy(-1),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
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
          if (query.isNotEmpty)
            Positioned(
              left: Tokens.s16,
              top: Tokens.s16,
              child: InputChip(
                avatar: const Icon(Icons.search, size: 18),
                label: Text('Поиск: $query'),
                tooltip: 'Поиск из списка нод',
                deleteButtonTooltipMessage: 'Показать все ноды',
                onDeleted: () => ref.read(nodeFilterProvider.notifier).state =
                    filter.copyWith(query: ''),
              ),
            ),
          if (points.isEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: Card(
                // Под плашкой поиска, если она есть.
                margin: EdgeInsets.fromLTRB(
                  Tokens.s16,
                  query.isEmpty ? Tokens.s16 : 72,
                  Tokens.s16,
                  Tokens.s16,
                ),
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

/// «Слои»: подложка и группировка нод — то, что меняют редко.
class _LayersMenu extends ConsumerWidget {
  const _LayersMenu({required this.cluster});
  final bool cluster;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(mapStyleProvider).value ?? MapStyle.auto;
    final offline = ref.watch(offlineMapEnabledProvider).value ?? false;
    final correction = ref.watch(positionCorrectionProvider).value ?? false;
    final precision = ref.watch(mapPrecisionProvider).value ?? false;
    final db = ref.read(databaseProvider);
    return PopupMenuButton<Object>(
      tooltip: 'Слои',
      icon: const Icon(Icons.layers_outlined),
      onSelected: (v) => switch (v) {
        MapStyle s => db.setSetting(AppSettingKeys.mapStyle, s.name),
        #offline => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: OfflineMapSettings(),
            ),
          ),
        ),
        #correction => db.setSetting(
          AppSettingKeys.mapCorrection,
          '${!correction}',
        ),
        #precision => db.setSetting(
          AppSettingKeys.mapPrecision,
          '${!precision}',
        ),
        _ => db.setSetting(AppSettingKeys.mapCluster, '${!cluster}'),
      },
      itemBuilder: (_) => [
        ...[
          for (final s in offline ? <MapStyle>[] : availableMapStyles())
            CheckedPopupMenuItem<Object>(
              value: s,
              checked: s == style,
              child: Text(s.label),
            ),
          PopupMenuItem<Object>(
            value: #offline,
            child: Text(
              (ref.watch(offlineMapEnabledProvider).value ?? false)
                  ? 'Офлайн-карта включена'
                  : 'Офлайн-карта…',
            ),
          ),
          const PopupMenuDivider(),
        ],
        CheckedPopupMenuItem<Object>(
          value: #cluster,
          checked: cluster,
          child: const Text('Группировать ноды'),
        ),
        CheckedPopupMenuItem<Object>(
          value: #correction,
          checked: correction,
          child: const Text('Корректировка позиций'),
        ),
        CheckedPopupMenuItem<Object>(
          value: #precision,
          checked: precision,
          child: const Text('Точность позиций'),
        ),
      ],
    );
  }
}
