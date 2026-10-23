import 'node_row_info.dart';

/// Качество сигнала словом (как в строке ноды: с учётом пресета).
String qualityText(SignalQuality q) => switch (q) {
  SignalQuality.good => 'хороший',
  SignalQuality.fair => 'средний',
  SignalQuality.bad => 'плохой',
  SignalQuality.none => 'на грани',
};

/// «3 д 4 ч», «5 ч 12 мин», «40 мин».
String uptimeText(int seconds) {
  final d = seconds ~/ 86400, h = seconds % 86400 ~/ 3600;
  final m = seconds % 3600 ~/ 60;
  if (d > 0) return '$d д $h ч';
  if (h > 0) return '$h ч $m мин';
  return '$m мин';
}

/// Азимут → «СВ 45°».
String bearingText(double deg) {
  const names = ['С', 'СВ', 'В', 'ЮВ', 'Ю', 'ЮЗ', 'З', 'СЗ'];
  return '${names[((deg + 22.5) % 360) ~/ 45]} ${deg.round()}°';
}
