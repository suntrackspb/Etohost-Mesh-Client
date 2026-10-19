import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../core/update/update_checker.dart';
import '../../data/database.dart';
import '../../ui/kit/kit.dart';

/// Плашка «вышла новая версия» (пока пользователь её не скрыл).
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(updateBadgeProvider);
    if (r == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: Tokens.s16),
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.system_update, color: scheme.onPrimaryContainer),
                const SizedBox(width: Tokens.s8),
                Expanded(
                  child: Text(
                    'Вышла версия ${r.version}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (r.notes.trim().isNotEmpty) ...[
              const SizedBox(height: Tokens.s8),
              Text(
                r.notes.trim(),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: Tokens.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => ref
                      .read(databaseProvider)
                      .setSetting(AppSettingKeys.updateDismissed, r.version),
                  child: const Text('Не напоминать'),
                ),
                const SizedBox(width: Tokens.s8),
                FilledButton(
                  onPressed: () => openRelease(r),
                  child: const Text('Скачать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openRelease(AppRelease r) =>
    launchUrl(r.url, mode: LaunchMode.externalApplication);

/// «О приложении»: версия, ручная проверка, автопроверка.
class AboutSection extends ConsumerStatefulWidget {
  const AboutSection({super.key});

  @override
  ConsumerState<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends ConsumerState<AboutSection> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final r = await checkForUpdate(await ref.read(appVersionProvider.future));
      if (!mounted) return;
      if (r == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Установлена последняя версия')),
        );
      } else {
        // Ручная проверка снимает «не напоминать» и показывает плашку.
        await ref
            .read(databaseProvider)
            .setSetting(AppSettingKeys.updateDismissed, '');
        ref.invalidate(latestReleaseProvider);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Доступна версия ${r.version}'),
            action: SnackBarAction(
              label: 'Скачать',
              onPressed: () => openRelease(r),
            ),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Не удалось проверить: $e')),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = ref.watch(appVersionProvider).value ?? '…';
    final auto = ref.watch(updateAutoCheckProvider).value ?? true;
    return SectionCard(
      title: 'О приложении',
      children: [
        MeshTile(
          title: 'Версия',
          leading: const Icon(Icons.info_outline),
          trailing: Text(version),
        ),
        MeshTile(
          title: 'Проверить обновления',
          leading: const Icon(Icons.system_update),
          trailing: _checking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: _checking ? null : _check,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.update),
          title: const Text('Проверять при запуске'),
          value: auto,
          onChanged: (v) => ref
              .read(databaseProvider)
              .setSetting(AppSettingKeys.updateAutoCheck, '$v'),
        ),
      ],
    );
  }
}
