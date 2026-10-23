import 'dart:convert';

import 'database.dart';

/// Фильтр сообщений (как Message Filter в Meshtastic-Android): слова
/// ищутся целиком без учёта регистра, запись `regex:шаблон` —
/// регулярное выражение. Неверный шаблон пропускается.
class MessageFilter {
  MessageFilter({this.enabled = false, this.words = const []})
    : _patterns = [for (final w in words) ?compileFilterWord(w)];

  final bool enabled;
  final List<String> words;
  final List<RegExp> _patterns;

  /// Префикс регулярного выражения.
  static const regexPrefix = 'regex:';

  /// Текст длиннее не проверяем целиком (как у Android).
  static const maxCheckLength = 10000;

  /// Скрывать ли сообщение. [disabledHere] — фильтр выключен в этом чате.
  bool hides(String text, {bool disabledHere = false}) {
    if (!enabled || disabledHere || _patterns.isEmpty) return false;
    final t = text.length > maxCheckLength
        ? text.substring(0, maxCheckLength)
        : text;
    return _patterns.any((p) => p.hasMatch(t));
  }
}

/// Слово или `regex:шаблон` → RegExp; пустое или неверное — null.
/// Граница слова — не буква и не цифра (Unicode): `\b` в Dart знает
/// только латиницу.
RegExp? compileFilterWord(String word) {
  final w = word.trim();
  if (w.isEmpty) return null;
  try {
    if (w.startsWith(MessageFilter.regexPrefix)) {
      final src = w.substring(MessageFilter.regexPrefix.length);
      if (src.isEmpty) return null;
      return RegExp(src, caseSensitive: false, unicode: true);
    }
    return RegExp(
      '(?<![\\p{L}\\p{N}_])${RegExp.escape(w)}(?![\\p{L}\\p{N}_])',
      caseSensitive: false,
      unicode: true,
    );
  } on FormatException {
    return null;
  }
}

/// Добавить слово: без пустых и повторов (без учёта регистра).
List<String> addFilterWord(List<String> words, String word) {
  final w = word.trim();
  if (w.isEmpty || words.any((x) => x.toLowerCase() == w.toLowerCase())) {
    return words;
  }
  return [...words, w];
}

/// Список строк в настройках — JSON; битое — пусто.
List<String> decodeStringList(String? s) {
  if (s == null || s.isEmpty) return const [];
  try {
    return [
      for (final v in jsonDecode(s) as List)
        if (v is String) v,
    ];
  } catch (_) {
    return const [];
  }
}

String encodeStringList(List<String> l) => jsonEncode(l);

/// Лента после фильтра: [shown] — что показать, [filtered] — скрытые
/// фильтром (при [showFiltered] они остаются в [shown] с пометкой).
/// Свои сообщения не фильтруются.
({List<Message> shown, Set<Message> filtered}) filterFeed(
  List<Message> all,
  MessageFilter? f, {
  bool disabledHere = false,
  bool showFiltered = false,
}) {
  if (f == null || !f.enabled || disabledHere) {
    return (shown: all, filtered: const {});
  }
  final filtered = {
    for (final m in all)
      if (!m.isOutgoing && f.hides(m.body)) m,
  };
  return (
    shown: showFiltered || filtered.isEmpty
        ? all
        : [
            for (final m in all)
              if (!filtered.contains(m)) m,
          ],
    filtered: filtered,
  );
}
