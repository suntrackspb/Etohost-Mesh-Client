import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/proto/mesh.dart';
import 'security_section.dart';

/// Резервная копия закрытого ключа ноды (iOS — связка ключей iCloud,
/// Android — SecurityKeyBackupStore). Храним по номеру ноды; в 2.8 номер
/// выводится из ключа, поэтому после сброса копия может лежать под другим
/// номером — восстанавливать можно из любой.
class KeyBackup {
  const KeyBackup({
    required this.nodeNum,
    required this.publicKey,
    required this.privateKey,
    required this.time,
    this.longName,
  });

  final int nodeNum;
  final String publicKey;
  final String privateKey;
  final DateTime time;
  final String? longName;

  /// Копия из закрытого ключа (base64); null — ключ неверный.
  static Future<KeyBackup?> make(
    int num,
    String privateKey, {
    String? longName,
    DateTime? now,
  }) async {
    final priv = SecurityKey.decode(privateKey);
    if (priv == null) return null;
    final pub = await SecurityKey.publicFor(priv);
    return KeyBackup(
      nodeNum: num,
      publicKey: SecurityKey.encode(pub!),
      privateKey: privateKey,
      time: now ?? DateTime.now(),
      longName: longName,
    );
  }

  /// «Имя (!id)» для выбора копии.
  String get label =>
      '${longName?.isNotEmpty == true ? '$longName ' : ''}(${nodeIdString(nodeNum)})';

  Map<String, Object?> toJson() => {
    'num': nodeNum,
    'pub': publicKey,
    'priv': privateKey,
    'time': time.millisecondsSinceEpoch,
    if (longName != null) 'name': longName,
  };

  static KeyBackup? fromJson(String raw) {
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final priv = j['priv'] as String;
      if (SecurityKey.decode(priv) == null) return null;
      return KeyBackup(
        nodeNum: j['num'] as int,
        publicKey: j['pub'] as String? ?? '',
        privateKey: priv,
        time: DateTime.fromMillisecondsSinceEpoch(j['time'] as int),
        longName: j['name'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Минимум защищённого хранилища — для подмены в тестах.
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<Map<String, String>> readAll();
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Системное хранилище секретов. iOS — связка ключей с синхронизацией
/// iCloud (как в Meshtastic-Apple); macOS — без data protection keychain,
/// иначе нужен entitlement Keychain Sharing с профилем подготовки.
class PlatformSecretStore implements SecretStore {
  PlatformSecretStore()
    : _s = const FlutterSecureStorage(
        iOptions: IOSOptions(
          synchronizable: true,
          accessibility: KeychainAccessibility.unlocked,
        ),
        mOptions: MacOsOptions(usesDataProtectionKeychain: false),
      );

  final FlutterSecureStorage _s;

  @override
  Future<String?> read(String key) => _s.read(key: key);
  @override
  Future<Map<String, String>> readAll() => _s.readAll();
  @override
  Future<void> write(String key, String value) =>
      _s.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _s.delete(key: key);
}

class KeyBackupStore {
  KeyBackupStore(this._store);

  final SecretStore _store;
  static const _prefix = 'keyBackup.';

  static String _key(int num) => '$_prefix$num';

  Future<KeyBackup?> get(int num) async {
    final raw = await _store.read(_key(num));
    return raw == null ? null : KeyBackup.fromJson(raw);
  }

  /// Все копии, новые сверху.
  Future<List<KeyBackup>> all() async {
    final m = await _store.readAll();
    return [
      for (final e in m.entries)
        if (e.key.startsWith(_prefix)) ?KeyBackup.fromJson(e.value),
    ]..sort((a, b) => b.time.compareTo(a.time));
  }

  /// Сохранить закрытый ключ [privateKey] (base64). Публичный — из него.
  Future<KeyBackup?> save(
    int num,
    String privateKey, {
    String? longName,
    DateTime? now,
  }) async {
    final b = await KeyBackup.make(
      num,
      privateKey,
      longName: longName,
      now: now,
    );
    if (b != null) await _store.write(_key(num), jsonEncode(b.toJson()));
    return b;
  }

  Future<void> delete(int num) => _store.delete(_key(num));
}

/// Файл резервной копии ключей (JSON, свой формат: у официальных клиентов
/// выгрузки ключей в файл нет). Один файл может нести несколько копий.
abstract final class KeyBackupFile {
  static const format = 'meshex-keys';
  static const version = 1;
  static const extension = 'json';

  static String fileName(int num) =>
      'meshtastic-key-${nodeIdString(num).substring(1)}.$extension';

  static Uint8List encode(List<KeyBackup> keys) => Uint8List.fromList(
    utf8.encode(
      const JsonEncoder.withIndent('  ').convert({
        'format': format,
        'version': version,
        'keys': [for (final k in keys) k.toJson()],
      }),
    ),
  );

  /// Копии из файла; ошибка — [FormatException] с текстом для UI.
  static List<KeyBackup> decode(List<int> bytes) {
    final Object? j;
    try {
      j = jsonDecode(utf8.decode(bytes));
    } catch (_) {
      throw const FormatException('Файл не похож на резервную копию ключа');
    }
    if (j is! Map<String, dynamic> || j['format'] != format) {
      throw const FormatException('Файл не похож на резервную копию ключа');
    }
    final v = j['version'];
    if (v is! int || v > version) {
      throw const FormatException(
        'Файл сохранён более новой версией приложения',
      );
    }
    final keys = [
      for (final k in (j['keys'] as List? ?? const []))
        if (k is Map<String, dynamic>) ?KeyBackup.fromJson(jsonEncode(k)),
    ];
    if (keys.isEmpty) {
      throw const FormatException('В файле нет ключей');
    }
    return keys;
  }
}
