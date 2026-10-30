import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/toasts.dart';
import '../../app/diagnostics_providers.dart';
import '../../ui/kit/kit.dart';
import '../../app/link_badge.dart';

/// «Отправить отчёт»: что уходит и чего нет, предпросмотр, комментарий,
/// после отправки — номер отчёта для связи с разработчиком.
class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final _comment = TextEditingController();
  final _contact = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(reportFlowProvider);
    final configured = ref.watch(reportUploaderProvider) != null;
    final report = flow.report;
    final theme = Theme.of(context);

    if (flow.stage == ReportStage.sent) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.reportSent_4eb02c),
          actions: const [LinkBadge()],
        ),
        body: _SentView(id: flow.reportId!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.sendReport_63b6fb),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            title: context.l10n.whatWillBeSent_e8db1a,
            children: [
              _Bullets([
                _Bullet(
                  context.l10n.applicationVersionPhoneModelOsVersion_3c056a,
                ),
                _Bullet(context.l10n.ownNodeIdModelFirmwareRole_2fdfaf),
                _Bullet(context.l10n.connectionStatusTransportBleNameOr_ccaddd),
                _Bullet(
                  context
                      .l10n
                      .applicationLogFromRecentLaunchesConnection_a484f1,
                ),
                _Bullet(context.l10n.yourCommentAndContactDetailsIf_7eb17d),
              ]),
            ],
          ),
          SectionCard(
            title: context.l10n.whatIsNotSent_7dd3f5,
            children: [
              _Bullets([
                _Bullet(context.l10n.messageTextTheLogContainsOnly_d95f22),
                _Bullet(context.l10n.coordinatesOfEitherThePhoneOr_6668dd),
                _Bullet(context.l10n.encryptionKeysPsksAndChannelNames_cfa888),
                _Bullet(context.l10n.mirrorAddressAndData_e46280),
              ]),
            ],
          ),
          SectionCard(
            title: context.l10n.preview_5d092c,
            children: [
              if (report == null)
                const Padding(
                  padding: EdgeInsets.all(Tokens.s16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.all(Tokens.s16),
                  child: SelectableText(
                    report.describe(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                MeshTile(
                  title: context.l10n.journal_67ade7,
                  subtitle: context.l10n.linesKb_94885c(
                    (report.logLines).toString(),
                    ((report.log.length / 1024).toStringAsFixed(0)).toString(),
                  ),
                  leading: const Icon(Icons.description_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _LogView(log: report.log),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Tokens.s16),
          TextField(
            controller: _comment,
            minLines: 3,
            maxLines: 8,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: context.l10n.whatHappened_81dc9f,
              hintText: context.l10n.whatYouDidWhatYouExpected_81e7ad,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: Tokens.s8),
          TextField(
            controller: _contact,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: context.l10n.contactOptional_309ca4,
              hintText: context.l10n.telegramOrEmailIfYouWould_8f673d,
              border: OutlineInputBorder(),
            ),
          ),
          if (flow.error != null) ...[
            const SizedBox(height: Tokens.s8),
            Text(
              context.l10n.error_8f7267((flow.error).toString()),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          if (!configured) ...[
            const SizedBox(height: Tokens.s8),
            Text(
              context.l10n.reportsAreSentThroughTheConnected_ceda96,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: Tokens.s16),
          FilledButton.icon(
            onPressed: flow.canSend
                ? () =>
                      flow.send(comment: _comment.text, contact: _contact.text)
                : null,
            icon: flow.stage == ReportStage.sending
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(context.l10n.send_76dcf7),
          ),
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);
  final List<Widget> items;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Tokens.s8),
    child: Column(children: items),
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: Tokens.s16,
      vertical: Tokens.s4,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _SentView extends StatelessWidget {
  const _SentView({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: Tokens.s16),
            Text(context.l10n.reportNumber_a2f60b),
            const SizedBox(height: Tokens.s8),
            SelectableText(
              id,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Tokens.s16),
            Text(
              context.l10n.giveThisNumberToTheDeveloper_53370d,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Tokens.s16),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: id));
                toasts.success(context.l10n.numberCopied_875e81);
              },
              icon: const Icon(Icons.copy),
              label: Text(context.l10n.copyNumber_82ae50),
            ),
          ],
        ),
      ),
    );
  }
}

/// Журнал целиком — как он уйдёт на сервер.
class _LogView extends StatelessWidget {
  const _LogView({required this.log});
  final String log;

  @override
  Widget build(BuildContext context) {
    final lines = log.split('\n');
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.reportLog_c75086),
        actions: const [LinkBadge()],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(Tokens.s8),
        itemCount: lines.length,
        itemBuilder: (_, i) => Text(lines[i], style: style),
      ),
    );
  }
}
