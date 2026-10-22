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

  /// Шлюзы, уже учтённые в relay_count, по id сообщения в зеркале: событие
  /// о ретрансляторе приходит и для шлюзов из списка `relays`, и повторно.
  final _relays = <int, Set<String>>{};

  /// [live] — пришло по WS только что: время — «сейчас», а не время сервера.
  Future<void> messages(List<MirrorMessage> batch, {bool live = false}) async {
    final hidden = await db.hiddenChannels();
    for (final m in batch) {
      final text = m.text, ch = m.channel;
      final from = nodeNumFromId(m.fromId);
      if (text == null || text.isEmpty || ch == null || from == null) continue;
      // Скрытый пользователем канал зеркала — не подтягиваем снова.
      if (hidden.contains(channelKey(ch))) continue;
      // Время приёма сервером, а не sentAt: часы отправителя могут спешить.
      final time = live
          ? DateTime.now()
          : (m.receivedAt ?? m.sentAt ?? DateTime.now());
      final to = m.toId == null
          ? broadcastNum
          : (nodeNumFromId(m.toId!) ?? broadcastNum);

      final relays = (_relays[m.id] ??= {})
        ..addAll([for (final r in m.relays) ?r.nodeId]);
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
              emoji: Value(m.emoji ?? 0),
              rxSnr: Value(m.snr),
              rxRssi: Value(m.rssi),
              heardOnMirror: const Value(true),
              mirrorId: Value(m.id),
              relayCount: Value(relays.length),
              isBot: Value(m.isBot),
            ),
            onConflict: DoUpdate.withExcluded(
              (old, ex) => MessagesCompanion.custom(
                heardOnMirror: const Constant(true),
                mirrorId: ex.mirrorId,
                isBot: ex.isBot,
                // Список из зеркала — полный: он и есть ответ. По WS
                // новое сообщение приходит без шлюзов — не обнуляем.
                relayCount: live
                    ? _max(old.relayCount, ex.relayCount)
                    : ex.relayCount,
                // Флаг реакции из эфира не затираем нулём из старого зеркала.
                emoji: _max(old.emoji, ex.emoji),
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

  Future<void> relay(int mirrorId, MirrorRelay r) async {
    final id = r.nodeId;
    if (id != null && !(_relays[mirrorId] ??= {}).add(id)) return;
    await db.customUpdate(
      'UPDATE messages SET relay_count = relay_count + 1 WHERE mirror_id = ?',
      variables: [Variable.withInt(mirrorId)],
      updates: {db.messages},
    );
  }

  Future<void> nodes(List<MirrorNode> batch) async {
    for (final n in batch) {
      final num = nodeNumFromId(n.nodeId);
      if (num == null) continue;
      final old = await (db.select(
        db.nodes,
      )..where((r) => r.num.equals(num))).getSingleOrNull();
      final hasPos = n.lastLat != null && n.lastLon != null;
      final seen = n.lastSeenAt;
      // Данные радио приоритетнее: у ноды, услышанной через свою ноду, зеркало
      // только заполняет пустое. Ключ — только если своего нет, «последний раз» —
      // самый свежий из обоих источников.
      final radio = old?.onRadio == true;
      Value<T> fill<T>(T? mirror, Object? current) =>
          mirror != null && (!radio || current == null || current == '')
          ? Value(mirror)
          : const Value.absent();
      await db
          .into(db.nodes)
          .insertOnConflictUpdate(
            NodesCompanion(
              num: Value(num),
              userId: fill(n.nodeId, old?.userId),
              longName: fill(n.longName, old?.longName),
              shortName: fill(n.shortName, old?.shortName),
              hwModel: fill(n.hwModel, old?.hwModel == 0 ? null : old?.hwModel),
              latitude: hasPos
                  ? fill(n.lastLat, old?.latitude)
                  : const Value.absent(),
              longitude: hasPos
                  ? fill(n.lastLon, old?.longitude)
                  : const Value.absent(),
              batteryLevel: fill(n.batteryLevel, old?.batteryLevel),
              snr: fill(n.lastSnr, old?.snr),
              modemPreset: fill(n.modemPreset, old?.modemPreset),
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
          // Есть строка без имён (пакет по радио без NodeInfo) — заполняем
          // пустое; непустые имена не трогаем.
          onConflict: DoUpdate.withExcluded(
            (old, ex) => NodesCompanion.custom(
              onMirror: const Constant(true),
              longName: _orFill(old.longName, ex.longName),
              shortName: _orFill(old.shortName, ex.shortName),
            ),
          ),
        );
  }

  static Expression<String> _orFill(
    Expression<String> old,
    Expression<String> ex,
  ) => CaseWhenExpression(
    cases: [CaseWhen(old.equals(''), then: ex)],
    orElse: old,
  );

  static Expression<int> _max(Expression<int> a, Expression<int> b) =>
      CaseWhenExpression(
        cases: [CaseWhen(a.isBiggerThan(b), then: a)],
        orElse: b,
      );
}
