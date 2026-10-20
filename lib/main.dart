import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'ui/theme.dart';

void main() => runApp(const ProviderScope(child: MeshApp()));

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
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(mirrorRealtimeProvider)?.reconnectNow(),
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
    return MaterialApp.router(
      title: 'Etohost Mesh',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
