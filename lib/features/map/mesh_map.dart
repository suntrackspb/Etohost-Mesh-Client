import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'map_tiles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'offline/offline_map_controller.dart';
import 'offline/offline_map_widgets.dart';

/// Сборка flutter_map: подложка, объекты приложения, атрибуция.
/// Слоты позволяют подключить локальную векторную подложку вместе
/// с её атрибуцией, не меняя прикладные слои на каждом экране.
class MeshMap extends ConsumerWidget {
  const MeshMap({
    super.key,
    this.mapController,
    required this.options,
    required this.children,
    this.basemap,
    this.attribution,
    this.compactAttribution = false,
  });

  final MapController? mapController;
  final MapOptions options;
  final List<Widget> children;
  final Widget? basemap;
  final Widget? attribution;
  final bool compactAttribution;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wait for the persisted choice before mounting any network tile layer.
    final choice = basemap == null
        ? ref.watch(offlineMapEnabledProvider)
        : null;
    final offline = choice?.value ?? false;
    final waiting = choice != null && !choice.hasValue;
    return FlutterMap(
      mapController: mapController,
      options: options,
      children: [
        basemap ??
            (waiting
                ? const ColoredBox(color: Color(0xFFF3F0E8))
                : offline
                ? const OfflineBasemap()
                : const OsmTiles()),
        ...children,
        if (offline) const OfflineCoverageNotice(),
        if (waiting)
          Center(
            child: choice.hasError
                ? const Text('Не удалось прочитать настройки карты')
                : const CircularProgressIndicator(),
          ),
        attribution ??
            (waiting
                ? const SizedBox.shrink()
                : offline
                ? OfflineMapAttribution(compact: compactAttribution)
                : OsmAttribution(compact: compactAttribution)),
      ],
    );
  }
}
