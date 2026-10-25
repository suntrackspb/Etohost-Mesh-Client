import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/proto/mesh.dart';
import '../core/radio/send_queue.dart';
import 'database.dart';
import 'id_bug.dart';
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

  /// Импорт контакта (QR / ссылка): `add_contact` своей ноде и запись в БД,
  /// как в официальных клиентах. Без ключа не импортируем: прошивка
  /// записывает ключ безусловно, и пустой сотрёт уже известный.
  /// true — нода подтвердила; в БД пишем в любом случае (как Android).
  Future<bool> importContact(SharedContact c) async {
    if (contactImportCheck(c, null).blocked) {
      throw StateError('у контакта нет публичного ключа');
    }
    final ok = await _admin(AdminMessage(addContact: c));
    final u = c.user;
    final mac = hasMac(u) ? Value(Uint8List.fromList(u.macaddr)) : null;
    await db
        .into(db.nodes)
        .insertOnConflictUpdate(
          NodesCompanion(
            num: Value(c.nodeNum),
            userId: Value(nodeIdOf(c.nodeNum)),
            longName: Value(u.longName),
            shortName: Value(u.shortName),
            hwModel: Value(u.hwModel.value),
            role: Value(u.role.value),
            isUnmessagable: Value(u.isUnmessagable),
            publicKey: Value(Uint8List.fromList(u.publicKey)),
            macaddr: mac ?? const Value.absent(),
          ),
        );
    return ok;
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

  /// Нода только из зеркала: удалить из локальной базы; зеркало вернёт её,
  /// только когда её услышат позже удаления.
  Future<void> forget(int num) => db.forgetNode(num);

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

  /// Мягкая починка [IdBugPending]: своя NodeInfo с настоящим [mac] —
  /// прошивка перезапишет им свою запись, перезагрузка не нужна.
  Future<DeliveryResult> fixIdBugWithMac(List<int> mac) async {
    final me = _me();
    if (macNodeNum(mac) != me) throw StateError('MAC не от этой ноды');
    final own = await (db.select(
      db.nodes,
    )..where((n) => n.num.equals(me))).getSingleOrNull();
    if (own == null) throw StateError('своя нода ещё не загружена');
    final user = nodeInfoUser(own, _radioUser?.call())
      ..macaddr = Uint8List.fromList(mac);
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

  /// Общая починка: стереть на ноде device.proto (номер, owner) и
  /// nodes.proto (запись с нулевым MAC), перезагрузить — прошивка возьмёт
  /// номер из MAC, ключ в config.proto останется. Имя запоминаем, чтобы
  /// вернуть после переподключения. Сразу перезагрузка, не выключение:
  /// выключение сохранило бы базу заново.
  Future<bool> fixIdBugByReset() async {
    final user = _radioUser?.call();
    if (user != null && user.longName.isNotEmpty) {
      final num = macNodeNum(user.macaddr) ?? _me();
      await db.setSetting(
        AppSettingKeys.pendingOwner,
        encodePendingOwner((
          num: num,
          longName: user.longName,
          shortName: user.shortName,
          isUnmessagable: user.isUnmessagable,
        )),
      );
    }
    final dev = await _admin(
      AdminMessage(deleteFileRequest: '/prefs/device.proto'),
    );
    final nodes = await _admin(
      AdminMessage(deleteFileRequest: '/prefs/nodes.proto'),
    );
    if (!dev && !nodes) return false;
    return _admin(AdminMessage(rebootSeconds: 2));
  }

  /// Вернуть имя после [fixIdBugByReset]; true — отправлено и подтверждено.
  Future<bool> restorePendingOwner() async {
    final p = parsePendingOwner(
      await db.getSetting(AppSettingKeys.pendingOwner),
    );
    if (p == null) return false;
    final me = _me();
    if (p.num != me) return false;
    if (!needsOwnerRestore(p, me, _radioUser?.call())) {
      await db.setSetting(AppSettingKeys.pendingOwner, '');
      return false;
    }
    final ok = await _admin(
      AdminMessage(
        setOwner: User(
          longName: p.longName,
          shortName: p.shortName,
          isUnmessagable: p.isUnmessagable,
        ),
      ),
    );
    if (ok) await db.setSetting(AppSettingKeys.pendingOwner, '');
    return ok;
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

/// `!1234abcd` по номеру ноды.
String nodeIdOf(int num) => '!${num.toRadixString(16).padLeft(8, '0')}';

/// Разобрать ссылку-контакт `https://meshtastic.org/v/#…` (с «=» и без,
/// без схемы тоже). null — не ссылка контакта.
SharedContact? parseContactUrl(String text) {
  final m = RegExp(
    r'^(?:https?://)?(?:www\.)?meshtastic\.org/v/#([A-Za-z0-9_\-+/=]+)$',
  ).firstMatch(text.trim());
  if (m == null) return null;
  var b64 = m[1]!.replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  b64 += '=' * ((4 - b64.length % 4) % 4);
  try {
    final c = SharedContact.fromBuffer(base64Url.decode(b64));
    return c.nodeNum == 0 || !c.hasUser() ? null : c;
  } catch (_) {
    return null;
  }
}

/// Что показать в диалоге импорта. [blocked] — нет ключа, импорт нельзя;
/// [known] — нода уже есть (перезапишется); [keyChanged] — ключ отличается
/// от известного.
typedef ContactImportCheck = ({bool blocked, bool known, bool keyChanged});

ContactImportCheck contactImportCheck(SharedContact c, Node? existing) {
  final key = c.user.publicKey;
  final old = existing?.publicKey;
  return (
    blocked: key.isEmpty,
    known: existing != null,
    keyChanged:
        old != null &&
        old.isNotEmpty &&
        key.isNotEmpty &&
        base64.encode(old) != base64.encode(key),
  );
}
