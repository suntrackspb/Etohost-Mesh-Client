import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/proto/channel_names.dart';
import '../core/proto/mesh.dart';
import 'database.dart';
import 'settings/node_text.dart';

/// Раскладывает FromRadio по таблицам. UI читает только из БД,
/// поэтому эфир, зеркало и история после перезапуска выглядят одинаково.
class PacketRouter {
  PacketRouter(this.db);

  final AppDatabase db;

  Future<void> handle(FromRadio f) async {
    switch (f.whichPayloadVariant()) {
      case FromRadio_PayloadVariant.nodeInfo:
        await _upsertNodeInfo(f.nodeInfo);
      case FromRadio_PayloadVariant.channel:
        await _upsertChannel(f.channel);
      case FromRadio_PayloadVariant.packet:
        await _onPacket(f.packet);
      case FromRadio_PayloadVariant.myInfo:
        // Единственная строка id = 0; дубли от старых версий удаляем.
        await (db.delete(db.myNode)..where((m) => m.id.equals(0).not())).go();
        await db
            .into(db.myNode)
            .insertOnConflictUpdate(
              MyNodeCompanion.insert(
                id: const Value(0),
                myNodeNum: f.myInfo.myNodeNum,
                rebootCount: Value(f.myInfo.rebootCount),
              ),
            );
      case FromRadio_PayloadVariant.metadata:
        await (db.update(db.myNode)..where((m) => m.id.equals(0))).write(
          MyNodeCompanion(
            firmwareVersion: Value(f.metadata.firmwareVersion),
            metadata: Value(f.metadata.writeToBuffer()),
          ),
        );
      case FromRadio_PayloadVariant.config:
        await _saveConfig(
          'config.${f.config.whichPayloadVariant().name}',
          f.config.writeToBuffer(),
        );
      case FromRadio_PayloadVariant.moduleConfig:
        await _saveConfig(
          'module.${f.moduleConfig.whichPayloadVariant().name}',
          f.moduleConfig.writeToBuffer(),
        );
      default:
        break;
    }
  }

  Future<void> _upsertNodeInfo(NodeInfo n) async {
    final u = n.user;
    final pos = n.hasPosition() ? n.position : null;
    final hasPos = pos != null && pos.latitudeI != 0 && pos.longitudeI != 0;
    final m = n.hasDeviceMetrics() ? n.deviceMetrics : null;
    await db
        .into(db.nodes)
        .insertOnConflictUpdate(
          NodesCompanion.insert(
            num: Value(n.num),
            userId: Value(u.id),
            longName: Value(u.longName),
            shortName: Value(u.shortName),
            hwModel: Value(u.hwModel.value),
            role: Value(u.role.value),
            publicKey: Value(
              u.publicKey.isEmpty ? null : Uint8List.fromList(u.publicKey),
            ),
            isUnmessagable: Value(u.isUnmessagable),
            lastHeard: Value(n.lastHeard == 0 ? null : _time(n.lastHeard)),
            snr: Value(n.snr == 0 ? null : n.snr),
            hopsAway: Value(n.hasHopsAway() ? n.hopsAway : null),
            viaMqtt: Value(n.viaMqtt),
            isFavorite: Value(n.isFavorite),
            isIgnored: Value(n.isIgnored),
            hasXeddsaSigned: Value(n.hasXeddsaSigned),
            latitude: Value(hasPos ? pos.latitudeI / 1e7 : null),
            longitude: Value(hasPos ? pos.longitudeI / 1e7 : null),
            altitude: Value(hasPos && pos.hasAltitude() ? pos.altitude : null),
            batteryLevel: Value(
              m != null && m.hasBatteryLevel() ? m.batteryLevel : null,
            ),
            voltage: Value(m != null && m.hasVoltage() ? m.voltage : null),
            onRadio: const Value(true),
          ),
        );
  }

  /// NodeInfo из эфира: обновляем только данные пользователя — позиция,
  /// метрики и флаги ноды остаются.
  Future<void> _upsertUser(int num, User u, int heard) async {
    final user = NodesCompanion(
      userId: Value(u.id),
      longName: Value(u.longName),
      shortName: Value(u.shortName),
      hwModel: Value(u.hwModel.value),
      role: Value(u.role.value),
      isUnmessagable: Value(u.isUnmessagable),
      lastHeard: Value(_time(heard)),
      onRadio: const Value(true),
    );
    await db
        .into(db.nodes)
        .insert(
          user.copyWith(
            num: Value(num),
            publicKey: Value(
              u.publicKey.isEmpty ? null : Uint8List.fromList(u.publicKey),
            ),
          ),
          onConflict: DoUpdate(
            // Пустой ключ в пакете не стирает известный.
            (_) => u.publicKey.isEmpty
                ? user
                : user.copyWith(
                    publicKey: Value(Uint8List.fromList(u.publicKey)),
                  ),
          ),
        );
  }

  Future<void> _upsertChannel(Channel c) async {
    await db
        .into(db.channels)
        .insertOnConflictUpdate(
          ChannelsCompanion.insert(
            index: Value(c.index),
            name: Value(c.settings.name),
            role: Value(c.role.value),
            psk: Value(
              c.settings.psk.isEmpty
                  ? null
                  : Uint8List.fromList(c.settings.psk),
            ),
          ),
        );
  }

  Future<void> _onPacket(MeshPacket p) async {
    // Любой пакет — признак, что нода жива.
    await _touchNode(p);
    if (!p.hasDecoded()) return;
    final d = p.decoded;
    switch (d.portnum) {
      case PortNum.TEXT_MESSAGE_APP:
        await _insertText(p, utf8.decode(d.payload, allowMalformed: true));
      case PortNum.POSITION_APP:
        await _onPosition(p.from, Position.fromBuffer(d.payload), _rxTime(p));
      case PortNum.TELEMETRY_APP:
        await _onTelemetry(p.from, Telemetry.fromBuffer(d.payload), _rxTime(p));
      case PortNum.ROUTING_APP:
        if (d.requestId != 0) {
          await _onRouting(d.requestId, Routing.fromBuffer(d.payload));
        }
      case PortNum.TRACEROUTE_APP:
        // Ответ на наш запрос: request_id ≠ 0, отправитель — цель трассировки.
        if (d.requestId != 0) {
          await db
              .into(db.traceroutes)
              .insert(
                TraceroutesCompanion.insert(
                  requestId: d.requestId,
                  targetNum: p.from,
                  time: _time(_rxTime(p)),
                  data: Uint8List.fromList(d.payload),
                ),
              );
        }
      case PortNum.NEIGHBORINFO_APP:
        await _onNeighbors(NeighborInfo.fromBuffer(d.payload), _rxTime(p));
      case PortNum.ADMIN_APP:
        await _onAdmin(AdminMessage.fromBuffer(d.payload));
      case PortNum.NODEINFO_APP:
        await _upsertUser(p.from, User.fromBuffer(d.payload), _rxTime(p));
      default:
        break;
    }
  }

  Future<void> _saveConfig(String key, List<int> data) => db
      .into(db.configBlobs)
      .insertOnConflictUpdate(
        ConfigBlobsCompanion.insert(
          key: key,
          data: Uint8List.fromList(data),
          updated: DateTime.now(),
        ),
      );

  Future<void> _onPosition(int from, Position pos, int rxTime) async {
    if (pos.latitudeI == 0 && pos.longitudeI == 0) return; // позиция скрыта
    final lat = pos.latitudeI / 1e7, lon = pos.longitudeI / 1e7;
    final alt = pos.hasAltitude() ? pos.altitude : null;
    await db
        .into(db.positions)
        .insert(
          PositionsCompanion.insert(
            nodeNum: from,
            time: _time(pos.time != 0 ? pos.time : rxTime),
            latitude: lat,
            longitude: lon,
            altitude: Value(alt),
          ),
        );
    await (db.update(db.nodes)..where((n) => n.num.equals(from))).write(
      NodesCompanion(
        latitude: Value(lat),
        longitude: Value(lon),
        altitude: Value(alt),
      ),
    );
  }

  Future<void> _onTelemetry(int from, Telemetry t, int rxTime) async {
    final kind = t.whichVariant();
    if (kind == Telemetry_Variant.notSet) return;
    await db
        .into(db.telemetryLog)
        .insert(
          TelemetryLogCompanion.insert(
            nodeNum: from,
            time: _time(t.time != 0 ? t.time : rxTime),
            kind: kind.name,
            data: t.writeToBuffer(),
          ),
        );
    if (kind == Telemetry_Variant.deviceMetrics) {
      final m = t.deviceMetrics;
      await (db.update(db.nodes)..where((n) => n.num.equals(from))).write(
        NodesCompanion(
          batteryLevel: m.hasBatteryLevel()
              ? Value(m.batteryLevel)
              : const Value.absent(),
          voltage: m.hasVoltage() ? Value(m.voltage) : const Value.absent(),
          channelUtilization: m.hasChannelUtilization()
              ? Value(m.channelUtilization)
              : const Value.absent(),
          airUtilTx: m.hasAirUtilTx()
              ? Value(m.airUtilTx)
              : const Value.absent(),
          uptimeSeconds: m.hasUptimeSeconds()
              ? Value(m.uptimeSeconds)
              : const Value.absent(),
        ),
      );
    }
  }

  /// ACK/NAK на наше сообщение.
  Future<void> _onRouting(int requestId, Routing r) async {
    final ok = r.errorReason == Routing_Error.NONE;
    await (db.update(db.messages)..where(
          (m) => m.packetId.equals(requestId) & m.isOutgoing.equals(true),
        ))
        .write(
          MessagesCompanion(
            ackState: Value(ok ? AckState.acked : AckState.failed),
            ackError: Value(ok ? null : r.errorReason.value),
          ),
        );
  }

  Future<void> _onNeighbors(NeighborInfo info, int rxTime) async {
    final time = _time(rxTime);
    await db.batch((b) {
      b.deleteWhere(db.neighbors, (n) => n.nodeNum.equals(info.nodeId));
      b.insertAll(db.neighbors, [
        for (final n in info.neighbors)
          NeighborsCompanion.insert(
            nodeNum: info.nodeId,
            neighborNum: n.nodeId,
            snr: n.snr,
            time: time,
          ),
      ]);
    });
  }

  /// Ответы на admin-запросы конфигурации сохраняем так же, как конфиг при подключении.
  Future<void> _onAdmin(AdminMessage a) async {
    switch (a.whichPayloadVariant()) {
      case AdminMessage_PayloadVariant.getConfigResponse:
        final c = a.getConfigResponse;
        await _saveConfig(
          'config.${c.whichPayloadVariant().name}',
          c.writeToBuffer(),
        );
      case AdminMessage_PayloadVariant.getModuleConfigResponse:
        final c = a.getModuleConfigResponse;
        await _saveConfig(
          'module.${c.whichPayloadVariant().name}',
          c.writeToBuffer(),
        );
      case AdminMessage_PayloadVariant.getChannelResponse:
        await _upsertChannel(a.getChannelResponse);
      case AdminMessage_PayloadVariant.getRingtoneResponse:
        await _saveConfig(ringtone.key, utf8.encode(a.getRingtoneResponse));
      case AdminMessage_PayloadVariant.getCannedMessageModuleMessagesResponse:
        await _saveConfig(
          cannedMessages.key,
          utf8.encode(a.getCannedMessageModuleMessagesResponse),
        );
      default:
        break;
    }
  }

  Future<void> _touchNode(MeshPacket p) async {
    if (p.from == 0) return;
    await db
        .into(db.nodes)
        .insert(
          NodesCompanion.insert(
            num: Value(p.from),
            lastHeard: Value(_time(_rxTime(p))),
            snr: Value(p.rxSnr == 0 ? null : p.rxSnr),
            viaMqtt: Value(p.viaMqtt),
            onRadio: const Value(true),
          ),
          onConflict: DoUpdate(
            (_) => NodesCompanion(
              lastHeard: Value(_time(_rxTime(p))),
              snr: Value(p.rxSnr == 0 ? null : p.rxSnr),
              viaMqtt: Value(p.viaMqtt),
              onRadio: const Value(true),
            ),
          ),
        );
  }

  Future<void> _insertText(MeshPacket p, String text) async {
    // Личные сообщения — по собеседнику, ключ канала им не нужен.
    final key = p.to == broadcastNum
        ? channelKey(await _channelName(p.channel))
        : '';
    final radio = MessagesCompanion(
      channel: Value(p.channel),
      rxSnr: Value(p.rxSnr == 0 ? null : p.rxSnr),
      rxRssi: Value(p.rxRssi == 0 ? null : p.rxRssi),
      hopStart: Value(p.hopStart == 0 ? null : p.hopStart),
      hopLimit: Value(p.hopLimit),
      viaMqtt: Value(p.viaMqtt),
      xeddsaSigned: Value(p.xeddsaSigned),
      heardOnRadio: const Value(true),
    );
    await db
        .into(db.messages)
        .insert(
          MessagesCompanion.insert(
            packetId: p.id,
            fromNum: p.from,
            toNum: p.to,
            channel: Value(p.channel),
            channelKey: Value(key),
            body: text,
            rxTime: _time(_rxTime(p)),
            replyId: Value(p.decoded.replyId == 0 ? null : p.decoded.replyId),
            emoji: Value(p.decoded.emoji),
            rxSnr: radio.rxSnr,
            rxRssi: radio.rxRssi,
            hopStart: radio.hopStart,
            hopLimit: radio.hopLimit,
            viaMqtt: radio.viaMqtt,
            pkiEncrypted: Value(p.pkiEncrypted),
            xeddsaSigned: radio.xeddsaSigned,
            heardOnRadio: const Value(true),
          ),
          // Уже пришло из зеркала (или нода повторила) — дополняем данными эфира.
          onConflict: DoUpdate(
            (_) => radio,
            target: [db.messages.packetId, db.messages.fromNum],
          ),
        );
    // Подписанный пакет — значит, нода подписывает (на случай, если NodeInfo старая).
    if (p.xeddsaSigned) {
      await (db.update(db.nodes)..where((n) => n.num.equals(p.from))).write(
        const NodesCompanion(hasXeddsaSigned: Value(true)),
      );
    }
  }

  /// Имя канала по индексу на своей ноде; безымянный основной — имя пресета.
  Future<String> _channelName(int index) async {
    final c = await (db.select(
      db.channels,
    )..where((c) => c.index.equals(index))).getSingleOrNull();
    if (c == null) return '';
    if (c.name.isNotEmpty) return c.name;
    if (c.role != Channel_Role.PRIMARY.value) return '';
    final lora = await (db.select(
      db.configBlobs,
    )..where((b) => b.key.equals('config.lora'))).getSingleOrNull();
    // Конфиг LoRa ещё не пришёл — у прошивки по умолчанию LongFast.
    if (lora == null) return 'LongFast';
    return modemPresetName(Config.fromBuffer(lora.data).lora);
  }

  static int _rxTime(MeshPacket p) =>
      p.rxTime != 0 ? p.rxTime : DateTime.now().millisecondsSinceEpoch ~/ 1000;

  static DateTime _time(int unixSeconds) =>
      DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
}
