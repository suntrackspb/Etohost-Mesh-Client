import '../../core/proto/mesh.dart';
import '../../core/radio/send_queue.dart';

/// Отправка админ-команд настроек своей ноде (как saveUser/saveConfig в iOS):
/// RELIABLE, want_ack, без сессионного ключа (он нужен только для удалённых нод).
/// hop_limit не задаём.
class AdminSettings {
  AdminSettings(this._send, this._myNum, this._nextId);

  final Future<DeliveryResult> Function(MeshPacket p) _send;
  final int? Function() _myNum;
  final int Function() _nextId;

  Future<bool> send(AdminMessage m) async {
    final me = _myNum();
    if (me == null) throw StateError('нет соединения с нодой');
    final r = await _send(
      MeshPacket(
        id: _nextId(),
        to: me,
        wantAck: true,
        priority: MeshPacket_Priority.RELIABLE,
        decoded: Data(portnum: PortNum.ADMIN_APP, payload: m.writeToBuffer()),
      ),
    );
    if (r.status == DeliveryStatus.failed) {
      throw StateError('ошибка ноды: ${r.error?.name}');
    }
    return r.status == DeliveryStatus.acked;
  }

  /// Несколько команд одной транзакцией: нода применит их разом.
  Future<bool> transaction(List<AdminMessage> ms) async {
    if (!await send(AdminMessage(beginEditSettings: true))) return false;
    for (final m in ms) {
      if (!await send(m)) return false;
    }
    return send(AdminMessage(commitEditSettings: true));
  }
}
