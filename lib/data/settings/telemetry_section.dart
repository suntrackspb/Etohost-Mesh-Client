import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';
import 'user_section.dart' show firmwareAtLeast;

/// Модуль «Телеметрия»: TelemetryConfig.swift (iOS), те же поля в Android.
/// Подписи — iOS ru, затем Android ru, затем английские. Интервал виден,
/// когда включён свой датчик (iOS).
abstract final class TelemetrySection {
  static const title = 'Настройки телеметрии';
  static const saveConfirm = 'Сохранить настройки телеметрии?';
  static const groupDevice = 'Параметры устройства';
  static const groupEnvironment = 'Параметры датчика окружения';
  static const groupAir = 'Air Quality Sensor Options';
  static const groupPower = 'Параметры питания сенсоров';

  /// С 2.7.13 прошивка читает device_telemetry_enabled; раньше рассылку
  /// выключал только интервал «Никогда».
  static bool hasDeviceToggle(String fw) => firmwareAtLeast(fw, 2, 7, 13);

  static ChoiceFieldSpec _interval(
    String key,
    String label,
    String group,
    String help, {
    bool Function(Map<String, Object?> v)? visibleWhen,
  }) => ChoiceFieldSpec(
    key,
    label,
    Intervals.choices(Intervals.broadcastShort),
    group: group,
    help: help,
    visibleWhen: visibleWhen,
    unknownLabel: Intervals.label,
  );

  static bool Function(Map<String, Object?> v) _on(String key) =>
      (v) => v[key] == true;

  static List<FieldSpec<Object?>> fields({required String firmware}) {
    final toggle = hasDeviceToggle(firmware);
    return [
      if (toggle)
        const BoolFieldSpec(
          'deviceTelemetryEnabled',
          'Показатели широковещательного устройства',
          group: groupDevice,
          help:
              'Включить передачу метрик устройства в ячеистую сеть. При '
              'отключении метрики отправляются только подключенным клиентам.',
        ),
      _interval(
        'deviceUpdateInterval',
        'Интервал обновления метрик устройства',
        groupDevice,
        'How often device metrics are sent over the mesh.',
        visibleWhen: toggle ? _on('deviceTelemetryEnabled') : null,
      ),
      const BoolFieldSpec(
        'environmentMeasurementEnabled',
        'Метрики окружения включены',
        group: groupEnvironment,
        help: 'Collect environment measurements',
      ),
      _interval(
        'environmentUpdateInterval',
        'Интервал обновления метрик среды',
        groupEnvironment,
        'How often environment metrics are sent over the mesh.',
        visibleWhen: _on('environmentMeasurementEnabled'),
      ),
      BoolFieldSpec(
        'environmentScreenEnabled',
        'Показать на экране устройства',
        group: groupEnvironment,
        visibleWhen: _on('environmentMeasurementEnabled'),
      ),
      BoolFieldSpec(
        'environmentDisplayFahrenheit',
        'Отображение по Фаренгейту',
        group: groupEnvironment,
        visibleWhen: _on('environmentMeasurementEnabled'),
      ),
      const BoolFieldSpec(
        'airQualityEnabled',
        'Модуль измерения качества воздуха включен',
        group: groupAir,
        help: 'Collect air quality metrics',
      ),
      _interval(
        'airQualityInterval',
        'Интервал обновления данных качества воздуха',
        groupAir,
        'How often air quality metrics are sent over the mesh.',
        visibleWhen: _on('airQualityEnabled'),
      ),
      const BoolFieldSpec(
        'powerMeasurementEnabled',
        'Модуль метрик питания включен',
        group: groupPower,
        help: 'Collect power metrics',
      ),
      _interval(
        'powerUpdateInterval',
        'Интервал обновления метрик электропитания',
        groupPower,
        'How often power metrics are sent over the mesh.',
        visibleWhen: _on('powerMeasurementEnabled'),
      ),
      BoolFieldSpec(
        'powerScreenEnabled',
        'Питание экрана',
        group: groupPower,
        visibleWhen: _on('powerMeasurementEnabled'),
        help: 'Display power metrics on device',
      ),
    ];
  }

  static Map<String, Object?> read(ModuleConfig_TelemetryConfig c) => {
    'deviceTelemetryEnabled': c.deviceTelemetryEnabled,
    'deviceUpdateInterval': c.deviceUpdateInterval,
    'environmentMeasurementEnabled': c.environmentMeasurementEnabled,
    'environmentUpdateInterval': c.environmentUpdateInterval,
    'environmentScreenEnabled': c.environmentScreenEnabled,
    'environmentDisplayFahrenheit': c.environmentDisplayFahrenheit,
    'airQualityEnabled': c.airQualityEnabled,
    'airQualityInterval': c.airQualityInterval,
    'powerMeasurementEnabled': c.powerMeasurementEnabled,
    'powerUpdateInterval': c.powerUpdateInterval,
    'powerScreenEnabled': c.powerScreenEnabled,
  };

  static ModuleConfig_TelemetryConfig apply(
    ModuleConfig_TelemetryConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..deviceTelemetryEnabled = v['deviceTelemetryEnabled']! as bool
    ..deviceUpdateInterval = v['deviceUpdateInterval']! as int
    ..environmentMeasurementEnabled =
        v['environmentMeasurementEnabled']! as bool
    ..environmentUpdateInterval = v['environmentUpdateInterval']! as int
    ..environmentScreenEnabled = v['environmentScreenEnabled']! as bool
    ..environmentDisplayFahrenheit = v['environmentDisplayFahrenheit']! as bool
    ..airQualityEnabled = v['airQualityEnabled']! as bool
    ..airQualityInterval = v['airQualityInterval']! as int
    ..powerMeasurementEnabled = v['powerMeasurementEnabled']! as bool
    ..powerUpdateInterval = v['powerUpdateInterval']! as int
    ..powerScreenEnabled = v['powerScreenEnabled']! as bool;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_TelemetryConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'telemetry',
    ModuleConfig(telemetry: apply(base, v)),
  );
}
