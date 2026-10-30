import 'dart:convert';
import 'dart:math';

import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/fields.dart';
import 'package:meshex/data/settings/security_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final key = base64.encode(List.filled(32, 7));

  test('ключ: пусто или 32 байта base64', () {
    expect(SecurityKey.isValid(''), isTrue);
    expect(SecurityKey.isValid(key), isTrue);
    expect(SecurityKey.isValid(base64.encode([1, 2, 3])), isFalse);
    expect(SecurityKey.isValid('не base64'), isFalse);
  });

  test('новый закрытый ключ «зажат» по Curve25519', () {
    final k = SecurityKey.generatePrivate(Random(1));
    expect(k.length, 32);
    expect(k[0] & 0x07, 0);
    expect(k[31] & 0xC0, 0x40);
  });

  test('публичный ключ X25519 по RFC 7748', () async {
    // RFC 7748 §6.1: закрытый ключ Алисы → публичный.
    final priv = _hex(
      '77076d0a7318a57d3c16c17251b26645df4c2f87ebc0992ab177fba51db92c2a',
    );
    final pub = await SecurityKey.publicFor(priv);
    expect(
      pub,
      _hex('8520f0098930a754748b7ddcb43ef75a0dbf3a0d26381af4eba4a98eaa9b4e6a'),
    );
  });

  test('без ключа админа управляемый режим выключается', () {
    final v = SecuritySection.read(
      Config_SecurityConfig(isManaged: true, adminKey: [base64.decode(key)]),
    );
    expect(SecuritySection.hasAdminKey(v), isTrue);
    v['adminKey0'] = '';
    SecuritySection.adjust(v);
    expect(v['isManaged'], isFalse);
  });

  test('apply: три позиции ключей админа и публичный из закрытого', () async {
    final base = Config_SecurityConfig(adminChannelEnabled: true);
    final v = SecuritySection.read(base)
      ..['privateKey'] = key
      ..['adminKey1'] = key;
    final out = await SecuritySection.apply(base, v);
    expect(out.adminKey.map((k) => k.length), [0, 32, 0]);
    expect(out.publicKey, await SecurityKey.publicFor(base64.decode(key)));
    expect(out.adminChannelEnabled, isTrue);
  });

  test(
    'политика подписи: недоступна без поддержки, Strict с подтверждением',
    () {
      ChoiceFieldSpec policy(bool? x) =>
          SecuritySection.fields(xeddsa: x).first as ChoiceFieldSpec;
      expect(policy(true).enabled(const {}), isTrue);
      expect(policy(null).enabled(const {}), isFalse);
      expect(policy(false).helpFor!(0), SecuritySection.unsupported);
      expect(policy(true).confirmFor!(2), SecuritySection.strictConfirm);
      expect(policy(true).confirmFor!(1), isNull);
    },
  );
}

List<int> _hex(String s) => [
  for (var i = 0; i < s.length; i += 2)
    int.parse(s.substring(i, i + 2), radix: 16),
];
