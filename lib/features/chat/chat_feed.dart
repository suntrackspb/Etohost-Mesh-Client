import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/appearance.dart';
import '../../ui/theme.dart';
import '../../app/toasts.dart';
import '../../app/images_providers.dart';
import '../../app/notify_providers.dart';
import '../../app/providers.dart';
import '../../core/glyph_zip.dart';
import '../../core/proto/mesh.dart';
import '../../data/bubble_groups.dart';
import '../../data/chat_days.dart';
import '../../data/database.dart';
import '../../data/delivery.dart';
import '../../data/message_filter.dart';
import '../../data/message_meta.dart';
import '../../data/notify/message_alerts.dart';
import '../../data/message_sender.dart';
import '../../data/message_split.dart';
import '../../data/ping_guard.dart';
import '../../data/mirror_ingest.dart';
import '../../data/reaction_groups.dart';
import '../../data/recent_reactions.dart';
import '../../mirror/mirror_config.dart';
import '../../mirror/mirror_models.dart';
import '../../ui/kit/kit.dart';
import '../nodes/open_node.dart';
import '../../data/read_marker.dart';
import 'chat_page.dart';
import 'chat_search_delegate.dart';
import 'emoji_sheet.dart';
import 'link_text.dart';
import 'message_images.dart';
import 'reactions_sheet.dart';
import 'relay_map_sheet.dart';
import 'scroll_to_item.dart';
import 'swipe_to_reply.dart';
import '../../app/link_badge.dart';

/// Быстрые реакции (как в официальных клиентах — эмодзи-ответ на сообщение).

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

  /// «Показать отфильтрованные» — на время открытого чата.
  bool _showFiltered = false;
  bool _loadingMore = false;

  /// Зеркало отдало всю историю (или её нет).
  bool _mirrorDone = false;

  late final _openChats = ref.read(openChatsProvider);

  /// Отметка «прочитано» на момент входа: граница «Новые сообщения»
  /// держится, пока чат открыт.
  DateTime? _entryMark;
  bool _entryReady = false;

  @override
  void initState() {
    super.initState();
    _openChats.open(widget.id);
    _enter();
  }

  /// Запомнить отметку и догрузить ленту до первого непрочитанного.
  Future<void> _enter() async {
    final id = widget.id;
    final mark = await ref.read(feedReadProvider(id).future);
    final unread = await ref
        .read(unreadCountProvider(id).future)
        .timeout(const Duration(seconds: 3), onTimeout: () => 0);
    final limit = ref.read(feedLimitProvider(id).notifier);
    final want = feedLimitForUnread(limit.state, unread);
    if (want != limit.state) {
      limit.state = want;
      await ref.read(feedMessagesProvider(id).future);
    }
    if (!mounted || id != widget.id) return;
    setState(() {
      _entryMark = mark;
      _entryReady = true;
    });
  }

  /// На экране побывали сообщения до [seen] — двигаем отметку вперёд.
  void _seen(DateTime? seen) {
    final read = ref.read(feedReadProvider(widget.id));
    if (!read.hasValue) return;
    final next = advanceMark(read.value, seen);
    if (next == null || next == read.value) return;
    ref
        .read(databaseProvider)
        .setSetting(readSettingKey(widget.id), next.toIso8601String());
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
      _entryMark = null;
      _entryReady = false;
      _enter();
    }
  }

  Future<void> _search(Map<int, Node> nodes) async {
    final actions = ref.read(chatSearchProvider);
    final id = widget.id;
    final m = await showSearch<Message?>(
      context: context,
      delegate: ChatSearchDelegate(
        search: (q) => actions.search(id, q),
        nodes: nodes,
      ),
    );
    if (m != null) await actions.open(id, m);
  }

  /// Подгрузить старше: сначала из БД, когда там кончилось — страница зеркала.
  /// Выключить или снова включить фильтр сообщений в этом чате.
  Future<void> _toggleFilterHere(bool offNow) async {
    final db = ref.read(databaseProvider);
    final off = decodeStringList(
      await db.getSetting(AppSettingKeys.messageFilterOffChats),
    );
    await db.setSetting(
      AppSettingKeys.messageFilterOffChats,
      encodeStringList([
        for (final c in off)
          if (c != widget.id) c,
        if (!offNow) widget.id,
      ]),
    );
  }

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
        toasts.error('История не загружена: $e');
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
    // Держим недавние реакции загруженными к открытию меню сообщения.
    ref.watch(recentReactionsProvider);
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
    final filter = ref.watch(messageFilterProvider).value;
    final filterOffHere =
        ref.watch(messageFilterOffChatsProvider).value?.contains(id) ?? false;
    final feed = filterFeed(
      messages.value ?? const [],
      filter,
      disabledHere: filterOffHere,
      showFiltered: _showFiltered,
    );

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
        actions: [
          IconButton(
            tooltip: 'Поиск',
            icon: const Icon(Icons.search),
            onPressed: () => _search(nodes),
          ),
          if (filter?.enabled == true)
            _FilterMenu(
              count: feed.filtered.length,
              shown: _showFiltered,
              offHere: filterOffHere,
              onToggleShown: () =>
                  setState(() => _showFiltered = !_showFiltered),
              onToggleHere: () => _toggleFilterHere(filterOffHere),
            ),
          const LinkBadge(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  EmptyState(icon: Icons.error_outline, text: '$e'),
              data: (list) {
                return _MessageList(
                  key: ValueKey(id),
                  feedId: id,
                  unreadAfter: _entryMark,
                  ready: _entryReady,
                  unread: ref.watch(unreadCountProvider(id)).value ?? 0,
                  onSeen: _seen,
                  messages: feed.shown,
                  filtered: feed.filtered,
                  canLoadMore:
                      list.length >= ref.watch(feedLimitProvider(id)) ||
                      (mirrorHistory && !_mirrorDone),
                  loadingMore: _loadingMore,
                  onLoadMore: () => _loadMore(list.length),
                  nodes: nodes,
                  canWrite: blocked == null,
                  onReply: (m) => setState(() => _replyTo = m),
                  onReact: (m, emoji) {
                    rememberReaction(ref, emoji);
                    _send(emoji, replyTo: m, emoji: true);
                  },
                );
              },
            ),
          ),
          if (blocked != null)
            _Notice(blocked)
          else
            _Composer(
              // Свой черновик у каждого чата.
              key: ValueKey('composer:${widget.id}'),
              chatId: widget.id,
              replyTo: _replyTo,
              replyAuthor: _replyTo == null
                  ? null
                  : _authorName(nodes, _replyTo!.fromNum),
              onCancelReply: () => setState(() => _replyTo = null),
              onSend: (text, {required first}) async {
                // Цитата — только у первой части. Следующие уходят с паузой,
                // и за это время могли выбрать «ответить» на другое
                // сообщение: та цитата — уже для следующей отправки.
                if (!first) return _send(text);
                switch (await _pingChoice(text)) {
                  case _PingChoice.cancel:
                    return false;
                  case _PingChoice.services:
                    return _sendToServices(text);
                  case _PingChoice.send:
                    break;
                }
                final r = _replyTo;
                setState(() => _replyTo = null);
                return _send(text, replyTo: r);
              },
            ),
        ],
      ),
    );
  }

  ChatChannel? _channel(String key) => ref
      .read(chatChannelsProvider)
      .value
      ?.where((c) => c.key == key)
      .firstOrNull;

  /// Пинг в основном канале: предложить сервисный канал.
  Future<_PingChoice> _pingChoice(String text) async {
    final target = ChatTarget.parse(widget.id);
    final primary =
        target is ChannelTarget && (_channel(target.key)?.primary ?? false);
    if (!PingGuard.shouldAsk(text, primary: primary)) return _PingChoice.send;
    final services = _channel(PingGuard.servicesKey)?.index != null;
    final choice = await showDialog<_PingChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отправить пинг в Services?'),
        content: Text(
          'Пинги принято отправлять в сервисный канал, там отвечают боты.'
          '${services ? '' : '\n\nКанала Services на ноде нет — добавьте '
                    'его в настройках каналов.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _PingChoice.cancel),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _PingChoice.send),
            child: const Text('Всё равно отправить'),
          ),
          if (services)
            FilledButton(
              onPressed: () => Navigator.pop(ctx, _PingChoice.services),
              child: const Text('Отправить в Services'),
            ),
        ],
      ),
    );
    return choice ?? _PingChoice.cancel;
  }

  /// Отправить в сервисный канал и перейти в него.
  Future<bool> _sendToServices(String text) async {
    final c = _channel(PingGuard.servicesKey);
    if (c?.index == null) return false;
    setState(() => _replyTo = null);
    final sending = ref
        .read(messageSenderProvider)
        .sendToChannel(channel: c!.index!, channelKey: c.key, text: text);
    sending.catchError((Object e) => _error(e));
    if (mounted) context.go(ChatPage.location(c.key));
    return true;
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
    toasts.error('Не отправлено: $e');
  }
}

enum _PingChoice { services, send, cancel }

String _authorName(Map<int, Node> nodes, int num) {
  final n = nodes[num];
  return n?.longName.isNotEmpty == true ? n!.longName : nodeIdString(num);
}

class _MessageList extends ConsumerStatefulWidget {
  const _MessageList({
    super.key,
    required this.feedId,
    required this.unreadAfter,
    required this.ready,
    required this.unread,
    required this.onSeen,
    required this.messages,
    required this.canLoadMore,
    required this.loadingMore,
    required this.onLoadMore,
    required this.nodes,
    required this.canWrite,
    required this.onReply,
    required this.onReact,
    this.filtered = const {},
  });

  final String feedId;

  /// Скрытые фильтром, но показанные по «Показать отфильтрованные».
  final Set<Message> filtered;

  /// Входящие новее — «новые»: над самым старым из них разделитель.
  final DateTime? unreadAfter;

  /// Отметка входа известна, лента догружена — можно позиционировать.
  final bool ready;

  /// Непрочитанных сейчас — счётчик на кнопке «вниз».
  final int unread;
  final ValueChanged<DateTime?> onSeen;
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
  final _listKey = GlobalKey();
  final _keys = <int, GlobalKey>{};
  int? _highlight;
  List<Message> _visible = const [];

  /// Начальная позиция выставлена (к первому непрочитанному или как была).
  bool _positioned = false;

  /// Можно отмечать прочитанное: до позиционирования на экране «низ».
  bool _settled = false;
  bool _atBottom = true;

  GlobalKey _keyFor(int packetId) => _keys[packetId] ??= GlobalKey();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bottom = !_scroll.hasClients || _scroll.offset < 150;
    if (bottom != _atBottom) setState(() => _atBottom = bottom);
  }

  /// Индекс самого свежего сообщения, видного на экране.
  int? _newestOnScreen() {
    final list = _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (list == null || !list.attached) return null;
    final h = list.size.height;
    for (var i = 0; i < _visible.length; i++) {
      final ctx = _keys[_visible[i].packetId]?.currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero, ancestor: list).dy;
      if (top < h && top + box.size.height > 0) return i;
    }
    return null;
  }

  void _reportSeen() {
    if (!_settled || !mounted) return;
    final i = _newestOnScreen();
    if (i == null) return;
    // Внизу — прочитано всё, вместе с реакциями (их нет среди пузырей).
    widget.onSeen(
      i == 0 ? readUpTo(widget.messages, 0) : readUpTo(_visible, i),
    );
  }

  /// Открыть на первом непрочитанном: разделитель — вверху экрана.
  Future<void> _position() async {
    final i = firstUnreadIndex(_visible, widget.unreadAfter);
    if (i != null && i > 0) {
      final list = _visible;
      await scrollToItem(
        _scroll,
        i,
        list.length,
        (j) => _keyFor(list[j].packetId),
        // Список перевёрнут: 1 — верх экрана; чуть ниже, чтобы был виден
        // разделитель над сообщением.
        alignment: 0.9,
        duration: Duration.zero,
      );
    }
    if (!mounted) return;
    _settled = true;
    _onScroll();
    _reportSeen();
  }

  /// Вниз — и всё прочитано.
  void _toBottom() {
    if (!_scroll.hasClients) return;
    if (_scroll.offset > 3 * _scroll.position.viewportDimension) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    widget.onSeen(readUpTo(widget.messages, 0));
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
    final mentionColor = ref.watch(mentionColorProvider);
    final mc = mentionColor.hasValue
        ? mentionColor.value
        : parseMentionColor(null);
    final mentionFill = mc == null
        ? null
        : mentionBubble(mc.color, Theme.of(context).brightness);
    final mirror = ref.watch(mirrorActiveProvider);
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    final myShort = me == null ? '' : nodes[me]?.shortName ?? '';
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
    final positions = bubblePositions(visible);
    _visible = visible;
    final firstNew = firstUnreadIndex(visible, w.unreadAfter);
    if (!_positioned && w.ready) {
      _positioned = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _position());
    } else if (_settled) {
      // Новые данные (пришло сообщение) — видно ли его.
      WidgetsBinding.instance.addPostFrameCallback((_) => _reportSeen());
    }
    // Переход к результату поиска — когда сообщение уже в ленте.
    final jump = ref.watch(chatJumpProvider(feedId));
    if (jump != null && visible.any((m) => m.packetId == jump)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(chatJumpProvider(feedId).notifier).state = null;
        _jumpTo(visible, jump);
      });
    }
    final list = NotificationListener<ScrollNotification>(
      // Долистали почти до верха (список перевёрнут — это конец) — подгружаем.
      onNotification: (n) {
        if (n is ScrollEndNotification) _reportSeen();
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
          final bubble = SwipeToReply(
            onReply: canWrite ? () => onReply(m) : null,
            child: _Bubble(
              key: _keyFor(m.packetId),
              pos: positions[i],
              mention: !m.isOutgoing && _toMe(m, byPacket, me, myShort)
                  ? mentionFill
                  : null,
              highlighted: _highlight == m.packetId,
              filtered: widget.filtered.contains(m),
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
                mirror: mirror,
                onOpenRelays: _openRelays,
              ),
              mirror: mirror,
              onMenu: () => _showMenu(context, ref, m),
              onOpenNode: () => openNode(context, m.fromNum),
              onOpenRelays: () => _openRelays(m),
            ),
          );
          // Первое сообщение дня — плашка с датой над ним; первое
          // непрочитанное — разделитель «Новые сообщения».
          final day = startsDay(visible, i);
          if (!day && i != firstNew) return bubble;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (day) _DayChip(dayLabel(m.rxTime, DateTime.now())),
              if (i == firstNew) const _NewDivider(),
              bubble,
            ],
          );
        },
      ),
    );
    return Stack(
      children: [
        KeyedSubtree(key: _listKey, child: list),
        if (!_atBottom)
          Positioned(
            right: Tokens.s12,
            bottom: Tokens.s12,
            child: Badge(
              isLabelVisible: w.unread > 0,
              label: Text(w.unread > 999 ? '999+' : '${w.unread}'),
              child: FloatingActionButton.small(
                heroTag: 'feedDown:$feedId',
                tooltip: 'Вниз, всё прочитано',
                onPressed: _toBottom,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ),
          ),
      ],
    );
  }

  /// Карта шлюзов зеркала, принявших сообщение (или реакцию).
  void _openRelays(Message m) {
    final cfg = ref.read(mirrorConfigProvider).value;
    final url = cfg == null || m.mirrorId == null
        ? null
        : relayMapUrl(cfg, m.mirrorId!);
    if (url != null) showRelayMap(context, url);
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
                // Два ряда по 6: 11 частых реакций и «+» — полный выбор.
                child: Builder(
                  builder: (_) {
                    final emojis = quickReactions(
                      ref.read(recentReactionsProvider).value ?? const [],
                    );
                    final buttons = <Widget>[
                      for (final e in emojis)
                        IconButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onReact(m, e);
                          },
                          icon: Text(e, style: const TextStyle(fontSize: 24)),
                        ),
                      IconButton(
                        tooltip: 'Другие эмодзи',
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final e = await pickEmoji(context);
                          if (e != null) onReact(m, e);
                        },
                        icon: const Icon(Icons.add_reaction_outlined),
                      ),
                    ];
                    return Column(
                      children: [
                        for (var r = 0; r < buttons.length; r += 6)
                          Row(
                            children: [
                              for (final b in buttons.skip(r).take(6))
                                Expanded(child: b),
                            ],
                          ),
                      ],
                    );
                  },
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
              title: const Text('Копировать текст'),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: m.body));
                toasts.success('Скопировано');
              },
            ),
            const Divider(height: 1),
            for (final (label, value) in messageIds(m))
              ListTile(
                dense: true,
                leading: const Icon(Icons.tag),
                title: Text(label),
                subtitle: Text(
                  value,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: value));
                  toasts.success('Скопировано');
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
    required this.pos,
    required this.mention,
    required this.highlighted,
    this.filtered = false,
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

  /// Место в серии сообщений одного автора.
  final BubblePos pos;

  /// Обращено ко мне (упомянуто короткое имя своей ноды или ответ
  /// с цитатой на моё сообщение) — цвет пузыря; null — обычный.
  final Color? mention;
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

  /// Скрыто фильтром сообщений, показано по запросу — пометка.
  final bool filtered;

  /// Тап по цитате; null — исходного сообщения нет в загруженной ленте.
  final VoidCallback? onOpenQuote;

  /// Внутри серии углы со стороны автора острые: там у серии ровный край,
  /// а с другой стороны пузыри разной ширины — острые углы торчали бы.
  BorderRadius _radius(bool out) {
    const big = Radius.circular(Tokens.radiusL);
    const small = Radius.circular(Tokens.s4);
    final top = pos.joinedAbove ? small : big;
    final bottom = pos.joinedBelow ? small : big;
    return out
        ? BorderRadius.only(
            topLeft: big,
            bottomLeft: big,
            topRight: top,
            bottomRight: bottom,
          )
        : BorderRadius.only(
            topRight: big,
            bottomRight: big,
            topLeft: top,
            bottomLeft: bottom,
          );
  }

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
            // Обращение ко мне — цветом пузыря, а не рамкой: рамка рвёт
            // склеенную серию.
            : mention ?? scheme.surfaceContainerHigh,
        borderRadius: _radius(out),
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!out && !pos.joinedAbove)
              Text(
                author,
                style: text.labelMedium?.copyWith(color: scheme.primary),
              ),
            if (message.replyId != null)
              GestureDetector(
                onTap: onOpenQuote,
                child: _Quote(quoted, quotedAuthor),
              ),
            if (filtered)
              Text(
                'Отфильтрованные',
                style: text.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
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
                  RelayChip(count: message.relayCount, onTap: onOpenRelays),
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
      // В серии пузыри стоят плотно.
      padding: EdgeInsets.only(
        top: pos.joinedAbove ? 1 : Tokens.s4,
        bottom: pos.joinedBelow ? 1 : Tokens.s4,
      ),
      child: Row(
        mainAxisAlignment: out
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!out) ...[
            // Аватар — у нижнего пузыря серии, над остальными — отступ.
            if (pos.joinedBelow)
              const SizedBox(width: _avatarSize)
            else
              GestureDetector(
                onTap: onOpenNode,
                child: NodeAvatar(
                  nodeNum: message.fromNum,
                  shortName: shortName,
                  size: _avatarSize,
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

const _avatarSize = 36.0;

/// Плашка дня между сообщениями: «Сегодня», «Вчера», «20 окт.».
/// Граница прочитанного: над первым сообщением, пришедшим без вас.
class _NewDivider extends StatelessWidget {
  const _NewDivider();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Tokens.s8),
      child: Row(
        children: [
          Expanded(child: Divider(color: scheme.primary)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Tokens.s8),
            child: Text(
              'Новые сообщения',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: scheme.primary),
            ),
          ),
          Expanded(child: Divider(color: scheme.primary)),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Tokens.s8),
        padding: const EdgeInsets.symmetric(
          horizontal: Tokens.s12,
          vertical: Tokens.s4,
        ),
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHighest,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// Чужое сообщение обращено ко мне: упоминание короткого имени своей ноды
/// (как для уведомлений) или ответ на моё сообщение.
bool _toMe(Message m, Map<int, Message> byPacket, int? me, String myShort) {
  if (MessageAlerts.mentions(m.body, myShort)) return true;
  final q = m.replyId == null ? null : byPacket[m.replyId];
  return q != null && (q.isOutgoing || (me != null && q.fromNum == me));
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
        // Своё сообщение ушло через свою ноду: зеркало лишь услышало его
        // эфир. «NET», а не «MQTT»: это зеркало, а не прямой MQTT.
        message.isOutgoing
            ? label(
                CupertinoIcons.dot_radiowaves_right,
                'TX',
                'Отправлено в эфир',
              )
            : label(CupertinoIcons.globe, 'NET', 'Из зеркала'),
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

/// Меню фильтра сообщений в шапке чата (как у Android).
class _FilterMenu extends StatelessWidget {
  const _FilterMenu({
    required this.count,
    required this.shown,
    required this.offHere,
    required this.onToggleShown,
    required this.onToggleHere,
  });

  final int count;
  final bool shown;
  final bool offHere;
  final VoidCallback onToggleShown;
  final VoidCallback onToggleHere;

  @override
  Widget build(BuildContext context) => PopupMenuButton<VoidCallback>(
    tooltip: 'Фильтр сообщений',
    icon: Badge(
      isLabelVisible: count > 0 && !shown && !offHere,
      label: Text('$count'),
      child: Icon(
        offHere ? Icons.filter_alt_off_outlined : Icons.filter_alt_outlined,
      ),
    ),
    onSelected: (f) => f(),
    itemBuilder: (_) => [
      if (count > 0 && !offHere)
        PopupMenuItem(
          value: onToggleShown,
          child: Text(
            shown
                ? 'Скрыть $count отфильтрованных'
                : 'Показать $count отфильтрованных',
          ),
        ),
      PopupMenuItem(
        value: onToggleHere,
        child: Text(offHere ? 'Включить фильтрацию' : 'Отключить фильтрацию'),
      ),
    ],
  );
}

/// Сколько шлюзов зеркала приняли сообщение; нажатие — карта ретрансляций.
class RelayChip extends StatelessWidget {
  const RelayChip({super.key, required this.count, required this.onTap});

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
    super.key,
    required this.chatId,
    required this.replyTo,
    required this.replyAuthor,
    required this.onCancelReply,
    required this.onSend,
  });

  final String chatId;
  final Message? replyTo;
  final String? replyAuthor;
  final VoidCallback onCancelReply;

  /// [first] — первая часть сообщения (только она несёт цитату).
  final Future<bool> Function(String text, {required bool first}) onSend;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    final drafts = ref.read(chatDraftsProvider);
    _text.text = drafts[widget.chatId] ?? '';
    _text.addListener(() {
      // Черновик переживает уход с вкладки и переход в другой чат.
      final t = _text.text;
      if (t.isEmpty) {
        drafts.remove(widget.chatId);
      } else {
        drafts[widget.chatId] = t;
      }
      setState(() {});
    });
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
      if (!mounted || !await widget.onSend(part, first: sent == 0)) break;
      sent++;
      if (mounted) setState(() => _progress = (sent, parts.length));
    }
    if (!mounted) return;
    setState(() => _progress = null);
    if (sent == parts.length) {
      _text.clear();
    } else if (sent > 0) {
      toasts.show('Отправлено $sent из ${parts.length}');
    }
    _focus.requestFocus();
  }

  bool _uploading = false;

  /// Выбрать картинку, загрузить и вставить ссылку в поле.
  Future<void> _attachImage(ImageUploads images) async {
    // Поле в фокусе, пока открыт системный выбор фото: после возврата iOS
    // поднимает клавиатуру сама, а Flutter не получает её высоту — поле
    // ввода оказывается под клавиатурой. Снимаем фокус заранее и
    // возвращаем его, когда окно выбора уже закрылось.
    _focus.unfocus();
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return _refocusAfterPicker();
      setState(() => _uploading = true);
      final img = await images.upload(await files.first.readAsBytes());
      final t = _text.text;
      final sep = t.isEmpty || t.endsWith(' ') || t.endsWith('\n') ? '' : ' ';
      _text.text = '$t$sep${img.url}';
      _text.selection = TextSelection.collapsed(offset: _text.text.length);
      toasts.success('Картинка загружена, хранится 3 дня');
    } catch (e) {
      toasts.error('$e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
    _refocusAfterPicker();
  }

  /// Вернуть фокус после закрытия системного окна (анимация ~0,3 с).
  void _refocusAfterPicker() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focus.requestFocus();
    });
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
