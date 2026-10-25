import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/id_bug.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mac = [0x9c, 0x13, 0x9e, 0xef, 0xf1, 0x20];
  const num = 0x9eeff120;
  final key = List<int>.generate(32, (i) => i);
  User user(List<int> m) => User(macaddr: m, publicKey: key);

  test('номер из MAC — бага нет', () {
    expect(
      detectIdBug(me: num, radio: user(mac), firmware: '2.7.26.54e0d8d'),
      isNull,
    );
  });

  test('нулевой MAC — не перезагружена; MAC из базы только свой', () {
    final zero = user(List.filled(6, 0));
    final a = detectIdBug(
      me: num,
      radio: zero,
      firmware: '2.7.26',
      savedMac: mac,
    );
    expect(a, isA<IdBugPending>());
    expect((a! as IdBugPending).mac, mac);
    final b = detectIdBug(
      me: num,
      radio: zero,
      firmware: '2.7.26',
      savedMac: const [1, 2, 3, 4, 5, 6],
    );
    expect((b! as IdBugPending).mac, isNull);
  });

  test('случайный номер при настоящем MAC — ID сменился', () {
    final r = detectIdBug(me: 0x7161108e, radio: user(mac), firmware: '2.7.26');
    expect(r, isA<IdBugChanged>());
    expect((r! as IdBugChanged).original, num);
  });

  test('2.8 и номер из ключа — не баг', () {
    expect(
      detectIdBug(me: 0x7161108e, radio: user(mac), firmware: '2.8.0'),
      isNull,
    );
    expect(
      detectIdBug(me: crc32(key), radio: user(mac), firmware: '2.7.26'),
      isNull,
    );
  });

  test('crc32 как zlib', () {
    expect(crc32('123456789'.codeUnits), 0xcbf43926);
  });

  test('имя для возврата', () {
    const p = (num: num, longName: 'SUN', shortName: 'S', isUnmessagable: true);
    expect(parsePendingOwner(encodePendingOwner(p)), p);
    expect(parsePendingOwner(''), isNull);
    expect(
      needsOwnerRestore(p, num, User(longName: 'Meshtastic f120')),
      isTrue,
    );
    expect(
      needsOwnerRestore(p, num, User(longName: 'SUN', shortName: 'S')),
      isFalse,
    );
    expect(needsOwnerRestore(p, 1, User(longName: 'x')), isFalse);
  });
}
