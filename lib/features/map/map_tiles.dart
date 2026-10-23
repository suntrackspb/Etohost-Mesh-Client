import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/providers.dart';
import '../../data/map_style.dart';
import '../../data/tile_cache.dart';

/// Центр карты, пока нет ни одной точки.
const defaultMapCenter = LatLng(59.94, 30.31);

/// Кэширующий прокси тайлов на нашем сервере (OSM и OpenTopoMap): быстрее
/// и работает там, где источник напрямую недоступен. Если он лежит —
/// тайлы идут напрямую (fallbackUrl). CARTO по их правилам проксировать
/// нельзя — он всегда напрямую.
const tileProxy = 'https://tiles.etohost.ru';

/// Каталог просмотренных тайлов (системный кэш приложения).
final tileCacheDirProvider = FutureProvider<Directory>(
  (ref) async =>
      Directory('${(await getApplicationCacheDirectory()).path}/tiles'),
);

/// Отдельный кэш для CARTO: им хранить тайлы можно не дольше 30 дней,
/// поэтому при запуске старше срока удаляются, а устаревшие без сети
/// не показываются.
final cartoTileProviderProvider = FutureProvider<TileProvider>((ref) async {
  final dir = Directory(
    '${(await ref.watch(tileCacheDirProvider.future)).path}/carto',
  );
  try {
    dropOlderThan(dir, cartoCacheMaxAge);
  } on FileSystemException {
    // Кэш недоступен — карта всё равно грузится из сети.
  }
  return CachedTileProvider(
    store: FileCacheStore(dir.path),
    cachePolicy: CachePolicy.request,
    maxStale: cartoCacheMaxAge,
  );
});

/// Тайлы через дисковый кэш: с сетью — по заголовкам сервера (устаревший
/// тайл перепроверяется, неизменный приходит ответом 304), без сети —
/// из кэша. При запуске кэш (вместе с CARTO) обрезается до
/// [tileCacheLimitBytes].
final tileProviderProvider = FutureProvider<TileProvider>((ref) async {
  final dir = await ref.watch(tileCacheDirProvider.future);
  try {
    trimTileCache(dir, tileCacheLimitBytes);
  } on FileSystemException {
    // Кэш недоступен — карта всё равно грузится из сети.
  }
  return CachedTileProvider(
    store: FileCacheStore('${dir.path}/common'),
    cachePolicy: CachePolicy.request,
    maxStale: tileCacheMaxStale,
  );
});

/// Подложка: OpenStreetMap, тёмная CARTO (если сборка с CARTO_KEY)
/// или рельеф OpenTopoMap.
class OsmTiles extends ConsumerWidget {
  const OsmTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = tileSource(
      ref.watch(mapStyleProvider).value ?? MapStyle.auto,
      Theme.of(context).brightness,
    );
    final cached = ref.watch(tileProviderProvider).value;
    final carto = ref.watch(cartoTileProviderProvider).value;
    // Правила OSM и OpenTopoMap требуют User-Agent приложения.
    return switch (source) {
      TileSource.carto => TileLayer(
        key: const ValueKey('carto'),
        urlTemplate:
            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
            '?key=$cartoKey',
        subdomains: const ['a', 'b', 'c', 'd'],
        maxZoom: 19,
        userAgentPackageName: 'ru.etohost.mesh',
        tileProvider: carto,
      ),
      // Тайлы есть до 17-го масштаба, дальше — растянутые.
      TileSource.topo => TileLayer(
        key: const ValueKey('topo'),
        urlTemplate: '$tileProxy/topo/{z}/{x}/{y}.png',
        fallbackUrl: 'https://a.tile.opentopomap.org/{z}/{x}/{y}.png',
        maxNativeZoom: 17,
        userAgentPackageName: 'ru.etohost.mesh',
        tileProvider: cached,
      ),
      TileSource.osm => TileLayer(
        key: const ValueKey('osm'),
        urlTemplate: '$tileProxy/osm/{z}/{x}/{y}.png',
        fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'ru.etohost.mesh',
        tileProvider: cached,
      ),
    };
  }
}

class OsmAttribution extends ConsumerWidget {
  const OsmAttribution({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = tileSource(
      ref.watch(mapStyleProvider).value ?? MapStyle.auto,
      Theme.of(context).brightness,
    );
    return SimpleAttributionWidget(
      source: Text(switch (source) {
        TileSource.carto => 'OpenStreetMap contributors © CARTO',
        TileSource.topo =>
          'OpenStreetMap contributors, SRTM © OpenTopoMap (CC-BY-SA)',
        TileSource.osm => 'OpenStreetMap contributors',
      }),
    );
  }
}
