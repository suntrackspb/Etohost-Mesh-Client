import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshex/data/map_points.dart';
import 'package:meshex/features/home_widgets/widget_map_renderer.dart';

class CachedTiles extends TileProvider {
  CachedTiles(this.image);
  final ImageProvider image;
  int requests = 0;
  int cancellations = 0;
  @override
  bool get supportsCancelLoading => true;
  @override
  ImageProvider getImageWithCancelLoadingSupport(
    TileCoordinates coordinates,
    TileLayer options,
    Future<void> cancelLoading,
  ) {
    requests++;
    cancelLoading.then((_) => cancellations++);
    return image;
  }
}

void main() {
  testWidgets('widget map uses cancellable tile API and produces bounded PNG', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.white, BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(1, 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      picture.dispose();
      final tiles = CachedTiles(MemoryImage(bytes!.buffer.asUint8List()));
      final result = await renderWidgetMap(const [
        MapPoint(
          num: 1,
          lat: 59.94,
          lon: 30.31,
          label: 'N1',
          title: 'Node 1',
          isMe: true,
          isFavorite: false,
          stale: false,
          mirrorOnly: false,
        ),
      ], tiles);
      expect(result, isNotNull);
      expect(result!.length, greaterThan(100));
      expect(tiles.requests, greaterThan(0));
      await Future<void>.delayed(Duration.zero);
      expect(tiles.cancellations, tiles.requests);
      expect(await renderWidgetMap([], tiles), isEmpty);
    });
  });
}
