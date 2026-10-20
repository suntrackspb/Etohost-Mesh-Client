import 'package:etohost_mesh/data/message_sender.dart';
import 'package:etohost_mesh/data/message_split.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('short text stays one message without prefix', () {
    expect(MessageSplit.split('  привет  '), ['привет']);
    expect(MessageSplit.split('   '), isEmpty);
  });

  test('long cyrillic text splits by words within limit', () {
    final text = List.filled(60, 'слово').join(' '); // ~ 659 байт
    final parts = MessageSplit.split(text);
    expect(parts.length, greaterThan(1));
    for (var i = 0; i < parts.length; i++) {
      expect(parts[i], startsWith('[${i + 1}/${parts.length}] '));
      expect(messageBytes(parts[i]), lessThanOrEqualTo(maxMessageBytes));
      expect(parts[i].endsWith(' '), isFalse);
    }
    final body = parts.map((p) => p.substring(p.indexOf('] ') + 2)).join(' ');
    expect(body, text);
  });

  test('two-digit part count keeps the limit', () {
    final text = List.filled(700, 'ab').join(' ');
    final parts = MessageSplit.split(text);
    expect(parts.length, greaterThanOrEqualTo(10));
    expect(parts.last, startsWith('[${parts.length}/${parts.length}] '));
    expect(parts.every((p) => messageBytes(p) <= maxMessageBytes), isTrue);
  });

  test('a single huge word is cut by characters', () {
    final word = 'я' * 150; // 300 байт
    final parts = MessageSplit.split(word);
    expect(parts, hasLength(2));
    expect(parts.every((p) => messageBytes(p) <= maxMessageBytes), isTrue);
    expect(parts.map((p) => p.substring(6)).join(), word);
  });

  test('newlines inside a part are kept', () {
    final text = 'строка один\nстрока два ${'x' * 250}';
    final parts = MessageSplit.split(text);
    expect(parts.first, contains('\n'));
  });
}
