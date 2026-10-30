import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/delivery.dart';
import 'package:flutter_test/flutter_test.dart';

Message m(AckState s, [MeshPacket_AckProofStatus? proof]) => Message(
  id: 1,
  packetId: 1,
  fromNum: 1,
  toNum: 2,
  channelKey: '',
  body: '',
  rxTime: DateTime(2026),
  isOutgoing: true,
  emoji: 0,
  viaMqtt: false,
  heardOnRadio: false,
  heardOnMirror: false,
  relayCount: 0,
  isBot: false,
  pkiEncrypted: true,
  xeddsaSigned: false,
  ackState: s,
  ackProof: proof?.value,
);

void main() {
  test('доказательство доставки 2.8', () {
    expect(deliveryOf(m(AckState.acked)), Delivery.delivered);
    expect(
      deliveryOf(m(AckState.acked, MeshPacket_AckProofStatus.ACK_PROOF_ABSENT)),
      Delivery.delivered,
    );
    expect(
      deliveryOf(m(AckState.acked, MeshPacket_AckProofStatus.ACK_PROOF_VALID)),
      Delivery.proven,
    );
    expect(
      deliveryOf(
        m(AckState.acked, MeshPacket_AckProofStatus.ACK_PROOF_INVALID),
      ),
      Delivery.forged,
    );
    expect(deliveryOf(m(AckState.timeout)), Delivery.failed);
  });
}
