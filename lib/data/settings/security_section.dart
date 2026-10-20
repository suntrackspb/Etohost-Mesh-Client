import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Ключ Curve25519 (32 байта) в виде base64, как в iOS и Android.
abstract final class SecurityKey {
  static const byteCount = 32;
  static const slots = 3;

  /// Пусто — «не задан»; иначе ровно 32 байта в base64.
  static bool isValid(String text) => text.isEmpty || decode(text) != null;

  static Uint8List? decode(String text) {
    try {
      final b = base64.decode(text);
      return b.length == byteCount ? b : null;
    } on FormatException {
      return null;
    }
  }

  static String encode(List<int> data) =>
      data.isEmpty ? '' : base64.encode(data);

  /// Новый закрытый ключ с «зажимом» Curve25519, как generatePrivateKey в iOS.
  static Uint8List generatePrivate([Random? random]) {
    final r = random ?? Random.secure();
    final f = Uint8List.fromList(
      List.generate(byteCount, (_) => r.nextInt(256)),
    );
    f[0] &= 0xF8;
    f[31] = (f[31] & 0x7F) | 0x40;
    return f;
  }

  /// Публичный ключ X25519 из закрытого; null — ключ неверной длины.
  static Future<Uint8List?> publicFor(List<int> privateKey) async {
    if (privateKey.length != byteCount) return null;
    final pair = await X25519().newKeyPairFromSeed(privateKey);
    final pub = await pair.extractPublicKey();
    return Uint8List.fromList(pub.bytes);
  }
}

/// Раздел «Безопасность»: SecurityConfig.swift и PacketAuthenticity.swift
/// (iOS). Подписи — iOS ru, затем Android ru, затем английские.
/// admin_channel_enabled не показывается (как в iOS) и сохраняется как есть.
/// Lockdown и резервная копия ключа в iCloud — пока нет.
abstract final class SecuritySection {
  static const title = 'Настройки безопасности';
  static const saveConfirm = 'Сохранить настройки безопасности?';
  static const groupAuthenticity = 'Подлинность пакета';
  static const groupDirect = 'Ключ личных переписок';
  static const groupAdmin = 'Ключи админа';
  static const groupLogs = 'Журналы';
  static const groupAdministration = 'Администрирование';

  static const keyError = 'Ключ — 32 байта в base64';
  static const publicKeyLabel = 'Публичный ключ';
  static const publicKeyHelp =
      'Generated from your private key and sent out to other nodes on the '
      'mesh to allow them to compute a shared secret key';
  static const regenerateLabel = 'Создать заново закрытый ключ';
  static const regenerateHelp =
      'Создать новый закрытый ключ для замены текущего. Открытый ключ будет '
      'автоматически создан из вашего закрытого ключа.';
  static const regenerateConfirm =
      'Вы уверены, что хотите пересоздать свой приватный ключ?\n\nНоды, '
      'которые ранее обменивались ключами с этой нодой, должны будут удалить '
      'её и повторно обменяться ключами для того, чтобы возобновить '
      'защищённую связь.';
  static const managedNeedsAdmin =
      'An admin key must be set before enabling managed mode.';
  static const unknownXeddsa =
      'This device has not reported whether it supports packet signature '
      'verification. Update its firmware to configure this setting.';

  static const adminTitles = [
    'Первичный ключ администратора',
    'Второй ключ админа',
    'Третичный ключ администратора',
  ];

  static const policies = <Choice>[
    (value: 0, label: 'Compatible — Accept unsigned'),
    (value: 1, label: 'Balanced — Prefer authenticated'),
    (value: 2, label: 'Strict — Require authentication'),
  ];
  static const strictPolicy = 2;

  static String policyHelp(int v) => switch (v) {
    0 =>
      'Для максимальной совместимости принимать трафик без цифровой '
          'подписи. Пакет все равно будет отброшен, если подпись неверна и ее '
          'возможно проверить.',
    1 =>
      'Recommended. Reject unsigned downgrade attempts from nodes known to '
          'sign.',
    2 =>
      'Показывать и обрабатывать только криптографически '
          'аутентифицированные mesh-пакеты. Старые ноды и слишком большие '
          'пакеты могут исчезнуть.',
    _ =>
      'This device reported a packet authenticity policy that this app '
          'version does not recognize.',
  };

  static const unsupported =
      'Это подключенное устройство не поддерживает верификацию подписи '
      'пакетов.';
  static const strictConfirm =
      'Строгий игнорирует любые удалённые mesh-пакеты, которые не прошли '
      'криптографическую аутентификацию. Более старая прошивка, '
      'лицензированные устройства или ноды Ham без PKI-ключей и слишком '
      'большие пакеты могут перестать работать. Прямые сообщения с '
      'PKI-аутентификацией остаются доступными.';

  static String adminKey(int slot) => 'adminKey$slot';

  static bool hasAdminKey(Map<String, Object?> v) => [
    for (var i = 0; i < SecurityKey.slots; i++) v[adminKey(i)] as String? ?? '',
  ].any((s) => s.isNotEmpty && SecurityKey.isValid(s));

  /// [xeddsa]: поддержка подписи по metadata; null — нода не сообщила.
  static List<FieldSpec<Object?>> fields({required bool? xeddsa}) => [
    ChoiceFieldSpec(
      'packetSignaturePolicy',
      'Уровень защиты',
      policies,
      group: groupAuthenticity,
      enabledWhen: (_) => xeddsa == true,
      unknownLabel: (_) => 'Unknown policy',
      helpFor: (v) => xeddsa == false ? unsupported : policyHelp(v),
      confirmFor: (v) => v == strictPolicy ? strictConfirm : null,
    ),
    TextFieldSpec(
      'privateKey',
      'Закрытый ключ',
      group: groupDirect,
      maxBytes: 64,
      secure: true,
      validator: (s) => SecurityKey.isValid(s) ? null : keyError,
      help: 'Used to create a shared key with a remote device',
    ),
    for (var i = 0; i < SecurityKey.slots; i++)
      TextFieldSpec(
        adminKey(i),
        adminTitles[i],
        group: groupAdmin,
        maxBytes: 64,
        secure: true,
        validator: (s) => SecurityKey.isValid(s) ? null : keyError,
        help: i == SecurityKey.slots - 1
            ? 'The public key authorized to send admin messages to this node'
            : null,
      ),
    const BoolFieldSpec(
      'serialEnabled',
      'Консоль последовательного порта',
      group: groupLogs,
      help: 'Консоль последовательного порта через Stream API.',
    ),
    const BoolFieldSpec(
      'debugLogApiEnabled',
      'Журнал отладки',
      group: groupLogs,
      help:
          'Вывод отладочного журнала в реальном времени через '
          'последовательный порт, просмотр и экспорт журналов устройства со '
          'скрытыми позициями через Bluetooth.',
    ),
    BoolFieldSpec(
      'isManaged',
      'Управляемое устройство',
      group: groupAdministration,
      enabledWhen: hasAdminKey,
      help:
          'Устройством управляет администратор сети, пользователь не может '
          'получить доступ ни к одной настройке устройства.',
    ),
  ];

  /// Без ключа администратора управляемый режим запирает ноду навсегда.
  static void adjust(Map<String, Object?> v) {
    if (!hasAdminKey(v)) v['isManaged'] = false;
  }

  static Map<String, Object?> read(Config_SecurityConfig c) => {
    'packetSignaturePolicy': c.packetSignaturePolicy.value,
    'privateKey': SecurityKey.encode(c.privateKey),
    for (var i = 0; i < SecurityKey.slots; i++)
      adminKey(i): i < c.adminKey.length
          ? SecurityKey.encode(c.adminKey[i])
          : '',
    'serialEnabled': c.serialEnabled,
    'debugLogApiEnabled': c.debugLogApiEnabled,
    'isManaged': c.isManaged,
  };

  /// Публичный ключ берётся из закрытого. Массив ключей админа — всегда три
  /// позиции: пустая тоже занимает место, иначе ключи сдвинутся.
  static Future<Config_SecurityConfig> apply(
    Config_SecurityConfig base,
    Map<String, Object?> v,
  ) async {
    final priv = SecurityKey.decode(v['privateKey']! as String);
    final out = base.deepCopy()
      ..serialEnabled = v['serialEnabled']! as bool
      ..debugLogApiEnabled = v['debugLogApiEnabled']! as bool
      ..isManaged = v['isManaged']! as bool;
    final policy = Config_SecurityConfig_PacketSignaturePolicy.valueOf(
      v['packetSignaturePolicy']! as int,
    );
    if (policy != null) out.packetSignaturePolicy = policy;
    out.privateKey = priv ?? Uint8List(0);
    if (priv != null) out.publicKey = (await SecurityKey.publicFor(priv))!;
    out.adminKey
      ..clear()
      ..addAll([
        for (var i = 0; i < SecurityKey.slots; i++)
          SecurityKey.decode(v[adminKey(i)]! as String) ?? Uint8List(0),
      ]);
    return out;
  }

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    Config_SecurityConfig base,
    Map<String, Object?> v,
  ) async =>
      saveConfig(admin, db, 'security', Config(security: await apply(base, v)));
}
