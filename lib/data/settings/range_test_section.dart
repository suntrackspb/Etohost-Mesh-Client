import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';

/// Ключ канала публичный: пустой или однобайтовый ключ по умолчанию
/// (как в iOS и Android).
bool isPublicPsk(List<int>? psk) => (psk?.length ?? 0) < 2;

/// Модуль «Тест дальности»: RangeTestConfig.swift (iOS). Подписи — iOS ru,
/// затем Android ru, затем английские. Как в обоих клиентах: на публичном
/// основном канале модуль не включается (засоряет общую сеть).
abstract final class RangeTestSection {
  static const title = 'Настройка теста дальности';
  static const saveConfirm = 'Сохранить настройки теста дальности?';
  static const groupOptions = 'Параметры';
  static const publicChannel =
      'Range test requires an encrypted private channel. The primary channel '
      'on this node is using a default or empty key.';

  static List<FieldSpec<Object?>> fields({
    required bool hasWifi,
    required bool primaryPublic,
  }) => [
    BoolFieldSpec(
      'enabled',
      'Проверка дальности включена',
      group: groupOptions,
      enabledWhen: (_) => !primaryPublic,
      help: 'Enable range test module',
    ),
    ChoiceFieldSpec(
      'sender',
      'Sender Interval',
      Intervals.choices(Intervals.rangeTestSender),
      group: groupOptions,
      enabledWhen: (_) => !primaryPublic,
      unknownLabel: Intervals.label,
      help:
          'This device will send out range test messages on the selected '
          'interval. 0 disables sending.',
    ),
    // CSV раздаёт веб-сервер ноды — нужен Wi-Fi (iOS).
    BoolFieldSpec(
      'save',
      'Сохранить',
      group: groupOptions,
      enabledWhen: (_) => hasWifi && !primaryPublic,
      help:
          'Сохраняет CSV с деталями сообщений тестирования дальности, в '
          'настоящее время доступно только на устройствах ESP32 с '
          'веб-сервером.',
    ),
  ];

  static Map<String, Object?> read(ModuleConfig_RangeTestConfig c) => {
    'enabled': c.enabled,
    'sender': c.sender,
    'save': c.save,
  };

  /// На публичном основном канале модуль всегда выключаем (Android).
  static ModuleConfig_RangeTestConfig apply(
    ModuleConfig_RangeTestConfig base,
    Map<String, Object?> v, {
    required bool primaryPublic,
  }) => base.deepCopy()
    ..enabled = !primaryPublic && v['enabled']! as bool
    ..sender = v['sender']! as int
    ..save = v['save']! as bool;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_RangeTestConfig base,
    Map<String, Object?> v, {
    required bool primaryPublic,
  }) => saveModuleConfig(
    admin,
    db,
    'rangeTest',
    ModuleConfig(rangeTest: apply(base, v, primaryPublic: primaryPublic)),
  );
}
