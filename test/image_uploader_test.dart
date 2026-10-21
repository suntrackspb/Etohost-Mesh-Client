import 'dart:convert';
import 'dart:typed_data';

import 'package:etohost_mesh/data/images/image_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Тот же пример, что test_known_vector в Etohost-Mesh-Images/tests/test_app.py.
final svcPub = base64.decode('j0DFrbaPJWJK5bIU6nZ6bslNgp09e14a0bpvPiE4KF8=');
final nodePriv = List<int>.generate(32, (i) => i + 32);
const knownKey =
    '7c6df901ff4ad7a7b9aa60ce2a47bbd4aa026527b275253980190fc92e942349';
const knownSig =
    '645701c60b9cda5befeacc792827d3d6d0ba3e743abf18fedb5d3c7308045a7f';
const node = '!9eeff120';
const ts = 1792540000;

void main() {
  test('ключ и подпись совпадают с сервисом', () async {
    final key = await ImageUploader.hmacKey(nodePriv, svcPub);
    expect(ImageUploader.hex(key), knownKey);
    final sha = ImageUploader.hex(
      await ImageUploader.sha256(utf8.encode('hello')),
    );
    expect(await ImageUploader.sign(key, node, ts, sha), knownSig);
  });

  test('загрузка: заголовки и разбор ответа', () async {
    late http.Request sent;
    final up = ImageUploader(
      Uri.parse('https://i.jab.su/'),
      svcPub,
      client: MockClient((r) async {
        sent = r;
        return http.Response(
          jsonEncode({
            'id': 'Ab3dE5f',
            'url': 'https://i.jab.su/Ab3dE5f',
            'delete_token': 'tok',
            'expires_at': '2026-10-24T01:55:10Z',
          }),
          201,
        );
      }),
    );
    final img = await up.upload(
      body: Uint8List.fromList(utf8.encode('hello')),
      node: '!9EEFF120',
      nodePrivateKey: nodePriv,
      now: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
    );
    expect(sent.url.toString(), 'https://i.jab.su/api/v1/upload');
    expect(sent.headers['X-Node'], node);
    expect(sent.headers['X-Sig'], knownSig);
    expect(img.url, 'https://i.jab.su/Ab3dE5f');
    expect(img.deleteToken, 'tok');
    expect(img.expiresAt, DateTime.utc(2026, 10, 24, 1, 55, 10));
  });

  test('ошибка сервера — русский текст', () async {
    final up = ImageUploader(
      Uri.parse('https://i.jab.su/'),
      svcPub,
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'node_unknown', 'detail': 'x'}),
          403,
        ),
      ),
    );
    expect(
      () => up.upload(body: Uint8List(1), node: node, nodePrivateKey: nodePriv),
      throwsA(isA<ImageError>().having((e) => e.code, 'code', 'node_unknown')),
    );
  });

  test('жалоба подписана нодой', () async {
    late http.Request sent;
    final up = ImageUploader(
      Uri.parse('https://i.jab.su/'),
      svcPub,
      client: MockClient((r) async {
        sent = r;
        return http.Response('{"ok":true}', 200);
      }),
    );
    await up.report(
      'Ab3dE5f',
      'спам',
      node: node,
      nodePrivateKey: nodePriv,
      now: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
    );
    expect(sent.url.toString(), 'https://i.jab.su/api/v1/Ab3dE5f/report');
    expect(jsonDecode(sent.body), {'reason': 'спам'});
    final sha = ImageUploader.hex(await ImageUploader.sha256(sent.bodyBytes));
    expect(sent.headers['X-Sha256'], sha);
    final key = await ImageUploader.hmacKey(nodePriv, svcPub);
    expect(sent.headers['X-Sig'], await ImageUploader.sign(key, node, ts, sha));
  });
}
