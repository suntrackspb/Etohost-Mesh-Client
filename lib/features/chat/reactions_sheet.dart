import 'dart:math' show max;

import 'package:flutter/material.dart';

import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/message_meta.dart';
import '../../data/reaction_groups.dart';
import '../../ui/kit/kit.dart';
import '../nodes/open_node.dart';
import 'chat_feed.dart' show RelayChip;

/// Чипы реакций внутри пузыря; нажатие — панель «кто поставил».
class ReactionChips extends StatelessWidget {
  const ReactionChips({
    super.key,
    required this.groups,
    required this.outgoing,
    required this.onOpen,
  });

  final List<ReactionGroup> groups;

  /// Пузырь своего сообщения — другая подложка чипа.
  final bool outgoing;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fill = outgoing
        ? scheme.onPrimaryContainer.withValues(alpha: 0.1)
        : scheme.onSurface.withValues(alpha: 0.08);
    return Padding(
      padding: const EdgeInsets.only(top: Tokens.s4),
      child: Wrap(
        spacing: Tokens.s4,
        runSpacing: Tokens.s4,
        children: [
          for (final g in groups)
            Semantics(
              button: true,
              label: '${g.emoji}: ${g.count}. Показать, кто поставил',
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onOpen(g.emoji),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Tokens.s8,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    color: fill,
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(g.emoji, style: const TextStyle(fontSize: 15)),
                      if (g.count > 1) ...[
                        const SizedBox(width: 3),
                        Text(
                          '${g.count}',
                          style: text.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Нижняя панель реакций: вкладки «Все / 👋 2 / 🤝 1», строка на каждую
/// реакцию; нажатие на строку — карточка ноды.
Future<void> showReactionsSheet(
  BuildContext context, {
  required List<ReactionGroup> groups,
  required Map<int, Node> nodes,
  String? initial,
  bool mirror = false,
  ValueChanged<Message>? onOpenRelays,
}) {
  final tabs = <(String, List<Message>)>[
    if (groups.length > 1) ('Все', allReactions(groups)),
    for (final g in groups) (g.emoji, g.items),
  ];
  final start = initial == null || groups.length < 2
      ? 0
      : 1 + groups.indexWhere((g) => g.emoji == initial).clamp(0, 99);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => DefaultTabController(
      length: tabs.length,
      initialIndex: start.clamp(0, tabs.length - 1),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tabs.length > 1)
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final (title, items) in tabs)
                    Tab(text: '$title ${items.length}'),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: Tokens.s8),
                child: Text(
                  '${tabs.first.$1} ${tabs.first.$2.length}',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
            // TabBarView нужна точная высота: по самой длинной вкладке,
            // но не выше 60% экрана (дальше — прокрутка).
            SizedBox(
              height:
                  (_rowHeight * tabs.map((t) => t.$2.length).reduce(max) +
                          Tokens.s16)
                      .clamp(0, MediaQuery.sizeOf(ctx).height * 0.6),
              child: TabBarView(
                children: [
                  for (final (_, items) in tabs)
                    _ReactionList(
                      items: items,
                      nodes: nodes,
                      showEmoji: groups.length > 1,
                      mirror: mirror,
                      onOpenRelays: onOpenRelays == null
                          ? null
                          : (r) {
                              Navigator.pop(ctx);
                              onOpenRelays(r);
                            },
                      onOpenNode: (nodeNum) {
                        Navigator.pop(ctx);
                        openNode(context, nodeNum);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Высота строки ListTile с подзаголовком.
const _rowHeight = 72.0;

class _ReactionList extends StatelessWidget {
  const _ReactionList({
    required this.items,
    required this.nodes,
    required this.showEmoji,
    required this.onOpenNode,
    this.mirror = false,
    this.onOpenRelays,
  });

  final List<Message> items;
  final Map<int, Node> nodes;
  final bool showEmoji;
  final ValueChanged<int> onOpenNode;
  final bool mirror;

  /// Шлюзы зеркала, принявшие реакцию: она — отдельный пакет.
  final ValueChanged<Message>? onOpenRelays;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: Tokens.s16),
      children: [
        for (final r in items)
          Builder(
            builder: (context) {
              final node = nodes[r.fromNum];
              final id = nodeIdString(r.fromNum);
              final name = node?.longName.isNotEmpty == true
                  ? node!.longName
                  : id;
              final t = r.rxTime;
              final time =
                  '${t.hour.toString().padLeft(2, '0')}:'
                  '${t.minute.toString().padLeft(2, '0')}';
              final source = reactionSource(r);
              return ListTile(
                onTap: () => onOpenNode(r.fromNum),
                leading: NodeAvatar(
                  nodeNum: r.fromNum,
                  shortName: node?.shortName,
                  size: 40,
                ),
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  [if (name != id) id, time, ?source].join(' · '),
                  style: text.bodySmall?.copyWith(color: muted),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onOpenRelays != null && showRelays(r, mirror: mirror))
                      RelayChip(
                        count: r.relayCount,
                        onTap: () => onOpenRelays!(r),
                      ),
                    const SizedBox(width: Tokens.s8),
                    showEmoji
                        ? Text(
                            r.body.trim(),
                            style: const TextStyle(fontSize: 22),
                          )
                        : const Icon(Icons.chevron_right),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
