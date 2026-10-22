import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/node_row_info.dart';
import '../../ui/kit/kit.dart';
import 'node_detail_page.dart';
import 'node_filter_sheet.dart';
import '../../app/link_badge.dart';

/// Список нод; на широком экране справа — карточка выбранной.
class NodesPage extends ConsumerStatefulWidget {
  const NodesPage({super.key, this.selected});

  final int? selected;

  @override
  ConsumerState<NodesPage> createState() => _NodesPageState();
}

class _NodesPageState extends ConsumerState<NodesPage> {
  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(filteredNodesProvider);
    final total = ref.watch(nodesProvider).value?.length;
    final filter = ref.watch(nodeFilterProvider);
    final wide = SplitView.isWide(context);

    final list = Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !wide,
        title: Text(
          'Ноды${!nodes.hasValue
              ? ''
              : nodes.value!.length == total
              ? ' ($total)'
              : ' (${nodes.value!.length} из $total)'}',
        ),
        actions: [
          IconButton(
            tooltip: 'Фильтры и сортировка',
            icon: Badge(
              isLabelVisible: filter.active,
              smallSize: 8,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => NodeFilterSheet.show(context),
          ),
          const LinkBadge(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Tokens.s16,
              0,
              Tokens.s16,
              Tokens.s8,
            ),
            child: TextFormField(
              initialValue: filter.query,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Имя или !id',
              ),
              onChanged: (v) => ref.read(nodeFilterProvider.notifier).state =
                  ref.read(nodeFilterProvider).copyWith(query: v),
            ),
          ),
        ),
      ),
      body: nodes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, text: '$e'),
        data: (items) {
          if (total == 0) {
            return const EmptyState(
              icon: Icons.hub_outlined,
              text: 'Нод пока нет.\nПодключитесь к своей ноде.',
            );
          }
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.filter_list_off,
              text: 'Под фильтр ничего не подходит',
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) => _NodeTile(
              node: items[i],
              selected: wide && items[i].num == widget.selected,
              onTap: () => wide
                  ? context.go('/nodes/${items[i].num}')
                  : context.push('/node/${items[i].num}'),
            ),
          );
        },
      ),
    );

    return SplitView(
      list: list,
      detail: widget.selected == null
          ? null
          : NodeDetailPage(num: widget.selected!),
      placeholder: const EmptyState(
        icon: Icons.touch_app_outlined,
        text: 'Выберите ноду',
      ),
    );
  }
}

class _NodeTile extends ConsumerWidget {
  const _NodeTile({
    required this.node,
    required this.onTap,
    this.selected = false,
  });

  final Node node;
  final VoidCallback onTap;
  final bool selected;

  static Color _qualityColor(SignalQuality q) => switch (q) {
    SignalQuality.good => Colors.green,
    SignalQuality.fair => Colors.amber.shade700,
    SignalQuality.bad => Colors.deepOrange,
    SignalQuality.none => Colors.red,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = node.longName.isEmpty ? nodeIdString(node.num) : node.longName;
    final preset = nodePreset(node, ref.watch(presetNameProvider).value);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: muted);
    final hasKey = node.publicKey?.isNotEmpty == true;

    Widget item(IconData icon, String text, {Color? color}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? muted),
        const SizedBox(width: 2),
        Text(text, style: style?.copyWith(color: color)),
      ],
    );

    final line3 = [
      if (node.lastHeard != null)
        Text(
          lastHeardText(node.lastHeard!),
          style: heardRecently(node.lastHeard)
              ? style?.copyWith(color: Colors.green)
              : style,
        ),
      if (node.hopsAway != null)
        item(
          Icons.alt_route,
          node.hopsAway == 0 ? 'direct' : '${node.hopsAway}',
        ),
      if (node.latitude != null)
        Tooltip(
          message: 'Есть координаты',
          child: Icon(Icons.location_on, size: 14, color: muted),
        ),
      if (node.snr != null)
        item(
          Icons.signal_cellular_alt,
          '${node.snr!.toStringAsFixed(1)} dB',
          color: _qualityColor(snrQuality(node.snr!, preset)),
        ),
      if (node.rssi != null)
        item(
          Icons.settings_input_antenna,
          '${node.rssi} dBm',
          color: _qualityColor(rssiQuality(node.rssi!)),
        ),
      if (node.viaMqtt) Text('MQTT', style: style),
    ];

    return MeshTile(
      title: name,
      titleExtra: Tooltip(
        message: hasKey ? 'Есть публичный ключ' : 'Нет публичного ключа',
        child: Icon(
          Icons.key,
          size: 14,
          color: hasKey ? Colors.green : Colors.red,
        ),
      ),
      subtitleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [nodeIdString(node.num), roleName(node.role), ?preset].join(' · '),
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (line3.isNotEmpty)
            Wrap(spacing: 8, runSpacing: 2, children: line3),
        ],
      ),
      selected: selected,
      leading: NodeAvatar(nodeNum: node.num, shortName: node.shortName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!node.onRadio)
            const Tooltip(
              message: 'Только из зеркала',
              child: Icon(Icons.cloud_outlined, size: 18),
            ),
          if (node.isIgnored)
            const Tooltip(
              message: 'Игнорируется',
              child: Icon(Icons.block, size: 18),
            ),
          if (node.isFavorite)
            const Icon(Icons.star, size: 18, color: Colors.amber),
        ],
      ),
      onTap: onTap,
    );
  }
}

String lastHeardText(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'только что';
  if (d.inHours < 1) return '${d.inMinutes} мин назад';
  if (d.inDays < 1) return '${d.inHours} ч назад';
  return '${d.inDays} д назад';
}
