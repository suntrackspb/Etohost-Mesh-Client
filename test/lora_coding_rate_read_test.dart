import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/lora_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('явная скорость пресета читается как «по пресету»', () {
    final v = LoraSection.read(
      Config_LoRaConfig(
        usePreset: true,
        modemPreset: Config_LoRaConfig_ModemPreset.MEDIUM_FAST,
        codingRate: 5,
      ),
    );
    expect(v['codingRate'], 0);
  });
}
