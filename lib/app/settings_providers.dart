import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/proto/mesh.dart';
import '../core/radio/radio_session.dart';
import '../data/database.dart';
import '../data/settings/admin_settings.dart';
import 'providers.dart';

/// Админ-команды настроек своей ноде.
final adminSettingsProvider = Provider<AdminSettings>((ref) {
  final radio = ref.read(radioProvider);
  return AdminSettings(
    radio.sendPacket,
    () => radio.state == RadioState.ready ? radio.myNodeNum : null,
    radio.queue.nextId,
  );
});

/// Своя нода (строка nodes).
final ownNodeProvider = StreamProvider<Node?>((ref) {
  final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
  if (me == null) return Stream.value(null);
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.nodes,
  )..where((n) => n.num.equals(me))).watchSingleOrNull();
});

/// Прошивка и metadata своей ноды.
final ownDeviceProvider =
    StreamProvider<({String firmware, DeviceMetadata? metadata})>((ref) {
      final db = ref.watch(databaseProvider);
      return db
          .select(db.myNode)
          .watchSingleOrNull()
          .map(
            (r) => (
              firmware: r?.firmwareVersion ?? '',
              metadata: r?.metadata == null
                  ? null
                  : DeviceMetadata.fromBuffer(r!.metadata!),
            ),
          );
    });

/// Сохранённый конфиг модуля по имени варианта (`statusmessage`, `mqtt`…).
final moduleConfigProvider = StreamProvider.family<ModuleConfig?, String>((
  ref,
  name,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.configBlobs)..where((c) => c.key.equals('module.$name')))
      .watchSingleOrNull()
      .map((r) => r == null ? null : ModuleConfig.fromBuffer(r.data));
});
