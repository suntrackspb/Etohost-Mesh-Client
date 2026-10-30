import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/settings_form.dart';
import 'package:meshex/data/settings/traffic_management_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SettingsForm form(ModuleConfig_TrafficManagementConfig c) => SettingsForm(
    TrafficManagementSection.fields(),
    TrafficManagementSection.read(c),
    adjust: TrafficManagementSection.adjust,
    check: TrafficManagementSection.check,
  );

  test('read/apply сохраняют значения, выключатели из ненулевых', () {
    final c = ModuleConfig_TrafficManagementConfig(
      positionMinIntervalSecs: 3600,
      rateLimitWindowSecs: 30,
      rateLimitMaxPackets: 5,
    );
    final v = TrafficManagementSection.read(c);
    expect(v['on'], isTrue);
    expect(v['positionDedup'], isTrue);
    expect(v['nodeinfoDirect'], isFalse);
    expect(
      TrafficManagementSection.read(TrafficManagementSection.apply(c, v)),
      v,
    );
    final keys = TrafficManagementSection.fields().map((f) => f.key);
    expect(keys.toSet(), v.keys.toSet());
  });

  test('включение функции ставит значение iOS, выключение — 0', () {
    final f = form(ModuleConfig_TrafficManagementConfig());
    expect(f.value<bool>('on'), isFalse);
    f.set('on', true);
    expect(f.dirty, isTrue);
    f.set('positionDedup', true);
    expect(f.value<int>('positionMinIntervalSecs'), 18000);
    f.set('nodeinfoDirect', true);
    expect(f.value<int>('nodeinfoDirectResponseMaxHops'), 1);
    f.set('positionDedup', false);
    expect(f.value<int>('positionMinIntervalSecs'), 0);
  });

  test('ограничение скорости требует числа; главный выкл. обнуляет всё', () {
    final f = form(ModuleConfig_TrafficManagementConfig());
    f.set('on', true);
    f.set('rateLimit', true);
    expect(f.value<int>('rateLimitWindowSecs'), 60);
    expect(f.formError, isNotNull);
    f.set('rateLimitMaxPackets', 20);
    expect(f.formError, isNull);
    f.set('on', false);
    final c = TrafficManagementSection.apply(
      ModuleConfig_TrafficManagementConfig(),
      f.values,
    );
    expect(c.rateLimitWindowSecs, 0);
    expect(c.rateLimitMaxPackets, 0);
  });

  test('поддержка с 2.8', () {
    expect(TrafficManagementSection.supported('2.7.23.abc'), isFalse);
    expect(TrafficManagementSection.supported('2.8.0.abc'), isTrue);
  });
}
