import 'package:drift/drift.dart';

import '../core/geo/geo.dart';
import '../core/proto/mesh.dart';
import '../core/radio/send_queue.dart';
import 'database.dart';

/// Координаты с GPS телефона/ПК.
typedef Fix = ({double lat, double lon, double? altitude, DateTime time});

/// Варианты интервала передачи, минуты.
const positionIntervalOptions = [5, 15, 30, 60];
const defaultPositionIntervalMin = 15;

/// Сдвиг, меньше которого позицию повторно не передаём (кроме раза в 4 интервала).
const positionMinMoveKm = 0.05;

/// Передаёт позицию телефона своей ноде — для нод без GPS.
///
/// Пакет POSITION_APP уходит только своей ноде (to = myNodeNum): прошивка сама
/// решает, когда и с какой точностью рассылать позицию в сеть (умная рассылка,
/// точность канала, в 2.8 — выключено по умолчанию). hop_limit не задаём.
class PositionSharer {
  PositionSharer(this.db, this._send, this._myNum, this._nextId);

  final AppDatabase db;
  final Future<DeliveryResult> Function(MeshPacket p) _send;
  final int? Function() _myNum;
  final int Function() _nextId;

  Duration interval = const Duration(minutes: defaultPositionIntervalMin);

  Fix? lastSent;

  /// Нужно ли передавать [f] с учётом прошлой передачи.
  bool shouldSend(Fix f) {
    final last = lastSent;
    if (last == null) return true;
    final elapsed = f.time.difference(last.time);
    if (elapsed < interval) return false;
    if (elapsed >= interval * 4) return true;
    return distanceKm(
          (lat: last.lat, lon: last.lon),
          (lat: f.lat, lon: f.lon),
        ) >=
        positionMinMoveKm;
  }

  /// Новая точка с GPS; true — передана.
  Future<bool> onFix(Fix f) async {
    final me = _myNum();
    if (me == null || !shouldSend(f)) return false;
    final r = await _send(
      MeshPacket(
        id: _nextId(),
        to: me,
        decoded: Data(
          portnum: PortNum.POSITION_APP,
          payload: positionOf(f).writeToBuffer(),
        ),
      ),
    );
    if (r.status == DeliveryStatus.rejected ||
        r.status == DeliveryStatus.disconnected) {
      return false;
    }
    lastSent = f;
    // Свой пакет из эфира не вернётся — сразу показываем на карте.
    await (db.update(db.nodes)..where((n) => n.num.equals(me))).write(
      NodesCompanion(
        latitude: Value(f.lat),
        longitude: Value(f.lon),
        altitude: Value(f.altitude?.round()),
      ),
    );
    return true;
  }
}

Position positionOf(Fix f) => Position(
  latitudeI: (f.lat * 1e7).round(),
  longitudeI: (f.lon * 1e7).round(),
  altitude: f.altitude?.round(),
  time: f.time.millisecondsSinceEpoch ~/ 1000,
  timestamp: f.time.millisecondsSinceEpoch ~/ 1000,
  locationSource: Position_LocSource.LOC_EXTERNAL,
);
