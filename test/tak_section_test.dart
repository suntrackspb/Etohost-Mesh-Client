import 'package:etohost_mesh/core/proto/generated/meshtastic/atak.pbenum.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/tak_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read/apply сохраняют команду и роль', () {
    final c = ModuleConfig_TAKConfig(
      team: Team.Dark_Green,
      role: MemberRole.K9,
    );
    final v = TakSection.read(c);
    expect(v, {'team': 13, 'role': 8});
    expect(TakSection.read(TakSection.apply(c, v)), v);
  });

  test('предупреждение только вне ролей TAK', () {
    expect(TakSection.appliesTo(Config_DeviceConfig_Role.TAK.value), isTrue);
    expect(
      TakSection.appliesTo(Config_DeviceConfig_Role.TAK_TRACKER.value),
      isTrue,
    );
    expect(
      TakSection.appliesTo(Config_DeviceConfig_Role.CLIENT.value),
      isFalse,
    );
  });
}
