import 'dart:io';

import 'package:etohost_mesh/core/diagnostics/device_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('модель устройства через sysctl', () async {
    final m = await deviceModel();
    expect(m, isNotNull);
    expect(m, isNotEmpty);
  }, skip: !Platform.isMacOS);
}
