import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

import '../../core/client_version.dart';

/// Загрузка картинки на сервис картинок подключённого зеркала (адрес и ключ
/// — из его capabilities).
///
/// Запрос подписан ключом своей ноды: secret = X25519(ключ ноды, ключ
/// сервиса), из него HKDF-SHA256 даёт ключ HMAC, им подписано
/// `v1\n<node>\n<ts>\n<sha256>`. Сервис берёт публичный ключ ноды из базы
/// зеркала — без ноды, известной зеркалу, загрузить нельзя.
class ImageUploader {
  ImageUploader(this.baseUrl, this.servicePublicKey, {http.Client? client})
    : _client = client ?? VersionedClient();

  final Uri baseUrl;
  final List<int> servicePublicKey;
  final http.Client _client;

  static const timeout = Duration(seconds: 90);

  static Never _timedOut() => throw const ImageError(
    'Сервис картинок не отвечает — проверьте интернет',
  );
  static const _info = 'etohost-mesh-images v1';

  /// Ключ HMAC для пары (своя нода, сервис).
  static Future<List<int>> hmacKey(
    List<int> nodePrivateKey,
    List<int> servicePublicKey,
  ) async {
    final x = X25519();
    final pair = await x.newKeyPairFromSeed(nodePrivateKey);
    final shared = await x.sharedSecretKey(
      keyPair: pair,
      remotePublicKey: SimplePublicKey(
        servicePublicKey,
        type: KeyPairType.x25519,
      ),
    );
    final key = await Hkdf(
      hmac: Hmac.sha256(),
      outputLength: 32,
    ).deriveKey(secretKey: shared, nonce: const [], info: utf8.encode(_info));
    return key.extractBytes();
  }

  static Future<String> sign(
    List<int> key,
    String node,
    int ts,
    String sha256Hex,
  ) async {
    final mac = await Hmac.sha256().calculateMac(
      utf8.encode('v1\n$node\n$ts\n$sha256Hex'),
      secretKey: SecretKey(key),
    );
    return hex(mac.bytes);
  }

  static Future<List<int>> sha256(List<int> b) async =>
      (await Sha256().hash(b)).bytes;

  static String hex(List<int> b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

  /// Заголовки подписи ноды для тела запроса.
  Future<Map<String, String>> _signed(
    List<int> body,
    String node,
    List<int> nodePrivateKey,
    DateTime? now,
  ) async {
    final n = node.toLowerCase();
    final ts = (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    final sha = hex(await sha256(body));
    final key = await hmacKey(nodePrivateKey, servicePublicKey);
    return {
      'X-Node': n,
      'X-Ts': '$ts',
      'X-Sha256': sha,
      'X-Sig': await sign(key, n, ts, sha),
    };
  }

  Future<UploadedImage> upload({
    required Uint8List body,
    required String node,
    required List<int> nodePrivateKey,
    DateTime? now,
  }) async {
    final res = await _client
        .post(
          baseUrl.resolve('api/v1/upload'),
          headers: {
            ...await _signed(body, node, nodePrivateKey, now),
            'Content-Type': 'application/octet-stream',
          },
          body: body,
        )
        .timeout(timeout, onTimeout: _timedOut);
    if (res.statusCode != 201) throw ImageError.fromResponse(res);
    return UploadedImage.fromJson(jsonDecode(res.body) as Map<String, Object?>);
  }

  Future<void> delete(String id, String deleteToken) async {
    final res = await _client
        .delete(
          baseUrl.resolve('api/v1/$id'),
          headers: {'X-Delete-Token': deleteToken},
        )
        .timeout(timeout, onTimeout: _timedOut);
    if (res.statusCode != 200 && res.statusCode != 404) {
      throw ImageError.fromResponse(res);
    }
  }

  /// Жалоба подписана нодой, как загрузка (без ноды сервис жалобу не примет).
  /// Повторная жалоба той же ноды на ту же картинку — тоже успех.
  Future<void> report(
    String id,
    String reason, {
    required String node,
    required List<int> nodePrivateKey,
    DateTime? now,
  }) async {
    final body = utf8.encode(jsonEncode({'reason': reason}));
    final res = await _client
        .post(
          baseUrl.resolve('api/v1/$id/report'),
          headers: {
            ...await _signed(body, node, nodePrivateKey, now),
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .timeout(timeout, onTimeout: _timedOut);
    if (res.statusCode != 200) throw ImageError.fromResponse(res);
  }
}

class UploadedImage {
  const UploadedImage({
    required this.id,
    required this.url,
    required this.deleteToken,
    required this.expiresAt,
  });

  factory UploadedImage.fromJson(Map<String, Object?> j) => UploadedImage(
    id: j['id']! as String,
    url: j['url']! as String,
    deleteToken: j['delete_token']! as String,
    expiresAt: DateTime.parse(j['expires_at']! as String),
  );

  final String id;
  final String url;
  final String deleteToken;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'url': url,
    'delete_token': deleteToken,
    'expires_at': expiresAt.toUtc().toIso8601String(),
  };
}

class ImageError implements Exception {
  const ImageError(this.message, {this.code});

  factory ImageError.fromResponse(http.Response res) {
    String? code;
    String? detail;
    try {
      final j = jsonDecode(res.body) as Map;
      code = j['error'] as String?;
      detail = j['detail'] as String?;
    } catch (_) {}
    return ImageError(
      messages[code] ?? detail ?? 'сервер ответил ${res.statusCode}',
      code: code,
    );
  }

  static const messages = {
    'node_unknown':
        'Сервис пока не знает вашу ноду: она должна появиться на карте зеркала',
    'bad_signature':
        'Подпись не принята — ключ ноды изменился? Попробуйте позже',
    'stale_ts': 'Неверное время на устройстве',
    'no_mac':
        'Нода ещё не передала свои данные в сеть — подождите и попробуйте позже',
    'banned': 'Загрузка картинок для вас заблокирована',
    'rate_limited': 'Слишком часто, попробуйте позже',
    'not_found': 'Картинки уже нет',
    'too_large': 'Картинка слишком большая',
    'bad_image': 'Файл не похож на картинку',
    'keys_unavailable': 'Сервис временно недоступен',
  };

  final String message;
  final String? code;

  @override
  String toString() => message;
}
