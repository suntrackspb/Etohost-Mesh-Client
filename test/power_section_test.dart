import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/power_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Set<String> keys(int hw, {int role = 0}) =>
      PowerSection.fields(hwModel: hw, role: role).map((f) => f.key).toSet();

  test('поля по архитектуре: ESP32-S3, nRF52 (трекер и клиент)', () {
    final heltecV3 = HardwareModel.HELTEC_V3.value; // esp32-s3
    final rak = HardwareModel.RAK4631.value; // nrf52840
    expect(
      keys(heltecV3),
      containsAll(['isPowerSaving', 'waitBluetoothSecs', 'adcOn']),
    );
    expect(keys(rak), isNot(contains('isPowerSaving')));
    expect(keys(rak, role: 5), contains('isPowerSaving'));
    expect(keys(rak), isNot(contains('waitBluetoothSecs')));
    expect(keys(rak), isNot(contains('adcOn')));
    expect(keys(rak), containsAll(['shutdownOn', 'sdsSecs', 'minWakeSecs']));
  });

  test('выключенный переключатель пишет 0, число помнится', () {
    final base = Config_PowerConfig(lsSecs: 300);
    final v = PowerSection.read(base);
    expect(v['shutdownOn'], isFalse);
    expect(v['onBatteryShutdownAfterSecs'], PowerSection.shutdownDefault);
    expect(PowerSection.apply(base, v).onBatteryShutdownAfterSecs, 0);
    expect(PowerSection.apply(base, v).adcMultiplierOverride, 0);

    v['shutdownOn'] = true;
    v['adcOn'] = true;
    final out = PowerSection.apply(base, v);
    expect(out.onBatteryShutdownAfterSecs, 1800);
    expect(out.adcMultiplierOverride, PowerSection.adcStart);
    expect(out.lsSecs, 300, reason: 'нередактируемое поле сохраняется');
  });

  test('чтение и запись без изменений не меняют конфиг', () {
    final base = Config_PowerConfig(
      onBatteryShutdownAfterSecs: 600,
      adcMultiplierOverride: 3.5,
      waitBluetoothSecs: 30,
      sdsSecs: 3600,
    );
    final out = PowerSection.apply(base, PowerSection.read(base));
    expect(out.onBatteryShutdownAfterSecs, 600);
    expect(out.adcMultiplierOverride, 3.5);
    expect(out.waitBluetoothSecs, 30);
    expect(out.sdsSecs, 3600);
    expect(out.isPowerSaving, isFalse);
  });
}
