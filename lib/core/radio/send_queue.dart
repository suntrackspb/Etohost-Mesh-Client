import 'dart:async';
import 'dart:collection';
import 'dart:math';

import '../proto/mesh.dart';

/// Итог доставки пакета.
enum DeliveryStatus {
  /// Получатель (или ретранслятор для широковещательных) подтвердил.
  acked,

  /// Нода или сеть вернула ошибку маршрутизации ([DeliveryResult.error]).
  failed,

  /// Ноде было некуда положить пакет (очередь полна / отказ).
  rejected,

  /// Подтверждения не дождались.
  timeout,

  /// Соединение разорвано до подтверждения.
  disconnected,
}

class DeliveryResult {
  const DeliveryResult(this.status, [this.error, this.ackProof]);
  final DeliveryStatus status;
  final Routing_Error? error;

  /// Доказательство доставки (2.8); на 2.7 — ACK_PROOF_ABSENT.
  final MeshPacket_AckProofStatus? ackProof;

  bool get ok => status == DeliveryStatus.acked;

  @override
  String toString() =>
      error == null ? status.name : '${status.name}(${error!.name})';
}

/// Очередь отправки MeshPacket в ноду (по образцу Meshtastic-Android):
/// пакеты уходят по одному; после каждого ждём `QueueStatus` с его id
/// (сигнал прошивки «теряющийся», поэтому по таймауту считаем принятым);
/// подтверждение доставки — `Routing` с `request_id` = id пакета.
class SendQueue {
  SendQueue(
    this._write, {
    this.queueTimeout = const Duration(seconds: 5),
    this.ackTimeout = const Duration(minutes: 5),
  });

  final Future<void> Function(ToRadio msg) _write;
  final Duration queueTimeout;
  final Duration ackTimeout;

  final _waiting = Queue<_Pending>();
  final _inFlight = <int, _Pending>{};
  _Pending? _current;
  Completer<bool>? _queueAck;
  bool _running = false;
  final _rnd = Random();

  /// Пакетов ждут отправки или подтверждения.
  int get pending => _waiting.length + _inFlight.length;

  /// Новый id пакета (ненулевой uint32).
  int nextId() => _rnd.nextInt(0x7fffffff) + 1;

  /// Поставить пакет в очередь. Если `id == 0` — будет назначен.
  /// Результат завершается по ACK/NAK; без `want_ack` — сразу после приёма нодой.
  Future<DeliveryResult> enqueue(MeshPacket p) {
    if (p.id == 0) p.id = nextId();
    final item = _Pending(p);
    _waiting.add(item);
    _pump();
    return item.done.future;
  }

  /// Нода сообщила состояние своей очереди.
  void onQueueStatus(QueueStatus q) {
    final cur = _current;
    if (cur == null || q.meshPacketId != cur.packet.id) return;
    final ack = _queueAck;
    if (ack != null && !ack.isCompleted) ack.complete(q.res == 0);
  }

  /// Пришёл `Routing` с `request_id` = [requestId].
  void onRouting(
    int requestId,
    Routing_Error error, {
    MeshPacket_AckProofStatus? ackProof,
  }) {
    final item = _inFlight.remove(requestId);
    if (item == null) return;
    item.finish(
      error == Routing_Error.NONE
          ? DeliveryResult(DeliveryStatus.acked, null, ackProof)
          : DeliveryResult(DeliveryStatus.failed, error, ackProof),
    );
  }

  /// Разрыв: всё, что не подтверждено, завершается как [DeliveryStatus.disconnected].
  void reset() {
    const r = DeliveryResult(DeliveryStatus.disconnected);
    _current?.finish(r);
    final ack = _queueAck;
    if (ack != null && !ack.isCompleted) ack.complete(false);
    for (final i in [..._waiting, ..._inFlight.values]) {
      i.finish(r);
    }
    _waiting.clear();
    _inFlight.clear();
  }

  Future<void> _pump() async {
    if (_running) return;
    _running = true;
    try {
      while (_waiting.isNotEmpty) {
        final item = _waiting.removeFirst();
        _current = item;
        final accepted = Completer<bool>();
        _queueAck = accepted;
        try {
          await _write(ToRadio(packet: item.packet));
        } catch (_) {
          item.finish(const DeliveryResult(DeliveryStatus.disconnected));
          continue;
        }
        final ok = await accepted.future.timeout(
          queueTimeout,
          onTimeout: () => true,
        );
        _current = null;
        _queueAck = null;
        if (item.isDone) continue; // reset() во время ожидания
        if (!ok) {
          item.finish(const DeliveryResult(DeliveryStatus.rejected));
        } else if (!item.packet.wantAck) {
          item.finish(const DeliveryResult(DeliveryStatus.acked));
        } else {
          _inFlight[item.packet.id] = item;
          item.timer = Timer(ackTimeout, () {
            if (_inFlight.remove(item.packet.id) != null) {
              item.finish(const DeliveryResult(DeliveryStatus.timeout));
            }
          });
        }
      }
    } finally {
      _running = false;
    }
  }
}

class _Pending {
  _Pending(this.packet);
  final MeshPacket packet;
  final done = Completer<DeliveryResult>();
  Timer? timer;

  bool get isDone => done.isCompleted;

  void finish(DeliveryResult r) {
    timer?.cancel();
    if (!done.isCompleted) done.complete(r);
  }
}
