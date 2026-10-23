import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/toasts.dart';
import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../core/radio/send_queue.dart';
import '../../data/database.dart';
import '../../data/node_actions.dart';
import '../../ui/kit/kit.dart';
import 'nodes_page.dart';

/// Выполнить действие и сообщить итог; логика — в [NodeActions].
Future<void> _run(
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
    text = '$e';
  }
  toasts.show(text);
}

/// Кнопка действия карточки: иконка с подписью.
class _Action extends StatelessWidget {
  const _Action(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 96,
    child: InkWell(
      borderRadius: BorderRadius.circular(Tokens.s8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Tokens.s8),
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
    ),
  );
}

/// Действия с чужой нодой. Админ-действия — только для нод из эфира.
class NodeActionsCard extends ConsumerWidget {
  const NodeActionsCard(this.n, {super.key, this.onWrite});

  final Node n;

  /// null — написать нельзя (нет ключа и т. п.).
  final VoidCallback? onWrite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSend = ref.watch(canSendProvider) && n.onRadio;
    final a = ref.read(nodeActionsProvider);
    VoidCallback? run(Future<Object?> Function() f, String ok) =>
        canSend ? () => _run(context, f, ok) : null;
    return SectionCard(
      title: 'Действия',
      children: [
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: [
            _Action(Icons.chat_outlined, 'Написать', onWrite),
            _Action(
              Icons.route,
              'Трассировка маршрута',
              run(
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
              Icons.query_stats,
              'Запросить статистику',
              run(
                () => a.requestLocalStats(n.num),
                'Запрос статистики отправлен',
              ),
            ),
          ],
        ),
        SwitchListTile(
          secondary: const Icon(Icons.star_border),
          title: const Text('Избранное'),
          value: n.isFavorite,
          onChanged: canSend
              ? (v) => _run(
                  context,
                  () => a.setFavorite(n.num, v),
                  v ? 'Добавлено в избранное' : 'Убрано из избранного',
                )
              : null,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.block),
          title: const Text('Игнорировать'),
          value: n.isIgnored,
          onChanged: canSend
              ? (v) => _run(
                  context,
                  () => a.setIgnored(n.num, v),
                  v ? 'Нода игнорируется' : 'Нода больше не игнорируется',
                )
              : null,
        ),
      ],
    );
  }
}

/// Действия своей ноды: разослать NodeInfo и позицию (если есть координаты).
class OwnNodeActionsCard extends ConsumerWidget {
  const OwnNodeActionsCard(this.n, {super.key});

  final Node n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canSendProvider)) return const SizedBox.shrink();
    final a = ref.read(nodeActionsProvider);
    return SectionCard(
      title: 'Действия',
      children: [
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: [
            _Action(
              Icons.badge_outlined,
              'Отправить Nodeinfo',
              () => _run(
                context,
                a.broadcastNodeInfo,
                'NodeInfo отправлена в сеть',
              ),
            ),
            if (hasPosition(n))
              _Action(
                Icons.my_location,
                'Отправить позицию',
                () => _run(
                  context,
                  a.broadcastPosition,
                  'Позиция отправлена в сеть',
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Удаление ноды из базы своей ноды — внизу карточки, с подтверждением.
class DeleteNodeButton extends ConsumerWidget {
  const DeleteNodeButton(this.n, {super.key});

  final Node n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canSendProvider) || !n.onRadio) {
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
              content: const Text(
                'Нода будет удалена из базы своей ноды. '
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
            await _run(context, () => a.remove(n.num), 'Нода удалена');
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

/// История трассировок до ноды.
class TracerouteSection extends ConsumerWidget {
  const TracerouteSection(this.num, {super.key});

  final int num;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(tracerouteHistoryProvider(num)).value ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    final names = {
      for (final n in ref.watch(nodesProvider).value ?? <Node>[])
        n.num: n.shortName.isNotEmpty ? n.shortName : nodeIdString(n.num),
    };
    String path(List<Hop> hops) => hops
        .map(
          (h) =>
              '${names[h.num] ?? nodeIdString(h.num)}'
              '${h.snr == null ? '' : ' (${h.snr!.toStringAsFixed(1)} дБ)'}',
        )
        .join(' → ');
    return SectionCard(
      title: 'Трассировка',
      children: [
        for (final r in list)
          MeshTile(
            title: lastHeardText(r.time),
            subtitle: [
              'Туда: ${path(r.towards)}',
              if (r.back.isNotEmpty) 'Обратно: ${path(r.back)}',
            ].join('\n'),
          ),
      ],
    );
  }
}
