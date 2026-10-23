import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/proto/mesh.dart';
import '../database.dart';
import 'message_alerts.dart';

/// Готовое уведомление: [chat] — id чата для перехода по нажатию.
typedef MessageAlert = ({
  int id,
  AlertKind kind,
  String title,
  String body,
  String chat,
});

/// Следит за новыми строками в `messages` (новая строка — новое сообщение;
/// эфир и зеркало склеиваются в одну, поэтому одно сообщение — одно
/// уведомление) и решает, о чём уведомить.
class AlertWatcher {
  AlertWatcher(
    this.db, {
    required this.me,
    required this.settings,
    required this.isChatVisible,
    required this.onAlert,
    this.isFiltered,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase db;

  /// Номер своей ноды; null — не подключались, уведомлять не о чем.
  final int? Function() me;
  final AlertSettings Function() settings;

  /// Чат открыт и приложение на экране — уведомление не нужно.
  final bool Function(String chat) isChatVisible;
  final void Function(MessageAlert a) onAlert;

  /// Сообщение скрыто фильтром сообщений в этом чате — не уведомляем.
  final bool Function(String chat, String text)? isFiltered;
  final DateTime Function() _now;

  StreamSubscription? _sub;
  int _cursor = 0;

  /// Начать с текущего конца таблицы: уже сохранённое не уведомляем.
  Future<void> start() async {
    final max = db.messages.id.max();
    final row = await (db.selectOnly(
      db.messages,
    )..addColumns([max])).getSingle();
    _cursor = row.read(max) ?? 0;
    _sub = db
        .customSelect(
          'SELECT MAX(id) AS m FROM messages',
          readsFrom: {db.messages},
        )
        .watchSingle()
        .listen((_) => _drain());
  }

  bool _draining = false;

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      while (true) {
        final rows =
            await (db.select(db.messages)
                  ..where((m) => m.id.isBiggerThanValue(_cursor))
                  ..orderBy([(m) => OrderingTerm.asc(m.id)])
                  ..limit(50))
                .get();
        if (rows.isEmpty) break;
        for (final m in rows) {
          _cursor = m.id;
          final a = await check(m);
          if (a != null) onAlert(a);
        }
      }
    } finally {
      _draining = false;
    }
  }

  /// Решение по одному сообщению (открыто для тестов).
  Future<MessageAlert?> check(Message m) async {
    final me = this.me();
    if (me == null) return null;
    if (_now().difference(m.rxTime) > MessageAlerts.maxAge) return null;

    final nodes = await (db.select(
      db.nodes,
    )..where((n) => n.num.isIn([me, m.fromNum]))).get();
    Node? node(int n) => nodes.where((x) => x.num == n).firstOrNull;
    final sender = node(m.fromNum);

    final target = m.replyId == null
        ? null
        : await (db.select(db.messages)
                ..where((x) => x.packetId.equals(m.replyId!))
                ..limit(1))
              .getSingleOrNull();
    final mine = target != null && (target.isOutgoing || target.fromNum == me);

    final direct = m.toNum == me;
    final channel = direct ? null : await _channel(m);
    final muted =
        channel?.settings != null &&
        ChannelSettings.fromBuffer(channel!.settings!).moduleSettings.isMuted;

    final kind = MessageAlerts.classify(
      m,
      AlertContext(
        me: me,
        myShortName: node(me)?.shortName ?? '',
        targetIsMine: mine,
        senderIgnored: sender?.isIgnored ?? false,
        channelMuted: muted,
      ),
    );
    if (kind == null || !settings().allows(kind)) return null;

    final chat = direct ? 'dm:${m.fromNum}' : m.channelKey;
    if (isChatVisible(chat)) return null;
    if (isFiltered?.call(chat, m.body) ?? false) return null;

    final name = sender == null
        ? nodeIdString(m.fromNum)
        : sender.longName.isNotEmpty
        ? sender.longName
        : sender.shortName.isNotEmpty
        ? sender.shortName
        : nodeIdString(m.fromNum);
    final c = MessageAlerts.content(
      kind,
      m,
      sender: name,
      channel: direct
          ? ''
          : (channel?.name.isNotEmpty == true ? channel!.name : m.channelKey),
      target: target?.body ?? '',
    );
    return (id: m.id, kind: kind, title: c.title, body: c.body, chat: chat);
  }

  /// Канал своей ноды: по индексу (эфир) или по имени (зеркало).
  Future<MeshChannel?> _channel(Message m) async {
    final all = await db.select(db.channels).get();
    if (m.channel != null) {
      final byIndex = all.where((c) => c.index == m.channel).firstOrNull;
      if (byIndex != null) return byIndex;
    }
    return all
        .where((c) => c.name.isNotEmpty && c.name.toLowerCase() == m.channelKey)
        .firstOrNull;
  }

  void dispose() => _sub?.cancel();
}
