import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/fields.dart';
import 'package:meshex/data/settings/remote_hardware_section.dart';
import 'package:meshex/data/settings/settings_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final c = ModuleConfig_RemoteHardwareConfig(
    enabled: true,
    allowUndefinedPinAccess: true,
    availablePins: [
      RemoteHardwarePin(
        gpioPin: 12,
        name: 'Front door',
        type: RemoteHardwarePinType.DIGITAL_READ,
      ),
    ],
  );

  test('read/apply сохраняют поля и пины', () {
    final v = RemoteHardwareSection.read(c);
    final keys = RemoteHardwareSection.fields().map((f) => f.key);
    expect(keys.toSet(), v.keys.toSet());
    final out = RemoteHardwareSection.apply(c, v);
    expect(RemoteHardwareSection.read(out), v);
    expect(out.availablePins.single.name, 'Front door');
  });

  test('правка списка пинов видна форме; лимиты 4 пина и 14 байт имени', () {
    final f = SettingsForm(
      RemoteHardwareSection.fields(),
      RemoteHardwareSection.read(c),
    );
    expect(f.dirty, isFalse);
    f.set(
      'availablePins',
      RemotePins([
        for (var i = 0; i < 6; i++) (gpio: 300, name: 'x' * 20, type: 2),
      ]),
    );
    final pins = f.value<RemotePins>('availablePins').items;
    expect(pins.length, 4);
    expect(pins.first.gpio, 255);
    expect(pins.first.name.length, 14);
    expect(f.dirty, isTrue);
    f.set('availablePins', RemoteHardwareSection.read(c)['availablePins']);
    expect(f.dirty, isFalse);
  });
}
