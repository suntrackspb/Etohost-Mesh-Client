import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notify/local_notifier.dart';
import '../core/radio/journal.dart';
import '../data/database.dart';
import '../data/notify/alert_watcher.dart';
import '../data/notify/message_alerts.dart';
import '../data/notify/open_chats.dart';
import '../features/chat/chat_page.dart';
import 'desktop_tray_provider.dart';
import 'providers.dart';
import 'router.dart';

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

final localNotifierProvider = Provider<LocalNotifier>((ref) => LocalNotifier());

/// Уведомления о сообщениях. Держится живым из корня приложения.
final messageAlertsProvider = Provider<AlertWatcher>((ref) {
  final db = ref.read(databaseProvider);
  final notifier = ref.read(localNotifierProvider);
  final open = ref.read(openChatsProvider);
  final journal = ref.read(journalProvider);
  var settings = const AlertSettings();
  ref.listen(
    alertSettingsProvider,
    (_, s) => settings = s.value ?? settings,
    fireImmediately: true,
  );

  final watcher = AlertWatcher(
    db,
    me: () => ref.read(radioProvider).myNodeNum,
    settings: () => settings,
    isChatVisible: (chat) =>
        open.isOpen(chat) &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
    onAlert: (a) => notifier
        .show(a.id, a.title, a.body, payload: a.chat)
        .catchError(
          (Object e) => journal.add(JournalKind.app, 'Уведомление: $e'),
        ),
  );

  final taps = notifier.taps.listen((chat) {
    appRouter.go(ChatPage.location(chat));
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
  }().catchError(
    (Object e) => journal.add(JournalKind.app, 'Уведомления не запущены: $e'),
  );

  ref.onDispose(() {
    taps.cancel();
    watcher.dispose();
  });
  return watcher;
});
