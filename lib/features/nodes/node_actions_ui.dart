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
  String text;
  try {
    final r = await action();
    final success = switch (r) {
      bool b => b,
      DeliveryResult d => d.status == DeliveryStatus.acked,
      (int _, DeliveryResult d) => d.status == DeliveryStatus.acked,
      _ => true,
    };
    text = success ? ok : 'Нода не подтвердила команду';
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
      title: 'Действия',
      children: [
        _ActionRow([
          if (onWrite != null || quick)
            _Action(Icons.chat_outlined, 'Написать', onWrite),
          _Action(
            Icons.route,
            'Трассировка маршрута',
            a.blocked(n.num, NodeAction.traceroute)
                ? null
                : run(
                    () => a.traceroute(n.num),
                    'Трассировка отправлена — ждём ответ',
                  ),
          ),
          _Action(
            Icons.badge_outlined,
            'Обменяться NodeInfo',
            run(() => a.exchangeNodeInfo(n.num), 'NodeInfo отправлена'),
          ),
          _Action(
            Icons.share_location,
            'Обменяться местоположением',
            own != null && hasPosition(own)
                ? run(
                    () => a.exchangePosition(n.num),
                    'Позиция отправлена — ждём ответную',
                  )
                : null,
          ),
        ]),
        if (!quick && nodePosition(n, correction: false) != null)
          MeshTile(
            leading: const Icon(Icons.map_outlined),
            title: 'Перейти к ноде',
            onTap: () {
              ref.read(mapFocusProvider.notifier).state = n.num;
              context.go('/map');
            },
          ),
        if (!quick && url != null)
          MeshTile(
            leading: const Icon(Icons.qr_code_2),
            title: 'Поделиться QR контакта',
            onTap: () => showContactQr(context, n, url),
          ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_off_outlined),
          title: const Text('Отключить уведомления'),
          value: muted,
          onChanged: (v) => ref
              .read(databaseProvider)
              .setSetting(AppSettingKeys.nodeMuted(n.num), '$v'),
        ),
        SwitchListTile(
          secondary: a.blocked(n.num, NodeAction.favorite)
              ? const _ActionProgress()
              : const Icon(Icons.star_border),
          title: const Text('Избранное'),
          value: n.isFavorite,
          onChanged: canSend && !a.blocked(n.num, NodeAction.favorite)
              ? (v) => runNodeAction(
                  context,
                  () => a.setFavorite(n.num, v),
                  v ? 'Добавлено в избранное' : 'Убрано из избранного',
                )
              : null,
        ),
        SwitchListTile(
          secondary: a.blocked(n.num, NodeAction.ignored)
              ? const _ActionProgress()
              : const Icon(Icons.block),
          title: const Text('Игнорировать'),
          value: n.isIgnored,
          onChanged: a.blocked(n.num, NodeAction.ignored)
              ? null
              : (v) => runNodeAction(
                  context,
                  () => a.setIgnored(n.num, v, radio: canSend),
                  v ? 'Нода игнорируется' : 'Нода больше не игнорируется',
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
              const Padding(
                padding: EdgeInsets.all(Tokens.s8),
                child: Text('Получение публичного ключа из зеркала…'),
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
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 24,
    child: Padding(
      padding: EdgeInsets.all(2),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        semanticsLabel: 'Подождите, действие временно недоступно',
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
              const Text(
                'Отсканируйте в Meshtastic, чтобы добавить контакт',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              toasts.show('Ссылка скопирована');
            },
            child: const Text('Скопировать ссылку'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Закрыть'),
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
      title: 'Действия',
      children: [
        if (canSend)
          _ActionRow([
            _Action(
              Icons.badge_outlined,
              'Отправить Nodeinfo',
              () => runNodeAction(
                context,
                a.broadcastNodeInfo,
                'NodeInfo отправлена в сеть',
              ),
            ),
            _Action(
              Icons.my_location,
              'Отправить позицию',
              hasPosition(n)
                  ? () => runNodeAction(
                      context,
                      a.broadcastPosition,
                      'Позиция отправлена в сеть',
                    )
                  : null,
            ),
          ]),
        if (url != null)
          MeshTile(
            leading: const Icon(Icons.qr_code_2),
            title: 'Поделиться QR контакта',
            onTap: () => showContactQr(context, n, url),
          ),
        // Как в официальных клиентах — из карточки ноды; в настройках тоже.
        MeshTile(
          leading: const Icon(Icons.admin_panel_settings_outlined),
          title: 'Администрирование',
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
        label: const Text('Удалить'),
        onPressed: () async {
          final yes = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Удалить ноду?'),
              content: Text(
                radio
                    ? 'Нода будет удалена из базы своей ноды. '
                          'Она снова появится, когда её услышат.'
                    : 'Нода будет удалена из приложения. '
                          'Она снова появится, когда её услышат.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('Удалить'),
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
              'Нода удалена',
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
