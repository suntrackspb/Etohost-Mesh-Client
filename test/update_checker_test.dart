import 'dart:convert';

import 'package:meshex/core/update/update_checker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('сравнение версий', () {
    expect(isNewerVersion('v0.1.2', '0.1.1'), isTrue);
    expect(isNewerVersion('v0.2.0', '0.1.9'), isTrue);
    expect(isNewerVersion('v1.0', '0.9.9'), isTrue);
    expect(isNewerVersion('v0.1.1', '0.1.1'), isFalse);
    expect(isNewerVersion('v0.1.0', '0.1.1'), isFalse);
    expect(isNewerVersion('prototype-12', '0.1.1'), isFalse);
  });

  test('разбор ответа GitHub', () async {
    final client = MockClient(
      (_) async => http.Response.bytes(
        utf8.encode(
          '{"tag_name":"v0.1.2","name":"Meshex v0.1.2",'
          '"html_url":"https://github.com/x/y/releases/tag/v0.1.2","body":"Что нового"}',
        ),
        200,
      ),
    );
    final r = await fetchLatestRelease(client: client);
    expect(r!.version, '0.1.2');
    expect(r.notes, 'Что нового');
  });

  test('тег не версия — релиза нет', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"tag_name":"prototype-5","html_url":"https://x"}',
        200,
      ),
    );
    expect(await fetchLatestRelease(client: client), isNull);
  });
}
