import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/toasts.dart';
import '../../app/providers.dart';
import '../../core/store_build.dart';
import '../../core/update/release_notes.dart';
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
    final notes = ReleaseNotes.parse(r.notes);
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
            if (!notes.isEmpty) ...[
              const SizedBox(height: Tokens.s8),
              Text(notes.summary, maxLines: 4, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: Tokens.s8),
            _DownloadButtons(r),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!notes.isEmpty)
                  TextButton(
                    onPressed: () => showReleaseNotes(context, r, notes),
                    child: const Text('Подробнее'),
                  ),
                TextButton(
                  onPressed: () => ref
                      .read(databaseProvider)
                      .setSetting(AppSettingKeys.updateDismissed, r.version),
                  child: const Text('Не напоминать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Полные заметки к релизу — нижняя панель с прокруткой.
Future<void> showReleaseNotes(
  BuildContext context,
  AppRelease r,
  ReleaseNotes notes,
) {
  final text = Theme.of(context).textTheme;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (ctx, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(
          Tokens.s16,
          0,
          Tokens.s16,
          Tokens.s24,
        ),
        children: [
          Text('Версия ${r.version}', style: text.titleLarge),
          for (final b in notes.blocks)
            switch (b) {
              NotesHeading() => Padding(
                padding: const EdgeInsets.only(top: Tokens.s16),
                child: Text(b.text, style: text.titleMedium),
              ),
              NotesBullet() => Padding(
                padding: const EdgeInsets.only(top: Tokens.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(b.text)),
                  ],
                ),
              ),
              NotesParagraph() => Padding(
                padding: const EdgeInsets.only(top: Tokens.s8),
                child: Text(b.text),
              ),
            },
          const SizedBox(height: Tokens.s16),
          _DownloadButtons(r),
        ],
      ),
    ),
  );
}

Future<void> openRelease(AppRelease r) =>
    launchUrl(r.url, mode: LaunchMode.externalApplication);

/// Официальный сайт — без GitHub, который у части пользователей медленный.
Future<void> openDownloads() =>
    launchUrl(downloadsPage, mode: LaunchMode.externalApplication);

/// «О приложении»: версия, ручная проверка, автопроверка (проверки — не в
/// магазинной сборке).
class AboutSection extends ConsumerStatefulWidget {
  const AboutSection({super.key});

  @override
  ConsumerState<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends ConsumerState<AboutSection> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      final r = await checkForUpdate(await ref.read(appVersionProvider.future));
      if (!mounted) return;
      if (r == null) {
        toasts.show('Установлена последняя версия');
      } else {
        // Ручная проверка снимает «не напоминать» и показывает плашку.
        await ref
            .read(databaseProvider)
            .setSetting(AppSettingKeys.updateDismissed, '');
        ref.invalidate(latestReleaseProvider);
        toasts.show(
          'Доступна версия ${r.version} — нажмите, чтобы скачать',
          onTap: openDownloads,
        );
      }
    } catch (e) {
      toasts.error('Не удалось проверить: $e');
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
        if (!storeBuild) ...[
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
      ],
    );
  }
}

/// Две кнопки скачивания на всю ширину, поровну.
class _DownloadButtons extends StatelessWidget {
  const _DownloadButtons(this.r);

  final AppRelease r;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => openRelease(r),
          child: const Text('С GitHub'),
        ),
      ),
      const SizedBox(width: Tokens.s8),
      Expanded(
        child: FilledButton(
          onPressed: openDownloads,
          child: const Text('С сайта'),
        ),
      ),
    ],
  );
}
