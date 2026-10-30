import 'package:meshex/l10n/l10n.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/link_badge.dart';
import '../../app/toasts.dart';
import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/hardware_catalog.dart';
import '../../data/node_actions.dart';
import '../../data/node_row_info.dart';
import '../../ui/kit/kit.dart';
import 'node_actions_ui.dart';

/// mobile_scanner есть только на Android, iOS и macOS.
final canScanQr = Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

/// «Добавить контакт»: сканировать QR или вставить ссылку.
Future<void> showAddContact(BuildContext context, WidgetRef ref) async {
  final strings = context.l10n;
  final how = await showModalBottomSheet<String>(
    context: context,
    builder: (c) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canScanQr)
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(strings.scanQr_ba92dd),
              onTap: () => Navigator.pop(c, 'scan'),
            ),
          ListTile(
            leading: const Icon(Icons.link),
            title: Text(strings.insertLink_ab6720),
            onTap: () => Navigator.pop(c, 'paste'),
          ),
        ],
      ),
    ),
  );
  if (how == null || !context.mounted) return;
  final text = how == 'scan'
      ? await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => QrScanPage(
              title: strings.scanContact_be9772,
              accept: (t) => parseContactUrl(t) != null,
            ),
          ),
        )
      : await _askLink(context);
  if (text == null || !context.mounted) return;
  final c = parseContactUrl(text);
  if (c == null) {
    toasts.show(strings.thisIsNotAContactLink_e1159c);
    return;
  }
  await showContactImport(context, ref, c);
}

Future<String?> _askLink(BuildContext context) async {
  final strings = context.l10n;
  final clip = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
  final ctl = TextEditingController(
    text: parseContactUrl(clip) != null ? clip.trim() : '',
  );
  if (!context.mounted) return null;
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(strings.contactLink_3b3d44),
      content: TextField(
        controller: ctl,
        autofocus: true,
        maxLines: 3,
        minLines: 1,
        decoration: const InputDecoration(
          hintText: 'https://meshtastic.org/v/#…',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: Text(strings.cancel_0ec753),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, ctl.text),
          child: Text(strings.next_9c714c),
        ),
      ],
    ),
  );
}

/// «Импортировать контакт?» — подписи как в Android-клиенте.
Future<void> showContactImport(
  BuildContext context,
  WidgetRef ref,
  SharedContact c,
) async {
  final strings = context.l10n;
  final db = ref.read(databaseProvider);
  final existing = await (db.select(
    db.nodes,
  )..where((n) => n.num.equals(c.nodeNum))).getSingleOrNull();
  if (!context.mounted) return;
  final check = contactImportCheck(c, existing);
  final u = c.user;
  final go = await showDialog<bool>(
    context: context,
    builder: (d) => Consumer(
      builder: (d, ref, _) {
        final ready = ref.watch(canSendProvider);
        final error = TextStyle(color: Theme.of(d).colorScheme.error);
        return AlertDialog(
          title: Text(strings.importSharedContact_5e5c66),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (check.blocked) ...[
                  Text(strings.thisContactHasNoPublicKey_1b1efe, style: error),
                  const Divider(),
                ],
                if (check.known) ...[
                  Text(strings.warningThisContactIsKnownImporting_555efb),
                  if (check.keyChanged)
                    Text(strings.publicKeyChanged_999a04, style: error),
                  const Divider(),
                ],
                for (final (k, v) in [
                  (strings.name_aee78f, u.longName),
                  (strings.shortName_58073d, u.shortName),
                  ('ID', nodeIdOf(c.nodeNum)),
                  (strings.model_f1f1ee, hardwareName(u.hwModel.value)),
                  (strings.role_ab51a3, roleName(u.role.value)),
                ])
                  if (v.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: Tokens.s4),
                      child: Text('$k: $v'),
                    ),
                if (!ready && !check.blocked) ...[
                  const SizedBox(height: Tokens.s12),
                  Text(strings.connectToANodeToImport_c0f2ca, style: error),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text(
                check.blocked ? strings.close_4ae50d : strings.cancel_0ec753,
              ),
            ),
            if (!check.blocked)
              FilledButton(
                onPressed: ready ? () => Navigator.pop(d, true) : null,
                child: Text(strings.import_55fd5f),
              ),
          ],
        );
      },
    ),
  );
  if (go != true || !context.mounted) return;
  await runNodeAction(
    context,
    () => ref.read(nodeActionsProvider).importContact(c),
    strings.contactImported_0f4d2f,
  );
}

/// Сканер QR: возвращает текст первого кода, который принял [accept].
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key, required this.title, required this.accept});

  final String title;
  final bool Function(String text) accept;

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final b in capture.barcodes) {
      final text = b.rawValue;
      if (text == null || !widget.accept(text)) continue;
      _done = true;
      Navigator.of(context).pop(text);
      return;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title), actions: const [LinkBadge()]),
    body: MobileScanner(
      controller: _controller,
      onDetect: _onDetect,
      errorBuilder: (context, error) => EmptyState(
        icon: Icons.no_photography_outlined,
        text: context.l10n.cameraUnavailable_6012f0(
          (error.errorCode.name).toString(),
        ),
      ),
    ),
  );
}
