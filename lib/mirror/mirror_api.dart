import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/client_version.dart';

import '../data/jammer_zones.dart';
import 'mirror_models.dart';

/// «9c:13:9e:ef:f1:20» → байты; нулевой и неверный — null.
List<int>? parseMac(Object? v) {
  if (v is! String) return null;
  final p = v.split(RegExp('[:-]'));
  if (p.length != 6) return null;
  final b = [for (final x in p) int.tryParse(x, radix: 16) ?? -1];
  if (b.any((x) => x < 0 || x > 255) || b.every((x) => x == 0)) return null;
  return b;
}

class MirrorApiException implements Exception {
  MirrorApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// REST API зеркала. Перенос 1:1 из iOS (MirrorAPI.swift).
class MirrorApi {
  MirrorApi(this.baseUrl, {http.Client? client})
    : _client = client ?? VersionedClient();

  final Uri baseUrl;
  final http.Client _client;

  static const timeout = Duration(seconds: 20);

  Future<List<MirrorNode>> nodes({DateTime? updatedSince}) async {
    final j = await _get('api/nodes', {
      if (updatedSince != null)
        'updated_since': updatedSince.toUtc().toIso8601String(),
    });
    final list = j is Map ? j['nodes'] : null;
    return [
      for (final n in (list is List ? list : const [])) ?MirrorNode.tryParse(n),
    ];
  }

  /// Зоны глушилок; null — сервер их не отдаёт (старая версия).
  Future<JammerZones?> jammerZones() async =>
      JammerZones.fromJson(await _get('api/jammer-zones'));

  /// Полная карточка ноды (отсюда — публичный ключ, когда сервер начнёт его отдавать).
  Future<MirrorNode?> node(String id) async =>
      MirrorNode.tryParse(await _get('api/nodes/$id'));

  /// MAC ноды из карточки зеркала (`mac_addr`, «9c:13:…»); null — не отдаёт.
  /// В общий список не входит — только по одной ноде.
  Future<List<int>?> nodeMac(String id) async {
    final raw = await _get('api/nodes/$id');
    return raw is Map<String, dynamic> ? parseMac(raw['mac_addr']) : null;
  }

  Future<List<MirrorMessage>> chatHistory({
    required int beforeId,
    int limit = 100,
  }) async => parseMirrorMessages(
    await _get('api/chat/history', {
      'before_id': '$beforeId',
      'limit': '$limit',
    }),
  );

  /// Проверка адреса перед включением: отвечает ли сервер как зеркало.
  Future<int> probe() async => (await nodes()).length;

  Future<Object?> _get(String path, [Map<String, String>? query]) async {
    final url = baseUrl.replace(
      path: '/$path',
      queryParameters: query?.isEmpty ?? true ? null : query,
    );
    final http.Response r;
    try {
      r = await _client.get(url).timeout(timeout);
    } on TimeoutException {
      throw MirrorApiException('сервер не ответил за ${timeout.inSeconds} с');
    } catch (e) {
      throw MirrorApiException('нет связи с сервером: $e');
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw MirrorApiException('сервер ответил ${r.statusCode} на /$path');
    }
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } on FormatException {
      throw MirrorApiException('ответ не похож на API зеркала (не JSON)');
    }
  }

  void close() => _client.close();
}
