import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/intervals.dart';
import 'package:meshex/data/settings/telemetry_section.dart';
import 'package:meshex/data/settings/user_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read/apply сохраняют все поля', () {
    final c = ModuleConfig_TelemetryConfig(
      deviceTelemetryEnabled: true,
      deviceUpdateInterval: 1800,
      environmentMeasurementEnabled: true,
      environmentUpdateInterval: Intervals.never,
      environmentDisplayFahrenheit: true,
      airQualityEnabled: true,
      airQualityInterval: 3600,
      powerMeasurementEnabled: true,
      powerScreenEnabled: true,
    );
    final v = TelemetrySection.read(c);
    final keys = TelemetrySection.fields(firmware: '2.8.0').map((f) => f.key);
    expect(keys.toSet(), v.keys.toSet());
    expect(TelemetrySection.read(TelemetrySection.apply(c, v)), v);
  });

  test('переключатель устройства — с 2.7.13, раньше только интервал', () {
    bool has(String fw) => TelemetrySection.fields(
      firmware: fw,
    ).any((f) => f.key == 'deviceTelemetryEnabled');
    expect(has('2.7.12.abc'), isFalse);
    expect(has('2.7.13.abc'), isTrue);
    expect(has('2.8.0'), isTrue);
    final old = TelemetrySection.fields(firmware: '2.6.11');
    final interval = old.firstWhere((f) => f.key == 'deviceUpdateInterval');
    expect(interval.visibleWhen, isNull);
  });

  test('интервалы датчиков видны при включённом датчике', () {
    final f = TelemetrySection.fields(firmware: '2.8.0');
    final v = TelemetrySection.read(ModuleConfig_TelemetryConfig());
    bool visible(String k) =>
        f.firstWhere((x) => x.key == k).visibleWhen?.call(v) ?? true;
    expect(visible('environmentUpdateInterval'), isFalse);
    expect(visible('powerScreenEnabled'), isFalse);
    v['environmentMeasurementEnabled'] = true;
    expect(visible('environmentUpdateInterval'), isTrue);
  });

  test('сравнение версий с патчем', () {
    expect(firmwareAtLeast('2.7.13', 2, 7, 13), isTrue);
    expect(firmwareAtLeast('2.7.9', 2, 7, 13), isFalse);
    expect(firmwareAtLeast('2.8.0', 2, 7, 13), isTrue);
    expect(firmwareAtLeast('2.7.0', 2, 7), isTrue);
  });
}
