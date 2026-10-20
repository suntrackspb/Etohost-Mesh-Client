import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/chat_page.dart';
import '../features/connection/connection_page.dart';
import '../features/journal/journal_page.dart';
import '../features/report/report_page.dart';
import '../features/map/map_page.dart';
import '../features/nodes/node_detail_page.dart';
import '../features/nodes/nodes_page.dart';
import '../features/settings/app_settings_page.dart';
import '../features/settings/area_picker_page.dart';
import '../features/settings/mirror_settings_page.dart';
import '../features/settings/radio/config_section_page.dart';
import '../features/settings/radio/config_sections.dart';
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
            _route(
              '/chat',
              (_) => const ChatPage(),
              routes: [
                _route(
                  ':id',
                  (s) => ChatPage(selected: s.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _route(
              '/nodes',
              (_) => const NodesPage(),
              routes: [
                _route(
                  ':num',
                  (s) =>
                      NodesPage(selected: int.parse(s.pathParameters['num']!)),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(routes: [_route('/map', (_) => const MapPage())]),
        StatefulShellBranch(
          routes: [
            _route(
              '/connection',
              (_) => const ConnectionPage(),
              routes: [_route('journal', (_) => const JournalPage())],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _route(
              '/settings',
              (_) => const SettingsPage(),
              routes: [
                _route(
                  'app',
                  (_) => const AppSettingsPage(),
                  routes: [
                    // На экране — карта: её панорамирование важнее свайпа,
                    // «назад» только от края.
                    GoRoute(
                      path: 'area',
                      pageBuilder: (_, s) => CupertinoPage(
                        key: s.pageKey,
                        child: const AreaPickerPage(),
                      ),
                    ),
                  ],
                ),
                _route('user', (_) => const UserConfigPage()),
                _route('lora', (_) => ConfigSectionPage(loraSpec)),
                _route('device', (_) => ConfigSectionPage(deviceSpec)),
                _route('position', (_) => ConfigSectionPage(positionSpec)),
                _route('power', (_) => ConfigSectionPage(powerSpec)),
                _route('network', (_) => ConfigSectionPage(networkSpec)),
                _route('bluetooth', (_) => ConfigSectionPage(bluetoothSpec)),
                _route('security', (_) => ConfigSectionPage(securitySpec)),
                _route('serial', (_) => ConfigSectionPage(serialSpec)),
                _route(
                  'external-notification',
                  (_) => ConfigSectionPage(externalNotificationSpec),
                ),
                _route(
                  'store-forward',
                  (_) => ConfigSectionPage(storeForwardSpec),
                ),
                _route('range-test', (_) => ConfigSectionPage(rangeTestSpec)),
                _route('telemetry', (_) => ConfigSectionPage(telemetrySpec)),
                _route(
                  'canned-messages',
                  (_) => ConfigSectionPage(cannedMessageSpec),
                ),
                _route('audio', (_) => ConfigSectionPage(audioSpec)),
                _route(
                  'remote-hardware',
                  (_) => ConfigSectionPage(remoteHardwareSpec),
                ),
                _route('mqtt', (_) => ConfigSectionPage(mqttSpec)),
                _route('display', (_) => ConfigSectionPage(displaySpec)),
                _route('mirror', (_) => const MirrorSettingsPage()),
                _route('report', (_) => const ReportPage()),
              ],
            ),
          ],
        ),
      ],
    ),
    // Отдельный экран ноды для узкой раскладки (на широкой — правая колонка).
    _route(
      '/node/:num',
      (s) => NodeDetailPage(
        num: int.parse(s.pathParameters['num']!),
        standalone: true,
      ),
    ),
  ],
);

/// Маршрут с явной MaterialPage: go_router 18.1 иначе может выбрать
/// страницу без перехода платформы, и свайп «назад» на iOS не работает.
GoRoute _route(
  String path,
  Widget Function(GoRouterState s) build, {
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  pageBuilder: (_, s) => MaterialPage(key: s.pageKey, child: build(s)),
  routes: routes,
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
