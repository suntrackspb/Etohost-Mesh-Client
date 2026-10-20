import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Модуль «Последовательный порт»: SerialConfig.swift (iOS). Подписи — iOS
/// ru, затем Android ru, затем английские. Как в Android: все режимы и
/// «Переопределить COM-порт консоли».
abstract final class SerialSection {
  static const title = 'Настройка последовательного порта';
  static const saveConfirm = 'Сохранить настройки последовательного порта?';
  static const groupOptions = 'Параметры';
  static const groupGpio = 'GPIO';

  static const bauds = <Choice>[
    (value: 0, label: 'По умолчанию'),
    (value: 1, label: '110 Baud'),
    (value: 2, label: '300 Baud'),
    (value: 3, label: '600 Baud'),
    (value: 4, label: '1200 Baud'),
    (value: 5, label: '2400 Baud'),
    (value: 6, label: '4800 Baud'),
    (value: 7, label: '9600 Baud'),
    (value: 8, label: '19200 Baud'),
    (value: 9, label: '38400 Baud'),
    (value: 10, label: '57600 Baud'),
    (value: 11, label: '115200 Baud'),
    (value: 12, label: '230400 Baud'),
    (value: 13, label: '460800 Baud'),
    (value: 14, label: '576000 Baud'),
    (value: 15, label: '921600 Baud'),
  ];

  /// SerialTimeoutIntervals (iOS), секунды.
  static const timeouts = <Choice>[
    (value: 0, label: 'Не задан'),
    (value: 1, label: 'One Second'),
    (value: 5, label: 'Five Seconds'),
    (value: 10, label: 'Ten Seconds'),
    (value: 15, label: 'Fifteen Seconds'),
    (value: 30, label: 'Thirty Seconds'),
    (value: 60, label: 'Одна минута'),
    (value: 300, label: 'Пять минут'),
  ];

  /// Шесть режимов iOS и остальные из Android (по имени перечисления).
  static const modes = <Choice>[
    (value: 0, label: 'По умолчанию'),
    (value: 1, label: 'Simple'),
    (value: 2, label: 'Protobufs'),
    (value: 3, label: 'Text Message'),
    (value: 4, label: 'NMEA Positions'),
    (value: 5, label: 'CALTOPO'),
    (value: 6, label: 'WS85'),
    (value: 7, label: 'VE_DIRECT'),
    (value: 8, label: 'MS_CONFIG'),
    (value: 9, label: 'LOG'),
    (value: 10, label: 'LOGTEXT'),
  ];

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'enabled',
      'COM-порт включен',
      group: groupOptions,
      help: 'Enable serial module',
    ),
    const BoolFieldSpec(
      'echo',
      'Эхо',
      group: groupOptions,
      help:
          'Если установлено, все отправляемые вами пакеты будут отправлены '
          'эхом обратно на ваше устройство.',
    ),
    const ChoiceFieldSpec(
      'baud',
      'Бод',
      bauds,
      group: groupOptions,
      help: 'Скорость COM-порта',
    ),
    ChoiceFieldSpec(
      'timeout',
      'Таймаут',
      timeouts,
      group: groupOptions,
      unknownLabel: (s) => '$s с',
      help:
          'How long to wait before treating received serial data as a '
          'complete packet. 0 uses 250 ms.',
    ),
    ChoiceFieldSpec(
      'mode',
      'Режим',
      modes,
      group: groupOptions,
      unknownLabel: (v) =>
          ModuleConfig_SerialConfig_Serial_Mode.valueOf(v)?.name ?? '$v',
      help: 'Serial module operation mode',
    ),
    const BoolFieldSpec(
      'overrideConsoleSerialPort',
      'Переопределить COM-порт консоли',
      group: groupOptions,
    ),
    const IntFieldSpec(
      'rxd',
      'Контакт GPIO приема данных (rxd)',
      group: groupGpio,
      min: 0,
      max: 255,
      help: 'RX pin number',
    ),
    const IntFieldSpec(
      'txd',
      'Контакт GPIO передачи данных (txd)',
      group: groupGpio,
      min: 0,
      max: 255,
      help: 'TX pin number',
    ),
  ];

  static Map<String, Object?> read(ModuleConfig_SerialConfig c) => {
    'enabled': c.enabled,
    'echo': c.echo,
    'baud': c.baud.value,
    'timeout': c.timeout,
    'mode': c.mode.value,
    'overrideConsoleSerialPort': c.overrideConsoleSerialPort,
    'rxd': c.rxd,
    'txd': c.txd,
  };

  static ModuleConfig_SerialConfig apply(
    ModuleConfig_SerialConfig base,
    Map<String, Object?> v,
  ) {
    final out = base.deepCopy()
      ..enabled = v['enabled']! as bool
      ..echo = v['echo']! as bool
      ..overrideConsoleSerialPort = v['overrideConsoleSerialPort']! as bool
      ..timeout = v['timeout']! as int
      ..rxd = v['rxd']! as int
      ..txd = v['txd']! as int;
    final baud = ModuleConfig_SerialConfig_Serial_Baud.valueOf(
      v['baud']! as int,
    );
    if (baud != null) out.baud = baud;
    final mode = ModuleConfig_SerialConfig_Serial_Mode.valueOf(
      v['mode']! as int,
    );
    if (mode != null) out.mode = mode;
    return out;
  }

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_SerialConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'serial',
    ModuleConfig(serial: apply(base, v)),
  );
}
