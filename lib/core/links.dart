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
