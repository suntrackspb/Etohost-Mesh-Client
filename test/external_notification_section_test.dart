import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/external_notification_section.dart';
import 'package:etohost_mesh/data/settings/node_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fields = ExternalNotificationSection.fields();
  bool visible(String key, Map<String, Object?> v) =>
      fields.firstWhere((f) => f.key == key).visibleWhen?.call(v) ?? true;

  test('read/apply сохраняют все поля', () {
    final c = ModuleConfig_ExternalNotificationConfig(
      enabled: true,
      output: 13,
      active: true,
      outputMs: 1000,
      nagTimeout: 60,
      outputBuzzer: 4,
      usePwm: true,
      alertMessageVibra: true,
      useI2sAsBuzzer: true,
    );
    final v = ExternalNotificationSection.read(c);
    expect(fields.map((f) => f.key).toSet(), v.keys.toSet());
    expect(
      ExternalNotificationSection.read(ExternalNotificationSection.apply(c, v)),
      v,
    );
    v['nagTimeout'] = 5;
    expect(ExternalNotificationSection.apply(c, v).nagTimeout, 5);
  });

  test('«Активно» и PWM видны только при заданных выходах (Android)', () {
    final v = ExternalNotificationSection.read(
      ModuleConfig_ExternalNotificationConfig(),
    );
    expect(visible('active', v), isFalse);
    expect(visible('usePwm', v), isFalse);
    v['output'] = 13;
    v['outputBuzzer'] = 4;
    expect(visible('active', v), isTrue);
    expect(visible('usePwm', v), isTrue);
  });

  test('рингтон не длиннее 230 символов', () {
    expect(ringtone.check('a' * 230), isNull);
    expect(ringtone.check('a' * 231), isNotNull);
    expect(NodeText.decode('24:d=32,o=5'.codeUnits), '24:d=32,o=5');
  });
}
