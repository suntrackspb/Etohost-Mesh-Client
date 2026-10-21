/// Кусок текста сообщения: обычный текст или ссылка.
typedef TextPart = ({String text, Uri? link});

final _url = RegExp(r'(?:https?://|www\.)[^\s<>"]+', caseSensitive: false);

/// Делит текст на куски, выделяя ссылки http(s)://… и www.…
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
      raw.toLowerCase().startsWith('www.') ? 'https://$raw' : raw,
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
/// любой собеседник узнает IP по запросу к своему серверу.
Uri? imagePreview(Uri link) {
  if (link.scheme != 'https' || link.hasQuery || link.hasFragment) {
    return null;
  }
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
