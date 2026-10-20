import 'dart:typed_data';

import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/settings/channel_url.dart';
import 'package:flutter_test/flutter_test.dart';

MeshChannel _ch(int index, String name, {int role = 2}) => MeshChannel(
  index: index,
  name: name,
  role: role,
  psk: Uint8List.fromList([1]),
);

void main() {
  final set = ChannelSet(
    settings: [
      ChannelSettings(name: '', psk: [1]),
      ChannelSettings(name: 'Team', psk: List.filled(16, 7)),
    ],
    loraConfig: Config_LoRaConfig(
      region: Config_LoRaConfig_RegionCode.RU,
      txPower: 20,
    ),
  );

  group('ChannelLink', () {
    test('round trip, replace keeps LoRa', () {
      final url = ChannelLink.encode(set);
      expect(url, startsWith('https://meshtastic.org/e/#'));
      expect(url.contains('='), isFalse);
      final l = ChannelLink.parse(url);
      expect(l.add, isFalse);
      expect(l.set.settings.map((s) => s.name), ['', 'Team']);
      expect(l.set.loraConfig.region, Config_LoRaConfig_RegionCode.RU);
    });

    test('add flag in query or fragment drops LoRa', () {
      final url = ChannelLink.encode(set, add: true);
      expect(url, contains('?add=true#'));
      final l = ChannelLink.parse(url);
      expect(l.add, isTrue);
      expect(l.set.hasLoraConfig(), isFalse);
      final payload = url.split('#').last;
      final f = ChannelLink.parse('https://meshtastic.org/e/#$payload?add=1');
      expect(f.add, isTrue);
    });

    test('bare payload, www host, app scheme', () {
      final payload = ChannelLink.encode(set).split('#').last;
      expect(ChannelLink.parse(payload).set.settings, hasLength(2));
      expect(
        ChannelLink.parse('https://www.meshtastic.org/e/#$payload').add,
        isFalse,
      );
      expect(ChannelLink.parse('meshtastic://e#$payload').add, isFalse);
    });

    test('rejects foreign and broken links', () {
      expect(
        () => ChannelLink.parse('https://example.com/e/#CgI'),
        throwsFormatException,
      );
      expect(
        () => ChannelLink.parse('https://meshtastic.org/e/'),
        throwsFormatException,
      );
      expect(() => ChannelLink.parse('  '), throwsFormatException);
      expect(() => ChannelLink.parse('%%%'), throwsFormatException);
    });
  });

  group('ChannelImport', () {
    test('replace fills slots, disables tail, keeps own txPower', () {
      final p = ChannelImport.plan(
        set,
        [_ch(0, ''), _ch(3, 'Old')],
        Config_LoRaConfig(txPower: 5, configOkToMqtt: true),
        add: false,
      );
      expect(p.ok, isTrue);
      expect(p.channels, hasLength(8));
      expect(p.channels[0].role, Channel_Role.PRIMARY);
      expect(p.channels[1].role, Channel_Role.SECONDARY);
      expect(p.channels[2].role, Channel_Role.DISABLED);
      expect(p.channels[1].settings.moduleSettings.positionPrecision, 0);
      expect(p.lora!.txPower, 5);
      expect(p.lora!.configOkToMqtt, isTrue);
      expect(p.lora!.region, Config_LoRaConfig_RegionCode.RU);
    });

    test('replace needs LoRa', () {
      final p = ChannelImport.plan(
        ChannelSet(settings: set.settings),
        const [],
        null,
        add: false,
      );
      expect(p.ok, isFalse);
    });

    test('add uses free secondary slots and rejects duplicates', () {
      final one = ChannelSet(settings: [set.settings[1]]);
      final p = ChannelImport.plan(
        one,
        [_ch(0, '', role: 1), _ch(1, 'A')],
        null,
        add: true,
      );
      expect(p.ok, isTrue);
      expect(p.channels.single.index, 2);
      expect(p.lora, isNull);
      expect(p.usedSlots, 3);

      final dup = ChannelImport.plan(
        one,
        [_ch(0, '', role: 1), _ch(1, 'Team')],
        null,
        add: true,
      );
      expect(dup.ok, isFalse);

      final full = ChannelImport.plan(
        one,
        [for (var i = 0; i < 8; i++) _ch(i, 'c$i')],
        null,
        add: true,
      );
      expect(full.ok, isFalse);
    });

    test('share picks included active channels in order', () {
      final s = ChannelImport.share(
        [_ch(2, 'B'), _ch(0, 'P', role: 1), _ch(1, 'A'), _ch(4, 'X', role: 0)],
        {0, 2, 4},
        Config_LoRaConfig(txPower: 1),
      );
      expect(s.settings.map((e) => e.name), ['P', 'B']);
      expect(s.loraConfig.txPower, 1);
    });
  });
}
