import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/pax_counter_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read/apply сохраняют все поля', () {
    final c = ModuleConfig_PaxcounterConfig(
      enabled: true,
      paxcounterUpdateInterval: 1800,
      wifiThreshold: -70,
      bleThreshold: -90,
    );
    final v = PaxCounterSection.read(c);
    final keys = PaxCounterSection.fields().map((f) => f.key);
    expect(keys.toSet(), v.keys.toSet());
    expect(PaxCounterSection.read(PaxCounterSection.apply(c, v)), v);
  });

  test('нули прошивки: пороги -80, интервал остаётся 0', () {
    final v = PaxCounterSection.read(ModuleConfig_PaxcounterConfig());
    expect(v['wifiThreshold'], -80);
    expect(v['bleThreshold'], -80);
    expect(v['paxcounterUpdateInterval'], 0);
  });
}
