import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Раздел «Сеть»: NetworkConfig.swift (iOS). Группы — по оборудованию из
/// DeviceMetadata (has_wifi / has_ethernet). Адреса IPv4 — строкой, в proto
/// это uint32 с первым октетом в младшем байте (как IPv4Address в iOS).
/// ipv6_enabled не редактируется (как в iOS) и сохраняется как есть.
abstract final class NetworkSection {
  static const title = 'Настройка сети';
  static const groupWifi = 'Параметры WiFi';
  static const groupEthernet = 'Параметры Ethernet';
  static const groupServers = 'Network Servers';
  static const groupAddress = 'Address Mode';
  static const groupStatic = 'Static IPv4 Configuration';
  static const groupUdp = 'UDP-трансляция';
  static const saveConfirm = 'Сохранить настройки сети?';
  static const noNetwork = 'У этой ноды нет ни Wi-Fi, ни Ethernet.';

  static const dhcp = 0, static_ = 1;
  static const addressModes = <Choice>[
    (value: 0, label: 'DHCP'),
    (value: 1, label: 'Static'),
  ];

  static const udpBroadcastBit = 1;

  static const _staticFooter =
      'Address, gateway and subnet are required and must be valid IPv4 '
      'addresses. DNS may be left blank.';
  static const _badAddress = 'Неверный адрес IPv4';

  static bool _static(Map<String, Object?> v) => v['addressMode'] == static_;

  static List<FieldSpec<Object?>> fields({
    required bool hasWifi,
    required bool hasEthernet,
  }) {
    final networked = hasWifi || hasEthernet;
    return [
      if (hasWifi) ...[
        const BoolFieldSpec(
          'wifiEnabled',
          'Wi-Fi включен',
          group: groupWifi,
          help:
              'При включении WiFi отключится bluetooth подключение к телефону',
        ),
        const TextFieldSpec(
          'wifiSsid',
          'SSID',
          group: groupWifi,
          maxBytes: 32,
          help: 'WiFi network name to connect to',
        ),
        const TextFieldSpec(
          'wifiPsk',
          'Пароль',
          group: groupWifi,
          maxBytes: 63,
          secure: true,
          help: 'WiFi password for authentication',
        ),
      ],
      if (hasEthernet)
        const BoolFieldSpec(
          'ethEnabled',
          'Ethernet включен',
          group: groupEthernet,
          help:
              'Включение Ethernet отключит соединение Bluetooth с приложением.',
        ),
      if (networked) ...[
        const TextFieldSpec(
          'ntpServer',
          'NTP-сервер',
          group: groupServers,
          maxBytes: 32,
          help: 'NTP server address. Defaults to meshtastic.pool.ntp.org',
        ),
        const TextFieldSpec(
          'rsyslogServer',
          'Сервер rsyslog',
          group: groupServers,
          maxBytes: 32,
        ),
        const ChoiceFieldSpec(
          'addressMode',
          'Режим IPv4',
          addressModes,
          group: groupAddress,
        ),
        for (final (key, label) in const [
          ('ip', 'IP-адрес'),
          ('gateway', 'Шлюз'),
          ('subnet', 'Подсеть'),
          ('dns', 'Служба доменных имен (DNS)'),
        ])
          TextFieldSpec(
            key,
            label,
            group: groupStatic,
            maxBytes: 15,
            visibleWhen: _static,
            validator: (s) => isValidIpv4(s) ? null : _badAddress,
            help: key == 'dns' ? _staticFooter : null,
          ),
        const BoolFieldSpec(
          'udpBroadcast',
          'UDP-трансляция',
          group: groupUdp,
          help: 'Включить трансляцию пакетов через UDP по локальной сети.',
        ),
      ],
    ];
  }

  /// Статический адрес без IP, шлюза или подсети нода не переживёт: она
  /// вернётся недоступной (как canSave в iOS).
  static String? check(Map<String, Object?> v) {
    if (!_static(v)) return null;
    for (final k in ['ip', 'gateway', 'subnet']) {
      final s = v[k] as String? ?? '';
      if (!isValidIpv4(s) || ipv4ToInt(s) == 0) return _staticFooter;
    }
    return isValidIpv4(v['dns'] as String? ?? '') ? null : _staticFooter;
  }

  static Map<String, Object?> read(Config_NetworkConfig c) => {
    'wifiEnabled': c.wifiEnabled,
    'wifiSsid': c.wifiSsid,
    'wifiPsk': c.wifiPsk,
    'ethEnabled': c.ethEnabled,
    'ntpServer': c.ntpServer,
    'rsyslogServer': c.rsyslogServer,
    'addressMode': c.addressMode.value,
    'ip': ipv4ToString(c.ipv4Config.ip),
    'gateway': ipv4ToString(c.ipv4Config.gateway),
    'subnet': ipv4ToString(c.ipv4Config.subnet),
    'dns': ipv4ToString(c.ipv4Config.dns),
    'udpBroadcast': c.enabledProtocols & udpBroadcastBit != 0,
  };

  static Config_NetworkConfig apply(
    Config_NetworkConfig base,
    Map<String, Object?> v,
  ) {
    final out = base.deepCopy()
      ..wifiEnabled = v['wifiEnabled']! as bool
      ..wifiSsid = v['wifiSsid']! as String
      ..wifiPsk = v['wifiPsk']! as String
      ..ethEnabled = v['ethEnabled']! as bool
      ..ntpServer = v['ntpServer']! as String
      ..rsyslogServer = v['rsyslogServer']! as String
      ..addressMode = Config_NetworkConfig_AddressMode.valueOf(
        v['addressMode']! as int,
      )!
      ..enabledProtocols = v['udpBroadcast'] == true
          ? base.enabledProtocols | udpBroadcastBit
          : base.enabledProtocols & ~udpBroadcastBit;
    // Адреса пишем только для статики: DHCP-адреса нода присылает сама.
    if (_static(v)) {
      out.ipv4Config = Config_NetworkConfig_IpV4Config(
        ip: ipv4ToInt(v['ip']! as String),
        gateway: ipv4ToInt(v['gateway']! as String),
        subnet: ipv4ToInt(v['subnet']! as String),
        dns: ipv4ToInt(v['dns']! as String),
      );
    }
    return out;
  }

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    Config_NetworkConfig base,
    Map<String, Object?> v,
  ) => saveConfig(admin, db, 'network', Config(network: apply(base, v)));
}

/// Пустая строка допустима (адрес не задан); иначе четыре числа 0–255.
bool isValidIpv4(String s) {
  if (s.isEmpty) return true;
  final parts = s.split('.');
  return parts.length == 4 &&
      parts.every(
        (p) =>
            p.isNotEmpty &&
            p.length <= 3 &&
            RegExp(r'^\d+$').hasMatch(p) &&
            int.parse(p) <= 255,
      );
}

/// «192.168.1.10» → uint32, первый октет в младшем байте; 0 — не разобрано.
int ipv4ToInt(String s) {
  if (s.isEmpty || !isValidIpv4(s)) return 0;
  final p = s.split('.').map(int.parse).toList();
  return p[0] | p[1] << 8 | p[2] << 16 | p[3] << 24;
}

/// 0 — пустая строка (так прошивка сообщает «не задан»).
String ipv4ToString(int v) => v == 0
    ? ''
    : '${v & 0xff}.${v >> 8 & 0xff}.${v >> 16 & 0xff}.${v >> 24 & 0xff}';
