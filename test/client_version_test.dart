import 'package:meshex/core/client_version.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('версия в заголовке, пока известна', () async {
    Map<String, String>? seen;
    final c = VersionedClient(
      MockClient((r) async {
        seen = r.headers;
        return http.Response('', 200);
      }),
    );
    clientVersion = '';
    await c.get(Uri.parse('https://x/a'));
    expect(seen!.containsKey('X-Meshex-Version'), isFalse);
    clientVersion = '0.1.13';
    await c.get(Uri.parse('https://x/a'));
    expect(seen!['X-Meshex-Version'], '0.1.13');
    expect(seen!['X-Meshex-Platform'], isNotEmpty);
    clientVersion = '';
  });

  test('426 — текст отказа для плашки, ответ доходит целым', () async {
    outdatedMessage.value = null;
    final c = VersionedClient(
      MockClient(
        (r) async => http.Response(
          '{"message":"Обновитесь"}',
          426,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
    final r = await c.get(Uri.parse('https://x/a'));
    expect(r.statusCode, 426);
    expect(r.body, contains('Обновитесь'));
    expect(outdatedMessage.value, 'Обновитесь');
    outdatedMessage.value = null;
  });

  test('outdatedText', () {
    expect(outdatedText('Старая версия'), 'Старая версия');
    expect(outdatedText(''), defaultOutdatedText);
    expect(outdatedText('<html>'), defaultOutdatedText);
    expect(outdatedText('{"error":1}'), defaultOutdatedText);
  });
}
