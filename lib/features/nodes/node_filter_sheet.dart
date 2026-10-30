import 'package:meshex/l10n/l10n.dart';
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
            label(context.l10n.sort_ed0301),
            Wrap(
              spacing: Tokens.s8,
              children: [
                for (final (s, t) in [
                  (NodeSort.lastHeard, context.l10n.byTime_5bad62),
                  (NodeSort.name, context.l10n.byName_21b8bf),
                  (NodeSort.snr, context.l10n.bySnr_f87a18),
                  (NodeSort.hops, context.l10n.byHops_90b84d),
                ])
                  ChoiceChip(
                    label: Text(t),
                    selected: f.sort == s,
                    onSelected: (_) => set(f.copyWith(sort: s)),
                  ),
              ],
            ),
            label(context.l10n.lastHeard_07e526),
            Wrap(
              spacing: Tokens.s8,
              children: [
                for (final (h, t) in [
                  (1, context.l10n.lastHour_5702d4),
                  (2, context.l10n.lastHours_154ae5),
                  (24, context.l10n.lastHours_fee233),
                  (168, context.l10n.lastDays_3f4fcc),
                  (null, context.l10n.allTime_9790a7),
                ])
                  ChoiceChip(
                    label: Text(t),
                    selected: f.onlineHours == h,
                    onSelected: (_) => set(f.copyWith(onlineHours: () => h)),
                  ),
              ],
            ),
            label(context.l10n.maximumHops_a86743),
            Wrap(
              spacing: Tokens.s8,
              children: [
                for (final h in const [null, 0, 1, 2, 3])
                  ChoiceChip(
                    label: Text(
                      h == null
                          ? context.l10n.any_3290bc
                          : h == 0
                          ? context.l10n.direct_95dc0c
                          : '$h',
                    ),
                    selected: f.maxHops == h,
                    onSelected: (_) => set(f.copyWith(maxHops: () => h)),
                  ),
              ],
            ),
            label(context.l10n.roles_265068),
            Wrap(
              spacing: Tokens.s8,
              runSpacing: Tokens.s4,
              children: [
                ChoiceChip(
                  label: Text(context.l10n.all_ef8ff2),
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
              label(context.l10n.source_8290a3),
              Wrap(
                spacing: Tokens.s8,
                children: [
                  for (final (s, t) in [
                    (NodeSource.all, context.l10n.all_ef8ff2),
                    (NodeSource.radio, context.l10n.radio_c9a417),
                    (NodeSource.mirror, context.l10n.mirror_53fbab),
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
              title: Text(context.l10n.favoritesOnly_f1d6dc),
              value: f.favoritesOnly,
              onChanged: (v) => set(f.copyWith(favoritesOnly: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.encryptedOnly_5943ed),
              subtitle: Text(context.l10n.hasPublicKeyPki_b08915),
              value: f.encryptedOnly,
              onChanged: (v) => set(f.copyWith(encryptedOnly: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.signedOnly_a90195),
              subtitle: Text(context.l10n.signPacketsFirmware_c59ca8),
              value: f.signedOnly,
              onChanged: (v) => set(f.copyWith(signedOnly: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.hideNodesViaMqtt_a06257),
              value: f.hideMqtt,
              onChanged: (v) => set(f.copyWith(hideMqtt: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.showIgnoredNodes_48f862),
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
                    child: Text(context.l10n.resetFilters_03ead0),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.done_398c7d),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
