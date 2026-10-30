import 'package:meshex/l10n/l10n.dart';
import '../../core/update/update_checker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/toasts.dart';
import '../../ui/kit/kit.dart';

const _supportUrl = 'https://github.com/$releasesRepo/issues';

Future<void> _openSupport() async {
  try {
    if (await launchUrl(
      Uri.parse(_supportUrl),
      mode: LaunchMode.externalApplication,
    )) {
      return;
    }
  } catch (_) {
    // Адрес остаётся доступным для копирования на экране.
  }
  toasts.error('Не удалось открыть страницу поддержки');
}

/// Встроенные сведения доступны и без подключения к интернету.
class AppInformationPage extends StatelessWidget {
  const AppInformationPage.privacy({super.key}) : privacy = true;
  const AppInformationPage.support({super.key}) : privacy = false;

  final bool privacy;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        privacy
            ? context.l10n.privacyPolicy_4041aa
            : context.l10n.support_6ae569,
      ),
    ),
    body: ListView(
      padding: pagePadding(context),
      children: [
        if (privacy) ...[
          _InformationSection(
            context.l10n.dataOnThisDevice_2ff795,
            context.l10n.meshexIsAClientForMeshtastic_b9497b,
          ),
          _InformationSection(
            context.l10n.permissionsAndPhoneLocation_73702c,
            context.l10n.bluetoothAndTheLocalNetworkConnect_2e6ed6,
          ),
          _InformationSection(
            context.l10n.communityServers_917685,
            context.l10n.connectingToAMirrorIsOptional_975b0b,
          ),
          _InformationSection(
            context.l10n.imagesAndReports_a79f68,
            context.l10n.uploadingAnImageSendsTheFile_5e9db2,
          ),
          _InformationSection(
            context.l10n.diagnosticReports_1eec79,
            context.l10n.reportsAreSentAtYourRequest_7fcca2,
          ),
          _InformationSection(
            context.l10n.mapsAndUpdateChecks_f48d47,
            context.l10n.loadingMapsSendsYourIpAddress_c7eb25,
          ),
          _InformationSection(
            context.l10n.keysAndBackups_9b106e,
            context.l10n.nodeConfigurationsMayContainPrivateKeys_b72311,
          ),
          _InformationSection(
            context.l10n.storageAndDeletion_a10344,
            context.l10n.useDataToClearTheLocal_2715b2,
          ),
        ] else
          _InformationSection(
            context.l10n.contactTheDeveloper_ca5284,
            context.l10n.questionsBugReportsAndPrivacyRequests_5ebcd5,
          ),
        SectionCard(
          title: context.l10n.projectContact_9535fa,
          children: [
            const Padding(
              padding: EdgeInsets.all(Tokens.s16),
              child: SelectableText(_supportUrl),
            ),
            MeshTile(
              title: context.l10n.openGithubSupport_603c75,
              leading: const Icon(Icons.open_in_new),
              onTap: _openSupport,
            ),
          ],
        ),
      ],
    ),
  );
}

class _InformationSection extends StatelessWidget {
  const _InformationSection(this.title, this.text);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: title,
    children: [
      Padding(
        padding: const EdgeInsets.all(Tokens.s16),
        child: SelectableText(text),
      ),
    ],
  );
}
