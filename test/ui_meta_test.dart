import 'package:meshex/core/links.dart';
import 'package:meshex/ui/kit/kit.dart';
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

  test('голые домены известных зон — ссылки, остальное нет', () {
    Uri? link(String t) =>
        splitLinks(t).where((p) => p.link != null).firstOrNull?.link;
    expect(
      link('Настройки и сообщество: tmesh.ru/s/w').toString(),
      'https://tmesh.ru/s/w',
    );
    expect(link('зайди на i.jab.su.').toString(), 'https://i.jab.su');
    expect(link('прошивка 2.7.18'), isNull);
    expect(link('файл config.yaml'), isNull);
    expect(link('пиши на a@tmesh.ru'), isNull);
    expect(link('https://x.ru/tmesh.ru').toString(), 'https://x.ru/tmesh.ru');
  });
}
