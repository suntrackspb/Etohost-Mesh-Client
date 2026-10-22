import 'dart:convert';

import 'package:etohost_mesh/core/transport/ansi_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Как плагин: байты cp1251, прочитанные как latin1.
  String garbled(List<int> cp1251) => latin1.decode(cp1251);

  test('cp1251 → кириллица', () {
    // «Стандартный порт Ёё №»
    final bytes = [
      0xd1, 0xf2, 0xe0, 0xed, 0xe4, 0xe0, 0xf0, 0xf2, 0xed, 0xfb, 0xe9, //
      0x20, 0xef, 0xee, 0xf0, 0xf2, 0x20, 0xa8, 0xb8, 0x20, 0xb9,
    ];
    expect(fixAnsiText(garbled(bytes)), 'Стандартный порт Ёё №');
  });

  test('ASCII и нормальный юникод не трогаем', () {
    expect(fixAnsiText('COM3 USB-SERIAL CH340'), 'COM3 USB-SERIAL CH340');
    expect(fixAnsiText('Последовательный порт'), 'Последовательный порт');
  });
}
