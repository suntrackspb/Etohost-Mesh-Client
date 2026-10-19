import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/core/radio/send_queue.dart';

MeshPacket _pkt({bool wantAck = true}) =>
    MeshPacket(to: broadcastNum, wantAck: wantAck);

void main() {
  test('пакеты уходят по одному: следующий — после QueueStatus', () {
    fakeAsync((fa) {
      final sent = <ToRadio>[];
      final q = SendQueue((m) async => sent.add(m));
      q.enqueue(_pkt());
      q.enqueue(_pkt());
      fa.flushMicrotasks();
      expect(sent, hasLength(1));
      q.onQueueStatus(
        QueueStatus(res: 0, free: 15, meshPacketId: sent[0].packet.id),
      );
      fa.flushMicrotasks();
      expect(sent, hasLength(2));
    });
  });

  test('без QueueStatus очередь не встаёт — идёт дальше по таймауту', () {
    fakeAsync((fa) {
      final sent = <ToRadio>[];
      final q = SendQueue((m) async => sent.add(m));
      q.enqueue(_pkt());
      q.enqueue(_pkt());
      fa.elapse(const Duration(seconds: 6));
      expect(sent, hasLength(2));
    });
  });

  test('ACK и NAK по Routing', () {
    fakeAsync((fa) {
      final sent = <ToRadio>[];
      final q = SendQueue((m) async => sent.add(m));
      DeliveryResult? a, b;
      q.enqueue(_pkt()).then((r) => a = r);
      q.enqueue(_pkt()).then((r) => b = r);
      fa.elapse(const Duration(seconds: 11));
      q.onRouting(sent[0].packet.id, Routing_Error.NONE);
      q.onRouting(sent[1].packet.id, Routing_Error.NO_CHANNEL);
      fa.flushMicrotasks();
      expect(a!.status, DeliveryStatus.acked);
      expect(b!.status, DeliveryStatus.failed);
      expect(b!.error, Routing_Error.NO_CHANNEL);
    });
  });

  test(
    'без want_ack — готово после приёма нодой; таймаут ACK; отказ очереди',
    () {
      fakeAsync((fa) {
        final sent = <ToRadio>[];
        final q = SendQueue((m) async => sent.add(m));
        DeliveryResult? noAck, timeout, rejected;
        q.enqueue(_pkt(wantAck: false)).then((r) => noAck = r);
        fa.flushMicrotasks();
        q.onQueueStatus(QueueStatus(meshPacketId: sent[0].packet.id));
        q.enqueue(_pkt()).then((r) => timeout = r);
        q.enqueue(_pkt()).then((r) => rejected = r);
        fa.flushMicrotasks();
        q.onQueueStatus(QueueStatus(meshPacketId: sent[1].packet.id));
        fa.flushMicrotasks();
        q.onQueueStatus(QueueStatus(res: 1, meshPacketId: sent[2].packet.id));
        fa.elapse(const Duration(minutes: 6));
        expect(noAck!.status, DeliveryStatus.acked);
        expect(timeout!.status, DeliveryStatus.timeout);
        expect(rejected!.status, DeliveryStatus.rejected);
      });
    },
  );

  test('reset() завершает всё как disconnected', () {
    fakeAsync((fa) {
      final q = SendQueue((m) async {});
      final results = <DeliveryResult>[];
      q.enqueue(_pkt()).then(results.add);
      q.enqueue(_pkt()).then(results.add);
      fa.flushMicrotasks();
      q.reset();
      fa.flushMicrotasks();
      expect(
        results.map((r) => r.status),
        everyElement(DeliveryStatus.disconnected),
      );
      expect(results, hasLength(2));
    });
  });
}
