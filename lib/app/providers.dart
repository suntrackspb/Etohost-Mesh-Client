import 'package:flutter/material.dart' show ThemeMode;
import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_ble/universal_ble.dart';

import '../core/diagnostics/journal_file.dart';
import '../core/geo/geo.dart';
import '../core/proto/channel_names.dart';
import '../core/proto/mesh.dart';
import '../core/radio/endpoint.dart';
import '../core/radio/journal.dart';
import '../core/radio/radio_session.dart';
import '../core/transport/serial_transport.dart';
import '../core/update/update_checker.dart';
import '../data/database.dart';
import '../data/map_style.dart';
import '../data/message_sender.dart';
import '../data/map_points.dart';
import '../data/node_actions.dart';
import '../data/node_filter.dart';
import '../data/position_sharer.dart';
import '../data/mirror_ingest.dart';
import '../data/packet_router.dart';
import '../mirror/mirror_api.dart';
import '../mirror/mirror_config.dart';
import '../mirror/mirror_models.dart';
import '../mirror/mirror_realtime.dart';
import 'position_service.dart';
import '../data/radio_stats.dart';

/// База данных приложения. В тестах подменяется на in-memory.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Файл журнала (ротация 2×1 МБ) — источник журнала для отчётов.
final journalFileProvider = Provider<JournalFile>(
  (ref) => JournalFile(
    getApplicationSupportDirectory().then((d) => Directory('${d.path}/logs')),
  ),
);

final journalProvider = ChangeNotifierProvider<Journal>((ref) {
  final file = ref.read(journalFileProvider);
  return Journal()..sink = file.add;
});

/// Соединение с нодой. Пакеты сразу уходят в БД через [PacketRouter].
final radioProvider = ChangeNotifierProvider<RadioSession>((ref) {
  final session = RadioSession(ref.read(journalProvider));
  ref.read(databaseProvider).getSetting(AppSettingKeys.autoReconnect).then((v) {
    if (v == 'false') session.autoReconnect = false;
  });
  final router = PacketRouter(ref.read(databaseProvider));
  final sub = session.packets.asyncMap(router.handle).listen(null);

  // Успешное подключение (дошли до ready) — в недавние.
  var wasReady = false;
  void onChange() {
    final ready = session.state == RadioState.ready;
    final e = session.target?.endpoint;
    if (ready && !wasReady && e != null) {
      ref
          .read(databaseProvider)
          .touchRecent(e.kind.name, e.address, e.name, session.myNodeNum);
    }
    wasReady = ready;
  }

  session.addListener(onChange);
  ref.onDispose(() {
    session.removeListener(onChange);
    sub.cancel();
    session.dispose();
  });
  return session;
});

/// Конфиг зеркала из настроек. По умолчанию — выключено, адреса нет.
final mirrorConfigProvider = StreamProvider<MirrorConfig>(
  (ref) => ref
      .watch(databaseProvider)
      .watchSettings()
      .map(
        (s) => MirrorConfig(
          enabled: s[AppSettingKeys.mirrorEnabled] == 'true',
          address: s[AppSettingKeys.mirrorAddress] ?? '',
        ),
      )
      .distinct(),
);

/// Показывать ли данные зеркала. Выключили — данные зеркала скрыты (не удалены).
final mirrorActiveProvider = Provider<bool>(
  (ref) => ref.watch(mirrorConfigProvider).value?.active ?? false,
);

/// REST-клиент зеркала; null, пока зеркало не включено.
final mirrorApiProvider = Provider<MirrorApi?>((ref) {
  final cfg = ref.watch(mirrorConfigProvider).value ?? MirrorConfig.off;
  final base = cfg.baseUrl;
  if (!cfg.active || base == null) return null;
  final api = MirrorApi(base);
  ref.onDispose(api.close);
  return api;
});

/// WS-подписка на зеркало; null, пока зеркало не включено.
final mirrorRealtimeProvider = ChangeNotifierProvider<MirrorRealtime?>((ref) {
  final cfg = ref.watch(mirrorConfigProvider).value ?? MirrorConfig.off;
  final ws = cfg.webSocketUrl, api = ref.watch(mirrorApiProvider);
  if (!cfg.active || ws == null || api == null) return null;

  final ingest = MirrorIngest(ref.read(databaseProvider));
  final journal = ref.read(journalProvider);
  // В файл (и отчёт) — без текста ошибки: в нём бывает адрес зеркала.
  void log(String s, [Object? e]) => journal.add(
    JournalKind.app,
    e == null ? s : '$s: $e',
    fileText: e == null ? s : '$s (${e.runtimeType})',
  );

  api.nodes().then(ingest.nodes).catchError((Object e) {
    log('Зеркало: ноды не загружены', e);
  });

  final rt = MirrorRealtime(ws, (e) async {
    switch (e) {
      case MirrorInit(:final messages):
        await ingest.messages(messages);
      case MirrorNewMessage(:final message):
        await ingest.messages([message], live: true);
      case MirrorRelayUpdate(:final messageId, :final relay):
        await ingest.relay(messageId, relay);
      case MirrorNodeUpdate(:final node):
        await ingest.nodes([node]);
      case MirrorOther():
        break;
    }
  }, log: log)..start();
  ref.onDispose(rt.dispose);
  return rt;
});

final nodesProvider = StreamProvider<List<Node>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchNodes(includeMirror: ref.watch(mirrorActiveProvider)),
);

/// Текущий фильтр списка нод (в памяти, на время сессии).
final nodeFilterProvider = StateProvider<NodeFilter>(
  (ref) => const NodeFilter(),
);

/// Список нод после фильтра и сортировки.
final filteredNodesProvider = Provider<AsyncValue<List<Node>>>((ref) {
  final f = ref.watch(nodeFilterProvider);
  final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
  final area = ref.watch(nodeAreaProvider);
  return ref
      .watch(nodesProvider)
      .whenData((l) => f.apply(l, me: me, area: area));
});

/// Ноды на карте: тот же фильтр, что и у списка.
final mapPointsProvider = Provider<List<MapPoint>>((ref) {
  final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
  final nodes = ref.watch(filteredNodesProvider).value ?? const [];
  return mapPoints(nodes, me: me);
});

final channelsProvider = StreamProvider<List<MeshChannel>>(
  (ref) => ref.watch(databaseProvider).watchChannels(),
);

/// Имя пресета модема своей ноды (для безымянного основного канала).
final presetNameProvider = StreamProvider<String>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.configBlobs,
  )..where((b) => b.key.equals('config.lora'))).watchSingleOrNull().map(
    (b) => b == null
        ? 'LongFast'
        : modemPresetName(Config.fromBuffer(b.data).lora),
  );
});

final _messageChannelKeysProvider = StreamProvider<List<String>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchMessageChannelKeys(includeMirror: ref.watch(mirrorActiveProvider)),
);

/// Канал в чате: свой (с индексом на ноде) или только из зеркала.
class ChatChannel {
  const ChatChannel({
    required this.key,
    required this.title,
    this.index,
    this.primary = false,
  });
  final String key;
  final String title;

  /// Индекс на своей ноде; null — канал есть только в зеркале (писать в него нельзя).
  final int? index;
  final bool primary;
}

/// Свои каналы по порядку, затем каналы, известные только по сообщениям (зеркало).
final chatChannelsProvider = Provider<AsyncValue<List<ChatChannel>>>((ref) {
  final own = ref.watch(channelsProvider);
  final preset = ref.watch(presetNameProvider).value ?? 'LongFast';
  final keys = ref.watch(_messageChannelKeysProvider).value ?? const <String>[];
  return own.whenData((rows) {
    final result = <ChatChannel>[];
    for (final c in rows) {
      if (c.role == Channel_Role.DISABLED.value) continue;
      final primary = c.role == Channel_Role.PRIMARY.value;
      final title = channelDisplayName(
        c.name,
        primary: primary,
        presetName: preset,
      );
      if (title.isEmpty) continue;
      result.add(
        ChatChannel(
          key: channelKey(title),
          title: title,
          index: c.index,
          primary: primary,
        ),
      );
    }
    final known = {for (final c in result) c.key};
    for (final k in [...keys]..sort()) {
      if (known.add(k)) result.add(ChatChannel(key: k, title: k));
    }
    return result;
  });
});

/// Шаг подгрузки ленты.
const feedPageSize = 100;

/// Переписка в чате: канал (по ключу имени) или личный диалог с нодой.
/// [id] — строка для маршрута и ключей провайдеров.
sealed class ChatTarget {
  const ChatTarget();
  String get id;

  static ChatTarget parse(String id) {
    if (id.startsWith('dm:')) {
      final n = int.tryParse(id.substring(3));
      if (n != null) return DirectTarget(n);
    }
    return ChannelTarget(id);
  }
}

class ChannelTarget extends ChatTarget {
  const ChannelTarget(this.key);
  final String key;
  @override
  String get id => key;
}

class DirectTarget extends ChatTarget {
  const DirectTarget(this.num);
  final int num;
  @override
  String get id => 'dm:$num';
}

/// Сколько последних сообщений держит лента (растёт при прокрутке вверх).
final feedLimitProvider = StateProvider.family<int, String>(
  (ref, id) => feedPageSize,
);

final feedMessagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  id,
) {
  final db = ref.watch(databaseProvider);
  final limit = ref.watch(feedLimitProvider(id));
  return switch (ChatTarget.parse(id)) {
    ChannelTarget(:final key) => db.watchChannelMessages(
      key,
      includeMirror: ref.watch(mirrorActiveProvider),
      limit: limit,
    ),
    DirectTarget(:final num) => db.watchDirectMessages(num, limit: limit),
  };
});

String readSettingKey(String id) => switch (ChatTarget.parse(id)) {
  ChannelTarget(:final key) => AppSettingKeys.channelRead(key),
  DirectTarget(:final num) => AppSettingKeys.directRead(num),
};

/// Время последнего прочитанного; null — переписку ещё не открывали.
final feedReadProvider = StreamProvider.family<DateTime?, String>(
  (ref, id) => ref
      .watch(databaseProvider)
      .watchSetting(readSettingKey(id))
      .map((v) => v == null ? null : DateTime.tryParse(v)),
);

final unreadCountProvider = StreamProvider.family<int, String>((ref, id) {
  final read = ref.watch(feedReadProvider(id));
  if (!read.hasValue) return const Stream.empty();
  final db = ref.watch(databaseProvider);
  return switch (ChatTarget.parse(id)) {
    ChannelTarget(:final key) => db.watchUnreadCount(
      key,
      read.value,
      includeMirror: ref.watch(mirrorActiveProvider),
    ),
    DirectTarget(:final num) => db.watchDirectUnread(num, read.value),
  };
});

/// Личный диалог: собеседник и последнее сообщение.
class Conversation {
  const Conversation(this.peer, this.last);
  final int peer;
  final Message last;
}

/// Диалоги, свежие первыми.
final conversationsProvider = StreamProvider<List<Conversation>>(
  (ref) => ref.watch(databaseProvider).watchAllDirect().map((all) {
    final seen = <int, Conversation>{};
    for (final m in all) {
      final peer = m.isOutgoing ? m.toNum : m.fromNum;
      seen.putIfAbsent(peer, () => Conversation(peer, m));
    }
    return seen.values.toList();
  }),
);

/// Сумма непрочитанного по каналам и диалогам — для бейджа вкладки «Чат».
final totalUnreadProvider = Provider<int>((ref) {
  final ids = [
    for (final c in ref.watch(chatChannelsProvider).value ?? const []) c.key,
    for (final d in ref.watch(conversationsProvider).value ?? const [])
      DirectTarget(d.peer).id,
  ];
  var total = 0;
  for (final id in ids) {
    total += ref.watch(unreadCountProvider(id)).value ?? 0;
  }
  return total;
});

/// Отправка сообщений через текущее соединение.
final messageSenderProvider = Provider<MessageSender>((ref) {
  final radio = ref.read(radioProvider);
  return MessageSender(
    ref.read(databaseProvider),
    radio.sendPacket,
    () => radio.state == RadioState.ready ? radio.myNodeNum : null,
    radio.queue.nextId,
  );
});

final nodeActionsProvider = Provider<NodeActions>((ref) {
  final radio = ref.read(radioProvider);
  return NodeActions(
    ref.read(databaseProvider),
    radio.sendPacket,
    () => radio.state == RadioState.ready ? radio.myNodeNum : null,
    radio.queue.nextId,
  );
});

/// История трассировок до ноды, новые сверху.
final tracerouteHistoryProvider =
    StreamProvider.family<List<TracerouteResult>, int>((ref, target) {
      final db = ref.watch(databaseProvider);
      final me = ref.watch(radioProvider.select((r) => r.myNodeNum)) ?? 0;
      return (db.select(db.traceroutes)
            ..where((t) => t.targetNum.equals(target))
            ..orderBy([(t) => OrderingTerm.desc(t.time)])
            ..limit(20))
          .watch()
          .map((l) => [for (final r in l) TracerouteResult.parse(r, me)]);
    });

/// Можно ли сейчас отправлять (нода подключена и конфиг загружен).
final canSendProvider = Provider<bool>(
  (ref) => ref.watch(radioProvider.select((r) => r.state)) == RadioState.ready,
);

/// Уровень GlyphZip для исходящих (0 — выкл), запоминается между запусками.
final glyphZipLevelProvider = StreamProvider<int>(
  (ref) => ref
      .watch(databaseProvider)
      .watchSetting(AppSettingKeys.glyphZipLevel)
      .map((v) => int.tryParse(v ?? '') ?? 0),
);

final recentConnectionsProvider = StreamProvider<List<RecentConnection>>(
  (ref) => ref.watch(databaseProvider).watchRecent(),
);

/// «Подключаться к последней ноде при запуске» (по умолчанию — да).
final autoConnectProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(databaseProvider)
      .watchSetting(AppSettingKeys.autoConnect)
      .map((v) => v != 'false'),
);

/// Переподключение при обрыве: сразу в сессию и в настройки.
void setAutoReconnect(WidgetRef ref, bool v) {
  ref.read(radioProvider).autoReconnect = v;
  ref.read(databaseProvider).setSetting(AppSettingKeys.autoReconnect, '$v');
}

Endpoint endpointOf(RecentConnection r) =>
    Endpoint(EndpointKind.values.byName(r.kind), r.address, r.name);

/// Один раз при старте: подключиться к последней ноде, если включено.
final startupConnectProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  if (await db.getSetting(AppSettingKeys.autoConnect) == 'false') return;
  final recent = await db.watchRecent(limit: 1).first;
  if (recent.isEmpty) return;
  final e = endpointOf(recent.single);
  if (e.kind == EndpointKind.serial && !serialSupported) return;
  if (e.kind == EndpointKind.ble && (Platform.isAndroid || Platform.isIOS)) {
    await UniversalBle.requestPermissions(withAndroidFineLocation: false);
  }
  final radio = ref.read(radioProvider);
  // Пользователь уже подключается сам.
  if (radio.state != RadioState.idle) return;
  ref.read(journalProvider).add(JournalKind.app, 'Автоподключение: ${e.title}');
  await radio.connect(e.toTarget());
});

/// Установленная версия приложения (1.2.3).
final appVersionProvider = FutureProvider<String>(
  (ref) async => (await PackageInfo.fromPlatform()).version,
);

/// Автопроверка обновлений включена.
final updateAutoCheckProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(databaseProvider)
      .watchSetting(AppSettingKeys.updateAutoCheck)
      .map((v) => v != 'false'),
);

/// Последний релиз, если он новее установленного; null — обновлений нет.
/// Ошибки сети не показываем (проверка фоновая); ручная — через [checkForUpdate].
final latestReleaseProvider = FutureProvider<AppRelease?>((ref) async {
  final auto = await ref.watch(updateAutoCheckProvider.future);
  if (!auto) return null;
  try {
    return await checkForUpdate(await ref.watch(appVersionProvider.future));
  } catch (_) {
    return null;
  }
});

/// Свежий релиз новее установленного (ошибки — наружу).
Future<AppRelease?> checkForUpdate(String current) async {
  final r = await fetchLatestRelease();
  return r != null && isNewerVersion(r.version, current) ? r : null;
}

/// Обновление, о котором стоит напомнить (не отклонено пользователем).
final updateBadgeProvider = Provider<AppRelease?>((ref) {
  final r = ref.watch(latestReleaseProvider).value;
  final skip = ref.watch(_updateDismissedProvider).value;
  return r == null || r.version == skip ? null : r;
});

final _updateDismissedProvider = StreamProvider<String?>(
  (ref) =>
      ref.watch(databaseProvider).watchSetting(AppSettingKeys.updateDismissed),
);

// ── Настройки приложения: карта и позиция ──

Stream<String?> _setting(Ref ref, String key) =>
    ref.watch(databaseProvider).watchSetting(key);

Future<void> saveSetting(WidgetRef ref, String key, String value) =>
    ref.read(databaseProvider).setSetting(key, value);

/// Тема приложения; неизвестное значение — как в системе.
final themeModeProvider = StreamProvider<ThemeMode>(
  (ref) => _setting(ref, AppSettingKeys.theme).map(
    (v) =>
        ThemeMode.values.where((m) => m.name == v).firstOrNull ??
        ThemeMode.system,
  ),
);

/// Вращение карты жестом (по умолчанию выключено — север всегда сверху).
final mapRotateProvider = StreamProvider<bool>(
  (ref) => _setting(ref, AppSettingKeys.mapRotate).map((v) => v == 'true'),
);

/// Группировка близких нод на карте (по умолчанию включена).
final mapClusterProvider = StreamProvider<bool>(
  (ref) => _setting(ref, AppSettingKeys.mapCluster).map((v) => v != 'false'),
);

/// Подложка карты.
final mapStyleProvider = StreamProvider<MapStyle>(
  (ref) => _setting(ref, AppSettingKeys.mapStyle).map(MapStyle.parse),
);

/// Превью картинок в ленте (по умолчанию включено).
final showImagesProvider = StreamProvider<bool>(
  (ref) => _setting(ref, AppSettingKeys.showImages).map((v) => v != 'false'),
);

final areaEnabledProvider = StreamProvider<bool>(
  (ref) => _setting(ref, AppSettingKeys.areaEnabled).map((v) => v == 'true'),
);

const defaultAreaRadiusKm = 100.0;

final areaRadiusProvider = StreamProvider<double>(
  (ref) => _setting(
    ref,
    AppSettingKeys.areaRadiusKm,
  ).map((v) => double.tryParse(v ?? '') ?? defaultAreaRadiusKm),
);

final areaCenterProvider = StreamProvider<LatLon?>(
  (ref) => _setting(ref, AppSettingKeys.areaCenter).map(parseLatLon),
);

/// Область «скрывать дальние ноды»; null — выключено или центр не задан.
final nodeAreaProvider = Provider<NodeArea?>((ref) {
  if (ref.watch(areaEnabledProvider).value != true) return null;
  final c = ref.watch(areaCenterProvider).value;
  if (c == null) return null;
  return (
    center: c,
    km: ref.watch(areaRadiusProvider).value ?? defaultAreaRadiusKm,
  );
});

final positionShareProvider = StreamProvider<bool>(
  (ref) => _setting(ref, AppSettingKeys.positionShare).map((v) => v == 'true'),
);

final positionIntervalProvider = StreamProvider<int>(
  (ref) => _setting(
    ref,
    AppSettingKeys.positionIntervalMin,
  ).map((v) => int.tryParse(v ?? '') ?? defaultPositionIntervalMin),
);

/// Передача позиции телефона своей ноде; null — выключена или нет связи.
final positionServiceProvider = ChangeNotifierProvider<PositionService?>((ref) {
  final on = ref.watch(positionShareProvider).value == true;
  final ready = ref.watch(canSendProvider);
  final minutes =
      ref.watch(positionIntervalProvider).value ?? defaultPositionIntervalMin;
  if (!on || !ready) return null;
  final radio = ref.read(radioProvider);
  final service = PositionService(
    PositionSharer(
      ref.read(databaseProvider),
      radio.sendPacket,
      () => radio.state == RadioState.ready ? radio.myNodeNum : null,
      radio.queue.nextId,
    ),
    interval: Duration(minutes: minutes),
  )..start();
  return service;
});

/// Сводка своей ноды: ноды в эфире, онлайн, каналы, батарея, загрузка эфира.
final radioStatsProvider = Provider<RadioStats?>((ref) {
  final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
  if (me == null) return null;
  final nodes = ref.watch(nodesProvider).value ?? const <Node>[];
  final channels = ref.watch(channelsProvider).value ?? const <MeshChannel>[];
  return RadioStats.of(nodes, channels, me: me);
});
