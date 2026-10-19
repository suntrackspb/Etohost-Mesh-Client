import 'package:drift/drift.dart';

import '../core/proto/channel_names.dart';
import '../core/proto/mesh.dart';
import '../mirror/mirror_models.dart';
import 'database.dart';

/// Складывает данные зеркала в ту же БД, что и эфир.
/// Склейка сообщений — по (packetId, fromNum), как в iOS-клиенте; данные эфира
/// (SNR, хопы, время приёма своей нодой) зеркало не перезаписывает.
class MirrorIngest {
  MirrorIngest(this.db);

  final AppDatabase db;

  /// [live] — пришло по WS только что: время — «сейчас», а не время сервера.
  Future<void> messages(List<MirrorMessage> batch, {bool live = false}) async {
    for (final m in batch) {
      final text = m.text, ch = m.channel;
      final from = nodeNumFromId(m.fromId);
      if (text == null || text.isEmpty || ch == null || from == null) continue;
      // Время приёма сервером, а не sentAt: часы отправителя могут спешить.
      final time = live
          ? DateTime.now()
          : (m.receivedAt ?? m.sentAt ?? DateTime.now());
      final to = m.toId == null
          ? broadcastNum
          : (nodeNumFromId(m.toId!) ?? broadcastNum);

      await db
          .into(db.messages)
          .insert(
            MessagesCompanion.insert(
              // Без packet_id склеивать не с чем — уникальный отрицательный ключ.
              packetId: m.packetId ?? -m.id,
              fromNum: from,
              toNum: to,
              channelKey: Value(channelKey(ch)),
              body: text,
              rxTime: time,
              replyId: Value(m.replyToPacketId),
              rxSnr: Value(m.snr),
              rxRssi: Value(m.rssi),
              heardOnMirror: const Value(true),
              mirrorId: Value(m.id),
              relayCount: Value(m.relays.length),
              isBot: Value(m.isBot),
            ),
            onConflict: DoUpdate.withExcluded(
              (old, ex) => MessagesCompanion.custom(
                heardOnMirror: const Constant(true),
                mirrorId: ex.mirrorId,
                isBot: ex.isBot,
                relayCount: _max(old.relayCount, ex.relayCount),
                // Лента из зеркала без эфира — выравниваем по времени сервера;
                // своё исходящее и услышанное в эфире — время наше.
                rxTime: live
                    ? old.rxTime
                    : CaseWhenExpression(
                        cases: [
                          CaseWhen(
                            old.heardOnRadio | old.isOutgoing,
                            then: old.rxTime,
                          ),
                        ],
                        orElse: ex.rxTime,
                      ),
              ),
              target: [db.messages.packetId, db.messages.fromNum],
            ),
          );
      await _nodeFromMessage(from, m);
    }
  }

  Future<void> relay(int mirrorId, MirrorRelay r) => db.customUpdate(
    'UPDATE messages SET relay_count = relay_count + 1 WHERE mirror_id = ?',
    variables: [Variable.withInt(mirrorId)],
    updates: {db.messages},
  );

  Future<void> nodes(List<MirrorNode> batch) async {
    for (final n in batch) {
      final num = nodeNumFromId(n.nodeId);
      if (num == null) continue;
      final old = await (db.select(
        db.nodes,
      )..where((r) => r.num.equals(num))).getSingleOrNull();
      final hasPos = n.lastLat != null && n.lastLon != null;
      final seen = n.lastSeenAt;
      // Зеркало обновляет только то, что знает; ключ — только если своего нет,
      // «последний раз» — только если свежее известного.
      await db
          .into(db.nodes)
          .insertOnConflictUpdate(
            NodesCompanion(
              num: Value(num),
              userId: Value(n.nodeId),
              longName: n.longName != null
                  ? Value(n.longName!)
                  : const Value.absent(),
              shortName: n.shortName != null
                  ? Value(n.shortName!)
                  : const Value.absent(),
              hwModel: n.hwModel != null
                  ? Value(n.hwModel!)
                  : const Value.absent(),
              latitude: hasPos ? Value(n.lastLat) : const Value.absent(),
              longitude: hasPos ? Value(n.lastLon) : const Value.absent(),
              batteryLevel: n.batteryLevel != null
                  ? Value(n.batteryLevel)
                  : const Value.absent(),
              snr: old?.onRadio != true && n.lastSnr != null
                  ? Value(n.lastSnr)
                  : const Value.absent(),
              publicKey: old?.publicKey == null && n.publicKeyBytes != null
                  ? Value(n.publicKeyBytes)
                  : const Value.absent(),
              lastHeard:
                  seen != null &&
                      (old?.lastHeard == null || seen.isAfter(old!.lastHeard!))
                  ? Value(seen)
                  : const Value.absent(),
              onMirror: const Value(true),
            ),
          );
    }
  }

  /// Имена отправителя из сообщения — чтобы в ленте не было голых !id.
  Future<void> _nodeFromMessage(int num, MirrorMessage m) async {
    if (m.shortName == null && m.longName == null) return;
    await db
        .into(db.nodes)
        .insert(
          NodesCompanion.insert(
            num: Value(num),
            userId: Value(m.fromId),
            longName: Value(m.longName ?? ''),
            shortName: Value(m.shortName ?? ''),
            onMirror: const Value(true),
          ),
          onConflict: DoUpdate(
            (_) => const NodesCompanion(onMirror: Value(true)),
          ),
        );
  }

  static Expression<int> _max(Expression<int> a, Expression<int> b) =>
      CaseWhenExpression(
        cases: [CaseWhen(a.isBiggerThan(b), then: a)],
        orElse: b,
      );
}
