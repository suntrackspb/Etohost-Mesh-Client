import '../core/proto/mesh.dart';
import 'database.dart';

/// Состояние доставки исходящего для отображения.
enum Delivery {
  sending,

  /// ACK получен (от получателя или ретранслятора — на 2.7 не различить).
  delivered,

  /// 2.8: доказательство доставки проверено ключом получателя.
  proven,

  /// 2.8: доказательство не сошлось — подтверждение подделано.
  forged,
  failed,
}

Delivery deliveryOf(Message m) => switch (m.ackState) {
  AckState.none || AckState.pending => Delivery.sending,
  AckState.acked => switch (MeshPacket_AckProofStatus.valueOf(
    m.ackProof ?? 0,
  )) {
    MeshPacket_AckProofStatus.ACK_PROOF_VALID => Delivery.proven,
    MeshPacket_AckProofStatus.ACK_PROOF_INVALID => Delivery.forged,
    _ => Delivery.delivered,
  },
  AckState.failed || AckState.timeout || AckState.notSent => Delivery.failed,
};

/// Подсказка к значку доставки.
String deliveryHint(Message m) => switch (m.ackState) {
  AckState.none || AckState.pending => 'Отправляется',
  AckState.failed =>
    'Ошибка: ${Routing_Error.valueOf(m.ackError ?? 0)?.name ?? m.ackError}',
  AckState.timeout => 'Нет подтверждения',
  AckState.notSent => 'Не отправлено',
  AckState.acked => switch (deliveryOf(m)) {
    Delivery.proven => 'Доставлено, подтверждено получателем',
    Delivery.forged => 'Подтверждение не прошло проверку — возможна подделка',
    _ => 'Доставлено',
  },
};
