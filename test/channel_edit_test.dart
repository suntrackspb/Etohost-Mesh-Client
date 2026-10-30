import 'dart:convert';
import 'dart:math';

import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/settings/channel_edit.dart';
import 'package:meshex/data/settings/settings_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final strong = List.generate(32, (i) => i);

  SettingsForm form(ChannelSettings s, int role) => SettingsForm(
    ChannelEdit.fields(),
    ChannelEdit.read(s, role),
    adjust: ChannelEdit.adjust,
    check: ChannelEdit.check,
  );

  test('read/apply сохраняют канал и неизвестные поля', () {
    final s = ChannelSettings(
      name: 'Team',
      psk: strong,
      uplinkEnabled: true,
      id: 77,
      moduleSettings: ModuleSettings(positionPrecision: 13, isMuted: true),
    );
    final v = ChannelEdit.read(s, 2);
    expect(v['keySize'], 32);
    expect(v['positionsEnabled'], isTrue);
    expect(v['preciseLocation'], isFalse);
    final ch = ChannelEdit.apply(s, 3, v);
    expect(ch.index, 3);
    expect(ch.role, Channel_Role.SECONDARY);
    expect(ch.settings.psk, strong);
    expect(ch.settings.id, 77);
    expect(ch.settings.moduleSettings.isMuted, isTrue);
    expect(ch.settings.moduleSettings.positionPrecision, 13);
  });

  test('ключ по умолчанию: размер -1, точная позиция недоступна', () {
    final f = form(
      ChannelSettings(
        psk: [1],
        moduleSettings: ModuleSettings(positionPrecision: 32),
      ),
      1,
    );
    expect(f.value<int>('keySize'), -1);
    expect(f.value<bool>('preciseLocation'), isFalse);
    expect(f.value<int>('positionPrecision'), 14);
    expect(ChannelEdit.apply(ChannelSettings(), 0, f.values).settings.psk, [1]);
  });

  test('смена размера ключа даёт новый ключ нужной длины', () {
    final f = form(ChannelSettings(psk: [1]), 2);
    f.set('keySize', 16);
    expect(base64.decode(f.value<String>('key')).length, 16);
    expect(f.formError, isNull);
    f.set('key', base64.encode([1, 2, 3]));
    expect(f.formError, ChannelEdit.badKey);
    f.set('keySize', 0);
    expect(f.value<String>('key'), '');
    expect(f.formError, isNull);
  });

  test('позиции: включение 15, точная 32, выключение 0; имя без пробелов', () {
    final f = form(ChannelSettings(psk: strong), 2);
    f.set('positionsEnabled', true);
    expect(f.value<int>('positionPrecision'), 15);
    f.set('preciseLocation', true);
    var ch = ChannelEdit.apply(ChannelSettings(), 1, f.values);
    expect(ch.settings.moduleSettings.positionPrecision, 32);
    f.set('positionsEnabled', false);
    ch = ChannelEdit.apply(ChannelSettings(), 1, f.values);
    expect(ch.settings.moduleSettings.positionPrecision, 0);
    f.set('name', 'a b c');
    expect(f.value<String>('name'), 'abc');
  });

  test('свободный слот и новый канал', () {
    MeshChannel c(int i, int role) =>
        MeshChannel(index: i, name: '', role: role);
    expect(ChannelEdit.nextFreeIndex([c(0, 1), c(1, 2), c(2, 0)]), 2);
    expect(
      ChannelEdit.nextFreeIndex([
        for (var i = 0; i < 8; i++) c(i, i == 0 ? 1 : 2),
      ]),
      isNull,
    );
    final v = ChannelEdit.fresh(Random(1));
    expect(v['keySize'], 16);
    expect(v['role'], 2);
    expect(v['positionsEnabled'], isFalse);
  });

  test('зарезервированные имена', () {
    expect(ChannelEdit.isReserved('Admin'), isTrue);
    expect(ChannelEdit.isReserved('team'), isFalse);
  });
}
