import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/message_sender.dart';
import '../chat/chat_page.dart';
import '../../ui/kit/kit.dart';
import 'node_actions_ui.dart';
import 'nodes_page.dart';
import '../../app/link_badge.dart';

final _nodeProvider = StreamProvider.family<Node?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.nodes,
  )..where((n) => n.num.equals(id))).watchSingleOrNull();
});

/// Карточка ноды: данные из БД, «Написать» и действия с нодой.
class NodeDetailPage extends ConsumerWidget {
  const NodeDetailPage({super.key, required this.num, this.standalone = false});

  final int num;

  /// Открыта отдельным экраном (узкая раскладка) — нужен AppBar с «назад».
  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(_nodeProvider(num));
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    final block = directBlock(node.value);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: standalone,
        title: Text(
          node.value?.longName.isNotEmpty == true
              ? node.value!.longName
              : nodeIdString(num),
        ),
        actions: [
          if (node.value != null && num != me)
            IconButton(
              tooltip: switch (block) {
                null => 'Написать',
                DirectBlock.noKey => 'Нет публичного ключа — написать нельзя',
                DirectBlock.unmessagable => 'Нода не принимает сообщения',
              },
              icon: const Icon(Icons.chat_outlined),
              onPressed: block == null
                  ? () => context.go(ChatPage.location(DirectTarget(num).id))
                  : null,
            ),
          if (node.value != null && num != me)
            ...nodeActionButtons(context, ref, node.value!)
          else if (num == me)
            ...ownNodeActionButtons(context, ref),
          const LinkBadge(),
        ],
      ),
      body: node.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, text: '$e'),
        data: (n) => n == null
            ? const EmptyState(
                icon: Icons.help_outline,
                text: 'Нода не найдена',
              )
            : ListView(
                padding: const EdgeInsets.all(Tokens.s16),
                children: [
                  Center(
                    child: NodeAvatar(
                      nodeNum: n.num,
                      shortName: n.shortName,
                      size: 72,
                    ),
                  ),
                  const SizedBox(height: Tokens.s16),
                  SectionCard(
                    title: 'Нода',
                    children: [
                      _row('ID', nodeIdString(n.num)),
                      _row('Короткое имя', n.shortName),
                      _row(
                        'Модель',
                        HardwareModel.valueOf(n.hwModel)?.name ??
                            '${n.hwModel}',
                      ),
                      _row(
                        'Роль',
                        Config_DeviceConfig_Role.valueOf(n.role)?.name ??
                            '${n.role}',
                      ),
                      _row('Источник', nodeSourceText(n)),
                      _row(
                        'Публичный ключ',
                        n.publicKey == null ? 'нет' : 'есть',
                      ),
                      if (n.hasXeddsaSigned)
                        _row('Подпись XEdDSA', 'подписывает пакеты'),
                    ],
                  ),
                  SectionCard(
                    title: 'Связь',
                    children: [
                      _row(
                        'Последний раз',
                        n.lastHeard == null ? '—' : lastHeardText(n.lastHeard!),
                      ),
                      _row('SNR', n.snr?.toStringAsFixed(1) ?? '—'),
                      _row('Хопов', n.hopsAway?.toString() ?? '—'),
                      _row('Через MQTT', n.viaMqtt ? 'да' : 'нет'),
                    ],
                  ),
                  if (n.batteryLevel != null || n.latitude != null)
                    SectionCard(
                      title: 'Устройство',
                      children: [
                        if (n.batteryLevel != null)
                          _row(
                            'Батарея',
                            n.batteryLevel! > 100
                                ? 'питание от сети'
                                : '${n.batteryLevel}%',
                          ),
                        if (n.voltage != null)
                          _row(
                            'Напряжение',
                            '${n.voltage!.toStringAsFixed(2)} В',
                          ),
                        if (n.latitude != null)
                          _row(
                            'Позиция',
                            '${n.latitude!.toStringAsFixed(5)}, ${n.longitude!.toStringAsFixed(5)}',
                          ),
                      ],
                    ),
                  TracerouteSection(n.num),
                ],
              ),
      ),
    );
  }

  Widget _row(String k, String v) =>
      MeshTile(title: k, trailing: SelectableText(v));
}
