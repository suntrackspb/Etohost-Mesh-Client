import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/fields.dart';
import 'package:etohost_mesh/data/settings/serial_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('apply: режим LOG и переопределение консоли', () {
    final base = ModuleConfig_SerialConfig(
      overrideConsoleSerialPort: true,
      mode: ModuleConfig_SerialConfig_Serial_Mode.valueOf(9),
    );
    final v = SerialSection.read(base)
      ..['enabled'] = true
      ..['baud'] = 11
      ..['timeout'] = 15;
    final out = SerialSection.apply(base, v);
    expect(out.enabled, isTrue);
    expect(out.baud, ModuleConfig_SerialConfig_Serial_Baud.BAUD_115200);
    expect(out.timeout, 15);
    expect(out.mode.value, 9);
    expect(out.overrideConsoleSerialPort, isTrue);
  });

  test('режим вне перечисления виден номером', () {
    final mode =
        SerialSection.fields().firstWhere((f) => f.key == 'mode')
            as ChoiceFieldSpec;
    final v = SerialSection.read(
      ModuleConfig_SerialConfig(
        mode: ModuleConfig_SerialConfig_Serial_Mode.valueOf(10),
      ),
    );
    expect(mode.choices(v).last.label, 'LOGTEXT');
  });
}
