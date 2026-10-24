import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/toasts.dart';
import '../../core/geo/geo.dart';
import '../../data/hardware_catalog.dart';
import '../../data/node_actions.dart';
import '../../data/node_details.dart';
import '../../data/node_row_info.dart';
import '../map/map_tiles.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/message_sender.dart';
import '../chat/chat_page.dart';
import '../../ui/kit/kit.dart';
import 'node_actions_ui.dart';
import 'telemetry_ui.dart';
import 'traceroute_ui.dart';
import 'nodes_page.dart';
import '../../app/link_badge.dart';

/// Одна нода по номеру.
final nodeProvider = StreamProvider.family<Node?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.nodes,
  )..where((n) => n.num.equals(id))).watchSingleOrNull();
});

/// Карточка ноды: шапка, действия, сведения, позиция, трассировки, удаление.
class NodeDetailPage extends ConsumerWidget {
  const NodeDetailPage({super.key, required this.num, this.standalone = false});

  final int num;

  /// Открыта отдельным экраном (узкая раскладка) — нужен AppBar с «назад».
  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(nodeProvider(num));
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    final own = me == null ? null : ref.watch(nodeProvider(me)).value;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: standalone,
        title: Text(
          node.value?.longName.isNotEmpty == true
              ? node.value!.longName
              : nodeIdString(num),
        ),
        actions: const [LinkBadge()],
      ),
      body: node.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.error_outline, text: '$e'),
        data: (n) {
          if (n == null) {
            return const EmptyState(
              icon: Icons.help_outline,
              text: 'Нода не найдена',
            );
          }
          final isMe = n.num == me;
          if (!isMe && n.onMirror && n.firmwareVersion == null) {
            ref.watch(mirrorNodeDetailProvider(n.num));
          }
          final block = directBlock(n);
          return ListView(
            padding: const EdgeInsets.all(Tokens.s16),
            children: [
              _Header(n),
              if (n.newPublicKey != null) const _KeyMismatch(),
              const SizedBox(height: Tokens.s8),
              if (isMe)
                OwnNodeActionsCard(n)
              else
                NodeActionsCard(
                  n,
                  onWrite:
                      block == null ||
                          (ref.watch(hasDirectChatProvider(n.num)).value ??
                              false)
                      ? () => context.go(
                          ChatPage.location(DirectTarget(n.num).id),
                        )
                      : null,
                ),
              _BoardCard(n.hwModel),
              _DetailsCard(n),
              TracerouteCard(n.num),
              if (hasPosition(n)) _PositionCard(n, isMe ? null : own),
              TelemetrySection(n),
              _NoteCard(n.num),
              if (!isMe) DeleteNodeButton(n),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.n);

  final Node n;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final heard = [
      if (n.lastHeard != null) lastHeardText(n.lastHeard!),
      if (n.hopsAway != null)
        n.hopsAway == 0 ? 'напрямую' : 'хопов: ${n.hopsAway}',
      if (n.viaMqtt) 'MQTT',
    ].join(' · ');
    return Row(
      children: [
        NodeAvatar(nodeNum: n.num, shortName: n.shortName, size: 64),
        const SizedBox(width: Tokens.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n.longName.isEmpty ? nodeIdString(n.num) : n.longName,
                style: t.titleLarge,
              ),
              SelectableText(
                '${n.shortName}  ${nodeIdString(n.num)}',
                style: t.bodyMedium,
              ),
              if (heard.isNotEmpty) Text(heard, style: t.bodySmall),
            ],
          ),
        ),
        if (n.isFavorite) const Icon(Icons.star, color: Colors.amber),
      ],
    );
  }
}

/// Сведения сеткой в две колонки.
class _DetailsCard extends StatelessWidget {
  const _DetailsCard(this.n);

  final Node n;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('Роль', roleTitle(n.role)),
      ('Модель', hardwareName(n.hwModel)),
      ('Номер', '${n.num}'),
      if (n.firmwareVersion != null) ('Прошивка', n.firmwareVersion!),
      if (n.firstHeard != null)
        ('Первое обнаружение', lastHeardText(n.firstHeard!)),
      if (n.lastHeard != null) ('Слышали', lastHeardText(n.lastHeard!)),
      if (n.hopsAway != null) ('Хопов', '${n.hopsAway}'),
      if (n.snr != null)
        (
          'SNR',
          '${n.snr!.toStringAsFixed(1)} дБ, ${qualityText(snrQuality(n.snr!, n.modemPreset))}',
        ),
      if (n.rssi != null) ('RSSI', '${n.rssi} дБм'),
      if (n.uptimeSeconds != null) ('Аптайм', uptimeText(n.uptimeSeconds!)),
      if (n.batteryLevel != null)
        (
          'Батарея',
          [
            n.batteryLevel! > 100 ? 'от сети' : '${n.batteryLevel}%',
            if (n.voltage != null) '${n.voltage!.toStringAsFixed(2)} В',
          ].join(', '),
        ),
      if (n.channelUtilization != null)
        ('ChUtil', '${n.channelUtilization!.toStringAsFixed(1)}%'),
      if (n.airUtilTx != null)
        ('AirUtil', '${n.airUtilTx!.toStringAsFixed(1)}%'),
      if (n.modemPreset != null) ('Пресет', n.modemPreset!),
      ('Источник', nodeSourceText(n)),
      ('Шифрование', n.publicKey?.isNotEmpty == true ? 'PKI' : 'нет ключа'),
      if (n.hasXeddsaSigned) ('Подпись', 'XEdDSA'),
      if (n.isUnmessagable) ('Сообщения', 'Неконтролируемый'),
    ];
    final key = n.publicKey;
    return SectionCard(
      title: 'Сведения',
      children: [
        InfoGrid([for (final (k, v) in items) (k, v, null)]),
        if (key != null && key.isNotEmpty)
          MeshTile(
            title: 'Публичный ключ',
            subtitle: base64Encode(key),
            trailing: IconButton(
              tooltip: 'Скопировать',
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: base64Encode(key)));
                toasts.show('Ключ скопирован');
              },
            ),
          ),
      ],
    );
  }
}

/// Мини-карта, координаты, расстояние и азимут от своей ноды.
class _PositionCard extends StatelessWidget {
  const _PositionCard(this.n, this.own);

  final Node n;

  /// Своя нода — для расстояния; null — не считаем.
  final Node? own;

  @override
  Widget build(BuildContext context) {
    final p = LatLng(n.latitude!, n.longitude!);
    final coords =
        '${n.latitude!.toStringAsFixed(5)}, ${n.longitude!.toStringAsFixed(5)}';
    final o = own;
    final from = o != null && hasPosition(o)
        ? (lat: o.latitude!, lon: o.longitude!)
        : null;
    final to = (lat: n.latitude!, lon: n.longitude!);
    return SectionCard(
      title: 'Позиция',
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Tokens.s8),
          child: SizedBox(
            height: 160,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: p,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                const OsmTiles(),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: p,
                      width: 32,
                      height: 32,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_pin,
                        size: 32,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const OsmAttribution(compact: true),
              ],
            ),
          ),
        ),
        MeshTile(
          title: coords,
          subtitle: n.altitude != null ? 'высота ${n.altitude} м' : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Открыть в Картах',
                icon: const Icon(Icons.map_outlined),
                onPressed: () => launchUrl(
                  Uri.parse(
                    'https://maps.apple.com/?q=${p.latitude},${p.longitude}',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              IconButton(
                tooltip: 'Скопировать',
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: coords));
                  toasts.show('Координаты скопированы');
                },
              ),
            ],
          ),
        ),
        if (from != null)
          MeshTile(
            title: 'От своей ноды',
            trailing: Text(
              '${distanceText(distanceKm(from, to))}, '
              '${bearingText(bearingDeg(from, to))}',
            ),
          ),
      ],
    );
  }
}

/// Личная заметка о ноде: видна только на этом устройстве.
class _NoteCard extends ConsumerWidget {
  const _NoteCard(this.num);

  final int num;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(nodeNoteProvider(num)).value ?? '';
    return SectionCard(
      title: 'Заметка',
      children: [
        MeshTile(
          title: note.isEmpty ? 'Добавить заметку' : note,
          subtitle: note.isEmpty ? 'Видна только вам' : null,
          trailing: const Icon(Icons.edit_outlined),
          onTap: () async {
            final c = TextEditingController(text: note);
            final v = await showDialog<String>(
              context: context,
              builder: (d) => AlertDialog(
                title: const Text('Заметка'),
                content: TextField(
                  controller: c,
                  autofocus: true,
                  minLines: 1,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(d),
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(d, c.text),
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            );
            c.dispose();
            if (v != null) {
              await saveSetting(
                ref,
                AppSettingKeys.nodeNote(num),
                normalizeNote(v),
              );
            }
          },
        ),
      ],
    );
  }
}

/// Плата из справочника: картинка (или иконка), название, уровень поддержки.
class _BoardCard extends StatelessWidget {
  const _BoardCard(this.hwModel);

  final int hwModel;

  @override
  Widget build(BuildContext context) {
    final info = hardwareInfo(hwModel);
    if (info == null) return const SizedBox.shrink();
    final assets = hardwareImageAssets(hwModel);
    final t = Theme.of(context).textTheme;
    return SectionCard(
      title: hardwareSectionTitle(hwModel, info),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Tokens.s16,
            vertical: Tokens.s8,
          ),
          child: Row(
            children: [
              if (assets.isEmpty)
                SizedBox(
                  width: 112,
                  height: 64,
                  child: Icon(
                    Icons.developer_board,
                    size: 56,
                    color: Theme.of(context).disabledColor,
                  ),
                )
              else
                for (final a in assets)
                  SizedBox(
                    width: assets.length == 1 ? 112 : 64,
                    height: 64,
                    child: SvgPicture.asset(a, fit: BoxFit.contain),
                  ),
              const SizedBox(width: Tokens.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name, style: t.titleMedium),
                    const SizedBox(height: Tokens.s4),
                    Text(
                      hardwareDescription(hwModel, info),
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Тексты — из перевода официального iOS.
class _KeyMismatch extends StatelessWidget {
  const _KeyMismatch();

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: Tokens.s16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.key_off, color: error),
          const SizedBox(width: Tokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Несоответствие открытого ключа',
                  style: t.titleMedium?.copyWith(color: error),
                ),
                const SizedBox(height: Tokens.s4),
                Text(
                  'Проверьте, с кем вы общаетесь, сравнив открытые ключи при '
                  'личной встрече или по телефону. Самый последний открытый '
                  'ключ для этой ноды не совпадает с ранее записанным ключом. '
                  'Вы можете удалить ноду и позволить ей снова обменяться '
                  'ключами, если смена ключа произошла из-за сброса настроек '
                  'или другого преднамеренного действия, но это также может '
                  'указывать на более серьезную проблему безопасности.',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
