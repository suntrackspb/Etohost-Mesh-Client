import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';

/// Модуль «Внешние уведомления»: ExternalNotificationConfig.swift (iOS).
/// Подписи — iOS ru, затем Android ru, затем английские. Как в Android:
/// «Активно» видно только при заданном выходе, PWM — при выходе зуммера.
/// Рингтон — отдельно, см. [ringtone] в node_text.dart.
abstract final class ExternalNotificationSection {
  static const title = 'Настройка внешних уведомлений';
  static const saveConfirm = 'Сохранить настройки внешних уведомлений?';
  static const groupOptions = 'Параметры';
  static const groupPrimary = 'Первичный GPIO';
  static const groupOptional = 'Дополнительный GPIO';

  /// OutputIntervals (iOS), миллисекунды.
  static const outputs = <Choice>[
    (value: 0, label: 'Не задан'),
    (value: 1000, label: 'One Second'),
    (value: 2000, label: 'Two Seconds'),
    (value: 3000, label: 'Three Seconds'),
    (value: 4000, label: 'Four Seconds'),
    (value: 5000, label: 'Five Seconds'),
    (value: 10000, label: 'Ten Seconds'),
    (value: 15000, label: 'Fifteen Seconds'),
    (value: 30000, label: 'Thirty Seconds'),
    (value: 60000, label: 'Одна минута'),
  ];

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'enabled',
      'Внешние уведомления включены',
      group: groupOptions,
    ),
    const BoolFieldSpec(
      'alertBell',
      'Предупреждение при получении звукового сигнала',
      group: groupOptions,
    ),
    const BoolFieldSpec(
      'alertMessage',
      'Предупреждение при получении сообщения',
      group: groupOptions,
    ),
    BoolFieldSpec(
      'usePwm',
      'Использовать PWM зуммер',
      group: groupOptions,
      visibleWhen: (v) => v['outputBuzzer'] != 0,
      help:
          'Используйте выход PWM (например, RAK Buzzer) для мелодий вместо '
          'вывода вкл/выкл. Это будет игнорировать вывод, длительность '
          'вывода и активные настройки и использовать опцию GPIO зуммера в '
          'конфигурации устройства.',
    ),
    const BoolFieldSpec(
      'useI2sAsBuzzer',
      'Использовать I2S как зуммер',
      group: groupOptions,
      help:
          'Позволяет устройствам с нативным аудиовыходом I2S использовать '
          'RTTTL через динамик как зуммер. Например, T-Watch S3 и T-Deck '
          'имеют эту возможность.',
    ),
    const IntFieldSpec(
      'output',
      'Выходной контакт GPIO',
      group: groupPrimary,
      min: 0,
      max: 255,
    ),
    BoolFieldSpec(
      'active',
      'Активно',
      group: groupPrimary,
      visibleWhen: (v) => v['output'] != 0,
      help:
          "Если включено, контакт 'output' будет активирован на высоком "
          'уровне, отключено означает активный низкий уровень.',
    ),
    ChoiceFieldSpec(
      'outputMs',
      'Длительность выхода GPIO',
      outputs,
      group: groupPrimary,
      unknownLabel: (ms) => '$ms мс',
    ),
    ChoiceFieldSpec(
      'nagTimeout',
      'Интервал повтора',
      Intervals.choices(Intervals.nagTimeout),
      group: groupPrimary,
      unknownLabel: Intervals.label,
    ),
    const BoolFieldSpec(
      'alertBellBuzzer',
      'Предупреждающий зуммер GPIO при получении звукового сигнала',
      group: groupOptional,
    ),
    const BoolFieldSpec(
      'alertBellVibra',
      'Предупреждающий вибромотор GPIO о получении звукового сигнала',
      group: groupOptional,
    ),
    const BoolFieldSpec(
      'alertMessageBuzzer',
      'Предупреждающий зуммер GPIO при получении сообщения',
      group: groupOptional,
    ),
    const BoolFieldSpec(
      'alertMessageVibra',
      'Вибрация при уведомлении',
      group: groupOptional,
      help: 'Предупреждающий вибромотор GPIO о получении сообщения',
    ),
    const IntFieldSpec(
      'outputBuzzer',
      'Выходной контакт зуммера GPIO',
      group: groupOptional,
      min: 0,
      max: 255,
    ),
    const IntFieldSpec(
      'outputVibra',
      'Выходной контакт вибрации GPIO',
      group: groupOptional,
      min: 0,
      max: 255,
    ),
  ];

  static Map<String, Object?> read(ModuleConfig_ExternalNotificationConfig c) =>
      {
        'enabled': c.enabled,
        'alertBell': c.alertBell,
        'alertMessage': c.alertMessage,
        'usePwm': c.usePwm,
        'useI2sAsBuzzer': c.useI2sAsBuzzer,
        'output': c.output,
        'active': c.active,
        'outputMs': c.outputMs,
        'nagTimeout': c.nagTimeout,
        'alertBellBuzzer': c.alertBellBuzzer,
        'alertBellVibra': c.alertBellVibra,
        'alertMessageBuzzer': c.alertMessageBuzzer,
        'alertMessageVibra': c.alertMessageVibra,
        'outputBuzzer': c.outputBuzzer,
        'outputVibra': c.outputVibra,
      };

  static ModuleConfig_ExternalNotificationConfig apply(
    ModuleConfig_ExternalNotificationConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..enabled = v['enabled']! as bool
    ..alertBell = v['alertBell']! as bool
    ..alertMessage = v['alertMessage']! as bool
    ..usePwm = v['usePwm']! as bool
    ..useI2sAsBuzzer = v['useI2sAsBuzzer']! as bool
    ..output = v['output']! as int
    ..active = v['active']! as bool
    ..outputMs = v['outputMs']! as int
    ..nagTimeout = v['nagTimeout']! as int
    ..alertBellBuzzer = v['alertBellBuzzer']! as bool
    ..alertBellVibra = v['alertBellVibra']! as bool
    ..alertMessageBuzzer = v['alertMessageBuzzer']! as bool
    ..alertMessageVibra = v['alertMessageVibra']! as bool
    ..outputBuzzer = v['outputBuzzer']! as int
    ..outputVibra = v['outputVibra']! as int;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_ExternalNotificationConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'externalNotification',
    ModuleConfig(externalNotification: apply(base, v)),
  );
}
