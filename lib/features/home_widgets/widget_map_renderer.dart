import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../data/map_points.dart';
import '../../ui/tokens.dart';

/// Uses the app's cached tile provider. No location is sent to a static-map API.
Future<Uint8List?> renderWidgetMap(
  List<MapPoint> points,
  TileProvider tiles, {
  List<int> route = const [],
}) async {
  if (points.isEmpty) return Uint8List(0);
  const width = 480.0, height = 270.0;
  Offset project(MapPoint p) {
    final lat = p.lat.clamp(-85.0511, 85.0511) * math.pi / 180;
    return Offset(
      (p.lon + 180) / 360,
      (1 - math.log(math.tan(lat) + 1 / math.cos(lat)) / math.pi) / 2,
    );
  }

  final origin = project(points.first).dx;
  Offset wrapped(MapPoint p) {
    final v = project(p);
    var x = v.dx;
    if (x - origin > .5) x -= 1;
    if (x - origin < -.5) x += 1;
    return Offset(x, v.dy);
  }

  final positions = {for (final p in points) p.num: wrapped(p)};
  final xs = positions.values.map((p) => p.dx),
      ys = positions.values.map((p) => p.dy);
  final left = xs.reduce(math.min), right = xs.reduce(math.max);
  final top = ys.reduce(math.min), bottom = ys.reduce(math.max);
  final zoom =
      (math.log(
                math.min(
                      (width - 80) / math.max(right - left, .00001),
                      (height - 80) / math.max(bottom - top, .00001),
                    ) /
                    256,
              ) /
              math.ln2)
          .floor()
          .clamp(1, 14);
  final scale = 256.0 * (1 << zoom);
  final center = Offset((left + right) / 2, (top + bottom) / 2) * scale;
  final start = center - const Offset(width / 2, height / 2);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawColor(const Color(0xFFE7EBF0), BlendMode.src);
  final layer = TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'ru.meshex.app',
    tileProvider: tiles,
  );
  var loaded = 0;
  for (
    var y = (start.dy / 256).floor();
    y <= ((start.dy + height) / 256).floor();
    y++
  ) {
    for (
      var x = (start.dx / 256).floor();
      x <= ((start.dx + width) / 256).floor();
      x++
    ) {
      if (y < 0 || y >= 1 << zoom) continue;
      final cancel = Completer<void>();
      try {
        final coordinates = TileCoordinates(x % (1 << zoom), y, zoom);
        final image = await _resolve(
          tiles.supportsCancelLoading
              ? tiles.getImageWithCancelLoadingSupport(
                  coordinates,
                  layer,
                  cancel.future,
                )
              : tiles.getImage(coordinates, layer),
        );
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(x * 256 - start.dx, y * 256 - start.dy, 256, 256),
          Paint(),
        );
        image.dispose();
        loaded++;
      } catch (_) {
        /* Missing offline tile: retain neutral background. */
      } finally {
        cancel.complete();
      }
    }
  }
  // Do not replace the last useful map with an image missing its entire basemap.
  if (loaded == 0) {
    recorder.endRecording().dispose();
    return null;
  }
  Offset screen(int num) => positions[num]! * scale - start;
  if (route.isNotEmpty) {
    for (var i = 1; i < route.length; i++) {
      if (!positions.containsKey(route[i - 1]) ||
          !positions.containsKey(route[i])) {
        continue;
      }
      canvas.drawLine(
        screen(route[i - 1]),
        screen(route[i]),
        Paint()
          ..color = Tokens.purple
          ..strokeWidth = 4,
      );
    }
  }
  for (final p in points) {
    final pos = screen(p.num);
    canvas.drawCircle(pos, 10, Paint()..color = Colors.white);
    canvas.drawCircle(
      pos,
      7,
      Paint()..color = p.isMe ? Tokens.pink : Tokens.blue,
    );
    final text = TextPainter(
      text: TextSpan(
        text: p.label,
        style: const TextStyle(
          color: Color(0xFF15161B),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 100);
    text.paint(canvas, pos + const Offset(12, -8));
  }
  final attribution = TextPainter(
    text: const TextSpan(
      text: '© OpenStreetMap contributors',
      style: TextStyle(
        color: Colors.black,
        fontSize: 12,
        backgroundColor: Colors.white,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  attribution.paint(canvas, Offset(width - attribution.width - 5, height - 19));
  final picture = recorder.endRecording();
  final image = await picture.toImage(width.toInt(), height.toInt());
  picture.dispose();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes?.buffer.asUint8List();
}

Future<ui.Image> _resolve(ImageProvider provider) async {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      if (!completer.isCompleted) completer.complete(info.image.clone());
    },
    onError: (Object error, StackTrace? stack) {
      if (!completer.isCompleted) completer.completeError(error, stack);
    },
  );
  stream.addListener(listener);
  try {
    return await completer.future.timeout(const Duration(seconds: 3));
  } finally {
    stream.removeListener(listener);
  }
}
