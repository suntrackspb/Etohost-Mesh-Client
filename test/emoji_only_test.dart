import 'package:etohost_mesh/data/message_meta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('реакция — только эмодзи', () {
    for (final s in [
      '👍',
      '❤️',
      '👍🏻',
      '🇷🇺',
      '👨‍👩‍👧',
      ' 😂 ',
      '🔥🔥',
      '1️⃣',
    ]) {
      expect(isEmojiOnly(s), isTrue, reason: s);
    }
    for (final s in [
      '',
      'ок',
      '👍 ок',
      '1',
      '+',
      '😂😂😂😂😂😂😂😂😂😂😂😂😂',
    ]) {
      expect(isEmojiOnly(s), isFalse, reason: s);
    }
  });
}
