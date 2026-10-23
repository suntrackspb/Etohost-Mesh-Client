import 'package:etohost_mesh/data/message_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('whole word, case-insensitive, Cyrillic too', () {
    final f = MessageFilter(enabled: true, words: ['спам', 'Test']);
    expect(f.hides('Это СПАМ!'), isTrue);
    expect(f.hides('спамер пишет'), isFalse); // не целое слово
    expect(f.hides('a test here'), isTrue);
    expect(f.hides('testing'), isFalse);
    expect(f.hides('ничего'), isFalse);
  });

  test('regex: prefix, invalid pattern is skipped', () {
    final f = MessageFilter(
      enabled: true,
      words: ['regex:^bot\\d+', 'regex:('],
    );
    expect(f.hides('BOT42 says hi'), isTrue);
    expect(f.hides('hi bot42'), isFalse);
    expect(compileFilterWord('regex:('), isNull);
    expect(compileFilterWord('  '), isNull);
  });

  test('off globally or in this chat — nothing hidden', () {
    expect(MessageFilter(words: ['x']).hides('x'), isFalse);
    final f = MessageFilter(enabled: true, words: ['x']);
    expect(f.hides('x', disabledHere: true), isFalse);
  });

  test('special characters in a word are literal', () {
    final f = MessageFilter(enabled: true, words: ['a.b']);
    expect(f.hides('see a.b now'), isTrue);
    expect(f.hides('see axb now'), isFalse);
  });

  test('add word: trims, skips empty and duplicates', () {
    expect(addFilterWord(['спам'], ' СПАМ '), ['спам']);
    expect(addFilterWord(['спам'], ' '), ['спам']);
    expect(addFilterWord(['спам'], 'реклама'), ['спам', 'реклама']);
  });

  test('string list round-trip, broken is empty', () {
    expect(decodeStringList(encodeStringList(['a', 'б'])), ['a', 'б']);
    expect(decodeStringList('мусор'), isEmpty);
    expect(decodeStringList(null), isEmpty);
  });
}
