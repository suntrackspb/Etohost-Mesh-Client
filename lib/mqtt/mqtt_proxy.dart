import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/proto/mesh.dart';
import 'mqtt_link.dart';
import 'mqtt_proxy_config.dart';

enum MqttProxyState { inactive, connecting, connected, reconnecting, failed }

/// MQTT Client Proxy: нода без Wi‑Fi ходит в брокер через сеть телефона.
/// Нода → брокер: [MqttClientProxyMessage] из FromRadio публикуются как есть.
/// Брокер → нода: через [MqttDownlinkFilter], одна запись в ноду за раз —
/// лишнее отбрасываем (как iOS: публичный брокер шлёт быстрее, чем тянет BLE).
class MqttProxy extends ChangeNotifier {
  MqttProxy({
    required MqttLink link,
    required this.sendToRadio,
    this.log,
    this.minRetry = const Duration(seconds: 1),
    this.maxRetry = const Duration(seconds: 30),
  }) : _link = link {
    _subs.add(_link.messages.listen(_onInbound));
    _subs.add(_link.lost.listen((_) => _onLost()));
  }

  final MqttLink _link;
  final Future<void> Function(ToRadio) sendToRadio;
  final void Function(String)? log;
  final Duration minRetry;
  final Duration maxRetry;
  final _subs = <StreamSubscription>[];

  MqttProxyState state = MqttProxyState.inactive;

  /// Последняя ошибка для UI; пусто — нет.
  String error = '';
  int attempt = 0;
  int forwarded = 0;
  int dropped = 0;
  int published = 0;

  MqttProxyConfig? _cfg;
  int? _me;
  Timer? _retry;
  Duration _delay = Duration.zero;
  bool _busy = false;

  /// Сессия подключения: устаревшие ответы `connect` игнорируем.
  int _session = 0;

  MqttProxyConfig? get config => _cfg;

  /// Состояние для UI. Подписи — Meshtastic-Android (mqtt_status_*).
  String get statusText => switch (state) {
    MqttProxyState.inactive => 'Неактивно',
    MqttProxyState.connecting => 'Подключение…',
    MqttProxyState.connected => 'Подключено',
    MqttProxyState.reconnecting =>
      error.isEmpty
          ? 'Восстановление связи…'
          : 'Восстановление (попытка $attempt) — $error',
    MqttProxyState.failed => 'Отключено — $error',
  };
  bool get active => _cfg != null;

  /// Подключиться (или переподключиться, если настройки изменились).
  void start(MqttProxyConfig cfg, {int? myNodeNum}) {
    _me = myNodeNum;
    if (cfg == _cfg && state != MqttProxyState.failed) return;
    _stopLink();
    _cfg = cfg;
    attempt = 0;
    _delay = minRetry;
    error = '';
    unawaited(_connect());
  }

  void stop() {
    if (_cfg == null && state == MqttProxyState.inactive) return;
    _stopLink();
    _cfg = null;
    error = '';
    _set(MqttProxyState.inactive);
  }

  void _stopLink() {
    _session++;
    _retry?.cancel();
    _retry = null;
    _link.disconnect();
  }

  Future<void> _connect() async {
    final cfg = _cfg;
    if (cfg == null) return;
    final session = ++_session;
    attempt++;
    _set(
      attempt == 1 ? MqttProxyState.connecting : MqttProxyState.reconnecting,
    );
    log?.call('MQTT-прокси: подключение к ${cfg.description} (#$attempt)');
    try {
      await _link.connect(cfg, MqttClientLink.clientId(_me));
      if (session != _session) return;
      _link.subscribe(cfg.topics);
      attempt = 0;
      _delay = minRetry;
      error = '';
      log?.call('MQTT-прокси: подключено, темы: ${cfg.topics.join(', ')}');
      _set(MqttProxyState.connected);
    } on MqttRejected catch (e) {
      if (session != _session) return;
      _link.disconnect();
      error = e.message;
      log?.call('MQTT-прокси: $e');
      if (e.credentials) {
        _set(MqttProxyState.failed);
      } else {
        _scheduleRetry();
      }
    } catch (e) {
      if (session != _session) return;
      _link.disconnect();
      error = 'Сбой MQTT-прокси: $e';
      log?.call(error);
      _scheduleRetry();
    }
  }

  void _onLost() {
    if (_cfg == null || state != MqttProxyState.connected) return;
    error = 'MQTT: соединение потеряно';
    log?.call(error);
    _scheduleRetry();
  }

  void _scheduleRetry() {
    _set(MqttProxyState.reconnecting);
    _retry?.cancel();
    _retry = Timer(_delay, _connect);
    _delay = Duration(
      milliseconds: min(_delay.inMilliseconds * 2, maxRetry.inMilliseconds),
    );
  }

  /// Нода → брокер.
  void publish(MqttClientProxyMessage m) {
    if (state != MqttProxyState.connected) return;
    final List<int> payload;
    if (m.hasData()) {
      payload = m.data;
    } else if (m.hasText()) {
      payload = utf8.encode(m.text);
    } else {
      return;
    }
    _link.publish(m.topic, payload, retained: m.retained);
    published++;
    _countersChanged();
  }

  void _onInbound(MqttInbound m) {
    if (state != MqttProxyState.connected) return;
    final d = MqttDownlinkFilter.decide(m.topic, m.payload, _me);
    if (d != MqttDownlink.forward || _busy) {
      dropped++;
      _countersChanged();
      return;
    }
    final proxy = MqttClientProxyMessage(topic: m.topic, retained: m.retained);
    if (m.topic.contains('/json/')) {
      proxy.text = utf8.decode(m.payload, allowMalformed: true);
    } else {
      proxy.data = m.payload;
    }
    _busy = true;
    forwarded++;
    _countersChanged();
    sendToRadio(ToRadio(mqttClientProxyMessage: proxy))
        .catchError((Object e) => log?.call('MQTT-прокси: в ноду не ушло: $e'))
        .whenComplete(() => _busy = false);
  }

  Timer? _countersTimer;

  /// Счётчики меняются на каждый пакет — UI обновляем не чаще раза в секунду.
  void _countersChanged() {
    _countersTimer ??= Timer(const Duration(seconds: 1), () {
      _countersTimer = null;
      notifyListeners();
    });
  }

  void _set(MqttProxyState s) {
    state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _countersTimer?.cancel();
    _stopLink();
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
