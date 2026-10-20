import 'package:flutter_test/flutter_test.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/position_section.dart';
import 'package:etohost_mesh/data/settings/settings_form.dart';

void main() {
  test('флаги читаются из маски и пишутся обратно, чужие биты сохраняются', () {
    final base = Config_PositionConfig(positionFlags: 1 | 8 | 1024);
    final v = PositionSection.read(base);
    expect(v['flag1'], isTrue);
    expect(v['flag8'], isTrue);
    expect(v['flag2'], isFalse);
    v['flag8'] = false;
    v['flag256'] = true;
    final out = PositionSection.apply(base, v);
    expect(out.positionFlags, 1 | 256 | 1024);
  });

  test('apply не трогает fixed_position', () {
    final base = Config_PositionConfig(fixedPosition: true);
    final out = PositionSection.apply(base, PositionSection.read(base));
    expect(out.fixedPosition, isTrue);
  });

  test('видимость: умные поля, интервал GPS, подфлаги', () {
    final form = SettingsForm(
      PositionSection.fields(),
      PositionSection.read(Config_PositionConfig()),
    );
    bool visible(String k) =>
        form.fields.firstWhere((f) => f.key == k).visible(form.values);
    expect(visible('broadcastSmartMinimumDistance'), isFalse);
    expect(visible('gpsUpdateInterval'), isFalse);
    expect(visible('flag2'), isFalse);
    form.set('positionBroadcastSmartEnabled', true);
    form.set('gpsMode', PositionSection.gpsEnabled);
    form.set('flag1', true);
    expect(visible('broadcastSmartMinimumDistance'), isTrue);
    expect(visible('gpsUpdateInterval'), isTrue);
    expect(visible('flag2'), isTrue);
  });

  test('фиксированная позиция: без GPS или если уже стоит', () {
    expect(
      PositionSection.fixedAvailable(PositionSection.gpsEnabled, false),
      isFalse,
    );
    expect(
      PositionSection.fixedAvailable(PositionSection.gpsEnabled, true),
      isTrue,
    );
    expect(
      PositionSection.fixedAvailable(PositionSection.gpsDisabled, false),
      isTrue,
    );
  });
}
