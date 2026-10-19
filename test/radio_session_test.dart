import 'package:flutter_test/flutter_test.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/core/radio/journal.dart';
import 'package:etohost_mesh/core/radio/radio_session.dart';
import 'package:etohost_mesh/core/radio/send_queue.dart';

import 'support/fake_transport.dart';

void main() {
  test('двухфазный want_config: конфиг → база нод → ready', () async {
    final t = FakeTransport();
    t.onSend = (m) {
      if (m.hasWantConfigId()) {
        Future.microtask(
          () => t.reply(FromRadio(configCompleteId: m.wantConfigId)),
        );
      }
    };
    final s = RadioSession(Journal());
    final states = <RadioState>[];
    s.addListener(() => states.add(s.state));
    await s.connect(RadioTarget('fake', (_) => t));
    await pumpEventQueue();

    expect(
      t.sent.where((m) => m.hasWantConfigId()).map((m) => m.wantConfigId),
      [RadioSession.configNonce, RadioSession.nodesNonce],
    );
    expect(
      states,
      containsAllInOrder([
        RadioState.configuring,
        RadioState.loadingNodes,
        RadioState.ready,
      ]),
    );
    await s.disconnect();
  });

  test(
    'нода молчит на запрос базы нод — повтор, затем полный конфиг',
    () async {
      final t = FakeTransport();
      var nodesAsked = 0;
      t.onSend = (m) {
        if (!m.hasWantConfigId()) return;
        final id = m.wantConfigId;
        if (id == RadioSession.nodesNonce) {
          nodesAsked++;
          return; // как 2.7.23 по Wi‑Fi: не отвечает
        }
        Future.microtask(() => t.reply(FromRadio(configCompleteId: id)));
      };
      final s = RadioSession(Journal())
        ..nodesTimeout = const Duration(milliseconds: 20);
      await s.connect(RadioTarget('fake', (_) => t));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(nodesAsked, 2);
      expect(
        t.sent.where((m) => m.hasWantConfigId()).last.wantConfigId,
        RadioSession.fullNonce,
      );
      expect(s.state, RadioState.ready);
      await s.disconnect();
    },
  );

  test('ACK приходит в sendPacket, разрыв завершает ожидающие', () async {
    final t = FakeTransport();
    t.onSend = (m) {
      if (m.hasPacket()) {
        Future.microtask(() {
          t.reply(
            FromRadio(queueStatus: QueueStatus(meshPacketId: m.packet.id)),
          );
          if (m.packet.channel == 0) {
            t.reply(
              FromRadio(
                packet: MeshPacket(
                  from: 1,
                  decoded: Data(
                    portnum: PortNum.ROUTING_APP,
                    requestId: m.packet.id,
                    payload: Routing(
                      errorReason: Routing_Error.NONE,
                    ).writeToBuffer(),
                  ),
                ),
              ),
            );
          }
        });
      }
    };
    final s = RadioSession(Journal())..autoReconnect = false;
    await s.connect(RadioTarget('fake', (_) => t));

    final ok = await s.sendPacket(MeshPacket(to: broadcastNum, wantAck: true));
    expect(ok.status, DeliveryStatus.acked);

    final pending = s.sendPacket(
      MeshPacket(to: broadcastNum, channel: 1, wantAck: true),
    );
    await pumpEventQueue();
    t.drop('test');
    expect((await pending).status, DeliveryStatus.disconnected);
    s.dispose();
  });
}
