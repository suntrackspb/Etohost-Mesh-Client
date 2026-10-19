// This is a generated file - do not edit.
//
// Generated from meshtastic/deviceonly.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use positionLiteDescriptor instead')
const PositionLite$json = {
  '1': 'PositionLite',
  '2': [
    {'1': 'latitude_i', '3': 1, '4': 1, '5': 15, '10': 'latitudeI'},
    {'1': 'longitude_i', '3': 2, '4': 1, '5': 15, '10': 'longitudeI'},
    {'1': 'altitude', '3': 3, '4': 1, '5': 5, '10': 'altitude'},
    {'1': 'time', '3': 4, '4': 1, '5': 7, '10': 'time'},
    {
      '1': 'location_source',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.Position.LocSource',
      '10': 'locationSource'
    },
    {'1': 'precision_bits', '3': 6, '4': 1, '5': 13, '10': 'precisionBits'},
  ],
};

/// Descriptor for `PositionLite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionLiteDescriptor = $convert.base64Decode(
    'CgxQb3NpdGlvbkxpdGUSHQoKbGF0aXR1ZGVfaRgBIAEoD1IJbGF0aXR1ZGVJEh8KC2xvbmdpdH'
    'VkZV9pGAIgASgPUgpsb25naXR1ZGVJEhoKCGFsdGl0dWRlGAMgASgFUghhbHRpdHVkZRISCgR0'
    'aW1lGAQgASgHUgR0aW1lEkcKD2xvY2F0aW9uX3NvdXJjZRgFIAEoDjIeLm1lc2h0YXN0aWMuUG'
    '9zaXRpb24uTG9jU291cmNlUg5sb2NhdGlvblNvdXJjZRIlCg5wcmVjaXNpb25fYml0cxgGIAEo'
    'DVINcHJlY2lzaW9uQml0cw==');

@$core.Deprecated('Use userLiteDescriptor instead')
const UserLite$json = {
  '1': 'UserLite',
  '2': [
    {
      '1': 'macaddr',
      '3': 1,
      '4': 1,
      '5': 12,
      '8': {'3': true},
      '10': 'macaddr',
    },
    {'1': 'long_name', '3': 2, '4': 1, '5': 9, '10': 'longName'},
    {'1': 'short_name', '3': 3, '4': 1, '5': 9, '10': 'shortName'},
    {
      '1': 'hw_model',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.HardwareModel',
      '10': 'hwModel'
    },
    {'1': 'is_licensed', '3': 5, '4': 1, '5': 8, '10': 'isLicensed'},
    {
      '1': 'role',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.Config.DeviceConfig.Role',
      '10': 'role'
    },
    {'1': 'public_key', '3': 7, '4': 1, '5': 12, '10': 'publicKey'},
    {
      '1': 'is_unmessagable',
      '3': 9,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'isUnmessagable',
      '17': true
    },
  ],
  '8': [
    {'1': '_is_unmessagable'},
  ],
};

/// Descriptor for `UserLite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userLiteDescriptor = $convert.base64Decode(
    'CghVc2VyTGl0ZRIcCgdtYWNhZGRyGAEgASgMQgIYAVIHbWFjYWRkchIbCglsb25nX25hbWUYAi'
    'ABKAlSCGxvbmdOYW1lEh0KCnNob3J0X25hbWUYAyABKAlSCXNob3J0TmFtZRI0Cghod19tb2Rl'
    'bBgEIAEoDjIZLm1lc2h0YXN0aWMuSGFyZHdhcmVNb2RlbFIHaHdNb2RlbBIfCgtpc19saWNlbn'
    'NlZBgFIAEoCFIKaXNMaWNlbnNlZBI4CgRyb2xlGAYgASgOMiQubWVzaHRhc3RpYy5Db25maWcu'
    'RGV2aWNlQ29uZmlnLlJvbGVSBHJvbGUSHQoKcHVibGljX2tleRgHIAEoDFIJcHVibGljS2V5Ei'
    'wKD2lzX3VubWVzc2FnYWJsZRgJIAEoCEgAUg5pc1VubWVzc2FnYWJsZYgBAUISChBfaXNfdW5t'
    'ZXNzYWdhYmxl');

@$core.Deprecated('Use nodeInfoLiteDescriptor instead')
const NodeInfoLite$json = {
  '1': 'NodeInfoLite',
  '2': [
    {'1': 'num', '3': 1, '4': 1, '5': 13, '10': 'num'},
    {'1': 'snr', '3': 4, '4': 1, '5': 2, '10': 'snr'},
    {'1': 'last_heard', '3': 5, '4': 1, '5': 7, '10': 'lastHeard'},
    {'1': 'channel', '3': 7, '4': 1, '5': 13, '10': 'channel'},
    {
      '1': 'hops_away',
      '3': 9,
      '4': 1,
      '5': 13,
      '9': 0,
      '10': 'hopsAway',
      '17': true
    },
    {'1': 'next_hop', '3': 12, '4': 1, '5': 13, '10': 'nextHop'},
    {'1': 'bitfield', '3': 13, '4': 1, '5': 13, '10': 'bitfield'},
    {'1': 'long_name', '3': 14, '4': 1, '5': 9, '10': 'longName'},
    {'1': 'short_name', '3': 15, '4': 1, '5': 9, '10': 'shortName'},
    {
      '1': 'hw_model',
      '3': 16,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.HardwareModel',
      '10': 'hwModel'
    },
    {
      '1': 'role',
      '3': 17,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.Config.DeviceConfig.Role',
      '10': 'role'
    },
    {'1': 'public_key', '3': 18, '4': 1, '5': 12, '10': 'publicKey'},
    {'1': 'snr_q4', '3': 19, '4': 1, '5': 17, '10': 'snrQ4'},
  ],
  '8': [
    {'1': '_hops_away'},
  ],
  '9': [
    {'1': 2, '2': 3},
    {'1': 3, '2': 4},
    {'1': 6, '2': 7},
    {'1': 8, '2': 9},
    {'1': 10, '2': 11},
    {'1': 11, '2': 12},
  ],
  '10': [
    'user',
    'position',
    'device_metrics',
    'via_mqtt',
    'is_favorite',
    'is_ignored'
  ],
};

/// Descriptor for `NodeInfoLite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeInfoLiteDescriptor = $convert.base64Decode(
    'CgxOb2RlSW5mb0xpdGUSEAoDbnVtGAEgASgNUgNudW0SEAoDc25yGAQgASgCUgNzbnISHQoKbG'
    'FzdF9oZWFyZBgFIAEoB1IJbGFzdEhlYXJkEhgKB2NoYW5uZWwYByABKA1SB2NoYW5uZWwSIAoJ'
    'aG9wc19hd2F5GAkgASgNSABSCGhvcHNBd2F5iAEBEhkKCG5leHRfaG9wGAwgASgNUgduZXh0SG'
    '9wEhoKCGJpdGZpZWxkGA0gASgNUghiaXRmaWVsZBIbCglsb25nX25hbWUYDiABKAlSCGxvbmdO'
    'YW1lEh0KCnNob3J0X25hbWUYDyABKAlSCXNob3J0TmFtZRI0Cghod19tb2RlbBgQIAEoDjIZLm'
    '1lc2h0YXN0aWMuSGFyZHdhcmVNb2RlbFIHaHdNb2RlbBI4CgRyb2xlGBEgASgOMiQubWVzaHRh'
    'c3RpYy5Db25maWcuRGV2aWNlQ29uZmlnLlJvbGVSBHJvbGUSHQoKcHVibGljX2tleRgSIAEoDF'
    'IJcHVibGljS2V5EhUKBnNucl9xNBgTIAEoEVIFc25yUTRCDAoKX2hvcHNfYXdheUoECAIQA0oE'
    'CAMQBEoECAYQB0oECAgQCUoECAoQC0oECAsQDFIEdXNlclIIcG9zaXRpb25SDmRldmljZV9tZX'
    'RyaWNzUgh2aWFfbXF0dFILaXNfZmF2b3JpdGVSCmlzX2lnbm9yZWQ=');

@$core.Deprecated('Use deviceStateDescriptor instead')
const DeviceState$json = {
  '1': 'DeviceState',
  '2': [
    {
      '1': 'my_node',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.MyNodeInfo',
      '10': 'myNode'
    },
    {
      '1': 'owner',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.User',
      '10': 'owner'
    },
    {
      '1': 'receive_queue',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.meshtastic.MeshPacket',
      '10': 'receiveQueue'
    },
    {'1': 'version', '3': 8, '4': 1, '5': 13, '10': 'version'},
    {
      '1': 'rx_text_message',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.MeshPacket',
      '10': 'rxTextMessage'
    },
    {
      '1': 'no_save',
      '3': 9,
      '4': 1,
      '5': 8,
      '8': {'3': true},
      '10': 'noSave',
    },
    {
      '1': 'did_gps_reset',
      '3': 11,
      '4': 1,
      '5': 8,
      '8': {'3': true},
      '10': 'didGpsReset',
    },
    {
      '1': 'rx_waypoint',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.MeshPacket',
      '10': 'rxWaypoint'
    },
    {
      '1': 'node_remote_hardware_pins',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.meshtastic.NodeRemoteHardwarePin',
      '10': 'nodeRemoteHardwarePins'
    },
  ],
};

/// Descriptor for `DeviceState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceStateDescriptor = $convert.base64Decode(
    'CgtEZXZpY2VTdGF0ZRIvCgdteV9ub2RlGAIgASgLMhYubWVzaHRhc3RpYy5NeU5vZGVJbmZvUg'
    'ZteU5vZGUSJgoFb3duZXIYAyABKAsyEC5tZXNodGFzdGljLlVzZXJSBW93bmVyEjsKDXJlY2Vp'
    'dmVfcXVldWUYBSADKAsyFi5tZXNodGFzdGljLk1lc2hQYWNrZXRSDHJlY2VpdmVRdWV1ZRIYCg'
    'd2ZXJzaW9uGAggASgNUgd2ZXJzaW9uEj4KD3J4X3RleHRfbWVzc2FnZRgHIAEoCzIWLm1lc2h0'
    'YXN0aWMuTWVzaFBhY2tldFINcnhUZXh0TWVzc2FnZRIbCgdub19zYXZlGAkgASgIQgIYAVIGbm'
    '9TYXZlEiYKDWRpZF9ncHNfcmVzZXQYCyABKAhCAhgBUgtkaWRHcHNSZXNldBI3CgtyeF93YXlw'
    'b2ludBgMIAEoCzIWLm1lc2h0YXN0aWMuTWVzaFBhY2tldFIKcnhXYXlwb2ludBJcChlub2RlX3'
    'JlbW90ZV9oYXJkd2FyZV9waW5zGA0gAygLMiEubWVzaHRhc3RpYy5Ob2RlUmVtb3RlSGFyZHdh'
    'cmVQaW5SFm5vZGVSZW1vdGVIYXJkd2FyZVBpbnM=');

@$core.Deprecated('Use nodePositionEntryDescriptor instead')
const NodePositionEntry$json = {
  '1': 'NodePositionEntry',
  '2': [
    {'1': 'num', '3': 1, '4': 1, '5': 13, '10': 'num'},
    {
      '1': 'position',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.PositionLite',
      '10': 'position'
    },
  ],
};

/// Descriptor for `NodePositionEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodePositionEntryDescriptor = $convert.base64Decode(
    'ChFOb2RlUG9zaXRpb25FbnRyeRIQCgNudW0YASABKA1SA251bRI0Cghwb3NpdGlvbhgCIAEoCz'
    'IYLm1lc2h0YXN0aWMuUG9zaXRpb25MaXRlUghwb3NpdGlvbg==');

@$core.Deprecated('Use nodeTelemetryEntryDescriptor instead')
const NodeTelemetryEntry$json = {
  '1': 'NodeTelemetryEntry',
  '2': [
    {'1': 'num', '3': 1, '4': 1, '5': 13, '10': 'num'},
    {
      '1': 'device_metrics',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.DeviceMetrics',
      '10': 'deviceMetrics'
    },
  ],
};

/// Descriptor for `NodeTelemetryEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeTelemetryEntryDescriptor = $convert.base64Decode(
    'ChJOb2RlVGVsZW1ldHJ5RW50cnkSEAoDbnVtGAEgASgNUgNudW0SQAoOZGV2aWNlX21ldHJpY3'
    'MYAiABKAsyGS5tZXNodGFzdGljLkRldmljZU1ldHJpY3NSDWRldmljZU1ldHJpY3M=');

@$core.Deprecated('Use nodeEnvironmentEntryDescriptor instead')
const NodeEnvironmentEntry$json = {
  '1': 'NodeEnvironmentEntry',
  '2': [
    {'1': 'num', '3': 1, '4': 1, '5': 13, '10': 'num'},
    {
      '1': 'environment_metrics',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.EnvironmentMetrics',
      '10': 'environmentMetrics'
    },
  ],
};

/// Descriptor for `NodeEnvironmentEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeEnvironmentEntryDescriptor = $convert.base64Decode(
    'ChROb2RlRW52aXJvbm1lbnRFbnRyeRIQCgNudW0YASABKA1SA251bRJPChNlbnZpcm9ubWVudF'
    '9tZXRyaWNzGAIgASgLMh4ubWVzaHRhc3RpYy5FbnZpcm9ubWVudE1ldHJpY3NSEmVudmlyb25t'
    'ZW50TWV0cmljcw==');

@$core.Deprecated('Use nodeStatusEntryDescriptor instead')
const NodeStatusEntry$json = {
  '1': 'NodeStatusEntry',
  '2': [
    {'1': 'num', '3': 1, '4': 1, '5': 13, '10': 'num'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.StatusMessage',
      '10': 'status'
    },
  ],
};

/// Descriptor for `NodeStatusEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeStatusEntryDescriptor = $convert.base64Decode(
    'Cg9Ob2RlU3RhdHVzRW50cnkSEAoDbnVtGAEgASgNUgNudW0SMQoGc3RhdHVzGAIgASgLMhkubW'
    'VzaHRhc3RpYy5TdGF0dXNNZXNzYWdlUgZzdGF0dXM=');

@$core.Deprecated('Use nodeDatabaseDescriptor instead')
const NodeDatabase$json = {
  '1': 'NodeDatabase',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 13, '10': 'version'},
    {
      '1': 'nodes',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.meshtastic.NodeInfoLite',
      '8': {},
      '10': 'nodes'
    },
    {
      '1': 'positions',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.meshtastic.NodePositionEntry',
      '8': {},
      '10': 'positions'
    },
    {
      '1': 'telemetry',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.meshtastic.NodeTelemetryEntry',
      '8': {},
      '10': 'telemetry'
    },
    {
      '1': 'status',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.meshtastic.NodeStatusEntry',
      '8': {},
      '10': 'status'
    },
    {
      '1': 'environment',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.meshtastic.NodeEnvironmentEntry',
      '8': {},
      '10': 'environment'
    },
  ],
};

/// Descriptor for `NodeDatabase`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeDatabaseDescriptor = $convert.base64Decode(
    'CgxOb2RlRGF0YWJhc2USGAoHdmVyc2lvbhgBIAEoDVIHdmVyc2lvbhJaCgVub2RlcxgCIAMoCz'
    'IYLm1lc2h0YXN0aWMuTm9kZUluZm9MaXRlQiqSPyeSASRzdGQ6OnZlY3RvcjxtZXNodGFzdGlj'
    'X05vZGVJbmZvTGl0ZT5SBW5vZGVzEmwKCXBvc2l0aW9ucxgDIAMoCzIdLm1lc2h0YXN0aWMuTm'
    '9kZVBvc2l0aW9uRW50cnlCL5I/LJIBKXN0ZDo6dmVjdG9yPG1lc2h0YXN0aWNfTm9kZVBvc2l0'
    'aW9uRW50cnk+Uglwb3NpdGlvbnMSbgoJdGVsZW1ldHJ5GAQgAygLMh4ubWVzaHRhc3RpYy5Ob2'
    'RlVGVsZW1ldHJ5RW50cnlCMJI/LZIBKnN0ZDo6dmVjdG9yPG1lc2h0YXN0aWNfTm9kZVRlbGVt'
    'ZXRyeUVudHJ5PlIJdGVsZW1ldHJ5EmIKBnN0YXR1cxgFIAMoCzIbLm1lc2h0YXN0aWMuTm9kZV'
    'N0YXR1c0VudHJ5Qi2SPyqSASdzdGQ6OnZlY3RvcjxtZXNodGFzdGljX05vZGVTdGF0dXNFbnRy'
    'eT5SBnN0YXR1cxJ2CgtlbnZpcm9ubWVudBgGIAMoCzIgLm1lc2h0YXN0aWMuTm9kZUVudmlyb2'
    '5tZW50RW50cnlCMpI/L5IBLHN0ZDo6dmVjdG9yPG1lc2h0YXN0aWNfTm9kZUVudmlyb25tZW50'
    'RW50cnk+UgtlbnZpcm9ubWVudA==');

@$core.Deprecated('Use channelFileDescriptor instead')
const ChannelFile$json = {
  '1': 'ChannelFile',
  '2': [
    {
      '1': 'channels',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meshtastic.Channel',
      '10': 'channels'
    },
    {'1': 'version', '3': 2, '4': 1, '5': 13, '10': 'version'},
  ],
};

/// Descriptor for `ChannelFile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelFileDescriptor = $convert.base64Decode(
    'CgtDaGFubmVsRmlsZRIvCghjaGFubmVscxgBIAMoCzITLm1lc2h0YXN0aWMuQ2hhbm5lbFIIY2'
    'hhbm5lbHMSGAoHdmVyc2lvbhgCIAEoDVIHdmVyc2lvbg==');

@$core.Deprecated('Use backupPreferencesDescriptor instead')
const BackupPreferences$json = {
  '1': 'BackupPreferences',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 13, '10': 'version'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 7, '10': 'timestamp'},
    {
      '1': 'config',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.LocalConfig',
      '10': 'config'
    },
    {
      '1': 'module_config',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.LocalModuleConfig',
      '10': 'moduleConfig'
    },
    {
      '1': 'channels',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.ChannelFile',
      '10': 'channels'
    },
    {
      '1': 'owner',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.User',
      '10': 'owner'
    },
  ],
};

/// Descriptor for `BackupPreferences`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backupPreferencesDescriptor = $convert.base64Decode(
    'ChFCYWNrdXBQcmVmZXJlbmNlcxIYCgd2ZXJzaW9uGAEgASgNUgd2ZXJzaW9uEhwKCXRpbWVzdG'
    'FtcBgCIAEoB1IJdGltZXN0YW1wEi8KBmNvbmZpZxgDIAEoCzIXLm1lc2h0YXN0aWMuTG9jYWxD'
    'b25maWdSBmNvbmZpZxJCCg1tb2R1bGVfY29uZmlnGAQgASgLMh0ubWVzaHRhc3RpYy5Mb2NhbE'
    '1vZHVsZUNvbmZpZ1IMbW9kdWxlQ29uZmlnEjMKCGNoYW5uZWxzGAUgASgLMhcubWVzaHRhc3Rp'
    'Yy5DaGFubmVsRmlsZVIIY2hhbm5lbHMSJgoFb3duZXIYBiABKAsyEC5tZXNodGFzdGljLlVzZX'
    'JSBW93bmVy');
