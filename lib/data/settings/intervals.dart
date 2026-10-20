import 'fields.dart';

/// Интервалы из IntervalEnums.swift (iOS), в секундах.
abstract final class Intervals {
  static const never = 2147483647;

  /// broadcastLong: NodeInfo и подобное (минимум прошивки — 3 часа).
  static const broadcastLong = [
    10800,
    14400,
    18000,
    21600,
    43200,
    64800,
    86400,
    129600,
    172800,
    259200,
    never,
  ];

  /// broadcastMedium: позиция.
  static const broadcastMedium = [
    3600,
    7200,
    10800,
    14400,
    18000,
    21600,
    43200,
    64800,
    86400,
    129600,
    172800,
    259200,
    never,
  ];

  /// smartBroadcastMinimum: минимальный интервал умной позиции.
  static const smartMinimum = [15, 30, 45, 60, 300, 600, 900, 1800, 3600];

  /// GpsUpdateIntervals.
  static const gpsUpdate = [
    30,
    60,
    120,
    300,
    600,
    900,
    1800,
    3600,
    21600,
    43200,
    86400,
    never,
  ];

  /// waitBluetooth (iOS): 0 — по умолчанию прошивки (минута).
  static const waitBluetooth = [0, 15, 30, 60, 120, 300, 600, 900];

  /// rangeTestSender (iOS): 0 — не отправлять.
  static const rangeTestSender = [0, 15, 30, 45, 60, 300, 600, 900, 1800, 3600];

  /// NAG_TIMEOUT (Android): минимальное время бодрствования.
  static const nagTimeout = [0, 1, 5, 10, 15, 30, 60];

  /// ALL (Android) по возрастанию.
  static const all = [
    0,
    1,
    2,
    3,
    4,
    5,
    8,
    10,
    15,
    20,
    30,
    40,
    45,
    60,
    80,
    90,
    120,
    300,
    600,
    900,
    1800,
    3600,
    7200,
    10800,
    14400,
    18000,
    21600,
    43200,
    64800,
    86400,
    129600,
    172800,
    259200,
    never,
  ];

  static List<Choice> choices(List<int> secs) => [
    for (final s in secs) (value: s, label: label(s)),
  ];

  static String label(int s) {
    if (s == never) return 'Никогда';
    if (s == 0) return 'Не задан';
    if (s % 3600 == 0) {
      return '${s ~/ 3600} ${_plural(s ~/ 3600, 'час', 'часа', 'часов')}';
    }
    if (s % 60 == 0) {
      return '${s ~/ 60} ${_plural(s ~/ 60, 'минута', 'минуты', 'минут')}';
    }
    return '$s ${_plural(s, 'секунда', 'секунды', 'секунд')}';
  }

  static String _plural(int n, String one, String few, String many) {
    final m10 = n % 10, m100 = n % 100;
    if (m10 == 1 && m100 != 11) return one;
    if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return few;
    return many;
  }
}
