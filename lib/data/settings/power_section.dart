import '../../core/proto/hardware_architecture.dart';
import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';

/// Раздел «Питание»: PowerConfig.swift (iOS) + PowerConfigItemList.kt
/// (Android: супер-глубокий сон, минимальное время бодрствования, адрес INA).
/// Поля по архитектуре платы — как в iOS (каталог DeviceHardware.json).
/// powermon_enables и ls_secs не редактируются и сохраняются как есть.
abstract final class PowerSection {
  static const title = 'Настройки питания';
  static const groupPower = 'Питание';
  static const groupBattery = 'Батарея';
  static const saveConfirm = 'Сохранить настройки питания?';

  /// Значение при включении «Отключения при потере питания» (iOS).
  static const shutdownDefault = 1800;

  /// Начальный коэффициент АЦП при включении без прежнего значения (iOS).
  static const adcStart = 2.0;

  static List<FieldSpec<Object?>> fields({
    required int hwModel,
    required int role,
  }) {
    final arch = hardwareArchitecture[hwModel];
    final esp32 = arch == 'esp32' || arch == 'esp32-s3';
    final esp32Family = esp32 || arch == 'esp32-c3' || arch == 'esp32-c6';
    final canPowerSave =
        esp32 || (arch == 'nrf52840' && (role == 5 || role == 6));
    return [
      if (canPowerSave)
        const BoolFieldSpec(
          'isPowerSaving',
          'Энергосбережение',
          group: groupPower,
          help:
              'Все устройства будут работать в режиме ожидания, насколько это '
              'возможно, в качестве трекера и датчика также будет '
              'использоваться радиоприемник lora. Не используйте эту '
              'настройку, если вы хотите использовать свое устройство с '
              'приложениями для телефона или устройство без пользовательской '
              'кнопки.',
        ),
      const BoolFieldSpec(
        'shutdownOn',
        'Отключение при потере питания',
        group: groupPower,
        help:
            'How long after external power is removed before the device '
            'powers off. Zero to disable.',
      ),
      ChoiceFieldSpec(
        'onBatteryShutdownAfterSecs',
        'Отключение при потере питания',
        Intervals.choices(
          Intervals.all.where((s) => s >= 30 && s != Intervals.never).toList(),
        ),
        group: groupPower,
        visibleWhen: (v) => v['shutdownOn'] == true,
        unknownLabel: Intervals.label,
      ),
      if (esp32Family)
        ChoiceFieldSpec(
          'waitBluetoothSecs',
          'Длительность ожидания Bluetooth',
          Intervals.choices(Intervals.waitBluetooth),
          group: groupPower,
          unknownLabel: Intervals.label,
        ),
      ChoiceFieldSpec(
        'sdsSecs',
        'Длительность супер-глубокого сна',
        Intervals.choices(Intervals.all),
        group: groupPower,
        unknownLabel: Intervals.label,
      ),
      ChoiceFieldSpec(
        'minWakeSecs',
        'Минимальное время бодрствования',
        Intervals.choices(Intervals.nagTimeout),
        group: groupPower,
        unknownLabel: Intervals.label,
      ),
      const IntFieldSpec(
        'deviceBatteryInaAddress',
        'I2C-адрес INA_2XX батареи',
        group: groupPower,
        min: 0,
        max: 127,
      ),
      if (esp32) ...[
        const BoolFieldSpec(
          'adcOn',
          'Переопределение АЦП',
          group: groupBattery,
        ),
        DoubleFieldSpec(
          'adcMultiplierOverride',
          'Переопределение АЦП',
          group: groupBattery,
          visibleWhen: (v) => v['adcOn'] == true,
          min: 2,
          max: 6,
        ),
      ],
    ];
  }

  static Map<String, Object?> read(Config_PowerConfig c) => {
    'isPowerSaving': c.isPowerSaving,
    'shutdownOn': c.onBatteryShutdownAfterSecs != 0,
    'onBatteryShutdownAfterSecs': c.onBatteryShutdownAfterSecs == 0
        ? shutdownDefault
        : c.onBatteryShutdownAfterSecs,
    'waitBluetoothSecs': c.waitBluetoothSecs,
    'sdsSecs': c.sdsSecs,
    'minWakeSecs': c.minWakeSecs,
    'deviceBatteryInaAddress': c.deviceBatteryInaAddress,
    'adcOn': c.adcMultiplierOverride != 0,
    'adcMultiplierOverride': c.adcMultiplierOverride == 0
        ? adcStart
        : c.adcMultiplierOverride,
  };

  /// Выключенный переключатель пишет 0; число в форме остаётся, чтобы
  /// вернуться при повторном включении (как в iOS).
  static Config_PowerConfig apply(
    Config_PowerConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..isPowerSaving = v['isPowerSaving']! as bool
    ..onBatteryShutdownAfterSecs = v['shutdownOn'] == true
        ? v['onBatteryShutdownAfterSecs']! as int
        : 0
    ..waitBluetoothSecs = v['waitBluetoothSecs']! as int
    ..sdsSecs = v['sdsSecs']! as int
    ..minWakeSecs = v['minWakeSecs']! as int
    ..deviceBatteryInaAddress = v['deviceBatteryInaAddress']! as int
    ..adcMultiplierOverride = v['adcOn'] == true
        ? (v['adcMultiplierOverride']! as double)
        : 0;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    Config_PowerConfig base,
    Map<String, Object?> v,
  ) => saveConfig(admin, db, 'power', Config(power: apply(base, v)));
}
