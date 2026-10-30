import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/message_sender.dart';
import '../../ui/kit/kit.dart';
import '../notices/notice_banner.dart';
import 'chat_feed.dart';
import '../../app/link_badge.dart';

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
      // На широком экране список — левая панель, «назад» ему не нужен.
      appBar: AppBar(
        title: Text(context.l10n.chat_8c77e4),
        automaticallyImplyLeading: !wide,
        actions: const [LinkBadge()],
      ),
      body: Column(
        children: [
          const NoticeBanners(),
          Expanded(
            child: channels.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  EmptyState(icon: Icons.error_outline, text: '$e'),
              data: (all) {
                if (all.isEmpty && dms.isEmpty) {
                  return EmptyState(
                    icon: Icons.forum_outlined,
                    text:
                        context.l10n.channelsWillAppearAfterConnectingTo_e7a062,
                  );
                }
                return ListView(
                  children: [
                    if (all.isNotEmpty) _Header(context.l10n.channels_88a8ec),
                    for (final c in all)
                      MeshTile(
                        title: c.title,
                        subtitle: c.index == null
                            ? context.l10n.mirrorOnly_cb09e9
                            : c.primary
                            ? context.l10n.primary_8a174a
                            : context.l10n.channel_6a801e((c.index).toString()),
                        leading: CircleAvatar(
                          child: c.index == null
                              ? const Icon(Icons.cloud_outlined, size: 18)
                              : Text('${c.index}'),
                        ),
                        trailing: _UnreadBadge(c.key),
                        selected: wide && c.key == selected,
                        onTap: () => context.go(ChatPage.location(c.key)),
                        // Канал только из зеркала можно скрыть.
                        onLongPress: c.index == null
                            ? () => _hide(context, ref, c)
                            : null,
                      ),
                    if (dms.isNotEmpty)
                      _Header(context.l10n.directMessages_96a4a7),
                    for (final d in dms)
                      _DirectTile(d, nodes[d.peer], wide, selected),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );

    return SplitView(
      list: list,
      detail: selected == null ? null : ChatFeed(id: selected!),
      placeholder: EmptyState(
        icon: Icons.forum_outlined,
        text: context.l10n.selectAChannelOrConversation_3b7ddb,
      ),
    );
  }
}

class _DirectTile extends ConsumerWidget {
  const _DirectTile(this.conv, this.node, this.wide, this.selected);

  final Conversation conv;
  final Node? node;
  final bool wide;
  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = DirectTarget(conv.peer).id;
    final name = node?.longName.isNotEmpty == true
        ? node!.longName
        : nodeIdString(conv.peer);
    final encrypted = directBlock(node) == null;
    final last = conv.last;
    return MeshTile(
      title: name,
      subtitle: '${last.isOutgoing ? context.l10n.youPrefix : ''}${last.body}',
      leading: NodeAvatar(nodeNum: conv.peer, shortName: node?.shortName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: encrypted
                ? context.l10n.encrypted_347a1a
                : context.l10n.noKeyNotEncrypted_1c5fa9,
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
      onLongPress: () => _deleteDirect(context, ref, conv.peer, name),
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

Future<void> _hide(BuildContext context, WidgetRef ref, ChatChannel c) async {
  final strings = context.l10n;
  final db = ref.read(databaseProvider);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(strings.hideChannel_3f4e20((c.title).toString())),
      content: Text(strings.itsMirrorMessagesWillBeDeleted_d9e39c),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(strings.cancel_0ec753),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(strings.hide_107291),
        ),
      ],
    ),
  );
  if (ok == true) await db.hideChannel(c.key);
}

Future<void> _deleteDirect(
  BuildContext context,
  WidgetRef ref,
  int peer,
  String name,
) async {
  final strings = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(strings.deleteConversationWith_7b6ba5((name).toString())),
      content: Text(strings.allMessagesInThisChatWill_6baa0a),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(strings.cancel_0ec753),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(strings.delete_86ea33),
        ),
      ],
    ),
  );
  if (ok == true) await ref.read(databaseProvider).deleteDirectChat(peer);
}
