import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Модуль «Сохраненные сообщения»: CannedMessagesConfig.swift (iOS).
/// Устаревшие enabled и allow_input_source не показываем (как iOS), их
/// значения сохраняются через deepCopy. Сам текст сообщений — отдельная
/// админ-команда, см. [cannedMessages] в node_text.dart.
abstract final class CannedMessageSection {
  static const title = 'Конфигурация сохраненных сообщений';
  static const saveConfirm = 'Сохранить настройки сохраненных сообщений?';
  static const groupOptions = 'Параметры';
  static const groupPresets = 'Пресеты';
  static const groupControl = 'Тип управления';
  static const groupInputs = 'Входы';
  static const groupKeys = 'Назначение клавиш';

  /// Ключ формы для пресета; в протоколе его нет.
  static const preset = 'preset';

  static const _e = ModuleConfig_CannedMessageConfig_InputEventChar.values;

  /// Варианты событий — английские, как в iOS.
  static final events = <Choice>[
    (value: 0, label: 'None'),
    (value: 10, label: 'Select'),
    (value: 17, label: 'Up'),
    (value: 18, label: 'Down'),
    (value: 19, label: 'Left'),
    (value: 20, label: 'Right'),
    (value: 24, label: 'Cancel'),
    (value: 27, label: 'Back'),
  ];

  static const presets = <Choice>[
    (value: 0, label: 'Manual Configuration'),
    (value: 1, label: 'RAK Rotary Encoder'),
    (value: 2, label: 'M5 Stack Card KB / RAK Keypad'),
  ];

  /// Значения пресетов (iOS ConfigPresets).
  static const _presetValues = <int, Map<String, Object?>>{
    1: {
      'updown1Enabled': true,
      'rotary1Enabled': false,
      'inputbrokerPinA': 4,
      'inputbrokerPinB': 10,
      'inputbrokerPinPress': 9,
      'inputbrokerEventCw': 18,
      'inputbrokerEventCcw': 17,
      'inputbrokerEventPress': 10,
    },
    2: {
      'updown1Enabled': false,
      'rotary1Enabled': false,
      'inputbrokerPinA': 0,
      'inputbrokerPinB': 0,
      'inputbrokerPinPress': 0,
      'inputbrokerEventCw': 0,
      'inputbrokerEventCcw': 0,
      'inputbrokerEventPress': 0,
    },
  };

  static bool _manual(Map<String, Object?> v) => v[preset] == 0;

  static IntFieldSpec _pin(String key, String label) => IntFieldSpec(
    key,
    label,
    group: groupInputs,
    min: 0,
    max: 255,
    enabledWhen: _manual,
  );

  static ChoiceFieldSpec _event(String key, String label) => ChoiceFieldSpec(
    key,
    label,
    events,
    group: groupKeys,
    enabledWhen: _manual,
  );

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec('sendBell', 'Отправить колокол', group: groupOptions),
    const ChoiceFieldSpec(
      preset,
      'Преднастройки конфигурации',
      presets,
      group: groupPresets,
    ),
    BoolFieldSpec(
      'rotary1Enabled',
      'Поворотный 1',
      group: groupControl,
      enabledWhen: (v) => _manual(v) && v['updown1Enabled'] != true,
    ),
    BoolFieldSpec(
      'updown1Enabled',
      'Вверх вниз 1',
      group: groupControl,
      enabledWhen: (v) => _manual(v) && v['rotary1Enabled'] != true,
    ),
    _pin('inputbrokerPinA', 'Pin A'),
    _pin('inputbrokerPinB', 'Pin B'),
    _pin('inputbrokerPinPress', 'Контакт нажатия'),
    _event('inputbrokerEventCw', 'Вращение по часовой стрелке'),
    _event('inputbrokerEventCcw', 'Вращение энкодера против часовой стрелки'),
    _event('inputbrokerEventPress', 'Событие нажатия энкодера'),
  ];

  /// Выбранный пресет переписывает поля управления.
  static void adjust(Map<String, Object?> v) {
    final p = _presetValues[v[preset]];
    if (p != null) v.addAll(p);
  }

  static Map<String, Object?> read(ModuleConfig_CannedMessageConfig c) => {
    'sendBell': c.sendBell,
    preset: 0,
    'rotary1Enabled': c.rotary1Enabled,
    'updown1Enabled': c.updown1Enabled,
    'inputbrokerPinA': c.inputbrokerPinA,
    'inputbrokerPinB': c.inputbrokerPinB,
    'inputbrokerPinPress': c.inputbrokerPinPress,
    'inputbrokerEventCw': c.inputbrokerEventCw.value,
    'inputbrokerEventCcw': c.inputbrokerEventCcw.value,
    'inputbrokerEventPress': c.inputbrokerEventPress.value,
  };

  static ModuleConfig_CannedMessageConfig_InputEventChar _ev(Object? v) =>
      _e.firstWhere((e) => e.value == v, orElse: () => _e.first);

  static ModuleConfig_CannedMessageConfig apply(
    ModuleConfig_CannedMessageConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..sendBell = v['sendBell']! as bool
    ..rotary1Enabled = v['rotary1Enabled']! as bool
    ..updown1Enabled = v['updown1Enabled']! as bool
    ..inputbrokerPinA = v['inputbrokerPinA']! as int
    ..inputbrokerPinB = v['inputbrokerPinB']! as int
    ..inputbrokerPinPress = v['inputbrokerPinPress']! as int
    ..inputbrokerEventCw = _ev(v['inputbrokerEventCw'])
    ..inputbrokerEventCcw = _ev(v['inputbrokerEventCcw'])
    ..inputbrokerEventPress = _ev(v['inputbrokerEventPress']);

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_CannedMessageConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'cannedMessage',
    ModuleConfig(cannedMessage: apply(base, v)),
  );
}
