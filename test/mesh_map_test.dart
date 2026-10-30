import 'package:meshex/data/map_points.dart';
import 'package:meshex/data/map_scene.dart';
import 'package:meshex/features/map/flutter_mesh_layers.dart';
import 'package:meshex/features/map/mesh_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meshex/features/map/map_tiles.dart';
import 'package:meshex/features/map/offline/offline_map_controller.dart';
import 'package:meshex/features/map/offline/offline_map_widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const point = MapPoint(
    num: 1,
    lat: 59.94,
    lon: 30.31,
    label: 'A',
    title: 'Test node',
    isMe: false,
    isFavorite: false,
    stale: false,
    mirrorOnly: false,
    precisionMeters: 100,
  );

  testWidgets('custom basemap keeps node selection and attribution', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => MeshMap(
              options: const MapOptions(
                initialCenter: LatLng(59.94, 30.31),
                initialZoom: 16,
              ),
              basemap: const ColoredBox(color: Colors.white),
              attribution: const Text('Local map'),
              children: flutterMeshLayers(
                context,
                scene: MeshMapScene(points: [point], cluster: false),
                zoom: 16,
                onNodeTap: (p) => selected = p.num,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(MeshNodeMarker), findsOneWidget);
    expect(find.text('Local map'), findsOneWidget);
    await tester.tap(find.byType(MeshNodeMarker));
    expect(selected, 1);
  });

  testWidgets('waits for persisted choice before mounting network tiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          offlineMapEnabledProvider.overrideWith(
            (ref) => const Stream<bool>.empty(),
          ),
        ],
        child: const MaterialApp(
          home: MeshMap(options: MapOptions(), children: []),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(OsmTiles), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('broken offline map never silently falls back to network', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          offlineMapEnabledProvider.overrideWith((ref) => Stream.value(true)),
          localVectorProvider.overrideWith(
            (ref) async => throw StateError('missing archive'),
          ),
        ],
        child: const MaterialApp(
          home: MeshMap(options: MapOptions(), children: []),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OfflineBasemap), findsOneWidget);
    expect(find.byType(OsmTiles), findsNothing);
    expect(find.text('Не удалось открыть скачанную карту.'), findsOneWidget);
  });

  testWidgets('precision overlay follows scene setting and zoom', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    List<Widget> layers(bool enabled, double zoom) => flutterMeshLayers(
      context,
      scene: MeshMapScene(points: [point], showPrecision: enabled),
      zoom: zoom,
      onNodeTap: (_) {},
    );
    expect(layers(false, 18).whereType<PolygonLayer>(), isEmpty);
    expect(layers(true, 2).whereType<PolygonLayer>(), isEmpty);
    expect(layers(true, 18).whereType<PolygonLayer>(), hasLength(1));
  });
}
