import 'package:flutter/foundation.dart';

/// Ссылка «Открыть в Картах» под платформу: Android — `geo:` (откроет
/// Google Maps или выбор приложения карт), Apple — Apple Maps,
/// остальные — Google Maps в браузере.
Uri mapsUri(double lat, double lon, TargetPlatform platform) =>
    switch (platform) {
      TargetPlatform.android => Uri.parse('geo:$lat,$lon?q=$lat,$lon'),
      TargetPlatform.iOS ||
      TargetPlatform.macOS => Uri.parse('https://maps.apple.com/?q=$lat,$lon'),
      _ => Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
      ),
    };
