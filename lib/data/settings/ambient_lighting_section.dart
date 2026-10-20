import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Модуль «Окружающее освещение»: AmbientLightingConfig.swift (iOS), те же
/// поля в Android. Подписи — iOS ru, затем Android ru. Цвет — каналы 0–255
/// (в iOS один выбор цвета, в Android ещё и числа).
abstract final class AmbientLightingSection {
  static const title = 'Настройка окружающего освещения';
  static const saveConfirm = 'Сохранить настройки окружающего освещения?';
  static const groupOptions = 'Параметры';
  static const groupColor = 'Цвет';

  static IntFieldSpec _channel(String key, String label, String help) =>
      IntFieldSpec(key, label, group: groupColor, help: help, min: 0, max: 255);

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'ledState',
      'Состояние LED',
      group: groupOptions,
      help: 'Состояние LED (вкл/выкл)',
    ),
    // В реестре iOS ток ограничен 0–31.
    const IntFieldSpec(
      'current',
      'Ток',
      group: groupOptions,
      help: 'Ток управления для выхода светодиода.',
      min: 0,
      max: 31,
    ),
    _channel('red', 'Красный', 'Уровень красного канала светодиода подсветки.'),
    _channel(
      'green',
      'Зеленый',
      'Уровень зелёного канала светодиода подсветки.',
    ),
    _channel('blue', 'Синий', 'Уровень синего светодиода фоновой подсветки.'),
  ];

  /// Цвет 0xAARRGGBB для образца.
  static int argb(Map<String, Object?> v) =>
      0xFF000000 |
      ((v['red']! as int) << 16) |
      ((v['green']! as int) << 8) |
      (v['blue']! as int);

  static Map<String, Object?> read(ModuleConfig_AmbientLightingConfig c) => {
    'ledState': c.ledState,
    'current': c.current,
    'red': c.red,
    'green': c.green,
    'blue': c.blue,
  };

  static ModuleConfig_AmbientLightingConfig apply(
    ModuleConfig_AmbientLightingConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..ledState = v['ledState']! as bool
    ..current = v['current']! as int
    ..red = v['red']! as int
    ..green = v['green']! as int
    ..blue = v['blue']! as int;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_AmbientLightingConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'ambientLighting',
    ModuleConfig(ambientLighting: apply(base, v)),
  );
}
