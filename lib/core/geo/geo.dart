import 'dart:math';

/// Точка на Земле (градусы).
typedef LatLon = ({double lat, double lon});

const _earthKm = 6371.0088;

double _rad(double d) => d * pi / 180;

/// Расстояние по большому кругу (гаверсинус), км.
double distanceKm(LatLon a, LatLon b) {
  final dLat = _rad(b.lat - a.lat);
  final dLon = _rad(b.lon - a.lon);
  final h =
      pow(sin(dLat / 2), 2) +
      cos(_rad(a.lat)) * cos(_rad(b.lat)) * pow(sin(dLon / 2), 2);
  return 2 * _earthKm * asin(min(1, sqrt(h)));
}

/// Азимут из [a] на [b], 0–360°, 0 — север.
double bearingDeg(LatLon a, LatLon b) {
  final y = sin(_rad(b.lon - a.lon)) * cos(_rad(b.lat));
  final x =
      cos(_rad(a.lat)) * sin(_rad(b.lat)) -
      sin(_rad(a.lat)) * cos(_rad(b.lat)) * cos(_rad(b.lon - a.lon));
  return (atan2(y, x) * 180 / pi + 360) % 360;
}

/// «850 м», «12,4 км», «130 км».
String distanceText(double km) {
  if (km < 1) return '${(km * 1000).round()} м';
  if (km < 100) return '${km.toStringAsFixed(1).replaceAll('.', ',')} км';
  return '${km.round()} км';
}

/// «59.93901, 30.31586» → точка; иначе null.
LatLon? parseLatLon(String? s) {
  final p = s?.split(',');
  if (p == null || p.length != 2) return null;
  final lat = double.tryParse(p[0].trim());
  final lon = double.tryParse(p[1].trim());
  if (lat == null || lon == null || lat.abs() > 90 || lon.abs() > 180) {
    return null;
  }
  return (lat: lat, lon: lon);
}

String formatLatLon(LatLon p) =>
    '${p.lat.toStringAsFixed(5)}, ${p.lon.toStringAsFixed(5)}';
