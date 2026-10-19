import 'mesh.dart';

/// Имя пресета модема так, как его пишет прошивка
/// (DisplayFormatters::getModemPresetDisplayName). Из него же строятся имя
/// основного канала без имени, хеш канала и MQTT-топик — поэтому строки
/// должны совпадать байт в байт; два имени сокращены (LongMod, VLongSlow).
/// Сверено с прошивкой v2.8.1. VERY_LONG_SLOW в 2.8 убран (там «Invalid»),
/// оставлен для нод на 2.7.
String modemPresetName(Config_LoRaConfig lora) {
  if (!lora.usePreset) return 'Custom';
  return switch (lora.modemPreset) {
    Config_LoRaConfig_ModemPreset.SHORT_TURBO => 'ShortTurbo',
    Config_LoRaConfig_ModemPreset.SHORT_FAST => 'ShortFast',
    Config_LoRaConfig_ModemPreset.SHORT_SLOW => 'ShortSlow',
    Config_LoRaConfig_ModemPreset.MEDIUM_FAST => 'MediumFast',
    Config_LoRaConfig_ModemPreset.MEDIUM_SLOW => 'MediumSlow',
    Config_LoRaConfig_ModemPreset.LONG_FAST => 'LongFast',
    Config_LoRaConfig_ModemPreset.LONG_SLOW => 'LongSlow',
    Config_LoRaConfig_ModemPreset.LONG_MODERATE => 'LongMod',
    Config_LoRaConfig_ModemPreset.VERY_LONG_SLOW => 'VLongSlow',
    Config_LoRaConfig_ModemPreset.LONG_TURBO => 'LongTurbo',
    Config_LoRaConfig_ModemPreset.MEDIUM_TURBO => 'MediumTurbo',
    Config_LoRaConfig_ModemPreset.LITE_FAST => 'LiteFast',
    Config_LoRaConfig_ModemPreset.LITE_SLOW => 'LiteSlow',
    Config_LoRaConfig_ModemPreset.NARROW_FAST => 'NarrowFast',
    Config_LoRaConfig_ModemPreset.NARROW_SLOW => 'NarrowSlow',
    Config_LoRaConfig_ModemPreset.TINY_FAST => 'TinyFast',
    Config_LoRaConfig_ModemPreset.TINY_SLOW => 'TinySlow',
    final p => _pascal(p.name),
  };
}

/// Для пресетов, которых нет в списке выше (новые прошивки): LITE_FAST → LiteFast.
String _pascal(String enumName) => enumName
    .toLowerCase()
    .split('_')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
    .join();

/// Имя канала для ленты: своё имя или (у безымянного основного) имя пресета.
String channelDisplayName(
  String name, {
  required bool primary,
  required String presetName,
}) => name.isNotEmpty ? name : (primary ? presetName : '');

/// Ключ канала в БД и для склейки с зеркалом — без учёта регистра.
String channelKey(String name) => name.toLowerCase();
