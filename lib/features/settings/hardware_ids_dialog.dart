import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/toasts.dart';
import '../../app/providers.dart';
import '../../core/radio/hardware_ids.dart';

/// Окно с MAC и device_id подключённой ноды.
Future<void> showHardwareIds(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const _HardwareIdsDialog(),
);

class _HardwareIdsDialog extends ConsumerWidget {
  const _HardwareIdsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(radioProvider);
    final t = r.target;
    final ids = HardwareIds(
      myInfo: r.myInfo,
      user: r.ownUser,
      metadata: r.metadata,
      transport: t == null
          ? null
          : [t.endpoint?.kind.name, t.title].nonNulls.join(' · '),
    );
    final style = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(context.l10n.nodeHardwareIds_a78041),
      content: r.myInfo == null
          ? Text(context.l10n.connectToANode_6caeff)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (k, v) in ids.rows())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.builtIn(k), style: style.labelSmall),
                          SelectableText(
                            v,
                            style: style.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
      actions: [
        if (r.myInfo != null)
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: ids.asText()));
              toasts.success(context.l10n.copied_892254);
            },
            child: Text(context.l10n.copy_4a05d8),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.close_4ae50d),
        ),
      ],
    );
  }
}
