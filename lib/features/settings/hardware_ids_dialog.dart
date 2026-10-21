import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      title: const Text('Аппаратные id ноды'),
      content: r.myInfo == null
          ? const Text('Подключитесь к ноде')
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
                          Text(k, style: style.labelSmall),
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Скопировано')));
            },
            child: const Text('Копировать'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
