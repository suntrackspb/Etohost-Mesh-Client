import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/images_providers.dart';
import '../../app/notify_providers.dart';
import '../../app/providers.dart';
import '../../core/glyph_zip.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/delivery.dart';
import '../../data/message_meta.dart';
import '../../data/message_sender.dart';
import '../../data/message_split.dart';
import '../../data/mirror_ingest.dart';
import '../../data/reaction_groups.dart';
import '../../mirror/mirror_config.dart';
import '../../mirror/mirror_models.dart';
import '../../ui/kit/kit.dart';
import '../nodes/open_node.dart';
import 'link_text.dart';
import 'message_images.dart';
import 'reactions_sheet.dart';
import 'relay_map_sheet.dart';
import 'scroll_to_item.dart';
import 'swipe_to_reply.dart';

/// Быстрые реакции (как в официальных клиентах — эмодзи-ответ на сообщение).
const quickReactions = ['👍', '❤️', '😂', '😮', '😢', '👎'];

/// Сообщение-реакция: эмодзи-ответ на другое сообщение. Из зеркала флаг
/// `emoji` не приходит — тогда реакция это ответ из одних эмодзи.
bool isReaction(Message m) =>
    m.replyId != null && (m.emoji != 0 || isEmojiOnly(m.body));

/// Лента переписки (канал или личный диалог) с полем ввода.
class ChatFeed extends ConsumerStatefulWidget {
  const ChatFeed({super.key, required this.id, this.standalone = false});

  /// [ChatTarget.id].
  final String id;
  final bool standalone;

  @override
  ConsumerState<ChatFeed> createState() => _ChatFeedState();
}

class _ChatFeedState extends ConsumerState<ChatFeed> {
  Message? _replyTo;
  bool _loadingMore = false;

  /// Зеркало отдало всю историю (или её нет).
  bool _mirrorDone = false;

  late final _openChats = ref.read(openChatsProvider);

  @override
  void initState() {
    super.initState();
    _openChats.open(widget.id);
  }

  @override
  void dispose() {
    _openChats.close(widget.id);
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatFeed old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      _openChats
        ..close(old.id)
        ..open(widget.id);
      _replyTo = null;
      _mirrorDone = false;
    }
  }

  /// Открытая переписка прочитана до самого свежего входящего.
  void _markRead(List<Message> list) {
    final newest = list.where((m) => !m.isOutgoing).firstOrNull?.rxTime;
    if (newest == null) return;
    final id = widget.id;
    final read = ref.read(feedReadProvider(id));
    if (!read.hasValue) return;
    if (read.value != null && !newest.isAfter(read.value!)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(databaseProvider)
          .setSetting(readSettingKey(id), newest.toIso8601String());
    });
  }

  /// Подгрузить старше: сначала из БД, когда там кончилось — страница зеркала.
  Future<void> _loadMore(int loaded) async {
    if (_loadingMore) return;
    final limit = feedLimitProvider(widget.id);
    final current = ref.read(limit);
    if (loaded >= current) {
      ref.read(limit.notifier).state = current + feedPageSize;
      return;
    }
    // Личных сообщений в зеркале нет.
    final api = ref.read(mirrorApiProvider);
    if (api == null || _mirrorDone || widget.id.startsWith('dm:')) return;
    setState(() => _loadingMore = true);
    try {
      final db = ref.read(databaseProvider);
      final before = await db.oldestMirrorId();
      final page = before == null
          ? const <MirrorMessage>[]
          : await api.chatHistory(beforeId: before);
      if (page.isEmpty) {
        _mirrorDone = true;
      } else {
        await MirrorIngest(db).messages(page);
        ref.read(limit.notifier).state = current + feedPageSize;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('История не загружена: $e')));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    final target = ChatTarget.parse(id);
    final messages = ref.watch(feedMessagesProvider(id));
    final nodes = {
      for (final n in ref.watch(nodesProvider).value ?? <Node>[]) n.num: n,
    };
    final String title;
    final String? blocked; // почему писать нельзя
    switch (target) {
      case ChannelTarget(:final key):
        final channel = ref
            .watch(chatChannelsProvider)
            .value
            ?.where((c) => c.key == key)
            .firstOrNull;
        title = channel?.title ?? key;
        blocked = channel?.index == null
            ? 'Канал есть только в зеркале — писать в него нельзя.'
            : null;
      case DirectTarget(:final num):
        title = _authorName(nodes, num);
        blocked = switch (directBlock(nodes[num])) {
          DirectBlock.noKey =>
            'Нет публичного ключа ноды — писать можно будет, когда придёт её NodeInfo.',
          DirectBlock.unmessagable => 'Нода не принимает личные сообщения.',
          null => null,
        };
    }
    final mirrorHistory =
        target is ChannelTarget && ref.watch(mirrorActiveProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.standalone,
        leading: widget.standalone
            ? BackButton(onPressed: () => context.go('/chat'))
            : null,
        title: Row(
          children: [
            if (target is DirectTarget) ...[
              _PkiIcon(blocked == null),
              const SizedBox(width: Tokens.s8),
            ],
            Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  EmptyState(icon: Icons.error_outline, text: '$e'),
              data: (list) {
                _markRead(list);
                return _MessageList(
                  feedId: id,
                  messages: list,
                  canLoadMore:
                      list.length >= ref.watch(feedLimitProvider(id)) ||
                      (mirrorHistory && !_mirrorDone),
                  loadingMore: _loadingMore,
                  onLoadMore: () => _loadMore(list.length),
                  nodes: nodes,
                  canWrite: blocked == null,
                  onReply: (m) => setState(() => _replyTo = m),
                  onReact: (m, emoji) => _send(emoji, replyTo: m, emoji: true),
                );
              },
            ),
          ),
          if (blocked != null)
            _Notice(blocked)
          else
            _Composer(
              replyTo: _replyTo,
              replyAuthor: _replyTo == null
                  ? null
                  : _authorName(nodes, _replyTo!.fromNum),
              onCancelReply: () => setState(() => _replyTo = null),
              onSend: (text) {
                final r = _replyTo;
                setState(() => _replyTo = null);
                return _send(text, replyTo: r);
              },
            ),
        ],
      ),
    );
  }

  Future<bool> _send(
    String text, {
    Message? replyTo,
    bool emoji = false,
  }) async {
    final sender = ref.read(messageSenderProvider);
    try {
      // Не ждём доставки: статус обновится в ленте.
      final Future<void> sending;
      switch (ChatTarget.parse(widget.id)) {
        case ChannelTarget(:final key):
          final index = ref
              .read(chatChannelsProvider)
              .value
              ?.where((c) => c.key == key)
              .firstOrNull
              ?.index;
          if (index == null) return false;
          sending = sender.sendToChannel(
            channel: index,
            channelKey: key,
            text: text,
            replyId: replyTo?.packetId,
            emoji: emoji,
          );
        case DirectTarget(:final num):
          sending = sender.sendDirect(
            to: num,
            text: text,
            replyId: replyTo?.packetId,
            emoji: emoji,
          );
      }
      sending.catchError((Object e) => _error(e));
      return true;
    } catch (e) {
      _error(e);
      return false;
    }
  }

  void _error(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Не отправлено: $e')));
  }
}

String _authorName(Map<int, Node> nodes, int num) {
  final n = nodes[num];
  return n?.longName.isNotEmpty == true ? n!.longName : nodeIdString(num);
}

class _MessageList extends ConsumerStatefulWidget {
  const _MessageList({
    required this.feedId,
    required this.messages,
    required this.canLoadMore,
    required this.loadingMore,
    required this.onLoadMore,
    required this.nodes,
    required this.canWrite,
    required this.onReply,
    required this.onReact,
  });

  final String feedId;
  final List<Message> messages;
  final bool canLoadMore;
  final bool loadingMore;
  final VoidCallback onLoadMore;
  final Map<int, Node> nodes;
  final bool canWrite;
  final ValueChanged<Message> onReply;
  final void Function(Message m, String emoji) onReact;

  @override
  ConsumerState<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<_MessageList> {
  final _scroll = ScrollController();
  final _keys = <int, GlobalKey>{};
  int? _highlight;

  GlobalKey _keyFor(int packetId) => _keys[packetId] ??= GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Тап по цитате: прокрутить к исходному сообщению и подсветить его.
  Future<void> _jumpTo(List<Message> visible, int packetId) async {
    final target = visible.indexWhere((m) => m.packetId == packetId);
    if (target < 0) return;
    final ok = await scrollToItem(
      _scroll,
      target,
      visible.length,
      (i) => _keyFor(visible[i].packetId),
    );
    if (!ok || !mounted) return;
    setState(() => _highlight = packetId);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted && _highlight == packetId) setState(() => _highlight = null);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final (feedId, messages, canLoadMore, loadingMore, onLoadMore, nodes) = (
      w.feedId,
      w.messages,
      w.canLoadMore,
      w.loadingMore,
      w.onLoadMore,
      w.nodes,
    );
    final (canWrite, onReply) = (w.canWrite, w.onReply);
    final mirror = ref.watch(mirrorActiveProvider);
    final byPacket = {for (final m in messages) m.packetId: m};
    final reactions = <int, List<Message>>{};
    final visible = <Message>[];
    for (final m in messages) {
      if (isReaction(m)) {
        (reactions[m.replyId!] ??= []).add(m);
      } else {
        visible.add(m);
      }
    }
    if (visible.isEmpty && !canLoadMore) {
      return const EmptyState(
        icon: Icons.chat_bubble_outline,
        text: 'Сообщений пока нет',
      );
    }
    final more = canLoadMore ? 1 : 0;
    return NotificationListener<ScrollNotification>(
      // Долистали почти до верха (список перевёрнут — это конец) — подгружаем.
      onNotification: (n) {
        if (canLoadMore &&
            !loadingMore &&
            n.metrics.extentAfter < 400 &&
            n is ScrollUpdateNotification) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        // Позиция прокрутки своя у каждого канала.
        key: PageStorageKey('feed:$feedId'),
        controller: _scroll,
        reverse: true, // свежие снизу; список отсортирован по убыванию времени
        padding: const EdgeInsets.all(Tokens.s8),
        itemCount: visible.length + more,
        itemBuilder: (_, i) {
          if (i == visible.length) {
            return Center(
              child: loadingMore
                  ? const Padding(
                      padding: EdgeInsets.all(Tokens.s8),
                      child: CircularProgressIndicator(),
                    )
                  : TextButton(
                      onPressed: onLoadMore,
                      child: const Text('Загрузить ещё'),
                    ),
            );
          }
          final m = visible[i];
          return SwipeToReply(
            onReply: canWrite ? () => onReply(m) : null,
            child: _Bubble(
              key: _keyFor(m.packetId),
              highlighted: _highlight == m.packetId,
              onOpenQuote: m.replyId == null || byPacket[m.replyId] == null
                  ? null
                  : () => _jumpTo(visible, m.replyId!),
              message: m,
              author: _authorName(nodes, m.fromNum),
              shortName: nodes[m.fromNum]?.shortName,
              quoted: m.replyId == null ? null : byPacket[m.replyId],
              quotedAuthor: m.replyId == null || byPacket[m.replyId] == null
                  ? null
                  : _authorName(nodes, byPacket[m.replyId]!.fromNum),
              reactions: groupReactions(reactions[m.packetId] ?? const []),
              onOpenReactions: (groups, emoji) => showReactionsSheet(
                context,
                groups: groups,
                nodes: nodes,
                initial: emoji,
              ),
              mirror: mirror,
              onMenu: () => _showMenu(context, ref, m),
              onOpenNode: () => openNode(context, m.fromNum),
              onOpenRelays: () {
                final cfg = ref.read(mirrorConfigProvider).value;
                final url = cfg == null || m.mirrorId == null
                    ? null
                    : relayMapUrl(cfg, m.mirrorId!);
                if (url != null) showRelayMap(context, url);
              },
            ),
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref, Message m) {
    final (canWrite, onReply, onReact) = (
      widget.canWrite,
      widget.onReply,
      widget.onReact,
    );
    final failed =
        m.isOutgoing &&
        const [
          AckState.failed,
          AckState.timeout,
          AckState.notSent,
        ].contains(m.ackState);
    final canSend = canWrite && ref.read(canSendProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canSend)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Tokens.s16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final e in quickReactions)
                      IconButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onReact(m, e);
                        },
                        icon: Text(e, style: const TextStyle(fontSize: 24)),
                      ),
                  ],
                ),
              ),
            if (canWrite)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Ответить'),
                onTap: () {
                  Navigator.pop(ctx);
                  onReply(m);
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Копировать'),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: m.body));
              },
            ),
            if (failed && canSend)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Отправить ещё раз'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(messageSenderProvider).retry(m);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.highlighted,
    required this.onOpenQuote,
    required this.message,
    required this.author,
    required this.shortName,
    required this.quoted,
    required this.quotedAuthor,
    required this.reactions,
    required this.onOpenReactions,
    required this.mirror,
    required this.onMenu,
    required this.onOpenNode,
    required this.onOpenRelays,
  });

  final Message message;
  final String author;
  final String? shortName;
  final Message? quoted;
  final String? quotedAuthor;
  final List<ReactionGroup> reactions;
  final void Function(List<ReactionGroup> groups, String emoji) onOpenReactions;
  final bool mirror;
  final VoidCallback onMenu;
  final VoidCallback onOpenNode;
  final VoidCallback onOpenRelays;

  /// Подсветка после перехода по цитате.
  final bool highlighted;

  /// Тап по цитате; null — исходного сообщения нет в загруженной ленте.
  final VoidCallback? onOpenQuote;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final out = message.isOutgoing;
    final t = message.rxTime;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final bubble = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.s12,
        vertical: Tokens.s8,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? scheme.tertiaryContainer
            : out
            ? scheme.primaryContainer
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(Tokens.radiusL),
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!out)
              Text(
                author,
                style: text.labelMedium?.copyWith(color: scheme.primary),
              ),
            if (message.replyId != null)
              GestureDetector(
                onTap: onOpenQuote,
                child: _Quote(quoted, quotedAuthor),
              ),
            LinkText(message.body),
            MessageImages(message.body),
            if (reactions.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: ReactionChips(
                  groups: reactions,
                  outgoing: out,
                  onOpen: (e) => onOpenReactions(reactions, e),
                ),
              ),
            const SizedBox(height: Tokens.s4),
            // Слева источник (и хопы), по центру шлюзы, справа время.
            Row(
              children: [
                if (message.pkiEncrypted) ...[
                  const _PkiIcon(true, size: 12),
                  const SizedBox(width: Tokens.s4),
                ],
                if (message.xeddsaSigned) ...[
                  const Tooltip(
                    message: 'Подпись отправителя проверена',
                    child: Icon(Icons.draw_outlined, size: 12),
                  ),
                  const SizedBox(width: Tokens.s4),
                ],
                _SourceIcons(message: message, mirror: mirror),
                const Spacer(),
                if (showRelays(message, mirror: mirror)) ...[
                  const SizedBox(width: Tokens.s8),
                  _RelayChip(count: message.relayCount, onTap: onOpenRelays),
                  const SizedBox(width: Tokens.s8),
                  const Spacer(),
                ] else
                  const SizedBox(width: Tokens.s12),
                Text(time, style: text.labelSmall),
                if (out) ...[
                  const SizedBox(width: Tokens.s4),
                  _AckIcon(message),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Tokens.s4),
      child: Row(
        mainAxisAlignment: out
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!out) ...[
            GestureDetector(
              onTap: onOpenNode,
              child: NodeAvatar(
                nodeNum: message.fromNum,
                shortName: shortName,
                size: 36,
              ),
            ),
            const SizedBox(width: Tokens.s8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: GestureDetector(
                onLongPress: onMenu,
                onSecondaryTap: onMenu,
                child: bubble,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote(this.quoted, this.author);

  final Message? quoted;
  final String? author;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Tokens.s4),
      padding: const EdgeInsets.only(left: Tokens.s8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: scheme.primary, width: 3)),
      ),
      child: Text(
        quoted == null
            ? 'Ответ на сообщение'
            : '${author ?? ''}: ${quoted!.body}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _AckIcon extends StatelessWidget {
  const _AckIcon(this.message);

  final Message message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (deliveryOf(message)) {
      Delivery.sending => (Icons.schedule, scheme.outline),
      Delivery.delivered => (Icons.done_all, scheme.primary),
      Delivery.proven => (Icons.verified, StatusColors.ok),
      Delivery.forged => (Icons.gpp_bad_outlined, scheme.error),
      Delivery.failed => (Icons.error_outline, scheme.error),
    };
    return Tooltip(
      message: deliveryHint(message),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

class _SourceIcons extends StatelessWidget {
  const _SourceIcons({required this.message, required this.mirror});

  final Message message;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: color);
    final hops = messageHops(message);
    final signal = directSignal(message);
    Widget label(IconData icon, String text, String hint) => Tooltip(
      message: hint,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(text, style: style),
        ],
      ),
    );
    // Как в iOS: RX и хопы для эфира, иначе зеркало.
    final items = [
      if (message.heardOnRadio && !message.isOutgoing) ...[
        label(CupertinoIcons.dot_radiowaves_right, 'RX', 'Слышно в эфире'),
        if (hops != null)
          label(CupertinoIcons.arrow_branch, '$hops', 'Хопов: $hops'),
        if (signal != null) Text(signal, style: style),
      ] else if (mirror && message.heardOnMirror)
        label(CupertinoIcons.globe, 'MQTT', 'Из зеркала'),
    ];
    // Row, а не Wrap: Wrap не учитывает spacing в intrinsic-ширине,
    // и пузырь (IntrinsicWidth) получался уже футера.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, w) in items.indexed) ...[
          if (i > 0) const SizedBox(width: Tokens.s8),
          w,
        ],
      ],
    );
  }
}

/// Сколько шлюзов зеркала приняли сообщение; нажатие — карта ретрансляций.
class _RelayChip extends StatelessWidget {
  const _RelayChip({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.outline;
    return Tooltip(
      message: 'Шлюзы: $count. Показать на карте',
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: ShapeDecoration(
            color: scheme.onSurface.withValues(alpha: 0.08),
            shape: const StadiumBorder(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.antenna_radiowaves_left_right,
                size: 13,
                color: color,
              ),
              const SizedBox(width: 3),
              Text(
                '$count',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s12),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}

/// Поле ввода: лимит в байтах, Enter — отправить, Shift+Enter — перенос.
class _Composer extends ConsumerStatefulWidget {
  const _Composer({
    required this.replyTo,
    required this.replyAuthor,
    required this.onCancelReply,
    required this.onSend,
  });

  final Message? replyTo;
  final String? replyAuthor;
  final VoidCallback onCancelReply;
  final Future<bool> Function(String text) onSend;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(_Composer old) {
    super.didUpdateWidget(old);
    if (widget.replyTo != null && old.replyTo != widget.replyTo) {
      _focus.requestFocus();
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  int get _zip => ref.read(glyphZipLevelProvider).value ?? 0;

  /// Что реально уйдёт в эфир.
  String _outgoing(int zip) => GlyphZip.apply(_text.text.trim(), zip);

  /// Части для отправки: длинный текст — несколькими сообщениями.
  List<String> _parts(int zip) => MessageSplit.split(_outgoing(zip));

  bool _valid(int zip) {
    final n = _parts(zip).length;
    return n > 0 && n <= MessageSplit.maxParts;
  }

  /// Идёт отправка частей: (отправлено, всего).
  (int, int)? _progress;

  Future<void> _submit() async {
    final zip = _zip;
    if (_progress != null || !_valid(zip) || !ref.read(canSendProvider)) {
      return;
    }
    final parts = _parts(zip);
    var sent = 0;
    setState(() => _progress = (0, parts.length));
    for (final part in parts) {
      if (sent > 0) await Future<void>.delayed(MessageSplit.delay);
      if (!mounted || !await widget.onSend(part)) break;
      sent++;
      if (mounted) setState(() => _progress = (sent, parts.length));
    }
    if (!mounted) return;
    setState(() => _progress = null);
    if (sent == parts.length) {
      _text.clear();
    } else if (sent > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Отправлено $sent из ${parts.length}')),
      );
    }
    _focus.requestFocus();
  }

  bool _uploading = false;

  /// Выбрать картинку, загрузить и вставить ссылку в поле.
  Future<void> _attachImage(ImageUploads images) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return;
      setState(() => _uploading = true);
      final img = await images.upload(await files.first.readAsBytes());
      final t = _text.text;
      final sep = t.isEmpty || t.endsWith(' ') || t.endsWith('\n') ? '' : ' ';
      _text.text = '$t$sep${img.url}';
      _text.selection = TextSelection.collapsed(offset: _text.text.length);
      messenger.showSnackBar(
        const SnackBar(content: Text('Картинка загружена, хранится 3 дня')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSend = ref.watch(canSendProvider);
    final images = ref.watch(imageUploadsProvider);
    final zip = ref.watch(glyphZipLevelProvider).value ?? 0;
    final bytes = messageBytes(_outgoing(zip));
    final parts = _parts(zip).length;
    final over = parts > MessageSplit.maxParts;
    final progress = _progress;
    final reply = widget.replyTo;

    // Свайп вниз по строке ввода прячет клавиатуру.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: (d) {
        if (d.delta.dy > 4 && _focus.hasFocus) _focus.unfocus();
      },
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(
            Tokens.s12,
            Tokens.s4,
            Tokens.s4,
            Tokens.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reply != null)
                Row(
                  children: [
                    Icon(Icons.reply, size: 16, color: scheme.primary),
                    const SizedBox(width: Tokens.s8),
                    Expanded(
                      child: Text(
                        '${widget.replyAuthor}: ${reply.body}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Отменить ответ',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: widget.onCancelReply,
                    ),
                  ],
                ),
              // Счётчик над строкой: внутри поля он менял его высоту и
              // сбивал выравнивание с кнопками.
              if (bytes > 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: Tokens.s4,
                      right: Tokens.s12,
                    ),
                    child: Text(
                      parts <= 1
                          ? '$bytes / $maxMessageBytes'
                          : over
                          ? 'Слишком длинно: больше ${MessageSplit.maxParts} сообщений'
                          : '$bytes байт · уйдёт $parts сообщениями',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: over ? scheme.error : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.enter):
                            _submit,
                        const SingleActivator(LogicalKeyboardKey.numpadEnter):
                            _submit,
                      },
                      child: TextField(
                        controller: _text,
                        focusNode: _focus,
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: canSend
                              ? 'Сообщение'
                              : 'Подключитесь к ноде, чтобы писать',
                          border: InputBorder.none,
                          // Одна строка — ровно высота кнопок (48), текст
                          // по центру вровень с ними.
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (images != null)
                    _uploading
                        ? const SizedBox(
                            width: _rowHeight,
                            height: _rowHeight,
                            child: Center(
                              child: SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Картинка',
                            icon: const Icon(Icons.image_outlined),
                            onPressed: canSend
                                ? () => _attachImage(images)
                                : null,
                          ),
                  SizedBox(
                    height: _rowHeight,
                    child: Center(child: _ZipButton(level: zip)),
                  ),
                  if (progress != null)
                    SizedBox(
                      width: _rowHeight,
                      height: _rowHeight,
                      child: Center(
                        child: Text(
                          '${progress.$1}/${progress.$2}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      tooltip: 'Отправить',
                      icon: const Icon(Icons.send),
                      onPressed: canSend && _valid(zip) ? _submit : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Высота строки ввода: как у IconButton.
const _rowHeight = 48.0;

/// Переключатель GlyphZip: цвет — уровень (серый, зелёный, жёлтый, красный).
class _ZipButton extends ConsumerWidget {
  const _ZipButton({required this.level});

  final int level;

  static const _colors = [Colors.grey, Colors.green, Colors.amber, Colors.red];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _colors[level.clamp(0, GlyphZip.maxLevel)];
    return Tooltip(
      message: GlyphZip.hints[level.clamp(0, GlyphZip.maxLevel)],
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => ref
            .read(databaseProvider)
            .setSetting(
              AppSettingKeys.glyphZipLevel,
              '${(level + 1) % (GlyphZip.maxLevel + 1)}',
            ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Tokens.s8,
            vertical: Tokens.s4,
          ),
          decoration: ShapeDecoration(
            color: color.withValues(alpha: 0.18),
            shape: StadiumBorder(
              side: BorderSide(color: color.withValues(alpha: 0.6)),
            ),
          ),
          child: Text(
            'ZIP',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

/// Замок PKI: зелёный — личное шифруется ключом ноды, жёлтый открытый — ключа нет.
class _PkiIcon extends StatelessWidget {
  const _PkiIcon(this.encrypted, {this.size = 18});

  final bool encrypted;
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: encrypted ? 'Зашифровано' : 'Не зашифровано',
    child: Icon(
      encrypted ? Icons.lock : Icons.lock_open,
      size: size,
      color: encrypted ? StatusColors.ok : StatusColors.warn,
    ),
  );
}
