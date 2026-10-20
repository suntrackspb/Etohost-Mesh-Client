import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';

/// Модуль «Информация о соседях»: NeighborInfoConfig.swift (iOS), те же поля
/// в Android. Подписи — iOS ru, затем Android ru, затем английские.
abstract final class NeighborInfoSection {
  static const title = 'Настройки соседей';
  static const saveConfirm = 'Сохранить настройки информации о соседях?';
  static const groupOptions = 'Параметры';
  static const groupSettings = 'Настройки';

  /// 0 — по умолчанию прошивки (4 часа). Как в iOS: показываем «4 часа»,
  /// а нетронутое значение сохраняется нулём.
  static List<Choice> _intervals(Map<String, Object?> v) {
    final list = Intervals.choices(Intervals.neighborInfo);
    if (v['updateInterval'] != 0) return list;
    return [
      for (final c in list) c.value == 14400 ? (value: 0, label: c.label) : c,
    ];
  }

  static bool _on(Map<String, Object?> v) => v['enabled'] == true;

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'enabled',
      'Информация о соседях включена',
      group: groupOptions,
      help:
          'Enable neighbor info broadcasting. Periodically sends information '
          'about directly-heard neighbors to help visualize mesh topology.',
    ),
    ChoiceFieldSpec(
      'updateInterval',
      'Интервал обновления',
      Intervals.choices(Intervals.neighborInfo),
      optionsFor: _intervals,
      unknownLabel: Intervals.label,
      group: groupSettings,
      visibleWhen: _on,
      help: 'How often to broadcast neighbor info.',
    ),
    BoolFieldSpec(
      'transmitOverLora',
      'Передать через LoRa',
      group: groupSettings,
      visibleWhen: _on,
      help:
          'Whether to transmit neighbor info over LoRa in addition to MQTT '
          'and PhoneAPI. Not available on channels with default key and '
          'name.',
    ),
  ];

  static Map<String, Object?> read(ModuleConfig_NeighborInfoConfig c) => {
    'enabled': c.enabled,
    'updateInterval': c.updateInterval,
    'transmitOverLora': c.transmitOverLora,
  };

  static ModuleConfig_NeighborInfoConfig apply(
    ModuleConfig_NeighborInfoConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..enabled = v['enabled']! as bool
    ..updateInterval = v['updateInterval']! as int
    ..transmitOverLora = v['transmitOverLora']! as bool;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_NeighborInfoConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'neighborInfo',
    ModuleConfig(neighborInfo: apply(base, v)),
  );
}
