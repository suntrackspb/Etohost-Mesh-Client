import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../app/providers.dart';
import '../../core/geo/geo.dart';
import '../../data/database.dart';
import '../map/map_tiles.dart';
import '../../app/link_badge.dart';

/// Выбор центра области на карте: центр — под перекрестием.
class AreaPickerPage extends ConsumerStatefulWidget {
  const AreaPickerPage({super.key});

  @override
  ConsumerState<AreaPickerPage> createState() => _AreaPickerPageState();
}

class _AreaPickerPageState extends ConsumerState<AreaPickerPage> {
  final _map = MapController();
  LatLng? _center;

  LatLng _initial() {
    final c = ref.read(areaCenterProvider).value;
    if (c != null) return LatLng(c.lat, c.lon);
    final me = ref.read(mapPointsProvider).where((p) => p.isMe).firstOrNull;
    if (me != null) return LatLng(me.lat, me.lon);
    return defaultMapCenter;
  }

  @override
  Widget build(BuildContext context) {
    final km = ref.watch(areaRadiusProvider).value ?? defaultAreaRadiusKm;
    final center = _center ??= _initial();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Центр области'),
        actions: [
          TextButton(
            onPressed: () async {
              await saveSetting(
                ref,
                AppSettingKeys.areaCenter,
                formatLatLon((lat: center.latitude, lon: center.longitude)),
              );
              if (context.mounted) context.pop();
            },
            child: const Text('Готово'),
          ),
          const LinkBadge(),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 7,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onPositionChanged: (cam, _) =>
                  setState(() => _center = cam.center),
            ),
            children: [
              const OsmTiles(),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: center,
                    radius: km * 1000,
                    useRadiusInMeter: true,
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderColor: scheme.primary,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              const OsmAttribution(),
            ],
          ),
          IgnorePointer(
            child: Icon(Icons.add, size: 36, color: scheme.primary),
          ),
          Positioned(
            bottom: 32,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  '${formatLatLon((lat: center.latitude, lon: center.longitude))}'
                  ' · радиус ${distanceText(km)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
