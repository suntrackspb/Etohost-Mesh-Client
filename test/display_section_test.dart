import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/display_section.dart';
import 'package:meshex/data/settings/fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('apply сохраняет нередактируемые поля', () {
    final base = Config_DisplayConfig(
      compassNorthTop: true,
      useLongNodeName: true,
      enableMessageBubbles: true,
      screenOnSecs: 60,
    );
    final v = DisplaySection.read(base)..['flipScreen'] = true;
    final out = DisplaySection.apply(base, v);
    expect(out.flipScreen, isTrue);
    expect(out.screenOnSecs, 60);
    expect(out.compassNorthTop, isTrue);
    expect(out.useLongNodeName, isTrue);
    expect(out.enableMessageBubbles, isTrue);
  });

  test('новый тип OLED и нестандартный интервал остаются видны', () {
    final f = DisplaySection.fields();
    ChoiceFieldSpec spec(String k) =>
        f.firstWhere((x) => x.key == k) as ChoiceFieldSpec;
    final v = DisplaySection.read(
      Config_DisplayConfig(
        oled: Config_DisplayConfig_OledType.valueOf(5),
        screenOnSecs: 0,
        autoScreenCarouselSecs: 0,
      ),
    );
    expect(spec('oled').choices(v).last.label, 'SH 1107 Rotated');
    expect(spec('screenOnSecs').choices(v).last.label, 'Не задан');
    expect(spec('autoScreenCarouselSecs').choices(v).first.label, 'Выключено');
    expect(
      spec(
        'screenOnSecs',
      ).choices(v).firstWhere((c) => c.value == DisplaySection.alwaysOn).label,
      'Всегда включен',
    );
  });
}
