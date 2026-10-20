import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Модуль «Сохранить и переслать»: StoreForwardConfig.swift (iOS), поля
/// записей и истории — числами, как в Android. Окно истории в прошивке —
/// минуты (у iOS варианты подписаны секундами, это неверно).
abstract final class StoreForwardSection {
  static const title = 'Настройка сохранения и пересылки';
  static const saveConfirm = 'Сохранить настройки Store & Forward?';
  static const groupOptions = 'Параметры';
  static const groupSettings = 'Настройки';
  static const groupServer = 'Параметры сервера';
  static const serverNote =
      'Серверы сохранения и пересылки требуют устройство ESP32 с PSRAM или '
      'Linux Native.';

  static bool _on(Map<String, Object?> v) => v['enabled'] == true;

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'enabled',
      'Store & Forward включена',
      group: groupOptions,
      help: 'Включает модуль хранения и пересылки.',
    ),
    const BoolFieldSpec(
      'heartbeat',
      'Отправить сердцебиение',
      group: groupSettings,
      visibleWhen: _on,
      help: 'Отправить heartbeat для оповещения о присутствии сервера.',
    ),
    const IntFieldSpec(
      'records',
      'Количество записей',
      group: groupSettings,
      visibleWhen: _on,
      min: 0,
      max: 1000000,
      help:
          'Maximum number of messages to store. 0 uses three quarters of '
          'free PSRAM.',
    ),
    const IntFieldSpec(
      'historyReturnMax',
      'Максимальное возвращение истории',
      group: groupSettings,
      visibleWhen: _on,
      min: 0,
      max: 1000000,
      help:
          'Maximum number of stored messages returned per request. 0 uses 25.',
    ),
    const IntFieldSpec(
      'historyReturnWindow',
      'Временное окно возврата истории',
      group: groupSettings,
      visibleWhen: _on,
      min: 0,
      max: 1000000,
      unit: 'мин',
      help:
          'How far back, in minutes, stored messages are returned. 0 uses '
          '240.',
    ),
    const BoolFieldSpec(
      'isServer',
      'Сервер',
      group: groupServer,
      visibleWhen: _on,
      help:
          'Включить это устройство как сервер хранения и пересылки. '
          'Требуется устройство ESP32 с PSRAM.',
    ),
  ];

  /// Предупреждение под формой (как trailing в iOS).
  static bool showServerNote(Map<String, Object?> v) =>
      _on(v) && v['isServer'] == true;

  static Map<String, Object?> read(ModuleConfig_StoreForwardConfig c) => {
    'enabled': c.enabled,
    'heartbeat': c.heartbeat,
    'records': c.records,
    'historyReturnMax': c.historyReturnMax,
    'historyReturnWindow': c.historyReturnWindow,
    'isServer': c.isServer,
  };

  static ModuleConfig_StoreForwardConfig apply(
    ModuleConfig_StoreForwardConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..enabled = v['enabled']! as bool
    ..heartbeat = v['heartbeat']! as bool
    ..records = v['records']! as int
    ..historyReturnMax = v['historyReturnMax']! as int
    ..historyReturnWindow = v['historyReturnWindow']! as int
    ..isServer = v['isServer']! as bool;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_StoreForwardConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'storeForward',
    ModuleConfig(storeForward: apply(base, v)),
  );
}
