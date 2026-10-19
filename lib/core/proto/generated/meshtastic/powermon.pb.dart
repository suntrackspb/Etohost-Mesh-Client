// This is a generated file - do not edit.
//
// Generated from meshtastic/powermon.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'powermon.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'powermon.pbenum.dart';

/// Note: There are no 'PowerMon' messages normally in use (PowerMons are sent only as structured logs - slogs).
/// But we wrap our State enum in this message to effectively nest a namespace (without our linter yelling at us)
class PowerMon extends $pb.GeneratedMessage {
  factory PowerMon() => PowerMon._();

  PowerMon._();

  factory PowerMon.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PowerMon()..mergeFromBuffer(data, registry);
  factory PowerMon.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PowerMon()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PowerMon',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: PowerMon.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PowerMon clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PowerMon copyWith(void Function(PowerMon) updates) =>
      super.copyWith((message) => updates(message as PowerMon)) as PowerMon;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PowerMon() / PowerMon.new instead')
  static PowerMon create() => PowerMon._();
  static $pb.GeneratedMessage $_createMessage() => PowerMon._();
  @$core.override
  PowerMon createEmptyInstance() => PowerMon._();
  @$core.pragma('dart2js:noInline')
  static PowerMon getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PowerMon>(PowerMon.$_createMessage);
  static PowerMon? _defaultInstance;
}

///
///  PowerStress testing support via the C++ PowerStress module
class PowerStressMessage extends $pb.GeneratedMessage {
  factory PowerStressMessage({
    PowerStressMessage_Opcode? cmd,
    $core.double? numSeconds,
  }) {
    final result = PowerStressMessage._();
    if (cmd != null) result.cmd = cmd;
    if (numSeconds != null) result.numSeconds = numSeconds;
    return result;
  }

  PowerStressMessage._();

  factory PowerStressMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PowerStressMessage()..mergeFromBuffer(data, registry);
  factory PowerStressMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PowerStressMessage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PowerStressMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: PowerStressMessage.$_createMessage)
    ..aE<PowerStressMessage_Opcode>(1, _omitFieldNames ? '' : 'cmd',
        enumValues: PowerStressMessage_Opcode.values)
    ..aD(2, _omitFieldNames ? '' : 'numSeconds', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PowerStressMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PowerStressMessage copyWith(void Function(PowerStressMessage) updates) =>
      super.copyWith((message) => updates(message as PowerStressMessage))
          as PowerStressMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PowerStressMessage() / PowerStressMessage.new instead')
  static PowerStressMessage create() => PowerStressMessage._();
  static $pb.GeneratedMessage $_createMessage() => PowerStressMessage._();
  @$core.override
  PowerStressMessage createEmptyInstance() => PowerStressMessage._();
  @$core.pragma('dart2js:noInline')
  static PowerStressMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PowerStressMessage>(
          PowerStressMessage.$_createMessage);
  static PowerStressMessage? _defaultInstance;

  ///
  ///  What type of HardwareMessage is this?
  @$pb.TagNumber(1)
  PowerStressMessage_Opcode get cmd => $_getN(0);
  @$pb.TagNumber(1)
  set cmd(PowerStressMessage_Opcode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCmd() => $_has(0);
  @$pb.TagNumber(1)
  void clearCmd() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get numSeconds => $_getN(1);
  @$pb.TagNumber(2)
  set numSeconds($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNumSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumSeconds() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
