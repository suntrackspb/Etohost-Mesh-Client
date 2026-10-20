import 'dart:convert';

import '../core/proto/channel_names.dart';
import '../core/proto/mesh.dart';
import '../data/database.dart';

/// Куда и как подключаться прокси: из MQTT-конфига ноды, LoRa и каналов.
/// Правила — MQTTRepositoryImpl (Android) и MQTTProxy (iOS).
class MqttProxyConfig {
  const MqttProxyConfig({
    required this.host,
    required this.port,
    required this.tls,
    required this.webSocket,
    required this.username,
    required this.password,
    required this.topics,
  });

  static const publicServer = 'mqtt.meshtastic.org';
  // Учётные данные публичного сервера — как Default.h в прошивке.
  static const publicUser = 'meshdev';
  static const publicPassword = 'large4cats';
  static const defaultRoot = 'msh';
  static const pkiChannel = 'PKI';

  final String host;
  final int port;
  final bool tls;

  /// Адрес вида `ws://` / `wss://` — MQTT поверх WebSocket.
  final bool webSocket;
  final String username;
  final String password;
  final List<String> topics;

  /// Прокси нужен, только если в ноде включены и MQTT, и клиент-прокси.
  static bool wanted(ModuleConfig_MQTTConfig c) =>
      c.enabled && c.proxyToClientEnabled;

  static MqttProxyConfig from(
    ModuleConfig_MQTTConfig c, {
    Config_LoRaConfig? lora,
    List<MeshChannel> channels = const [],
  }) {
    final raw = c.address.trim();
    // Пустой адрес — публичный сервер со своими учётными данными
    // (прошивка подставляет их вместе, сохранённые игнорирует).
    final address = raw.isEmpty ? publicServer : raw;
    final scheme = address.contains('://')
        ? address.substring(0, address.indexOf('://')).toLowerCase()
        : null;
    var rest = scheme == null
        ? address
        : address.substring(address.indexOf('://') + 3);
    final slash = rest.indexOf('/');
    final path = slash < 0 ? '' : rest.substring(slash);
    if (slash >= 0) rest = rest.substring(0, slash);
    final colon = rest.lastIndexOf(':');
    final host = colon < 0 ? rest : rest.substring(0, colon);
    final explicitPort = colon < 0
        ? null
        : int.tryParse(rest.substring(colon + 1));

    final webSocket = scheme == 'ws' || scheme == 'wss';
    final public = host.toLowerCase() == publicServer;
    // Публичный сервер — только TLS.
    final tls = switch (scheme) {
      'ssl' || 'mqtts' || 'wss' || 'tls' => true,
      'tcp' || 'mqtt' || 'ws' => public,
      _ => c.tlsEnabled || public,
    };
    final port =
        explicitPort ?? (webSocket ? (tls ? 443 : 80) : (tls ? 8883 : 1883));

    final root = c.root.isEmpty ? defaultRoot : c.root;
    final presetName = lora == null ? 'LongFast' : modemPresetName(lora);
    final topics = <String>[];
    for (final ch in channels) {
      if (ch.role == Channel_Role.DISABLED.value) continue;
      final s = ch.settings == null
          ? null
          : ChannelSettings.fromBuffer(ch.settings!);
      if (s == null || !s.downlinkEnabled) continue;
      var name = ch.name;
      if (name.isEmpty && ch.role == Channel_Role.PRIMARY.value) {
        name = presetName;
      }
      if (name.isEmpty) continue;
      topics.add('$root/2/e/$name/+');
      if (c.jsonEnabled) topics.add('$root/2/json/$name/+');
    }
    topics.add('$root/2/e/$pkiChannel/+');

    return MqttProxyConfig(
      host: webSocket ? '${tls ? 'wss' : 'ws'}://$host$path' : host,
      port: port,
      tls: tls,
      webSocket: webSocket,
      username: raw.isEmpty ? publicUser : c.username,
      password: raw.isEmpty ? publicPassword : c.password,
      topics: topics,
    );
  }

  /// Для журнала: без пароля.
  String get description => '$host:$port${tls ? ' TLS' : ''}';

  @override
  bool operator ==(Object other) =>
      other is MqttProxyConfig &&
      other.host == host &&
      other.port == port &&
      other.tls == tls &&
      other.webSocket == webSocket &&
      other.username == username &&
      other.password == password &&
      other.topics.join('\n') == topics.join('\n');

  @override
  int get hashCode => Object.hash(
    host,
    port,
    tls,
    webSocket,
    username,
    password,
    topics.join('\n'),
  );
}

/// Что делать с пакетом из брокера перед отправкой в ноду.
enum MqttDownlink {
  forward,

  /// Служебные топики `/stat/`.
  status,

  /// Наш `from` через чужой шлюз — подделка квитанции.
  forgedSender,

  /// Чужой пакет через наш шлюз — нода сама его нам отдала.
  ownUplinkEcho,

  /// В MeshPacket нет ни decoded, ни encrypted — ноде нечего с ним делать.
  noPayload,
}

/// Фильтр входящих из брокера: классификация как в Android
/// (classifyMqttSelfTraffic, isUndeliverableDownlink). Пропускает всё, в чём
/// не уверен. hop_limit не трогаем: «политика нулевого хопа» для трафика
/// из MQTT — на стороне прошивки.
abstract final class MqttDownlinkFilter {
  static MqttDownlink decide(String topic, List<int> payload, int? myNodeNum) {
    if (topic.contains('/stat/')) return MqttDownlink.status;
    final me = myNodeNum == null ? null : nodeIdString(myNodeNum);
    if (topic.contains('/json/')) return _json(payload, me);

    final ServiceEnvelope env;
    try {
      env = ServiceEnvelope.fromBuffer(payload);
    } catch (_) {
      return MqttDownlink.forward;
    }
    if (me != null && env.hasPacket()) {
      final self = _self(
        fromUs: nodeIdString(env.packet.from) == me,
        viaUs: env.gatewayId == me,
      );
      if (self != MqttDownlink.forward) return self;
    }
    // Свой пакет, вернувшийся через свой шлюз, — для прошивки это ACK;
    // PKI нода принимает без расшифровки — их не режем.
    final guarded =
        env.channelId == MqttProxyConfig.pkiChannel ||
        (me != null && env.gatewayId == me);
    if (!guarded &&
        env.hasPacket() &&
        !env.packet.hasDecoded() &&
        !env.packet.hasEncrypted()) {
      return MqttDownlink.noPayload;
    }
    return MqttDownlink.forward;
  }

  static MqttDownlink _json(List<int> payload, String? me) {
    if (me == null) return MqttDownlink.forward;
    try {
      final j = jsonDecode(utf8.decode(payload));
      if (j is! Map) return MqttDownlink.forward;
      final from = j['from'], sender = j['sender'];
      if (from is! int || sender is! String) return MqttDownlink.forward;
      return _self(fromUs: nodeIdString(from) == me, viaUs: sender == me);
    } catch (_) {
      return MqttDownlink.forward;
    }
  }

  static MqttDownlink _self({required bool fromUs, required bool viaUs}) {
    if (fromUs && !viaUs) return MqttDownlink.forgedSender;
    if (!fromUs && viaUs) return MqttDownlink.ownUplinkEcho;
    return MqttDownlink.forward;
  }
}
