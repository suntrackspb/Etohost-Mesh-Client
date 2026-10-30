import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/network_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('IPv4: первый октет в младшем байте, как в iOS', () {
    expect(ipv4ToInt('192.168.1.10'), 192 | 168 << 8 | 1 << 16 | 10 << 24);
    expect(ipv4ToString(ipv4ToInt('10.0.0.254')), '10.0.0.254');
    expect(ipv4ToString(0), '');
    expect(ipv4ToInt(''), 0);
    for (final bad in ['1.2.3', '1.2.3.4.', '256.1.1.1', 'a.b.c.d', '1..2.3']) {
      expect(isValidIpv4(bad), isFalse, reason: bad);
    }
  });

  test('группы по оборудованию', () {
    Set<String> keys({bool wifi = false, bool eth = false}) =>
        NetworkSection.fields(
          hasWifi: wifi,
          hasEthernet: eth,
        ).map((f) => f.key).toSet();
    expect(keys(), isEmpty);
    expect(keys(wifi: true), containsAll(['wifiSsid', 'ntpServer', 'ip']));
    expect(keys(wifi: true), isNot(contains('ethEnabled')));
    expect(keys(eth: true), containsAll(['ethEnabled', 'addressMode']));
    expect(keys(eth: true), isNot(contains('wifiPsk')));
  });

  test('статика требует IP, шлюз и подсеть; DNS можно пустым', () {
    final v = NetworkSection.read(Config_NetworkConfig())
      ..['addressMode'] = NetworkSection.static_;
    expect(NetworkSection.check(v), isNotNull);
    v
      ..['ip'] = '192.168.1.50'
      ..['gateway'] = '192.168.1.1'
      ..['subnet'] = '255.255.255.0';
    expect(NetworkSection.check(v), isNull);
    v['dns'] = '8.8.8';
    expect(NetworkSection.check(v), isNotNull);
    v['addressMode'] = NetworkSection.dhcp;
    expect(NetworkSection.check(v), isNull);
  });

  test(
    'apply: UDP-бит, чужие биты и ipv6 сохраняются, DHCP не трогает адреса',
    () {
      final base = Config_NetworkConfig(
        enabledProtocols: 0x10,
        ipv6Enabled: true,
        ipv4Config: Config_NetworkConfig_IpV4Config(ip: 123),
      );
      final v = NetworkSection.read(base)..['udpBroadcast'] = true;
      final out = NetworkSection.apply(base, v);
      expect(out.enabledProtocols, 0x11);
      expect(out.ipv6Enabled, isTrue);
      expect(out.ipv4Config.ip, 123);

      v
        ..['addressMode'] = NetworkSection.static_
        ..['ip'] = '192.168.1.50';
      expect(
        NetworkSection.apply(base, v).ipv4Config.ip,
        ipv4ToInt('192.168.1.50'),
      );
    },
  );
}
