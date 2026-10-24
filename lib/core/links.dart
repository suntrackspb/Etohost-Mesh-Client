/// Кусок текста сообщения: обычный текст или ссылка.
typedef TextPart = ({String text, Uri? link});

/// Зоны, по которым адрес без http(s):// и www. считаем ссылкой
/// («tmesh.ru/s/w»). Только известные — иначе «2.7.18» или «file.txt».
const _bareZones =
    'ru|su|com|net|org|io|me|info|biz|dev|app|online|site|xyz|pro|club|'
    'tech|cc|co|tv|by|kz|ua|uz|de|eu|uk|fm|gg|ly|to';

final _url = RegExp(
  r'(?:https?://|www\.)[^\s<>"]+'
  // Голый домен: не после буквы, @ (почта) или точки; затем путь.
  r'|(?<![\w@.\-/])(?:[\p{L}\d](?:[\p{L}\d\-]*[\p{L}\d])?\.)+'
  '(?:$_bareZones)'
  r'(?![\p{L}\d\-])(?:[/?#][^\s<>"]*)?',
  caseSensitive: false,
  unicode: true,
);

/// Делит текст на куски, выделяя ссылки http(s)://…, www.… и голые
/// домены известных зон (tmesh.ru/s/w) — им подставляется https://.
/// Хвостовая пунктуация («.», «,», «)» и т.п.) в ссылку не входит.
List<TextPart> splitLinks(String text) {
  final parts = <TextPart>[];
  var pos = 0;
  for (final m in _url.allMatches(text)) {
    var raw = m.group(0)!;
    while (raw.isNotEmpty && '.,;:!?)]}»\'"'.contains(raw[raw.length - 1])) {
      // Закрывающую скобку оставляем, если открывающая внутри ссылки.
      if (raw.endsWith(')') &&
          '('.allMatches(raw).length >= ')'.allMatches(raw).length) {
        break;
      }
      raw = raw.substring(0, raw.length - 1);
    }
    final uri = Uri.tryParse(
      raw.toLowerCase().startsWith(RegExp('https?://')) ? raw : 'https://$raw',
    );
    if (uri == null || uri.host.isEmpty) continue;
    if (m.start > pos) {
      parts.add((text: text.substring(pos, m.start), link: null));
    }
    parts.add((text: raw, link: uri));
    pos = m.start + raw.length;
  }
  if (pos < text.length) parts.add((text: text.substring(pos), link: null));
  return parts;
}

final _jabId = RegExp(r'^/[A-Za-z0-9]{7}$');
final _etohostFile = RegExp(
  r'^/[A-Za-z0-9_-]+\.(png|jpe?g|webp|gif)$',
  caseSensitive: false,
);

/// Ссылка на картинку, которую можно показать прямо в ленте: только свои
/// сервисы (i.jab.su и img.etohost.ru), чужие адреса не грузим — иначе
/// любой собеседник узнает IP по запросу к своему серверу. Ссылку http
/// грузим по https: оба сервиса его отдают, а iOS http без исключений не
/// пускает.
Uri? imagePreview(Uri link) {
  if (!const {'http', 'https'}.contains(link.scheme) ||
      link.hasQuery ||
      link.hasFragment) {
    return null;
  }
  link = link.replace(scheme: 'https');
  return switch (link.host.toLowerCase()) {
    'i.jab.su' when _jabId.hasMatch(link.path) => link,
    'img.etohost.ru' when _etohostFile.hasMatch(link.path) => link,
    _ => null,
  };
}

/// Картинки для превью из текста сообщения (без повторов, не больше [max]).
List<Uri> imagePreviews(String text, {int max = 3}) {
  final out = <Uri>[];
  for (final p in splitLinks(text)) {
    final u = p.link == null ? null : imagePreview(p.link!);
    if (u != null && !out.contains(u)) out.add(u);
    if (out.length == max) break;
  }
  return out;
}

/// id картинки сервиса i.jab.su (там есть удаление и жалобы), иначе null.
String? jabImageId(Uri link) =>
    link.host.toLowerCase() == 'i.jab.su' && imagePreview(link) != null
    ? link.path.substring(1)
    : null;
