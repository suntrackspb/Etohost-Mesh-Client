import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/message_sender.dart';
import '../../ui/kit/kit.dart';
import 'chat_feed.dart';

/// Каналы и личные диалоги. Каналы — по имени: так эфир склеивается с зеркалом.
class ChatPage extends ConsumerWidget {
  const ChatPage({super.key, this.selected});

  /// [ChatTarget.id] открытой переписки.
  final String? selected;

  static String location(String id) => '/chat/${Uri.encodeComponent(id)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = SplitView.isWide(context);
    // На узком экране открытая переписка занимает весь экран.
    if (!wide && selected != null) {
      return ChatFeed(id: selected!, standalone: true);
    }

    final channels = ref.watch(chatChannelsProvider);
    final dms = ref.watch(conversationsProvider).value ?? const [];
    final nodes = {
      for (final n in ref.watch(nodesProvider).value ?? <Node>[]) n.num: n,
    };

    final list = Scaffold(
      appBar: AppBar(title: const Text('Чат')),
      body: channels.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, text: '$e'),
        data: (all) {
          if (all.isEmpty && dms.isEmpty) {
            return const EmptyState(
              icon: Icons.forum_outlined,
              text: 'Каналы появятся после подключения к ноде.',
            );
          }
          return ListView(
            children: [
              if (all.isNotEmpty) const _Header('Каналы'),
              for (final c in all)
                MeshTile(
                  title: c.title,
                  subtitle: c.index == null
                      ? 'только из зеркала'
                      : c.primary
                      ? 'основной'
                      : 'канал ${c.index}',
                  leading: CircleAvatar(
                    child: c.index == null
                        ? const Icon(Icons.cloud_outlined, size: 18)
                        : Text('${c.index}'),
                  ),
                  trailing: _UnreadBadge(c.key),
                  selected: wide && c.key == selected,
                  onTap: () => context.go(ChatPage.location(c.key)),
                ),
              if (dms.isNotEmpty) const _Header('Личные'),
              for (final d in dms)
                _DirectTile(d, nodes[d.peer], wide, selected),
            ],
          );
        },
      ),
    );

    return SplitView(
      list: list,
      detail: selected == null ? null : ChatFeed(id: selected!),
      placeholder: const EmptyState(
        icon: Icons.forum_outlined,
        text: 'Выберите канал или диалог',
      ),
    );
  }
}

class _DirectTile extends StatelessWidget {
  const _DirectTile(this.conv, this.node, this.wide, this.selected);

  final Conversation conv;
  final Node? node;
  final bool wide;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final id = DirectTarget(conv.peer).id;
    final name = node?.longName.isNotEmpty == true
        ? node!.longName
        : nodeIdString(conv.peer);
    final encrypted = directBlock(node) == null;
    final last = conv.last;
    return MeshTile(
      title: name,
      subtitle: '${last.isOutgoing ? 'Вы: ' : ''}${last.body}',
      leading: NodeAvatar(nodeNum: conv.peer, shortName: node?.shortName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: encrypted ? 'Зашифровано' : 'Нет ключа — не зашифровано',
            child: Icon(
              encrypted ? Icons.lock : Icons.lock_open,
              size: 16,
              color: encrypted ? StatusColors.ok : StatusColors.warn,
            ),
          ),
          const SizedBox(width: Tokens.s8),
          _UnreadBadge(id),
        ],
      ),
      selected: wide && id == selected,
      onTap: () => context.go(ChatPage.location(id)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Tokens.s16,
      Tokens.s16,
      Tokens.s16,
      Tokens.s4,
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _UnreadBadge extends ConsumerWidget {
  const _UnreadBadge(this.id);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(unreadCountProvider(id)).value ?? 0;
    if (n == 0) return const SizedBox.shrink();
    return Badge(label: Text(n > 99 ? '99+' : '$n'));
  }
}
