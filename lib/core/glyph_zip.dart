/// GlyphZip: кириллица в UTF-8 — 2 байта на букву, латиница — 1. Похожие буквы
/// меняем на латинские, чтобы в лимит пакета влезало больше текста.
/// Таблицы и порядок проверки — как в iOS-клиенте (из github.com/5CORNERS/GlyphZip).
abstract final class GlyphZip {
  /// 0 — выкл, 1 — безопасные замены, 2 — плюс похожие символы, 3 — максимум.
  static const maxLevel = 3;

  static const _group1 = {
    'А': 'A', 'В': 'B', 'Е': 'E', 'К': 'K', 'М': 'M', 'Н': 'H', 'О': 'O', //
    'Р': 'P', 'С': 'C', 'Т': 'T', 'Х': 'X', 'а': 'a', 'е': 'e', 'ё': 'e',
    'о': 'o', 'р': 'p', 'с': 'c', 'у': 'y', 'х': 'x', '—': '-',
  };
  static const _group2 = {'т': 'm', 'п': 'n', 'и': 'u', 'д': 'g'};
  static const _group3 = {
    'б': '6', 'З': '3', 'У': 'Y', 'Д': 'D', 'к': 'k', 'г': 'r', 'т': 't', //
    'ш': 'w', 'Ш': 'W', 'ч': '4', 'ь': 'b',
  };

  static String apply(String text, int level) {
    if (level <= 0) return text;
    final out = StringBuffer();
    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      out.write(
        (level >= 2 ? _group2[ch] : null) ??
            (level >= 3 ? _group3[ch] : null) ??
            _group1[ch] ??
            ch,
      );
    }
    return out.toString();
  }

  static const hints = [
    'GlyphZip выключен',
    'Уровень 1: безопасные замены',
    'Уровень 2: + похожие символы',
    'Уровень 3: максимальное сжатие',
  ];
}
