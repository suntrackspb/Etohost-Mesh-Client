import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/toasts.dart';
import '../../../app/settings_providers.dart';
import '../../../core/proto/mesh.dart';
import '../../../data/database.dart';
import '../../../data/settings/channel_edit.dart';
import '../../../data/settings/settings_form.dart';
import '../../../ui/kit/kit.dart';
import 'settings_form_view.dart';
import '../../../app/link_badge.dart';

/// Список каналов своей ноды (Channels.swift, iOS): 8 слотов, свободный —
/// «Добавить канал».
class ChannelsPage extends ConsumerWidget {
  const ChannelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows =
        (ref.watch(channelsProvider).value ?? const <MeshChannel>[])
            .where((c) => c.role > 0)
            .toList()
          ..sort((a, b) => a.index.compareTo(b.index));
    final preset = ref.watch(presetNameProvider).value ?? 'LongFast';
    final free = ChannelEdit.nextFreeIndex(rows);
    return Scaffold(
      appBar: AppBar(
        title: const Text(ChannelEdit.title),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            children: [
              for (final c in rows) _ChannelTile(c, preset: preset),
              if (free != null)
                MeshTile(
                  leading: const Icon(Icons.add_box_outlined),
                  title: 'Добавить канал',
                  onTap: () => context.go('/settings/channels/$free?new=1'),
                ),
            ],
          ),
          SectionCard(
            children: [
              MeshTile(
                leading: const Icon(Icons.qr_code),
                title: 'Поделиться QR-кодом',
                onTap: () => context.go('/settings/channels/share'),
              ),
              MeshTile(
                leading: const Icon(Icons.download_outlined),
                title: 'Импортировать',
                onTap: () => context.go('/settings/channels/import'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Строка канала: значки позиции, MQTT uplink/downlink и замка, крестик
/// «Удалить» — как ChannelCard в Android.
class _ChannelTile extends ConsumerWidget {
  const _ChannelTile(this.c, {required this.preset});

  final MeshChannel c;
  final String preset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ChannelEdit.settingsOf(c);
    final primary = c.role == Channel_Role.PRIMARY.value;
    final name = c.name.isNotEmpty
        ? c.name
        : primary
        ? preset
        : 'Channel ${c.index}';
    final canSend = ref.watch(canSendProvider);
    Widget icon(IconData i, String tip) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Tooltip(message: tip, child: Icon(i, size: 18)),
    );
    return MeshTile(
      leading: CircleAvatar(child: Text('${c.index}')),
      title: name,
      subtitle: primary ? 'Первичный' : 'Второй',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (s.moduleSettings.positionPrecision > 0)
            icon(Icons.location_on, 'Поделиться местоположением'),
          if (s.uplinkEnabled)
            icon(Icons.cloud_upload_outlined, 'MQTT Uplink включён'),
          if (s.downlinkEnabled)
            icon(Icons.cloud_download_outlined, 'MQTT Downlink включён'),
          icon(
            (c.psk?.length ?? 0) > 1 ? Icons.lock : Icons.lock_open,
            (c.psk?.length ?? 0) > 1 ? 'Зашифрован' : 'Без шифрования',
          ),
          if (!primary)
            IconButton(
              tooltip: 'Удалить',
              icon: const Icon(Icons.close),
              onPressed: canSend ? () => _delete(context, ref, name) : null,
            ),
        ],
      ),
      onTap: () => context.go('/settings/channels/${c.index}'),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String name) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('Удалить канал «$name»?'),
        content: const Text('Канал будет отключен на ноде.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(d).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    final ok = await ChannelEdit.disable(
      ref.read(adminSettingsProvider),
      ref.read(databaseProvider),
      c,
    );
    if (!ok) toasts.error('Нода не подтвердила');
  }
}

/// Редактор канала (ChannelForm.swift, iOS).
class ChannelEditPage extends ConsumerStatefulWidget {
  const ChannelEditPage({super.key, required this.index, this.isNew = false});

  final int index;
  final bool isNew;

  @override
  ConsumerState<ChannelEditPage> createState() => _ChannelEditPageState();
}

class _ChannelEditPageState extends ConsumerState<ChannelEditPage> {
  SettingsForm? _form;
  ChannelSettings? _base;

  SettingsForm _make(MeshChannel? row) {
    if (row == null || widget.isNew) {
      _base = ChannelSettings();
      final v = ChannelEdit.fresh();
      // Новый канал сразу «изменён»: исходно слот отключен (iOS hasChanges).
      return SettingsForm(
        ChannelEdit.fields(),
        {...v, 'role': Channel_Role.DISABLED.value},
        adjust: ChannelEdit.adjust,
        check: ChannelEdit.check,
      )..set('role', Channel_Role.SECONDARY.value);
    }
    _base = ChannelEdit.settingsOf(row);
    return SettingsForm(
      ChannelEdit.fields(),
      ChannelEdit.read(_base!, row.role),
      adjust: ChannelEdit.adjust,
      check: ChannelEdit.check,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(channelsProvider);
    final canSend = ref.watch(canSendProvider);
    if (!rows.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final row = rows.value!.where((c) => c.index == widget.index).firstOrNull;
    final form = _form ??= _make(row);
    return Scaffold(
      appBar: AppBar(
        title: Text('Канал ${widget.index}'),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          AbsorbPointer(
            absorbing: !canSend,
            child: SettingsFormView(form: form),
          ),
          ListenableBuilder(
            listenable: form,
            builder: (context, _) {
              final v = form.values;
              final size = v['keySize']! as int;
              final name = v['name']! as String;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (ChannelEdit.isReserved(name))
                    WarningNote(ChannelEdit.reservedNote(name)),
                  if (size > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: Tokens.s8),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.autorenew),
                        label: const Text('Generate channel key'),
                        onPressed: form.saving || !canSend
                            ? null
                            : () => form.set(
                                'key',
                                ChannelEdit.generateKey(size),
                              ),
                      ),
                    ),
                ],
              );
            },
          ),
          SaveBar(
            form: form,
            confirm: 'Сохранить канал?',
            onSave: () async {
              final admin = ref.read(adminSettingsProvider);
              final db = ref.read(databaseProvider);
              final ok = await form.submit(
                (v, _) => ChannelEdit.save(admin, db, _base!, widget.index, v),
              );
              if (ok && context.mounted) context.pop();
            },
          ),
        ],
      ),
    );
  }
}
