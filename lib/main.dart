import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/desktop_tray_provider.dart';
import 'app/keep_alive_provider.dart';
import 'app/mqtt_providers.dart';
import 'app/notify_providers.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'core/desktop/linux_desktop_entry.dart';
import 'core/radio/journal.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  final journal = container.read(journalProvider);
  journal.add(JournalKind.app, 'Запуск приложения');

  // Ошибки Flutter и необработанные асинхронные — в журнал (и в отчёт).
  final flutterOnError = FlutterError.onError;
  FlutterError.onError = (d) {
    journal.add(JournalKind.error, '${d.exceptionAsString()}\n${d.stack}');
    flutterOnError?.call(d);
  };
  PlatformDispatcher.instance.onError = (e, st) {
    journal.add(JournalKind.error, '$e\n$st');
    return false;
  };

  installLinuxDesktopEntry().catchError(
    (Object e) => journal.add(JournalKind.error, 'Ярлык Linux: $e'),
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const MeshApp()),
  );
}

class MeshApp extends ConsumerStatefulWidget {
  const MeshApp({super.key});

  @override
  ConsumerState<MeshApp> createState() => _MeshAppState();
}

class _MeshAppState extends ConsumerState<MeshApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    ref.read(startupConnectProvider);
    // После сна сокет часто «жив» только на бумаге — переподключаемся сразу.
    final journal = ref.read(journalProvider);
    _lifecycle = AppLifecycleListener(
      onResume: () {
        journal.add(JournalKind.app, 'Приложение на экране');
        ref.read(mirrorRealtimeProvider)?.reconnectNow();
      },
      onPause: () {
        journal.add(JournalKind.app, 'Приложение свёрнуто');
        // Свёрнутое приложение iOS может выгрузить — сбросить журнал в файл.
        ref.read(journalFileProvider).flush();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Держит подписку на зеркало живой (listen не перестраивает приложение).
    ref.listen(mirrorRealtimeProvider, (_, _) {});
    ref.listen(positionServiceProvider, (_, _) {});
    ref.listen(mqttProxyProvider, (_, _) {});
    ref.listen(keepAliveProvider, (_, _) {});
    ref.listen(messageAlertsProvider, (_, _) {});
    ref.listen(desktopTrayProvider, (_, _) {});
    return MaterialApp.router(
      title: 'Etohost Mesh',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider).value ?? ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
