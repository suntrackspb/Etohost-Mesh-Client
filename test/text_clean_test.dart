import 'package:etohost_mesh/data/text_clean.dart';
import 'package:flutter_test/flutter_test.dart';

/// Строка из кодов символов: невидимые символы в литералах не видны в
/// редакторе, а управляющие направлением анализатор запрещает.
String u(List<int> codes) => String.fromCharCodes(codes);

void main() {
  const zwsp = 0x200B, zwj = 0x200D, vs16 = 0xFE0F;
  final a = 'а'.codeUnitAt(0), b = 'б'.codeUnitAt(0);

  test('невидимые символы убираются', () {
    expect(stripInvisible('при${u([zwsp])}вет'), 'привет');
    expect(
      stripInvisible('при${u([0xAD])}вет${u([0x2060, 0xFEFF])}'),
      'привет',
    );
    expect(
      stripInvisible('${u([0x202E])}текст${u([0x202C, 0x200E])}'),
      'текст',
    );
    expect(stripInvisible('a${u([0x3164, 0x115F])}b'), 'ab');
    expect(stripInvisible('x${u([0xFE00])}y'), 'xy');
    expect(stripInvisible('ok${u(List.filled(50, zwsp))}'), 'ok');
  });

  test('эмодзи не ломаются', () {
    final emoji = [
      u([0x1F468, zwj, 0x1F469, zwj, 0x1F467]), // семья
      u([0x1F3F3, vs16, zwj, 0x1F308]), // радужный флаг
      u([0x2764, vs16]), // сердце
      u([0x31, vs16, 0x20E3]), // 1 в рамке
      u([0x1F3F4, 0xE0067, 0xE0062, 0xE0073, 0xE0063, 0xE0074, 0xE007F]),
      u([0x1F44D, 0x1F3FD]), // палец с оттенком кожи
    ];
    for (final e in emoji) {
      expect(stripInvisible('ок $e'), 'ок $e', reason: e);
    }
  });

  test('эмодзи-символы вне эмодзи убираются', () {
    expect(stripInvisible(u([a, zwj, b])), 'аб');
    expect(stripInvisible(u([a, vs16, b])), 'аб');
    expect(stripInvisible(u([0x2764, vs16, vs16, vs16])), u([0x2764, vs16]));
    expect(stripInvisible('a${u([0xE0067])}'), 'a');
  });
}
