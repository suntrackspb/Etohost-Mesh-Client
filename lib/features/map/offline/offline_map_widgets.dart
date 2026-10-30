import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import 'offline_map_controller.dart';
import 'offline_map_style.dart';

class OfflineBasemap extends ConsumerWidget {
  const OfflineBasemap({super.key});
  static final _light = const vt.ThemeReader().read(offlineMapStyle(false));
  static final _dark = const vt.ThemeReader().read(offlineMapStyle(true));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final map = ref.watch(localVectorProvider);
    return map.when(
      data: (provider) => vt.VectorTileLayer(
        theme: Theme.of(context).brightness == Brightness.dark ? _dark : _light,
        tileProviders: vt.TileProviders({'basemap': provider}),
        diskCacheMaximumSizeInBytes: 0,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Не удалось открыть скачанную карту.'),
                TextButton(
                  onPressed: () => ref.invalidate(localVectorProvider),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OfflineMapAttribution extends StatelessWidget {
  const OfflineMapAttribution({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomRight,
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () =>
            launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            compact
                ? '© OpenStreetMap'
                : 'Офлайн · © OpenStreetMap contributors',
            style: TextStyle(fontSize: compact ? 10 : 11),
          ),
        ),
      ),
    ),
  );
}

/// Покрытие ограничено регионом; не подменяем отсутствующие данные сетью.
class OfflineCoverageNotice extends StatelessWidget {
  const OfflineCoverageNotice({super.key});
  @override
  Widget build(BuildContext context) {
    final center = MapCamera.of(context).center;
    final inside =
        center.latitude >= 59.03 &&
        center.latitude <= 60.84 &&
        center.longitude >= 28.49 &&
        center.longitude <= 32.14;
    if (inside) return const SizedBox.shrink();
    return const Align(
      alignment: Alignment.topCenter,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text('За пределами скачанной карты Петербурга'),
        ),
      ),
    );
  }
}

class OfflineMapSettings extends ConsumerWidget {
  const OfflineMapSettings({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final download = ref.watch(offlineMapDownloadProvider);
    final enabled = ref.watch(offlineMapEnabledProvider).value ?? false;
    final controller = ref.read(offlineMapDownloadProvider.notifier);
    return download.when(
      loading: () => const ListTile(
        title: Text('Офлайн-карта'),
        trailing: CircularProgressIndicator(),
      ),
      error: (_, _) => ListTile(
        title: const Text('Не удалось проверить офлайн-карту'),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(offlineMapDownloadProvider),
        ),
      ),
      data: (status) => Column(
        children: [
          ListTile(
            title: const Text('Петербург и окрестности'),
            subtitle: Text(
              status.busy
                  ? 'Скачано ${(status.received / 1000000).toStringAsFixed(1)} из 194 МБ'
                  : status.error ??
                        'Офлайн-карта · около 100 км · 194 МБ\nДанные от 29.10.2026',
            ),
            isThreeLine: !status.busy && status.error == null,
            trailing: status.busy
                ? IconButton(
                    tooltip: 'Отменить загрузку',
                    icon: const Icon(Icons.close),
                    onPressed: controller.cancel,
                  )
                : status.ready
                ? IconButton(
                    tooltip: 'Удалить карту',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: controller.remove,
                  )
                : IconButton(
                    tooltip: 'Скачать карту',
                    icon: const Icon(Icons.download),
                    onPressed: controller.download,
                  ),
          ),
          if (status.busy)
            LinearProgressIndicator(
              value: status.received >= offlineMapBytes
                  ? null
                  : status.received / offlineMapBytes,
            ),
          if (status.ready)
            SwitchListTile(
              title: const Text('Использовать скачанную карту'),
              subtitle: const Text(
                'Работает без сети. Онлайн-подложка отключена.',
              ),
              value: enabled,
              onChanged: (value) => ref
                  .read(databaseProvider)
                  .setSetting(offlineMapSetting, '$value'),
            ),
        ],
      ),
    );
  }
}
