import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final messenger = ScaffoldMessenger.of(context);
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
  messenger.showSnackBar(SnackBar(content: Text(text)));
}

/// Кнопки действий в AppBar карточки. Админ-действия — только для нод из эфира.
List<Widget> nodeActionButtons(BuildContext context, WidgetRef ref, Node n) {
  final canSend = ref.watch(canSendProvider);
  final a = ref.read(nodeActionsProvider);
  if (!canSend || !n.onRadio) return const [];
  return [
    IconButton(
      tooltip: n.isFavorite ? 'Убрать из избранного' : 'В избранное',
      icon: Icon(n.isFavorite ? Icons.star : Icons.star_border),
      onPressed: () => _run(
        context,
        () => a.setFavorite(n.num, !n.isFavorite),
        n.isFavorite ? 'Убрано из избранного' : 'Добавлено в избранное',
      ),
    ),
    PopupMenuButton<void Function()>(
      onSelected: (f) => f(),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: () => _run(
            context,
            () => a.traceroute(n.num),
            'Трассировка отправлена — ждём ответ',
          ),
          child: const Text('Трассировка маршрута'),
        ),
        PopupMenuItem(
          value: () => _run(
            context,
            () => a.exchangeNodeInfo(n.num),
            'NodeInfo отправлена',
          ),
          child: const Text('Обменяться NodeInfo'),
        ),
        PopupMenuItem(
          value: () => _run(
            context,
            () => a.requestLocalStats(n.num),
            'Запрос статистики отправлен',
          ),
          child: const Text('Запросить статистику'),
        ),
        PopupMenuItem(
          value: () => _run(
            context,
            () => a.setIgnored(n.num, !n.isIgnored),
            n.isIgnored ? 'Нода больше не игнорируется' : 'Нода игнорируется',
          ),
          child: Text(n.isIgnored ? 'Не игнорировать' : 'Игнорировать'),
        ),
        PopupMenuItem(
          value: () async {
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
              await _run(context, () => a.remove(n.num), 'Нода удалена');
            }
          },
          child: const Text('Удалить'),
        ),
      ],
    ),
  ];
}

/// Откуда данные о ноде: эфир приоритетнее зеркала.
String nodeSourceText(Node n) => switch ((n.onRadio, n.onMirror)) {
  (true, true) => 'эфир (зеркало дополняет)',
  (true, false) => 'эфир',
  (false, true) => 'только зеркало',
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
