import 'package:flutter_test/flutter_test.dart';
import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/device_section.dart';
import 'package:meshex/data/settings/fields.dart';
import 'package:meshex/data/settings/intervals.dart';

void main() {
  test(
    'чтение как в iOS: Router Client → Client Mute, NodeInfo ≥ 3 ч, LED',
    () {
      final v = DeviceSection.read(
        Config_DeviceConfig(
          role: Config_DeviceConfig_Role.valueOf(3),
          nodeInfoBroadcastSecs: 900,
          ledHeartbeatDisabled: true,
        ),
      );
      expect(v['role'], 1);
      expect(v['nodeInfoBroadcastSecs'], 10800);
      expect(v['ledHeartbeat'], isFalse);
    },
  );

  test('apply инвертирует LED обратно и сохраняет buzzer_mode', () {
    final base = Config_DeviceConfig(
      buzzerMode: Config_DeviceConfig_BuzzerMode.valueOf(1),
    );
    final v = DeviceSection.read(base)..['ledHeartbeat'] = false;
    final out = DeviceSection.apply(base, v);
    expect(out.ledHeartbeatDisabled, isTrue);
    expect(out.buzzerMode.value, 1);
  });

  test('предупреждение для Router, Router Late и Client Base', () {
    final role =
        DeviceSection.fields().firstWhere((f) => f.key == 'role')
            as ChoiceFieldSpec;
    expect(role.confirmFor!(2), isNotNull);
    expect(role.confirmFor!(11), isNotNull);
    expect(role.confirmFor!(12), isNotNull);
    expect(role.confirmFor!(0), isNull);
  });

  test('часовой пояс телефона в POSIX', () {
    // Смещение берётся из локального пояса машины — проверяем формат.
    expect(
      DeviceSection.phoneTz(),
      matches(r'^<[+-]\d{2,4}>-?\d{1,2}(:\d{2})?$'),
    );
  });

  test('подписи интервалов', () {
    expect(Intervals.label(10800), '3 часа');
    expect(Intervals.label(86400), '24 часа');
    expect(Intervals.label(18000), '5 часов');
    expect(Intervals.label(Intervals.never), 'Никогда');
  });
}
