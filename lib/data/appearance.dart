import 'dart:ui' show Color;

/// Тема приложения. [black] — тёмная с чистым чёрным фоном (OLED).
enum AppTheme {
  system('Система'),
  light('Светлая'),
  dark('Тёмная'),
  black('Чёрная');

  const AppTheme(this.title);
  final String title;

  /// Неизвестное значение — как в системе.
  static AppTheme parse(String? v) =>
      values.where((t) => t.name == v).firstOrNull ?? system;
}

/// Цвет акцента: из него строится вся палитра темы. Цвета статусов
/// (ok/warn/bad) от него не зависят.
class Accent {
  const Accent(this.id, this.title, this.color);
  final String id;
  final String title;
  final Color color;
}

const accents = [
  Accent('teal', 'Бирюзовый', Color(0xFF2E9E8F)),
  Accent('green', 'Зелёный', Color(0xFF22C55E)), // как на etohost.ru
  Accent('blue', 'Синий', Color(0xFF3B82F6)),
  Accent('indigo', 'Индиго', Color(0xFF5C6BC0)),
  Accent('purple', 'Фиолетовый', Color(0xFF8E5CC4)),
  Accent('pink', 'Розовый', Color(0xFFD2508A)),
  Accent('orange', 'Оранжевый', Color(0xFFE67E22)),
];

/// Неизвестный id — первый (бирюзовый).
Accent parseAccent(String? id) =>
    accents.where((a) => a.id == id).firstOrNull ?? accents.first;
