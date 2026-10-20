import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_data.dart' as typed;

import 'mqtt_proxy_config.dart';

/// Сообщение из брокера.
typedef MqttInbound = ({String topic, Uint8List payload, bool retained});

/// Брокер отказал в подключении. [credentials] — повтор не поможет.
class MqttRejected implements Exception {
  const MqttRejected(this.message, {this.credentials = false});
  final String message;
  final bool credentials;
  @override
  String toString() => message;
}

/// Соединение с брокером — для подмены в тестах.
abstract interface class MqttLink {
  /// Бросает [MqttRejected] или ошибку сети.
  Future<void> connect(MqttProxyConfig cfg, String clientId);
  void subscribe(List<String> topics);
  void publish(String topic, List<int> payload, {required bool retained});
  void disconnect();
  Stream<MqttInbound> get messages;

  /// Соединение оборвалось само (не через [disconnect]).
  Stream<void> get lost;
}

/// [MqttLink] на `mqtt_client`: MQTT 3.1.1, TCP/TLS или WebSocket.
class MqttClientLink implements MqttLink {
  MqttServerClient? _c;
  StreamSubscription? _sub;
  bool _closing = false;
  final _messages = StreamController<MqttInbound>.broadcast();
  final _lost = StreamController<void>.broadcast();

  @override
  Stream<MqttInbound> get messages => _messages.stream;
  @override
  Stream<void> get lost => _lost.stream;

  @override
  Future<void> connect(MqttProxyConfig cfg, String clientId) async {
    disconnect();
    _closing = false;
    final c = MqttServerClient.withPort(cfg.host, clientId, cfg.port)
      ..logging(on: false)
      ..setProtocolV311()
      ..keepAlivePeriod = 60
      ..connectTimeoutPeriod = 10000
      ..useWebSocket = cfg.webSocket
      ..secure = cfg.tls && !cfg.webSocket;
    if (cfg.webSocket) {
      c.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    }
    final msg = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    if (cfg.username.isNotEmpty) msg.authenticateAs(cfg.username, cfg.password);
    c.connectionMessage = msg;
    c.onDisconnected = () {
      if (!_closing && identical(_c, c)) _lost.add(null);
    };
    _c = c;
    try {
      await c.connect();
    } on NoConnectionException {
      throw _rejected(c.connectionStatus?.returnCode);
    }
    if (c.connectionStatus?.state != MqttConnectionState.connected) {
      throw _rejected(c.connectionStatus?.returnCode);
    }
    _sub = c.updates?.listen((batch) {
      for (final m in batch) {
        final p = m.payload;
        if (p is! MqttPublishMessage) continue;
        _messages.add((
          topic: m.topic,
          payload: Uint8List.fromList(p.payload.message),
          retained: p.header?.retain ?? false,
        ));
      }
    });
  }

  /// Подписи — Meshtastic-Android (mqtt_error_*), иначе iOS.
  static Exception _rejected(MqttConnectReturnCode? code) => switch (code) {
    MqttConnectReturnCode.badUsernameOrPassword ||
    MqttConnectReturnCode.notAuthorized => const MqttRejected(
      'MQTT: соединение отклонено (проверьте учетные данные)',
      credentials: true,
    ),
    MqttConnectReturnCode.identifierRejected => const MqttRejected(
      'MQTT: Соединение отклонено: Invalid Id',
      credentials: true,
    ),
    MqttConnectReturnCode.unacceptedProtocolVersion => const MqttRejected(
      'MQTT: Соединение отклонено: Unacceptable Protocol version',
    ),
    MqttConnectReturnCode.brokerUnavailable => const MqttRejected(
      'MQTT: Соединение отклонено: Invalid Server',
    ),
    _ => const MqttRejected('Не удается подключиться к брокеру'),
  };

  @override
  void subscribe(List<String> topics) {
    for (final t in topics) {
      _c?.subscribe(t, MqttQos.atLeastOnce);
    }
  }

  @override
  void publish(String topic, List<int> payload, {required bool retained}) {
    final c = _c;
    if (c?.connectionStatus?.state != MqttConnectionState.connected) return;
    c!.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      typed.Uint8Buffer()..addAll(payload),
      retain: retained,
    );
  }

  @override
  void disconnect() {
    _closing = true;
    _sub?.cancel();
    _sub = null;
    final c = _c;
    _c = null;
    try {
      c?.disconnect();
    } catch (_) {}
  }

  /// Свой id на каждое подключение: клиенты с одинаковым id выбивают друг
  /// друга (как в Android).
  static String clientId(int? myNodeNum) {
    final r = Random.secure();
    final tail = List.generate(
      8,
      (_) => r.nextInt(16).toRadixString(16),
    ).join();
    final node = myNodeNum?.toRadixString(16).padLeft(8, '0') ?? 'unknown';
    return 'EtohostMeshMqttProxy-$node-$tail';
  }
}
