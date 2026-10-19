import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'mirror_models.dart';

enum MirrorState { idle, connecting, connected, waiting }

/// WebSocket-подписка на зеркало с переподключением (1, 2, 4, 8, 15, 15… с).
/// Радио-часть от неё не зависит: падение сети здесь — только повторные попытки.
class MirrorRealtime extends ChangeNotifier {
  MirrorRealtime(this.url, this.onEvent, {this.log});

  final Uri url;
  final Future<void> Function(MirrorEvent e) onEvent;
  final void Function(String)? log;

  MirrorState state = MirrorState.idle;
  int retryIn = 0;
  String? lastError;

  WebSocket? _ws;
  Timer? _retry;
  Timer? _countdown;
  int _attempt = 0;
  bool _running = false;
  Future<void> _queue = Future.value();

  void start() {
    if (_running) return;
    _running = true;
    _connect();
  }

  /// Переподключиться сразу (возврат в приложение, смена сети).
  void reconnectNow() {
    if (!_running) return;
    _attempt = 0;
    _retry?.cancel();
    _countdown?.cancel();
    final ws = _ws;
    _ws = null;
    ws?.close(WebSocketStatus.goingAway);
    _connect();
  }

  Future<void> stop() async {
    _running = false;
    _retry?.cancel();
    _countdown?.cancel();
    final ws = _ws;
    _ws = null;
    await ws?.close(WebSocketStatus.goingAway);
    _set(MirrorState.idle);
  }

  Future<void> _connect() async {
    if (!_running) return;
    _set(MirrorState.connecting);
    try {
      final ws = await WebSocket.connect(
        url.toString(),
      ).timeout(const Duration(seconds: 15));
      if (!_running) {
        await ws.close();
        return;
      }
      // Пинг каждые 15 с; без понга сокет закроется сам — не ждём системного таймаута.
      ws.pingInterval = const Duration(seconds: 15);
      _ws = ws;
      _attempt = 0;
      lastError = null;
      _set(MirrorState.connected);
      log?.call('Зеркало: подключено');
      ws.listen(
        _onData,
        onError: (Object e) => lastError = '$e',
        onDone: () => _onClosed(ws),
        cancelOnError: true,
      );
    } catch (e) {
      lastError = '$e';
      _scheduleRetry();
    }
  }

  void _onData(dynamic data) {
    final Object? j;
    try {
      j = jsonDecode(data is String ? data : utf8.decode(data as List<int>));
    } catch (_) {
      return;
    }
    if (j is! Map<String, dynamic>) return;
    final e = MirrorEvent.parse(j);
    if (e is MirrorOther) return;
    // По порядку: init должен лечь в БД раньше new_message.
    _queue = _queue.then((_) => onEvent(e)).catchError((Object err) {
      log?.call('Зеркало: ошибка обработки ${e.runtimeType}: $err');
    });
  }

  void _onClosed(WebSocket ws) {
    if (!identical(ws, _ws)) return; // закрыли сами при reconnectNow/stop
    _ws = null;
    log?.call(
      'Зеркало: соединение закрыто${lastError == null ? '' : ' ($lastError)'}',
    );
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (!_running) return;
    _attempt++;
    retryIn = [1, 2, 4, 8, 15][(_attempt - 1).clamp(0, 4)];
    _set(MirrorState.waiting);
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (retryIn > 1) {
        retryIn--;
        notifyListeners();
      }
    });
    _retry = Timer(Duration(seconds: retryIn), () {
      _countdown?.cancel();
      _connect();
    });
  }

  void _set(MirrorState s) {
    state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _running = false;
    _retry?.cancel();
    _countdown?.cancel();
    _ws?.close(WebSocketStatus.goingAway);
    _ws = null;
    super.dispose();
  }
}
