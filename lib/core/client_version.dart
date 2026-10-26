import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Версия приложения в запросах к своим сервисам (зеркало, картинки):
/// по ней сервер сможет отказать устаревшим клиентам. Задаётся при запуске
/// из PackageInfo — в CI это версия из тега (--build-name).
String clientVersion = '';

/// Заголовки версии; пусто, пока версия не известна.
Map<String, String> clientHeaders() => clientVersion.isEmpty
    ? const {}
    : {
        'X-Etohost-Version': clientVersion,
        'X-Etohost-Platform': Platform.operatingSystem,
      };

/// Сервер отказал этой версии (HTTP 426): текст для плашки «обновите
/// приложение». null — отказа не было.
final outdatedMessage = ValueNotifier<String?>(null);

const defaultOutdatedText =
    'Эта версия Etohost Mesh устарела и больше не работает с зеркалом и '
    'картинками. Обновите приложение.';

/// Текст отказа из тела ответа: JSON {"message": …}, иначе сам текст;
/// пусто или не разобрать — [defaultOutdatedText].
String outdatedText(String body) {
  final t = body.trim();
  try {
    final j = jsonDecode(t);
    if (j is Map && j['message'] is String && '${j['message']}'.isNotEmpty) {
      return '${j['message']}';
    }
  } catch (_) {}
  return t.isEmpty || t.startsWith('{') || t.startsWith('<')
      ? defaultOutdatedText
      : t;
}

/// http.Client, добавляющий [clientHeaders] к каждому запросу и
/// замечающий отказ по версии (426).
class VersionedClient extends http.BaseClient {
  VersionedClient([http.Client? inner]) : _inner = inner ?? http.Client();

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(clientHeaders());
    final res = await _inner.send(request);
    if (res.statusCode != 426) return res;
    // Тело читаем ради текста и отдаём дальше заново.
    final body = await res.stream.toBytes();
    outdatedMessage.value = outdatedText(
      utf8.decode(body, allowMalformed: true),
    );
    return http.StreamedResponse(
      Stream.value(body),
      res.statusCode,
      contentLength: body.length,
      request: res.request,
      headers: res.headers,
      reasonPhrase: res.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();
}
