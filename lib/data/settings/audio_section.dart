import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Модуль «Звук»: AudioConfig.swift (iOS), те же поля в Android.
/// В iOS нет ru — подписи из Android ru, иначе английские iOS. Битрейт и
/// пины видны при включённом Codec2 (iOS).
abstract final class AudioSection {
  static const title = 'Настройка звука';
  static const saveConfirm = 'Сохранить настройки звука?';
  static const groupOptions = 'Параметры';
  static const groupCodec = 'Codec2 Settings';
  static const groupGpio = 'GPIO Configuration';

  static const _baud = ModuleConfig_AudioConfig_Audio_Baud.values;

  /// Имена английские, как в iOS; устаревшие 700 и 700B не предлагаем.
  static const bitrates = <Choice>[
    (value: 0, label: 'Default'),
    (value: 1, label: '3200 bps'),
    (value: 2, label: '2400 bps'),
    (value: 3, label: '1600 bps'),
    (value: 4, label: '1400 bps'),
    (value: 5, label: '1300 bps'),
    (value: 6, label: '1200 bps'),
    (value: 9, label: '700C bps'),
    (value: 10, label: '450 bps'),
  ];

  static bool _codec(Map<String, Object?> v) => v['codec2Enabled'] == true;

  static IntFieldSpec _pin(String key, String label, {String? help}) =>
      IntFieldSpec(
        key,
        label,
        group: groupGpio,
        help: help,
        min: 0,
        max: 255,
        visibleWhen: _codec,
      );

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'codec2Enabled',
      'CODEC 2 включен',
      group: groupOptions,
      help:
          'Включить кодирование/декодирование звука Codec2 для голосовой '
          'связи по mesh-сети.',
    ),
    ChoiceFieldSpec(
      'bitrate',
      'Частота дискретизации CODEC2',
      bitrates,
      group: groupCodec,
      visibleWhen: _codec,
      help:
          'Используемая скорость передачи Codec2. Частота дискретизации '
          'всегда 8 кГц. Более низкие скорости используют меньше полосы '
          'пропускания, но снижают качество звука.',
    ),
    _pin('pttPin', 'Контакт PTT', help: 'Push-to-talk GPIO pin number.'),
    _pin('i2sWs', 'I2S WS'),
    _pin('i2sSd', 'I2S SD'),
    _pin('i2sDin', 'I2S DIN'),
    _pin('i2sSck', 'I2S SCK'),
  ];

  static Map<String, Object?> read(ModuleConfig_AudioConfig c) => {
    'codec2Enabled': c.codec2Enabled,
    'bitrate': c.bitrate.value,
    'pttPin': c.pttPin,
    'i2sWs': c.i2sWs,
    'i2sSd': c.i2sSd,
    'i2sDin': c.i2sDin,
    'i2sSck': c.i2sSck,
  };

  static ModuleConfig_AudioConfig apply(
    ModuleConfig_AudioConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..codec2Enabled = v['codec2Enabled']! as bool
    ..bitrate = _baud.firstWhere(
      (b) => b.value == v['bitrate'],
      orElse: () => base.bitrate,
    )
    ..pttPin = v['pttPin']! as int
    ..i2sWs = v['i2sWs']! as int
    ..i2sSd = v['i2sSd']! as int
    ..i2sDin = v['i2sDin']! as int
    ..i2sSck = v['i2sSck']! as int;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_AudioConfig base,
    Map<String, Object?> v,
  ) =>
      saveModuleConfig(admin, db, 'audio', ModuleConfig(audio: apply(base, v)));
}
