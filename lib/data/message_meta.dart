import '../core/proto/mesh.dart';
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

/// Идентификаторы для меню сообщения: (подпись, значение для копирования).
/// Без packet_id у сообщения из зеркала ключ отрицательный — тогда его id
/// в зеркале.
List<(String, String)> messageIds(Message m) => [
  if (m.packetId > 0) ...[
    ('ID пакета', '${m.packetId}'),
    ('ID пакета (hex)', '0x${m.packetId.toRadixString(16).padLeft(8, '0')}'),
  ] else if (m.mirrorId != null)
    ('ID в зеркале', '${m.mirrorId}'),
  ('Отправитель', nodeIdString(m.fromNum)),
];
