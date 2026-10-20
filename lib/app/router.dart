import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/chat_page.dart';
import '../features/connection/connection_page.dart';
import '../features/journal/journal_page.dart';
import '../features/map/map_page.dart';
import '../features/nodes/node_detail_page.dart';
import '../features/nodes/nodes_page.dart';
import '../features/settings/app_settings_page.dart';
import '../features/settings/area_picker_page.dart';
import '../features/settings/mirror_settings_page.dart';
import '../features/settings/radio/user_config_page.dart';
import '../features/settings/settings_page.dart';
import 'shell.dart';

final appRouter = GoRouter(
  initialLocation: '/connection',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AdaptiveShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (_, _) => const ChatPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, s) => ChatPage(selected: s.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/nodes',
              builder: (_, _) => const NodesPage(),
              routes: [
                GoRoute(
                  path: ':num',
                  builder: (_, s) =>
                      NodesPage(selected: int.parse(s.pathParameters['num']!)),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/map', builder: (_, _) => const MapPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/connection',
              builder: (_, _) => const ConnectionPage(),
              routes: [
                GoRoute(
                  path: 'journal',
                  builder: (_, _) => const JournalPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, _) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'app',
                  builder: (_, _) => const AppSettingsPage(),
                  routes: [
                    GoRoute(
                      path: 'area',
                      builder: (_, _) => const AreaPickerPage(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'user',
                  builder: (_, _) => const UserConfigPage(),
                ),
                GoRoute(
                  path: 'mirror',
                  builder: (_, _) => const MirrorSettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Отдельный экран ноды для узкой раскладки (на широкой — правая колонка).
    GoRoute(
      path: '/node/:num',
      builder: (_, s) => NodeDetailPage(
        num: int.parse(s.pathParameters['num']!),
        standalone: true,
      ),
    ),
  ],
);

/// Вкладки приложения — одно описание для нижней панели и боковой.
class AppTab {
  const AppTab(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const appTabs = [
  AppTab('Чат', Icons.chat_bubble_outline, Icons.chat_bubble),
  AppTab('Ноды', Icons.hub_outlined, Icons.hub),
  AppTab('Карта', Icons.map_outlined, Icons.map),
  AppTab('Подключение', Icons.link, Icons.link),
  AppTab('Настройки', Icons.settings_outlined, Icons.settings),
];
