import 'dart:convert';

import '../../core/proto/mesh.dart';
import '../database.dart';
import 'channel_url.dart';
import 'device_profile.dart';

/// Что о своей ноде [me] известно приложению — для резервной копии.
Future<ProfileSource> loadProfileSource(AppDatabase db, int me) async {
  final blobs = await db.select(db.configBlobs).get();
  final configs = <String, Config>{};
  final modules = <String, ModuleConfig>{};
  var ringtone = '';
  var canned = '';
  for (final b in blobs) {
    if (b.key.startsWith('config.')) {
      configs[b.key.substring(7)] = Config.fromBuffer(b.data);
    } else if (b.key.startsWith('module.')) {
      modules[b.key.substring(7)] = ModuleConfig.fromBuffer(b.data);
    } else if (b.key == 'ringtone') {
      ringtone = utf8.decode(b.data, allowMalformed: true);
    } else if (b.key == 'cannedMessages') {
      canned = utf8.decode(b.data, allowMalformed: true);
    }
  }
  final node = await (db.select(
    db.nodes,
  )..where((n) => n.num.equals(me))).getSingleOrNull();
  final channels = await db.watchChannels().first;
  final lora = configs['lora']?.lora;
  final set = ChannelImport.share(channels, {
    for (final c in channels) c.index,
  }, lora);
  Position? fixed;
  if (node?.latitude != null && node?.longitude != null) {
    fixed = Position(
      latitudeI: (node!.latitude! * 1e7).round(),
      longitudeI: (node.longitude! * 1e7).round(),
      altitude: node.altitude ?? 0,
    );
  }
  return ProfileSource(
    longName: node?.longName,
    shortName: node?.shortName,
    isUnmessagable: node?.isUnmessagable ?? false,
    configs: configs,
    modules: modules,
    channelUrl: set.settings.isEmpty || lora == null
        ? null
        : ChannelLink.encode(set),
    fixed: fixed,
    ringtone: ringtone,
    cannedMessages: canned,
  );
}
