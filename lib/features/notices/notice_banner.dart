import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/notice_providers.dart';
import '../../core/notices/notices.dart';
import '../../ui/kit/kit.dart';

/// Объявления разработчика над списком чатов.
class NoticeBanners extends ConsumerWidget {
  const NoticeBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(visibleNoticesProvider);
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(children: [for (final n in list) _NoticeCard(n)]);
  }
}

class _NoticeCard extends ConsumerWidget {
  const _NoticeCard(this.n);
  final Notice n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (n.level) {
      NoticeLevel.critical => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.error_outline,
      ),
      NoticeLevel.warning => (
        Colors.amber.shade200,
        Colors.black87,
        Icons.warning_amber,
      ),
      NoticeLevel.info => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.campaign_outlined,
      ),
    };
    return Card(
      color: bg,
      margin: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s8, Tokens.s16, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Tokens.s16, Tokens.s12, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: fg),
                const SizedBox(width: Tokens.s12),
                Expanded(
                  child: Text(n.text, style: TextStyle(color: fg)),
                ),
                IconButton(
                  tooltip: context.l10n.close_4ae50d,
                  icon: Icon(Icons.close, color: fg),
                  onPressed: () =>
                      ref.read(noticesProvider.notifier).dismiss(n),
                ),
              ],
            ),
            if (n.linkUrl case final url?)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: fg),
                  onPressed: () =>
                      launchUrl(url, mode: LaunchMode.externalApplication),
                  child: Text(n.linkLabel ?? context.l10n.details_7e4277),
                ),
              )
            else
              const SizedBox(height: Tokens.s12),
          ],
        ),
      ),
    );
  }
}
