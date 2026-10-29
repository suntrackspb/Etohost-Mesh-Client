import 'package:etohost_mesh/core/links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hosts = {'i.jab.su', 'img.etohost.ru'};

  test('превью только с хостов сервиса картинок', () {
    expect(
      imagePreviews(
        'смотри https://i.jab.su/V1LVzGN и https://img.etohost.ru/ggw1abc.jpg.',
        hosts,
      ).map((u) => u.toString()),
      ['https://i.jab.su/V1LVzGN', 'https://img.etohost.ru/ggw1abc.jpg'],
    );
  });

  test('без подключённого зеркала превью нет', () {
    expect(imagePreviews('https://i.jab.su/V1LVzGN', const {}), isEmpty);
    expect(
      imagePreviews('https://i.jab.su/V1LVzGN', {'img.etohost.ru'}),
      isEmpty,
    );
  });

  test('не картинки и чужие адреса — без превью', () {
    for (final t in [
      'https://i.jab.su/',
      'https://i.jab.su/api/v1/health',
      'https://i.jab.su/V1LVzGN?x=1',
      'ftp://i.jab.su/V1LVzGN',
      'https://img.etohost.ru/8315uyb.mp4',
      'https://evil.example/a.png',
      'https://i.jab.su.evil.example/V1LVzGN',
    ]) {
      expect(imagePreviews(t, hosts), isEmpty, reason: t);
    }
  });

  test('http грузится по https', () {
    expect(imagePreviews('http://img.etohost.ru/ggw1abc.jpg', hosts), [
      Uri.parse('https://img.etohost.ru/ggw1abc.jpg'),
    ]);
  });

  test('повторы схлопываются, не больше трёх', () {
    const a = 'https://i.jab.su/AAAAAAA';
    expect(imagePreviews('$a $a', hosts), hasLength(1));
    expect(
      imagePreviews(
        'https://i.jab.su/AAAAAA1 https://i.jab.su/AAAAAA2 '
        'https://i.jab.su/AAAAAA3 https://i.jab.su/AAAAAA4',
        hosts,
      ),
      hasLength(3),
    );
  });

  test('id картинки только у хоста сервиса', () {
    expect(
      serviceImageId(Uri.parse('https://i.jab.su/V1LVzGN'), 'i.jab.su'),
      'V1LVzGN',
    );
    expect(
      serviceImageId(
        Uri.parse('https://img.etohost.ru/ggw1abc.jpg'),
        'i.jab.su',
      ),
      isNull,
    );
    expect(
      serviceImageId(Uri.parse('https://i.jab.su/api/v1/health'), 'i.jab.su'),
      isNull,
    );
  });
}
