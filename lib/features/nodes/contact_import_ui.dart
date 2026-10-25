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
  final how = await showModalBottomSheet<String>(
    context: context,
    builder: (c) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canScanQr)
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Сканировать QR'),
              onTap: () => Navigator.pop(c, 'scan'),
            ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Вставить ссылку'),
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
              title: 'Сканировать контакт',
              accept: (t) => parseContactUrl(t) != null,
            ),
          ),
        )
      : await _askLink(context);
  if (text == null || !context.mounted) return;
  final c = parseContactUrl(text);
  if (c == null) {
    toasts.show('Это не ссылка контакта');
    return;
  }
  await showContactImport(context, ref, c);
}

Future<String?> _askLink(BuildContext context) async {
  final clip = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
  final ctl = TextEditingController(
    text: parseContactUrl(clip) != null ? clip.trim() : '',
  );
  if (!context.mounted) return null;
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Ссылка контакта'),
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
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, ctl.text),
          child: const Text('Далее'),
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
          title: const Text('Импортировать контакт?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (check.blocked) ...[
                  Text(
                    'У этого контакта нет публичного ключа, поэтому его '
                    'нельзя импортировать. Контакт без ключа стирает любой '
                    'ключ, который твоя радиостанция уже хранит для этой '
                    'ноды. Попроси отправителя снова поделиться им, когда '
                    'его нода обменяется ключами.',
                    style: error,
                  ),
                  const Divider(),
                ],
                if (check.known) ...[
                  const Text(
                    'Внимание: Данный контакт уже существует, импорт '
                    'перезапишет ранее известную информацию о нём.',
                  ),
                  if (check.keyChanged)
                    Text('Публичный ключ изменён', style: error),
                  const Divider(),
                ],
                for (final (k, v) in [
                  ('Имя', u.longName),
                  ('Короткое имя', u.shortName),
                  ('ID', nodeIdOf(c.nodeNum)),
                  ('Модель', hardwareName(u.hwModel.value)),
                  ('Роль', roleName(u.role.value)),
                ])
                  if (v.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: Tokens.s4),
                      child: Text('$k: $v'),
                    ),
                if (!ready && !check.blocked) ...[
                  const SizedBox(height: Tokens.s12),
                  Text(
                    'Подключитесь к ноде, чтобы импортировать',
                    style: error,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text(check.blocked ? 'Закрыть' : 'Отмена'),
            ),
            if (!check.blocked)
              FilledButton(
                onPressed: ready ? () => Navigator.pop(d, true) : null,
                child: const Text('Импортировать'),
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
    'Контакт импортирован',
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
        text: 'Камера недоступна: ${error.errorCode.name}',
      ),
    ),
  );
}
