import 'dart:convert';

import '../core/proto/mesh.dart';
import 'settings/user_section.dart' show firmwareAtLeast;

/// Ошибка Etohost Mesh 0.1.10 и раньше: «Отправить NodeInfo» рассылала свою
/// NodeInfo с нулевым MAC. Прошивка 2.7 записывает её в свою же запись, а
/// после перезагрузки считает номер из MAC занятым «чужим» MAC и берёт
/// случайный (NodeDB::pickNewNodeNum).
sealed class IdBug {
  const IdBug();
}

/// Нода ещё не перезагружалась: ID прежний, в её записи нулевой MAC.
/// [mac] — настоящий MAC из нашей базы, если он известен (мягкая починка).
class IdBugPending extends IdBug {
  const IdBugPending(this.num, this.mac);
  final int num;
  final List<int>? mac;
}

/// ID уже сменился: [original] — номер из MAC, [current] — случайный.
class IdBugChanged extends IdBug {
  const IdBugChanged(this.original, this.current);
  final int original;
  final int current;
}

/// Номер ноды из MAC (младшие 4 байта), как в прошивке 2.7; null — MAC нет.
int? macNodeNum(List<int> mac) => mac.length == 6 && mac.any((b) => b != 0)
    ? (mac[2] << 24) | (mac[3] << 16) | (mac[4] << 8) | mac[5]
    : null;

/// Проверка своей ноды после подключения. [radio] — своя NodeInfo из
/// выгрузки, [savedMac] — MAC своей ноды из нашей базы. null — бага нет
/// или проверить нельзя.
IdBug? detectIdBug({
  required int me,
  required User? radio,
  required String? firmware,
  List<int>? savedMac,
}) {
  if (radio == null || firmware == null || firmware.isEmpty) return null;
  // 2.8 считает номер из ключа: смена ID там штатная, MAC не участвует.
  if (firmwareAtLeast(firmware, 2, 8)) return null;
  if (radio.publicKey.length == 32 && crc32(radio.publicKey) == me) {
    return null;
  }
  final fromMac = macNodeNum(radio.macaddr);
  if (fromMac == null) {
    final ok = savedMac != null && macNodeNum(savedMac) == me;
    return IdBugPending(me, ok ? savedMac : null);
  }
  return fromMac == me ? null : IdBugChanged(fromMac, me);
}

/// CRC-32 (IEEE, как crc32Buffer в прошивке и zlib).
int crc32(List<int> data) {
  var c = 0xffffffff;
  for (final b in data) {
    c ^= b;
    for (var i = 0; i < 8; i++) {
      c = (c & 1) != 0 ? (c >> 1) ^ 0xedb88320 : c >> 1;
    }
  }
  return c ^ 0xffffffff;
}

/// Имя ноды, которое вернуть после сброса device.proto (там хранится owner).
typedef PendingOwner = ({
  int num,
  String longName,
  String shortName,
  bool isUnmessagable,
});

String encodePendingOwner(PendingOwner o) => jsonEncode({
  'num': o.num,
  'long': o.longName,
  'short': o.shortName,
  'unmsg': o.isUnmessagable,
});

PendingOwner? parsePendingOwner(String? s) {
  if (s == null || s.isEmpty) return null;
  try {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return (
      num: m['num'] as int,
      longName: m['long'] as String,
      shortName: m['short'] as String,
      isUnmessagable: m['unmsg'] as bool? ?? false,
    );
  } catch (_) {
    return null;
  }
}

/// Нужно ли вернуть имя: та же нода, а имя сброшено (отличается от сохранённого).
bool needsOwnerRestore(PendingOwner p, int me, User? radio) =>
    radio != null &&
    p.num == me &&
    (radio.longName != p.longName || radio.shortName != p.shortName);
