import 'dart:io';

import 'package:cryptography/dart.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:path_provider/path_provider.dart';

import '../../../app/providers.dart';
import 'local_archive_client.dart';

const offlineMapUrl = 'https://etohost.ru/maps/spb-20261029.pmtiles';
const offlineMapBytes = 194118834;
const offlineMapSha256 =
    '95ddcce9bc26b46e6dc72acc55e8f79742af53ed433ef067a6e9d873c364c955';
const offlineMapSetting = 'map.offline.spb.enabled';

final offlineMapEnabledProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(databaseProvider)
      .watchSetting(offlineMapSetting)
      .map((value) => value == 'true'),
);

final offlineMapFileProvider = FutureProvider<File>((ref) async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/offline-maps/spb-20261029.pmtiles');
});

class OfflineMapDownload {
  const OfflineMapDownload({
    this.ready = false,
    this.busy = false,
    this.received = 0,
    this.error,
  });
  final bool ready;
  final bool busy;
  final int received;
  final String? error;
}

final offlineMapDownloadProvider =
    AsyncNotifierProvider<OfflineMapController, OfflineMapDownload>(
      OfflineMapController.new,
    );

class OfflineMapController extends AsyncNotifier<OfflineMapDownload> {
  CancelToken? _cancel;

  @override
  Future<OfflineMapDownload> build() async {
    final file = await ref.watch(offlineMapFileProvider.future);
    ref.onDispose(() => _cancel?.cancel());
    return OfflineMapDownload(
      ready: await file.exists() && await file.length() == offlineMapBytes,
    );
  }

  void cancel() => _cancel?.cancel();

  Future<void> download() async {
    if (state.value?.busy ?? true) return;
    state = const AsyncData(OfflineMapDownload(busy: true));
    final file = await ref.read(offlineMapFileProvider.future);
    final part = File('${file.path}.part');
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    _cancel = CancelToken();
    state = const AsyncData(OfflineMapDownload(busy: true));
    var reported = 0;
    try {
      await file.parent.create(recursive: true);
      await dio.download(
        offlineMapUrl,
        part.path,
        cancelToken: _cancel,
        onReceiveProgress: (received, _) {
          if (received - reported >= 500000 || received == offlineMapBytes) {
            reported = received;
            state = AsyncData(
              OfflineMapDownload(busy: true, received: received),
            );
          }
        },
      );
      await validateOfflineArchive(part, cancelToken: _cancel);
      await part.rename(file.path);
      ref.invalidate(localVectorProvider);
      await ref.read(databaseProvider).setSetting(offlineMapSetting, 'true');
      state = const AsyncData(OfflineMapDownload(ready: true));
    } catch (error) {
      if (await part.exists()) await part.delete();
      state = AsyncData(
        OfflineMapDownload(
          ready: await file.exists() && await file.length() == offlineMapBytes,
          error: _cancel!.isCancelled
              ? null
              : 'Не удалось скачать карту. Проверьте сеть и повторите.',
        ),
      );
    } finally {
      dio.close(force: true);
      _cancel = null;
    }
  }

  Future<void> remove() async {
    if (state.value?.busy ?? true) return;
    await ref.read(databaseProvider).setSetting(offlineMapSetting, 'false');
    ref.invalidate(localVectorProvider);
    final file = await ref.read(offlineMapFileProvider.future);
    if (await file.exists()) await file.delete();
    state = const AsyncData(OfflineMapDownload());
  }
}

final localVectorProvider = FutureProvider.autoDispose<vt.VectorTileProvider>((
  ref,
) async {
  final file = await ref.watch(offlineMapFileProvider.future);
  final client = LocalArchiveClient(file);
  vt.PmTilesVectorTileProvider? provider;
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
    provider?.dispose();
    client.close();
  });
  try {
    provider = await vt.PmTilesVectorTileProvider.open(
      'https://offline.invalid/spb-20261029.pmtiles',
      client: client,
      maxRetries: 0,
    );
    if (disposed) {
      provider.dispose();
      throw StateError('Map closed');
    }
    return LocalVectorArchive(provider);
  } catch (_) {
    client.close();
    rethrow;
  }
});

/// Проверка до публикации .part как готовой карты; хеш считается потоком.
Future<void> validateOfflineArchive(
  File file, {
  int expectedBytes = offlineMapBytes,
  String expectedSha256 = offlineMapSha256,
  CancelToken? cancelToken,
}) async {
  if (await file.length() != expectedBytes) {
    throw const FormatException('Размер карты не совпал');
  }
  final sink = const DartSha256().newHashSink();
  await for (final chunk in file.openRead()) {
    if (cancelToken?.isCancelled ?? false) {
      throw const FormatException('Загрузка отменена');
    }
    sink.add(chunk);
  }
  sink.close();
  final hash = await sink.hash();
  final hex = hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  if (hex != expectedSha256) {
    throw const FormatException('Контрольная сумма карты не совпала');
  }
  if (cancelToken?.isCancelled ?? false) {
    throw const FormatException('Загрузка отменена');
  }
}

/// Локальный архив уже хранит тайлы; не дублируем их в дисковом кэше.
class LocalVectorArchive extends vt.VectorTileProvider {
  LocalVectorArchive(this.archive);
  final vt.PmTilesVectorTileProvider archive;
  @override
  int get minimumZoom => archive.minimumZoom;
  @override
  int get maximumZoom => archive.maximumZoom;
  @override
  String get cacheKey => archive.cacheKey;
  @override
  bool get cacheBytesToDisk => false;
  @override
  Future<vt.TileResponse> load(
    vt.TileKey tile, {
    vt.CancellationToken? cancellation,
  }) => archive.load(tile, cancellation: cancellation);
  @override
  void dispose() => archive.dispose();
}
