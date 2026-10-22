/// Поиск по настройкам: разделы и поля внутри них.
class SettingsEntry {
  const SettingsEntry({
    required this.title,
    required this.route,
    this.section,
    this.help,
  });

  /// Подпись поля или название раздела.
  final String title;

  /// Куда вести: путь под `/settings/`.
  final String route;

  /// Раздел (и группа внутри него) — для подписи результата; null — сам раздел.
  final String? section;
  final String? help;
}

/// Нижний регистр и «ё» → «е»: ищут как пишут.
String _norm(String s) => s.toLowerCase().replaceAll('ё', 'е');

/// Записи, где встречаются все слова [query]: сначала совпадения в начале
/// названия, потом в названии, потом в разделе/подсказке. Разделы выше полей.
List<SettingsEntry> searchSettings(List<SettingsEntry> all, String query) {
  final words = _norm(query).split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return const [];
  final scored = <(int, int, SettingsEntry)>[];
  for (var i = 0; i < all.length; i++) {
    final e = all[i];
    final title = _norm(e.title);
    final rest = _norm('${e.section ?? ''} ${e.help ?? ''}');
    var score = 0;
    var ok = true;
    for (final w in words) {
      if (title.startsWith(w) || title.contains(' $w')) {
        score += 0;
      } else if (title.contains(w)) {
        score += 1;
      } else if (rest.contains(w)) {
        score += 3;
      } else {
        ok = false;
        break;
      }
    }
    if (!ok) continue;
    if (e.section != null) score += 1;
    scored.add((score, i, e));
  }
  scored.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
  // Одно поле может встретиться дважды (одна подпись в двух местах) — без дублей.
  final seen = <String>{};
  return [
    for (final s in scored)
      if (seen.add('${s.$3.route}|${s.$3.title}')) s.$3,
  ];
}
