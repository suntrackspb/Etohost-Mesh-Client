// This is a generated file - do not edit.
//
// Generated from meshtastic/interdevice.proto.

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

@$core.Deprecated('Use interdeviceVersionDescriptor instead')
const InterdeviceVersion$json = {
  '1': 'InterdeviceVersion',
  '2': [
    {'1': 'INTERDEVICE_VERSION_UNSPECIFIED', '2': 0},
    {'1': 'INTERDEVICE_VERSION_CURRENT', '2': 2},
  ],
};

/// Descriptor for `InterdeviceVersion`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List interdeviceVersionDescriptor = $convert.base64Decode(
    'ChJJbnRlcmRldmljZVZlcnNpb24SIwofSU5URVJERVZJQ0VfVkVSU0lPTl9VTlNQRUNJRklFRB'
    'AAEh8KG0lOVEVSREVWSUNFX1ZFUlNJT05fQ1VSUkVOVBAC');

@$core.Deprecated('Use fileOperationDescriptor instead')
const FileOperation$json = {
  '1': 'FileOperation',
  '2': [
    {'1': 'GET', '2': 0},
    {'1': 'POST', '2': 1},
    {'1': 'PUT', '2': 2},
    {'1': 'DELETE', '2': 3},
  ],
};

/// Descriptor for `FileOperation`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List fileOperationDescriptor = $convert.base64Decode(
    'Cg1GaWxlT3BlcmF0aW9uEgcKA0dFVBAAEggKBFBPU1QQARIHCgNQVVQQAhIKCgZERUxFVEUQAw'
    '==');

@$core.Deprecated('Use fileStatusDescriptor instead')
const FileStatus$json = {
  '1': 'FileStatus',
  '2': [
    {'1': 'FILE_UNSPECIFIED', '2': 0},
    {'1': 'FILE_OK', '2': 1},
    {'1': 'FILE_BUSY', '2': 2},
    {'1': 'FILE_NO_CARD', '2': 3},
    {'1': 'FILE_NOT_FOUND', '2': 4},
    {'1': 'FILE_OFFSET_CONFLICT', '2': 5},
    {'1': 'FILE_IO_ERROR', '2': 6},
    {'1': 'FILE_NOT_A_FILE', '2': 7},
  ],
};

/// Descriptor for `FileStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List fileStatusDescriptor = $convert.base64Decode(
    'CgpGaWxlU3RhdHVzEhQKEEZJTEVfVU5TUEVDSUZJRUQQABILCgdGSUxFX09LEAESDQoJRklMRV'
    '9CVVNZEAISEAoMRklMRV9OT19DQVJEEAMSEgoORklMRV9OT1RfRk9VTkQQBBIYChRGSUxFX09G'
    'RlNFVF9DT05GTElDVBAFEhEKDUZJTEVfSU9fRVJST1IQBhITCg9GSUxFX05PVF9BX0ZJTEUQBw'
    '==');

@$core.Deprecated('Use sdCommandDescriptor instead')
const SdCommand$json = {
  '1': 'SdCommand',
  '2': [
    {'1': 'SD_COMMAND_UNSPECIFIED', '2': 0},
    {'1': 'SD_MOUNT', '2': 1},
    {'1': 'SD_EJECT', '2': 2},
    {'1': 'SD_FORMAT', '2': 3},
  ],
};

/// Descriptor for `SdCommand`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sdCommandDescriptor = $convert.base64Decode(
    'CglTZENvbW1hbmQSGgoWU0RfQ09NTUFORF9VTlNQRUNJRklFRBAAEgwKCFNEX01PVU5UEAESDA'
    'oIU0RfRUpFQ1QQAhINCglTRF9GT1JNQVQQAw==');

@$core.Deprecated('Use fileTransferDescriptor instead')
const FileTransfer$json = {
  '1': 'FileTransfer',
  '2': [
    {
      '1': 'operation',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.FileOperation',
      '10': 'operation'
    },
    {'1': 'filepath', '3': 2, '4': 1, '5': 9, '10': 'filepath'},
    {'1': 'filedata', '3': 3, '4': 1, '5': 12, '10': 'filedata'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.FileStatus',
      '10': 'status'
    },
    {'1': 'message', '3': 5, '4': 1, '5': 9, '10': 'message'},
    {'1': 'offset', '3': 6, '4': 1, '5': 4, '10': 'offset'},
    {'1': 'length', '3': 7, '4': 1, '5': 13, '10': 'length'},
    {'1': 'file_size', '3': 8, '4': 1, '5': 4, '10': 'fileSize'},
  ],
};

/// Descriptor for `FileTransfer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileTransferDescriptor = $convert.base64Decode(
    'CgxGaWxlVHJhbnNmZXISNwoJb3BlcmF0aW9uGAEgASgOMhkubWVzaHRhc3RpYy5GaWxlT3Blcm'
    'F0aW9uUglvcGVyYXRpb24SGgoIZmlsZXBhdGgYAiABKAlSCGZpbGVwYXRoEhoKCGZpbGVkYXRh'
    'GAMgASgMUghmaWxlZGF0YRIuCgZzdGF0dXMYBCABKA4yFi5tZXNodGFzdGljLkZpbGVTdGF0dX'
    'NSBnN0YXR1cxIYCgdtZXNzYWdlGAUgASgJUgdtZXNzYWdlEhYKBm9mZnNldBgGIAEoBFIGb2Zm'
    'c2V0EhYKBmxlbmd0aBgHIAEoDVIGbGVuZ3RoEhsKCWZpbGVfc2l6ZRgIIAEoBFIIZmlsZVNpem'
    'U=');

@$core.Deprecated('Use directoryListingDescriptor instead')
const DirectoryListing$json = {
  '1': 'DirectoryListing',
  '2': [
    {'1': 'directory', '3': 1, '4': 1, '5': 9, '10': 'directory'},
    {'1': 'filenames', '3': 2, '4': 3, '5': 9, '10': 'filenames'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.FileStatus',
      '10': 'status'
    },
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {'1': 'offset', '3': 5, '4': 1, '5': 13, '10': 'offset'},
    {'1': 'total_count', '3': 6, '4': 1, '5': 13, '10': 'totalCount'},
  ],
};

/// Descriptor for `DirectoryListing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List directoryListingDescriptor = $convert.base64Decode(
    'ChBEaXJlY3RvcnlMaXN0aW5nEhwKCWRpcmVjdG9yeRgBIAEoCVIJZGlyZWN0b3J5EhwKCWZpbG'
    'VuYW1lcxgCIAMoCVIJZmlsZW5hbWVzEi4KBnN0YXR1cxgDIAEoDjIWLm1lc2h0YXN0aWMuRmls'
    'ZVN0YXR1c1IGc3RhdHVzEhgKB21lc3NhZ2UYBCABKAlSB21lc3NhZ2USFgoGb2Zmc2V0GAUgAS'
    'gNUgZvZmZzZXQSHwoLdG90YWxfY291bnQYBiABKA1SCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use i2CTransactionDescriptor instead')
const I2CTransaction$json = {
  '1': 'I2CTransaction',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 13, '10': 'address'},
    {'1': 'write_data', '3': 2, '4': 1, '5': 12, '10': 'writeData'},
    {'1': 'read_len', '3': 3, '4': 1, '5': 13, '10': 'readLen'},
  ],
};

/// Descriptor for `I2CTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List i2CTransactionDescriptor = $convert.base64Decode(
    'Cg5JMkNUcmFuc2FjdGlvbhIYCgdhZGRyZXNzGAEgASgNUgdhZGRyZXNzEh0KCndyaXRlX2RhdG'
    'EYAiABKAxSCXdyaXRlRGF0YRIZCghyZWFkX2xlbhgDIAEoDVIHcmVhZExlbg==');

@$core.Deprecated('Use sdCardInfoDescriptor instead')
const SdCardInfo$json = {
  '1': 'SdCardInfo',
  '2': [
    {'1': 'present', '3': 1, '4': 1, '5': 8, '10': 'present'},
    {
      '1': 'card_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.SdCardInfo.CardType',
      '10': 'cardType'
    },
    {
      '1': 'fat_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.SdCardInfo.FatType',
      '10': 'fatType'
    },
    {'1': 'card_size', '3': 4, '4': 1, '5': 4, '10': 'cardSize'},
    {'1': 'used_bytes', '3': 5, '4': 1, '5': 4, '10': 'usedBytes'},
    {'1': 'free_bytes', '3': 6, '4': 1, '5': 4, '10': 'freeBytes'},
    {'1': 'stats_valid', '3': 7, '4': 1, '5': 8, '10': 'statsValid'},
    {'1': 'busy', '3': 8, '4': 1, '5': 8, '10': 'busy'},
    {'1': 'unformatted', '3': 9, '4': 1, '5': 8, '10': 'unformatted'},
  ],
  '4': [SdCardInfo_CardType$json, SdCardInfo_FatType$json],
};

@$core.Deprecated('Use sdCardInfoDescriptor instead')
const SdCardInfo_CardType$json = {
  '1': 'CardType',
  '2': [
    {'1': 'NONE', '2': 0},
    {'1': 'MMC', '2': 1},
    {'1': 'SD', '2': 2},
    {'1': 'SDHC', '2': 3},
    {'1': 'SDXC', '2': 4},
    {'1': 'UNKNOWN_CARD', '2': 5},
  ],
};

@$core.Deprecated('Use sdCardInfoDescriptor instead')
const SdCardInfo_FatType$json = {
  '1': 'FatType',
  '2': [
    {'1': 'UNKNOWN_FAT', '2': 0},
    {'1': 'FAT16', '2': 1},
    {'1': 'FAT32', '2': 2},
    {'1': 'EXFAT', '2': 3},
  ],
};

/// Descriptor for `SdCardInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sdCardInfoDescriptor = $convert.base64Decode(
    'CgpTZENhcmRJbmZvEhgKB3ByZXNlbnQYASABKAhSB3ByZXNlbnQSPAoJY2FyZF90eXBlGAIgAS'
    'gOMh8ubWVzaHRhc3RpYy5TZENhcmRJbmZvLkNhcmRUeXBlUghjYXJkVHlwZRI5CghmYXRfdHlw'
    'ZRgDIAEoDjIeLm1lc2h0YXN0aWMuU2RDYXJkSW5mby5GYXRUeXBlUgdmYXRUeXBlEhsKCWNhcm'
    'Rfc2l6ZRgEIAEoBFIIY2FyZFNpemUSHQoKdXNlZF9ieXRlcxgFIAEoBFIJdXNlZEJ5dGVzEh0K'
    'CmZyZWVfYnl0ZXMYBiABKARSCWZyZWVCeXRlcxIfCgtzdGF0c192YWxpZBgHIAEoCFIKc3RhdH'
    'NWYWxpZBISCgRidXN5GAggASgIUgRidXN5EiAKC3VuZm9ybWF0dGVkGAkgASgIUgt1bmZvcm1h'
    'dHRlZCJLCghDYXJkVHlwZRIICgROT05FEAASBwoDTU1DEAESBgoCU0QQAhIICgRTREhDEAMSCA'
    'oEU0RYQxAEEhAKDFVOS05PV05fQ0FSRBAFIjsKB0ZhdFR5cGUSDwoLVU5LTk9XTl9GQVQQABIJ'
    'CgVGQVQxNhABEgkKBUZBVDMyEAISCQoFRVhGQVQQAw==');

@$core.Deprecated('Use i2CResultDescriptor instead')
const I2CResult$json = {
  '1': 'I2CResult',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.I2CResult.Status',
      '10': 'status'
    },
    {'1': 'read_data', '3': 2, '4': 1, '5': 12, '10': 'readData'},
  ],
  '4': [I2CResult_Status$json],
};

@$core.Deprecated('Use i2CResultDescriptor instead')
const I2CResult_Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'UNSPECIFIED', '2': 0},
    {'1': 'OK', '2': 1},
    {'1': 'NACK_ADDRESS', '2': 2},
    {'1': 'NACK_DATA', '2': 3},
    {'1': 'ERROR', '2': 4},
  ],
};

/// Descriptor for `I2CResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List i2CResultDescriptor = $convert.base64Decode(
    'CglJMkNSZXN1bHQSNAoGc3RhdHVzGAEgASgOMhwubWVzaHRhc3RpYy5JMkNSZXN1bHQuU3RhdH'
    'VzUgZzdGF0dXMSGwoJcmVhZF9kYXRhGAIgASgMUghyZWFkRGF0YSJNCgZTdGF0dXMSDwoLVU5T'
    'UEVDSUZJRUQQABIGCgJPSxABEhAKDE5BQ0tfQUREUkVTUxACEg0KCU5BQ0tfREFUQRADEgkKBU'
    'VSUk9SEAQ=');

@$core.Deprecated('Use interdeviceMessageDescriptor instead')
const InterdeviceMessage$json = {
  '1': 'InterdeviceMessage',
  '2': [
    {'1': 'id', '3': 15, '4': 1, '5': 13, '10': 'id'},
    {'1': 'nmea', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'nmea'},
    {'1': 'beep', '3': 2, '4': 1, '5': 13, '9': 0, '10': 'beep'},
    {
      '1': 'i2c_transaction',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.I2CTransaction',
      '9': 0,
      '10': 'i2cTransaction'
    },
    {
      '1': 'i2c_result',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.I2CResult',
      '9': 0,
      '10': 'i2cResult'
    },
    {'1': 'i2c_scan', '3': 5, '4': 1, '5': 8, '9': 0, '10': 'i2cScan'},
    {
      '1': 'i2c_scan_result',
      '3': 6,
      '4': 1,
      '5': 12,
      '9': 0,
      '10': 'i2cScanResult'
    },
    {
      '1': 'file_transfer',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.FileTransfer',
      '9': 0,
      '10': 'fileTransfer'
    },
    {
      '1': 'directory_listing',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.DirectoryListing',
      '9': 0,
      '10': 'directoryListing'
    },
    {'1': 'get_sd_info', '3': 9, '4': 1, '5': 8, '9': 0, '10': 'getSdInfo'},
    {
      '1': 'sd_info',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.meshtastic.SdCardInfo',
      '9': 0,
      '10': 'sdInfo'
    },
    {
      '1': 'ping',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.InterdeviceVersion',
      '9': 0,
      '10': 'ping'
    },
    {
      '1': 'pong',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.InterdeviceVersion',
      '9': 0,
      '10': 'pong'
    },
    {'1': 'nack', '3': 13, '4': 1, '5': 8, '9': 0, '10': 'nack'},
    {
      '1': 'sd_command',
      '3': 14,
      '4': 1,
      '5': 14,
      '6': '.meshtastic.SdCommand',
      '9': 0,
      '10': 'sdCommand'
    },
  ],
  '8': [
    {'1': 'data'},
  ],
};

/// Descriptor for `InterdeviceMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List interdeviceMessageDescriptor = $convert.base64Decode(
    'ChJJbnRlcmRldmljZU1lc3NhZ2USDgoCaWQYDyABKA1SAmlkEhQKBG5tZWEYASABKAlIAFIEbm'
    '1lYRIUCgRiZWVwGAIgASgNSABSBGJlZXASRQoPaTJjX3RyYW5zYWN0aW9uGAMgASgLMhoubWVz'
    'aHRhc3RpYy5JMkNUcmFuc2FjdGlvbkgAUg5pMmNUcmFuc2FjdGlvbhI2CgppMmNfcmVzdWx0GA'
    'QgASgLMhUubWVzaHRhc3RpYy5JMkNSZXN1bHRIAFIJaTJjUmVzdWx0EhsKCGkyY19zY2FuGAUg'
    'ASgISABSB2kyY1NjYW4SKAoPaTJjX3NjYW5fcmVzdWx0GAYgASgMSABSDWkyY1NjYW5SZXN1bH'
    'QSPwoNZmlsZV90cmFuc2ZlchgHIAEoCzIYLm1lc2h0YXN0aWMuRmlsZVRyYW5zZmVySABSDGZp'
    'bGVUcmFuc2ZlchJLChFkaXJlY3RvcnlfbGlzdGluZxgIIAEoCzIcLm1lc2h0YXN0aWMuRGlyZW'
    'N0b3J5TGlzdGluZ0gAUhBkaXJlY3RvcnlMaXN0aW5nEiAKC2dldF9zZF9pbmZvGAkgASgISABS'
    'CWdldFNkSW5mbxIxCgdzZF9pbmZvGAogASgLMhYubWVzaHRhc3RpYy5TZENhcmRJbmZvSABSBn'
    'NkSW5mbxI0CgRwaW5nGAsgASgOMh4ubWVzaHRhc3RpYy5JbnRlcmRldmljZVZlcnNpb25IAFIE'
    'cGluZxI0CgRwb25nGAwgASgOMh4ubWVzaHRhc3RpYy5JbnRlcmRldmljZVZlcnNpb25IAFIEcG'
    '9uZxIUCgRuYWNrGA0gASgISABSBG5hY2sSNgoKc2RfY29tbWFuZBgOIAEoDjIVLm1lc2h0YXN0'
    'aWMuU2RDb21tYW5kSABSCXNkQ29tbWFuZEIGCgRkYXRh');
