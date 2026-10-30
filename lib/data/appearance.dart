import 'dart:ui' show Color;

import '../ui/tokens.dart';

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
  Accent('meshex', 'Meshex', Tokens.seed),
  Accent('teal', 'Бирюзовый', Color(0xFF2E9E8F)),
  Accent('green', 'Зелёный', Color(0xFF22C55E)),
  Accent('blue', 'Синий', Color(0xFF3B82F6)),
  Accent('indigo', 'Индиго', Color(0xFF5C6BC0)),
  Accent('purple', 'Фиолетовый', Color(0xFF8E5CC4)),
  Accent('pink', 'Розовый', Color(0xFFD2508A)),
  Accent('orange', 'Оранжевый', Color(0xFFE67E22)),
];

/// Подсветка обращений ко мне: значение настройки «без подсветки».
const mentionOff = 'off';

/// Цвет пузыря с обращением ко мне — из той же палитры, что акцент;
/// null — без подсветки. По умолчанию зелёный, как было раньше.
Accent? parseMentionColor(String? id) => id == mentionOff
    ? null
    : accents.where((a) => a.id == id).firstOrNull ??
          accents.firstWhere((a) => a.id == 'green');

/// По умолчанию — фирменная палитра Meshex.
Accent parseAccent(String? id) =>
    accents.where((a) => a.id == id).firstOrNull ?? accents.first;
