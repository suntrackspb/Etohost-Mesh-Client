import 'dart:convert';

import 'package:etohost_mesh/mirror/mirror_capabilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final key = base64.encode(List.filled(32, 7));

  test('пустой ответ — ничего не умеет', () {
    final c = MirrorCapabilities.parse({'version': 1});
    expect(c.images, isNull);
    expect(c.contact, isNull);
    expect(MirrorCapabilities.parse('мусор').images, isNull);
  });

  test('картинки из ответа зеркала', () {
    final c = MirrorCapabilities.parse({
      'version': 1,
      'operator': {'contact': 'admin@etohost.ru'},
      'images': {
        'enabled': true,
        'base_url': 'https://i.jab.su',
        'public_key': key,
        'max_bytes': 5 * 1024 * 1024,
        'preview_hosts': ['i.jab.su', 'IMG.etohost.ru'],
        'report': true,
        'delete': true,
      },
    });
    expect(c.contact, 'admin@etohost.ru');
    final i = c.images!;
    expect(i.baseUrl.toString(), 'https://i.jab.su/');
    expect(i.publicKey, hasLength(32));
    expect(i.maxBytes, 5 * 1024 * 1024);
    expect(i.previewHosts, {'i.jab.su', 'img.etohost.ru'});
    expect(i.host, 'i.jab.su');
    expect(i.report && i.delete, isTrue);
  });

  test('без preview_hosts — хост сервиса', () {
    final i = ImagesCapability.tryParse({
      'enabled': true,
      'base_url': 'https://m.example.org/img/',
      'public_key': key,
    })!;
    expect(i.previewHosts, {'m.example.org'});
    expect(i.report, isFalse);
  });

  test('выключено, http или плохой ключ — картинок нет', () {
    for (final j in [
      {'enabled': false, 'base_url': 'https://i.jab.su/', 'public_key': key},
      {'enabled': true, 'base_url': 'http://i.jab.su/', 'public_key': key},
      {'enabled': true, 'base_url': 'https://i.jab.su/', 'public_key': 'AAAA'},
      {'enabled': true, 'base_url': 'https://i.jab.su/', 'public_key': '!!'},
    ]) {
      expect(ImagesCapability.tryParse(j), isNull, reason: '$j');
    }
  });

  test('отчёты: только https', () {
    final r = MirrorCapabilities.parse({
      'reports': {
        'base_url': 'https://report.etohost.ru',
        'api_key': 'k',
        'notices': true,
      },
    }).reports!;
    expect(r.baseUrl.toString(), 'https://report.etohost.ru/');
    expect(r.apiKey, 'k');
    expect(r.notices, isTrue);
    expect(
      ReportsCapability.tryParse({'base_url': 'http://report.etohost.ru/'}),
      isNull,
    );
    expect(MirrorCapabilities.parse({'version': 1}).reports, isNull);
  });
}
