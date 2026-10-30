import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/fields.dart';
import 'package:meshex/data/settings/neighbor_info_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read/apply сохраняют все поля', () {
    final c = ModuleConfig_NeighborInfoConfig(
      enabled: true,
      updateInterval: 21600,
      transmitOverLora: true,
    );
    final v = NeighborInfoSection.read(c);
    final keys = NeighborInfoSection.fields().map((f) => f.key);
    expect(keys.toSet(), v.keys.toSet());
    expect(NeighborInfoSection.read(NeighborInfoSection.apply(c, v)), v);
  });

  test('0 показывается как 4 часа и остаётся нулём', () {
    final v = NeighborInfoSection.read(
      ModuleConfig_NeighborInfoConfig(enabled: true),
    );
    final f =
        NeighborInfoSection.fields().firstWhere(
              (f) => f.key == 'updateInterval',
            )
            as ChoiceFieldSpec;
    final opts = f.choices(v);
    expect(opts.first, (value: 0, label: '4 часа'));
    expect(opts.any((o) => o.value == 14400), isFalse);
    v['updateInterval'] = 18000;
    expect(f.choices(v).first.value, 14400);
  });
}
