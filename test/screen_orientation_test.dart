import 'package:etohost_mesh/data/screen_orientation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse: unknown is auto', () {
    expect(
      ScreenOrientation.parse('portraitDown'),
      ScreenOrientation.portraitDown,
    );
    expect(ScreenOrientation.parse(null), ScreenOrientation.auto);
    expect(ScreenOrientation.parse('мусор'), ScreenOrientation.auto);
  });

  test('auto follows the sensor, fixed ones lock a single orientation', () {
    expect(ScreenOrientation.auto.preferred, isEmpty);
    expect(ScreenOrientation.portrait.preferred, [
      DeviceOrientation.portraitUp,
    ]);
    expect(ScreenOrientation.landscapeDown.preferred, [
      DeviceOrientation.landscapeRight,
    ]);
    final fixed = ScreenOrientation.values.skip(1).map((o) => o.device);
    expect(fixed.toSet(), hasLength(4));
  });
}
