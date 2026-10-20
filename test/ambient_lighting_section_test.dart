import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/ambient_lighting_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read/apply сохраняют все поля, образец цвета', () {
    final c = ModuleConfig_AmbientLightingConfig(
      ledState: true,
      current: 10,
      red: 255,
      green: 128,
      blue: 1,
    );
    final v = AmbientLightingSection.read(c);
    final keys = AmbientLightingSection.fields().map((f) => f.key);
    expect(keys.toSet(), v.keys.toSet());
    expect(AmbientLightingSection.read(AmbientLightingSection.apply(c, v)), v);
    expect(AmbientLightingSection.argb(v), 0xFFFF8001);
  });
}
