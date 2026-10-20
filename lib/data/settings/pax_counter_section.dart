import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';

/// Модуль «Счетчик прохожих»: PaxCounterConfig.swift (iOS), те же поля в
/// Android. Подписи — iOS ru, затем английские (в Android ru ошибки:
/// «Интервал опроса GPS»).
abstract final class PaxCounterSection {
  static const title = 'Настройка счетчика прохожих';
  static const saveConfirm = 'Сохранить настройки счетчика прохожих?';

  /// Прошивка: 0 — по умолчанию (интервал 1 час, пороги -80 dBm).
  static const defaultInterval = 3600;
  static const defaultThreshold = -80;

  /// 0 показываем как «1 час» и сохраняем нулём (iOS displayDefault).
  static List<Choice> _intervals(Map<String, Object?> v) {
    final list = Intervals.choices(Intervals.paxCounter);
    if (v['paxcounterUpdateInterval'] != 0) return list;
    return [
      for (final c in list)
        c.value == defaultInterval ? (value: 0, label: c.label) : c,
    ];
  }

  static bool _on(Map<String, Object?> v) => v['enabled'] == true;

  static IntFieldSpec _threshold(String key, String label, String help) =>
      IntFieldSpec(
        key,
        label,
        help: help,
        min: -120,
        max: -1,
        unit: 'dBm',
        visibleWhen: _on,
      );

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'enabled',
      'PAX Counter Enabled',
      help:
          'При включении модуль прохожих подсчитывает количество людей, '
          'проходящих мимо, используя Wi-Fi и Bluetooth. Для работы счетчика '
          'количества человек как Wi-Fi, так и Bluetooth должны быть '
          'отключены.',
    ),
    ChoiceFieldSpec(
      'paxcounterUpdateInterval',
      'Интервал обновления',
      Intervals.choices(Intervals.paxCounter),
      optionsFor: _intervals,
      unknownLabel: Intervals.label,
      visibleWhen: _on,
      help:
          'How often we can send a message to the mesh when people are '
          'detected.',
    ),
    _threshold(
      'wifiThreshold',
      'WiFi Threshold',
      'RSSI threshold for counting WiFi devices.',
    ),
    _threshold(
      'bleThreshold',
      'BLE Threshold',
      'RSSI threshold for counting BLE devices.',
    ),
  ];

  /// Порог 0 показываем значением прошивки (-80): сохранить его — то же.
  static Map<String, Object?> read(ModuleConfig_PaxcounterConfig c) => {
    'enabled': c.enabled,
    'paxcounterUpdateInterval': c.paxcounterUpdateInterval,
    'wifiThreshold': c.wifiThreshold == 0 ? defaultThreshold : c.wifiThreshold,
    'bleThreshold': c.bleThreshold == 0 ? defaultThreshold : c.bleThreshold,
  };

  static ModuleConfig_PaxcounterConfig apply(
    ModuleConfig_PaxcounterConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..enabled = v['enabled']! as bool
    ..paxcounterUpdateInterval = v['paxcounterUpdateInterval']! as int
    ..wifiThreshold = v['wifiThreshold']! as int
    ..bleThreshold = v['bleThreshold']! as int;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_PaxcounterConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'paxcounter',
    ModuleConfig(paxcounter: apply(base, v)),
  );
}
