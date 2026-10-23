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
import '../features/settings/data_settings_page.dart';
import '../features/settings/app_settings_page.dart';
import '../features/settings/area_picker_page.dart';
import '../features/settings/mirror_settings_page.dart';
import '../features/settings/radio/administration_page.dart';
import '../features/settings/radio/backup_page.dart';
import '../features/settings/radio/channel_share_page.dart';
import '../features/settings/radio/channels_page.dart';
import '../features/settings/radio/config_section_page.dart';
import '../features/settings/radio/config_sections.dart';
import '../features/settings/radio/user_config_page.dart';
import '../features/settings/message_filter_page.dart';
import '../features/settings/settings_page.dart';
import '../ui/kit/kit.dart';
import 'shell.dart';

/// Корневой навигатор — для диалогов не из виджетов (вопрос при закрытии).
final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
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
                  split: true,
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
                  split: true,
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
                _route(
                  'channels',
                  (_) => const ChannelsPage(),
                  routes: [
                    _route('share', (_) => const ChannelSharePage()),
                    _route('import', (_) => const ChannelImportPage()),
                    _route(
                      ':index',
                      (s) => ChannelEditPage(
                        index: int.parse(s.pathParameters['index']!),
                        isNew: s.uri.queryParameters['new'] == '1',
                      ),
                    ),
                  ],
                ),
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
                _route(
                  'neighbor-info',
                  (_) => ConfigSectionPage(neighborInfoSpec),
                ),
                _route(
                  'ambient-lighting',
                  (_) => ConfigSectionPage(ambientLightingSpec),
                ),
                _route(
                  'detection-sensor',
                  (_) => ConfigSectionPage(detectionSensorSpec),
                ),
                _route('pax-counter', (_) => ConfigSectionPage(paxCounterSpec)),
                _route('tak', (_) => ConfigSectionPage(takSpec)),
                _route(
                  'traffic-management',
                  (_) => ConfigSectionPage(trafficManagementSpec),
                ),
                _route('mqtt', (_) => ConfigSectionPage(mqttSpec)),
                _route('display', (_) => ConfigSectionPage(displaySpec)),
                _route('admin', (_) => const AdministrationPage()),
                _route('backup', (_) => const BackupPage()),
                _route('data', (_) => const DataSettingsPage()),
                _route('mirror', (_) => const MirrorSettingsPage()),
                _route('message-filter', (_) => const MessageFilterPage()),
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
  bool split = false,
}) => GoRoute(
  path: path,
  // [split] — правая панель SplitView: на широком экране список остаётся
  // на месте, поэтому страница без анимации (иначе въезжает и моргает
  // весь экран вместе со списком).
  pageBuilder: (context, s) => split && SplitView.isWide(context)
      ? NoTransitionPage(key: s.pageKey, child: build(s))
      : MaterialPage(key: s.pageKey, child: build(s)),
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
  AppTab('Связь', Icons.link, Icons.link),
  AppTab('Настройки', Icons.settings_outlined, Icons.settings),
];
