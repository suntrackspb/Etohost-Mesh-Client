import 'dart:math' as math;

import '../core/proto/mesh.dart';

/// Типы телеметрии, которые показываем и запрашиваем. [variant] — имя
/// варианта Telemetry, как его пишет в БД роутер (`TelemetryLog.kind`).
enum TelemetryKind {
  device('deviceMetrics', 'Метрики устройства'),
  environment('environmentMetrics', 'Метрики окружения'),
  airQuality('airQualityMetrics', 'Метрики качества воздуха'),
  power('powerMetrics', 'Метрики питания');

  const TelemetryKind(this.variant, this.title);

  final String variant;
  final String title;

  static TelemetryKind? byVariant(String v) =>
      values.where((k) => k.variant == v).firstOrNull;

  /// Пустой запрос этого типа: нода отвечает своими текущими значениями.
  Telemetry request() => switch (this) {
    device => Telemetry(deviceMetrics: DeviceMetrics()),
    environment => Telemetry(environmentMetrics: EnvironmentMetrics()),
    airQuality => Telemetry(airQualityMetrics: AirQualityMetrics()),
    power => Telemetry(powerMetrics: PowerMetrics()),
  };
}

/// Одна величина. [chart] — заголовок графика: величины с одинаковым
/// заголовком рисуются вместе (у них общая единица). null — не рисуется.
/// [min]..[max] — правдоподобный диапазон: всё вне его считаем мусором
/// датчика и помечаем, а не рисуем.
class Metric {
  const Metric(
    this.key,
    this.label,
    this.unit,
    this.read, {
    this.digits = 1,
    this.chart,
    this.min = double.negativeInfinity,
    this.max = double.infinity,
    String? short,
  }) : short = short ?? label;

  final String key;
  final String label;

  /// Заголовок столбца в журнале.
  final String short;
  final String unit;
  final double? Function(Telemetry t) read;
  final int digits;
  final String? chart;
  final double min;
  final double max;

  bool plausible(double v) => v.isFinite && v >= min && v <= max;

  String format(double v) {
    final s = v.toStringAsFixed(digits);
    return unit.isEmpty ? s : '$s $unit';
  }
}

double? _v(bool has, num v) => has ? v.toDouble() : null;

/// Батарея: 101 — внешнее питание, отдельно от процентов.
const batteryKey = 'battery';
const uptimeKey = 'uptime';
const dewPointKey = 'dewPoint';

/// Величины по типам — в порядке показа. Подписи: iOS ru, чего там нет —
/// Android ru.
final Map<TelemetryKind, List<Metric>> telemetryMetrics = {
  TelemetryKind.device: [
    Metric(
      batteryKey,
      'Уровень заряда',
      '%',
      (t) =>
          _v(t.deviceMetrics.hasBatteryLevel(), t.deviceMetrics.batteryLevel),
      digits: 0,
      chart: 'Уровень заряда',
      min: 0,
      max: 100,
      short: 'Заряд',
    ),
    Metric(
      'voltage',
      'Напряжение',
      'В',
      (t) => _v(t.deviceMetrics.hasVoltage(), t.deviceMetrics.voltage),
      digits: 2,
      chart: 'Напряжение',
      min: 0,
      max: 30,
      short: 'Напр.',
    ),
    Metric(
      'chUtil',
      'Использование канала',
      '%',
      (t) => _v(
        t.deviceMetrics.hasChannelUtilization(),
        t.deviceMetrics.channelUtilization,
      ),
      short: 'ChUtil',
      chart: 'Загрузка эфира',
      min: 0,
      max: 100,
    ),
    Metric(
      'airUtil',
      'Эфирное время',
      '%',
      (t) => _v(t.deviceMetrics.hasAirUtilTx(), t.deviceMetrics.airUtilTx),
      chart: 'Загрузка эфира',
      min: 0,
      max: 100,
      short: 'AirUtil',
    ),
    Metric(
      uptimeKey,
      'Время работы',
      'с',
      (t) =>
          _v(t.deviceMetrics.hasUptimeSeconds(), t.deviceMetrics.uptimeSeconds),
      digits: 0,
      min: 0,
    ),
  ],
  TelemetryKind.environment: [
    Metric(
      'temperature',
      'Температура',
      '°C',
      (t) => _v(
        t.environmentMetrics.hasTemperature(),
        t.environmentMetrics.temperature,
      ),
      short: 'Темп',
      chart: 'Температура',
      min: -60,
      max: 85,
    ),
    // Считаем сами из температуры и влажности (как iOS и Android).
    Metric(
      dewPointKey,
      'Точка росы',
      '°C',
      (t) => null,
      chart: 'Температура',
      min: -80,
      max: 85,
      short: 'Т. росы',
    ),
    Metric(
      'humidity',
      'Влажность',
      '%',
      (t) => _v(
        t.environmentMetrics.hasRelativeHumidity(),
        t.environmentMetrics.relativeHumidity,
      ),
      short: 'Влажн',
      digits: 0,
      chart: 'Влажность',
      min: 0,
      max: 100,
    ),
    Metric(
      'pressure',
      'Давление',
      'гПа',
      (t) => _v(
        t.environmentMetrics.hasBarometricPressure(),
        t.environmentMetrics.barometricPressure,
      ),
      short: 'Давл',
      digits: 0,
      chart: 'Давление',
      min: 300,
      max: 1100,
    ),
    Metric(
      'gas',
      'Сопротивление газа',
      'МОм',
      (t) => _v(
        t.environmentMetrics.hasGasResistance(),
        t.environmentMetrics.gasResistance,
      ),
      short: 'Газ',
      digits: 2,
      chart: 'Сопротивление газа',
      min: 0,
      max: 10000,
    ),
    Metric(
      'iaq',
      'IAQ',
      '',
      (t) => _v(t.environmentMetrics.hasIaq(), t.environmentMetrics.iaq),
      digits: 0,
      chart: 'IAQ',
      min: 0,
      max: 500,
    ),
    Metric(
      'lux',
      'Освещённость',
      'лк',
      (t) => _v(t.environmentMetrics.hasLux(), t.environmentMetrics.lux),
      digits: 0,
      chart: 'Освещённость',
      min: 0,
      max: 200000,
      short: 'Свет',
    ),
    Metric(
      'wind',
      'Ветер',
      'м/с',
      (t) => _v(
        t.environmentMetrics.hasWindSpeed(),
        t.environmentMetrics.windSpeed,
      ),
      chart: 'Ветер',
      min: 0,
      max: 100,
    ),
    Metric(
      'radiation',
      'Излучение',
      'мкР/ч',
      (t) => _v(
        t.environmentMetrics.hasRadiation(),
        t.environmentMetrics.radiation,
      ),
      chart: 'Излучение',
      min: 0,
      max: 100000,
    ),
    Metric(
      'rain1h',
      'Дождь (1ч)',
      'мм',
      (t) => _v(
        t.environmentMetrics.hasRainfall1h(),
        t.environmentMetrics.rainfall1h,
      ),
      short: 'Дождь 1ч',
      chart: 'Дождь',
      min: 0,
      max: 500,
    ),
    Metric(
      'rain24h',
      'Дождь (24ч)',
      'мм',
      (t) => _v(
        t.environmentMetrics.hasRainfall24h(),
        t.environmentMetrics.rainfall24h,
      ),
      short: 'Дождь 24ч',
      chart: 'Дождь',
      min: 0,
      max: 2000,
    ),
    Metric(
      'soilMoisture',
      'Влажность почвы',
      '%',
      (t) => _v(
        t.environmentMetrics.hasSoilMoisture(),
        t.environmentMetrics.soilMoisture,
      ),
      short: 'Влажн почвы',
      digits: 0,
      chart: 'Влажность почвы',
      min: 0,
      max: 100,
    ),
    Metric(
      'soilTemp',
      'Температура почвы',
      '°C',
      (t) => _v(
        t.environmentMetrics.hasSoilTemperature(),
        t.environmentMetrics.soilTemperature,
      ),
      short: 'Темп почвы',
      chart: 'Температура почвы',
      min: -60,
      max: 85,
    ),
    Metric(
      'weight',
      'Вес',
      'кг',
      (t) => _v(t.environmentMetrics.hasWeight(), t.environmentMetrics.weight),
      digits: 2,
      chart: 'Вес',
      min: 0,
    ),
    Metric(
      'envVoltage',
      'Напряжение',
      'В',
      (t) =>
          _v(t.environmentMetrics.hasVoltage(), t.environmentMetrics.voltage),
      digits: 2,
      chart: 'Напряжение',
      min: 0,
      max: 100,
    ),
    Metric(
      'envCurrent',
      'Ток',
      'мА',
      (t) =>
          _v(t.environmentMetrics.hasCurrent(), t.environmentMetrics.current),
      digits: 0,
      chart: 'Ток',
    ),
  ],
  TelemetryKind.airQuality: [
    Metric(
      'pm1',
      'PM1.0',
      'мкг/м³',
      (t) => _v(
        t.airQualityMetrics.hasPm10Standard(),
        t.airQualityMetrics.pm10Standard,
      ),
      digits: 0,
      chart: 'Частицы',
      min: 0,
      max: 2000,
    ),
    Metric(
      'pm25',
      'PM2.5',
      'мкг/м³',
      (t) => _v(
        t.airQualityMetrics.hasPm25Standard(),
        t.airQualityMetrics.pm25Standard,
      ),
      digits: 0,
      chart: 'Частицы',
      min: 0,
      max: 2000,
    ),
    Metric(
      'pm10',
      'PM10',
      'мкг/м³',
      (t) => _v(
        t.airQualityMetrics.hasPm100Standard(),
        t.airQualityMetrics.pm100Standard,
      ),
      digits: 0,
      chart: 'Частицы',
      min: 0,
      max: 2000,
    ),
    Metric(
      'co2',
      'CO₂',
      'ppm',
      (t) => _v(t.airQualityMetrics.hasCo2(), t.airQualityMetrics.co2),
      digits: 0,
      chart: 'CO₂',
      min: 0,
      max: 40000,
    ),
  ],
  TelemetryKind.power: [
    for (var ch = 1; ch <= 8; ch++) ...[
      Metric(
        'ch${ch}V',
        'Канал $ch',
        'В',
        (t) => _powerChannel(t.powerMetrics, ch, voltage: true),
        digits: 2,
        chart: 'Напряжение',
        min: 0,
        max: 100,
      ),
      Metric(
        'ch${ch}I',
        'Канал $ch',
        'мА',
        (t) => _powerChannel(t.powerMetrics, ch, voltage: false),
        digits: 0,
        chart: 'Ток',
      ),
    ],
  ],
};

double? _powerChannel(PowerMetrics m, int ch, {required bool voltage}) =>
    switch ((ch, voltage)) {
      (1, true) => _v(m.hasCh1Voltage(), m.ch1Voltage),
      (1, false) => _v(m.hasCh1Current(), m.ch1Current),
      (2, true) => _v(m.hasCh2Voltage(), m.ch2Voltage),
      (2, false) => _v(m.hasCh2Current(), m.ch2Current),
      (3, true) => _v(m.hasCh3Voltage(), m.ch3Voltage),
      (3, false) => _v(m.hasCh3Current(), m.ch3Current),
      (4, true) => _v(m.hasCh4Voltage(), m.ch4Voltage),
      (4, false) => _v(m.hasCh4Current(), m.ch4Current),
      (5, true) => _v(m.hasCh5Voltage(), m.ch5Voltage),
      (5, false) => _v(m.hasCh5Current(), m.ch5Current),
      (6, true) => _v(m.hasCh6Voltage(), m.ch6Voltage),
      (6, false) => _v(m.hasCh6Current(), m.ch6Current),
      (7, true) => _v(m.hasCh7Voltage(), m.ch7Voltage),
      (7, false) => _v(m.hasCh7Current(), m.ch7Current),
      (8, true) => _v(m.hasCh8Voltage(), m.ch8Voltage),
      (8, false) => _v(m.hasCh8Current(), m.ch8Current),
      _ => null,
    };

/// Точка росы по Магнусу (коэффициенты Sonntag, как в официальных клиентах).
double? dewPoint(double tempC, double humidity) {
  if (humidity <= 0 || humidity > 100) return null;
  const a = 17.62, b = 243.12;
  final g = math.log(humidity / 100) + a * tempC / (b + tempC);
  return b * g / (a - g);
}

/// Один замер: правдоподобные значения — [values], выбивающиеся — [suspect].
/// [externalPower] — батарея прислала 101 (питание от сети/USB).
class TelemetrySample {
  const TelemetrySample({
    required this.time,
    required this.values,
    this.suspect = const {},
    this.externalPower = false,
  });

  final DateTime time;
  final Map<String, double> values;
  final Map<String, double> suspect;
  final bool externalPower;

  bool get isEmpty => values.isEmpty && suspect.isEmpty && !externalPower;
}

/// Разобрать сохранённый Telemetry в замер.
TelemetrySample parseSample(TelemetryKind kind, DateTime time, Telemetry t) {
  final values = <String, double>{}, suspect = <String, double>{};
  var external = false;
  for (final m in telemetryMetrics[kind]!) {
    final v = m.read(t);
    if (v == null) continue;
    if (m.key == batteryKey && v > 100) {
      external = true;
    } else if (m.plausible(v)) {
      values[m.key] = v;
    } else {
      suspect[m.key] = v;
    }
  }
  if (kind == TelemetryKind.environment) {
    final temp = values['temperature'], hum = values['humidity'];
    final d = temp == null || hum == null ? null : dewPoint(temp, hum);
    if (d != null) values[dewPointKey] = d;
  }
  return TelemetrySample(
    time: time,
    values: values,
    suspect: suspect,
    externalPower: external,
  );
}

Metric? metricByKey(TelemetryKind kind, String key) =>
    telemetryMetrics[kind]!.where((m) => m.key == key).firstOrNull;

/// Ряд одной величины для графика: (время, значение).
typedef SeriesPoint = ({DateTime time, double value});

/// Графики типа: заголовок → величины на нём, только те, что есть в [samples].
/// Порядок — как в [telemetryMetrics].
Map<String, List<Metric>> chartGroups(
  TelemetryKind kind,
  List<TelemetrySample> samples,
) {
  final present = {for (final s in samples) ...s.values.keys};
  final out = <String, List<Metric>>{};
  for (final m in telemetryMetrics[kind]!) {
    final c = m.chart;
    if (c == null || !present.contains(m.key)) continue;
    (out[c] ??= []).add(m);
  }
  return out;
}

List<SeriesPoint> series(List<TelemetrySample> samples, String key) => [
  for (final s in samples)
    if (s.values[key] case final v?) (time: s.time, value: v),
];

/// Замеры не старше [period] от [now]; null — все.
List<TelemetrySample> inPeriod(
  List<TelemetrySample> samples,
  Duration? period,
  DateTime now,
) => period == null
    ? samples
    : samples.where((s) => now.difference(s.time) <= period).toList();

/// Ряд для графика: точки, null — разрыв линии (долго не было данных).
typedef ChartSeries = List<SeriesPoint?>;

/// Усреднить ряд по [buckets] равным интервалам на [from]..[to] и разорвать
/// линию там, где данных не было дольше трёх интервалов (или трёх обычных
/// промежутков между замерами, если они реже). Шлюз шлёт замер раз в минуту —
/// без этого за сутки получается «щётка» из 1400 точек.
ChartSeries chartSeries(
  List<SeriesPoint> points,
  DateTime from,
  DateTime to, {
  int buckets = 96,
}) {
  if (points.isEmpty) return const [];
  final span = to.difference(from).inMilliseconds;
  final width = span <= 0 ? 1 : (span / buckets).ceil();
  final sum = <int, double>{}, count = <int, int>{}, at = <int, int>{};
  for (final p in points) {
    final b = (p.time.difference(from).inMilliseconds / width).floor();
    sum[b] = (sum[b] ?? 0) + p.value;
    count[b] = (count[b] ?? 0) + 1;
    at[b] = (at[b] ?? 0) + p.time.millisecondsSinceEpoch;
  }
  final keys = sum.keys.toList()..sort();
  // Обычный промежуток между замерами — медиана.
  final gaps = [
    for (var i = 1; i < points.length; i++)
      points[i].time.difference(points[i - 1].time).inMilliseconds,
  ]..sort();
  final typical = gaps.isEmpty ? 0 : gaps[gaps.length ~/ 2];
  final maxGap = 3 * (typical > width ? typical : width);
  final out = <SeriesPoint?>[];
  int? prev;
  for (final b in keys) {
    final t = at[b]! ~/ count[b]!;
    if (prev != null && t - prev > maxGap) out.add(null);
    out.add((
      time: DateTime.fromMillisecondsSinceEpoch(t),
      value: sum[b]! / count[b]!,
    ));
    prev = t;
  }
  return out;
}

/// Шкала оси Y: границы кратны шагу, шаг «круглый» (1, 2, 5 × 10ⁿ), подписей
/// около [ticks]. Узкий разброс (4.28–4.29 В) расширяется, чтобы подписи
/// не повторялись. [floorZero] — величина не бывает отрицательной.
({double min, double max, double step, int digits}) niceAxis(
  double lo,
  double hi, {
  int ticks = 4,
  bool floorZero = false,
}) {
  final mid = (lo + hi) / 2;
  final minSpan = math.max(mid.abs() * 0.02, 1e-3);
  if (hi - lo < minSpan) {
    lo = mid - minSpan / 2;
    hi = mid + minSpan / 2;
  }
  final raw = (hi - lo) / ticks;
  final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final step = [
    1,
    2,
    2.5,
    5,
    10,
  ].map((m) => m * mag).firstWhere((s) => s >= raw);
  var min = (lo / step).floor() * step;
  final max = (hi / step).ceil() * step;
  if (floorZero && min < 0) min = 0;
  final digits = math.max(
    0,
    -(math.log(step) / math.ln10).floor() + (step / mag == 2.5 ? 1 : 0),
  );
  return (
    min: min,
    max: max == min ? min + step : max,
    step: step,
    digits: digits,
  );
}

/// Шаг засечек времени: целые 5/15/30 мин, часы, сутки — не больше [ticks].
Duration timeStep(Duration span, {int ticks = 5}) {
  const steps = [
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 3),
    Duration(hours: 6),
    Duration(hours: 12),
    Duration(days: 1),
    Duration(days: 2),
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
  ];
  return steps.firstWhere(
    (s) => span.inMilliseconds / s.inMilliseconds <= ticks,
    orElse: () => steps.last,
  );
}

/// Засечки времени, кратные [step] по местному времени, внутри [from]..[to].
List<DateTime> timeTicks(DateTime from, DateTime to, Duration step) {
  final local = from.toLocal();
  var t = step >= const Duration(days: 1)
      ? DateTime(local.year, local.month, local.day)
      : DateTime(
          local.year,
          local.month,
          local.day,
          local.hour,
          step.inMinutes >= 60
              ? 0
              : local.minute - local.minute % step.inMinutes,
        );
  if (step.inHours > 1 && step.inHours < 24) {
    t = DateTime(t.year, t.month, t.day, t.hour - t.hour % step.inHours);
  }
  final out = <DateTime>[];
  while (!t.isAfter(to)) {
    if (!t.isBefore(from)) out.add(t);
    t = step >= const Duration(days: 1)
        ? DateTime(t.year, t.month, t.day + step.inDays)
        : t.add(step);
  }
  return out;
}
