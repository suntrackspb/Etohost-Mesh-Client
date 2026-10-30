import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/bluetooth_section.dart';
import 'package:meshex/data/settings/fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PIN: ровно шесть цифр без ведущего нуля', () {
    expect(BluetoothSection.isValidPin('123456'), isTrue);
    expect(BluetoothSection.isValidPin('12345'), isFalse);
    expect(BluetoothSection.isValidPin('012345'), isFalse);
    expect(BluetoothSection.isValidPin('12a456'), isFalse);
  });

  test('PIN виден и проверяется только в режиме фиксированного PIN', () {
    final pin =
        BluetoothSection.fields().firstWhere((f) => f.key == 'fixedPin')
            as TextFieldSpec;
    final v = BluetoothSection.read(Config_BluetoothConfig(enabled: true));
    expect(v['fixedPin'], '');
    expect(pin.visible(v), isFalse);
    v['mode'] = BluetoothSection.fixedPinMode;
    expect(pin.visible(v), isTrue);
    expect(pin.validator!('123'), BluetoothSection.pinError);
  });

  test('apply: PIN меняется только в фиксированном режиме', () {
    final base = Config_BluetoothConfig(enabled: true, fixedPin: 111111);
    final v = BluetoothSection.read(base)..['fixedPin'] = '';
    expect(BluetoothSection.apply(base, v).fixedPin, 111111);
    v
      ..['mode'] = BluetoothSection.fixedPinMode
      ..['fixedPin'] = '654321'
      ..['enabled'] = false;
    final out = BluetoothSection.apply(base, v);
    expect(out.fixedPin, 654321);
    expect(out.mode, Config_BluetoothConfig_PairingMode.FIXED_PIN);
    expect(out.enabled, isFalse);
  });
}
