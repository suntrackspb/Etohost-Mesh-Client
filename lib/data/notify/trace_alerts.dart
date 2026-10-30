import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/proto/mesh.dart';
import '../database.dart';
import '../node_actions.dart';
import '../traceroute_view.dart';

/// Уведомление о пришедшей трассировке; [id] — строка журнала.
typedef TraceAlert = ({int id, String title, String body});

/// Payload уведомления о трассировке (у сообщений — id чата).
String tracePayload(int id) => 'trace:$id';

/// id трассировки из payload; null — это не трассировка.
int? traceIdFromPayload(String p) =>
    p.startsWith('trace:') ? int.tryParse(p.substring(6)) : null;

/// Следит за журналом трассировок: запись получила ответ — уведомляем.
/// Без ответа не уведомляем: нет уведомления — значит, не дошла.
class TraceAlertWatcher {
  TraceAlertWatcher(
    this.db, {
    required this.me,
    required this.enabled,
    required this.onAlert,
    this.formatTitle,
    this.formatBody,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final String Function(String)? formatTitle;
  final String Function(String)? formatBody;
  final int? Function() me;
  final bool Function() enabled;
  final void Function(TraceAlert a) onAlert;
  final DateTime Function() _now;

  /// Старше — история, не уведомляем.
  static const maxAge = Duration(minutes: 10);

  StreamSubscription? _sub;
  final _known = <int>{};

  Stream<List<TracerouteRecord>> _recent() =>
      (db.select(db.traceroutes)
            ..orderBy([(t) => OrderingTerm.desc(t.id)])
            ..limit(50))
          .watch();

  /// Уже отвеченные на старте не уведомляем.
  Future<void> start() async {
    final first = await _recent().first;
    _known.addAll([
      for (final r in first)
        if (r.answered) r.id,
    ]);
    _sub = _recent().listen((rows) async {
      for (final r in rows) {
        if (!r.answered || !_known.add(r.id)) continue;
        final a = await check(r);
        if (a != null) onAlert(a);
      }
    });
  }

  /// Решение по одной отвеченной записи (открыто для тестов).
  Future<TraceAlert?> check(TracerouteRecord r) async {
    final me = this.me();
    if (me == null || !enabled()) return null;
    if (_now().difference(r.time) > maxAge) return null;
    final n = await (db.select(
      db.nodes,
    )..where((x) => x.num.equals(r.targetNum))).getSingleOrNull();
    final name = n == null
        ? nodeIdString(r.targetNum)
        : n.longName.isNotEmpty
        ? n.longName
        : n.shortName.isNotEmpty
        ? n.shortName
        : nodeIdString(r.targetNum);
    final t = TracerouteResult.parse(r, me);
    return (
      id: r.id,
      title: formatTitle?.call(name) ?? 'Трассировка маршрута: $name',
      body:
          formatBody?.call(traceSummary(t, _now())) ?? traceSummary(t, _now()),
    );
  }

  void dispose() => _sub?.cancel();
}
