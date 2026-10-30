import 'dart:convert';
import 'dart:typed_data';

import 'package:meshex/core/transport/net_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _b(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  test('имя из TXT — как в iOS-клиенте', () {
    String name(Map<String, Uint8List?>? txt, [String? service]) =>
        discoveryName(
          serviceName: service,
          host: '192.168.1.115',
          port: 4403,
          txt: txt,
        );

    expect(name({'shortname': _b('SUNo'), 'id': _b('!9eeff120')}), 'SUNo_f120');
    expect(name({'id': _b('!9eeff120')}), 'f120');
    expect(name({'shortname': _b('SUNo'), 'id': _b('!12')}), 'SUNo');
    expect(name(null, 'Meshtastic_f120'), 'Meshtastic_f120');
    expect(name({'shortname': null}), '192.168.1.115:4403');
  });

  test('адрес IPv6 — в скобках', () {
    expect(
      const NetNode(name: 'n', host: 'fe80::1', port: 4403).address,
      '[fe80::1]:4403',
    );
    expect(
      const NetNode(name: 'n', host: '10.0.0.2', port: 4403).address,
      '10.0.0.2:4403',
    );
  });
}
