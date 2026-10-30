import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:meshex/features/map/offline/offline_map_controller.dart';

import 'package:meshex/features/map/offline/local_archive_client.dart';
import 'package:meshex/features/map/offline/offline_map_style.dart';
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late LocalArchiveClient client;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('local-map-test');
    final file = await File(
      '${dir.path}/map.pmtiles',
    ).writeAsBytes(List.generate(256, (i) => i));
    client = LocalArchiveClient(file);
  });
  tearDown(() async {
    client.close();
    await dir.delete(recursive: true);
  });

  test(
    'concurrent ranges read independent positions without a network',
    () async {
      final uri = Uri.parse('https://offline.invalid/map');
      final results = await Future.wait([
        client.get(uri, headers: {'range': 'bytes=20-29'}),
        client.get(uri, headers: {'Range': 'bytes=100-109'}),
        client.get(uri, headers: {'range': 'bytes=250-300'}),
      ]);
      expect(results[0].statusCode, 206);
      expect(results[0].bodyBytes, List.generate(10, (i) => i + 20));
      expect(results[1].bodyBytes, List.generate(10, (i) => i + 100));
      expect(results[2].bodyBytes, List.generate(6, (i) => i + 250));
      expect(
        (await client.get(uri, headers: {'range': 'bytes=256-300'})).statusCode,
        416,
      );
    },
  );

  test(
    'PMTiles provider reads a local archive and tile without HTTP',
    () async {
      // Minimal valid v3 archive: one uncompressed tile at z0, no leaves.
      final header = ByteData(127);
      final magic = 'PMTiles'.codeUnits;
      for (var i = 0; i < magic.length; i++) {
        header.setUint8(i, magic[i]);
      }
      header.setUint8(7, 3);
      // Directory: count, id delta, run length, content length, offset+1.
      const directory = [1, 0, 1, 3, 1];
      void u64(int offset, int value) =>
          header.setUint64(offset, value, Endian.little);
      u64(8, 127);
      u64(16, directory.length);
      u64(24, 132);
      u64(32, 0);
      u64(40, 132);
      u64(48, 0);
      u64(56, 132);
      u64(64, 3);
      u64(72, 1);
      u64(80, 1);
      u64(88, 1);
      header.setUint8(96, 1);
      header.setUint8(97, 1);
      header.setUint8(98, 1);
      header.setUint8(99, 1);
      final file = await File('${dir.path}/fixture.pmtiles').writeAsBytes([
        ...header.buffer.asUint8List(),
        ...directory,
        10,
        20,
        30,
      ]);
      final local = LocalArchiveClient(file);
      final provider = await vt.PmTilesVectorTileProvider.open(
        'https://offline.invalid/fixture',
        client: local,
        maxRetries: 0,
      );
      final tile = await provider.load(const vt.TileKey(0, 0, 0));
      expect(tile, isA<vt.TileResponseData>());
      expect((tile as vt.TileResponseData).bytes, [10, 20, 30]);
      provider.dispose();
      local.close();
    },
  );

  test(
    'download validation rejects truncation, corruption and cancellation',
    () async {
      final file = await File('${dir.path}/download.part').writeAsString('abc');
      const hash =
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';
      await validateOfflineArchive(
        file,
        expectedBytes: 3,
        expectedSha256: hash,
      );
      await expectLater(
        validateOfflineArchive(file, expectedBytes: 4, expectedSha256: hash),
        throwsFormatException,
      );
      await file.writeAsString('abd');
      await expectLater(
        validateOfflineArchive(file, expectedBytes: 3, expectedSha256: hash),
        throwsFormatException,
      );
      final cancel = CancelToken()..cancel();
      await expectLater(
        validateOfflineArchive(
          file,
          expectedBytes: 3,
          expectedSha256: hash,
          cancelToken: cancel,
        ),
        throwsFormatException,
      );
    },
  );

  test('both local styles parse without external resources', () {
    expect(
      const vt.ThemeReader().read(offlineMapStyle(false)).id,
      isNot(const vt.ThemeReader().read(offlineMapStyle(true)).id),
    );
    for (final dark in [false, true]) {
      final style = offlineMapStyle(dark);
      expect(() => const vt.ThemeReader().read(style), returnsNormally);
      expect(style.containsKey('glyphs'), isFalse);
      expect(style.containsKey('sprite'), isFalse);
    }
  });
}
