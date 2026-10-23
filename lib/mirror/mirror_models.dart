import 'dart:convert';
import 'dart:typed_data';

/// Модели API зеркала (`/api/nodes`, `/api/chat/history`, WS `/ws`).
/// Перенос 1:1 из iOS-клиента. JSON в snake_case; почти все поля опциональны.

class MirrorRelay {
  const MirrorRelay({this.nodeId, this.snr, this.rssi, this.hops});

  factory MirrorRelay.fromJson(Map<String, dynamic> j) => MirrorRelay(
    nodeId: j['node_id'] as String?,
    snr: _double(j['snr']),
    rssi: _int(j['rssi']),
    hops: _int(j['hops']),
  );

  final String? nodeId;
  final double? snr;
  final int? rssi;
  final int? hops;
}

class MirrorMessage {
  const MirrorMessage({
    required this.id,
    required this.fromId,
    this.packetId,
    this.toId,
    this.text,
    this.replyToPacketId,
    this.emoji,
    this.snr,
    this.rssi,
    this.channel,
    this.receivedAt,
    this.sentAt,
    this.shortName,
    this.longName,
    this.isBot = false,
    this.relays = const [],
  });

  /// null — запись не сообщение (в ленте бывают `name_change` со строковым id).
  static MirrorMessage? tryParse(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final id = raw['id'], from = raw['from_id'];
    if (id is! int || from is! String) return null;
    return MirrorMessage(
      id: id,
      fromId: from,
      packetId: _int(raw['packet_id']),
      toId: raw['to_id'] as String?,
      text: raw['text'] as String?,
      replyToPacketId: _int(raw['reply_to_packet_id']),
      emoji: _int(raw['emoji']),
      snr: _double(raw['snr']),
      rssi: _int(raw['rssi']),
      channel: raw['channel'] as String?,
      receivedAt: parseMirrorDate(raw['received_at'] as String?),
      sentAt: parseMirrorDate(raw['sent_at'] as String?),
      shortName: raw['short_name'] as String?,
      longName: raw['long_name'] as String?,
      isBot: raw['is_bot'] == true,
      relays: [
        for (final r in _list(raw['relays']))
          if (r is Map<String, dynamic>) MirrorRelay.fromJson(r),
      ],
    );
  }

  final int id;
  final int? packetId;
  final String fromId;
  final String? toId;
  final String? text;
  final int? replyToPacketId;

  /// Data.emoji: не 0 — реакция на [replyToPacketId]. Старое зеркало
  /// поле не отдаёт — null.
  final int? emoji;
  final double? snr;
  final int? rssi;
  final String? channel;
  final DateTime? receivedAt;
  final DateTime? sentAt;
  final String? shortName;
  final String? longName;
  final bool isBot;
  final List<MirrorRelay> relays;
}

class MirrorNode {
  const MirrorNode({
    required this.nodeId,
    this.longName,
    this.shortName,
    this.hwModel,
    this.lastLat,
    this.lastLon,
    this.lastSeenAt,
    this.batteryLevel,
    this.lastSnr,
    this.modemPreset,
    this.publicKey,
    this.firmwareVersion,
  });

  static MirrorNode? tryParse(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final id = raw['node_id'];
    if (id is! String) return null;
    return MirrorNode(
      nodeId: id,
      longName: raw['long_name'] as String?,
      shortName: raw['short_name'] as String?,
      hwModel: _int(raw['hw_model']),
      lastLat: _double(raw['last_lat']),
      lastLon: _double(raw['last_lon']),
      lastSeenAt: parseMirrorDate(raw['last_seen_at'] as String?),
      batteryLevel: _int(raw['battery_level']),
      lastSnr: _double(raw['last_snr']),
      modemPreset: raw['modem_preset'] is String
          ? raw['modem_preset'] as String
          : null,
      publicKey: raw['public_key'] as String?,
      firmwareVersion: raw['firmware_version'] is String
          ? raw['firmware_version'] as String
          : null,
    );
  }

  final String nodeId;
  final String? longName;
  final String? shortName;
  final int? hwModel;
  final double? lastLat;
  final double? lastLon;
  final DateTime? lastSeenAt;
  final int? batteryLevel;
  final double? lastSnr;
  final String? modemPreset;

  /// Из MapReport; в списке /api/nodes сервер пока не отдаёт, только в карточке.
  final String? firmwareVersion;

  /// Пока сервер не отдаёт — null; hex (64 символа) или base64 (32 байта).
  final String? publicKey;

  Uint8List? get publicKeyBytes {
    final k = publicKey;
    if (k == null || k.isEmpty) return null;
    if (k.length == 64 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(k)) {
      return Uint8List.fromList([
        for (var i = 0; i < 64; i += 2)
          int.parse(k.substring(i, i + 2), radix: 16),
      ]);
    }
    try {
      final b = Uri.parse('data:;base64,$k').data?.contentAsBytes();
      if (b != null && b.length == 32) return b;
    } catch (_) {}
    return null;
  }
}

/// Кадры WebSocket `/ws`.
sealed class MirrorEvent {
  const MirrorEvent();

  static MirrorEvent parse(Map<String, dynamic> j) => switch (j['type']) {
    'init' => MirrorInit(_messages(j['messages'])),
    'new_message' => switch (MirrorMessage.tryParse(j['message'])) {
      final m? => MirrorNewMessage(m),
      null => const MirrorOther(),
    },
    'relay_update'
        when j['message_id'] is int && j['relay'] is Map<String, dynamic> =>
      MirrorRelayUpdate(
        j['message_id'] as int,
        MirrorRelay.fromJson(j['relay'] as Map<String, dynamic>),
      ),
    'node_update' => switch (MirrorNode.tryParse(j['node'])) {
      final n? => MirrorNodeUpdate(n),
      null => const MirrorOther(),
    },
    _ => const MirrorOther(),
  };
}

class MirrorInit extends MirrorEvent {
  MirrorInit(this.messages);
  final List<MirrorMessage> messages;
}

class MirrorNewMessage extends MirrorEvent {
  MirrorNewMessage(this.message);
  final MirrorMessage message;
}

class MirrorRelayUpdate extends MirrorEvent {
  MirrorRelayUpdate(this.messageId, this.relay);
  final int messageId;
  final MirrorRelay relay;
}

class MirrorNodeUpdate extends MirrorEvent {
  MirrorNodeUpdate(this.node);
  final MirrorNode node;
}

class MirrorOther extends MirrorEvent {
  const MirrorOther();
}

/// Нераспознанные элементы пропускаем, а не валим весь разбор.
List<MirrorMessage> _messages(Object? raw) => [
  for (final m in (raw is List ? raw : const [])) ?MirrorMessage.tryParse(m),
];

List<MirrorMessage> parseMirrorMessages(Object? raw) => _messages(raw);

/// Бэкенд отдаёт и `2026-10-09 19:20:32.127335+00:00`, и `2026-10-09T19:02:01.107651Z`.
/// DateTime.parse понимает оба (пробел и микросекунды), но не без зоны — такие считаем UTC.
DateTime? parseMirrorDate(String? s) {
  if (s == null || s.isEmpty) return null;
  var v = s.trim();
  final hasZone = RegExp(r'(Z|[+-]\d\d:?\d\d)$').hasMatch(v);
  if (!hasZone) v = '${v}Z';
  return DateTime.tryParse(v)?.toLocal();
}

/// `!a1b2c3d4` → номер ноды.
int? nodeNumFromId(String id) {
  final s = id.startsWith('!') ? id.substring(1) : id;
  return s.length == 8 ? int.tryParse(s, radix: 16) : null;
}

int? _int(Object? v) => v is int ? v : (v is num ? v.toInt() : null);
double? _double(Object? v) => v is num ? v.toDouble() : null;

/// Список из JSON; realtime зеркала бывает присылает его строкой с JSON.
List<Object?> _list(Object? v) {
  if (v is List) return v;
  if (v is String && v.isNotEmpty) {
    try {
      final d = jsonDecode(v);
      if (d is List) return d;
    } catch (_) {}
  }
  return const [];
}
