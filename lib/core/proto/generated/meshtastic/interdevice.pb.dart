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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'interdevice.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'interdevice.pbenum.dart';

/// Message for file operations
class FileTransfer extends $pb.GeneratedMessage {
  factory FileTransfer({
    FileOperation? operation,
    $core.String? filepath,
    $core.List<$core.int>? filedata,
    FileStatus? status,
    $core.String? message,
    $fixnum.Int64? offset,
    $core.int? length,
    $fixnum.Int64? fileSize,
  }) {
    final result = FileTransfer._();
    if (operation != null) result.operation = operation;
    if (filepath != null) result.filepath = filepath;
    if (filedata != null) result.filedata = filedata;
    if (status != null) result.status = status;
    if (message != null) result.message = message;
    if (offset != null) result.offset = offset;
    if (length != null) result.length = length;
    if (fileSize != null) result.fileSize = fileSize;
    return result;
  }

  FileTransfer._();

  factory FileTransfer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileTransfer()..mergeFromBuffer(data, registry);
  factory FileTransfer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileTransfer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileTransfer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: FileTransfer.$_createMessage)
    ..aE<FileOperation>(1, _omitFieldNames ? '' : 'operation',
        enumValues: FileOperation.values)
    ..aOS(2, _omitFieldNames ? '' : 'filepath')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'filedata', $pb.PbFieldType.OY)
    ..aE<FileStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: FileStatus.values)
    ..aOS(5, _omitFieldNames ? '' : 'message')
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(7, _omitFieldNames ? '' : 'length', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'fileSize', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileTransfer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileTransfer copyWith(void Function(FileTransfer) updates) =>
      super.copyWith((message) => updates(message as FileTransfer))
          as FileTransfer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FileTransfer() / FileTransfer.new instead')
  static FileTransfer create() => FileTransfer._();
  static $pb.GeneratedMessage $_createMessage() => FileTransfer._();
  @$core.override
  FileTransfer createEmptyInstance() => FileTransfer._();
  @$core.pragma('dart2js:noInline')
  static FileTransfer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileTransfer>(
          FileTransfer.$_createMessage);
  static FileTransfer? _defaultInstance;

  @$pb.TagNumber(1)
  FileOperation get operation => $_getN(0);
  @$pb.TagNumber(1)
  set operation(FileOperation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOperation() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperation() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get filepath => $_getSZ(1);
  @$pb.TagNumber(2)
  set filepath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilepath() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilepath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get filedata => $_getN(2);
  @$pb.TagNumber(3)
  set filedata($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFiledata() => $_has(2);
  @$pb.TagNumber(3)
  void clearFiledata() => $_clearField(3);

  @$pb.TagNumber(4)
  FileStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(FileStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get message => $_getSZ(4);
  @$pb.TagNumber(5)
  set message($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessage() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get offset => $_getI64(5);
  @$pb.TagNumber(6)
  set offset($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOffset() => $_has(5);
  @$pb.TagNumber(6)
  void clearOffset() => $_clearField(6);

  /// GET request: number of bytes to read, 0 = max chunk size. A response
  /// carries at most the filedata max_size (see interdevice.options) per
  /// chunk; larger requests are truncated, visible in the filedata length.
  @$pb.TagNumber(7)
  $core.int get length => $_getIZ(6);
  @$pb.TagNumber(7)
  set length($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLength() => $_has(6);
  @$pb.TagNumber(7)
  void clearLength() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get fileSize => $_getI64(7);
  @$pb.TagNumber(8)
  set fileSize($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFileSize() => $_has(7);
  @$pb.TagNumber(8)
  void clearFileSize() => $_clearField(8);
}

/// Message for structured directory listing
class DirectoryListing extends $pb.GeneratedMessage {
  factory DirectoryListing({
    $core.String? directory,
    $core.Iterable<$core.String>? filenames,
    FileStatus? status,
    $core.String? message,
    $core.int? offset,
    $core.int? totalCount,
  }) {
    final result = DirectoryListing._();
    if (directory != null) result.directory = directory;
    if (filenames != null) result.filenames.addAll(filenames);
    if (status != null) result.status = status;
    if (message != null) result.message = message;
    if (offset != null) result.offset = offset;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  DirectoryListing._();

  factory DirectoryListing.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DirectoryListing()..mergeFromBuffer(data, registry);
  factory DirectoryListing.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DirectoryListing()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DirectoryListing',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: DirectoryListing.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'directory')
    ..pPS(2, _omitFieldNames ? '' : 'filenames')
    ..aE<FileStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: FileStatus.values)
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..aI(5, _omitFieldNames ? '' : 'offset', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'totalCount', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DirectoryListing clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DirectoryListing copyWith(void Function(DirectoryListing) updates) =>
      super.copyWith((message) => updates(message as DirectoryListing))
          as DirectoryListing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DirectoryListing() / DirectoryListing.new instead')
  static DirectoryListing create() => DirectoryListing._();
  static $pb.GeneratedMessage $_createMessage() => DirectoryListing._();
  @$core.override
  DirectoryListing createEmptyInstance() => DirectoryListing._();
  @$core.pragma('dart2js:noInline')
  static DirectoryListing getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DirectoryListing>(
          DirectoryListing.$_createMessage);
  static DirectoryListing? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get directory => $_getSZ(0);
  @$pb.TagNumber(1)
  set directory($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDirectory() => $_has(0);
  @$pb.TagNumber(1)
  void clearDirectory() => $_clearField(1);

  /// One page of entry names, full FAT LFN length. Subdirectories carry a
  /// trailing slash. Note that a name whose directory prefix pushes the
  /// combined path past the FileTransfer.filepath limit cannot round-trip.
  /// Page size is the max_count in interdevice.options; page through with
  /// offset and total_count.
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get filenames => $_getList(1);

  @$pb.TagNumber(3)
  FileStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(FileStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get offset => $_getIZ(4);
  @$pb.TagNumber(5)
  set offset($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOffset() => $_has(4);
  @$pb.TagNumber(5)
  void clearOffset() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get totalCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set totalCount($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalCount() => $_clearField(6);
}

/// A single I2C transaction: an optional write followed by an optional
/// read with repeated start, matching the TwoWire usage of sensor drivers
/// (beginTransmission/write.../endTransmission(false)/requestFrom)
class I2CTransaction extends $pb.GeneratedMessage {
  factory I2CTransaction({
    $core.int? address,
    $core.List<$core.int>? writeData,
    $core.int? readLen,
  }) {
    final result = I2CTransaction._();
    if (address != null) result.address = address;
    if (writeData != null) result.writeData = writeData;
    if (readLen != null) result.readLen = readLen;
    return result;
  }

  I2CTransaction._();

  factory I2CTransaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      I2CTransaction()..mergeFromBuffer(data, registry);
  factory I2CTransaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      I2CTransaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'I2CTransaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: I2CTransaction.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'address', fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'writeData', $pb.PbFieldType.OY)
    ..aI(3, _omitFieldNames ? '' : 'readLen', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  I2CTransaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  I2CTransaction copyWith(void Function(I2CTransaction) updates) =>
      super.copyWith((message) => updates(message as I2CTransaction))
          as I2CTransaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use I2CTransaction() / I2CTransaction.new instead')
  static I2CTransaction create() => I2CTransaction._();
  static $pb.GeneratedMessage $_createMessage() => I2CTransaction._();
  @$core.override
  I2CTransaction createEmptyInstance() => I2CTransaction._();
  @$core.pragma('dart2js:noInline')
  static I2CTransaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<I2CTransaction>(
          I2CTransaction.$_createMessage);
  static I2CTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get address => $_getIZ(0);
  @$pb.TagNumber(1)
  set address($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get writeData => $_getN(1);
  @$pb.TagNumber(2)
  set writeData($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWriteData() => $_has(1);
  @$pb.TagNumber(2)
  void clearWriteData() => $_clearField(2);

  /// Number of bytes to read after the write, 0 = write-only. Bounded by
  /// the read_data max_size of I2CResult (see interdevice.options); larger
  /// requests are truncated, visible in the returned byte count.
  @$pb.TagNumber(3)
  $core.int get readLen => $_getIZ(2);
  @$pb.TagNumber(3)
  set readLen($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReadLen() => $_has(2);
  @$pb.TagNumber(3)
  void clearReadLen() => $_clearField(3);
}

/// SD card statistics
class SdCardInfo extends $pb.GeneratedMessage {
  factory SdCardInfo({
    $core.bool? present,
    SdCardInfo_CardType? cardType,
    SdCardInfo_FatType? fatType,
    $fixnum.Int64? cardSize,
    $fixnum.Int64? usedBytes,
    $fixnum.Int64? freeBytes,
    $core.bool? statsValid,
    $core.bool? busy,
    $core.bool? unformatted,
  }) {
    final result = SdCardInfo._();
    if (present != null) result.present = present;
    if (cardType != null) result.cardType = cardType;
    if (fatType != null) result.fatType = fatType;
    if (cardSize != null) result.cardSize = cardSize;
    if (usedBytes != null) result.usedBytes = usedBytes;
    if (freeBytes != null) result.freeBytes = freeBytes;
    if (statsValid != null) result.statsValid = statsValid;
    if (busy != null) result.busy = busy;
    if (unformatted != null) result.unformatted = unformatted;
    return result;
  }

  SdCardInfo._();

  factory SdCardInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SdCardInfo()..mergeFromBuffer(data, registry);
  factory SdCardInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SdCardInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdCardInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: SdCardInfo.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'present')
    ..aE<SdCardInfo_CardType>(2, _omitFieldNames ? '' : 'cardType',
        enumValues: SdCardInfo_CardType.values)
    ..aE<SdCardInfo_FatType>(3, _omitFieldNames ? '' : 'fatType',
        enumValues: SdCardInfo_FatType.values)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'cardSize', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'usedBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'freeBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(7, _omitFieldNames ? '' : 'statsValid')
    ..aOB(8, _omitFieldNames ? '' : 'busy')
    ..aOB(9, _omitFieldNames ? '' : 'unformatted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdCardInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdCardInfo copyWith(void Function(SdCardInfo) updates) =>
      super.copyWith((message) => updates(message as SdCardInfo)) as SdCardInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SdCardInfo() / SdCardInfo.new instead')
  static SdCardInfo create() => SdCardInfo._();
  static $pb.GeneratedMessage $_createMessage() => SdCardInfo._();
  @$core.override
  SdCardInfo createEmptyInstance() => SdCardInfo._();
  @$core.pragma('dart2js:noInline')
  static SdCardInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdCardInfo>(SdCardInfo.$_createMessage);
  static SdCardInfo? _defaultInstance;

  /// Card initialized and usable. False while `busy` is set does not mean
  /// there is no card: the co-processor does not know yet.
  @$pb.TagNumber(1)
  $core.bool get present => $_getBF(0);
  @$pb.TagNumber(1)
  set present($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPresent() => $_has(0);
  @$pb.TagNumber(1)
  void clearPresent() => $_clearField(1);

  @$pb.TagNumber(2)
  SdCardInfo_CardType get cardType => $_getN(1);
  @$pb.TagNumber(2)
  set cardType(SdCardInfo_CardType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCardType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCardType() => $_clearField(2);

  @$pb.TagNumber(3)
  SdCardInfo_FatType get fatType => $_getN(2);
  @$pb.TagNumber(3)
  set fatType(SdCardInfo_FatType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFatType() => $_has(2);
  @$pb.TagNumber(3)
  void clearFatType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get cardSize => $_getI64(3);
  @$pb.TagNumber(4)
  set cardSize($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCardSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearCardSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get usedBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set usedBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUsedBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearUsedBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get freeBytes => $_getI64(5);
  @$pb.TagNumber(6)
  set freeBytes($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFreeBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearFreeBytes() => $_clearField(6);

  /// used_bytes/free_bytes are only meaningful when true: the scan behind
  /// them runs in the background after mount and can take a while, and a
  /// full card is otherwise indistinguishable from a scan in progress
  @$pb.TagNumber(7)
  $core.bool get statsValid => $_getBF(6);
  @$pb.TagNumber(7)
  set statsValid($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatsValid() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatsValid() => $_clearField(7);

  /// The co-processor is mounting a card right now, so whether one is
  /// present is not decided yet. Ask again rather than concluding the slot
  /// is empty.
  @$pb.TagNumber(8)
  $core.bool get busy => $_getBF(7);
  @$pb.TagNumber(8)
  set busy($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBusy() => $_has(7);
  @$pb.TagNumber(8)
  void clearBusy() => $_clearField(8);

  /// A card answers in the slot but carries no filesystem that could be
  /// mounted (present is false then). Formatting it makes it usable.
  @$pb.TagNumber(9)
  $core.bool get unformatted => $_getBF(8);
  @$pb.TagNumber(9)
  set unformatted($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUnformatted() => $_has(8);
  @$pb.TagNumber(9)
  void clearUnformatted() => $_clearField(9);
}

/// Result of an I2CTransaction
class I2CResult extends $pb.GeneratedMessage {
  factory I2CResult({
    I2CResult_Status? status,
    $core.List<$core.int>? readData,
  }) {
    final result = I2CResult._();
    if (status != null) result.status = status;
    if (readData != null) result.readData = readData;
    return result;
  }

  I2CResult._();

  factory I2CResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      I2CResult()..mergeFromBuffer(data, registry);
  factory I2CResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      I2CResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'I2CResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: I2CResult.$_createMessage)
    ..aE<I2CResult_Status>(1, _omitFieldNames ? '' : 'status',
        enumValues: I2CResult_Status.values)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'readData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  I2CResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  I2CResult copyWith(void Function(I2CResult) updates) =>
      super.copyWith((message) => updates(message as I2CResult)) as I2CResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use I2CResult() / I2CResult.new instead')
  static I2CResult create() => I2CResult._();
  static $pb.GeneratedMessage $_createMessage() => I2CResult._();
  @$core.override
  I2CResult createEmptyInstance() => I2CResult._();
  @$core.pragma('dart2js:noInline')
  static I2CResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<I2CResult>(I2CResult.$_createMessage);
  static I2CResult? _defaultInstance;

  @$pb.TagNumber(1)
  I2CResult_Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(I2CResult_Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get readData => $_getN(1);
  @$pb.TagNumber(2)
  set readData($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReadData() => $_has(1);
  @$pb.TagNumber(2)
  void clearReadData() => $_clearField(2);
}

enum InterdeviceMessage_Data {
  nmea,
  beep,
  i2cTransaction,
  i2cResult,
  i2cScan,
  i2cScanResult,
  fileTransfer,
  directoryListing,
  getSdInfo,
  sdInfo,
  ping,
  pong,
  nack,
  sdCommand,
  notSet
}

/// Main message for interdevice communication
class InterdeviceMessage extends $pb.GeneratedMessage {
  factory InterdeviceMessage({
    $core.String? nmea,
    $core.int? beep,
    I2CTransaction? i2cTransaction,
    I2CResult? i2cResult,
    $core.bool? i2cScan,
    $core.List<$core.int>? i2cScanResult,
    FileTransfer? fileTransfer,
    DirectoryListing? directoryListing,
    $core.bool? getSdInfo,
    SdCardInfo? sdInfo,
    InterdeviceVersion? ping,
    InterdeviceVersion? pong,
    $core.bool? nack,
    SdCommand? sdCommand,
    $core.int? id,
  }) {
    final result = InterdeviceMessage._();
    if (nmea != null) result.nmea = nmea;
    if (beep != null) result.beep = beep;
    if (i2cTransaction != null) result.i2cTransaction = i2cTransaction;
    if (i2cResult != null) result.i2cResult = i2cResult;
    if (i2cScan != null) result.i2cScan = i2cScan;
    if (i2cScanResult != null) result.i2cScanResult = i2cScanResult;
    if (fileTransfer != null) result.fileTransfer = fileTransfer;
    if (directoryListing != null) result.directoryListing = directoryListing;
    if (getSdInfo != null) result.getSdInfo = getSdInfo;
    if (sdInfo != null) result.sdInfo = sdInfo;
    if (ping != null) result.ping = ping;
    if (pong != null) result.pong = pong;
    if (nack != null) result.nack = nack;
    if (sdCommand != null) result.sdCommand = sdCommand;
    if (id != null) result.id = id;
    return result;
  }

  InterdeviceMessage._();

  factory InterdeviceMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterdeviceMessage()..mergeFromBuffer(data, registry);
  factory InterdeviceMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InterdeviceMessage()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, InterdeviceMessage_Data>
      _InterdeviceMessage_DataByTag = {
    1: InterdeviceMessage_Data.nmea,
    2: InterdeviceMessage_Data.beep,
    3: InterdeviceMessage_Data.i2cTransaction,
    4: InterdeviceMessage_Data.i2cResult,
    5: InterdeviceMessage_Data.i2cScan,
    6: InterdeviceMessage_Data.i2cScanResult,
    7: InterdeviceMessage_Data.fileTransfer,
    8: InterdeviceMessage_Data.directoryListing,
    9: InterdeviceMessage_Data.getSdInfo,
    10: InterdeviceMessage_Data.sdInfo,
    11: InterdeviceMessage_Data.ping,
    12: InterdeviceMessage_Data.pong,
    13: InterdeviceMessage_Data.nack,
    14: InterdeviceMessage_Data.sdCommand,
    0: InterdeviceMessage_Data.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InterdeviceMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'),
      createEmptyInstance: InterdeviceMessage.$_createMessage)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14])
    ..aOS(1, _omitFieldNames ? '' : 'nmea')
    ..aI(2, _omitFieldNames ? '' : 'beep', fieldType: $pb.PbFieldType.OU3)
    ..aOM<I2CTransaction>(3, _omitFieldNames ? '' : 'i2cTransaction',
        subBuilder: I2CTransaction.$_createMessage)
    ..aOM<I2CResult>(4, _omitFieldNames ? '' : 'i2cResult',
        subBuilder: I2CResult.$_createMessage)
    ..aOB(5, _omitFieldNames ? '' : 'i2cScan')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'i2cScanResult', $pb.PbFieldType.OY)
    ..aOM<FileTransfer>(7, _omitFieldNames ? '' : 'fileTransfer',
        subBuilder: FileTransfer.$_createMessage)
    ..aOM<DirectoryListing>(8, _omitFieldNames ? '' : 'directoryListing',
        subBuilder: DirectoryListing.$_createMessage)
    ..aOB(9, _omitFieldNames ? '' : 'getSdInfo')
    ..aOM<SdCardInfo>(10, _omitFieldNames ? '' : 'sdInfo',
        subBuilder: SdCardInfo.$_createMessage)
    ..aE<InterdeviceVersion>(11, _omitFieldNames ? '' : 'ping',
        enumValues: InterdeviceVersion.values)
    ..aE<InterdeviceVersion>(12, _omitFieldNames ? '' : 'pong',
        enumValues: InterdeviceVersion.values)
    ..aOB(13, _omitFieldNames ? '' : 'nack')
    ..aE<SdCommand>(14, _omitFieldNames ? '' : 'sdCommand',
        enumValues: SdCommand.values)
    ..aI(15, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterdeviceMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InterdeviceMessage copyWith(void Function(InterdeviceMessage) updates) =>
      super.copyWith((message) => updates(message as InterdeviceMessage))
          as InterdeviceMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InterdeviceMessage() / InterdeviceMessage.new instead')
  static InterdeviceMessage create() => InterdeviceMessage._();
  static $pb.GeneratedMessage $_createMessage() => InterdeviceMessage._();
  @$core.override
  InterdeviceMessage createEmptyInstance() => InterdeviceMessage._();
  @$core.pragma('dart2js:noInline')
  static InterdeviceMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InterdeviceMessage>(
          InterdeviceMessage.$_createMessage);
  static InterdeviceMessage? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  InterdeviceMessage_Data whichData() =>
      _InterdeviceMessage_DataByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  void clearData() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get nmea => $_getSZ(0);
  @$pb.TagNumber(1)
  set nmea($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNmea() => $_has(0);
  @$pb.TagNumber(1)
  void clearNmea() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get beep => $_getIZ(1);
  @$pb.TagNumber(2)
  set beep($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBeep() => $_has(1);
  @$pb.TagNumber(2)
  void clearBeep() => $_clearField(2);

  @$pb.TagNumber(3)
  I2CTransaction get i2cTransaction => $_getN(2);
  @$pb.TagNumber(3)
  set i2cTransaction(I2CTransaction value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasI2cTransaction() => $_has(2);
  @$pb.TagNumber(3)
  void clearI2cTransaction() => $_clearField(3);
  @$pb.TagNumber(3)
  I2CTransaction ensureI2cTransaction() => $_ensure(2);

  @$pb.TagNumber(4)
  I2CResult get i2cResult => $_getN(3);
  @$pb.TagNumber(4)
  set i2cResult(I2CResult value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasI2cResult() => $_has(3);
  @$pb.TagNumber(4)
  void clearI2cResult() => $_clearField(4);
  @$pb.TagNumber(4)
  I2CResult ensureI2cResult() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.bool get i2cScan => $_getBF(4);
  @$pb.TagNumber(5)
  set i2cScan($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasI2cScan() => $_has(4);
  @$pb.TagNumber(5)
  void clearI2cScan() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get i2cScanResult => $_getN(5);
  @$pb.TagNumber(6)
  set i2cScanResult($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasI2cScanResult() => $_has(5);
  @$pb.TagNumber(6)
  void clearI2cScanResult() => $_clearField(6);

  @$pb.TagNumber(7)
  FileTransfer get fileTransfer => $_getN(6);
  @$pb.TagNumber(7)
  set fileTransfer(FileTransfer value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasFileTransfer() => $_has(6);
  @$pb.TagNumber(7)
  void clearFileTransfer() => $_clearField(7);
  @$pb.TagNumber(7)
  FileTransfer ensureFileTransfer() => $_ensure(6);

  @$pb.TagNumber(8)
  DirectoryListing get directoryListing => $_getN(7);
  @$pb.TagNumber(8)
  set directoryListing(DirectoryListing value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasDirectoryListing() => $_has(7);
  @$pb.TagNumber(8)
  void clearDirectoryListing() => $_clearField(8);
  @$pb.TagNumber(8)
  DirectoryListing ensureDirectoryListing() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.bool get getSdInfo => $_getBF(8);
  @$pb.TagNumber(9)
  set getSdInfo($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGetSdInfo() => $_has(8);
  @$pb.TagNumber(9)
  void clearGetSdInfo() => $_clearField(9);

  @$pb.TagNumber(10)
  SdCardInfo get sdInfo => $_getN(9);
  @$pb.TagNumber(10)
  set sdInfo(SdCardInfo value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSdInfo() => $_has(9);
  @$pb.TagNumber(10)
  void clearSdInfo() => $_clearField(10);
  @$pb.TagNumber(10)
  SdCardInfo ensureSdInfo() => $_ensure(9);

  /// Link liveness probe and version handshake. The receiver answers ping
  /// with pong, echoing the id. Touches no peripherals, so it works with
  /// nothing attached. Both carry the version the sender speaks; a peer
  /// that answers with a different one speaks another protocol and must
  /// not be used.
  @$pb.TagNumber(11)
  InterdeviceVersion get ping => $_getN(10);
  @$pb.TagNumber(11)
  set ping(InterdeviceVersion value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasPing() => $_has(10);
  @$pb.TagNumber(11)
  void clearPing() => $_clearField(11);

  @$pb.TagNumber(12)
  InterdeviceVersion get pong => $_getN(11);
  @$pb.TagNumber(12)
  set pong(InterdeviceVersion value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasPong() => $_has(11);
  @$pb.TagNumber(12)
  void clearPong() => $_clearField(12);

  /// Response: the request could not be decoded or is of an unhandled
  /// type, so the requester fails fast instead of burning its timeout.
  /// Echoes the id when known, 0 when the frame was undecodable. Never
  /// sent in reaction to a nack.
  @$pb.TagNumber(13)
  $core.bool get nack => $_getBF(12);
  @$pb.TagNumber(13)
  set nack($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasNack() => $_has(12);
  @$pb.TagNumber(13)
  void clearNack() => $_clearField(13);

  /// Request: mount the card, or release it so it can be pulled safely. The
  /// co-processor answers with sd_info. Without an eject the card is mounted
  /// on its own and kept mounted; after one it stays released until a mount
  /// is asked for.
  @$pb.TagNumber(14)
  SdCommand get sdCommand => $_getN(13);
  @$pb.TagNumber(14)
  set sdCommand(SdCommand value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasSdCommand() => $_has(13);
  @$pb.TagNumber(14)
  void clearSdCommand() => $_clearField(14);

  /// Correlates a response with its request: responses echo the id of the
  /// request they answer. 0 for unsolicited messages (e.g. the nmea stream).
  @$pb.TagNumber(15)
  $core.int get id => $_getIZ(14);
  @$pb.TagNumber(15)
  set id($core.int value) => $_setUnsignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasId() => $_has(14);
  @$pb.TagNumber(15)
  void clearId() => $_clearField(15);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
