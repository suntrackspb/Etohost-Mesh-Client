import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Репозиторий с релизами приложения.
const releasesRepo = 'suntrackspb/Etohost-Mesh-Client';

/// Вышедший релиз на GitHub.
class AppRelease {
  const AppRelease({
    required this.version,
    required this.name,
    required this.url,
    this.notes = '',
  });

  /// Версия из тега без «v» (1.2.3).
  final String version;
  final String name;

  /// Страница релиза.
  final Uri url;
  final String notes;
}

/// Последний релиз (без черновиков и пре-релизов). null — релизов с тегом vX.Y.Z нет.
Future<AppRelease?> fetchLatestRelease({
  http.Client? client,
  Duration timeout = const Duration(seconds: 10),
}) async {
  final c = client ?? http.Client();
  try {
    final r = await c
        .get(
          Uri.https('api.github.com', '/repos/$releasesRepo/releases/latest'),
          headers: {'Accept': 'application/vnd.github+json'},
        )
        .timeout(timeout);
    if (r.statusCode == 404) return null;
    if (r.statusCode != 200) {
      throw http.ClientException('GitHub ответил ${r.statusCode}');
    }
    final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    final tag = j['tag_name'] as String? ?? '';
    if (parseVersion(tag) == null) return null;
    return AppRelease(
      version: tag.replaceFirst(RegExp('^v'), ''),
      name: j['name'] as String? ?? tag,
      url: Uri.parse(j['html_url'] as String),
      notes: j['body'] as String? ?? '',
    );
  } finally {
    if (client == null) c.close();
  }
}

/// «v1.2.3», «1.2.3+4», «1.2» → [1, 2, 3]; не версия — null.
List<int>? parseVersion(String s) {
  final m = RegExp(r'^v?(\d+)\.(\d+)(?:\.(\d+))?').firstMatch(s.trim());
  if (m == null) return null;
  return [int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3] ?? '0')];
}

/// [candidate] новее [current].
bool isNewerVersion(String candidate, String current) {
  final a = parseVersion(candidate), b = parseVersion(current);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] > b[i];
  }
  return false;
}
