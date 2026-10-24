import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notify_channels.dart';

export 'notify_channels.dart';

/// Локальные уведомления (без push-сервера и сертификатов): показываются,
/// пока приложение живо — на экране, в фоне (iOS — bluetooth-central,
/// Android — foreground service) или свёрнуто на десктопе.
class LocalNotifier {
  LocalNotifier({FlutterLocalNotificationsPlugin? plugin})
    : _p = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _p;
  final _taps = StreamController<String>.broadcast();
  bool _ready = false;

  /// Нажатие на уведомление: payload (id чата).
  Stream<String> get taps => _taps.stream;

  NotificationDetails _details(NotifyChannel c) => NotificationDetails(
    android: AndroidNotificationDetails(
      c.id,
      c.name,
      channelDescription: c.description,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
    ),
    iOS: const DarwinNotificationDetails(presentSound: true),
    macOS: const DarwinNotificationDetails(presentSound: true),
    linux: const LinuxNotificationDetails(
      category: LinuxNotificationCategory.imReceived,
    ),
  );

  /// Каналы и группы Android заранее — чтобы в системных настройках
  /// приложения они были сразу и по группам; старый общий канал убираем.
  Future<void> _androidChannels() async {
    final a = _p
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (a == null) return;
    for (final g in NotifyGroup.values) {
      await a.createNotificationChannelGroup(
        AndroidNotificationChannelGroup(g.id, g.name),
      );
    }
    for (final c in NotifyChannel.values) {
      await a.createNotificationChannel(
        AndroidNotificationChannel(
          c.id,
          c.name,
          description: c.description,
          groupId: c.group.id,
          importance: Importance.high,
        ),
      );
    }
    await a.deleteNotificationChannel(channelId: NotifyChannel.legacyId);
  }

  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    const darwin = DarwinInitializationSettings(
      // Разрешение просим отдельно, когда включают уведомления.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _p.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
        linux: LinuxInitializationSettings(defaultActionName: 'Открыть'),
        windows: WindowsInitializationSettings(
          appName: 'Etohost Mesh',
          appUserModelId: 'ru.etohost.mesh',
          guid: '6c1c2f4e-3b8a-4f0e-9a51-2d7e5b8c4a10',
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null && p.isNotEmpty) _taps.add(p);
      },
    );
    // Приложение запустили нажатием на уведомление. На Linux плагин
    // этого не умеет (UnimplementedError) — и без проверки init падал,
    // а с ним и все уведомления.
    if (Platform.isAndroid) await _androidChannels();
    if (Platform.isLinux) return;
    final launch = await _p.getNotificationAppLaunchDetails();
    final p = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) && p != null) {
      scheduleMicrotask(() => _taps.add(p));
    }
  }

  /// Спросить разрешение (iOS, macOS, Android 13+). true — можно показывать.
  Future<bool> requestPermission() async {
    await init();
    if (Platform.isIOS) {
      return await _p
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, sound: true) ??
          false;
    }
    if (Platform.isMacOS) {
      return await _p
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, sound: true) ??
          false;
    }
    if (Platform.isAndroid) {
      return await _p
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    return true;
  }

  Future<void> show(
    int id,
    String title,
    String body, {
    String? payload,
    NotifyChannel channel = NotifyChannel.direct,
  }) async {
    await init();
    await _p.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(channel),
      payload: payload,
    );
  }
}
