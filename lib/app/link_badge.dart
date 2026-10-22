import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/radio/radio_session.dart';
import '../data/database.dart';
import '../data/node_dbs.dart';
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
/// Нажатие — вкладка «Связь».
class LinkBadge extends ConsumerWidget {
  const LinkBadge({super.key});

  static const _yellow = Color(0xFFF2B705);
  static const _green = Color(0xFF34C759);
  static const _red = Color(0xFFFF453A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = linkLevel(ref.watch(radioProvider.select((r) => r.state)));
    final node = ref.watch(linkNodeProvider).value;
    final name = node?.shortName ?? '';
    if (name.isEmpty) return const SizedBox.shrink();
    final color = switch (level) {
      LinkLevel.connecting => _yellow,
      LinkLevel.connected => _green,
      LinkLevel.disconnected => _red,
    };
    final status = switch (level) {
      LinkLevel.connecting => 'подключение',
      LinkLevel.connected => 'подключена',
      LinkLevel.disconnected => 'не подключена',
    };
    final badge = Tooltip(
      message: '${node!.longName.isEmpty ? name : node.longName}: $status',
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.s8),
        onTap: () => context.go('/connection'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Tokens.s8,
            vertical: Tokens.s4,
          ),
          child: Text(
            name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(right: Tokens.s8),
      child: Center(child: badge),
    );
  }
}
