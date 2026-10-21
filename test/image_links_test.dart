import 'package:etohost_mesh/core/links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('превью только для своих сервисов', () {
    expect(
      imagePreviews(
        'смотри https://i.jab.su/V1LVzGN и https://img.etohost.ru/ggw1abc.jpg.',
      ).map((u) => u.toString()),
      ['https://i.jab.su/V1LVzGN', 'https://img.etohost.ru/ggw1abc.jpg'],
    );
  });

  test('не картинки и чужие адреса — без превью', () {
    for (final t in [
      'https://i.jab.su/',
      'https://i.jab.su/api/v1/health',
      'https://i.jab.su/V1LVzGN?x=1',
      'http://i.jab.su/V1LVzGN',
      'https://img.etohost.ru/8315uyb.mp4',
      'https://evil.example/a.png',
      'https://i.jab.su.evil.example/V1LVzGN',
    ]) {
      expect(imagePreviews(t), isEmpty, reason: t);
    }
  });

  test('повторы схлопываются, не больше трёх', () {
    const a = 'https://i.jab.su/AAAAAAA';
    expect(imagePreviews('$a $a'), hasLength(1));
    expect(
      imagePreviews(
        'https://i.jab.su/AAAAAA1 https://i.jab.su/AAAAAA2 '
        'https://i.jab.su/AAAAAA3 https://i.jab.su/AAAAAA4',
      ),
      hasLength(3),
    );
  });

  test('id картинки только у i.jab.su', () {
    expect(jabImageId(Uri.parse('https://i.jab.su/V1LVzGN')), 'V1LVzGN');
    expect(jabImageId(Uri.parse('https://img.etohost.ru/ggw1abc.jpg')), isNull);
    expect(jabImageId(Uri.parse('https://i.jab.su/api/v1/health')), isNull);
  });
}
