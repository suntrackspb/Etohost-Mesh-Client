import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  /// Канал Android для сообщений (подпись — Meshtastic-Android ru).
  static const _channel = AndroidNotificationDetails(
    'messages',
    'Уведомления о сообщениях',
    channelDescription: 'Личные сообщения, ответы, реакции и упоминания.',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.message,
  );

  static const _details = NotificationDetails(
    android: _channel,
    iOS: DarwinNotificationDetails(presentSound: true),
    macOS: DarwinNotificationDetails(presentSound: true),
    linux: LinuxNotificationDetails(
      category: LinuxNotificationCategory.imReceived,
    ),
  );

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
  }) async {
    await init();
    await _p.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details,
      payload: payload,
    );
  }
}
