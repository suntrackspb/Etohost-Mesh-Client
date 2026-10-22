import 'dart:convert';

/// Быстрые реакции по умолчанию — пока человек ничего не выбирал.
const defaultReactions = [
  '👍', '❤️', '😂', '😮', '😢', '👎', //
  '🔥', '👏', '🙏', '🤝', '👋',
];

/// Сколько эмодзи в быстрой панели: два ряда по 6, последнее место — «+».
const quickReactionCount = 11;

/// Недавние реакции из настройки (JSON-список), мусор — пусто.
List<String> parseRecentReactions(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];
    return [
      for (final v in list)
        if (v is String && v.isNotEmpty) v,
    ];
  } on FormatException {
    return const [];
  }
}

String encodeRecentReactions(List<String> list) => jsonEncode(list);

/// Поставили [emoji]: он первым, без повторов, не больше [max].
List<String> useReaction(
  List<String> recent,
  String emoji, {
  int max = quickReactionCount,
}) => [emoji, ...recent.where((e) => e != emoji)].take(max).toList();

/// Быстрая панель: сначала недавние, свободные места — по умолчанию.
List<String> quickReactions(List<String> recent) => [
  ...recent,
  ...defaultReactions.where((e) => !recent.contains(e)),
].take(quickReactionCount).toList();
