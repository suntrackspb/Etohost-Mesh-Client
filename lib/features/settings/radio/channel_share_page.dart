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
        title: const Text('Поделиться QR-кодом'),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            title: 'Включить',
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
                title: const Text('Заменить каналы'),
                subtitle: Text(
                  _replace
                      ? 'Этот QR-код содержит полную конфигурацию. Это заменит '
                            'ваши существующие каналы и настройки радио.'
                      : 'Каналы будут добавлены; существующие каналы и '
                            'настройки LoRa сохранятся.',
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
              label: const Text('Копировать'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (context.mounted) {
                  toasts.success('Скопировано');
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
        title: const Text('Импортировать'),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          if (canScanQr) ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Сканировать QR-код общих каналов'),
              onPressed: () async {
                final text = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => QrScanPage(
                      title: 'Сканировать QR-код общих каналов',
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
              labelText: 'URL канала',
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
                  label: const Text('Заменить каналы'),
                  enabled: !link.add,
                ),
                const ButtonSegment(
                  value: true,
                  label: Text('Добавить каналы'),
                ),
              ],
              selected: {add},
              onSelectionChanged: (s) => setState(() => _add = s.first),
            ),
            const SizedBox(height: Tokens.s8),
            Text(
              add
                  ? 'В QR-коде были найдены следующие каналы. Существующие '
                        'каналы будут сохранены.'
                  : 'Этот QR-код содержит полную конфигурацию. Это заменит '
                        'ваши существующие каналы и настройки радио. Все '
                        'существующие каналы будут удалены.',
            ),
            SectionCard(
              children: [
                for (final s in link.set.settings)
                  MeshTile(
                    title: s.name.isEmpty ? 'по умолчанию' : s.name,
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
                  : const Text('Сохранить'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _import(ChannelImportPlan plan, bool add) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(add ? 'Добавить каналы' : 'Заменить каналы'),
        content: Text(
          add
              ? 'Каналы будут добавлены на ноду.'
              : 'Каналы и настройки LoRa на ноде будут заменены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Подтверждение'),
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
      ok ? 'Каналы сохранены' : 'Нода не подтвердила',
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
