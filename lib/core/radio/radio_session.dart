import 'dart:async';

import 'package:flutter/foundation.dart';

import '../proto/mesh.dart';
import '../transport/transport.dart';
import 'endpoint.dart';
import 'journal.dart';
import 'send_queue.dart';

/// configuring — фаза 1 (конфиг, каналы); loadingNodes — фаза 2 (база нод).
enum RadioState {
  idle,
  connecting,
  configuring,
  loadingNodes,
  ready,
  waitingReconnect,
}

/// Куда подключаться. Фабрика создаёт новый транспорт на каждую попытку.
class RadioTarget {
  const RadioTarget(this.title, this.create, {this.endpoint});
  final String title;

  /// Сохраняемое описание цели (для недавних и автоподключения).
  final Endpoint? endpoint;
  final Transport Function(void Function(String log) log) create;
}

/// Единственный владелец соединения с нодой: handshake, heartbeat,
/// автопереподключение. Наружу отдаёт разобранные [FromRadio] через [packets].
class RadioSession extends ChangeNotifier {
  RadioSession(this.journal) {
    queue = SendQueue(send);
  }

  /// Двухфазный handshake (прошивка 2.7+, как в Meshtastic-Android):
  /// сначала конфиг/модули/каналы, затем база нод. Старые прошивки
  /// на любой nonce отдают всё целиком — второй запрос просто повторит базу.
  static const configNonce = 69420;
  static const nodesNonce = 69421;

  /// Полный конфиг вместе с базой нод — запасной путь, если нода не ответила
  /// на [nodesNonce] (встречалось на 2.7.23 по Wi‑Fi).
  static const fullNonce = 69422;

  /// Сколько ждать NodeInfo/конца базы, прежде чем повторить запрос.
  Duration nodesTimeout = const Duration(seconds: 10);

  static const heartbeatInterval = Duration(seconds: 60);
  static const reconnectDelay = Duration(seconds: 5);

  final Journal journal;

  /// Очередь MeshPacket с ожиданием ACK.
  late final SendQueue queue;

  RadioState state = RadioState.idle;
  RadioTarget? target;
  DateTime? connectedSince;
  DateTime? lastRx;
  int packetCount = 0;
  int disconnects = 0;
  int attempts = 0;
  bool _autoReconnect = true;
  bool get autoReconnect => _autoReconnect;
  set autoReconnect(bool v) {
    _autoReconnect = v;
    notifyListeners();
  }

  /// Номер нашей ноды (из MyNodeInfo), пока не подключены — null.
  int? myNodeNum;

  final _packets = StreamController<FromRadio>.broadcast();

  /// Все FromRadio от ноды, включая базу нод при подключении.
  Stream<FromRadio> get packets => _packets.stream;

  Transport? _t;
  Timer? _heartbeat;
  Timer? _nodesWatch;
  int _nodesRetry = 0;
  Timer? _reconnect;
  final _subs = <StreamSubscription>[];
  bool _stopped = true;

  void _app(String s) => journal.add(JournalKind.app, s);

  /// Подключиться к [t]. Предыдущее соединение закрывается.
  Future<void> connect(RadioTarget t) async {
    await disconnect(quiet: true);
    target = t;
    attempts = 0;
    disconnects = 0;
    _stopped = false;
    await _connect();
  }

  Future<void> _connect() async {
    final tgt = target;
    if (tgt == null) return;
    _reconnect?.cancel();
    attempts++;
    _setState(RadioState.connecting);

    final t = tgt.create(_app);
    _t = t;
    _app('Попытка #$attempts: ${t.description}');
    try {
      _subs.add(t.fromRadio.listen(_onFromRadio));
      _subs.add(t.logs.listen(_onLog));
      await t.connect();
      unawaited(t.closed.then((r) => _onClosed(t, r)));

      _setState(RadioState.configuring);
      _app('want_config: конфигурация ($configNonce)');
      await send(ToRadio(wantConfigId: configNonce));

      _heartbeat?.cancel();
      _heartbeat = Timer.periodic(heartbeatInterval, (_) => _sendHeartbeat());
    } catch (e) {
      _app(
        'Ошибка подключения: $e'
        '${e is TimeoutException ? ' (возможно, ждали ввода PIN при сопряжении)' : ''}',
      );
      await _teardown();
      // Android GATT 133 — стек «залип» на старом соединении, обычно лечится быстрым повтором.
      final quick = e.toString().contains('133');
      _scheduleReconnect(delay: quick ? const Duration(seconds: 1) : null);
    }
  }

  /// Отправить ToRadio в текущее соединение.
  Future<void> send(ToRadio msg) async {
    final t = _t;
    if (t == null) throw StateError('нет соединения с нодой');
    await t.send(Uint8List.fromList(msg.writeToBuffer()));
  }

  /// Отправить MeshPacket через очередь; результат — по ACK/NAK.
  Future<DeliveryResult> sendPacket(MeshPacket p) {
    if (_t == null) {
      return Future.value(const DeliveryResult(DeliveryStatus.disconnected));
    }
    return queue.enqueue(p);
  }

  Future<void> _sendHeartbeat() async {
    try {
      await send(ToRadio(heartbeat: Heartbeat()));
    } catch (e) {
      _app('heartbeat не отправлен: $e');
    }
  }

  void _onFromRadio(Uint8List data) {
    final FromRadio f;
    try {
      f = FromRadio.fromBuffer(data);
    } catch (e) {
      _app('Не разобран FromRadio (${data.length} байт): $e');
      return;
    }
    packetCount++;
    lastRx = DateTime.now();
    if (f.hasMyInfo()) myNodeNum = f.myInfo.myNodeNum;
    if (f.hasQueueStatus()) queue.onQueueStatus(f.queueStatus);
    if (f.hasPacket() && f.packet.hasDecoded()) {
      final d = f.packet.decoded;
      if (d.portnum == PortNum.ROUTING_APP && d.requestId != 0) {
        try {
          queue.onRouting(
            d.requestId,
            Routing.fromBuffer(d.payload).errorReason,
          );
        } catch (_) {}
      }
    }
    if (f.hasNodeInfo() && state == RadioState.loadingNodes) _armNodesWatch();
    if (f.hasConfigCompleteId()) _onConfigComplete(f.configCompleteId);
    journal.add(
      f.hasLogRecord() ? JournalKind.node : JournalKind.radio,
      describeFromRadio(f),
    );
    _packets.add(f);
  }

  void _onConfigComplete(int id) {
    if (id == configNonce && state == RadioState.configuring) {
      _setState(RadioState.loadingNodes);
      _nodesRetry = 0;
      _wantConfig(nodesNonce, 'база нод');
      _armNodesWatch();
    } else if ((id == nodesNonce || id == fullNonce) &&
        state == RadioState.loadingNodes) {
      _nodesWatch?.cancel();
      connectedSince = DateTime.now();
      _setState(RadioState.ready);
    }
  }

  void _wantConfig(int nonce, String what) {
    _app('want_config: $what ($nonce)');
    send(ToRadio(wantConfigId: nonce)).catchError((Object e) {
      _app('want_config не отправлен: $e');
    });
  }

  /// Нода молчит в фазе базы нод: повтор, затем полный конфиг, затем
  /// считаем подключение готовым (ноды придут из эфира).
  void _armNodesWatch() {
    _nodesWatch?.cancel();
    _nodesWatch = Timer(nodesTimeout, () {
      if (state != RadioState.loadingNodes) return;
      switch (_nodesRetry++) {
        case 0:
          _app('Нет ответа на запрос базы нод — повтор');
          _wantConfig(nodesNonce, 'база нод');
          _armNodesWatch();
        case 1:
          _app('Нет ответа — запрашиваю полную конфигурацию');
          _wantConfig(fullNonce, 'полная конфигурация');
          _armNodesWatch();
        default:
          _app('База нод не получена — работаем без неё');
          connectedSince = DateTime.now();
          _setState(RadioState.ready);
      }
    });
  }

  void _onLog(NodeLogChunk chunk) {
    lastRx = DateTime.now();
    switch (chunk) {
      case NodeLogRecord(:final bytes):
        try {
          journal.add(
            JournalKind.node,
            describeLogRecord(LogRecord.fromBuffer(bytes)),
          );
        } catch (_) {
          journal.add(
            JournalKind.node,
            'LogRecord (${bytes.length} байт) не разобран',
          );
        }
      case NodeLogText(:final text):
        for (final l in text.split('\n')) {
          if (l.trim().isNotEmpty) journal.add(JournalKind.node, l.trimRight());
        }
    }
  }

  Future<void> _onClosed(Transport t, String reason) async {
    // Закрытие из _teardown (наша же ошибка/остановка) — не второй разрыв.
    if (_stopped || !identical(t, _t)) return;
    disconnects++;
    final held = connectedSince == null
        ? ''
        : ' (держалось ${formatDuration(DateTime.now().difference(connectedSince!))})';
    _app('Разрыв: $reason$held');
    await _teardown();
    _scheduleReconnect();
  }

  void _scheduleReconnect({Duration? delay}) {
    if (_stopped || !autoReconnect) {
      _setState(RadioState.idle);
      return;
    }
    _setState(RadioState.waitingReconnect);
    final d = delay ?? reconnectDelay;
    _app('Переподключение через ${d.inSeconds} с');
    _reconnect?.cancel();
    _reconnect = Timer(d, _connect);
  }

  Future<void> _teardown() async {
    _heartbeat?.cancel();
    _nodesWatch?.cancel();
    queue.reset();
    // Копия: _teardown может зайти повторно (разрыв во время отключения).
    final subs = [..._subs];
    _subs.clear();
    for (final s in subs) {
      await s.cancel();
    }
    final t = _t;
    _t = null;
    connectedSince = null;
    if (t != null) {
      try {
        await t.close();
      } catch (_) {}
    }
  }

  /// Повторить подключение к последней цели (после «Отключить»).
  Future<void> reconnect() async {
    if (target == null) return;
    _stopped = false;
    await _connect();
  }

  Future<void> disconnect({bool quiet = false}) async {
    final wasActive = !_stopped;
    _stopped = true;
    _reconnect?.cancel();
    if (_t != null) {
      try {
        await send(ToRadio(disconnect: true));
      } catch (_) {}
    }
    await _teardown();
    myNodeNum = null;
    _setState(RadioState.idle);
    if (wasActive && !quiet) _app('Отключено');
  }

  bool _disposed = false;

  void _setState(RadioState s) {
    if (_disposed) return;
    state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopped = true;
    _reconnect?.cancel();
    _teardown();
    _packets.close();
    super.dispose();
  }
}

String formatDuration(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  return h > 0 ? '$hч $mм $sс' : (m > 0 ? '$mм $sс' : '$sс');
}
