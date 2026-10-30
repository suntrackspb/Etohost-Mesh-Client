import 'package:meshex/core/proto/channel_names.dart';
import 'package:meshex/core/proto/mesh.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String name(Config_LoRaConfig_ModemPreset p) =>
      modemPresetName(Config_LoRaConfig(usePreset: true, modemPreset: p));

  test('имена пресетов как в прошивке 2.8.1', () {
    const expected = {
      'SHORT_TURBO': 'ShortTurbo',
      'SHORT_FAST': 'ShortFast',
      'SHORT_SLOW': 'ShortSlow',
      'MEDIUM_FAST': 'MediumFast',
      'MEDIUM_SLOW': 'MediumSlow',
      'MEDIUM_TURBO': 'MediumTurbo',
      'LONG_FAST': 'LongFast',
      'LONG_SLOW': 'LongSlow',
      'LONG_TURBO': 'LongTurbo',
      'LONG_MODERATE': 'LongMod',
      'VERY_LONG_SLOW': 'VLongSlow',
      'LITE_FAST': 'LiteFast',
      'LITE_SLOW': 'LiteSlow',
      'NARROW_FAST': 'NarrowFast',
      'NARROW_SLOW': 'NarrowSlow',
      'TINY_FAST': 'TinyFast',
      'TINY_SLOW': 'TinySlow',
    };
    for (final p in Config_LoRaConfig_ModemPreset.values) {
      expect(name(p), expected[p.name], reason: p.name);
    }
  });

  test('без пресета — Custom', () {
    expect(modemPresetName(Config_LoRaConfig(usePreset: false)), 'Custom');
  });
}
