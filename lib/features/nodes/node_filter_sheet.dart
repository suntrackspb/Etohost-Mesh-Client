import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/node_filter.dart';
import '../../data/node_row_info.dart';
import '../../ui/kit/kit.dart';

/// Панель фильтров списка нод. Состояние — в [nodeFilterProvider].
class NodeFilterSheet extends ConsumerWidget {
  const NodeFilterSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    // Корневой навигатор: из вложенного (вкладка go_router) системное
    // «назад» на Android лист не закрывало.
    useRootNavigator: true,
    useSafeArea: true,
    // Не на весь экран — остаётся полоса, тап по которой закрывает лист.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    builder: (_) => const NodeFilterSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(nodeFilterProvider);
    void set(NodeFilter v) => ref.read(nodeFilterProvider.notifier).state = v;
    final mirror = ref.watch(mirrorActiveProvider);
    final present = {
      for (final n in ref.watch(nodesProvider).value ?? const []) n.role,
    };

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
            label('Роли'),
            Wrap(
              spacing: Tokens.s8,
              runSpacing: Tokens.s4,
              children: [
                ChoiceChip(
                  label: const Text('все'),
                  selected: f.roles.isEmpty,
                  onSelected: (_) => set(f.copyWith(roles: const {})),
                ),
                for (final r in roleChoices({...present, ...f.roles}))
                  FilterChip(
                    label: Text(roleTitle(r)),
                    selected: f.roles.contains(r),
                    onSelected: (on) => set(
                      f.copyWith(
                        roles: on ? {...f.roles, r} : ({...f.roles}..remove(r)),
                      ),
                    ),
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
                    (NodeSource.radio, 'радио'),
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
              title: const Text('Только зашифрованные'),
              subtitle: const Text('Есть публичный ключ (PKI)'),
              value: f.encryptedOnly,
              onChanged: (v) => set(f.copyWith(encryptedOnly: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Только подписанные'),
              subtitle: const Text('Подписывают пакеты (прошивка 2.8)'),
              value: f.signedOnly,
              onChanged: (v) => set(f.copyWith(signedOnly: v)),
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
            const SizedBox(height: Tokens.s8),
            Row(
              children: [
                if (f.active)
                  TextButton(
                    onPressed: () =>
                        set(NodeFilter(query: f.query, sort: f.sort)),
                    child: const Text('Сбросить фильтры'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Готово'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
