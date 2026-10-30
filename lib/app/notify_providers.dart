import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notify/local_notifier.dart';
import '../core/radio/journal.dart';
import '../data/message_filter.dart';
import '../data/database.dart';
import '../data/notify/alert_watcher.dart';
import '../data/notify/message_alerts.dart';
import '../data/notify/open_chats.dart';
import '../data/notify/trace_alerts.dart';
import '../features/nodes/traceroute_ui.dart';
import '../features/chat/chat_page.dart';
import 'desktop_tray_provider.dart';
import 'providers.dart';
import 'router.dart';
import 'locale_provider.dart';
import '../l10n/l10n.dart';

final openChatsProvider = Provider<OpenChats>((ref) => OpenChats());

/// Включённые типы уведомлений (по умолчанию все).
final alertSettingsProvider = StreamProvider<AlertSettings>(
  (ref) => ref.watch(databaseProvider).watchSettings().map((s) {
    bool on(String k) => s[k] != 'false';
    return AlertSettings(
      direct: on(AppSettingKeys.notifyDirect),
      reaction: on(AppSettingKeys.notifyReaction),
      reply: on(AppSettingKeys.notifyReply),
      mention: on(AppSettingKeys.notifyMention),
    );
  }),
);

/// Уведомлять о пришедших трассировках (по умолчанию да).
final notifyTracerouteProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(databaseProvider)
      .watchSettings()
      .map((s) => s[AppSettingKeys.notifyTraceroute] != 'false'),
);

final localNotifierProvider = Provider<LocalNotifier>((ref) {
  final notifier = LocalNotifier(
    translate: (text) =>
        localizeBuiltInText(ref.read(appStringsProvider), text),
  );
  ref.listen(appStringsProvider, (_, _) {
    notifier.refreshChannelLabels().catchError((Object _) {});
  });
  return notifier;
});

/// Уведомления о сообщениях. Держится живым из корня приложения.
final messageAlertsProvider = Provider<AlertWatcher>((ref) {
  final db = ref.watch(databaseProvider);
  final notifier = ref.read(localNotifierProvider);
  final open = ref.read(openChatsProvider);
  final journal = ref.read(journalProvider);
  var settings = const AlertSettings();
  MessageFilter? filter;
  var filterOff = const <String>{};
  ref.listen(
    messageFilterProvider,
    (_, f) => filter = f.value ?? filter,
    fireImmediately: true,
  );
  ref.listen(
    messageFilterOffChatsProvider,
    (_, s) => filterOff = s.value ?? filterOff,
    fireImmediately: true,
  );
  ref.listen(
    alertSettingsProvider,
    (_, s) => settings = s.value ?? settings,
    fireImmediately: true,
  );

  final watcher = AlertWatcher(
    db,
    replyTitle: (where) =>
        ref.read(appStringsProvider).notificationReplyTitle(where),
    reactionBody: (reaction, target) =>
        ref.read(appStringsProvider).notificationReactionBody(reaction, target),
    me: () => ref.read(radioProvider).myNodeNum,
    settings: () => settings,
    isChatVisible: (chat) =>
        open.isOpen(chat) &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
    isFiltered: (chat, text) =>
        filter?.hides(text, disabledHere: filterOff.contains(chat)) ?? false,
    onAlert: (a) => notifier
        .show(
          a.id,
          a.title,
          a.body,
          payload: a.chat,
          channel: notifyChannelFor(a.kind),
        )
        .catchError(
          (Object e) => journal.add(JournalKind.app, 'Уведомление: $e'),
        ),
  );

  var traceOn = true;
  ref.listen(
    notifyTracerouteProvider,
    (_, v) => traceOn = v.value ?? traceOn,
    fireImmediately: true,
  );
  final traces = TraceAlertWatcher(
    db,
    formatTitle: (name) =>
        ref.read(appStringsProvider).notificationTraceTitle(name),
    formatBody: (text) =>
        localizeBuiltInText(ref.read(appStringsProvider), text),
    me: () => ref.read(radioProvider).myNodeNum,
    enabled: () => traceOn,
    // id не пересекаются с сообщениями (там id строки messages).
    onAlert: (a) => notifier
        .show(
          0x40000000 + a.id,
          a.title,
          a.body,
          payload: tracePayload(a.id),
          channel: NotifyChannel.traceroutes,
        )
        .catchError(
          (Object e) => journal.add(JournalKind.app, 'Уведомление: $e'),
        ),
  );

  final taps = notifier.taps.listen((p) {
    final trace = traceIdFromPayload(p);
    if (trace != null) {
      appRouter.push(TraceroutePage.location(trace));
    } else {
      appRouter.go(ChatPage.location(p));
    }
    // Десктоп: окно могло быть в трее или свёрнуто.
    ref.read(desktopTrayProvider)?.bringToFront();
  });
  () async {
    await notifier.init();
    // Разрешение спрашиваем один раз, при первом запуске.
    if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
      if (await db.getSetting(AppSettingKeys.notifyAsked) != 'true') {
        await db.setSetting(AppSettingKeys.notifyAsked, 'true');
        await notifier.requestPermission();
      }
    }
    await watcher.start();
    await traces.start();
  }().catchError(
    (Object e) => journal.add(JournalKind.app, 'Уведомления не запущены: $e'),
  );

  ref.onDispose(() {
    taps.cancel();
    watcher.dispose();
    traces.dispose();
  });
  return watcher;
});
