// This is a generated file - do not edit.
//
// Generated from meshtastic/deviceonly.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'channel.pb.dart' as $2;
import 'config.pbenum.dart' as $4;
import 'localonly.pb.dart' as $3;
import 'mesh.pb.dart' as $0;
import 'telemetry.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

///
///  Position with static location information only for NodeDBLite
class PositionLite extends $pb.GeneratedMessage {
  factory PositionLite({
    $core.int? latitudeI,
    $core.int? longitudeI,
    $core.int? altitude,
    $core.int? time,
    $0.Position_LocSource? locationSource,
    $core.int? precisionBits,
  }) {
    final result = PositionLite._();
    if (latitudeI != null) result.latitudeI = latitudeI;
    if (longitudeI != null) result.longitudeI = longitudeI;
    if (altitude != null) result.altitude = altitude;
    if (time != null) result.time = time;
    if (locationSource != null) result.locationSource = locationSource;
    if (precisionBits != null) result.precisionBits = precisionBits;
    return result;
  }

  PositionLite._();

  factory PositionLite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionLite()..mergeFromBuffer(data, registry);
  factory PositionLite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PositionLite()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PositionLite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: PositionLite.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'latitudeI', fieldType: $pb.PbFieldType.OSF3)
    ..aI(2, _omitFieldNames ? '' : 'longitudeI',
        fieldType: $pb.PbFieldType.OSF3)
    ..aI(3, _omitFieldNames ? '' : 'altitude')
    ..aI(4, _omitFieldNames ? '' : 'time', fieldType: $pb.PbFieldType.OF3)
    ..aE<$0.Position_LocSource>(5, _omitFieldNames ? '' : 'locationSource',
        enumValues: $0.Position_LocSource.values)
    ..aI(6, _omitFieldNames ? '' : 'precisionBits',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionLite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PositionLite copyWith(void Function(PositionLite) updates) =>
      super.copyWith((message) => updates(message as PositionLite))
          as PositionLite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PositionLite() / PositionLite.new instead')
  static PositionLite create() => PositionLite._();
  static $pb.GeneratedMessage $_createMessage() => PositionLite._();
  @$core.override
  PositionLite createEmptyInstance() => PositionLite._();
  @$core.pragma('dart2js:noInline')
  static PositionLite getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PositionLite>(
          PositionLite.$_createMessage);
  static PositionLite? _defaultInstance;

  ///
  ///  The new preferred location encoding, multiply by 1e-7 to get degrees
  ///  in floating point
  @$pb.TagNumber(1)
  $core.int get latitudeI => $_getIZ(0);
  @$pb.TagNumber(1)
  set latitudeI($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitudeI() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitudeI() => $_clearField(1);

  ///
  ///  TODO: REPLACE
  @$pb.TagNumber(2)
  $core.int get longitudeI => $_getIZ(1);
  @$pb.TagNumber(2)
  set longitudeI($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitudeI() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitudeI() => $_clearField(2);

  ///
  ///  In meters above MSL (but see issue #359)
  @$pb.TagNumber(3)
  $core.int get altitude => $_getIZ(2);
  @$pb.TagNumber(3)
  set altitude($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAltitude() => $_has(2);
  @$pb.TagNumber(3)
  void clearAltitude() => $_clearField(3);

  ///
  ///  This is usually not sent over the mesh (to save space), but it is sent
  ///  from the phone so that the local device can set its RTC If it is sent over
  ///  the mesh (because there are devices on the mesh without GPS), it will only
  ///  be sent by devices which has a hardware GPS clock.
  ///  seconds since 1970
  @$pb.TagNumber(4)
  $core.int get time => $_getIZ(3);
  @$pb.TagNumber(4)
  set time($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearTime() => $_clearField(4);

  ///
  ///  TODO: REPLACE
  @$pb.TagNumber(5)
  $0.Position_LocSource get locationSource => $_getN(4);
  @$pb.TagNumber(5)
  set locationSource($0.Position_LocSource value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLocationSource() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocationSource() => $_clearField(5);

  ///
  ///  Indicates the bits of precision set by the sending node
  @$pb.TagNumber(6)
  $core.int get precisionBits => $_getIZ(5);
  @$pb.TagNumber(6)
  set precisionBits($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPrecisionBits() => $_has(5);
  @$pb.TagNumber(6)
  void clearPrecisionBits() => $_clearField(6);
}

class UserLite extends $pb.GeneratedMessage {
  factory UserLite({
    @$core.Deprecated('This field is deprecated.')
    $core.List<$core.int>? macaddr,
    $core.String? longName,
    $core.String? shortName,
    $0.HardwareModel? hwModel,
    $core.bool? isLicensed,
    $4.Config_DeviceConfig_Role? role,
    $core.List<$core.int>? publicKey,
    $core.bool? isUnmessagable,
  }) {
    final result = UserLite._();
    if (macaddr != null) result.macaddr = macaddr;
    if (longName != null) result.longName = longName;
    if (shortName != null) result.shortName = shortName;
    if (hwModel != null) result.hwModel = hwModel;
    if (isLicensed != null) result.isLicensed = isLicensed;
    if (role != null) result.role = role;
    if (publicKey != null) result.publicKey = publicKey;
    if (isUnmessagable != null) result.isUnmessagable = isUnmessagable;
    return result;
  }

  UserLite._();

  factory UserLite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UserLite()..mergeFromBuffer(data, registry);
  factory UserLite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UserLite()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserLite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: UserLite.$_createMessage)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'macaddr', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'longName')
    ..aOS(3, _omitFieldNames ? '' : 'shortName')
    ..aE<$0.HardwareModel>(4, _omitFieldNames ? '' : 'hwModel',
        enumValues: $0.HardwareModel.values)
    ..aOB(5, _omitFieldNames ? '' : 'isLicensed')
    ..aE<$4.Config_DeviceConfig_Role>(6, _omitFieldNames ? '' : 'role',
        enumValues: $4.Config_DeviceConfig_Role.values)
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'publicKey', $pb.PbFieldType.OY)
    ..aOB(9, _omitFieldNames ? '' : 'isUnmessagable')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserLite copyWith(void Function(UserLite) updates) =>
      super.copyWith((message) => updates(message as UserLite)) as UserLite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UserLite() / UserLite.new instead')
  static UserLite create() => UserLite._();
  static $pb.GeneratedMessage $_createMessage() => UserLite._();
  @$core.override
  UserLite createEmptyInstance() => UserLite._();
  @$core.pragma('dart2js:noInline')
  static UserLite getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserLite>(UserLite.$_createMessage);
  static UserLite? _defaultInstance;

  ///
  ///  This is the addr of the radio.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  $core.List<$core.int> get macaddr => $_getN(0);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  set macaddr($core.List<$core.int> value) => $_setBytes(0, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  $core.bool hasMacaddr() => $_has(0);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  void clearMacaddr() => $_clearField(1);

  ///
  ///  A full name for this user, i.e. "Kevin Hester"
  @$pb.TagNumber(2)
  $core.String get longName => $_getSZ(1);
  @$pb.TagNumber(2)
  set longName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongName() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongName() => $_clearField(2);

  ///
  ///  A VERY short name, ideally two characters.
  ///  Suitable for a tiny OLED screen
  @$pb.TagNumber(3)
  $core.String get shortName => $_getSZ(2);
  @$pb.TagNumber(3)
  set shortName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasShortName() => $_has(2);
  @$pb.TagNumber(3)
  void clearShortName() => $_clearField(3);

  ///
  ///  TBEAM, HELTEC, etc...
  ///  Starting in 1.2.11 moved to hw_model enum in the NodeInfo object.
  ///  Apps will still need the string here for older builds
  ///  (so OTA update can find the right image), but if the enum is available it will be used instead.
  @$pb.TagNumber(4)
  $0.HardwareModel get hwModel => $_getN(3);
  @$pb.TagNumber(4)
  set hwModel($0.HardwareModel value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasHwModel() => $_has(3);
  @$pb.TagNumber(4)
  void clearHwModel() => $_clearField(4);

  ///
  ///  In some regions Ham radio operators have different bandwidth limitations than others.
  ///  If this user is a licensed operator, set this flag.
  ///  Also, "long_name" should be their licence number.
  @$pb.TagNumber(5)
  $core.bool get isLicensed => $_getBF(4);
  @$pb.TagNumber(5)
  set isLicensed($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsLicensed() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsLicensed() => $_clearField(5);

  ///
  ///  Indicates that the user's role in the mesh
  @$pb.TagNumber(6)
  $4.Config_DeviceConfig_Role get role => $_getN(5);
  @$pb.TagNumber(6)
  set role($4.Config_DeviceConfig_Role value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => $_clearField(6);

  ///
  ///  The public key of the user's device.
  ///  This is sent out to other nodes on the mesh to allow them to compute a shared secret key.
  @$pb.TagNumber(7)
  $core.List<$core.int> get publicKey => $_getN(6);
  @$pb.TagNumber(7)
  set publicKey($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPublicKey() => $_has(6);
  @$pb.TagNumber(7)
  void clearPublicKey() => $_clearField(7);

  ///
  ///  Whether or not the node can be messaged
  @$pb.TagNumber(9)
  $core.bool get isUnmessagable => $_getBF(7);
  @$pb.TagNumber(9)
  set isUnmessagable($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(9)
  $core.bool hasIsUnmessagable() => $_has(7);
  @$pb.TagNumber(9)
  void clearIsUnmessagable() => $_clearField(9);
}

class NodeInfoLite extends $pb.GeneratedMessage {
  factory NodeInfoLite({
    $core.int? num,
    $core.double? snr,
    $core.int? lastHeard,
    $core.int? channel,
    $core.int? hopsAway,
    $core.int? nextHop,
    $core.int? bitfield,
    $core.String? longName,
    $core.String? shortName,
    $0.HardwareModel? hwModel,
    $4.Config_DeviceConfig_Role? role,
    $core.List<$core.int>? publicKey,
    $core.int? snrQ4,
  }) {
    final result = NodeInfoLite._();
    if (num != null) result.num = num;
    if (snr != null) result.snr = snr;
    if (lastHeard != null) result.lastHeard = lastHeard;
    if (channel != null) result.channel = channel;
    if (hopsAway != null) result.hopsAway = hopsAway;
    if (nextHop != null) result.nextHop = nextHop;
    if (bitfield != null) result.bitfield = bitfield;
    if (longName != null) result.longName = longName;
    if (shortName != null) result.shortName = shortName;
    if (hwModel != null) result.hwModel = hwModel;
    if (role != null) result.role = role;
    if (publicKey != null) result.publicKey = publicKey;
    if (snrQ4 != null) result.snrQ4 = snrQ4;
    return result;
  }

  NodeInfoLite._();

  factory NodeInfoLite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeInfoLite()..mergeFromBuffer(data, registry);
  factory NodeInfoLite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeInfoLite()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeInfoLite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: NodeInfoLite.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'num', fieldType: $pb.PbFieldType.OU3)
    ..aD(4, _omitFieldNames ? '' : 'snr', fieldType: $pb.PbFieldType.OF)
    ..aI(5, _omitFieldNames ? '' : 'lastHeard', fieldType: $pb.PbFieldType.OF3)
    ..aI(7, _omitFieldNames ? '' : 'channel', fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'hopsAway', fieldType: $pb.PbFieldType.OU3)
    ..aI(12, _omitFieldNames ? '' : 'nextHop', fieldType: $pb.PbFieldType.OU3)
    ..aI(13, _omitFieldNames ? '' : 'bitfield', fieldType: $pb.PbFieldType.OU3)
    ..aOS(14, _omitFieldNames ? '' : 'longName')
    ..aOS(15, _omitFieldNames ? '' : 'shortName')
    ..aE<$0.HardwareModel>(16, _omitFieldNames ? '' : 'hwModel',
        enumValues: $0.HardwareModel.values)
    ..aE<$4.Config_DeviceConfig_Role>(17, _omitFieldNames ? '' : 'role',
        enumValues: $4.Config_DeviceConfig_Role.values)
    ..a<$core.List<$core.int>>(
        18, _omitFieldNames ? '' : 'publicKey', $pb.PbFieldType.OY)
    ..aI(19, _omitFieldNames ? '' : 'snrQ4', fieldType: $pb.PbFieldType.OS3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeInfoLite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeInfoLite copyWith(void Function(NodeInfoLite) updates) =>
      super.copyWith((message) => updates(message as NodeInfoLite))
          as NodeInfoLite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NodeInfoLite() / NodeInfoLite.new instead')
  static NodeInfoLite create() => NodeInfoLite._();
  static $pb.GeneratedMessage $_createMessage() => NodeInfoLite._();
  @$core.override
  NodeInfoLite createEmptyInstance() => NodeInfoLite._();
  @$core.pragma('dart2js:noInline')
  static NodeInfoLite getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeInfoLite>(
          NodeInfoLite.$_createMessage);
  static NodeInfoLite? _defaultInstance;

  ///
  ///  The node number
  @$pb.TagNumber(1)
  $core.int get num => $_getIZ(0);
  @$pb.TagNumber(1)
  set num($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNum() => $_has(0);
  @$pb.TagNumber(1)
  void clearNum() => $_clearField(1);

  ///
  ///  In-memory SNR of the last received message in dB. Not serialised directly:
  ///  always zeroed before encode; persisted as snr_q4 = 19 below.
  @$pb.TagNumber(4)
  $core.double get snr => $_getN(1);
  @$pb.TagNumber(4)
  set snr($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(4)
  $core.bool hasSnr() => $_has(1);
  @$pb.TagNumber(4)
  void clearSnr() => $_clearField(4);

  ///
  ///  Set to indicate the last time we received a packet from this node
  @$pb.TagNumber(5)
  $core.int get lastHeard => $_getIZ(2);
  @$pb.TagNumber(5)
  set lastHeard($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(5)
  $core.bool hasLastHeard() => $_has(2);
  @$pb.TagNumber(5)
  void clearLastHeard() => $_clearField(5);

  ///
  ///  local channel index we heard that node on. Only populated if its not the default channel.
  @$pb.TagNumber(7)
  $core.int get channel => $_getIZ(3);
  @$pb.TagNumber(7)
  set channel($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(7)
  $core.bool hasChannel() => $_has(3);
  @$pb.TagNumber(7)
  void clearChannel() => $_clearField(7);

  ///
  ///  Number of hops away from us this node is (0 if direct neighbor)
  @$pb.TagNumber(9)
  $core.int get hopsAway => $_getIZ(4);
  @$pb.TagNumber(9)
  set hopsAway($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(9)
  $core.bool hasHopsAway() => $_has(4);
  @$pb.TagNumber(9)
  void clearHopsAway() => $_clearField(9);

  ///
  ///  Last byte of the node number of the node that should be used as the next hop to reach this node.
  @$pb.TagNumber(12)
  $core.int get nextHop => $_getIZ(5);
  @$pb.TagNumber(12)
  set nextHop($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(12)
  $core.bool hasNextHop() => $_has(5);
  @$pb.TagNumber(12)
  void clearNextHop() => $_clearField(12);

  ///
  ///  Bitfield for storing booleans. See NODEINFO_BITFIELD_* in src/mesh/NodeDB.h.
  ///  Bit 11 is NODEINFO_BITFIELD_HAS_RF_HEAR, set once this node has been heard
  ///  over our own radio and never cleared afterwards. Bits 12..23 hold a
  ///  fingerprint of the LoRa slot it was last heard on. NodeInfo.heard_on_current_lora
  ///  is derived from those two together, not stored: it is true when the node has
  ///  been heard over RF and its recorded slot matches the slot the radio is
  ///  currently committed to. Bits 24..31 are reserved.
  @$pb.TagNumber(13)
  $core.int get bitfield => $_getIZ(6);
  @$pb.TagNumber(13)
  set bitfield($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(13)
  $core.bool hasBitfield() => $_has(6);
  @$pb.TagNumber(13)
  void clearBitfield() => $_clearField(13);

  ///
  ///  A full name for this user, i.e. "Kevin Hester".
  @$pb.TagNumber(14)
  $core.String get longName => $_getSZ(7);
  @$pb.TagNumber(14)
  set longName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(14)
  $core.bool hasLongName() => $_has(7);
  @$pb.TagNumber(14)
  void clearLongName() => $_clearField(14);

  ///
  ///  A VERY short name, ideally two characters or an emoji.
  ///  Suitable for a tiny OLED screen.
  @$pb.TagNumber(15)
  $core.String get shortName => $_getSZ(8);
  @$pb.TagNumber(15)
  set shortName($core.String value) => $_setString(8, value);
  @$pb.TagNumber(15)
  $core.bool hasShortName() => $_has(8);
  @$pb.TagNumber(15)
  void clearShortName() => $_clearField(15);

  ///
  ///  Hardware model the user's device is running.
  @$pb.TagNumber(16)
  $0.HardwareModel get hwModel => $_getN(9);
  @$pb.TagNumber(16)
  set hwModel($0.HardwareModel value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasHwModel() => $_has(9);
  @$pb.TagNumber(16)
  void clearHwModel() => $_clearField(16);

  ///
  ///  The user's role in the mesh.
  @$pb.TagNumber(17)
  $4.Config_DeviceConfig_Role get role => $_getN(10);
  @$pb.TagNumber(17)
  set role($4.Config_DeviceConfig_Role value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasRole() => $_has(10);
  @$pb.TagNumber(17)
  void clearRole() => $_clearField(17);

  ///
  ///  The public key of the user's device, for PKI-based encrypted DMs.
  @$pb.TagNumber(18)
  $core.List<$core.int> get publicKey => $_getN(11);
  @$pb.TagNumber(18)
  set publicKey($core.List<$core.int> value) => $_setBytes(11, value);
  @$pb.TagNumber(18)
  $core.bool hasPublicKey() => $_has(11);
  @$pb.TagNumber(18)
  void clearPublicKey() => $_clearField(18);

  ///
  ///  Q4-encoded SNR: dB × 4, sint32 zigzag. Matches RouteDiscovery convention.
  ///  Encode: snr_q4 = (int32_t)lroundf(snr * 4.0f). Decode: snr = snr_q4 / 4.0f.
  ///  float snr is always zeroed on disk; this field carries all persisted SNR.
  ///  A stored 0 does not by itself mean "unknown" here - see NODEINFO_BITFIELD_HAS_SNR in
  ///  src/mesh/NodeDB.h for the presence bit that disambiguates a genuine 0 dB reading from
  ///  "never measured".
  @$pb.TagNumber(19)
  $core.int get snrQ4 => $_getIZ(12);
  @$pb.TagNumber(19)
  set snrQ4($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(19)
  $core.bool hasSnrQ4() => $_has(12);
  @$pb.TagNumber(19)
  void clearSnrQ4() => $_clearField(19);
}

///
///  This message is never sent over the wire, but it is used for serializing DB
///  state to flash in the device code
///  FIXME, since we write this each time we enter deep sleep (and have infinite
///  flash) it would be better to use some sort of append only data structure for
///  the receive queue and use the preferences store for the other stuff
class DeviceState extends $pb.GeneratedMessage {
  factory DeviceState({
    $0.MyNodeInfo? myNode,
    $0.User? owner,
    $core.Iterable<$0.MeshPacket>? receiveQueue,
    $0.MeshPacket? rxTextMessage,
    $core.int? version,
    @$core.Deprecated('This field is deprecated.') $core.bool? noSave,
    @$core.Deprecated('This field is deprecated.') $core.bool? didGpsReset,
    $0.MeshPacket? rxWaypoint,
    $core.Iterable<$0.NodeRemoteHardwarePin>? nodeRemoteHardwarePins,
  }) {
    final result = DeviceState._();
    if (myNode != null) result.myNode = myNode;
    if (owner != null) result.owner = owner;
    if (receiveQueue != null) result.receiveQueue.addAll(receiveQueue);
    if (rxTextMessage != null) result.rxTextMessage = rxTextMessage;
    if (version != null) result.version = version;
    if (noSave != null) result.noSave = noSave;
    if (didGpsReset != null) result.didGpsReset = didGpsReset;
    if (rxWaypoint != null) result.rxWaypoint = rxWaypoint;
    if (nodeRemoteHardwarePins != null)
      result.nodeRemoteHardwarePins.addAll(nodeRemoteHardwarePins);
    return result;
  }

  DeviceState._();

  factory DeviceState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceState()..mergeFromBuffer(data, registry);
  factory DeviceState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeviceState()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: DeviceState.$_createMessage)
    ..aOM<$0.MyNodeInfo>(2, _omitFieldNames ? '' : 'myNode',
        subBuilder: $0.MyNodeInfo.$_createMessage)
    ..aOM<$0.User>(3, _omitFieldNames ? '' : 'owner',
        subBuilder: $0.User.$_createMessage)
    ..pPM<$0.MeshPacket>(5, _omitFieldNames ? '' : 'receiveQueue',
        subBuilder: $0.MeshPacket.$_createMessage)
    ..aOM<$0.MeshPacket>(7, _omitFieldNames ? '' : 'rxTextMessage',
        subBuilder: $0.MeshPacket.$_createMessage)
    ..aI(8, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aOB(9, _omitFieldNames ? '' : 'noSave')
    ..aOB(11, _omitFieldNames ? '' : 'didGpsReset')
    ..aOM<$0.MeshPacket>(12, _omitFieldNames ? '' : 'rxWaypoint',
        subBuilder: $0.MeshPacket.$_createMessage)
    ..pPM<$0.NodeRemoteHardwarePin>(
        13, _omitFieldNames ? '' : 'nodeRemoteHardwarePins',
        subBuilder: $0.NodeRemoteHardwarePin.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceState copyWith(void Function(DeviceState) updates) =>
      super.copyWith((message) => updates(message as DeviceState))
          as DeviceState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeviceState() / DeviceState.new instead')
  static DeviceState create() => DeviceState._();
  static $pb.GeneratedMessage $_createMessage() => DeviceState._();
  @$core.override
  DeviceState createEmptyInstance() => DeviceState._();
  @$core.pragma('dart2js:noInline')
  static DeviceState getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeviceState>(
          DeviceState.$_createMessage);
  static DeviceState? _defaultInstance;

  ///
  ///  Read only settings/info about this node
  @$pb.TagNumber(2)
  $0.MyNodeInfo get myNode => $_getN(0);
  @$pb.TagNumber(2)
  set myNode($0.MyNodeInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMyNode() => $_has(0);
  @$pb.TagNumber(2)
  void clearMyNode() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.MyNodeInfo ensureMyNode() => $_ensure(0);

  ///
  ///  My owner info
  @$pb.TagNumber(3)
  $0.User get owner => $_getN(1);
  @$pb.TagNumber(3)
  set owner($0.User value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOwner() => $_has(1);
  @$pb.TagNumber(3)
  void clearOwner() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.User ensureOwner() => $_ensure(1);

  ///
  ///  Received packets saved for delivery to the phone
  @$pb.TagNumber(5)
  $pb.PbList<$0.MeshPacket> get receiveQueue => $_getList(2);

  ///
  ///  We keep the last received text message (only) stored in the device flash,
  ///  so we can show it on the screen.
  ///  Might be null
  @$pb.TagNumber(7)
  $0.MeshPacket get rxTextMessage => $_getN(3);
  @$pb.TagNumber(7)
  set rxTextMessage($0.MeshPacket value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasRxTextMessage() => $_has(3);
  @$pb.TagNumber(7)
  void clearRxTextMessage() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.MeshPacket ensureRxTextMessage() => $_ensure(3);

  ///
  ///  A version integer used to invalidate old save files when we make
  ///  incompatible changes This integer is set at build time and is private to
  ///  NodeDB.cpp in the device code.
  @$pb.TagNumber(8)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(8)
  set version($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);

  ///
  ///  Used only during development.
  ///  Indicates developer is testing and changes should never be saved to flash.
  ///  Deprecated in 2.3.1
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(9)
  $core.bool get noSave => $_getBF(5);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(9)
  set noSave($core.bool value) => $_setBool(5, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(9)
  $core.bool hasNoSave() => $_has(5);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(9)
  void clearNoSave() => $_clearField(9);

  ///
  ///  Previously used to manage GPS factory resets.
  ///  Deprecated in 2.5.23
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(11)
  $core.bool get didGpsReset => $_getBF(6);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(11)
  set didGpsReset($core.bool value) => $_setBool(6, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(11)
  $core.bool hasDidGpsReset() => $_has(6);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(11)
  void clearDidGpsReset() => $_clearField(11);

  ///
  ///  We keep the last received waypoint stored in the device flash,
  ///  so we can show it on the screen.
  ///  Might be null
  @$pb.TagNumber(12)
  $0.MeshPacket get rxWaypoint => $_getN(7);
  @$pb.TagNumber(12)
  set rxWaypoint($0.MeshPacket value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasRxWaypoint() => $_has(7);
  @$pb.TagNumber(12)
  void clearRxWaypoint() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.MeshPacket ensureRxWaypoint() => $_ensure(7);

  ///
  ///  The mesh's nodes with their available gpio pins for RemoteHardware module
  @$pb.TagNumber(13)
  $pb.PbList<$0.NodeRemoteHardwarePin> get nodeRemoteHardwarePins =>
      $_getList(8);
}

class NodePositionEntry extends $pb.GeneratedMessage {
  factory NodePositionEntry({
    $core.int? num,
    PositionLite? position,
  }) {
    final result = NodePositionEntry._();
    if (num != null) result.num = num;
    if (position != null) result.position = position;
    return result;
  }

  NodePositionEntry._();

  factory NodePositionEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodePositionEntry()..mergeFromBuffer(data, registry);
  factory NodePositionEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodePositionEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodePositionEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: NodePositionEntry.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'num', fieldType: $pb.PbFieldType.OU3)
    ..aOM<PositionLite>(2, _omitFieldNames ? '' : 'position',
        subBuilder: PositionLite.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodePositionEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodePositionEntry copyWith(void Function(NodePositionEntry) updates) =>
      super.copyWith((message) => updates(message as NodePositionEntry))
          as NodePositionEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NodePositionEntry() / NodePositionEntry.new instead')
  static NodePositionEntry create() => NodePositionEntry._();
  static $pb.GeneratedMessage $_createMessage() => NodePositionEntry._();
  @$core.override
  NodePositionEntry createEmptyInstance() => NodePositionEntry._();
  @$core.pragma('dart2js:noInline')
  static NodePositionEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodePositionEntry>(
          NodePositionEntry.$_createMessage);
  static NodePositionEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get num => $_getIZ(0);
  @$pb.TagNumber(1)
  set num($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNum() => $_has(0);
  @$pb.TagNumber(1)
  void clearNum() => $_clearField(1);

  @$pb.TagNumber(2)
  PositionLite get position => $_getN(1);
  @$pb.TagNumber(2)
  set position(PositionLite value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearPosition() => $_clearField(2);
  @$pb.TagNumber(2)
  PositionLite ensurePosition() => $_ensure(1);
}

class NodeTelemetryEntry extends $pb.GeneratedMessage {
  factory NodeTelemetryEntry({
    $core.int? num,
    $1.DeviceMetrics? deviceMetrics,
  }) {
    final result = NodeTelemetryEntry._();
    if (num != null) result.num = num;
    if (deviceMetrics != null) result.deviceMetrics = deviceMetrics;
    return result;
  }

  NodeTelemetryEntry._();

  factory NodeTelemetryEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeTelemetryEntry()..mergeFromBuffer(data, registry);
  factory NodeTelemetryEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeTelemetryEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeTelemetryEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: NodeTelemetryEntry.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'num', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$1.DeviceMetrics>(2, _omitFieldNames ? '' : 'deviceMetrics',
        subBuilder: $1.DeviceMetrics.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeTelemetryEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeTelemetryEntry copyWith(void Function(NodeTelemetryEntry) updates) =>
      super.copyWith((message) => updates(message as NodeTelemetryEntry))
          as NodeTelemetryEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NodeTelemetryEntry() / NodeTelemetryEntry.new instead')
  static NodeTelemetryEntry create() => NodeTelemetryEntry._();
  static $pb.GeneratedMessage $_createMessage() => NodeTelemetryEntry._();
  @$core.override
  NodeTelemetryEntry createEmptyInstance() => NodeTelemetryEntry._();
  @$core.pragma('dart2js:noInline')
  static NodeTelemetryEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeTelemetryEntry>(
          NodeTelemetryEntry.$_createMessage);
  static NodeTelemetryEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get num => $_getIZ(0);
  @$pb.TagNumber(1)
  set num($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNum() => $_has(0);
  @$pb.TagNumber(1)
  void clearNum() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.DeviceMetrics get deviceMetrics => $_getN(1);
  @$pb.TagNumber(2)
  set deviceMetrics($1.DeviceMetrics value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceMetrics() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceMetrics() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.DeviceMetrics ensureDeviceMetrics() => $_ensure(1);
}

class NodeEnvironmentEntry extends $pb.GeneratedMessage {
  factory NodeEnvironmentEntry({
    $core.int? num,
    $1.EnvironmentMetrics? environmentMetrics,
  }) {
    final result = NodeEnvironmentEntry._();
    if (num != null) result.num = num;
    if (environmentMetrics != null)
      result.environmentMetrics = environmentMetrics;
    return result;
  }

  NodeEnvironmentEntry._();

  factory NodeEnvironmentEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeEnvironmentEntry()..mergeFromBuffer(data, registry);
  factory NodeEnvironmentEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeEnvironmentEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeEnvironmentEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: NodeEnvironmentEntry.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'num', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$1.EnvironmentMetrics>(2, _omitFieldNames ? '' : 'environmentMetrics',
        subBuilder: $1.EnvironmentMetrics.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeEnvironmentEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeEnvironmentEntry copyWith(void Function(NodeEnvironmentEntry) updates) =>
      super.copyWith((message) => updates(message as NodeEnvironmentEntry))
          as NodeEnvironmentEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use NodeEnvironmentEntry() / NodeEnvironmentEntry.new instead')
  static NodeEnvironmentEntry create() => NodeEnvironmentEntry._();
  static $pb.GeneratedMessage $_createMessage() => NodeEnvironmentEntry._();
  @$core.override
  NodeEnvironmentEntry createEmptyInstance() => NodeEnvironmentEntry._();
  @$core.pragma('dart2js:noInline')
  static NodeEnvironmentEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NodeEnvironmentEntry>(
          NodeEnvironmentEntry.$_createMessage);
  static NodeEnvironmentEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get num => $_getIZ(0);
  @$pb.TagNumber(1)
  set num($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNum() => $_has(0);
  @$pb.TagNumber(1)
  void clearNum() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.EnvironmentMetrics get environmentMetrics => $_getN(1);
  @$pb.TagNumber(2)
  set environmentMetrics($1.EnvironmentMetrics value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEnvironmentMetrics() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnvironmentMetrics() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.EnvironmentMetrics ensureEnvironmentMetrics() => $_ensure(1);
}

class NodeStatusEntry extends $pb.GeneratedMessage {
  factory NodeStatusEntry({
    $core.int? num,
    $0.StatusMessage? status,
  }) {
    final result = NodeStatusEntry._();
    if (num != null) result.num = num;
    if (status != null) result.status = status;
    return result;
  }

  NodeStatusEntry._();

  factory NodeStatusEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeStatusEntry()..mergeFromBuffer(data, registry);
  factory NodeStatusEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeStatusEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeStatusEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: NodeStatusEntry.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'num', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.StatusMessage>(2, _omitFieldNames ? '' : 'status',
        subBuilder: $0.StatusMessage.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeStatusEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeStatusEntry copyWith(void Function(NodeStatusEntry) updates) =>
      super.copyWith((message) => updates(message as NodeStatusEntry))
          as NodeStatusEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NodeStatusEntry() / NodeStatusEntry.new instead')
  static NodeStatusEntry create() => NodeStatusEntry._();
  static $pb.GeneratedMessage $_createMessage() => NodeStatusEntry._();
  @$core.override
  NodeStatusEntry createEmptyInstance() => NodeStatusEntry._();
  @$core.pragma('dart2js:noInline')
  static NodeStatusEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeStatusEntry>(
          NodeStatusEntry.$_createMessage);
  static NodeStatusEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get num => $_getIZ(0);
  @$pb.TagNumber(1)
  set num($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNum() => $_has(0);
  @$pb.TagNumber(1)
  void clearNum() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.StatusMessage get status => $_getN(1);
  @$pb.TagNumber(2)
  set status($0.StatusMessage value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.StatusMessage ensureStatus() => $_ensure(1);
}

class NodeDatabase extends $pb.GeneratedMessage {
  factory NodeDatabase({
    $core.int? version,
    $core.Iterable<NodeInfoLite>? nodes,
    $core.Iterable<NodePositionEntry>? positions,
    $core.Iterable<NodeTelemetryEntry>? telemetry,
    $core.Iterable<NodeStatusEntry>? status,
    $core.Iterable<NodeEnvironmentEntry>? environment,
  }) {
    final result = NodeDatabase._();
    if (version != null) result.version = version;
    if (nodes != null) result.nodes.addAll(nodes);
    if (positions != null) result.positions.addAll(positions);
    if (telemetry != null) result.telemetry.addAll(telemetry);
    if (status != null) result.status.addAll(status);
    if (environment != null) result.environment.addAll(environment);
    return result;
  }

  NodeDatabase._();

  factory NodeDatabase.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeDatabase()..mergeFromBuffer(data, registry);
  factory NodeDatabase.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NodeDatabase()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeDatabase',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: NodeDatabase.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..pPM<NodeInfoLite>(2, _omitFieldNames ? '' : 'nodes',
        subBuilder: NodeInfoLite.$_createMessage)
    ..pPM<NodePositionEntry>(3, _omitFieldNames ? '' : 'positions',
        subBuilder: NodePositionEntry.$_createMessage)
    ..pPM<NodeTelemetryEntry>(4, _omitFieldNames ? '' : 'telemetry',
        subBuilder: NodeTelemetryEntry.$_createMessage)
    ..pPM<NodeStatusEntry>(5, _omitFieldNames ? '' : 'status',
        subBuilder: NodeStatusEntry.$_createMessage)
    ..pPM<NodeEnvironmentEntry>(6, _omitFieldNames ? '' : 'environment',
        subBuilder: NodeEnvironmentEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeDatabase clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NodeDatabase copyWith(void Function(NodeDatabase) updates) =>
      super.copyWith((message) => updates(message as NodeDatabase))
          as NodeDatabase;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NodeDatabase() / NodeDatabase.new instead')
  static NodeDatabase create() => NodeDatabase._();
  static $pb.GeneratedMessage $_createMessage() => NodeDatabase._();
  @$core.override
  NodeDatabase createEmptyInstance() => NodeDatabase._();
  @$core.pragma('dart2js:noInline')
  static NodeDatabase getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeDatabase>(
          NodeDatabase.$_createMessage);
  static NodeDatabase? _defaultInstance;

  ///
  ///  A version integer used to invalidate old save files when we make
  ///  incompatible changes This integer is set at build time and is private to
  ///  NodeDB.cpp in the device code.
  @$pb.TagNumber(1)
  $core.int get version => $_getIZ(0);
  @$pb.TagNumber(1)
  set version($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  ///
  ///  New lite version of NodeDB to decrease memory footprint
  @$pb.TagNumber(2)
  $pb.PbList<NodeInfoLite> get nodes => $_getList(1);

  /// Per-NodeNum satellite arrays. Constrained platforms (e.g. STM32WL) omit
  /// these via MESHTASTIC_EXCLUDE_*DB build flags.
  @$pb.TagNumber(3)
  $pb.PbList<NodePositionEntry> get positions => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<NodeTelemetryEntry> get telemetry => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<NodeStatusEntry> get status => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<NodeEnvironmentEntry> get environment => $_getList(5);
}

///
///  The on-disk saved channels
class ChannelFile extends $pb.GeneratedMessage {
  factory ChannelFile({
    $core.Iterable<$2.Channel>? channels,
    $core.int? version,
  }) {
    final result = ChannelFile._();
    if (channels != null) result.channels.addAll(channels);
    if (version != null) result.version = version;
    return result;
  }

  ChannelFile._();

  factory ChannelFile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChannelFile()..mergeFromBuffer(data, registry);
  factory ChannelFile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChannelFile()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelFile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: ChannelFile.$_createMessage)
    ..pPM<$2.Channel>(1, _omitFieldNames ? '' : 'channels',
        subBuilder: $2.Channel.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelFile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelFile copyWith(void Function(ChannelFile) updates) =>
      super.copyWith((message) => updates(message as ChannelFile))
          as ChannelFile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChannelFile() / ChannelFile.new instead')
  static ChannelFile create() => ChannelFile._();
  static $pb.GeneratedMessage $_createMessage() => ChannelFile._();
  @$core.override
  ChannelFile createEmptyInstance() => ChannelFile._();
  @$core.pragma('dart2js:noInline')
  static ChannelFile getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChannelFile>(
          ChannelFile.$_createMessage);
  static ChannelFile? _defaultInstance;

  ///
  ///  The channels our node knows about
  @$pb.TagNumber(1)
  $pb.PbList<$2.Channel> get channels => $_getList(0);

  ///
  ///  A version integer used to invalidate old save files when we make
  ///  incompatible changes This integer is set at build time and is private to
  ///  NodeDB.cpp in the device code.
  @$pb.TagNumber(2)
  $core.int get version => $_getIZ(1);
  @$pb.TagNumber(2)
  set version($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);
}

///
///  The on-disk backup of the node's preferences
class BackupPreferences extends $pb.GeneratedMessage {
  factory BackupPreferences({
    $core.int? version,
    $core.int? timestamp,
    $3.LocalConfig? config,
    $3.LocalModuleConfig? moduleConfig,
    ChannelFile? channels,
    $0.User? owner,
  }) {
    final result = BackupPreferences._();
    if (version != null) result.version = version;
    if (timestamp != null) result.timestamp = timestamp;
    if (config != null) result.config = config;
    if (moduleConfig != null) result.moduleConfig = moduleConfig;
    if (channels != null) result.channels = channels;
    if (owner != null) result.owner = owner;
    return result;
  }

  BackupPreferences._();

  factory BackupPreferences.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackupPreferences()..mergeFromBuffer(data, registry);
  factory BackupPreferences.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackupPreferences()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BackupPreferences',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: BackupPreferences.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'timestamp', fieldType: $pb.PbFieldType.OF3)
    ..aOM<$3.LocalConfig>(3, _omitFieldNames ? '' : 'config',
        subBuilder: $3.LocalConfig.$_createMessage)
    ..aOM<$3.LocalModuleConfig>(4, _omitFieldNames ? '' : 'moduleConfig',
        subBuilder: $3.LocalModuleConfig.$_createMessage)
    ..aOM<ChannelFile>(5, _omitFieldNames ? '' : 'channels',
        subBuilder: ChannelFile.$_createMessage)
    ..aOM<$0.User>(6, _omitFieldNames ? '' : 'owner',
        subBuilder: $0.User.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackupPreferences clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackupPreferences copyWith(void Function(BackupPreferences) updates) =>
      super.copyWith((message) => updates(message as BackupPreferences))
          as BackupPreferences;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BackupPreferences() / BackupPreferences.new instead')
  static BackupPreferences create() => BackupPreferences._();
  static $pb.GeneratedMessage $_createMessage() => BackupPreferences._();
  @$core.override
  BackupPreferences createEmptyInstance() => BackupPreferences._();
  @$core.pragma('dart2js:noInline')
  static BackupPreferences getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BackupPreferences>(
          BackupPreferences.$_createMessage);
  static BackupPreferences? _defaultInstance;

  ///
  ///  The version of the backup
  @$pb.TagNumber(1)
  $core.int get version => $_getIZ(0);
  @$pb.TagNumber(1)
  set version($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  ///
  ///  The timestamp of the backup (if node has time)
  @$pb.TagNumber(2)
  $core.int get timestamp => $_getIZ(1);
  @$pb.TagNumber(2)
  set timestamp($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);

  ///
  ///  The node's configuration
  @$pb.TagNumber(3)
  $3.LocalConfig get config => $_getN(2);
  @$pb.TagNumber(3)
  set config($3.LocalConfig value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasConfig() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfig() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.LocalConfig ensureConfig() => $_ensure(2);

  ///
  ///  The node's module configuration
  @$pb.TagNumber(4)
  $3.LocalModuleConfig get moduleConfig => $_getN(3);
  @$pb.TagNumber(4)
  set moduleConfig($3.LocalModuleConfig value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasModuleConfig() => $_has(3);
  @$pb.TagNumber(4)
  void clearModuleConfig() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.LocalModuleConfig ensureModuleConfig() => $_ensure(3);

  ///
  ///  The node's channels
  @$pb.TagNumber(5)
  ChannelFile get channels => $_getN(4);
  @$pb.TagNumber(5)
  set channels(ChannelFile value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasChannels() => $_has(4);
  @$pb.TagNumber(5)
  void clearChannels() => $_clearField(5);
  @$pb.TagNumber(5)
  ChannelFile ensureChannels() => $_ensure(4);

  ///
  ///  The node's user (owner) information
  @$pb.TagNumber(6)
  $0.User get owner => $_getN(5);
  @$pb.TagNumber(6)
  set owner($0.User value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasOwner() => $_has(5);
  @$pb.TagNumber(6)
  void clearOwner() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.User ensureOwner() => $_ensure(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
