import 'package:meshex/l10n/l10n.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/framed_node_avatar.dart';
import '../../app/providers.dart';
import '../../app/toasts.dart';
import '../../core/geo/geo.dart';
import '../../core/geo/maps_link.dart';
import '../../data/hardware_catalog.dart';
import '../../data/node_actions.dart';
import '../../data/node_position.dart';
import '../../data/node_details.dart';
import '../../data/node_row_info.dart';
import '../map/mesh_map.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/message_sender.dart';
import '../chat/chat_page.dart';
import '../../ui/kit/kit.dart';
import 'node_actions_ui.dart';
import 'node_provider.dart';
import 'compass/compass_controller.dart';
import 'compass/compass_sheet.dart';
import 'telemetry_ui.dart';
import 'traceroute_ui.dart';
import 'nodes_page.dart';
import '../../app/link_badge.dart';

export 'node_provider.dart';

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
            return EmptyState(
              icon: Icons.help_outline,
              text: context.l10n.nodeNotFound_9951e4,
            );
          }
          final isMe = n.num == me;
          if (!isMe && n.onMirror && n.firmwareVersion == null) {
            ref.watch(mirrorNodeDetailProvider(n.num));
          }
          final keyLoad = !isMe && n.onMirror
              ? ref.watch(mirrorNodeKeyProvider(n.num))
              : null;
          final block = directBlock(n);
          final pos = nodePositionBy(n, ref.watch(positionRulesProvider));
          return ListView(
            padding: pagePadding(context),
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
              if (keyLoad?.isLoading == true && block == DirectBlock.noKey)
                MeshTile(title: context.l10n.retrievingKeyFromMirror_8c97ce),
              if (keyLoad?.hasError == true && block == DirectBlock.noKey)
                MeshTile(
                  title: context.l10n.couldNotRetrieveTheKeyFrom_693021,
                  trailing: TextButton(
                    onPressed: () =>
                        ref.invalidate(mirrorNodeKeyProvider(n.num)),
                    child: Text(context.l10n.retry_9e506a),
                  ),
                ),
              _BoardCard(n.hwModel),
              _DetailsCard(n),
              TracerouteCard(n.num),
              if (pos != null) _PositionCard(n, pos, isMe ? null : own),
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
      if (n.lastHeard != null) context.builtIn(lastHeardText(n.lastHeard!)),
      if (n.hopsAway != null)
        n.hopsAway == 0
            ? context.l10n.direct_95dc0c
            : context.l10n.hops_d23d4f((n.hopsAway).toString()),
      if (n.viaMqtt) 'MQTT',
    ].join(' · ');
    return Row(
      children: [
        FramedNodeAvatar(nodeNum: n.num, shortName: n.shortName, size: 64),
        const SizedBox(width: Tokens.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n.longName.isEmpty ? nodeIdString(n.num) : n.longName,
                style: t.titleLarge,
              ),
              Row(
                children: [
                  Flexible(
                    child: SelectableText(
                      nodeIdString(n.num),
                      style: t.bodyMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.copy_ed4950,
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: nodeIdString(n.num)),
                      );
                      if (context.mounted) {
                        toasts.show(context.l10n.copied_892254);
                      }
                    },
                  ),
                ],
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
      (context.l10n.role_ab51a3, roleTitle(n.role)),
      (context.l10n.model_f1f1ee, hardwareName(n.hwModel)),
      (context.l10n.number_1bb3d1, '${n.num}'),
      if (n.firmwareVersion != null)
        (context.l10n.firmware_df1881, n.firmwareVersion!),
      if (n.firstHeard != null)
        (
          context.l10n.firstHeard_fb9dde,
          context.builtIn(lastHeardText(n.firstHeard!)),
        ),
      if (n.lastHeard != null)
        (
          context.l10n.lastHeard_07e526,
          context.builtIn(lastHeardText(n.lastHeard!)),
        ),
      if (n.hopsAway != null) (context.l10n.hops_859d39, '${n.hopsAway}'),
      if (n.snr != null)
        (
          'SNR',
          context.l10n.db_660739(
            (n.snr!.toStringAsFixed(1)).toString(),
            (context.builtIn(
              qualityText(snrQuality(n.snr!, n.modemPreset)),
            )).toString(),
          ),
        ),
      if (n.rssi != null)
        ('RSSI', context.l10n.dbm_aadd53((n.rssi).toString())),
      if (n.uptimeSeconds != null)
        (
          context.l10n.uptime_d0d899,
          context.builtIn(uptimeText(n.uptimeSeconds!)),
        ),
      if (n.batteryLevel != null)
        (
          context.l10n.battery_96a4c3,
          [
            n.batteryLevel! > 100
                ? context.l10n.externalPower_963740
                : '${n.batteryLevel}%',
            if (n.voltage != null)
              context.l10n.v_7e1412((n.voltage!.toStringAsFixed(2)).toString()),
          ].join(', '),
        ),
      if (n.channelUtilization != null)
        ('ChUtil', '${n.channelUtilization!.toStringAsFixed(1)}%'),
      if (n.airUtilTx != null)
        ('AirUtil', '${n.airUtilTx!.toStringAsFixed(1)}%'),
      if (n.modemPreset != null) (context.l10n.preset_a6549e, n.modemPreset!),
      (context.l10n.source_8290a3, context.builtIn(nodeSourceText(n))),
      (
        context.l10n.encryption_72622e,
        n.publicKey?.isNotEmpty == true ? 'PKI' : context.l10n.noKey_edc637,
      ),
      if (n.hasXeddsaSigned) (context.l10n.signature_a5dcf3, 'XEdDSA'),
      if (n.isUnmessagable)
        (context.l10n.messages_019803, context.l10n.unmonitored_0eff12),
    ];
    final key = n.publicKey;
    return SectionCard(
      title: context.l10n.details_99bf04,
      children: [
        InfoGrid([for (final (k, v) in items) (k, v, null)]),
        if (key != null && key.isNotEmpty)
          MeshTile(
            title: context.l10n.publicKey_225a9f,
            subtitle: base64Encode(key),
            trailing: IconButton(
              tooltip: context.l10n.copy_ed4950,
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: base64Encode(key)));
                toasts.show(context.l10n.keyCopied_c184c1);
              },
            ),
          ),
      ],
    );
  }
}

/// Мини-карта, координаты, расстояние и азимут от своей ноды.
class _PositionCard extends StatelessWidget {
  const _PositionCard(this.n, this.pos, this.own);

  final Node n;
  final NodePosition pos;

  /// Своя нода — для расстояния; null — не считаем.
  final Node? own;

  @override
  Widget build(BuildContext context) {
    final p = LatLng(pos.lat, pos.lon);
    final coords =
        '${pos.lat.toStringAsFixed(5)}, ${pos.lon.toStringAsFixed(5)}';
    final o = own;
    final from = o != null && hasPosition(o)
        ? (lat: o.latitude!, lon: o.longitude!)
        : null;
    final to = (lat: pos.lat, lon: pos.lon);
    return SectionCard(
      title: context.l10n.position_c139a7,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Tokens.s8),
          child: SizedBox(
            height: 160,
            child: MeshMap(
              compactAttribution: true,
              options: MapOptions(
                initialCenter: p,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
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
              ],
            ),
          ),
        ),
        MeshTile(
          title: coords,
          subtitle: [
            context.builtInOrNull(positionNote(pos, lastHeardText)) ??
                (!pos.mirror && pos.at == null && n.altitude != null
                    ? context.l10n.altitudeM_dd3a3e((n.altitude).toString())
                    : null),
            context.builtInOrNull(precisionText(pos.precisionBits)),
          ].nonNulls.join(' · ').ifEmptyNull,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: context.l10n.openInMaps_6bb0f2,
                icon: const Icon(Icons.map_outlined),
                onPressed: () => launchUrl(
                  mapsUri(p.latitude, p.longitude, defaultTargetPlatform),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              IconButton(
                tooltip: context.l10n.copy_ed4950,
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: coords));
                  toasts.show(context.l10n.coordinatesCopied_082ae9);
                },
              ),
            ],
          ),
        ),
        if (supportsNodeCompass)
          MeshTile(
            title: context.l10n.compassTitle,
            leading: const Icon(Icons.explore_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showNodeCompass(context, n.num),
          ),
        if (from != null)
          MeshTile(
            title: context.l10n.fromMyNode_336438,
            trailing: Text(
              '${context.builtIn(distanceText(distanceKm(from, to)))}, '
              '${context.bearingLabel(bearingDeg(from, to))}',
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
      title: context.l10n.note_917b58,
      children: [
        MeshTile(
          title: note.isEmpty ? context.l10n.addNote_57d0f4 : note,
          subtitle: note.isEmpty ? context.l10n.visibleOnlyToYou_e71a47 : null,
          trailing: const Icon(Icons.edit_outlined),
          onTap: () async {
            final c = TextEditingController(text: note);
            final v = await showDialog<String>(
              context: context,
              builder: (d) => AlertDialog(
                title: Text(context.l10n.note_917b58),
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
                    child: Text(context.l10n.cancel_0ec753),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(d, c.text),
                    child: Text(context.l10n.save_486405),
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
      title: context.builtIn(hardwareSectionTitle(hwModel, info)),
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
                      context.builtIn(hardwareDescription(hwModel, info)),
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
                  context.l10n.publicKeyMismatch_a6a194,
                  style: t.titleMedium?.copyWith(color: error),
                ),
                const SizedBox(height: Tokens.s4),
                Text(
                  context.l10n.verifyWhoYouAreMessagingWith_690825,
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
