import 'database.dart';

/// Поиск по тексту ленты: без регистра, по всем словам запроса
/// («нода спать» найдёт «спать пойду, нода спит»).
abstract final class ChatSearch {
  static List<String> words(String query) => query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  static bool matches(String body, List<String> words) {
    if (words.isEmpty) return false;
    final b = body.toLowerCase();
    return words.every(b.contains);
  }

  static List<Message> filter(List<Message> newestFirst, String query) {
    final w = words(query);
    return [
      for (final m in newestFirst)
        if (matches(m.body, w)) m,
    ];
  }
}
