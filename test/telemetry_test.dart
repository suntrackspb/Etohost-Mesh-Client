import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 10, 23, 12);

  test('батарея 101 — внешнее питание, не 101 %', () {
    final s = parseSample(
      TelemetryKind.device,
      t0,
      Telemetry(deviceMetrics: DeviceMetrics(batteryLevel: 101, voltage: 4.37)),
    );
    expect(s.externalPower, isTrue);
    expect(s.values.containsKey(batteryKey), isFalse);
    expect(s.values['voltage'], closeTo(4.37, 1e-6));
  });

  test('неприсланные поля не превращаются в нули', () {
    final s = parseSample(
      TelemetryKind.device,
      t0,
      Telemetry(deviceMetrics: DeviceMetrics(batteryLevel: 80)),
    );
    expect(s.values.keys, [batteryKey]);
  });

  test('дикие значения датчика — в suspect, без точки росы', () {
    final s = parseSample(
      TelemetryKind.environment,
      t0,
      Telemetry(
        environmentMetrics: EnvironmentMetrics(
          temperature: 179,
          relativeHumidity: 100,
          barometricPressure: -123,
        ),
      ),
    );
    expect(s.suspect.keys, containsAll(['temperature', 'pressure']));
    expect(s.values.keys, ['humidity']);
  });

  test('точка росы считается из температуры и влажности', () {
    final s = parseSample(
      TelemetryKind.environment,
      t0,
      Telemetry(
        environmentMetrics: EnvironmentMetrics(
          temperature: 20,
          relativeHumidity: 50,
        ),
      ),
    );
    expect(s.values[dewPointKey], closeTo(9.3, 0.1));
  });

  test('графики группируют величины с общей единицей', () {
    final s = parseSample(
      TelemetryKind.device,
      t0,
      Telemetry(
        deviceMetrics: DeviceMetrics(
          channelUtilization: 10,
          airUtilTx: 2,
          uptimeSeconds: 100,
        ),
      ),
    );
    final g = chartGroups(TelemetryKind.device, [s]);
    expect(g.keys, ['Загрузка эфира']);
    expect(g['Загрузка эфира']!.map((m) => m.key), ['chUtil', 'airUtil']);
  });

  test('период отсекает старые замеры', () {
    final samples = [
      TelemetrySample(time: t0.subtract(const Duration(hours: 3)), values: {}),
      TelemetrySample(time: t0, values: {}),
    ];
    expect(inPeriod(samples, const Duration(hours: 1), t0), hasLength(1));
    expect(inPeriod(samples, null, t0), hasLength(2));
  });

  test('запрос — пустой вариант нужного типа', () {
    expect(
      TelemetryKind.environment.request().whichVariant(),
      Telemetry_Variant.environmentMetrics,
    );
    expect(TelemetryKind.byVariant('powerMetrics'), TelemetryKind.power);
  });

  test('узкий разброс напряжения — подписи не повторяются', () {
    final a = niceAxis(4.28, 4.29);
    final labels = {
      for (var v = a.min; v <= a.max + 1e-9; v += a.step)
        v.toStringAsFixed(a.digits),
    };
    expect(labels.length, greaterThan(2));
    expect(a.min, lessThanOrEqualTo(4.28));
    expect(a.max, greaterThanOrEqualTo(4.29));
  });

  test('проценты: ось от нуля, круглый шаг', () {
    final a = niceAxis(0.4, 20.7, floorZero: true);
    expect(a.min, 0);
    expect(a.max, greaterThanOrEqualTo(20.7));
    expect([1, 2, 2.5, 5, 10], contains(a.step / 1));
  });

  test('ряд: усреднение и разрыв на долгом провале', () {
    final pts = [
      for (var i = 0; i < 60; i++)
        (time: t0.add(Duration(minutes: i)), value: i.toDouble()),
      for (var i = 0; i < 60; i++)
        (time: t0.add(Duration(hours: 10, minutes: i)), value: 1.0),
    ];
    final s = chartSeries(pts, t0, t0.add(const Duration(hours: 11)));
    expect(s.length, lessThan(pts.length));
    expect(s.where((p) => p == null), hasLength(1));
  });

  test('засечки времени — целые часы внутри периода', () {
    final from = DateTime(2026, 10, 23, 1, 47);
    final to = DateTime(2026, 10, 24, 1, 47);
    final step = timeStep(to.difference(from));
    expect(step, const Duration(hours: 6));
    final ticks = timeTicks(from, to, step);
    expect(ticks.first, DateTime(2026, 10, 23, 6));
    expect(ticks.every((t) => t.minute == 0 && t.hour % 6 == 0), isTrue);
  });
}
