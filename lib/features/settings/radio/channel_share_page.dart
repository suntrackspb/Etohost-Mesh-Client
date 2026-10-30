import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/toasts.dart';
import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../data/database.dart';
import '../../../data/node_actions.dart';
import '../../../data/settings/channel_url.dart';
import '../../nodes/contact_import_ui.dart';
import '../../../ui/kit/kit.dart';
import '../../../app/link_badge.dart';

String _channelName(MeshChannel c, String preset) => c.name.isNotEmpty
    ? c.name
    : c.role == 1
    ? preset
    : 'Channel ${c.index}';

List<MeshChannel> _active(WidgetRef ref) =>
    (ref.watch(channelsProvider).value ?? const <MeshChannel>[])
        .where((c) => c.role > 0)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));

/// «Поделиться QR-кодом» (ShareChannels.swift, iOS): выбор каналов, режим
/// замены или добавления, QR и ссылка.
class ChannelSharePage extends ConsumerStatefulWidget {
  const ChannelSharePage({super.key});

  @override
  ConsumerState<ChannelSharePage> createState() => _ChannelSharePageState();
}

class _ChannelSharePageState extends ConsumerState<ChannelSharePage> {
  Set<int>? _include;
  bool _replace = true;

  @override
  Widget build(BuildContext context) {
    final rows = _active(ref);
    final preset = ref.watch(presetNameProvider).value ?? 'LongFast';
    final lora = ref.watch(configProvider('lora')).value?.lora;
    final include = _include ??= {for (final c in rows) c.index};
    final set = ChannelImport.share(rows, include, lora);
    final url = set.settings.isEmpty
        ? null
        : ChannelLink.encode(set, add: !_replace);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.shareQrCode_6584cb),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            title: context.l10n.include_66be7e,
            children: [
              for (final c in rows)
                CheckboxListTile(
                  title: Text(_channelName(c, preset)),
                  value: include.contains(c.index),
                  onChanged: (v) => setState(
                    () => v == true
                        ? include.add(c.index)
                        : include.remove(c.index),
                  ),
                ),
            ],
          ),
          SectionCard(
            children: [
              SwitchListTile(
                title: Text(context.l10n.replaceChannels_d0b4ac),
                subtitle: Text(
                  _replace
                      ? context.l10n.thisQrCodeContainsAFull_84c455
                      : context.l10n.channelsWillBeAddedExistingChannels_dfb994,
                ),
                value: _replace,
                onChanged: (v) => setState(() => _replace = v),
              ),
            ],
          ),
          if (url != null) ...[
            Center(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(Tokens.s16),
                child: QrImageView(data: url, size: 260),
              ),
            ),
            const SizedBox(height: Tokens.s16),
            SelectableText(url, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Tokens.s8),
            OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              label: Text(context.l10n.copy_4a05d8),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (context.mounted) {
                  toasts.success(context.l10n.copied_892254);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Импорт каналов по ссылке (SaveChannelQRCode.swift, iOS).
class ChannelImportPage extends ConsumerStatefulWidget {
  const ChannelImportPage({super.key, this.initial});

  final String? initial;

  @override
  ConsumerState<ChannelImportPage> createState() => _ChannelImportPageState();
}

class _ChannelImportPageState extends ConsumerState<ChannelImportPage> {
  late final _text = TextEditingController(text: widget.initial ?? '');
  bool? _add;
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = ref.watch(canSendProvider);
    final rows = ref.watch(channelsProvider).value ?? const <MeshChannel>[];
    final lora = ref.watch(configProvider('lora')).value?.lora;

    ChannelLink? link;
    String? error;
    if (_text.text.trim().isNotEmpty) {
      try {
        link = ChannelLink.parse(_text.text);
      } on FormatException catch (e) {
        error = e.message;
      }
    }
    // Ссылка «только добавить» не несёт LoRa — заменить нельзя.
    final add = link == null ? false : (link.add || (_add ?? link.add));
    final plan = link == null
        ? null
        : ChannelImport.plan(link.set, rows, lora, add: add);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.import_55fd5f),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          if (canScanQr) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(context.l10n.scanSharedChannelsQrCode_e4128b),
              onPressed: () async {
                final text = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => QrScanPage(
                      title: context.l10n.scanSharedChannelsQrCode_e4128b,
                      accept: _isChannelOrContact,
                    ),
                  ),
                );
                // Попалась ссылка контакта — сразу импорт контакта.
                final contact = text == null ? null : parseContactUrl(text);
                if (contact != null) {
                  if (context.mounted) {
                    await showContactImport(context, ref, contact);
                  }
                  return;
                }
                if (text != null && mounted) {
                  setState(() {
                    _text.text = text;
                    _add = null;
                  });
                }
              },
            ),
            const SizedBox(height: Tokens.s16),
          ],
          TextField(
            controller: _text,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: context.l10n.channelUrl_8b64fd,
              hintText: 'https://meshtastic.org/e/#…',
              errorText: error,
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste),
                onPressed: () async {
                  final d = await Clipboard.getData(Clipboard.kTextPlain);
                  if (d?.text != null) {
                    setState(() {
                      _text.text = d!.text!;
                      _add = null;
                    });
                  }
                },
              ),
            ),
            onChanged: (_) => setState(() => _add = null),
          ),
          if (link != null && plan != null) ...[
            const SizedBox(height: Tokens.s16),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(context.l10n.replaceChannels_d0b4ac),
                  enabled: !link.add,
                ),
                ButtonSegment(
                  value: true,
                  label: Text(context.l10n.addChannels_236dd4),
                ),
              ],
              selected: {add},
              onSelectionChanged: (s) => setState(() => _add = s.first),
            ),
            const SizedBox(height: Tokens.s8),
            Text(
              add
                  ? context.l10n.theFollowingChannelsWereFoundIn_c3f485
                  : context.l10n.thisQrCodeContainsAComplete_8382f2,
            ),
            SectionCard(
              children: [
                for (final s in link.set.settings)
                  MeshTile(
                    title: s.name.isEmpty
                        ? context.l10n.default_0d558f
                        : s.name,
                    trailing: Icon(
                      s.psk.length > 1 ? Icons.lock : Icons.lock_open,
                      size: 18,
                    ),
                  ),
              ],
            ),
            if (plan.ok)
              Text(
                '${plan.usedSlots} of ${ChannelImport.maxSlots} '
                'channel slots will be used',
              ),
            if (!plan.ok) WarningNote(plan.error!),
            const SizedBox(height: Tokens.s16),
            FilledButton(
              onPressed: !plan.ok || !canSend || _saving
                  ? null
                  : () => _import(plan, add),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.save_486405),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _import(ChannelImportPlan plan, bool add) async {
    final strings = context.l10n;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          add ? strings.addChannels_236dd4 : strings.replaceChannels_d0b4ac,
        ),
        content: Text(
          add
              ? strings.channelsWillBeAddedToThe_32e8d4
              : strings.channelsAndLoraSettingsOnThe_31a15a,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(strings.cancel_0ec753),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(strings.confirm_846aff),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    setState(() => _saving = true);
    final ok = await ChannelImport.apply(
      ref.read(adminSettingsProvider),
      ref.read(databaseProvider),
      plan,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    toasts.show(
      ok
          ? strings.channelsSaved_dbb2d3
          : strings.notAcknowledgedByTheNode_90929d,
      kind: ok ? ToastKind.success : ToastKind.error,
    );
    if (ok) Navigator.of(context).pop();
  }
}

bool _isChannelOrContact(String text) {
  if (parseContactUrl(text) != null) return true;
  try {
    ChannelLink.parse(text);
    return true;
  } on FormatException {
    return false;
  }
}
