import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Раздел «Bluetooth»: BluetoothConfig.swift (iOS). Подписи — iOS ru, где их
/// нет — Android ru; варианты режима без перевода в iOS — английские.
abstract final class BluetoothSection {
  static const title = 'Настройка Bluetooth';
  static const group = 'Параметры';
  static const saveConfirm = 'Сохранить настройки Bluetooth?';
  static const pinError = 'Длина пин-кода BLE должна быть 6 цифр.';

  static const fixedPinMode = 1;

  static const modes = <Choice>[
    (value: 0, label: 'Random Pin'),
    (value: fixedPinMode, label: 'Фиксированный PIN'),
    (value: 2, label: 'No PIN (Just Works)'),
  ];

  /// Шесть цифр без ведущего нуля: прошивка хранит PIN числом.
  static bool isValidPin(String s) => RegExp(r'^[1-9]\d{5}$').hasMatch(s);

  static bool _fixed(Map<String, Object?> v) => v['mode'] == fixedPinMode;

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'enabled',
      'Bluetooth включен',
      group: group,
      help: 'Включить Bluetooth на устройстве',
    ),
    const ChoiceFieldSpec(
      'mode',
      'Режим сопряжения',
      modes,
      group: group,
      help: 'Стратегия подключения Bluetooth',
    ),
    TextFieldSpec(
      'fixedPin',
      'Фиксированный PIN',
      group: group,
      maxBytes: 6,
      visibleWhen: _fixed,
      validator: (s) => isValidPin(s) ? null : pinError,
      help:
          'Фиксированный PIN-код для подключения к Bluetooth. Используется '
          'при соединении с фиксированным PIN-кодом',
    ),
  ];

  static Map<String, Object?> read(Config_BluetoothConfig c) => {
    'enabled': c.enabled,
    'mode': c.mode.value,
    'fixedPin': c.fixedPin == 0 ? '' : '${c.fixedPin}',
  };

  static Config_BluetoothConfig apply(
    Config_BluetoothConfig base,
    Map<String, Object?> v,
  ) {
    final out = base.deepCopy()
      ..enabled = v['enabled']! as bool
      ..mode = Config_BluetoothConfig_PairingMode.valueOf(v['mode']! as int)!;
    // PIN меняем только в режиме фиксированного PIN; иначе оставляем как был.
    if (_fixed(v)) out.fixedPin = int.parse(v['fixedPin']! as String);
    return out;
  }

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    Config_BluetoothConfig base,
    Map<String, Object?> v,
  ) => saveConfig(admin, db, 'bluetooth', Config(bluetooth: apply(base, v)));
}
