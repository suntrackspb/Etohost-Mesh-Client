import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../ui/kit/kit.dart';
import 'nodes_page.dart';

final _nodeProvider = StreamProvider.family<Node?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.nodes,
  )..where((n) => n.num.equals(id))).watchSingleOrNull();
});

/// Карточка ноды (этап 1 — только данные из БД; действия появятся на этапе 5).
class NodeDetailPage extends ConsumerWidget {
  const NodeDetailPage({super.key, required this.num, this.standalone = false});

  final int num;

  /// Открыта отдельным экраном (узкая раскладка) — нужен AppBar с «назад».
  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(_nodeProvider(num));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: standalone,
        title: Text(
          node.value?.longName.isNotEmpty == true
              ? node.value!.longName
              : nodeIdString(num),
        ),
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
                      _row(
                        'Публичный ключ',
                        n.publicKey == null ? 'нет' : 'есть',
                      ),
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
                ],
              ),
      ),
    );
  }

  Widget _row(String k, String v) =>
      MeshTile(title: k, trailing: SelectableText(v));
}
