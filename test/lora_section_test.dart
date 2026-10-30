import 'package:flutter_test/flutter_test.dart';
import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/lora_section.dart';
import 'package:meshex/data/settings/settings_form.dart';

void main() {
  Set<int> values(List<({int value, String label})> l) => {
    for (final c in l) c.value,
  };

  test('пресеты: в ЕС без Turbo, вне ЕС без Lite/Narrow/Tiny, 2.7 без 2.8', () {
    final eu = values(LoraSection.presetChoices(3, true));
    expect(eu.containsAll({8, 9, 16}), isFalse);
    expect(eu.contains(10), isTrue);
    final ru = values(LoraSection.presetChoices(9, true));
    expect(ru.contains(9), isTrue);
    expect(ru.contains(10), isFalse);
    expect(ru.contains(1), isFalse, reason: 'LongSlow устарел');
    expect(values(LoraSection.presetChoices(9, false)).contains(16), isFalse);
  });

  test('регионы: 2.8-регионы и любительские скрыты', () {
    expect(values(LoraSection.regionChoices(false)).contains(29), isFalse);
    expect(values(LoraSection.regionChoices(true)).contains(29), isTrue);
    expect(values(LoraSection.regionChoices(true)).contains(27), isFalse);
  });

  test('скорость кодирования согласуется с пресетом', () {
    final cfg = Config_LoRaConfig(
      usePreset: true,
      modemPreset: Config_LoRaConfig_ModemPreset.LONG_FAST,
      region: Config_LoRaConfig_RegionCode.RU,
      codingRate: 7,
      hopLimit: 3,
    );
    final f = SettingsForm(
      LoraSection.fields(firmware: '2.8.1', hwModel: 0),
      LoraSection.read(cfg),
      adjust: LoraSection.adjust,
      check: LoraSection.check,
    );
    // LongTurbo — 4/8 по умолчанию: 4/7 недопустимо, сброс на пресет.
    f.set('modemPreset', 9);
    expect(f.value<int>('codingRate'), 0);
    f.set('usePreset', false);
    expect(f.value<int>('codingRate'), 5);
    expect(
      f.groups.expand((g) => g.$2).any((x) => x.key == 'bandwidth'),
      isTrue,
    );
    expect(
      f.groups.expand((g) => g.$2).any((x) => x.key == 'modemPreset'),
      isFalse,
    );
    expect(f.formError, isNull);
  });

  test('неизвестный регион блокирует сохранение', () {
    final v = LoraSection.read(Config_LoRaConfig(usePreset: true));
    v['region'] = 99;
    expect(LoraSection.check(v), isNotNull);
  });

  test('apply сохраняет нередактируемые поля', () {
    final base = Config_LoRaConfig(
      region: Config_LoRaConfig_RegionCode.RU,
      ignoreIncoming: [42],
      frequencyOffset: 1.5,
    );
    final v = LoraSection.read(base)..['txPower'] = 20;
    final out = LoraSection.apply(base, v);
    expect(out.txPower, 20);
    expect(out.ignoreIncoming, [42]);
    expect(out.frequencyOffset, 1.5);
  });
}
