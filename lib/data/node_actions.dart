import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/proto/mesh.dart';
import '../core/radio/send_queue.dart';
import 'database.dart';
import 'message_sender.dart' show directBlock;
import 'telemetry.dart';

/// Действия с нодой из карточки — как в официальном iOS-клиенте.
/// hop_limit не задаём никогда: решает прошивка (масштабирование хопов в 2.8).
class NodeActions {
  NodeActions(
    this.db,
    this._send,
    this._myNum,
    this._nextId, [
    this._radioUser,
  ]);

  final AppDatabase db;
  final Future<DeliveryResult> Function(MeshPacket p) _send;
  final int? Function() _myNum;
  final int Function() _nextId;

  /// User своей ноды, как его прислало радио (с MAC и прочими полями).
  final User? Function()? _radioUser;

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

  /// Игнор: флаг в нашей базе ставится всегда — он же прячет сообщения из
  /// зеркала. [radio] — нода есть в базе своей ноды и она подключена: тогда
  /// команда уходит и ей (перестанет принимать пакеты от этой ноды).
  Future<bool> setIgnored(int num, bool ignored, {required bool radio}) async {
    await _update(num, NodesCompanion(isIgnored: Value(ignored)));
    if (!radio) return true;
    return _admin(
      ignored
          ? AdminMessage(setIgnoredNode: num)
          : AdminMessage(removeIgnoredNode: num),
    );
  }

  /// Удалить из NodeDB своей ноды и из локальной базы.
  Future<bool> remove(int num) async {
    final ok = await _admin(AdminMessage(removeByNodenum: num));
    if (ok) await (db.delete(db.nodes)..where((n) => n.num.equals(num))).go();
    return ok;
  }

  /// Трассировка: ответ придёт TRACEROUTE_APP с request_id = id запроса
  /// (PacketRouter заполнит запись). Запись в журнале создаётся сразу —
  /// без ответа она остаётся «нет ответа». Возвращает id запроса.
  Future<(int, DeliveryResult)> traceroute(int num) async {
    _me();
    final id = _nextId();
    final row = await db
        .into(db.traceroutes)
        .insert(
          TraceroutesCompanion.insert(
            requestId: id,
            targetNum: num,
            time: DateTime.now(),
            data: Uint8List(0),
            answered: const Value(false),
          ),
        );
    final DeliveryResult r;
    try {
      r = await _send(
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
    } catch (_) {
      // Не ушла — в журнал не пишем.
      await (db.delete(db.traceroutes)..where((t) => t.id.equals(row))).go();
      rethrow;
    }
    return (id, r);
  }

  Future<User> _ownUser() async {
    final me = _me();
    final own = await (db.select(
      db.nodes,
    )..where((n) => n.num.equals(me))).getSingleOrNull();
    if (own == null) throw StateError('своя нода ещё не загружена');
    final user = nodeInfoUser(own, _radioUser?.call());
    // Своя NodeInfo без MAC попадает в NodeDB самой ноды; после перезагрузки
    // прошивка считает свой номер занятым «чужим» MAC и берёт случайный.
    if (!hasMac(user)) throw StateError('MAC своей ноды неизвестен');
    return user;
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
  Future<DeliveryResult> broadcastPosition() async => _send(
    MeshPacket(
      id: _nextId(),
      to: 0xffffffff,
      decoded: Data(
        portnum: PortNum.POSITION_APP,
        payload: (await _ownPosition()).writeToBuffer(),
      ),
    ),
  );

  /// Отправить свою позицию ноде и попросить её ответную.
  Future<DeliveryResult> exchangePosition(int num) async => _send(
    MeshPacket(
      id: _nextId(),
      to: num,
      wantAck: true,
      decoded: Data(
        portnum: PortNum.POSITION_APP,
        payload: (await _ownPosition()).writeToBuffer(),
        wantResponse: true,
      ),
    ),
  );

  Future<Position> _ownPosition() async {
    final me = _me();
    final own = await (db.select(
      db.nodes,
    )..where((n) => n.num.equals(me))).getSingleOrNull();
    if (own == null || !hasPosition(own)) {
      throw StateError('у своей ноды нет координат');
    }
    return Position(
      latitudeI: (own.latitude! * 1e7).round(),
      longitudeI: (own.longitude! * 1e7).round(),
      altitude: own.altitude,
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
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
  Future<DeliveryResult> requestLocalStats(int num) =>
      _requestTelemetry(num, Telemetry(localStats: LocalStats()));

  /// Запросить телеметрию типа [kind]: нода ответит текущими значениями.
  Future<DeliveryResult> requestTelemetry(int num, TelemetryKind kind) =>
      _requestTelemetry(num, kind.request());

  Future<DeliveryResult> _requestTelemetry(int num, Telemetry t) {
    _me();
    return _send(
      MeshPacket(
        id: _nextId(),
        to: num,
        wantAck: true,
        decoded: Data(
          portnum: PortNum.TELEMETRY_APP,
          payload: t.writeToBuffer(),
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
  macaddr: n.macaddr,
);

/// User для рассылки своей NodeInfo: за основу — присланный радио
/// (macaddr и поля, которых нет в БД; без MAC TMesh считает id чужим),
/// имя, роль и ключ — из БД, они могли смениться после подключения.
User nodeInfoUser(Node n, User? radio) {
  final db = ownUser(n);
  if (radio == null) return db;
  return radio.deepCopy()
    ..id = db.id
    ..longName = db.longName
    ..shortName = db.shortName
    ..role = db.role
    ..isUnmessagable = db.isUnmessagable
    ..publicKey = (n.publicKey?.isNotEmpty ?? false)
        ? db.publicKey
        : radio.publicKey;
}

/// MAC задан и не нулевой.
bool hasMac(User u) => u.macaddr.length == 6 && u.macaddr.any((b) => b != 0);

/// Один хоп трассировки; [snr] — null, если неизвестен.
typedef Hop = ({int num, double? snr});

/// Разобранный результат трассировки: путь туда и обратно,
/// включая начальную и конечную ноду.
class TracerouteResult {
  const TracerouteResult({
    this.id = 0,
    this.target = 0,
    required this.time,
    required this.towards,
    required this.back,
    this.answered = true,
  });

  /// Строка журнала (`traceroutes.id`).
  final int id;

  /// До кого трассировка.
  final int target;

  /// Время запроса (у старых записей — время ответа).
  final DateTime time;

  /// false — ответа пока нет (см. [traceStatus]); пути пусты.
  final bool answered;
  final List<Hop> towards;

  /// Пусто — обратный путь неизвестен (старая прошивка).
  final List<Hop> back;

  /// SNR в RouteDiscovery — ×4, INT8_MIN (-128) = неизвестно.
  static double? _snr(List<int> l, int i) =>
      i < l.length && l[i] != -128 ? l[i] / 4 : null;

  /// [me] — своя нода (начало пути), запись — ответ цели.
  factory TracerouteResult.parse(TracerouteRecord rec, int me) {
    if (!rec.answered) {
      return TracerouteResult(
        id: rec.id,
        target: rec.targetNum,
        time: rec.time,
        towards: const [],
        back: const [],
        answered: false,
      );
    }
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
    return TracerouteResult(
      id: rec.id,
      target: rec.targetNum,
      time: rec.time,
      towards: towards,
      back: back,
    );
  }
}

/// Ссылка-контакт для QR, как в официальных клиентах:
/// `https://meshtastic.org/v/#` + SharedContact в base64url без «=».
/// null — делиться нечем: без ключа или нода не принимает личные.
/// Своя нода — с [radioUser] (MAC и прочее), как User в официальных.
String? contactUrl(Node n, {required bool own, User? radioUser}) {
  if (directBlock(n) != null) return null;
  final c = SharedContact(
    nodeNum: n.num,
    user: nodeInfoUser(n, radioUser),
    manuallyVerified: own,
  );
  final b64 = base64Url.encode(c.writeToBuffer()).replaceAll('=', '');
  return 'https://meshtastic.org/v/#$b64';
}
