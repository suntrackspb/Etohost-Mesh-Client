import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';

/// Раздел «Устройство»: DeviceConfig.swift (iOS) + DeviceConfigScreen.kt
/// (Android: часовой пояс телефона). Названия ролей и режимов — английские,
/// как в iOS; описания — ru Android, иначе английские. buzzer_mode не
/// редактируется (как в iOS) и сохраняется как есть.
abstract final class DeviceSection {
  static const title = 'Настройка устройства';
  static const groupOptions = 'Параметры';
  static const groupHardware = 'Оборудование';
  static const groupDebug = 'Отладка';
  static const groupGpio = 'GPIO';
  static const saveConfirm = 'Сохранить настройки устройства?';

  /// Роли в порядке iOS (DeviceRoles); устаревшие — только если уже выбраны.
  static const roles = <Choice>[
    (value: 0, label: 'Client'),
    (value: 1, label: 'Client Mute'),
    (value: 8, label: 'Client Hidden'),
    (value: 5, label: 'Tracker'),
    (value: 9, label: 'Lost and Found'),
    (value: 6, label: 'Sensor'),
    (value: 7, label: 'TAK'),
    (value: 10, label: 'TAK Tracker'),
    (value: 2, label: 'Router'),
    (value: 11, label: 'Router Late'),
    (value: 12, label: 'Client Base'),
  ];

  static const _deprecatedRoles = {3: 'Router Client', 4: 'Repeater'};

  static const _roleHelp = {
    0: 'Приложение подключено или автономное устройство обмена сообщениями.',
    1: 'Устройство, которое не пересылает пакеты с других устройств.',
    2:
        'Infrastructure node on a tower or mountain top only.  Not to be used '
        'for roofs or mobile nodes.  Needs exceptional coverage. Visible in '
        'Nodes list.',
    4:
        'Устаревшая инфраструктурная роль, создающая разрывы в цепочке '
        'ретрансляции mesh-сети. Переключите эту ноду на роль на основе Router '
        '(Router или Router Late).',
    5: 'Транслирует пакеты местоположения GPS в приоритетном порядке.',
    6: 'Транслирует пакеты телеметрии в приоритетном порядке.',
    7: 'Оптимизировано для связи с системой ATAK, сокращает текущие передачи.',
    8:
        'Устройство, которое передает сигнал только при необходимости для '
        'скрытности или экономии энергии.',
    9:
        'Регулярно отправляет местоположение в виде сообщения в основной '
        'канал, чтобы помочь с восстановлением устройства.',
    10:
        'Включает автоматические трансляции TAK PLI и сокращает рутинные '
        'трансляции.',
    11:
        'Инфраструктурная нода, которая всегда ретранслирует пакеты один раз, '
        'но только после всех остальных режимов. Отображается в списке нод. '
        'Не лучший выбор для нод на крышах.',
    12:
        'Used for rooftop nodes to distribute messages more widely from '
        'multiple nearby client mute nodes.',
  };

  static const _routerWarning =
      'The Router roles are only for high vantage locations like mountaintops '
      'and towers with few nearby nodes, not for use in urban areas. Improper '
      'use will hurt your local mesh.';
  static const _clientBaseWarning =
      "Switching to Client Base will clear this node's favorites. Client Base "
      'should only favorite other nodes you control. Improper use will hurt '
      'your local mesh.';

  static const rebroadcastModes = <Choice>[
    (value: 0, label: 'All'),
    (value: 1, label: 'All Skip Decoding'),
    (value: 2, label: 'Local Only'),
    (value: 3, label: 'Known Only'),
    (value: 4, label: 'None'),
    (value: 5, label: 'Core Portnums Only'),
  ];

  static const _rebroadcastHelp = {
    0:
        'Rebroadcast any observed message, if it was on our private channel or '
        'from another channel with the same lora params.',
    1:
        'Same as behavior as ALL but skips packet decoding and simply '
        'rebroadcasts them. Only available in Repeater role. Setting this on '
        'any other roles will result in ALL behavior.',
    2:
        'Ignores observed messages from foreign meshes that are open or those '
        'which it cannot decrypt. Only rebroadcasts message on the nodes local '
        'primary / secondary channels.',
    3:
        "Ignores observed messages from foreign meshes like Local Only, but "
        "takes it step further by also ignoring messages from nodes not "
        "already in the node's known list.",
    4:
        'Only permitted for SENSOR, TRACKER and TAK_TRACKER roles, this will '
        'inhibit all rebroadcasts, not unlike CLIENT_MUTE role.',
    5:
        'Only rebroadcasts packets from the core portnums: NodeInfo, Text, '
        'Position, Telemetry, and Routing.',
  };

  /// tzdef: 65 байт в прошивке, iOS режет до 63.
  static const tzBytes = 63;

  static List<FieldSpec<Object?>> fields() => [
    ChoiceFieldSpec(
      'role',
      'Роль устройства',
      roles,
      group: groupOptions,
      unknownLabel: (r) => _deprecatedRoles[r] ?? '$r',
      helpFor: (r) => [
        ?_roleHelp[r],
        if (_deprecatedRoles.containsKey(r))
          'This role is deprecated. Select a Router-based role to keep this '
              'node on a supported configuration.',
      ].join('\n\n'),
      confirmFor: (r) => switch (r) {
        2 || 11 => _routerWarning,
        12 => _clientBaseWarning,
        _ => null,
      },
    ),
    ChoiceFieldSpec(
      'rebroadcastMode',
      'Режим повторной передачи',
      rebroadcastModes,
      group: groupOptions,
      helpFor: (m) => _rebroadcastHelp[m],
    ),
    ChoiceFieldSpec(
      'nodeInfoBroadcastSecs',
      'Интервал вещания передачи информации об узле',
      Intervals.choices(Intervals.broadcastLong),
      group: groupOptions,
      unknownLabel: Intervals.label,
      help: 'How often node information is sent. Defaults to 900 seconds.',
    ),
    const BoolFieldSpec(
      'doubleTapAsButtonPress',
      'Двойной тап как кнопка',
      group: groupHardware,
      help:
          'Считать двойное нажатие на поддерживаемых акселерометрах как '
          'нажатие пользовательской кнопки.',
    ),
    const BoolFieldSpec(
      'disableTripleClick',
      'Отключить тройное нажатие кнопки',
      group: groupHardware,
      help:
          'Отключает горячую клавишу тройного нажатия пользовательской кнопки.',
    ),
    const BoolFieldSpec(
      'ledHeartbeat',
      'Пульс LED',
      group: groupHardware,
      help:
          'Управляет мигающим светодиодом на устройстве. Для большинства '
          'устройств это будет управлять одним из максимум 4 светодиодов, '
          'светодиоды зарядки и GPS не управляются.',
    ),
    const TextFieldSpec(
      'tzdef',
      'Часовой пояс',
      group: groupDebug,
      maxBytes: tzBytes,
      help: 'Строка определения часового пояса POSIX',
    ),
    const IntFieldSpec(
      'buttonGpio',
      'GPIO кнопки',
      group: groupGpio,
      min: 0,
      max: 255,
      help:
          'GPIO-вывод для пользовательской кнопки; можно переназначить на '
          'платах с несколькими кнопками',
    ),
    const IntFieldSpec(
      'buzzerGpio',
      'GPIO зуммер',
      group: groupGpio,
      min: 0,
      max: 255,
      help: 'GPIO-вывод для ШИМ-зуммера',
    ),
  ];

  /// Как normalize в iOS: Router Client показывается как Client Mute,
  /// интервал NodeInfo не меньше 3 часов.
  static Map<String, Object?> read(Config_DeviceConfig c) => {
    'role': c.role.value == 3 ? 1 : c.role.value,
    'rebroadcastMode': c.rebroadcastMode.value,
    'nodeInfoBroadcastSecs': c.nodeInfoBroadcastSecs < 10800
        ? 10800
        : c.nodeInfoBroadcastSecs,
    'doubleTapAsButtonPress': c.doubleTapAsButtonPress,
    'disableTripleClick': c.disableTripleClick,
    'ledHeartbeat': !c.ledHeartbeatDisabled,
    'tzdef': c.tzdef,
    'buttonGpio': c.buttonGpio,
    'buzzerGpio': c.buzzerGpio,
  };

  static Config_DeviceConfig apply(
    Config_DeviceConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..role = Config_DeviceConfig_Role.valueOf(v['role']! as int)!
    ..rebroadcastMode = Config_DeviceConfig_RebroadcastMode.valueOf(
      v['rebroadcastMode']! as int,
    )!
    ..nodeInfoBroadcastSecs = v['nodeInfoBroadcastSecs']! as int
    ..doubleTapAsButtonPress = v['doubleTapAsButtonPress']! as bool
    ..disableTripleClick = v['disableTripleClick']! as bool
    ..ledHeartbeatDisabled = !(v['ledHeartbeat']! as bool)
    ..tzdef = v['tzdef']! as String
    ..buttonGpio = v['buttonGpio']! as int
    ..buzzerGpio = v['buzzerGpio']! as int;

  /// Часовой пояс телефона строкой POSIX (Android: «Использовать часовой
  /// пояс телефона»). Без правил перехода на летнее время — только смещение.
  static String phoneTz([DateTime? now]) {
    final off = (now ?? DateTime.now()).timeZoneOffset;
    final sign = off.isNegative ? '-' : '+';
    final h = off.inHours.abs(), m = off.inMinutes.abs() % 60;
    final name =
        '<$sign${h.toString().padLeft(2, '0')}'
        '${m == 0 ? '' : m.toString().padLeft(2, '0')}>';
    // В POSIX знак обратный: UTC+3 — «-3».
    final posixSign = off.isNegative ? '' : '-';
    return '$name$posixSign$h${m == 0 ? '' : ':${m.toString().padLeft(2, '0')}'}';
  }

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    Config_DeviceConfig base,
    Map<String, Object?> v,
  ) => saveConfig(admin, db, 'device', Config(device: apply(base, v)));
}
