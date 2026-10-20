import 'message_sender.dart';

/// Длинный текст — несколькими сообщениями с префиксом `[i/N] `.
abstract final class MessageSplit {
  /// Больше частей не шлём: длинная «простыня» забивает эфир.
  static const maxParts = 10;

  /// Пауза между частями.
  static const delay = Duration(seconds: 3);

  static String prefix(int i, int n) => '[$i/$n] ';

  /// Части для отправки; один элемент — текст влезает целиком (без
  /// префикса). Пусто — текст пуст. Частей может быть больше [maxParts] —
  /// проверяет вызывающий.
  static List<String> split(String text, {int max = maxMessageBytes}) {
    final t = text.trim();
    if (t.isEmpty) return const [];
    if (messageBytes(t) <= max) return [t];
    // Ширина префикса зависит от числа частей: подбираем число цифр.
    for (var digits = 1; ; digits++) {
      final widest = messageBytes(prefix(_nines(digits), _nines(digits)));
      final chunks = _wrap(t, max - widest);
      if (chunks.length <= _nines(digits)) {
        final n = chunks.length;
        return [for (var i = 0; i < n; i++) '${prefix(i + 1, n)}${chunks[i]}'];
      }
    }
  }

  static int _nines(int digits) {
    var v = 0;
    for (var i = 0; i < digits; i++) {
      v = v * 10 + 9;
    }
    return v;
  }

  /// По словам (пробелы и переводы строк внутри части сохраняются); слово
  /// длиннее части — по символам.
  static List<String> _wrap(String text, int budget) {
    final out = <String>[];
    var cur = '';
    void flush() {
      final c = cur.trim();
      if (c.isNotEmpty) out.add(c);
      cur = '';
    }

    for (final m in RegExp(r'\S+\s*').allMatches(text)) {
      final token = m.group(0)!;
      final word = token.trimRight();
      if (messageBytes(cur + word) <= budget) {
        cur += token;
        continue;
      }
      flush();
      if (messageBytes(word) <= budget) {
        cur = token;
        continue;
      }
      // Слово не влезает целиком — режем по символам (руны не рвём).
      for (final r in word.runes) {
        final ch = String.fromCharCode(r);
        if (messageBytes(cur + ch) > budget) flush();
        cur += ch;
      }
      cur += token.substring(word.length);
    }
    flush();
    return out;
  }
}
