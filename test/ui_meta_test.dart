import 'package:etohost_mesh/core/links.dart';
import 'package:etohost_mesh/ui/kit/kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nodeColor берёт младшие 24 бита', () {
    expect(nodeColor(0xA1B2C3D4), const Color(0xFFB2C3D4));
  });

  test('контраст: чёрный на светлом, белый на тёмном', () {
    expect(contrastingText(const Color(0xFFFFFF00)), Colors.black);
    expect(contrastingText(const Color(0xFF000080)), Colors.white);
  });

  test('ссылки в тексте', () {
    final p = splitLinks('см. https://ya.ru/a?b=1, и www.x.org.');
    expect(p.where((e) => e.link != null).map((e) => e.text), [
      'https://ya.ru/a?b=1',
      'www.x.org',
    ]);
    expect(
      p.map((e) => e.text).join(),
      'см. https://ya.ru/a?b=1, и www.x.org.',
    );
    expect(p[3].link.toString(), 'https://www.x.org');
    expect(splitLinks('без ссылок').single.link, isNull);
    expect(
      splitLinks('(https://en.wikipedia.org/wiki/A_(b))')[1].text,
      'https://en.wikipedia.org/wiki/A_(b)',
    );
  });
}
