import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../radio/radio_session.dart';

/// Текст постоянного уведомления; null — служба не нужна.
typedef KeepAliveStatus = ({String title, String text});

/// Пока есть соединение с нодой (или идёт переподключение), держим процесс
/// живым: на Android без foreground service система рвёт BLE в фоне.
/// Подписи — Meshtastic-Android ru.
KeepAliveStatus? keepAliveStatus(
  RadioState state,
  String? target, {
  String? mqtt,
}) {
  final text = switch (state) {
    RadioState.idle => null,
    RadioState.ready => 'Подключено',
    RadioState.waitingReconnect => 'Отключено',
    _ => 'Подключение',
  };
  if (text == null) return null;
  final name = target == null || target.isEmpty ? '' : ': $target';
  return (
    title: 'Etohost Mesh$name',
    text: mqtt == null ? text : '$text · MQTT: $mqtt',
  );
}

/// Служба удержания связи. На всех платформах, кроме Android, ничего не делает
/// (iOS держит BLE фоновым режимом bluetooth-central).
abstract interface class KeepAlive {
  Future<void> update(KeepAliveStatus? status);

  factory KeepAlive.platform() =>
      Platform.isAndroid ? AndroidKeepAlive() : const _NoKeepAlive();
}

class _NoKeepAlive implements KeepAlive {
  const _NoKeepAlive();
  @override
  Future<void> update(KeepAliveStatus? status) async {}
}

@pragma('vm:entry-point')
void _keepAliveCallback() => FlutterForegroundTask.setTaskHandler(_Idle());

/// Обработчик в фоновом изоляте ничего не делает: соединение живёт в главном
/// изоляте, служба только не даёт системе усыпить процесс.
class _Idle extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}
  @override
  void onRepeatEvent(DateTime timestamp) {}
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

class AndroidKeepAlive implements KeepAlive {
  bool _init = false;
  bool _asked = false;
  KeepAliveStatus? _last;

  /// Вызовы приходят на каждое изменение состояния — выполняем по очереди.
  Future<void> _chain = Future.value();

  @override
  Future<void> update(KeepAliveStatus? status) {
    if (status == _last) return _chain;
    _last = status;
    return _chain = _chain.then((_) => _apply(status)).catchError((_) {});
  }

  Future<void> _apply(KeepAliveStatus? s) async {
    final running = await FlutterForegroundTask.isRunningService;
    if (s == null) {
      if (running) await FlutterForegroundTask.stopService();
      return;
    }
    if (running) {
      await FlutterForegroundTask.updateService(
        notificationTitle: s.title,
        notificationText: s.text,
      );
      return;
    }
    if (!_init) {
      _init = true;
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'connection',
          channelName: 'Служебные уведомления',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );
    }
    // Android 13+: без разрешения служба работает, но уведомление скрыто.
    if (!_asked) {
      _asked = true;
      final p = await FlutterForegroundTask.checkNotificationPermission();
      if (p == NotificationPermission.denied) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    }
    await FlutterForegroundTask.startService(
      serviceId: 1001,
      serviceTypes: [ForegroundServiceTypes.connectedDevice],
      notificationTitle: s.title,
      notificationText: s.text,
      callback: _keepAliveCallback,
    );
  }
}
