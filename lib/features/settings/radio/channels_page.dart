import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../core/proto/mesh.dart';
import '../../../data/database.dart';
import '../../../data/settings/channel_edit.dart';
import '../../../data/settings/settings_form.dart';
import '../../../ui/kit/kit.dart';
import 'settings_form_view.dart';

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
      appBar: AppBar(title: const Text(ChannelEdit.title)),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          SectionCard(
            children: [
              for (final c in rows)
                MeshTile(
                  leading: CircleAvatar(child: Text('${c.index}')),
                  title: c.name.isNotEmpty
                      ? c.name
                      : c.role == 1
                      ? preset
                      : 'Channel ${c.index}',
                  subtitle: c.role == 1 ? 'Первичный' : 'Второй',
                  trailing: Icon(
                    (c.psk?.length ?? 0) > 1 ? Icons.lock : Icons.lock_open,
                    size: 18,
                  ),
                  onTap: () => context.go('/settings/channels/${c.index}'),
                ),
              if (free != null)
                MeshTile(
                  leading: const Icon(Icons.add_box_outlined),
                  title: 'Добавить канал',
                  onTap: () => context.go('/settings/channels/$free?new=1'),
                ),
            ],
          ),
        ],
      ),
    );
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
      appBar: AppBar(title: Text('Канал ${widget.index}')),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
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
