import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../../app/toasts.dart';
import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../core/radio/send_queue.dart';
import '../../data/database.dart';
import '../../data/node_actions.dart';
import '../../data/message_sender.dart';
import '../chat/chat_page.dart';
import '../../data/node_position.dart';
import '../../ui/kit/kit.dart';
import '../settings/radio/administration_page.dart';

/// Выполнить действие и сообщить итог; логика — в [NodeActions].
Future<void> runNodeAction(
  BuildContext context,
  Future<Object?> Function() action,
  String ok,
) async {
  final strings = context.l10n;
  String text;
  try {
    final r = await action();
    final success = switch (r) {
      bool b => b,
      DeliveryResult d => d.status == DeliveryStatus.acked,
      (int _, DeliveryResult d) => d.status == DeliveryStatus.acked,
      _ => true,
    };
    text = success ? ok : strings.theNodeDidNotAcknowledgeThe_e56f57;
  } catch (e) {
    text = e is StateError ? e.message : '$e';
  }
  toasts.show(text);
}

/// Кнопка действия карточки: иконка с подписью; кнопки ряда делят ширину
/// поровну.
class _Action extends StatelessWidget {
  const _Action(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(Tokens.s8),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Tokens.s8,
        horizontal: Tokens.s4,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: onTap == null
                ? Theme.of(context).disabledColor
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: Tokens.s4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    ),
  );
}

/// Ряд крупных кнопок на всю ширину карточки.
class _ActionRow extends StatelessWidget {
  const _ActionRow(this.actions);

  final List<_Action> actions;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Tokens.s4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final a in actions) Expanded(child: a)],
    ),
  );
}

/// Своя нода (для «Обменяться местоположением» нужны её координаты).
final _ownNodeProvider = StreamProvider<Node?>((ref) {
  final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
  if (me == null) return Stream.value(null);
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.nodes,
  )..where((n) => n.num.equals(me))).watchSingleOrNull();
});

/// Действия с чужой нодой: сверху частые кнопками, ниже — строки.
/// Запросы по радио доступны и для нод зеркала; игнор и уведомления
/// работают и без подключения (прячут и сообщения из зеркала).
class NodeActionsCard extends ConsumerWidget {
  const NodeActionsCard(this.n, {super.key, this.onWrite, this.quick = false});

  final Node n;

  /// null — кнопки «Написать» нет (нода не принимает личные и т. п.).
  final VoidCallback? onWrite;

  /// Короткое меню списка без карты и QR контакта.
  final bool quick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = ref.watch(canSendProvider);
    final canSend = connected && n.onRadio;
    final own = ref.watch(_ownNodeProvider).value;
    final muted = ref.watch(nodeMutedProvider(n.num)).value ?? false;
    final a = ref.watch(nodeActionsProvider);
    final url = contactUrl(n, own: false);
    VoidCallback? run(Future<Object?> Function() f, String ok) =>
        connected ? () => runNodeAction(context, f, ok) : null;
    return SectionCard(
      title: context.l10n.actions_9978ac,
      children: [
        _ActionRow([
          if (onWrite != null || quick)
            _Action(Icons.chat_outlined, context.l10n.message_bda589, onWrite),
          _Action(
            Icons.route,
            context.l10n.traceRoute_c2e3ed,
            a.blocked(n.num, NodeAction.traceroute)
                ? null
                : run(
                    () => a.traceroute(n.num),
                    context.l10n.tracerouteSentWaitingForAResponse_9a18a6,
                  ),
          ),
          _Action(
            Icons.badge_outlined,
            context.l10n.exchangeNodeinfo_e2f5f6,
            run(
              () => a.exchangeNodeInfo(n.num),
              context.l10n.nodeinfoSent_16d722,
            ),
          ),
          _Action(
            Icons.share_location,
            context.l10n.exchangePosition_b039f2,
            own != null && hasPosition(own)
                ? run(
                    () => a.exchangePosition(n.num),
                    context.l10n.positionSentWaitingForAResponse_640d17,
                  )
                : null,
          ),
        ]),
        if (!quick && nodePosition(n, correction: false) != null)
          MeshTile(
            leading: const Icon(Icons.map_outlined),
            title: context.l10n.navigateToNode_3ebc01,
            onTap: () {
              ref.read(mapFocusProvider.notifier).state = n.num;
              context.go('/map');
            },
          ),
        if (!quick && url != null)
          MeshTile(
            leading: const Icon(Icons.qr_code_2),
            title: context.l10n.shareContactQr_3fcfa5,
            onTap: () => showContactQr(context, n, url),
          ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_off_outlined),
          title: Text(context.l10n.muteNotifications_6f777b),
          value: muted,
          onChanged: (v) => ref
              .read(databaseProvider)
              .setSetting(AppSettingKeys.nodeMuted(n.num), '$v'),
        ),
        SwitchListTile(
          secondary: a.blocked(n.num, NodeAction.favorite)
              ? const _ActionProgress()
              : const Icon(Icons.star_border),
          title: Text(context.l10n.favorite_b880e6),
          value: n.isFavorite,
          onChanged: canSend && !a.blocked(n.num, NodeAction.favorite)
              ? (v) => runNodeAction(
                  context,
                  () => a.setFavorite(n.num, v),
                  v
                      ? context.l10n.addedToFavorites_d0d718
                      : context.l10n.removedFromFavorites_f3503a,
                )
              : null,
        ),
        SwitchListTile(
          secondary: a.blocked(n.num, NodeAction.ignored)
              ? const _ActionProgress()
              : const Icon(Icons.block),
          title: Text(context.l10n.ignore_00e05b),
          value: n.isIgnored,
          onChanged: a.blocked(n.num, NodeAction.ignored)
              ? null
              : (v) => runNodeAction(
                  context,
                  () => a.setIgnored(n.num, v, radio: canSend),
                  v
                      ? context.l10n.nodeIgnored_cdfc8a
                      : context.l10n.nodeNoLongerIgnored_c2b973,
                ),
        ),
      ],
    );
  }
}

final _actionNodeProvider = StreamProvider.autoDispose.family<Node?, int>((
  ref,
  peer,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.nodes,
  )..where((n) => n.num.equals(peer))).watchSingleOrNull();
});

/// Меню сохраняет живую подписку на ноду даже после её скрытия фильтром игнора.
Future<void> showNodeActions(BuildContext context, Node node) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _NodeQuickActions(node),
    );

class _NodeQuickActions extends ConsumerWidget {
  const _NodeQuickActions(this.initial);

  final Node initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(_actionNodeProvider(initial.num)).value ?? initial;
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    final own = me == n.num;
    final keyLoad = !own && n.onMirror
        ? ref.watch(mirrorNodeKeyProvider(n.num))
        : null;
    final canWrite =
        directBlock(n) == null ||
        (ref.watch(hasDirectChatProvider(n.num)).value ?? false);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Tokens.s16,
          0,
          Tokens.s16,
          Tokens.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              n.longName.isEmpty ? nodeIdString(n.num) : n.longName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              nodeIdString(n.num),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: Tokens.s8),
            if (own)
              OwnNodeActionsCard(n)
            else
              NodeActionsCard(
                n,
                quick: true,
                onWrite: canWrite
                    ? () {
                        final router = GoRouter.of(context);
                        Navigator.pop(context);
                        router.go(ChatPage.location(DirectTarget(n.num).id));
                      }
                    : null,
              ),
            if (keyLoad?.isLoading == true &&
                directBlock(n) == DirectBlock.noKey)
              Padding(
                padding: EdgeInsets.all(Tokens.s8),
                child: Text(context.l10n.retrievingPublicKeyFromMirror_c82d52),
              ),
          ],
        ),
      ),
    );
  }
}

/// Занимает место обычной иконки, чтобы строка не сдвигалась при ожидании.
class _ActionProgress extends StatelessWidget {
  const _ActionProgress();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 24,
    child: Padding(
      padding: EdgeInsets.all(2),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        semanticsLabel: context.l10n.pleaseWaitThisActionIsTemporarily_4a28f0,
      ),
    ),
  );
}

/// QR со ссылкой-контактом: сканируется официальными клиентами.
Future<void> showContactQr(BuildContext context, Node n, String url) =>
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(n.longName.isEmpty ? nodeIdString(n.num) : n.longName),
        content: SizedBox(
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(Tokens.s8),
                  child: QrImageView(data: url, size: 244),
                ),
              ),
              const SizedBox(height: Tokens.s8),
              Text(
                context.l10n.scanInMeshtasticToAddThis_e46939,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              toasts.show(context.l10n.linkCopied_49261e);
            },
            child: Text(context.l10n.copyLink_a44800),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(context.l10n.close_4ae50d),
          ),
        ],
      ),
    );

/// Действия своей ноды: разослать NodeInfo и позицию (если есть координаты),
/// показать свой QR контакта, открыть «Администрирование».
class OwnNodeActionsCard extends ConsumerWidget {
  const OwnNodeActionsCard(this.n, {super.key});

  final Node n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSend = ref.watch(canSendProvider);
    final a = ref.read(nodeActionsProvider);
    final url = contactUrl(
      n,
      own: true,
      radioUser: ref.read(radioProvider).ownUser,
    );
    return SectionCard(
      title: context.l10n.actions_9978ac,
      children: [
        if (canSend)
          _ActionRow([
            _Action(
              Icons.badge_outlined,
              context.l10n.sendNodeinfo_79376f,
              () => runNodeAction(
                context,
                a.broadcastNodeInfo,
                context.l10n.nodeinfoBroadcast_f42668,
              ),
            ),
            _Action(
              Icons.my_location,
              context.l10n.sendPosition_1a3631,
              hasPosition(n)
                  ? () => runNodeAction(
                      context,
                      a.broadcastPosition,
                      context.l10n.positionBroadcast_9b9f9c,
                    )
                  : null,
            ),
          ]),
        if (url != null)
          MeshTile(
            leading: const Icon(Icons.qr_code_2),
            title: context.l10n.shareContactQr_3fcfa5,
            onTap: () => showContactQr(context, n, url),
          ),
        // Как в официальных клиентах — из карточки ноды; в настройках тоже.
        MeshTile(
          leading: const Icon(Icons.admin_panel_settings_outlined),
          title: context.l10n.administration_d838aa,
          onTap: () => Navigator.of(context).push(
            SwipeablePageRoute<void>(
              builder: (_) => const AdministrationPage(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Удаление ноды — внизу карточки, с подтверждением: с радио — из базы
/// своей ноды, только из зеркала — из приложения.
class DeleteNodeButton extends ConsumerWidget {
  const DeleteNodeButton(this.n, {super.key});

  final Node n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // С радио — админ-командой своей ноде; только из зеркала — локально.
    final radio = n.onRadio;
    if (radio ? !ref.watch(canSendProvider) : !n.onMirror) {
      return const SizedBox.shrink();
    }
    final error = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Tokens.s16),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: error,
          side: BorderSide(color: error),
        ),
        icon: const Icon(Icons.delete_outline),
        label: Text(context.l10n.delete_86ea33),
        onPressed: () async {
          final yes = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: Text(context.l10n.deleteNode_d5a0b2),
              content: Text(
                radio
                    ? context.l10n.theNodeWillBeRemovedFrom_e0fd0d
                    : context.l10n.theNodeWillBeRemovedFrom_0c5eb5,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: Text(context.l10n.cancel_0ec753),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(context.l10n.delete_86ea33),
                ),
              ],
            ),
          );
          if (yes == true && context.mounted) {
            final a = ref.read(nodeActionsProvider);
            await runNodeAction(
              context,
              radio
                  ? () => a.remove(n.num)
                  : () async {
                      await a.forget(n.num);
                      return true;
                    },
              context.l10n.nodeDeleted_bd0760,
            );
          }
        },
      ),
    );
  }
}

/// Откуда данные о ноде.
String nodeSourceText(Node n) => switch ((n.onRadio, n.onMirror)) {
  (true, true) => 'Радио + Зеркало',
  (true, false) => 'Радио',
  (false, true) => 'Зеркало',
  _ => '—',
};
