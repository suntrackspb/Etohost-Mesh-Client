import 'dart:convert';

import '../../data/database.dart';
import '../../core/proto/mesh.dart';
import '../../data/map_points.dart';
import '../../data/node_actions.dart';
import '../../data/radio_stats.dart';

/// A bounded, versioned contract; never exports keys or raw packets.
Map<String, Object?> widgetSnapshot({
  required List<Node> nodes,
  required List<Message> messages,
  required List<MapPoint> points,
  required bool connected,
  required int? me,
  required RadioStats? stats,
  required int unread,
  required String language,
  required DateTime now,
  TracerouteResult? trace,
  LocalStats? localStats,
}) {
  final visible = nodes.where((n) => !n.isIgnored).toList();
  final byNum = {for (final n in visible) n.num: n};
  String name(int num) {
    final n = byNum[num];
    return n == null
        ? nodeIdOf(num)
        : n.longName.isNotEmpty
        ? n.longName
        : n.shortName.isNotEmpty
        ? n.shortName
        : nodeIdOf(num);
  }

  return {
    'version': 1,
    'updated': now.millisecondsSinceEpoch,
    'language': language,
    'connected': connected,
    'name': me == null ? 'Meshex' : name(me),
    'online': stats?.online ?? 0,
    'total': stats?.onRadio ?? 0,
    'battery': stats?.battery,
    'channel': stats?.channelUtil?.toStringAsFixed(1),
    'airtime': stats?.airUtilTx?.toStringAsFixed(1),
    'unread': unread,
    'tx': localStats?.hasNumPacketsTx() == true
        ? localStats!.numPacketsTx
        : null,
    'rx': localStats?.hasNumPacketsRx() == true
        ? localStats!.numPacketsRx
        : null,
    'dupe': localStats?.hasNumRxDupe() == true ? localStats!.numRxDupe : null,
    'relay': localStats?.hasNumTxRelay() == true
        ? localStats!.numTxRelay
        : null,
    'noise': localStats?.hasNoiseFloor() == true
        ? localStats!.noiseFloor
        : null,
    'uptime': localStats?.hasUptimeSeconds() == true
        ? localStats!.uptimeSeconds
        : null,
    'mapped': points.length,
    'nodes': [
      for (final n in visible.take(1000))
        {
          'num': n.num,
          'name': name(n.num),
          'short': n.shortName,
          'battery': n.batteryLevel,
          'snr': n.snr,
          'heard': n.lastHeard?.millisecondsSinceEpoch,
        },
    ],
    'messages': [
      for (final m in messages.take(5))
        {
          'sender': name(m.fromNum),
          'body': m.body.length > 180 ? '${m.body.substring(0, 180)}…' : m.body,
          'path':
              '/chat/${Uri.encodeComponent(m.toNum == 0xffffffff ? m.channelKey : 'dm:${m.isOutgoing ? m.toNum : m.fromNum}')}',
        },
    ],
    'trace': trace == null
        ? null
        : {
            'path': '/traceroute/${trace.id}',
            'time': trace.time.millisecondsSinceEpoch,
            'summary': trace.towards
                .map(
                  (h) => byNum[h.num]?.shortName.isNotEmpty == true
                      ? byNum[h.num]!.shortName
                      : name(h.num),
                )
                .join(' → '),
            'back': trace.back.map((h) => name(h.num)).join(' → '),
          },
  };
}

String encodeWidgetSnapshot(Map<String, Object?> snapshot) =>
    jsonEncode(snapshot);
