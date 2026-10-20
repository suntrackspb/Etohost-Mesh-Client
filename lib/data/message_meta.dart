import 'database.dart';

/// Сколько хопов прошло сообщение по радио; null — неизвестно или не из эфира.
int? messageHops(Message m) {
  final start = m.hopStart, limit = m.hopLimit;
  if (!m.heardOnRadio || m.isOutgoing || start == null || limit == null) {
    return null;
  }
  final hops = start - limit;
  return hops < 0 ? null : hops;
}

/// Сигнал прямого приёма (0 хопов): «S 5.5 · R -80»; иначе null.
String? directSignal(Message m) {
  if (messageHops(m) != 0) return null;
  final parts = [
    if (m.rxSnr case final snr? when snr != 0) 'S ${snr.toStringAsFixed(1)}',
    if (m.rxRssi case final rssi? when rssi != 0) 'R $rssi',
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// Есть что показать в чипе шлюзов (только при включённом зеркале).
bool showRelays(Message m, {required bool mirror}) =>
    mirror && m.relayCount > 0 && m.mirrorId != null;

// Анализатор не знает свойство Extended_Pictographic, а движок Dart знает
// (проверено тестом).
final _emojiOnly = RegExp(
  // ignore: valid_regexps
  r'^(?:\p{Extended_Pictographic}|\p{Emoji_Modifier}|\p{Regional_Indicator}'
  r'|[0-9#*]\u{FE0F}?\u{20E3}|[\u{200D}\u{FE0F}])+$',
  unicode: true,
);

/// Текст — только эмодзи (1–3 штуки). Зеркало не передаёт флаг `emoji`
/// пакета, поэтому реакцию из зеркала узнаём по такому тексту ответа.
bool isEmojiOnly(String s) {
  final t = s.trim();
  return t.isNotEmpty && t.runes.length <= 12 && _emojiOnly.hasMatch(t);
}
