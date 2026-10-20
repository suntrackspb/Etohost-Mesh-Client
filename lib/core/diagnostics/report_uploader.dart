import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Отправка отчёта на сервер разработчика: POST `<base>/v1/reports`,
/// multipart: `info` (JSON), `comment`, `contact`, `log` (gzip).
/// Ответ — `{"id": "R-7K3M-Q9TX"}`: номер, по которому отчёт найдётся.
class ReportUploader {
  ReportUploader(this.baseUrl, this.apiKey, {http.Client? client})
    : _client = client ?? http.Client();

  /// Адрес и ключ задаются при сборке:
  /// `--dart-define=REPORT_URL=https://… --dart-define=REPORT_KEY=…`.
  static const configuredUrl = String.fromEnvironment('REPORT_URL');
  static const configuredKey = String.fromEnvironment('REPORT_KEY');

  static ReportUploader? fromEnvironment() => configuredUrl.isEmpty
      ? null
      : ReportUploader(Uri.parse(configuredUrl), configuredKey);

  final Uri baseUrl;
  final String apiKey;
  final http.Client _client;

  static const timeout = Duration(seconds: 60);

  Future<String> send({
    required Map<String, Object?> info,
    required String log,
    String comment = '',
    String contact = '',
  }) async {
    final req = http.MultipartRequest('POST', baseUrl.resolve('v1/reports'))
      ..headers['X-Api-Key'] = apiKey
      ..fields['info'] = jsonEncode(info)
      ..fields['comment'] = comment
      ..fields['contact'] = contact
      ..files.add(
        http.MultipartFile.fromBytes(
          'log',
          gzip.encode(utf8.encode(log)),
          filename: 'journal.log.gz',
        ),
      );
    final res = await http.Response.fromStream(
      await _client.send(req).timeout(timeout),
    );
    if (res.statusCode == 429) {
      throw const ReportError('слишком много отчётов, попробуйте позже');
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw ReportError('сервер ответил ${res.statusCode}');
    }
    final id = (jsonDecode(res.body) as Map)['id'];
    if (id is! String || id.isEmpty) {
      throw const ReportError('сервер не вернул номер отчёта');
    }
    return id;
  }
}

class ReportError implements Exception {
  const ReportError(this.message);
  final String message;
  @override
  String toString() => message;
}
