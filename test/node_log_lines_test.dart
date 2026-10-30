import 'package:meshex/core/radio/node_log_lines.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('куски склеиваются в строки, цвет убирается', () {
    final l = NodeLogLines();
    expect(l.add('\x1B[32mI'), isEmpty);
    expect(l.add('N'), isEmpty);
    expect(l.add('FO \x1B[0m| 14:47:07 [PowerFSM] wake\r\n  \nDE'), [
      'INFO | 14:47:07 [PowerFSM] wake',
    ]);
    expect(l.add('BUG x\n'), ['DEBUG x']);
  });

  test('слишком длинная строка без перевода отдаётся', () {
    final l = NodeLogLines();
    expect(l.add('a' * (NodeLogLines.maxPending + 1)), hasLength(1));
    expect(l.add('b\n'), ['b']);
  });
}
