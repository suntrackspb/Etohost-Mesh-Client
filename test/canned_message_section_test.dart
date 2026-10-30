import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/canned_message_section.dart';
import 'package:meshex/data/settings/node_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('read/apply сохраняют поля и устаревшие значения', () {
    final c = ModuleConfig_CannedMessageConfig(
      sendBell: true,
      rotary1Enabled: true,
      inputbrokerPinA: 4,
      inputbrokerPinB: 5,
      inputbrokerPinPress: 6,
      inputbrokerEventCw: ModuleConfig_CannedMessageConfig_InputEventChar.UP,
      inputbrokerEventPress:
          ModuleConfig_CannedMessageConfig_InputEventChar.BACK,
      // ignore: deprecated_member_use_from_same_package
      allowInputSource: 'rotEnc1',
    );
    final v = CannedMessageSection.read(c);
    final keys = CannedMessageSection.fields().map((f) => f.key);
    expect(keys.toSet(), v.keys.toSet());
    final out = CannedMessageSection.apply(c, v);
    expect(CannedMessageSection.read(out), v);
    // ignore: deprecated_member_use_from_same_package
    expect(out.allowInputSource, 'rotEnc1');
  });

  test('пресет RAK переписывает управление и блокирует поля', () {
    final v = CannedMessageSection.read(ModuleConfig_CannedMessageConfig());
    final pin = CannedMessageSection.fields().firstWhere(
      (f) => f.key == 'inputbrokerPinA',
    );
    expect(pin.enabled(v), isTrue);
    v[CannedMessageSection.preset] = 1;
    CannedMessageSection.adjust(v);
    expect(pin.enabled(v), isFalse);
    final c = CannedMessageSection.apply(ModuleConfig_CannedMessageConfig(), v);
    expect(c.updown1Enabled, isTrue);
    expect(c.inputbrokerPinA, 4);
    expect(
      c.inputbrokerEventCw,
      ModuleConfig_CannedMessageConfig_InputEventChar.DOWN,
    );
  });

  test('текст сообщений ограничен 200 байтами', () {
    expect(cannedMessages.check('Да|Нет'), isNull);
    expect(cannedMessages.check('ж' * 101), isNotNull);
    expect(cannedMessages.check('a' * 200), isNull);
  });
}
