import '../../core/proto/mesh.dart';
import '../../core/radio/send_queue.dart';
import '../database.dart';

/// Ошибка сохранения — текст для пользователя (форма показывает `$e`).
class SaveError implements Exception {
  const SaveError(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Связь пропала посреди сохранения: чаще всего нода применила настройки
/// и ушла в перезагрузку (LoRa на 2.7, владелец, сеть).
const rebooting =
    'Связь с нодой пропала — похоже, она перезагружается и применяет '
    'настройки. После переподключения проверьте значения.';

/// Отправка админ-команд настроек своей ноде (как saveUser/saveConfig в iOS):
/// RELIABLE, want_ack, без сессионного ключа (он нужен только для удалённых нод).
/// hop_limit не задаём.
class AdminSettings {
  AdminSettings(this._send, this._myNum, this._nextId);

  final Future<DeliveryResult> Function(MeshPacket p) _send;
  final int? Function() _myNum;
  final int Function() _nextId;

  /// [response] — просить ноду ответить (get_*_request).
  Future<bool> send(AdminMessage m, {bool response = false}) async {
    final me = _myNum();
    if (me == null) throw const SaveError('Нет соединения с нодой');
    final r = await _send(
      MeshPacket(
        id: _nextId(),
        to: me,
        wantAck: true,
        priority: MeshPacket_Priority.RELIABLE,
        decoded: Data(
          portnum: PortNum.ADMIN_APP,
          payload: m.writeToBuffer(),
          wantResponse: response,
        ),
      ),
    );
    // Нода приняла команду и сразу ушла в перезагрузку, не успев ответить
    // ACK (смена LoRa на 2.7, владельца и т. п.) — изменение применено.
    if (r.status == DeliveryStatus.disconnected && r.accepted) return true;
    if (r.status == DeliveryStatus.disconnected) {
      throw const SaveError(rebooting);
    }
    if (r.status == DeliveryStatus.failed) {
      throw SaveError('Ошибка ноды: ${r.error?.name}');
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

/// set_config своей ноде; при подтверждении — сохранить конфиг в БД
/// (ключ `config.<name>`, как у PacketRouter).
Future<bool> saveConfig(
  AdminSettings admin,
  AppDatabase db,
  String name,
  Config cfg,
) async {
  final ok = await admin.send(AdminMessage(setConfig: cfg));
  if (ok) {
    await storeConfig(db, name, cfg);
    // Нода может поправить значения (смена региона урезает мощность) и не
    // перезагрузиться — перечитываем раздел, ответ запишет PacketRouter.
    final type = configTypeOf(cfg);
    if (type != null) {
      _refresh(admin, AdminMessage(getConfigRequest: type));
    }
  }
  return ok;
}

/// Тип запроса get_config для раздела (номера совпадают с порядком oneof).
AdminMessage_ConfigType? configTypeOf(Config cfg) {
  final v = cfg.whichPayloadVariant();
  return v == Config_PayloadVariant.notSet
      ? null
      : AdminMessage_ConfigType.valueOf(v.index);
}

AdminMessage_ModuleConfigType? moduleTypeOf(ModuleConfig cfg) {
  final v = cfg.whichPayloadVariant();
  return v == ModuleConfig_PayloadVariant.notSet
      ? null
      : AdminMessage_ModuleConfigType.valueOf(v.index);
}

/// Запрос раздела в фоне; ошибки не важны — нода могла уйти в перезагрузку,
/// тогда конфиг придёт при переподключении.
void _refresh(AdminSettings admin, AdminMessage m) {
  admin.send(m, response: true).catchError((Object _) => false);
}

/// Записать конфиг в БД под ключом `config.<name>`.
Future<void> storeConfig(AppDatabase db, String name, Config cfg) => db
    .into(db.configBlobs)
    .insertOnConflictUpdate(
      ConfigBlobsCompanion.insert(
        key: 'config.$name',
        data: cfg.writeToBuffer(),
        updated: DateTime.now(),
      ),
    );

/// Отправить ModuleConfig своей ноде и после ACK записать в БД.
Future<bool> saveModuleConfig(
  AdminSettings admin,
  AppDatabase db,
  String name,
  ModuleConfig cfg,
) async {
  final ok = await admin.send(AdminMessage(setModuleConfig: cfg));
  if (ok) {
    await db
        .into(db.configBlobs)
        .insertOnConflictUpdate(
          ConfigBlobsCompanion.insert(
            key: 'module.$name',
            data: cfg.writeToBuffer(),
            updated: DateTime.now(),
          ),
        );
    final type = moduleTypeOf(cfg);
    if (type != null) {
      _refresh(admin, AdminMessage(getModuleConfigRequest: type));
    }
  }
  return ok;
}
