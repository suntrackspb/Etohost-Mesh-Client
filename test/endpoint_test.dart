import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etohost_mesh/core/radio/endpoint.dart';
import 'package:etohost_mesh/data/database.dart';

void main() {
  test('splitHostPort', () {
    expect(splitHostPort('192.168.1.5'), ('192.168.1.5', 4403));
    expect(splitHostPort(' meshtastic.local:4000 '), (
      'meshtastic.local',
      4000,
    ));
    expect(splitHostPort('fe80::1'), ('fe80::1', 4403));
    expect(splitHostPort('[fe80::1]:4500'), ('fe80::1', 4500));
    expect(splitHostPort('host:abc'), ('host', 4403));
  });

  test('joinHostPort: IPv6 в скобках, туда и обратно', () {
    expect(joinHostPort('192.168.1.5', 4403), '192.168.1.5:4403');
    expect(joinHostPort('fe80::1', 4403), '[fe80::1]:4403');
    final (h, p) = splitHostPort('2a02:6b8::1');
    expect(splitHostPort(joinHostPort(h, p)), ('2a02:6b8::1', 4403));
  });

  test('недавние: обновление по адресу, порядок, забыть', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.touchRecent('tcp', '10.0.0.1:4403', '', null);
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await db.touchRecent('ble', 'AA:BB', 'Node', 0x1234);
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await db.touchRecent('tcp', '10.0.0.1:4403', '', 7);

    var list = await db.watchRecent().first;
    expect(list.map((r) => r.address), ['10.0.0.1:4403', 'AA:BB']);
    expect(list.first.nodeNum, 7);

    await db.forgetRecent('tcp', '10.0.0.1:4403');
    list = await db.watchRecent().first;
    expect(list.single.address, 'AA:BB');
    await db.close();
  });

  test('настройки: значение по ключу', () async {
    final db = AppDatabase(NativeDatabase.memory());
    expect(await db.getSetting(AppSettingKeys.autoConnect), isNull);
    await db.setSetting(AppSettingKeys.autoConnect, 'false');
    expect(await db.getSetting(AppSettingKeys.autoConnect), 'false');
    await db.close();
  });
}
