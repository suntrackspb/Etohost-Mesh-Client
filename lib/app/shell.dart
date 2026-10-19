import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/radio/radio_session.dart';
import '../ui/kit/kit.dart';
import 'providers.dart';
import 'router.dart';

/// Телефон — нижние вкладки; планшет/десктоп — боковая панель.
class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int i) =>
      shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= Tokens.wideBreakpoint;
    final radio = ref.watch(radioProvider);
    final unread = ref.watch(totalUnreadProvider);
    // Бейдж непрочитанного — на вкладке «Чат» (первая).
    Widget icon(int i, IconData data) => i == 0 && unread > 0
        ? Badge(label: Text(unread > 99 ? '99+' : '$unread'), child: Icon(data))
        : Icon(data);

    if (!wide) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final (i, t) in appTabs.indexed)
              NavigationDestination(
                icon: icon(i, t.icon),
                selectedIcon: icon(i, t.selectedIcon),
                label: t.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _go,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: Tokens.s16),
              child: Tooltip(
                message: radioStateLabel(radio.state),
                child: Icon(
                  Icons.circle,
                  size: 12,
                  color: radioStateColor(radio.state),
                ),
              ),
            ),
            destinations: [
              for (final (i, t) in appTabs.indexed)
                NavigationRailDestination(
                  icon: icon(i, t.icon),
                  selectedIcon: icon(i, t.selectedIcon),
                  label: Text(t.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: shell),
        ],
      ),
    );
  }
}

String radioStateLabel(RadioState s) => switch (s) {
  RadioState.ready => 'на связи',
  RadioState.configuring => 'получение конфигурации',
  RadioState.loadingNodes => 'загрузка нод',
  RadioState.connecting => 'подключение',
  RadioState.waitingReconnect => 'ожидание переподключения',
  RadioState.idle => 'не подключено',
};

Color radioStateColor(RadioState s) => switch (s) {
  RadioState.ready => StatusColors.ok,
  RadioState.configuring ||
  RadioState.loadingNodes ||
  RadioState.connecting => StatusColors.warn,
  RadioState.waitingReconnect => StatusColors.bad,
  RadioState.idle => StatusColors.idle,
};
