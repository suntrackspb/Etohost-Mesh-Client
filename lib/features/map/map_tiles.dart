import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../app/providers.dart';
import '../../data/map_style.dart';

/// Центр карты, пока нет ни одной точки.
const defaultMapCenter = LatLng(59.94, 30.31);

/// Подложка: OpenStreetMap или тёмная CARTO (если сборка с CARTO_KEY).
class OsmTiles extends ConsumerWidget {
  const OsmTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = darkTiles(
      ref.watch(mapStyleProvider).value ?? MapStyle.auto,
      Theme.of(context).brightness,
    );
    return dark
        ? TileLayer(
            key: const ValueKey('carto'),
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                '?key=$cartoKey',
            subdomains: const ['a', 'b', 'c', 'd'],
            maxZoom: 19,
            userAgentPackageName: 'ru.etohost.mesh',
          )
        // Правила OSM требуют User-Agent приложения.
        : TileLayer(
            key: const ValueKey('osm'),
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'ru.etohost.mesh',
          );
  }
}

class OsmAttribution extends ConsumerWidget {
  const OsmAttribution({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = darkTiles(
      ref.watch(mapStyleProvider).value ?? MapStyle.auto,
      Theme.of(context).brightness,
    );
    return SimpleAttributionWidget(
      source: Text(
        dark
            ? 'OpenStreetMap contributors © CARTO'
            : 'OpenStreetMap contributors',
      ),
    );
  }
}
