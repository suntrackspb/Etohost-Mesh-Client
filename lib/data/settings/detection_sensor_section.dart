import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';

/// Модуль «Датчик обнаружения»: DetectionSensorConfig.swift (iOS), те же
/// поля в Android. Подписи — iOS ru, затем Android ru, затем английские.
/// Роль «датчик/клиент» в iOS — настройка приложения, не ноды; здесь её нет,
/// параметры датчика видны при включённом модуле.
abstract final class DetectionSensorSection {
  static const title = 'Настройка датчика обнаружения';
  static const saveConfirm = 'Сохранить настройки датчика обнаружения?';
  static const groupOptions = 'Параметры';
  static const groupSensor = 'Параметры датчика';
  static const groupInterval = 'Интервал обновления';

  static const _trigger = ModuleConfig_DetectionSensorConfig_TriggerType.values;

  /// Имена английские, как в iOS.
  static const triggers = <Choice>[
    (value: 0, label: 'Low'),
    (value: 1, label: 'High'),
    (value: 2, label: 'Falling Edge'),
    (value: 3, label: 'Rising Edge'),
    (value: 4, label: 'Either Edge Low'),
    (value: 5, label: 'Either Edge High'),
  ];

  static bool _on(Map<String, Object?> v) => v['enabled'] == true;

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'enabled',
      'Датчик определения включен',
      group: groupOptions,
      help:
          'Включает модуль датчика обнаружения. Его необходимо включить как '
          'на ноде с датчиком, так и на всех нодах, на которых вы хотите '
          'получать текстовые сообщения датчика обнаружения или '
          'просматривать журнал и график датчика обнаружения.',
    ),
    BoolFieldSpec(
      'sendBell',
      'Отправить колокол',
      group: groupSensor,
      visibleWhen: _on,
      help:
          'Отправьте ASCII колокольчик с предупреждающим сообщением. Полезно '
          'для срабатывания внешнего уведомления на колокольчик.',
    ),
    TextFieldSpec(
      'name',
      'Имя',
      group: groupSensor,
      visibleWhen: _on,
      // name max_size:20 — 19 байт и завершающий ноль.
      maxBytes: 19,
      help: 'Имя датчика для сообщений mesh-сети',
    ),
    IntFieldSpec(
      'monitorPin',
      'Контакт GPIO для мониторинга',
      group: groupSensor,
      visibleWhen: _on,
      min: 0,
      max: 255,
      help: 'GPIO pin watched for state changes.',
    ),
    ChoiceFieldSpec(
      'detectionTriggerType',
      'Тип триггера',
      triggers,
      group: groupSensor,
      visibleWhen: _on,
      help: 'Тип события-триггера',
    ),
    BoolFieldSpec(
      'usePullup',
      'Использует подтягивающий резистор',
      group: groupSensor,
      visibleWhen: _on,
      help:
          'Независимо от того, используется ли режим INPUT_PULLUP для вывода '
          'GPIO. Применимо только в том случае, если на выводе платы '
          'используются подтягивающие резисторы',
    ),
    ChoiceFieldSpec(
      'minimumBroadcastSecs',
      'Минимальное время между передачами обнаружения',
      Intervals.choices(Intervals.detectionMinimum),
      group: groupInterval,
      visibleWhen: _on,
      unknownLabel: Intervals.label,
      help: 'Минимальное время между передачами обнаружения.',
    ),
    ChoiceFieldSpec(
      'stateBroadcastSecs',
      'Интервал передачи состояния',
      Intervals.choices(Intervals.detectionState),
      group: groupInterval,
      visibleWhen: _on,
      unknownLabel: Intervals.label,
      help:
          'How often to send the detection sensor state to the mesh, '
          'whether or not anything was detected.',
    ),
  ];

  static Map<String, Object?> read(ModuleConfig_DetectionSensorConfig c) => {
    'enabled': c.enabled,
    'sendBell': c.sendBell,
    'name': c.name,
    'monitorPin': c.monitorPin,
    'detectionTriggerType': c.detectionTriggerType.value,
    'usePullup': c.usePullup,
    'minimumBroadcastSecs': c.minimumBroadcastSecs,
    'stateBroadcastSecs': c.stateBroadcastSecs,
  };

  static ModuleConfig_DetectionSensorConfig apply(
    ModuleConfig_DetectionSensorConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..enabled = v['enabled']! as bool
    ..sendBell = v['sendBell']! as bool
    ..name = v['name']! as String
    ..monitorPin = v['monitorPin']! as int
    ..detectionTriggerType = _trigger.firstWhere(
      (t) => t.value == v['detectionTriggerType'],
      orElse: () => base.detectionTriggerType,
    )
    ..usePullup = v['usePullup']! as bool
    ..minimumBroadcastSecs = v['minimumBroadcastSecs']! as int
    ..stateBroadcastSecs = v['stateBroadcastSecs']! as int;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_DetectionSensorConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'detectionSensor',
    ModuleConfig(detectionSensor: apply(base, v)),
  );
}
