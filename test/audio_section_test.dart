import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/audio_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read/apply сохраняют все поля', () {
    final c = ModuleConfig_AudioConfig(
      codec2Enabled: true,
      pttPin: 12,
      bitrate: ModuleConfig_AudioConfig_Audio_Baud.CODEC2_700C,
      i2sWs: 1,
      i2sSd: 2,
      i2sDin: 3,
      i2sSck: 4,
    );
    final v = AudioSection.read(c);
    expect(AudioSection.fields().map((f) => f.key).toSet(), v.keys.toSet());
    expect(AudioSection.read(AudioSection.apply(c, v)), v);
    expect(v['bitrate'], 9);
  });

  test('битрейт и пины видны только при включённом Codec2', () {
    final v = AudioSection.read(ModuleConfig_AudioConfig());
    final hidden = AudioSection.fields().where((f) => !f.visible(v));
    expect(hidden.length, 6);
    v['codec2Enabled'] = true;
    expect(AudioSection.fields().every((f) => f.visible(v)), isTrue);
  });
}
