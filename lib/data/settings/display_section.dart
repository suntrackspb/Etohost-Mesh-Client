import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';

/// Раздел «Экран»: DisplayConfig.swift (iOS). Варианты перечислений —
/// английские, как в iOS. compass_north_top (прошивка игнорирует с 2.7.2),
/// use_long_node_name и enable_message_bubbles не редактируются, как в iOS,
/// и сохраняются как есть.
abstract final class DisplaySection {
  static const title = 'Настройки экрана';
  static const groupScreen = 'Экран устройства';
  static const groupTiming = 'Выбор времени и переопределения';
  static const saveConfirm = 'Сохранить настройки экрана?';

  /// ScreenOnIntervals (iOS); год — «всегда включен».
  static const alwaysOn = 31536000;
  static const screenOn = [15, 30, 60, 300, 600, 900, 1800, 3600, alwaysOn];

  /// ScreenCarouselIntervals (iOS); 0 — выключено.
  static const carousel = [0, 15, 30, 60, 300, 600, 900];

  static const compassOrientations = <Choice>[
    (value: 0, label: '0°'),
    (value: 1, label: '90°'),
    (value: 2, label: '180°'),
    (value: 3, label: '270°'),
    (value: 4, label: '0° Inverted'),
    (value: 5, label: '90° Inverted'),
    (value: 6, label: '180° Inverted'),
    (value: 7, label: '270° Inverted'),
  ];

  static const units = <Choice>[
    (value: 0, label: 'Metric'),
    (value: 1, label: 'Imperial'),
  ];

  static const displayModes = <Choice>[
    (value: 0, label: 'Default 128x64 screen layout'),
    (value: 1, label: 'Optimized for 2 color displays'),
    (value: 2, label: 'Inverted top bar for 2 Color display'),
    (value: 3, label: 'TFT Full Color Displays'),
  ];

  /// Четыре типа, как в iOS: у двух новых пока нет подписей (protobufs#1103).
  static const oledTypes = <Choice>[
    (value: 0, label: 'Detect Automatically'),
    (value: 1, label: 'SSD 1306'),
    (value: 2, label: 'SH 1106'),
    (value: 3, label: 'SH 1107'),
  ];
  static const _otherOled = {4: 'SH 1107 128x128', 5: 'SH 1107 Rotated'};

  static String _screenOnLabel(int s) =>
      s == alwaysOn ? 'Всегда включен' : Intervals.label(s);
  static String _carouselLabel(int s) =>
      s == 0 ? 'Выключено' : Intervals.label(s);

  static List<FieldSpec<Object?>> fields() => [
    const ChoiceFieldSpec(
      'compassOrientation',
      'Направление компаса',
      compassOrientations,
      group: groupScreen,
      help:
          'Указывает, как повернуть или инвертировать вывод компаса для '
          'точного отображения.',
    ),
    const BoolFieldSpec(
      'use12hClock',
      '12-часовой формат',
      group: groupScreen,
      help: 'Устанавливает 12-часовой формат экранных часов.',
    ),
    const BoolFieldSpec(
      'headingBold',
      'Жирный заголовок',
      group: groupScreen,
      help: 'Выделять жирным шрифтом текст заголовка на экране.',
    ),
    const ChoiceFieldSpec(
      'units',
      'Единицы измерения на экране',
      units,
      group: groupScreen,
      help: 'Единицы измерения, отображаемые на экране устройства.',
    ),
    ChoiceFieldSpec(
      'screenOnSecs',
      'Экран включен на',
      [for (final s in screenOn) (value: s, label: _screenOnLabel(s))],
      group: groupTiming,
      unknownLabel: _screenOnLabel,
      help:
          'Как долго экран остается включенным после нажатия кнопки '
          'пользователя или получения сообщений.',
    ),
    ChoiceFieldSpec(
      'autoScreenCarouselSecs',
      'Интервал карусели',
      [for (final s in carousel) (value: s, label: _carouselLabel(s))],
      group: groupTiming,
      unknownLabel: _carouselLabel,
      help:
          'Автоматически переключает на следующую страницу на экране как '
          'карусель, основываясь на заданном интервале.',
    ),
    const BoolFieldSpec(
      'wakeOnTapOrMotion',
      'Экран пробуждения при нажатии или движении',
      group: groupTiming,
      help: 'Требуется наличие акселерометра на вашем устройстве.',
    ),
    const BoolFieldSpec(
      'flipScreen',
      'Перевернуть экран',
      group: groupTiming,
      help: 'Перевернуть экран вертикально',
    ),
    const ChoiceFieldSpec(
      'displaymode',
      'Режим экрана',
      displayModes,
      group: groupTiming,
      help: 'Переопределить макет экрана по умолчанию',
    ),
    ChoiceFieldSpec(
      'oled',
      'Тип OLED',
      oledTypes,
      group: groupTiming,
      unknownLabel: (v) => _otherOled[v] ?? '$v',
      help: 'Переопределить автоматическое обнаружение OLED-экрана.',
    ),
  ];

  static Map<String, Object?> read(Config_DisplayConfig c) => {
    'compassOrientation': c.compassOrientation.value,
    'use12hClock': c.use12hClock,
    'headingBold': c.headingBold,
    'units': c.units.value,
    'screenOnSecs': c.screenOnSecs,
    'autoScreenCarouselSecs': c.autoScreenCarouselSecs,
    'wakeOnTapOrMotion': c.wakeOnTapOrMotion,
    'flipScreen': c.flipScreen,
    'displaymode': c.displaymode.value,
    'oled': c.oled.value,
  };

  static Config_DisplayConfig apply(
    Config_DisplayConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..compassOrientation = Config_DisplayConfig_CompassOrientation.valueOf(
      v['compassOrientation']! as int,
    )!
    ..use12hClock = v['use12hClock']! as bool
    ..headingBold = v['headingBold']! as bool
    ..units = Config_DisplayConfig_DisplayUnits.valueOf(v['units']! as int)!
    ..screenOnSecs = v['screenOnSecs']! as int
    ..autoScreenCarouselSecs = v['autoScreenCarouselSecs']! as int
    ..wakeOnTapOrMotion = v['wakeOnTapOrMotion']! as bool
    ..flipScreen = v['flipScreen']! as bool
    ..displaymode = Config_DisplayConfig_DisplayMode.valueOf(
      v['displaymode']! as int,
    )!
    ..oled = Config_DisplayConfig_OledType.valueOf(v['oled']! as int)!;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    Config_DisplayConfig base,
    Map<String, Object?> v,
  ) => saveConfig(admin, db, 'display', Config(display: apply(base, v)));
}
