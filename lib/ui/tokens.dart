import 'package:flutter/material.dart';

/// Дизайн-токены. Новый дизайн начинается здесь, а не в экранах.
abstract final class Tokens {
  static const yellow = Color(0xFFFFDA43);
  static const green = Color(0xFF43CD78);
  static const blue = Color(0xFF3386FF);
  static const seed = yellow;

  // Отступы
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;

  // Скругления
  static const radiusM = 12.0;
  static const radiusL = 16.0;

  /// Ширина, начиная с которой раскладка «боковая панель + две колонки».
  static const wideBreakpoint = 840.0;

  /// Ширина левой колонки (список) в двухколоночной раскладке.
  static const listPaneWidth = 380.0;

  static const mono = TextStyle(fontFamily: 'monospace', fontSize: 12);
}

/// Статусные цвета (не зависят от темы).
abstract final class StatusColors {
  static const ok = Color(0xFF34A853);
  static const warn = Color(0xFFF29900);
  static const bad = Color(0xFFD93025);
  static const idle = Color(0xFF9AA0A6);
}
