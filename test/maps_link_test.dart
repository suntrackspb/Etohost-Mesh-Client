import 'package:meshex/core/geo/maps_link.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ссылка на карты под платформу', () {
    expect(
      mapsUri(59.9, 30.3, TargetPlatform.android).toString(),
      'geo:59.9,30.3?q=59.9,30.3',
    );
    expect(mapsUri(59.9, 30.3, TargetPlatform.iOS).host, 'maps.apple.com');
    expect(mapsUri(59.9, 30.3, TargetPlatform.windows).host, 'www.google.com');
  });
}
