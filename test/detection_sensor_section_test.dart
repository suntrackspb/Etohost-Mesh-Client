import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/detection_sensor_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read/apply сохраняют все поля', () {
    final c = ModuleConfig_DetectionSensorConfig(
      enabled: true,
      minimumBroadcastSecs: 45,
      stateBroadcastSecs: 3600,
      sendBell: true,
      name: 'Door',
      monitorPin: 7,
      detectionTriggerType:
          ModuleConfig_DetectionSensorConfig_TriggerType.RISING_EDGE,
      usePullup: true,
    );
    final v = DetectionSensorSection.read(c);
    final keys = DetectionSensorSection.fields().map((f) => f.key);
    expect(keys.toSet(), v.keys.toSet());
    expect(DetectionSensorSection.read(DetectionSensorSection.apply(c, v)), v);
  });

  test('параметры видны только при включённом модуле', () {
    final v = DetectionSensorSection.read(ModuleConfig_DetectionSensorConfig());
    expect(
      DetectionSensorSection.fields().where((f) => f.visible(v)).length,
      1,
    );
  });
}
