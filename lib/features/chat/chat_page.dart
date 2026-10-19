import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../ui/kit/kit.dart';

/// Каналы и лента канала. Каналы — по имени: так эфир склеивается с зеркалом.
/// Пока только чтение; отправка — этап 4.
class ChatPage extends ConsumerWidget {
  const ChatPage({super.key, this.channel});

  /// Ключ канала (имя в нижнем регистре).
  final String? channel;

  static String location(String key) => '/chat/${Uri.encodeComponent(key)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = SplitView.isWide(context);
    // На узком экране выбранный канал занимает весь экран.
    if (!wide && channel != null) {
      return _ChannelFeed(channelKey: channel!, standalone: true);
    }

    final channels = ref.watch(chatChannelsProvider);
    final list = Scaffold(
      appBar: AppBar(title: const Text('Чат')),
      body: channels.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, text: '$e'),
        data: (all) {
          if (all.isEmpty) {
            return const EmptyState(
              icon: Icons.forum_outlined,
              text: 'Каналы появятся после подключения к ноде.',
            );
          }
          return ListView(
            children: [
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
                  selected: wide && c.key == channel,
                  onTap: () => context.go(ChatPage.location(c.key)),
                ),
            ],
          );
        },
      ),
    );

    return SplitView(
      list: list,
      detail: channel == null ? null : _ChannelFeed(channelKey: channel!),
      placeholder: const EmptyState(
        icon: Icons.forum_outlined,
        text: 'Выберите канал',
      ),
    );
  }
}

class _ChannelFeed extends ConsumerWidget {
  const _ChannelFeed({required this.channelKey, this.standalone = false});

  final String channelKey;
  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(channelMessagesProvider(channelKey));
    final mirror = ref.watch(mirrorActiveProvider);
    final nodes = {
      for (final n in ref.watch(nodesProvider).value ?? <Node>[]) n.num: n,
    };
    final title =
        ref
            .watch(chatChannelsProvider)
            .value
            ?.where((c) => c.key == channelKey)
            .firstOrNull
            ?.title ??
        channelKey;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: standalone,
        leading: standalone
            ? BackButton(onPressed: () => context.go('/chat'))
            : null,
        title: Text(title),
      ),
      body: messages.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, text: '$e'),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.chat_bubble_outline,
                text: 'Сообщений пока нет',
              )
            : ListView.builder(
                reverse:
                    true, // свежие снизу, список отсортирован по убыванию времени
                padding: const EdgeInsets.all(Tokens.s8),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final m = list[i];
                  final n = nodes[m.fromNum];
                  final author = n?.longName.isNotEmpty == true
                      ? n!.longName
                      : nodeIdString(m.fromNum);
                  final t = m.rxTime;
                  return MeshTile(
                    title: author,
                    subtitle: m.body,
                    leading: CircleAvatar(
                      child: Text(
                        n?.shortName ?? '?',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Источник важен, только когда зеркало включено.
                        if (mirror) _SourceIcons(message: m),
                        Text(
                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _SourceIcons extends StatelessWidget {
  const _SourceIcons({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.only(right: Tokens.s4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.heardOnRadio)
            Tooltip(
              message: 'Слышно в эфире',
              child: Icon(Icons.cell_tower, size: 14, color: color),
            ),
          if (message.heardOnMirror)
            Tooltip(
              message: message.relayCount > 0
                  ? 'Из зеркала · ретрансляций: ${message.relayCount}'
                  : 'Из зеркала',
              child: Icon(Icons.cloud_outlined, size: 14, color: color),
            ),
        ],
      ),
    );
  }
}
