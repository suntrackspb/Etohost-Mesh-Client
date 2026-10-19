// This is a generated file - do not edit.
//
// Generated from meshtastic/interdevice.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Version of the interdevice protocol spoken on the link. Both sides send
/// theirs in the ping/pong handshake; a peer reporting a different one runs
/// firmware that does not match and is not talked to.
///
/// On a change that breaks the other side (renumbered fields, changed
/// semantics, removed messages), raise the value of CURRENT. Do not add
/// another entry: this enum carries a single constant, not a history.
class InterdeviceVersion extends $pb.ProtobufEnum {
  static const InterdeviceVersion INTERDEVICE_VERSION_UNSPECIFIED =
      InterdeviceVersion._(
          0, _omitEnumNames ? '' : 'INTERDEVICE_VERSION_UNSPECIFIED');

  /// Never use 1: ping/pong were bools before the handshake existed, and a
  /// bool true is the same varint on the wire as the number 1, so firmware
  /// predating the handshake would pass it.
  static const InterdeviceVersion INTERDEVICE_VERSION_CURRENT =
      InterdeviceVersion._(
          2, _omitEnumNames ? '' : 'INTERDEVICE_VERSION_CURRENT');

  static const $core.List<InterdeviceVersion> values = <InterdeviceVersion>[
    INTERDEVICE_VERSION_UNSPECIFIED,
    INTERDEVICE_VERSION_CURRENT,
  ];

  static final $core.Map<$core.int, InterdeviceVersion> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static InterdeviceVersion? valueOf($core.int value) => _byValue[value];

  const InterdeviceVersion._(super.value, super.name);
}

/// Defines the supported file operations
class FileOperation extends $pb.ProtobufEnum {
  static const FileOperation GET =
      FileOperation._(0, _omitEnumNames ? '' : 'GET');
  static const FileOperation POST =
      FileOperation._(1, _omitEnumNames ? '' : 'POST');
  static const FileOperation PUT =
      FileOperation._(2, _omitEnumNames ? '' : 'PUT');
  static const FileOperation DELETE =
      FileOperation._(3, _omitEnumNames ? '' : 'DELETE');

  static const $core.List<FileOperation> values = <FileOperation>[
    GET,
    POST,
    PUT,
    DELETE,
  ];

  static final $core.List<FileOperation?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static FileOperation? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FileOperation._(super.value, super.name);
}

/// Outcome of a file or directory operation. The requester must be able to
/// tell a transient condition from a definitive one: BUSY is worth another
/// try, NOT_FOUND is not.
class FileStatus extends $pb.ProtobufEnum {
  static const FileStatus FILE_UNSPECIFIED =
      FileStatus._(0, _omitEnumNames ? '' : 'FILE_UNSPECIFIED');
  static const FileStatus FILE_OK =
      FileStatus._(1, _omitEnumNames ? '' : 'FILE_OK');

  /// Retry later: the co-processor is doing card maintenance (mount,
  /// free space scan) and cannot serve the request right now
  static const FileStatus FILE_BUSY =
      FileStatus._(2, _omitEnumNames ? '' : 'FILE_BUSY');
  static const FileStatus FILE_NO_CARD =
      FileStatus._(3, _omitEnumNames ? '' : 'FILE_NO_CARD');
  static const FileStatus FILE_NOT_FOUND =
      FileStatus._(4, _omitEnumNames ? '' : 'FILE_NOT_FOUND');

  /// PUT only: offset did not match the current end of the file. file_size
  /// carries the size the file actually has, so the writer can resync (or
  /// recognize its own chunk as already written after a lost response).
  static const FileStatus FILE_OFFSET_CONFLICT =
      FileStatus._(5, _omitEnumNames ? '' : 'FILE_OFFSET_CONFLICT');
  static const FileStatus FILE_IO_ERROR =
      FileStatus._(6, _omitEnumNames ? '' : 'FILE_IO_ERROR');
  static const FileStatus FILE_NOT_A_FILE =
      FileStatus._(7, _omitEnumNames ? '' : 'FILE_NOT_A_FILE');

  static const $core.List<FileStatus> values = <FileStatus>[
    FILE_UNSPECIFIED,
    FILE_OK,
    FILE_BUSY,
    FILE_NO_CARD,
    FILE_NOT_FOUND,
    FILE_OFFSET_CONFLICT,
    FILE_IO_ERROR,
    FILE_NOT_A_FILE,
  ];

  static final $core.List<FileStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static FileStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FileStatus._(super.value, super.name);
}

/// What to do with the SD card of the co-processor
class SdCommand extends $pb.ProtobufEnum {
  static const SdCommand SD_COMMAND_UNSPECIFIED =
      SdCommand._(0, _omitEnumNames ? '' : 'SD_COMMAND_UNSPECIFIED');
  static const SdCommand SD_MOUNT =
      SdCommand._(1, _omitEnumNames ? '' : 'SD_MOUNT');
  static const SdCommand SD_EJECT =
      SdCommand._(2, _omitEnumNames ? '' : 'SD_EJECT');
  static const SdCommand SD_FORMAT =
      SdCommand._(3, _omitEnumNames ? '' : 'SD_FORMAT');

  static const $core.List<SdCommand> values = <SdCommand>[
    SD_COMMAND_UNSPECIFIED,
    SD_MOUNT,
    SD_EJECT,
    SD_FORMAT,
  ];

  static final $core.List<SdCommand?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SdCommand? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SdCommand._(super.value, super.name);
}

class SdCardInfo_CardType extends $pb.ProtobufEnum {
  static const SdCardInfo_CardType NONE =
      SdCardInfo_CardType._(0, _omitEnumNames ? '' : 'NONE');
  static const SdCardInfo_CardType MMC =
      SdCardInfo_CardType._(1, _omitEnumNames ? '' : 'MMC');
  static const SdCardInfo_CardType SD =
      SdCardInfo_CardType._(2, _omitEnumNames ? '' : 'SD');
  static const SdCardInfo_CardType SDHC =
      SdCardInfo_CardType._(3, _omitEnumNames ? '' : 'SDHC');
  static const SdCardInfo_CardType SDXC =
      SdCardInfo_CardType._(4, _omitEnumNames ? '' : 'SDXC');
  static const SdCardInfo_CardType UNKNOWN_CARD =
      SdCardInfo_CardType._(5, _omitEnumNames ? '' : 'UNKNOWN_CARD');

  static const $core.List<SdCardInfo_CardType> values = <SdCardInfo_CardType>[
    NONE,
    MMC,
    SD,
    SDHC,
    SDXC,
    UNKNOWN_CARD,
  ];

  static final $core.List<SdCardInfo_CardType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static SdCardInfo_CardType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SdCardInfo_CardType._(super.value, super.name);
}

class SdCardInfo_FatType extends $pb.ProtobufEnum {
  static const SdCardInfo_FatType UNKNOWN_FAT =
      SdCardInfo_FatType._(0, _omitEnumNames ? '' : 'UNKNOWN_FAT');
  static const SdCardInfo_FatType FAT16 =
      SdCardInfo_FatType._(1, _omitEnumNames ? '' : 'FAT16');
  static const SdCardInfo_FatType FAT32 =
      SdCardInfo_FatType._(2, _omitEnumNames ? '' : 'FAT32');
  static const SdCardInfo_FatType EXFAT =
      SdCardInfo_FatType._(3, _omitEnumNames ? '' : 'EXFAT');

  static const $core.List<SdCardInfo_FatType> values = <SdCardInfo_FatType>[
    UNKNOWN_FAT,
    FAT16,
    FAT32,
    EXFAT,
  ];

  static final $core.List<SdCardInfo_FatType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SdCardInfo_FatType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SdCardInfo_FatType._(super.value, super.name);
}

class I2CResult_Status extends $pb.ProtobufEnum {
  /// Never sent: an all-defaults (e.g. accidentally empty) message must
  /// not decode as a successful transaction
  static const I2CResult_Status UNSPECIFIED =
      I2CResult_Status._(0, _omitEnumNames ? '' : 'UNSPECIFIED');
  static const I2CResult_Status OK =
      I2CResult_Status._(1, _omitEnumNames ? '' : 'OK');
  static const I2CResult_Status NACK_ADDRESS =
      I2CResult_Status._(2, _omitEnumNames ? '' : 'NACK_ADDRESS');
  static const I2CResult_Status NACK_DATA =
      I2CResult_Status._(3, _omitEnumNames ? '' : 'NACK_DATA');
  static const I2CResult_Status ERROR =
      I2CResult_Status._(4, _omitEnumNames ? '' : 'ERROR');

  static const $core.List<I2CResult_Status> values = <I2CResult_Status>[
    UNSPECIFIED,
    OK,
    NACK_ADDRESS,
    NACK_DATA,
    ERROR,
  ];

  static final $core.List<I2CResult_Status?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static I2CResult_Status? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const I2CResult_Status._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
