import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../data/node_layout.dart';
import '../../ui/kit/kit.dart';
import 'nodes_page.dart';

/// Какие поля показывать в строке ноды; сверху — предпросмотр.
class NodeLayoutSheet extends ConsumerWidget {
  const NodeLayoutSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useRootNavigator: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    builder: (_) => const NodeLayoutSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(nodeLayoutProvider).value ?? const NodeLayout();
    final sample = ref.watch(filteredNodesProvider).value?.firstOrNull;
    void set(NodeLayout l) =>
        saveSetting(ref, AppSettingKeys.nodeLayout, l.encode());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: Tokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tokens.s16),
              child: Text(
                context.l10n.nodeRowLayout_12026b,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (sample != null)
              Card(
                margin: const EdgeInsets.all(Tokens.s16),
                child: NodeTile(node: sample, layout: layout, onTap: () {}),
              ),
            for (final f in NodeRowField.values)
              SwitchListTile(
                title: Text(context.builtIn(f.label)),
                value: layout.shows(f),
                onChanged: (v) => set(layout.toggle(f, v)),
              ),
          ],
        ),
      ),
    );
  }
}
