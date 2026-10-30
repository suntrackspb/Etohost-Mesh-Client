import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/radio/radio_session.dart';
import '../data/database.dart';
import '../data/node_dbs.dart';
import '../mirror/mirror_realtime.dart';
import '../ui/kit/kit.dart';
import 'providers.dart';

/// Состояние связи для бейджа в шапке.
enum LinkLevel { connecting, connected, disconnected }

LinkLevel linkLevel(RadioState s) => switch (s) {
  RadioState.ready => LinkLevel.connected,
  RadioState.idle => LinkLevel.disconnected,
  RadioState.connecting ||
  RadioState.configuring ||
  RadioState.loadingNodes ||
  RadioState.waitingReconnect => LinkLevel.connecting,
};

/// Состояние зеркала для значка; null — зеркало выключено, значка нет.
LinkLevel? mirrorLevel(MirrorState? s) => switch (s) {
  null => null,
  MirrorState.connected => LinkLevel.connected,
  MirrorState.waiting || MirrorState.outdated => LinkLevel.disconnected,
  MirrorState.idle || MirrorState.connecting => LinkLevel.connecting,
};

/// Нода для бейджа: подключённая, а без связи — последняя (её база открыта).
final linkNodeProvider = StreamProvider<Node?>((ref) {
  final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
  final int id = me ?? ref.watch(activeNodeDbProvider);
  if (id == noNodeDb) return Stream.value(null);
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.nodes,
  )..where((n) => n.num.equals(id))).watchSingleOrNull();
});

/// Короткое имя своей ноды в шапке любого экрана: жёлтое — подключаемся,
/// зелёное — на связи, красное — нет связи (последняя нода).
/// Нажатие — вкладка «Связь». Перед именем — значок зеркала тех же цветов
/// (при включённом зеркале); нажатие на него — настройки зеркала.
class LinkBadge extends ConsumerWidget {
  const LinkBadge({super.key});

  static const _yellow = Color(0xFFF2B705);
  static const _green = Color(0xFF34C759);
  static const _red = Color(0xFFFF453A);

  static Color _color(LinkLevel l) => switch (l) {
    LinkLevel.connecting => _yellow,
    LinkLevel.connected => _green,
    LinkLevel.disconnected => _red,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = linkLevel(ref.watch(radioProvider.select((r) => r.state)));
    final mirror = mirrorLevel(ref.watch(mirrorRealtimeProvider)?.state);
    final node = ref.watch(linkNodeProvider).value;
    final name = node?.shortName ?? '';
    if (name.isEmpty && mirror == null) return const SizedBox.shrink();
    final status = switch (level) {
      LinkLevel.connecting => context.l10n.connecting_794e89,
      LinkLevel.connected => context.l10n.connected_f006c9,
      LinkLevel.disconnected => context.l10n.disconnected_0cf65d,
    };
    final mirrorStatus = switch (mirror) {
      LinkLevel.connecting => context.l10n.connecting_794e89,
      LinkLevel.connected => context.l10n.connected_abb335,
      _ => context.l10n.noConnection_75a42a,
    };
    const pad = EdgeInsets.symmetric(
      horizontal: Tokens.s4,
      vertical: Tokens.s4,
    );
    return Padding(
      padding: const EdgeInsets.only(right: Tokens.s8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mirror != null)
            Tooltip(
              message: context.l10n.mirror_871d44((mirrorStatus).toString()),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.go('/settings/mirror'),
                child: Padding(
                  padding: pad,
                  child: Icon(Icons.public, size: 18, color: _color(mirror)),
                ),
              ),
            ),
          if (name.isNotEmpty)
            Tooltip(
              message:
                  '${node!.longName.isEmpty ? name : node.longName}: $status',
              child: InkWell(
                borderRadius: BorderRadius.circular(Tokens.s8),
                onTap: () => context.go('/connection'),
                child: Padding(
                  padding: pad,
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: _color(level),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
