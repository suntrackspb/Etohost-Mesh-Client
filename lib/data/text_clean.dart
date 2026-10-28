/// Убрать из исходящего текста невидимые символы: пробелы нулевой ширины,
/// мягкий перенос, управление направлением, «пустые» буквы-заполнители.
/// Они тратят байты пакета и позволяют раздуть короткое сообщение, чтобы
/// сработал сильный уровень GlyphZip. Соединитель (ZWJ), селектор
/// эмодзи (FE0F) и теги флагов внутри эмодзи сохраняем — без них
/// эмодзи разваливаются.
String stripInvisible(String text) {
  final runes = text.runes.toList();
  final out = <int>[];
  for (var i = 0; i < runes.length; i++) {
    final r = runes[i];
    final prev = out.isEmpty ? null : out.last;
    final next = i + 1 < runes.length ? runes[i + 1] : null;
    if (_alwaysInvisible(r)) continue;
    if (r == 0x200D) {
      // ZWJ — только между частями эмодзи: 👨‍👩‍👧, 🏳️‍🌈.
      if (prev != null &&
          _emojiPart(prev) &&
          next != null &&
          _pictographic(next)) {
        out.add(r);
      }
      continue;
    }
    if (r == 0xFE0F || r == 0xFE0E) {
      // Селектор вида — только после символа, у которого есть вид эмодзи.
      if (prev != null && (_pictographic(prev) || _keycapBase(prev))) {
        out.add(r);
      }
      continue;
    }
    if (r >= 0xE0020 && r <= 0xE007F) {
      // Теги — только в флагах регионов: 🏴 + теги.
      if (prev != null &&
          (prev == 0x1F3F4 || (prev >= 0xE0020 && prev <= 0xE007F))) {
        out.add(r);
      }
      continue;
    }
    out.add(r);
  }
  return String.fromCharCodes(out);
}

bool _alwaysInvisible(int r) =>
    r == 0x00AD || // мягкий перенос
    r == 0x034F || // CGJ
    r == 0x061C || // знак арабской буквы (направление)
    r == 0x115F ||
    r == 0x1160 ||
    r == 0x3164 ||
    r == 0xFFA0 || // хангыль-заполнители
    r == 0x180E || // монгольский разделитель гласных
    r == 0x200B ||
    r == 0x200C || // пробел и разделитель нулевой ширины
    r == 0x200E ||
    r == 0x200F || // метки направления
    (r >= 0x202A && r <= 0x202E) || // встраивание и переопределение направления
    (r >= 0x2060 && r <= 0x2064) || // WJ и невидимые операторы
    (r >= 0x2066 && r <= 0x206F) || // изоляция направления и устаревшие
    r == 0xFEFF || // BOM
    (r >= 0xFE00 && r <= 0xFE0D) || // селекторы вариантов, не эмодзи
    (r >= 0xE0100 && r <= 0xE01EF) || // дополнительные селекторы
    r == 0xE0001; // устаревший тег языка

/// Часть эмодзи, после которой может стоять ZWJ.
bool _emojiPart(int r) =>
    _pictographic(r) ||
    r == 0xFE0F ||
    (r >= 0x1F3FB && r <= 0x1F3FF); // оттенки кожи

/// Грубо, но достаточно: блоки, где живут эмодзи.
bool _pictographic(int r) =>
    r == 0x00A9 ||
    r == 0x00AE ||
    r == 0x203C ||
    r == 0x2049 ||
    (r >= 0x2100 && r <= 0x2BFF) ||
    (r >= 0x3030 && r <= 0x303D) ||
    r == 0x3297 ||
    r == 0x3299 ||
    (r >= 0x1F000 && r <= 0x1FAFF);

/// Цифры и #* перед ⃣: 1️⃣.
bool _keycapBase(int r) => (r >= 0x30 && r <= 0x39) || r == 0x23 || r == 0x2A;
