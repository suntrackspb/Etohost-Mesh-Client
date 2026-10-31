import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meshex_widgets/meshex_widgets.dart';

import '../../app/locale_provider.dart';
import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/radio/radio_session.dart';
import '../../core/radio/journal.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/node_actions.dart';
import '../map/map_tiles.dart';
import 'widget_map_renderer.dart';
import 'widget_snapshot.dart';

final _recentMessages = StreamProvider<List<Message>>((ref) {
  final db = ref.watch(databaseProvider);
  final mirror = ref.watch(mirrorActiveProvider);
  return (db.select(db.messages)
        ..where(
          (m) =>
              m.emoji.equals(0) &
              (mirror ? const Constant(true) : (m.heardOnRadio | m.isOutgoing)),
        )
        ..orderBy([(m) => OrderingTerm.desc(m.rxTime)])
        ..limit(40))
      .watch();
});
final _latestTrace = StreamProvider<TracerouteRecord?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.traceroutes)
        ..where((r) => r.answered)
        ..orderBy([(r) => OrderingTerm.desc(r.time)])
        ..limit(1))
      .watchSingleOrNull();
});

final _localStats = StreamProvider<LocalStats?>((ref) {
  final db = ref.watch(databaseProvider);
  final int me =
      ref.watch(radioProvider.select((r) => r.myNodeNum)) ??
      ref.watch(activeNodeDbProvider);
  return (db.select(db.telemetryLog)
        ..where((t) => t.nodeNum.equals(me) & t.kind.equals('localStats'))
        ..orderBy([(t) => OrderingTerm.desc(t.time)])
        ..limit(1))
      .watchSingleOrNull()
      .map(
        (row) => row == null ? null : Telemetry.fromBuffer(row.data).localStats,
      );
});

final _snapshotProvider = Provider<Map<String, Object?>>((ref) {
  final radio = ref.watch(radioProvider);
  final record = ref.watch(_latestTrace).value;
  final nodes = ref.watch(nodesProvider).value ?? <Node>[];
  final hidden = ref.watch(hiddenChannelsProvider).value ?? <String>{};
  final ignored = nodes.where((n) => n.isIgnored).map((n) => n.num).toSet();
  final filter = ref.watch(messageFilterProvider).value;
  final filterOff =
      ref.watch(messageFilterOffChatsProvider).value ?? <String>{};
  final messages = (ref.watch(_recentMessages).value ?? <Message>[])
      .where(
        (m) =>
            !ignored.contains(m.fromNum) &&
            !hidden.contains(m.channelKey) &&
            (m.isOutgoing ||
                filter?.hides(
                      m.body,
                      disabledHere: filterOff.contains(
                        m.toNum == 0xffffffff
                            ? m.channelKey
                            : DirectTarget(m.fromNum).id,
                      ),
                    ) !=
                    true),
      )
      .toList();
  return widgetSnapshot(
    nodes: nodes,
    messages: messages,
    points: ref.watch(mapPointsProvider),
    connected: radio.state == RadioState.ready,
    me: radio.myNodeNum,
    stats: ref.watch(radioStatsProvider),
    unread: ref.watch(totalUnreadProvider),
    language:
        ref.watch(appLocaleProvider).value?.languageCode ??
        ui.PlatformDispatcher.instance.locale.languageCode,
    now: DateTime.now(),
    localStats: ref.watch(_localStats).value,
    trace: record == null
        ? null
        : TracerouteResult.parse(
            record,
            radio.myNodeNum ?? ref.watch(activeNodeDbProvider),
          ),
  );
});

/// Debounced and serialized: a late render can never overwrite newer node data.
final homeWidgetsProvider = Provider<void>((ref) {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  Timer? debounce;
  var disposed = false, running = false, pending = false;
  String? mapKey, routeKey;
  DateTime? lastPublish;
  Future<void> publish() async {
    if (disposed) return;
    if (running) {
      pending = true;
      return;
    }
    running = true;
    try {
      do {
        pending = false;
        final data = ref.read(_snapshotProvider);
        lastPublish = DateTime.now();
        final kinds = await MeshexWidgets.activeKinds();
        if (disposed) break;
        final needsMap = kinds.any((k) => k == 'MapWidget' || k == 'MeshexMap');
        final needsRoute = kinds.any(
          (k) => k == 'RouteWidget' || k == 'MeshexRoute',
        );
        final points = ref.read(mapPointsProvider);
        final trace = ref.read(_latestTrace).value;
        final parsed = trace == null
            ? null
            : TracerouteResult.parse(
                trace,
                ref.read(radioProvider).myNodeNum ??
                    ref.read(activeNodeDbProvider),
              );
        final newMapKey = jsonEncode([
          ref.read(activeNodeDbProvider),
          for (final p in points) [p.num, p.lat, p.lon, p.label],
        ]);
        final newRouteKey = '$newMapKey:${trace?.id}';
        if (!identical(data, ref.read(_snapshotProvider))) {
          pending = true;
          continue;
        }
        // Clear mismatched images immediately, including when switching node databases.
        await MeshexWidgets.publish(
          encodeWidgetSnapshot(data),
          map: newMapKey != mapKey ? Uint8List(0) : null,
          route: newRouteKey != routeKey ? Uint8List(0) : null,
        );
        if ((needsMap && newMapKey != mapKey) ||
            (needsRoute && newRouteKey != routeKey)) {
          final tiles = await ref.read(tileProviderProvider.future);
          final map = !needsMap || newMapKey == mapKey
              ? null
              : await renderWidgetMap(points, tiles);
          final routePoints = parsed == null
              ? <int>{}
              : {
                  ...parsed.towards.map((h) => h.num),
                  ...parsed.back.map((h) => h.num),
                };
          final route = !needsRoute || newRouteKey == routeKey
              ? null
              : await renderWidgetMap(
                  points.where((p) => routePoints.contains(p.num)).toList(),
                  tiles,
                  route: parsed?.towards.map((h) => h.num).toList() ?? [],
                );
          if (!disposed && identical(data, ref.read(_snapshotProvider))) {
            await MeshexWidgets.publish(
              encodeWidgetSnapshot(data),
              map: map,
              route: route,
            );
            if (map != null) mapKey = newMapKey;
            if (route != null) routeKey = newRouteKey;
          }
        }
      } while (pending && !disposed);
    } on PlatformException {
      /* A missing App Group must not interrupt radio work. */
    } on MissingPluginException {
      /* Desktop/tests do not register the plugin. */
    } catch (error) {
      // Rendering/storage failure must never break the mesh connection.
      if (!disposed) {
        ref
            .read(journalProvider)
            .add(JournalKind.error, 'Widget update: ${error.runtimeType}');
      }
    } finally {
      running = false;
    }
  }

  void schedule() {
    if (debounce?.isActive == true) return;
    final elapsed = lastPublish == null
        ? 30
        : DateTime.now().difference(lastPublish!).inSeconds;
    debounce = Timer(
      Duration(seconds: elapsed >= 30 ? 2 : 30 - elapsed),
      publish,
    );
  }

  final lifecycle = AppLifecycleListener(onResume: schedule);
  ref.onDispose(lifecycle.dispose);
  ref.listen(_snapshotProvider, (_, _) => schedule(), fireImmediately: true);
  Future<void> route() async {
    final path = await MeshexWidgets.takeRoute();
    if (!disposed &&
        path != null &&
        RegExp(
          r'^/(connection|nodes|map|chat|traceroute)(/|$)',
        ).hasMatch(path)) {
      appRouter.go(path);
      schedule();
    }
  }

  if (Platform.isAndroid) {
    MeshexWidgets.channel.setMethodCallHandler((call) async {
      if (call.method == 'routeAvailable') await route();
    });
    Timer.run(route);
  }
  ref.onDispose(() {
    disposed = true;
    debounce?.cancel();
    if (Platform.isAndroid) MeshexWidgets.channel.setMethodCallHandler(null);
  });
});
