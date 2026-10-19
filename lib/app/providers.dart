import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:universal_ble/universal_ble.dart';

import '../core/proto/channel_names.dart';
import '../core/proto/mesh.dart';
import '../core/radio/endpoint.dart';
import '../core/radio/journal.dart';
import '../core/radio/radio_session.dart';
import '../core/transport/serial_transport.dart';
import '../data/database.dart';
import '../data/mirror_ingest.dart';
import '../data/packet_router.dart';
import '../mirror/mirror_api.dart';
import '../mirror/mirror_config.dart';
import '../mirror/mirror_models.dart';
import '../mirror/mirror_realtime.dart';

/// База данных приложения. В тестах подменяется на in-memory.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final journalProvider = ChangeNotifierProvider<Journal>((ref) => Journal());

/// Соединение с нодой. Пакеты сразу уходят в БД через [PacketRouter].
final radioProvider = ChangeNotifierProvider<RadioSession>((ref) {
  final session = RadioSession(ref.read(journalProvider));
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

/// WS-подписка на зеркало; null, пока зеркало не включено.
final mirrorRealtimeProvider = ChangeNotifierProvider<MirrorRealtime?>((ref) {
  final cfg = ref.watch(mirrorConfigProvider).value ?? MirrorConfig.off;
  final ws = cfg.webSocketUrl, base = cfg.baseUrl;
  if (!cfg.active || ws == null || base == null) return null;

  final ingest = MirrorIngest(ref.read(databaseProvider));
  final journal = ref.read(journalProvider);
  void log(String s) => journal.add(JournalKind.app, s);

  final api = MirrorApi(base);
  api.nodes().then(ingest.nodes).catchError((Object e) {
    log('Зеркало: ноды не загружены: $e');
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
  ref.onDispose(() {
    rt.dispose();
    api.close();
  });
  return rt;
});

final nodesProvider = StreamProvider<List<Node>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchNodes(includeMirror: ref.watch(mirrorActiveProvider)),
);

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

final channelMessagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, key) => ref
      .watch(databaseProvider)
      .watchChannelMessages(
        key,
        includeMirror: ref.watch(mirrorActiveProvider),
      ),
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
