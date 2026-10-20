import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/node_filter.dart';
import '../../ui/kit/kit.dart';

/// Панель фильтров списка нод. Состояние — в [nodeFilterProvider].
class NodeFilterSheet extends ConsumerWidget {
  const NodeFilterSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const NodeFilterSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(nodeFilterProvider);
    void set(NodeFilter v) => ref.read(nodeFilterProvider.notifier).state = v;
    final mirror = ref.watch(mirrorActiveProvider);

    Widget label(String t) => Padding(
      padding: const EdgeInsets.only(top: Tokens.s16, bottom: Tokens.s8),
      child: Text(t, style: Theme.of(context).textTheme.titleSmall),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Tokens.s16,
          0,
          Tokens.s16,
          Tokens.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label('Сортировка'),
            Wrap(
              spacing: Tokens.s8,
              children: [
                for (final (s, t) in const [
                  (NodeSort.lastHeard, 'по времени'),
                  (NodeSort.name, 'по имени'),
                  (NodeSort.snr, 'по SNR'),
                  (NodeSort.hops, 'по хопам'),
                ])
                  ChoiceChip(
                    label: Text(t),
                    selected: f.sort == s,
                    onSelected: (_) => set(f.copyWith(sort: s)),
                  ),
              ],
            ),
            label('Слышали'),
            Wrap(
              spacing: Tokens.s8,
              children: [
                for (final (h, t) in const [
                  (1, 'за час'),
                  (2, 'за 2 ч'),
                  (24, 'за сутки'),
                  (168, 'за 7 дней'),
                  (null, 'за всё время'),
                ])
                  ChoiceChip(
                    label: Text(t),
                    selected: f.onlineHours == h,
                    onSelected: (_) => set(f.copyWith(onlineHours: () => h)),
                  ),
              ],
            ),
            label('Хопов не больше'),
            Wrap(
              spacing: Tokens.s8,
              children: [
                for (final h in const [null, 0, 1, 2, 3])
                  ChoiceChip(
                    label: Text(
                      h == null
                          ? 'любое'
                          : h == 0
                          ? 'напрямую'
                          : '$h',
                    ),
                    selected: f.maxHops == h,
                    onSelected: (_) => set(f.copyWith(maxHops: () => h)),
                  ),
              ],
            ),
            if (mirror) ...[
              label('Источник'),
              Wrap(
                spacing: Tokens.s8,
                children: [
                  for (final (s, t) in const [
                    (NodeSource.all, 'все'),
                    (NodeSource.radio, 'эфир'),
                    (NodeSource.mirror, 'зеркало'),
                  ])
                    ChoiceChip(
                      label: Text(t),
                      selected: f.source == s,
                      onSelected: (_) => set(f.copyWith(source: s)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: Tokens.s8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Только избранные'),
              value: f.favoritesOnly,
              onChanged: (v) => set(f.copyWith(favoritesOnly: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Скрыть ноды через MQTT'),
              value: f.hideMqtt,
              onChanged: (v) => set(f.copyWith(hideMqtt: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Показывать игнорируемые'),
              value: f.showIgnored,
              onChanged: (v) => set(f.copyWith(showIgnored: v)),
            ),
            if (f.active)
              TextButton(
                onPressed: () => set(NodeFilter(query: f.query, sort: f.sort)),
                child: const Text('Сбросить фильтры'),
              ),
          ],
        ),
      ),
    );
  }
}
