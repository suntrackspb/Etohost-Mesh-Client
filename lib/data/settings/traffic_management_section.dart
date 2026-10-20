import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';
import 'user_section.dart' show firmwareAtLeast;

/// Модуль «Управление движением»: TrafficManagementConfig.swift (iOS).
/// В схеме 2.8 нет флагов: функция включена, когда её значение не 0. Как в
/// iOS, у каждой функции свой выключатель (ключи формы, не протокола), общий
/// выключатель только показывает разделы, а выключенный — обнуляет всё.
/// В Android экрана нет, но есть ru-подписи — берём их, иначе английские iOS.
abstract final class TrafficManagementSection {
  static const title = 'Настройка управления движением';
  static const saveConfirm = 'Сохранить настройки управления движением?';
  static const groupOptions = 'Параметры';
  static const groupPosition = 'Удаление дубликатов позиций';
  static const groupNodeInfo = 'Прямой ответ NodeInfo';
  static const groupRate = 'Ограничение скорости';
  static const groupUnknown = 'Unknown Packet Handling';

  static const needs28 =
      'Настройки управления движением в этом приложении — по схеме '
      'прошивки 2.8. Обновите прошивку ноды.';
  static const rateNeedsCount =
      'Для ограничения скорости задайте и окно, и число пакетов.';

  /// Схема без флагов — с прошивки 2.8.
  static bool supported(String firmware) => firmwareAtLeast(firmware, 2, 8);

  static const on = 'on';

  /// Выключатель функции → (поле значения, значение при включении, iOS).
  static const _toggles = {
    'positionDedup': ('positionMinIntervalSecs', 18000),
    'nodeinfoDirect': ('nodeinfoDirectResponseMaxHops', 1),
    'rateLimit': ('rateLimitWindowSecs', 60),
    'dropUnknown': ('unknownPacketThreshold', 10),
  };

  static const _values = [
    'positionMinIntervalSecs',
    'nodeinfoDirectResponseMaxHops',
    'rateLimitWindowSecs',
    'rateLimitMaxPackets',
    'unknownPacketThreshold',
  ];

  static bool _main(Map<String, Object?> v) => v[on] == true;
  static bool Function(Map<String, Object?>) _shown(String toggle) =>
      (v) => _main(v) && v[toggle] == true;

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(on, 'Включен', group: groupOptions),
    const BoolFieldSpec(
      'positionDedup',
      'Удаление дубликатов позиций',
      group: groupPosition,
      visibleWhen: _main,
    ),
    ChoiceFieldSpec(
      'positionMinIntervalSecs',
      'Мин. интервал позиционирования (сек)',
      Intervals.choices(Intervals.trafficPositionDedup),
      group: groupPosition,
      visibleWhen: _shown('positionDedup'),
      unknownLabel: Intervals.label,
      help:
          'Positions from the same node arriving sooner than this are '
          'dropped.',
    ),
    const BoolFieldSpec(
      'nodeinfoDirect',
      'Прямой ответ NodeInfo',
      group: groupNodeInfo,
      visibleWhen: _main,
    ),
    // Прошивка ограничивает 3 хопами — больше не предлагаем (iOS).
    ChoiceFieldSpec(
      'nodeinfoDirectResponseMaxHops',
      'Макс кол-во хопов для прямых сообщений',
      const [
        (value: 1, label: '1'),
        (value: 2, label: '2'),
        (value: 3, label: '3'),
      ],
      group: groupNodeInfo,
      visibleWhen: _shown('nodeinfoDirect'),
      help: 'Only answer requestors within this many hops.',
    ),
    const BoolFieldSpec(
      'rateLimit',
      'Ограничение скорости',
      group: groupRate,
      visibleWhen: _main,
    ),
    ChoiceFieldSpec(
      'rateLimitWindowSecs',
      'Окно ограничения скорости (сек.)',
      Intervals.choices(Intervals.trafficRateLimitWindow),
      group: groupRate,
      visibleWhen: _shown('rateLimit'),
      unknownLabel: Intervals.label,
      help: 'The time window packets are counted over.',
    ),
    IntFieldSpec(
      'rateLimitMaxPackets',
      'Макс пакетов в окне',
      group: groupRate,
      visibleWhen: _shown('rateLimit'),
      min: 0,
      max: 10000,
      help: 'The most packets one node may send per window.',
    ),
    const BoolFieldSpec(
      'dropUnknown',
      'Отбрасывать неизвестные пакеты',
      group: groupUnknown,
      visibleWhen: _main,
    ),
    IntFieldSpec(
      'unknownPacketThreshold',
      'Порог передач неизвестных пакетов',
      group: groupUnknown,
      visibleWhen: _shown('dropUnknown'),
      min: 1,
      max: 10000,
      help: 'How many per window before the sender is dropped.',
    ),
  ];

  /// Выключатели ↔ значения; главный выключатель выкл. — всё в ноль.
  static void adjust(Map<String, Object?> v) {
    if (!_main(v)) {
      for (final k in _toggles.keys) {
        v[k] = false;
      }
    }
    for (final MapEntry(key: t, value: (field, onValue)) in _toggles.entries) {
      if (v[t] != true) {
        v[field] = 0;
      } else if (v[field] == 0) {
        v[field] = onValue;
      }
    }
    // Окно и число — одна функция: без окна нет и числа (iOS reconcile).
    if (v['rateLimitWindowSecs'] == 0) v['rateLimitMaxPackets'] = 0;
  }

  static String? check(Map<String, Object?> v) =>
      v['rateLimit'] == true && v['rateLimitMaxPackets'] == 0
      ? rateNeedsCount
      : null;

  static Map<String, Object?> read(ModuleConfig_TrafficManagementConfig c) {
    final v = <String, Object?>{
      'positionMinIntervalSecs': c.positionMinIntervalSecs,
      'nodeinfoDirectResponseMaxHops': c.nodeinfoDirectResponseMaxHops,
      'rateLimitWindowSecs': c.rateLimitWindowSecs,
      'rateLimitMaxPackets': c.rateLimitMaxPackets,
      'unknownPacketThreshold': c.unknownPacketThreshold,
    };
    v[on] = _values.any((k) => v[k] != 0);
    for (final MapEntry(key: t, value: (field, _)) in _toggles.entries) {
      v[t] = v[field] != 0;
    }
    return v;
  }

  static ModuleConfig_TrafficManagementConfig apply(
    ModuleConfig_TrafficManagementConfig base,
    Map<String, Object?> v,
  ) {
    final a = Map.of(v);
    adjust(a);
    return base.deepCopy()
      ..positionMinIntervalSecs = a['positionMinIntervalSecs']! as int
      ..nodeinfoDirectResponseMaxHops =
          a['nodeinfoDirectResponseMaxHops']! as int
      ..rateLimitWindowSecs = a['rateLimitWindowSecs']! as int
      ..rateLimitMaxPackets = a['rateLimitMaxPackets']! as int
      ..unknownPacketThreshold = a['unknownPacketThreshold']! as int;
  }

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_TrafficManagementConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'trafficManagement',
    ModuleConfig(trafficManagement: apply(base, v)),
  );
}
