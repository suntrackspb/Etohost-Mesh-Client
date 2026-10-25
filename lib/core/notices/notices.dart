import 'dart:convert';

import 'package:http/http.dart' as http;

import '../update/update_checker.dart';

/// Важность объявления: critical — красная плашка, закрывается только
/// до перезапуска; info и warning закрываются насовсем.
enum NoticeLevel { info, warning, critical }

/// Объявление разработчика (сервис отчётов, `GET /v1/notices`).
class Notice {
  const Notice({
    required this.id,
    required this.text,
    this.level = NoticeLevel.info,
    this.linkUrl,
    this.linkLabel,
    this.minVersion,
    this.maxVersion,
    this.platforms,
    this.expires,
  });

  final String id;
  final String text;
  final NoticeLevel level;
  final Uri? linkUrl;
  final String? linkLabel;

  /// Для каких версий приложения (включительно); null — без границы.
  final String? minVersion;
  final String? maxVersion;

  /// android, ios, macos, windows, linux; null — для всех.
  final List<String>? platforms;
  final DateTime? expires;

  static Notice? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'], text = raw['text'];
    if (id is! String || id.isEmpty || text is! String || text.trim().isEmpty) {
      return null;
    }
    final link = raw['link'];
    final url = link is Map ? Uri.tryParse('${link['url']}') : null;
    final platforms = raw['platforms'];
    return Notice(
      id: id,
      text: text.trim(),
      level: NoticeLevel.values.asNameMap()[raw['level']] ?? NoticeLevel.info,
      linkUrl: url != null && url.isScheme('https') ? url : null,
      linkLabel: link is Map ? link['label'] as String? : null,
      minVersion: raw['min_version'] as String?,
      maxVersion: raw['max_version'] as String?,
      platforms: platforms is List
          ? platforms.whereType<String>().toList()
          : null,
      expires: DateTime.tryParse('${raw['expires']}'),
    );
  }
}

/// Разобрать ответ сервера; битые записи пропускаются.
List<Notice> parseNotices(String body) {
  final data = jsonDecode(body);
  if (data is! List) return const [];
  return [for (final r in data) ?Notice.tryParse(r)];
}

/// Объявление касается этой сборки: версия в диапазоне, платформа
/// подходит, срок не вышел.
bool noticeApplies(
  Notice n, {
  required String version,
  required String platform,
  required DateTime now,
}) {
  if (n.expires != null && !now.isBefore(n.expires!)) return false;
  if (n.platforms != null && !n.platforms!.contains(platform)) return false;
  if (n.minVersion != null && isNewerVersion(n.minVersion!, version)) {
    return false;
  }
  if (n.maxVersion != null && isNewerVersion(version, n.maxVersion!)) {
    return false;
  }
  return true;
}

/// Что показать: подходящие и не закрытые; сначала важные.
List<Notice> visibleNotices(
  List<Notice> all, {
  required String version,
  required String platform,
  required DateTime now,
  required Set<String> dismissed,
}) => [
  for (final n in all)
    if (!dismissed.contains(n.id) &&
        noticeApplies(n, version: version, platform: platform, now: now))
      n,
]..sort((a, b) => b.level.index.compareTo(a.level.index));

/// Не чаще раза в [noticesInterval] — если не прошло, проверку пропускаем.
const noticesInterval = Duration(minutes: 10);

bool noticesDue(DateTime? last, DateTime now) =>
    last == null || now.difference(last) >= noticesInterval;

/// Запрос объявлений: GET `<base>/v1/notices` с ключом приложения.
Future<List<Notice>> fetchNotices(
  Uri base,
  String apiKey, {
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  try {
    final res = await c
        .get(base.resolve('v1/notices'), headers: {'X-Api-Key': apiKey})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('notices: ${res.statusCode}');
    return parseNotices(utf8.decode(res.bodyBytes));
  } finally {
    if (client == null) c.close();
  }
}
