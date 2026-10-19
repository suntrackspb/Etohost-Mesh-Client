/// Точка входа в сгенерированный protobuf Meshtastic и мелкие помощники.
library;

export 'generated/meshtastic/admin.pb.dart';
export 'generated/meshtastic/channel.pb.dart';
export 'generated/meshtastic/config.pb.dart';
export 'generated/meshtastic/mesh.pb.dart';
export 'generated/meshtastic/mesh.pbenum.dart';
export 'generated/meshtastic/module_config.pb.dart';
export 'generated/meshtastic/portnums.pbenum.dart';
export 'generated/meshtastic/telemetry.pb.dart';

/// Широковещательный адрес.
const broadcastNum = 0xffffffff;

/// `!1ba174b8` — так ноды показывают все клиенты Meshtastic.
String nodeIdString(int num) => '!${num.toRadixString(16).padLeft(8, '0')}';
