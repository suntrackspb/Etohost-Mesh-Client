import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/node_actions.dart';
import '../../data/node_position.dart';
import '../../data/traceroute_view.dart';
import '../../ui/kit/kit.dart';
import '../map/map_tiles.dart';
import 'telemetry_ui.dart' show dateTimeText;

/// Цвета путей: туда — зелёный, обратно — синий.
const _towardsColor = Color(0xFF43A047);
const _backColor = Color(0xFF1E88E5);

/// Ноды по номеру — для имён и координат на маршруте.
Map<int, Node> _nodesByNum(WidgetRef ref) => {
  for (final n in ref.watch(nodesProvider).value ?? <Node>[]) n.num: n,
};

String _shortName(Map<int, Node> nodes, int num) {
  final n = nodes[num];
  return n == null || n.shortName.isEmpty ? nodeIdString(num) : n.shortName;
}

String _longName(Map<int, Node> nodes, int num) {
  final n = nodes[num];
  if (n == null) return nodeIdString(num);
  if (n.longName.isNotEmpty) return n.longName;
  return n.shortName.isNotEmpty ? n.shortName : nodeIdString(num);
}

/// Положение ноды на карте маршрута по общему правилу ([nodePosition]);
/// исправленное зеркалом — примерное (пунктир). Сюда же добавится оценка
/// положения нод без координат.
RoutePoint? routePoint(Node? n, {required PositionRules rules}) {
  final p = n == null ? null : nodePositionBy(n, rules);
  return p == null ? null : (lat: p.lat, lon: p.lon, approx: p.corrected);
}

/// Нужны ли часы: есть трассировка, ждущая ответа.
bool _needsClock(Iterable<TracerouteResult> l, DateTime now) =>
    l.any((r) => traceStatus(r, now) == TraceStatus.pending);

/// Блок карточки ноды: последняя трассировка и вход в журнал.
class TracerouteCard extends ConsumerWidget {
  const TracerouteCard(this.num, {super.key});

  final int num;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(tracerouteHistoryProvider(num)).value ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    var now = DateTime.now();
    if (_needsClock(list.take(1), now)) {
      now = ref.watch(clockProvider).value ?? now;
    }
    final last = list.first;
    final failed = traceStatus(last, now) == TraceStatus.noAnswer;
    return SectionCard(
      title: 'Трассировка маршрута',
      children: [
        MeshTile(
          title: dateTimeText(last.time),
          subtitle: traceSummary(last, now),
          trailing: Icon(
            failed ? Icons.portable_wifi_off : Icons.route,
            color: failed ? Theme.of(context).disabledColor : null,
          ),
          onTap: last.answered
              ? () => context.push(TraceroutePage.location(last.id))
              : null,
        ),
        if (list.length > 1)
          MeshTile(
            title: 'Журнал трассировки маршрута',
            subtitle: '${list.length}',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(TracerouteLogPage.location(num)),
          ),
      ],
    );
  }
}

/// Журнал трассировок до ноды: дата, до кого, итог.
class TracerouteLogPage extends ConsumerWidget {
  const TracerouteLogPage({super.key, required this.num});

  final int num;

  static String location(int num) => '/node/$num/traceroutes';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(tracerouteHistoryProvider(num)).value ?? const [];
    final nodes = _nodesByNum(ref);
    var now = DateTime.now();
    if (_needsClock(list, now)) now = ref.watch(clockProvider).value ?? now;
    return Scaffold(
      appBar: AppBar(title: const Text('Журнал трассировки маршрута')),
      body: list.isEmpty
          ? const EmptyState(icon: Icons.route, text: 'Трассировок нет')
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = list[i];
                return ListTile(
                  title: Text(
                    '${dateTimeText(r.time)} · ${_longName(nodes, r.target)}',
                  ),
                  subtitle: Text(traceSummary(r, now)),
                  trailing: r.answered ? const Icon(Icons.chevron_right) : null,
                  onTap: r.answered
                      ? () => context.push(TraceroutePage.location(r.id))
                      : null,
                );
              },
            ),
    );
  }
}

/// Подробности трассировки: сверху карта маршрута, ниже пути списком.
class TraceroutePage extends ConsumerWidget {
  const TraceroutePage({super.key, required this.id});

  final int id;

  static String location(int id) => '/traceroute/$id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(tracerouteProvider(id)).value;
    final nodes = _nodesByNum(ref);
    if (r == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.route,
          text: 'Трассировка не найдена',
        ),
      );
    }
    final now = DateTime.now();
    final h = MediaQuery.sizeOf(context).height;
    final c = ref.watch(positionRulesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_longName(nodes, r.target))),
      body: Column(
        children: [
          if (r.answered)
            SizedBox(height: h * 0.42, child: _RouteMap(r, nodes, c)),
          Expanded(
            child: ListView(
              padding: pagePadding(context),
              children: [
                Text(
                  '${dateTimeText(r.time)} · ${traceSummary(r, now)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (!r.answered)
                  const Padding(
                    padding: EdgeInsets.only(top: Tokens.s8),
                    child: Text(
                      'Был отправлен запрос трассировки маршрута, '
                      'ответа получено не было.',
                    ),
                  ),
                if (r.towards.isNotEmpty)
                  _PathBlock('Маршрут', _towardsColor, r.towards, nodes, c),
                if (r.back.isNotEmpty)
                  _PathBlock('Маршрут обратно', _backColor, r.back, nodes, c),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Путь списком: цепочка нод, у каждой — SNR приёма и пометка «нет
/// координат».
class _PathBlock extends StatelessWidget {
  const _PathBlock(
    this.title,
    this.color,
    this.path,
    this.nodes,
    this.correction,
  );

  final String title;
  final Color color;
  final List<Hop> path;
  final Map<int, Node> nodes;
  final PositionRules correction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final muted = Theme.of(context).disabledColor;
    return Padding(
      padding: const EdgeInsets.only(top: Tokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 16, height: 4, color: color),
              const SizedBox(width: Tokens.s8),
              Text('$title · ${hopsText(path)}', style: t.titleSmall),
            ],
          ),
          const SizedBox(height: Tokens.s4),
          for (final hop in path)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: color),
                  const SizedBox(width: Tokens.s8),
                  Expanded(
                    child: Text(
                      _longName(nodes, hop.num),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (routePoint(nodes[hop.num], rules: correction) == null)
                    Padding(
                      padding: const EdgeInsets.only(right: Tokens.s8),
                      child: Icon(Icons.location_off, size: 14, color: muted),
                    ),
                  if (hop.snr != null)
                    Text(
                      '${hop.snr!.toStringAsFixed(1)} дБ',
                      style: t.bodySmall,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Карта маршрута: туда — зелёная линия, обратно — синяя; общие отрезки
/// раздвинуты; через ноды без координат — пунктир с числом пропущенных.
class _RouteMap extends StatelessWidget {
  const _RouteMap(this.r, this.nodes, this.correction);

  final TracerouteResult r;
  final Map<int, Node> nodes;
  final PositionRules correction;

  @override
  Widget build(BuildContext context) {
    RoutePoint? pos(int num) => routePoint(nodes[num], rules: correction);
    final towards = routeLegs(r.towards, pos);
    final back = routeLegs(r.back, pos);
    final pts = <int, RoutePoint>{
      for (final h in [...r.towards, ...r.back]) h.num: ?pos(h.num),
    };
    if (pts.isEmpty) {
      return const EmptyState(
        icon: Icons.location_off,
        text: 'Ни у одной ноды маршрута нет координат',
      );
    }
    final lls = [for (final p in pts.values) LatLng(p.lat, p.lon)];
    final distinct = lls.toSet().length > 1;
    return FlutterMap(
      options: MapOptions(
        initialCenter: lls.first,
        initialZoom: 12,
        initialCameraFit: distinct
            ? CameraFit.coordinates(
                coordinates: lls,
                padding: const EdgeInsets.all(40),
              )
            : null,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        const OsmTiles(),
        _LegsLayer(towards: towards, back: back),
        MarkerLayer(
          markers: [
            for (final MapEntry(key: num, value: p) in pts.entries)
              Marker(
                point: LatLng(p.lat, p.lon),
                width: 64,
                height: 22,
                child: _NodeChip(
                  _shortName(nodes, num),
                  end: num == r.target || num == r.towards.first.num,
                ),
              ),
            for (final l in [...towards, ...back])
              if (l.skipped > 0)
                Marker(
                  point: LatLng(
                    (l.a.lat + l.b.lat) / 2,
                    (l.a.lon + l.b.lon) / 2,
                  ),
                  width: 96,
                  height: 18,
                  child: _SkippedChip(l.skipped),
                ),
          ],
        ),
        const OsmAttribution(compact: true),
      ],
    );
  }
}

/// Линии путей. Сдвиг общих отрезков считается в пикселях текущего
/// масштаба, поэтому слой перестраивается при движении карты.
class _LegsLayer extends StatelessWidget {
  const _LegsLayer({required this.towards, required this.back});

  final List<RouteLeg> towards;
  final List<RouteLeg> back;

  /// Половина расстояния между встречными линиями, px.
  static const _gap = 3.0;

  @override
  Widget build(BuildContext context) {
    final cam = MapCamera.of(context);
    final shared = sharedLegs(towards, back);
    Polyline line(RouteLeg l, Color color) {
      var a = LatLng(l.a.lat, l.a.lon), b = LatLng(l.b.lat, l.b.lon);
      if (isShared(l, shared)) {
        final pa = cam.crs.latLngToOffset(a, cam.zoom);
        final pb = cam.crs.latLngToOffset(b, cam.zoom);
        final (sa, sb) = shiftSegment((pa.dx, pa.dy), (pb.dx, pb.dy), _gap);
        a = cam.crs.offsetToLatLng(Offset(sa.$1, sa.$2), cam.zoom);
        b = cam.crs.offsetToLatLng(Offset(sb.$1, sb.$2), cam.zoom);
      }
      final dashed = l.skipped > 0 || l.a.approx || l.b.approx;
      return Polyline(
        points: [a, b],
        color: color,
        strokeWidth: 3,
        pattern: dashed
            ? StrokePattern.dashed(segments: const [8, 6])
            : const StrokePattern.solid(),
      );
    }

    return PolylineLayer(
      polylines: [
        for (final l in towards) line(l, _towardsColor),
        for (final l in back) line(l, _backColor),
      ],
    );
  }
}

class _NodeChip extends StatelessWidget {
  const _NodeChip(this.name, {this.end = false});

  final String name;

  /// Начало или конец маршрута — выделяем.
  final bool end;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: end ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.primary),
        ),
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: end ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _SkippedChip extends StatelessWidget {
  const _SkippedChip(this.n);

  final int n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('пропущено $n', style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}
