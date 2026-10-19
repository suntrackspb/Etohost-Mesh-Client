import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/glyph_zip.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/message_sender.dart';
import '../../data/mirror_ingest.dart';
import '../../mirror/mirror_models.dart';
import '../../ui/kit/kit.dart';

/// Быстрые реакции (как в официальных клиентах — эмодзи-ответ на сообщение).
const quickReactions = ['👍', '❤️', '😂', '😮', '😢', '👎'];

/// Сообщение-реакция: эмодзи-ответ на другое сообщение.
bool isReaction(Message m) => m.emoji != 0 && m.replyId != null;

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

  @override
  void didUpdateWidget(ChatFeed old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
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

class _MessageList extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
          return _Bubble(
            message: m,
            author: _authorName(nodes, m.fromNum),
            shortName: nodes[m.fromNum]?.shortName,
            quoted: m.replyId == null ? null : byPacket[m.replyId],
            quotedAuthor: m.replyId == null || byPacket[m.replyId] == null
                ? null
                : _authorName(nodes, byPacket[m.replyId]!.fromNum),
            reactions: reactions[m.packetId] ?? const [],
            showSource: mirror,
            onMenu: () => _showMenu(context, ref, m),
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref, Message m) {
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
    required this.message,
    required this.author,
    required this.shortName,
    required this.quoted,
    required this.quotedAuthor,
    required this.reactions,
    required this.showSource,
    required this.onMenu,
  });

  final Message message;
  final String author;
  final String? shortName;
  final Message? quoted;
  final String? quotedAuthor;
  final List<Message> reactions;
  final bool showSource;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final out = message.isOutgoing;
    final t = message.rxTime;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final bubble = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.s12,
        vertical: Tokens.s8,
      ),
      decoration: BoxDecoration(
        color: out ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(Tokens.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!out)
            Text(
              author,
              style: text.labelMedium?.copyWith(color: scheme.primary),
            ),
          if (message.replyId != null) _Quote(quoted, quotedAuthor),
          Text(message.body),
          const SizedBox(height: Tokens.s4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.pkiEncrypted) ...[
                const _PkiIcon(true, size: 12),
                const SizedBox(width: Tokens.s4),
              ],
              if (showSource) _SourceIcons(message: message),
              Text(time, style: text.labelSmall),
              if (out) ...[const SizedBox(width: Tokens.s4), _AckIcon(message)],
            ],
          ),
        ],
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
            CircleAvatar(
              radius: 16,
              child: Text(
                shortName?.isNotEmpty == true ? shortName! : '?',
                style: const TextStyle(fontSize: 11),
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
                child: Column(
                  crossAxisAlignment: out
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    bubble,
                    if (reactions.isNotEmpty) _Reactions(reactions),
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

class _Reactions extends StatelessWidget {
  const _Reactions(this.reactions);

  final List<Message> reactions;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final r in reactions) {
      counts[r.body] = (counts[r.body] ?? 0) + 1;
    }
    return Padding(
      padding: const EdgeInsets.only(top: Tokens.s4),
      child: Wrap(
        spacing: Tokens.s4,
        children: [
          for (final e in counts.entries)
            Chip(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              label: Text(e.value > 1 ? '${e.key} ${e.value}' : e.key),
            ),
        ],
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
    final (icon, color, hint) = switch (message.ackState) {
      AckState.none ||
      AckState.pending => (Icons.schedule, scheme.outline, 'Отправляется'),
      AckState.acked => (Icons.done_all, scheme.primary, 'Доставлено'),
      AckState.failed => (
        Icons.error_outline,
        scheme.error,
        'Ошибка: ${Routing_Error.valueOf(message.ackError ?? 0)?.name ?? message.ackError}',
      ),
      AckState.timeout => (
        Icons.error_outline,
        scheme.error,
        'Нет подтверждения',
      ),
      AckState.notSent => (Icons.error_outline, scheme.error, 'Не отправлено'),
    };
    return Tooltip(
      message: hint,
      child: Icon(icon, size: 14, color: color),
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

  bool _valid(int zip) {
    final t = _outgoing(zip);
    return t.isNotEmpty && messageBytes(t) <= maxMessageBytes;
  }

  Future<void> _submit() async {
    final zip = _zip;
    if (!_valid(zip) || !ref.read(canSendProvider)) return;
    if (await widget.onSend(_outgoing(zip))) _text.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSend = ref.watch(canSendProvider);
    final zip = ref.watch(glyphZipLevelProvider).value ?? 0;
    final bytes = messageBytes(_outgoing(zip));
    final over = bytes > maxMessageBytes;
    final reply = widget.replyTo;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        padding: const EdgeInsets.fromLTRB(
          Tokens.s12,
          Tokens.s4,
          Tokens.s4,
          Tokens.s8,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.enter): _submit,
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
                        counterText: bytes == 0
                            ? null
                            : '$bytes / $maxMessageBytes',
                        counterStyle: over
                            ? TextStyle(color: scheme.error)
                            : null,
                      ),
                    ),
                  ),
                ),
                _ZipButton(level: zip),
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
    );
  }
}

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
          margin: const EdgeInsets.only(bottom: Tokens.s8),
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
