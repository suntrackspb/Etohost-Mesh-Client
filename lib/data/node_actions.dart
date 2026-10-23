import 'package:drift/drift.dart';

import '../core/proto/mesh.dart';
import '../core/radio/send_queue.dart';
import 'database.dart';

/// Действия с нодой из карточки — как в официальном iOS-клиенте.
/// hop_limit не задаём никогда: решает прошивка (масштабирование хопов в 2.8).
class NodeActions {
  NodeActions(this.db, this._send, this._myNum, this._nextId);

  final AppDatabase db;
  final Future<DeliveryResult> Function(MeshPacket p) _send;
  final int? Function() _myNum;
  final int Function() _nextId;

  int _me() {
    final me = _myNum();
    if (me == null) throw StateError('нет соединения с нодой');
    return me;
  }

  /// Админ-команда своей ноде; флаг в БД меняем только после подтверждения.
  Future<bool> _admin(AdminMessage m) async {
    final me = _me();
    final r = await _send(
      MeshPacket(
        id: _nextId(),
        to: me,
        wantAck: true,
        priority: MeshPacket_Priority.RELIABLE,
        decoded: Data(
          portnum: PortNum.ADMIN_APP,
          payload: m.writeToBuffer(),
          wantResponse: true,
        ),
      ),
    );
    return r.status == DeliveryStatus.acked;
  }

  Future<void> _update(int num, NodesCompanion c) =>
      (db.update(db.nodes)..where((n) => n.num.equals(num))).write(c);

  Future<bool> setFavorite(int num, bool favorite) async {
    final ok = await _admin(
      favorite
          ? AdminMessage(setFavoriteNode: num)
          : AdminMessage(removeFavoriteNode: num),
    );
    if (ok) await _update(num, NodesCompanion(isFavorite: Value(favorite)));
    return ok;
  }

  Future<bool> setIgnored(int num, bool ignored) async {
    final ok = await _admin(
      ignored
          ? AdminMessage(setIgnoredNode: num)
          : AdminMessage(removeIgnoredNode: num),
    );
    if (ok) await _update(num, NodesCompanion(isIgnored: Value(ignored)));
    return ok;
  }

  /// Удалить из NodeDB своей ноды и из локальной базы.
  Future<bool> remove(int num) async {
    final ok = await _admin(AdminMessage(removeByNodenum: num));
    if (ok) await (db.delete(db.nodes)..where((n) => n.num.equals(num))).go();
    return ok;
  }

  /// Трассировка: ответ придёт TRACEROUTE_APP с request_id = id запроса
  /// (его сохраняет PacketRouter). Возвращает id запроса.
  Future<(int, DeliveryResult)> traceroute(int num) async {
    _me();
    final id = _nextId();
    final r = await _send(
      MeshPacket(
        id: id,
        to: num,
        wantAck: true,
        decoded: Data(
          portnum: PortNum.TRACEROUTE_APP,
          payload: RouteDiscovery().writeToBuffer(),
          wantResponse: true,
        ),
      ),
    );
    return (id, r);
  }

  Future<User> _ownUser() async {
    final me = _me();
    final own = await (db.select(
      db.nodes,
    )..where((n) => n.num.equals(me))).getSingleOrNull();
    if (own == null) throw StateError('своя нода ещё не загружена');
    return ownUser(own);
  }

  /// Разослать свою NodeInfo всем — чтобы новую ноду быстрее узнали сеть
  /// и зеркало (без этого сервис картинок её не пускает). Без подтверждения:
  /// у широковещательного пакета его некому дать.
  Future<DeliveryResult> broadcastNodeInfo() async {
    final user = await _ownUser();
    return _send(
      MeshPacket(
        id: _nextId(),
        to: 0xffffffff,
        decoded: Data(
          portnum: PortNum.NODEINFO_APP,
          payload: user.writeToBuffer(),
        ),
      ),
    );
  }

  /// Разослать свою позицию всем (координаты своей ноды из базы).
  /// Без подтверждения, hop_limit не задаём.
  Future<DeliveryResult> broadcastPosition() async {
    final me = _me();
    final own = await (db.select(
      db.nodes,
    )..where((n) => n.num.equals(me))).getSingleOrNull();
    if (own == null || !hasPosition(own)) {
      throw StateError('у своей ноды нет координат');
    }
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _send(
      MeshPacket(
        id: _nextId(),
        to: 0xffffffff,
        decoded: Data(
          portnum: PortNum.POSITION_APP,
          payload: Position(
            latitudeI: (own.latitude! * 1e7).round(),
            longitudeI: (own.longitude! * 1e7).round(),
            altitude: own.altitude,
            time: now,
          ).writeToBuffer(),
        ),
      ),
    );
  }

  /// Отправить свою NodeInfo и попросить ответную (ключ, имя).
  Future<DeliveryResult> exchangeNodeInfo(int num) async {
    final user = await _ownUser();
    return _send(
      MeshPacket(
        id: _nextId(),
        to: num,
        wantAck: true,
        decoded: Data(
          portnum: PortNum.NODEINFO_APP,
          payload: user.writeToBuffer(),
          wantResponse: true,
        ),
      ),
    );
  }

  /// Запросить LocalStats (телеметрия ответит TELEMETRY_APP).
  Future<DeliveryResult> requestLocalStats(int num) {
    _me();
    return _send(
      MeshPacket(
        id: _nextId(),
        to: num,
        wantAck: true,
        decoded: Data(
          portnum: PortNum.TELEMETRY_APP,
          payload: Telemetry(localStats: LocalStats()).writeToBuffer(),
          wantResponse: true,
        ),
      ),
    );
  }
}

/// Есть ли у ноды координаты (0,0 — «нет позиции»).
bool hasPosition(Node n) =>
    n.latitude != null &&
    n.longitude != null &&
    !(n.latitude == 0 && n.longitude == 0);

/// User своей ноды из строки БД.
User ownUser(Node n) => User(
  id: n.userId.isNotEmpty
      ? n.userId
      : '!${n.num.toRadixString(16).padLeft(8, '0')}',
  longName: n.longName,
  shortName: n.shortName,
  hwModel: HardwareModel.valueOf(n.hwModel),
  role: Config_DeviceConfig_Role.valueOf(n.role),
  publicKey: n.publicKey,
  isUnmessagable: n.isUnmessagable,
);

/// Один хоп трассировки; [snr] — null, если неизвестен.
typedef Hop = ({int num, double? snr});

/// Разобранный результат трассировки: путь туда и обратно,
/// включая начальную и конечную ноду.
class TracerouteResult {
  const TracerouteResult({
    required this.time,
    required this.towards,
    required this.back,
  });

  final DateTime time;
  final List<Hop> towards;

  /// Пусто — обратный путь неизвестен (старая прошивка).
  final List<Hop> back;

  /// SNR в RouteDiscovery — ×4, INT8_MIN (-128) = неизвестно.
  static double? _snr(List<int> l, int i) =>
      i < l.length && l[i] != -128 ? l[i] / 4 : null;

  /// [me] — своя нода (начало пути), запись — ответ цели.
  factory TracerouteResult.parse(TracerouteRecord rec, int me) {
    final rd = RouteDiscovery.fromBuffer(rec.data);
    final there = [me, ...rd.route, rec.targetNum];
    final towards = [
      for (var i = 0; i < there.length; i++)
        (num: there[i], snr: i == 0 ? null : _snr(rd.snrTowards, i - 1)),
    ];
    final back = <Hop>[];
    if (rd.snrBack.isNotEmpty) {
      final path = [rec.targetNum, ...rd.routeBack, me];
      for (var i = 0; i < path.length; i++) {
        back.add((num: path[i], snr: i == 0 ? null : _snr(rd.snrBack, i - 1)));
      }
    }
    return TracerouteResult(time: rec.time, towards: towards, back: back);
  }
}
