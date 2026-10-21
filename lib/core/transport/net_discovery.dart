import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nsd/nsd.dart' as nsd;

/// Тип сервиса, который объявляют ноды с Wi-Fi/Ethernet.
const meshServiceType = '_meshtastic._tcp';

/// Поиск в сети через системный Bonjour/NSD; на Linux плагина нет.
bool get netDiscoverySupported =>
    Platform.isIOS ||
    Platform.isAndroid ||
    Platform.isMacOS ||
    Platform.isWindows;

/// Нода, найденная в локальной сети.
class NetNode {
  const NetNode({required this.name, required this.host, required this.port});

  final String name;
  final String host;
  final int port;

  /// Адрес для подключения по TCP.
  String get address => host.contains(':') ? '[$host]:$port' : '$host:$port';
}

/// Имя как в iOS-клиенте: shortname из TXT + «_» + 4 последних знака id
/// (SUNo_f120), иначе имя сервиса или хост с адресом.
String discoveryName({
  required String? serviceName,
  required String host,
  required int port,
  Map<String, Uint8List?>? txt,
}) {
  String text(String key) {
    final v = txt?[key];
    return v == null ? '' : utf8.decode(v, allowMalformed: true).trim();
  }

  var name = text('shortname');
  final id = text('id');
  if (id.length > 4) {
    name = name.isEmpty
        ? id.substring(id.length - 4)
        : '${name}_${id.substring(id.length - 4)}';
  }
  if (name.isNotEmpty) return name;
  final s = serviceName?.trim() ?? '';
  return s.isEmpty ? '$host:$port' : s;
}

/// Поиск нод в локальной сети. [onChange] получает весь текущий список.
class NetDiscovery {
  nsd.Discovery? _discovery;

  bool get running => _discovery != null;

  Future<void> start(void Function(List<NetNode> nodes) onChange) async {
    if (_discovery != null) return;
    final d = await nsd.startDiscovery(
      meshServiceType,
      ipLookupType: nsd.IpLookupType.v4,
    );
    _discovery = d;
    void emit() => onChange([for (final s in d.services) ?_nodeOf(s)]);
    d.addListener(emit);
    emit();
  }

  Future<void> stop() async {
    final d = _discovery;
    _discovery = null;
    if (d != null) await nsd.stopDiscovery(d);
  }

  static NetNode? _nodeOf(nsd.Service s) {
    final port = s.port;
    // IPv4 надёжнее имени .local: не все сети резолвят mDNS-имена в TCP.
    final ip = s.addresses?.where((a) => a.type == InternetAddressType.IPv4);
    var host = ip?.isNotEmpty == true ? ip!.first.address : (s.host ?? '');
    if (host.endsWith('.')) host = host.substring(0, host.length - 1);
    if (port == null || host.isEmpty) return null;
    return NetNode(
      name: discoveryName(
        serviceName: s.name,
        host: host,
        port: port,
        txt: s.txt,
      ),
      host: host,
      port: port,
    );
  }
}
