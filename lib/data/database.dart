import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/proto/mesh.dart';

part 'database.g.dart';

/// Ключи [AppSettings].
abstract final class AppSettingKeys {
  /// 'true'/'false'; по умолчанию включено.
  static const autoConnect = 'connection.autoConnect';

  /// Переподключаться при обрыве: 'true'/'false', по умолчанию включено.
  static const autoReconnect = 'connection.autoReconnect';

  /// Проверять новую версию на GitHub при запуске (по умолчанию — да).
  static const updateAutoCheck = 'update.autoCheck';

  /// Версия, про которую попросили больше не напоминать.
  static const updateDismissed = 'update.dismissed';

  /// Зеркало: 'true'/'false', по умолчанию выключено.
  static const mirrorEnabled = 'mirror.enabled';

  /// Адрес зеркала как ввёл пользователь; по умолчанию пусто.
  static const mirrorAddress = 'mirror.address';
  static const glyphZipLevel = 'chat.glyphZipLevel';

  /// Тема: 'system' / 'light' / 'dark' (по умолчанию — как в системе).
  static const theme = 'app.theme';

  /// MQTT-прокси в этом приложении ('true'/'false', по умолчанию — да):
  /// выключить пересылку, не меняя настройку ноды.
  static const mqttProxyLocal = 'mqtt.proxyLocal';

  /// Уведомления ('true'/'false', по умолчанию — включены).
  static const notifyDirect = 'notify.direct';
  static const notifyReaction = 'notify.reaction';
  static const notifyReply = 'notify.reply';
  static const notifyMention = 'notify.mention';

  /// Разрешение на уведомления уже спрашивали ('true').
  static const notifyAsked = 'notify.asked';

  /// Windows/Linux: крестик сворачивает в трей ('true'/'false', по умолчанию — да).
  static const closeToTray = 'app.closeToTray';

  /// Показывать картинки i.jab.su и img.etohost.ru в ленте ('true'/'false',
  /// по умолчанию — да).
  static const showImages = 'chat.showImages';

  /// Свои загруженные картинки: JSON-список (id, url, токен удаления, срок).
  static const imageUploads = 'images.uploads';

  /// Карта: разрешить вращение жестом ('true'/'false', по умолчанию — нет).
  static const mapRotate = 'map.rotate';

  /// Группировать близкие ноды на карте: 'true'/'false', по умолчанию да.
  static const mapCluster = 'map.cluster';

  /// Подложка карты: [MapStyle].name, по умолчанию auto.
  static const mapStyle = 'map.style';

  /// Скрывать ноды дальше радиуса от центра ('true'/'false', по умолчанию — нет).
  static const areaEnabled = 'nodes.area.enabled';

  /// Радиус, км (по умолчанию 100).
  static const areaRadiusKm = 'nodes.area.radiusKm';

  /// Центр области: «широта, долгота».
  static const areaCenter = 'nodes.area.center';

  /// Передавать позицию телефона своей ноде ('true'/'false', по умолчанию — нет).
  static const positionShare = 'position.share';

  /// Как часто передавать позицию, минуты (по умолчанию 15).
  static const positionIntervalMin = 'position.intervalMin';

  /// Время последнего прочитанного сообщения канала (ISO-8601).
  static String channelRead(String key) => 'chat.read.$key';

  /// То же для личной переписки с нодой.
  static String directRead(int num) => 'dm.read.$num';
}

/// Состояние исходящего. Новые значения — только в конец (хранится индекс).
enum AckState {
  none,

  /// В очереди или отправлено, ждём подтверждения.
  pending,
  acked,

  /// Сеть вернула ошибку маршрутизации ([Messages.ackError]).
  failed,

  /// Подтверждения не дождались.
  timeout,

  /// Нода не приняла пакет или соединение разорвано.
  notSent,
}

/// Ноды сети. Ключ — номер ноды (uint32).
class Nodes extends Table {
  IntColumn get num => integer()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get longName => text().withDefault(const Constant(''))();
  TextColumn get shortName => text().withDefault(const Constant(''))();
  IntColumn get hwModel => integer().withDefault(const Constant(0))();
  IntColumn get role => integer().withDefault(const Constant(0))();
  BlobColumn get publicKey => blob().nullable()();

  /// Нода не принимает личные сообщения (`User.is_unmessagable`).
  BoolColumn get isUnmessagable =>
      boolean().withDefault(const Constant(false))();

  /// Нода подписывает пакеты XEdDSA (прошивка 2.8, `NodeInfo.has_xeddsa_signed`).
  BoolColumn get hasXeddsaSigned =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastHeard => dateTime().nullable()();
  RealColumn get snr => real().nullable()();
  IntColumn get hopsAway => integer().nullable()();
  BoolColumn get viaMqtt => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isIgnored => boolean().withDefault(const Constant(false))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get altitude => integer().nullable()();
  IntColumn get batteryLevel => integer().nullable()();
  RealColumn get voltage => real().nullable()();
  RealColumn get channelUtilization => real().nullable()();
  RealColumn get airUtilTx => real().nullable()();
  IntColumn get uptimeSeconds => integer().nullable()();

  /// RSSI последнего пакета из эфира.
  IntColumn get rssi => integer().nullable()();

  /// Пресет модема по данным зеркала («MediumFast»).
  TextColumn get modemPreset => text().nullable()();

  /// Слышали через свою ноду.
  BoolColumn get onRadio => boolean().withDefault(const Constant(false))();

  /// Знаем из зеркала.
  BoolColumn get onMirror => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {num};
}

/// Текстовые сообщения (общие каналы и личные).
@TableIndex(name: 'messages_channel_time', columns: {#channelKey, #rxTime})
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// id пакета Meshtastic; вместе с [fromNum] — ключ дедупликации эфир/зеркало.
  IntColumn get packetId => integer()();
  IntColumn get fromNum => integer()();
  IntColumn get toNum => integer()();

  /// Индекс канала на своей ноде (для отправки); у сообщений из зеркала — null.
  IntColumn get channel => integer().nullable()();

  /// Имя канала в нижнем регистре — по нему лента и склейка с зеркалом.
  TextColumn get channelKey => text().withDefault(const Constant(''))();
  TextColumn get body => text()();
  DateTimeColumn get rxTime => dateTime()();
  BoolColumn get isOutgoing => boolean().withDefault(const Constant(false))();
  IntColumn get replyId => integer().nullable()();
  IntColumn get emoji => integer().withDefault(const Constant(0))();
  RealColumn get rxSnr => real().nullable()();
  IntColumn get rxRssi => integer().nullable()();
  IntColumn get hopStart => integer().nullable()();
  IntColumn get hopLimit => integer().nullable()();
  BoolColumn get viaMqtt => boolean().withDefault(const Constant(false))();

  /// Личное, зашифрованное ключом получателя (PKI).
  BoolColumn get pkiEncrypted => boolean().withDefault(const Constant(false))();

  /// Подпись XEdDSA проверена прошивкой (2.8, `MeshPacket.xeddsa_signed`).
  BoolColumn get xeddsaSigned => boolean().withDefault(const Constant(false))();

  /// Доказательство доставки исходящего (`MeshPacket_AckProofStatus`), null — нет данных.
  IntColumn get ackProof => integer().nullable()();
  IntColumn get ackState =>
      intEnum<AckState>().withDefault(const Constant(0))();

  /// Routing.Error при [AckState.failed].
  IntColumn get ackError => integer().nullable()();
  BoolColumn get heardOnRadio => boolean().withDefault(const Constant(false))();
  BoolColumn get heardOnMirror =>
      boolean().withDefault(const Constant(false))();

  /// id записи на зеркале (для relay_update и подгрузки истории).
  IntColumn get mirrorId => integer().nullable().unique()();
  IntColumn get relayCount => integer().withDefault(const Constant(0))();
  BoolColumn get isBot => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {packetId, fromNum},
  ];
}

/// Каналы своей ноды (индекс 0–7). Имя строки — MeshChannel, чтобы не путать с protobuf Channel.
@DataClassName('MeshChannel')
class Channels extends Table {
  IntColumn get index => integer()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get role => integer().withDefault(const Constant(0))();
  BlobColumn get psk => blob().nullable()();

  /// ChannelSettings целиком (MQTT, точность позиции, mute, id) — для
  /// редактирования; null — запись старше схемы 7.
  BlobColumn get settings => blob().nullable()();

  @override
  Set<Column> get primaryKey => {index};
}

/// История позиций (для трека и карты).
@DataClassName('PositionRecord')
@TableIndex(name: 'positions_node_time', columns: {#nodeNum, #time})
class Positions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get nodeNum => integer()();
  DateTimeColumn get time => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get altitude => integer().nullable()();
}

/// Телеметрия как есть (protobuf Telemetry) — графики разбирают сами.
@TableIndex(name: 'telemetry_node_kind_time', columns: {#nodeNum, #kind, #time})
class TelemetryLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get nodeNum => integer()();
  DateTimeColumn get time => dateTime()();

  /// Имя варианта Telemetry: deviceMetrics, environmentMetrics, powerMetrics…
  TextColumn get kind => text()();
  BlobColumn get data => blob()();
}

/// Результаты трассировки маршрута (RouteDiscovery как есть).
@DataClassName('TracerouteRecord')
class Traceroutes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get requestId => integer()();
  IntColumn get targetNum => integer()();
  DateTimeColumn get time => dateTime()();
  BlobColumn get data => blob()();
}

/// Соседи из NeighborInfo: кто кого слышит напрямую.
@DataClassName('NeighborRecord')
class Neighbors extends Table {
  IntColumn get nodeNum => integer()();
  IntColumn get neighborNum => integer()();
  RealColumn get snr => real()();
  DateTimeColumn get time => dateTime()();

  @override
  Set<Column> get primaryKey => {nodeNum, neighborNum};
}

/// Своя нода (одна строка, id = 0).
@DataClassName('MyNodeRecord')
class MyNode extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get myNodeNum => integer()();
  IntColumn get rebootCount => integer().withDefault(const Constant(0))();
  TextColumn get firmwareVersion => text().withDefault(const Constant(''))();
  BlobColumn get metadata => blob().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Config / ModuleConfig своей ноды как protobuf-байты.
/// Ключ: `config.lora`, `module.mqtt` и т. п. (имя варианта payload).
class ConfigBlobs extends Table {
  TextColumn get key => text()();
  BlobColumn get data => blob()();
  DateTimeColumn get updated => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Недавние подключения (по одному на адрес).
@DataClassName('RecentConnection')
class RecentConnections extends Table {
  /// EndpointKind.name: ble / tcp / serial.
  TextColumn get kind => text()();
  TextColumn get address => text()();
  TextColumn get name => text().withDefault(const Constant(''))();

  /// Номер ноды на том конце (если успели узнать).
  IntColumn get nodeNum => integer().nullable()();
  DateTimeColumn get lastUsed => dateTime()();

  @override
  Set<Column> get primaryKey => {kind, address};
}

/// Настройки приложения: ключ → строка. Ключи — в `AppSettingKeys`.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Nodes,
    Messages,
    Channels,
    Positions,
    TelemetryLog,
    Traceroutes,
    Neighbors,
    MyNode,
    ConfigBlobs,
    RecentConnections,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 8;

  // До первого релиза схема пересоздаётся целиком (данные — кэш с ноды).
  // После релиза — нормальные пошаговые миграции.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // С 5-й версии у тестеров уже есть данные — только добавляем колонки.
      if (from >= 5 && from <= 7) {
        if (from == 5) {
          await m.addColumn(nodes, nodes.hasXeddsaSigned);
          await m.addColumn(messages, messages.xeddsaSigned);
          await m.addColumn(messages, messages.ackProof);
        }
        if (from <= 6) await m.addColumn(channels, channels.settings);
        await m.addColumn(nodes, nodes.rssi);
        await m.addColumn(nodes, nodes.modemPreset);
        return;
      }
      for (final t in allTables) {
        await m.deleteTable(t.actualTableName);
      }
      await m.createAll();
    },
  );

  static QueryExecutor _open() => driftDatabase(name: 'meshtastic');

  /// Все ноды, свежие сверху.
  /// Ноды; без [includeMirror] — только услышанные через свою ноду.
  Stream<List<Node>> watchNodes({bool includeMirror = false}) =>
      (select(nodes)
            ..where((n) => includeMirror ? const Constant(true) : n.onRadio)
            ..orderBy([
              (n) => OrderingTerm(
                expression: n.isFavorite,
                mode: OrderingMode.desc,
              ),
              (n) => OrderingTerm(
                expression: n.lastHeard,
                mode: OrderingMode.desc,
                nulls: NullsOrder.last,
              ),
            ]))
          .watch();

  /// Общая лента канала (широковещательные сообщения).
  Stream<List<Message>> watchChannelMessages(
    String channelKey, {
    bool includeMirror = false,
    int limit = 500,
  }) =>
      (select(messages)
            ..where(
              (m) =>
                  m.channelKey.equals(channelKey) &
                  m.toNum.equals(0xffffffff) &
                  _visible(m, includeMirror),
            )
            ..orderBy([(m) => OrderingTerm.desc(m.rxTime)])
            ..limit(limit))
          .watch();

  /// Каналы, в которых есть сообщения (для каналов зеркала, которых нет на своей ноде).
  Stream<List<String>> watchMessageChannelKeys({bool includeMirror = false}) {
    final q = selectOnly(messages, distinct: true)
      ..addColumns([messages.channelKey])
      ..where(
        messages.toNum.equals(0xffffffff) &
            messages.channelKey.equals('').not() &
            _visible(messages, includeMirror),
      );
    return q.map((r) => r.read(messages.channelKey)!).watch();
  }

  /// Личная переписка с [peer], свежие первыми.
  Stream<List<Message>> watchDirectMessages(int peer, {int limit = 500}) =>
      (select(messages)
            ..where(
              (m) =>
                  m.toNum.equals(0xffffffff).not() &
                  (m.fromNum.equals(peer) | m.toNum.equals(peer)),
            )
            ..orderBy([(m) => OrderingTerm.desc(m.rxTime)])
            ..limit(limit))
          .watch();

  /// Непрочитанные личные от [peer] новее [since] (null — все).
  Stream<int> watchDirectUnread(int peer, DateTime? since) {
    final count = messages.id.count();
    final q = selectOnly(messages)
      ..addColumns([count])
      ..where(
        messages.toNum.equals(0xffffffff).not() &
            messages.fromNum.equals(peer) &
            messages.isOutgoing.not() &
            (since == null
                ? const Constant(true)
                : messages.rxTime.isBiggerThanValue(since)),
      );
    return q.map((r) => r.read(count) ?? 0).watchSingle();
  }

  /// Все личные сообщения, свежие первыми (для списка диалогов).
  Stream<List<Message>> watchAllDirect() =>
      (select(messages)
            ..where((m) => m.toNum.equals(0xffffffff).not())
            ..orderBy([(m) => OrderingTerm.desc(m.rxTime)]))
          .watch();

  /// Без зеркала видно услышанное в эфире и своё исходящее.
  static Expression<bool> _visible($MessagesTable m, bool includeMirror) =>
      includeMirror ? const Constant(true) : m.heardOnRadio | m.isOutgoing;

  /// Непрочитанные входящие в канале: новее [since] (null — все).
  Stream<int> watchUnreadCount(
    String channelKey,
    DateTime? since, {
    bool includeMirror = false,
  }) {
    final count = messages.id.count();
    final q = selectOnly(messages)
      ..addColumns([count])
      ..where(
        messages.channelKey.equals(channelKey) &
            messages.toNum.equals(0xffffffff) &
            messages.isOutgoing.not() &
            _visible(messages, includeMirror) &
            (since == null
                ? const Constant(true)
                : messages.rxTime.isBiggerThanValue(since)),
      );
    return q.map((r) => r.read(count) ?? 0).watchSingle();
  }

  /// Самый старый id зеркала — точка для подгрузки истории.
  Future<int?> oldestMirrorId() async {
    final q = selectOnly(messages)..addColumns([messages.mirrorId.min()]);
    return (await q.getSingle()).read(messages.mirrorId.min());
  }

  Stream<List<RecentConnection>> watchRecent({int limit = 5}) =>
      (select(recentConnections)
            ..orderBy([(r) => OrderingTerm.desc(r.lastUsed)])
            ..limit(limit))
          .watch();

  Future<void> touchRecent(
    String kind,
    String address,
    String name,
    int? nodeNum,
  ) => into(recentConnections).insertOnConflictUpdate(
    RecentConnectionsCompanion.insert(
      kind: kind,
      address: address,
      name: Value(name),
      nodeNum: Value(nodeNum),
      lastUsed: DateTime.now(),
    ),
  );

  Future<void> forgetRecent(String kind, String address) => (delete(
    recentConnections,
  )..where((r) => r.kind.equals(kind) & r.address.equals(address))).go();

  Future<String?> getSetting(String key) async => (await (select(
    appSettings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Stream<String?> watchSetting(String key) => (select(
    appSettings,
  )..where((s) => s.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  /// Все настройки разом (для составных, вроде конфига зеркала).
  Stream<Map<String, String>> watchSettings() => select(
    appSettings,
  ).watch().map((rows) => {for (final r in rows) r.key: r.value});

  Future<void> setSetting(String key, String value) => into(
    appSettings,
  ).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));

  /// После сброса NodeDB своей ноды: ноды только с радио удаляем, у нод из
  /// зеркала снимаем отметку радио. Свою ноду и (при [keepFavorites])
  /// избранные не трогаем — прошивка их тоже сохранит.
  Future<void> resetRadioNodes(int me, {required bool keepFavorites}) =>
      transaction(() async {
        Expression<bool> kept(Nodes n) =>
            n.num.equals(me) |
            (keepFavorites ? n.isFavorite : const Constant(false));
        await (delete(
          nodes,
        )..where((n) => n.onRadio & n.onMirror.not() & kept(n).not())).go();
        await (update(nodes)..where((n) => kept(n).not())).write(
          const NodesCompanion(onRadio: Value(false), isFavorite: Value(false)),
        );
      });

  /// После сброса к заводским: каналы и конфиги ноды больше не верны.
  Future<void> clearDeviceConfig() => transaction(() async {
    await delete(channels).go();
    await delete(configBlobs).go();
  });

  /// Канал с ноды или после сохранения своей правки.
  Future<void> upsertChannel(Channel c) =>
      into(channels).insertOnConflictUpdate(
        ChannelsCompanion.insert(
          index: Value(c.index),
          name: Value(c.settings.name),
          role: Value(c.role.value),
          psk: Value(
            c.settings.psk.isEmpty ? null : Uint8List.fromList(c.settings.psk),
          ),
          settings: Value(c.settings.writeToBuffer()),
        ),
      );

  Stream<List<MeshChannel>> watchChannels() =>
      (select(channels)..orderBy([(c) => OrderingTerm.asc(c.index)])).watch();
}
