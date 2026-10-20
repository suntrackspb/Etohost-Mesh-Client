import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';

/// Раздел «Позиция»: PositionConfig.swift (iOS). Подписи — ru iOS, иначе
/// ru Android, иначе английские; названия режимов GPS — английские.
/// Флаги позиции — отдельные переключатели `flag<бит>` поверх битовой маски.
/// Фиксированная позиция ставится/снимается отдельной командой сразу
/// (set/remove_fixed_position), как в iOS, и в форму не входит.
abstract final class PositionSection {
  static const title = 'Настройка позиции';
  static const groupPacket = 'Пакет позиции';
  static const groupGps = 'Устройство GPS';
  static const groupFlags = 'Флаги позиции';
  static const groupAdvanced = 'Расширенное устройство GPS';
  static const saveConfirm = 'Сохранить настройки позиции?';

  static const gpsDisabled = 0, gpsEnabled = 1, gpsNotPresent = 2;
  static const gpsModes = <Choice>[
    (value: 0, label: 'Disabled'),
    (value: 1, label: 'Enabled'),
    (value: 2, label: 'Not Present'),
  ];

  static const fixedLabel = 'Фиксированная позиция';
  static const fixedHelp =
      'The last known latitude, longitude and altitude are broadcast over the '
      'mesh on the position interval, rather than a live GPS fix.';
  static const setFixedTitle = 'Set Fixed Position';
  static const removeFixedTitle = 'Remove Fixed Position';
  static const setFixedText =
      'Это отправит текущую позицию с вашего телефона и включит фиксированную '
      'позицию.';
  static const removeFixedText =
      'Это отключит фиксированную позицию и удалит текущую установленную '
      'позицию.';

  /// Флаги в порядке iOS: (бит, подпись, пояснение, родительский бит).
  static const flags = <(int, String, String?, int?)>[
    (
      1,
      'Высота',
      'Include an altitude value in position reports, when one is available.',
      null,
    ),
    (2, 'Высота над уровнем моря', null, 1),
    (4, 'Значение коррекции высоты', null, 1),
    (32, 'Количество спутников', null, null),
    (64, 'Порядковый номер', null, null),
    (128, 'Отметка времени', null, null),
    (512, 'Направление транспорта', null, null),
    (256, 'Скорость транспорта', null, null),
    (
      8,
      'DOP',
      'Include the dilution of precision value. PDOP is used by default.',
      null,
    ),
    (
      16,
      'HDOP / VDOP',
      'If DOP is set, send separate HDOP and VDOP values instead of PDOP.',
      8,
    ),
  ];

  static String flagKey(int bit) => 'flag$bit';

  static bool _gpsOn(Map<String, Object?> v) => v['gpsMode'] == gpsEnabled;
  static bool _smart(Map<String, Object?> v) =>
      v['positionBroadcastSmartEnabled'] == true;

  /// Фиксированную позицию можно включить без GPS (или выключить, если она
  /// уже стоит) — как в iOS.
  static bool fixedAvailable(int gpsMode, bool fixed) =>
      gpsMode != gpsEnabled || fixed;

  static List<FieldSpec<Object?>> fields() => [
    ChoiceFieldSpec(
      'positionBroadcastSecs',
      'Период рассылки',
      Intervals.choices(Intervals.broadcastMedium),
      group: groupPacket,
      unknownLabel: Intervals.label,
      help: 'Максимальное время между передачами позиции нодой.',
    ),
    const BoolFieldSpec(
      'positionBroadcastSmartEnabled',
      'Умное позиционирование',
      group: groupPacket,
    ),
    ChoiceFieldSpec(
      'broadcastSmartMinimumIntervalSecs',
      'Умный интервал',
      Intervals.choices(Intervals.smartMinimum),
      group: groupPacket,
      visibleWhen: _smart,
      unknownLabel: Intervals.label,
      help:
          'The shortest interval between position updates once the minimum '
          'distance has been met.',
    ),
    ChoiceFieldSpec(
      'broadcastSmartMinimumDistance',
      'Минимальное расстояние',
      [for (var m = 10; m <= 150; m += 5) (value: m, label: '$m м')],
      group: groupPacket,
      visibleWhen: _smart,
      unknownLabel: (m) => '$m м',
      help: 'Минимальное расстояние для умной рассылки координаты.',
    ),
    const ChoiceFieldSpec(
      'gpsMode',
      'Режим GPS (физическое оборудование)',
      gpsModes,
      group: groupGps,
    ),
    ChoiceFieldSpec(
      'gpsUpdateInterval',
      'Интервал обновления',
      Intervals.choices(Intervals.gpsUpdate),
      group: groupGps,
      visibleWhen: _gpsOn,
      unknownLabel: Intervals.label,
      help:
          'Как часто запрашивать координаты GPS (<10 секунд держит GPS '
          'включенным постоянно).',
    ),
    for (final (i, (bit, label, help, parent)) in flags.indexed)
      BoolFieldSpec(
        flagKey(bit),
        label,
        group: groupFlags,
        help: i == 0
            ? 'Необязательные поля в сообщении о местоположении. Чем больше '
                  'полей включено, тем больше сообщение, а значит больше время '
                  'передачи и риск потери пакетов.\n${help ?? ''}'
            : help,
        visibleWhen: parent == null ? null : (v) => v[flagKey(parent)] == true,
      ),
    for (final (key, label, help) in const [
      ('rxGpio', 'GPIO приема GPS', 'GPIO pin for GPS RX'),
      ('txGpio', 'GPIO передачи GPS', 'GPIO pin for GPS TX'),
      ('gpsEnGpio', 'GPS EN GPIO', 'GPIO pin for GPS enable'),
    ])
      IntFieldSpec(
        key,
        label,
        group: groupAdvanced,
        visibleWhen: _gpsOn,
        min: 0,
        max: 255,
        help: help,
      ),
  ];

  static Map<String, Object?> read(Config_PositionConfig c) => {
    'positionBroadcastSecs': c.positionBroadcastSecs,
    'positionBroadcastSmartEnabled': c.positionBroadcastSmartEnabled,
    'broadcastSmartMinimumIntervalSecs': c.broadcastSmartMinimumIntervalSecs,
    'broadcastSmartMinimumDistance': c.broadcastSmartMinimumDistance,
    'gpsMode': c.gpsMode.value,
    'gpsUpdateInterval': c.gpsUpdateInterval,
    for (final f in flags) flagKey(f.$1): c.positionFlags & f.$1 != 0,
    'rxGpio': c.rxGpio,
    'txGpio': c.txGpio,
    'gpsEnGpio': c.gpsEnGpio,
  };

  /// Биты, которых нет в списке, сохраняются как были.
  static Config_PositionConfig apply(
    Config_PositionConfig base,
    Map<String, Object?> v,
  ) {
    var mask = base.positionFlags;
    for (final f in flags) {
      mask = v[flagKey(f.$1)] == true ? mask | f.$1 : mask & ~f.$1;
    }
    return base.deepCopy()
      ..positionBroadcastSecs = v['positionBroadcastSecs']! as int
      ..positionBroadcastSmartEnabled =
          v['positionBroadcastSmartEnabled']! as bool
      ..broadcastSmartMinimumIntervalSecs =
          v['broadcastSmartMinimumIntervalSecs']! as int
      ..broadcastSmartMinimumDistance =
          v['broadcastSmartMinimumDistance']! as int
      ..gpsMode = Config_PositionConfig_GpsMode.valueOf(v['gpsMode']! as int)!
      ..gpsUpdateInterval = v['gpsUpdateInterval']! as int
      ..positionFlags = mask
      ..rxGpio = v['rxGpio']! as int
      ..txGpio = v['txGpio']! as int
      ..gpsEnGpio = v['gpsEnGpio']! as int;
  }

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    Config_PositionConfig base,
    Map<String, Object?> v,
  ) => saveConfig(admin, db, 'position', Config(position: apply(base, v)));

  /// Включить фиксированную позицию с координатами телефона ([pos]) или
  /// снять её ([pos] == null). При подтверждении — отметить в сохранённом
  /// конфиге, чтобы экран не ждал перечитывания с ноды.
  static Future<bool> setFixed(
    AdminSettings admin,
    AppDatabase db,
    Config_PositionConfig base,
    Position? pos,
  ) async {
    final ok = await admin.send(
      pos == null
          ? AdminMessage(removeFixedPosition: true)
          : AdminMessage(setFixedPosition: pos),
    );
    if (ok) {
      await storeConfig(
        db,
        'position',
        Config(position: base.deepCopy()..fixedPosition = pos != null),
      );
    }
    return ok;
  }
}
