import 'dart:convert';

import 'package:etohost_mesh/data/settings/key_backup.dart';
import 'package:etohost_mesh/data/settings/security_section.dart';
import 'package:flutter_test/flutter_test.dart';

class _Mem implements SecretStore {
  final m = <String, String>{};
  @override
  Future<String?> read(String key) async => m[key];
  @override
  Future<Map<String, String>> readAll() async => {...m};
  @override
  Future<void> write(String key, String value) async => m[key] = value;
  @override
  Future<void> delete(String key) async => m.remove(key);
}

void main() {
  final priv = SecurityKey.encode(SecurityKey.generatePrivate());
  final priv2 = SecurityKey.encode(SecurityKey.generatePrivate());

  test('store: save, get, all newest first, delete', () async {
    final mem = _Mem()..m['other'] = 'x';
    final s = KeyBackupStore(mem);
    expect(await s.save(1, 'bad'), isNull);
    final b = await s.save(1, priv, longName: 'A', now: DateTime(2026));
    await s.save(2, priv2, now: DateTime(2027));
    expect(b!.publicKey, hasLength(44));
    expect((await s.get(1))!.privateKey, priv);
    expect((await s.all()).map((e) => e.nodeNum), [2, 1]);
    await s.delete(2);
    expect(await s.get(2), isNull);
    expect(mem.m.containsKey('other'), isTrue);
  });

  test('file round trip', () async {
    final b = (await KeyBackup.make(0xa1b2c3d4, priv, longName: 'Node'))!;
    expect(KeyBackupFile.fileName(b.nodeNum), 'meshtastic-key-a1b2c3d4.json');
    final back = KeyBackupFile.decode(KeyBackupFile.encode([b]));
    expect(back.single.privateKey, priv);
    expect(back.single.longName, 'Node');
    expect(back.single.nodeNum, 0xa1b2c3d4);
  });

  test('file rejects foreign, newer and empty', () {
    List<int> j(Object o) => utf8.encode(jsonEncode(o));
    expect(
      () => KeyBackupFile.decode(utf8.encode('nope')),
      throwsFormatException,
    );
    expect(() => KeyBackupFile.decode(j({'a': 1})), throwsFormatException);
    expect(
      () => KeyBackupFile.decode(
        j({'format': KeyBackupFile.format, 'version': 99, 'keys': []}),
      ),
      throwsFormatException,
    );
    expect(
      () => KeyBackupFile.decode(
        j({
          'format': KeyBackupFile.format,
          'version': 1,
          'keys': [
            {'num': 1, 'priv': 'short', 'time': 0},
          ],
        }),
      ),
      throwsFormatException,
    );
  });
}
