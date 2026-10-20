import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Центр карты, пока нет ни одной точки.
const defaultMapCenter = LatLng(59.94, 30.31);

/// Подложка OpenStreetMap (правила OSM требуют User-Agent приложения).
class OsmTiles extends StatelessWidget {
  const OsmTiles({super.key});

  @override
  Widget build(BuildContext context) => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'ru.etohost.mesh',
  );
}

class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key});

  @override
  Widget build(BuildContext context) =>
      const SimpleAttributionWidget(source: Text('OpenStreetMap contributors'));
}
