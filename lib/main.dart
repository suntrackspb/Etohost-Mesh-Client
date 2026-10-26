import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'app/notice_providers.dart';
import 'app/toasts.dart';
import 'app/desktop_tray_provider.dart';
import 'app/keep_alive_provider.dart';
import 'app/mqtt_providers.dart';
import 'app/notify_providers.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'core/client_version.dart';
import 'core/desktop/desktop_tray.dart';
import 'core/desktop/linux_desktop_entry.dart';
import 'core/desktop/single_instance.dart';
import 'core/radio/journal.dart';
import 'data/appearance.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    clientVersion = (await PackageInfo.fromPlatform()).version;
  } catch (_) {}
  // Общая база и база ноды — один класс AppDatabase на разных файлах;
  // предупреждение drift про «несколько экземпляров» здесь ложное.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
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

  // Второй экземпляр на той же базе и ноде — «database is locked»:
  // показываем окно уже запущенного и выходим.
  if (DesktopTray.supported) {
    final dir = await getApplicationSupportDirectory();
    final instance = await SingleInstance.claim(
      dir,
      onActivate: () => container.read(desktopTrayProvider)?.bringToFront(),
    );
    if (instance == null) exit(0);
  }

  await prepareNodeDb(container);

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
    ref.read(noticesProvider.notifier).refresh();
    // После сна сокет часто «жив» только на бумаге — переподключаемся сразу.
    final journal = ref.read(journalProvider);
    _lifecycle = AppLifecycleListener(
      onResume: () {
        journal.add(JournalKind.app, 'Приложение на экране');
        ref.read(mirrorRealtimeProvider)?.reconnectNow();
        ref.read(noticesProvider.notifier).refresh();
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
    ref.listen(noticesOnConnectProvider, (_, _) {});
    ref.listen(messageAlertsProvider, (_, _) {});
    ref.listen(desktopTrayProvider, (_, _) {});
    ref.listen(orientationApplierProvider, (_, _) {});
    ref.listen(nodeFilterPersistProvider, (_, _) {});
    final theme = ref.watch(appThemeProvider).value ?? AppTheme.system;
    final accent = ref.watch(accentProvider).value ?? accents.first;
    return toastsHost(
      MaterialApp.router(
        title: 'Etohost Mesh',
        theme: buildTheme(Brightness.light, seed: accent.color),
        darkTheme: buildTheme(
          Brightness.dark,
          seed: accent.color,
          black: theme == AppTheme.black,
        ),
        themeMode: switch (theme) {
          AppTheme.system => ThemeMode.system,
          AppTheme.light => ThemeMode.light,
          AppTheme.dark || AppTheme.black => ThemeMode.dark,
        },
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
