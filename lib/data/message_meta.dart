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

/// Подпись под сообщением из эфира: «2 хопа» или «напрямую · SNR 5.5 · RSSI -80».
String? radioLabel(Message m) {
  final hops = messageHops(m);
  if (hops == null) return null;
  if (hops > 0) return '$hops ${_hopWord(hops)}';
  return [
    'напрямую',
    if (m.rxSnr case final snr? when snr != 0) 'SNR ${snr.toStringAsFixed(1)}',
    if (m.rxRssi case final rssi? when rssi != 0) 'RSSI $rssi',
  ].join(' · ');
}

String _hopWord(int n) {
  final d = n % 10, dd = n % 100;
  if (d == 1 && dd != 11) return 'хоп';
  if (d >= 2 && d <= 4 && (dd < 12 || dd > 14)) return 'хопа';
  return 'хопов';
}

/// Есть что показать в чипе шлюзов (только при включённом зеркале).
bool showRelays(Message m, {required bool mirror}) =>
    mirror && m.relayCount > 0 && m.mirrorId != null;
