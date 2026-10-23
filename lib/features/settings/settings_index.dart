import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/settings_search.dart';
import '../../ui/kit/kit.dart';
import 'radio/config_section_page.dart';
import 'radio/config_sections.dart';

/// Разделы экрана «Настройки» (подписи — как на нём) и пути.
const _pages = [
  ('Приложение', 'app'),
  ('Данные', 'data'),
  ('Зеркало', 'mirror'),
  ('Фильтр сообщений', 'message-filter'),
  ('LoRa', 'lora'),
  ('Каналы', 'channels'),
  ('Безопасность', 'security'),
  ('Пользователь', 'user'),
  ('Bluetooth', 'bluetooth'),
  ('Устройство', 'device'),
  ('Позиция', 'position'),
  ('Питание', 'power'),
  ('Сеть', 'network'),
  ('Экран', 'display'),
  ('MQTT', 'mqtt'),
  ('Последовательный порт', 'serial'),
  ('Внешние уведомления', 'external-notification'),
  ('Сохранить и переслать', 'store-forward'),
  ('Тест дальности', 'range-test'),
  ('Телеметрия', 'telemetry'),
  ('Сохраненные сообщения', 'canned-messages'),
  ('Звук', 'audio'),
  ('Удаленное оборудование', 'remote-hardware'),
  ('Информация о соседях', 'neighbor-info'),
  ('Окружающее освещение', 'ambient-lighting'),
  ('Датчик обнаружения', 'detection-sensor'),
  ('Счетчик прохожих', 'pax-counter'),
  ('TAK', 'tak'),
  ('Управление движением', 'traffic-management'),
  ('Администрирование', 'admin'),
  ('Резервная копия и восстановление', 'backup'),
  ('Отправить отчёт разработчику', 'report'),
];

final _specs = <(String, ConfigSectionSpec<Object?>)>[
  ('lora', loraSpec),
  ('device', deviceSpec),
  ('position', positionSpec),
  ('power', powerSpec),
  ('network', networkSpec),
  ('bluetooth', bluetoothSpec),
  ('security', securitySpec),
  ('serial', serialSpec),
  ('external-notification', externalNotificationSpec),
  ('store-forward', storeForwardSpec),
  ('range-test', rangeTestSpec),
  ('telemetry', telemetrySpec),
  ('canned-messages', cannedMessageSpec),
  ('audio', audioSpec),
  ('remote-hardware', remoteHardwareSpec),
  ('neighbor-info', neighborInfoSpec),
  ('ambient-lighting', ambientLightingSpec),
  ('detection-sensor', detectionSensorSpec),
  ('pax-counter', paxCounterSpec),
  ('tak', takSpec),
  ('traffic-management', trafficManagementSpec),
  ('mqtt', mqttSpec),
  ('display', displaySpec),
];

/// Самая «полная» нода: показываем все поля, какие бывают.
const OwnDevice _anyDevice = (
  firmware: '99.0.0',
  hwModel: 0,
  role: 0,
  hasWifi: true,
  hasEthernet: true,
  xeddsa: true,
  primaryPublic: false,
);

/// Поля экрана «Приложение» — он собран вручную, не из ConfigSectionSpec.
const _appFields = [
  ('Тема', 'Оформление', 'Система, светлая, тёмная или чёрная (OLED)'),
  ('Цвет акцента', 'Оформление', null),
  ('Обращения ко мне', 'Оформление', 'Цвет упоминаний и ответов на ваше'),
  ('Ориентация экрана', null, 'Авто, книжная, альбомная, перевёрнутые'),
  ('Кэш карты', 'Карта', 'Просмотренные тайлы без сети, очистка'),
];

List<SettingsEntry>? _cache;

/// Все разделы и поля настроек для поиска.
List<SettingsEntry> settingsIndex() => _cache ??= [
  for (final (title, route) in _pages)
    SettingsEntry(title: title, route: route),
  for (final (title, group, help) in _appFields)
    SettingsEntry(
      title: title,
      route: 'app',
      section: group == null ? 'Приложение' : 'Приложение › $group',
      help: help,
    ),
  for (final (route, spec) in _specs)
    for (final f in spec.fields(_anyDevice))
      SettingsEntry(
        title: f.label,
        route: route,
        section: f.group == null ? spec.title : '${spec.title} › ${f.group}',
        help: f.help,
      ),
];

/// Результаты поиска по настройкам.
class SettingsSearchResults extends StatelessWidget {
  const SettingsSearchResults(this.query, {super.key});
  final String query;

  @override
  Widget build(BuildContext context) {
    final found = searchSettings(settingsIndex(), query);
    if (found.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(Tokens.s16),
        child: Center(child: Text('Ничего не найдено')),
      );
    }
    return SectionCard(
      children: [
        for (final e in found)
          MeshTile(
            title: e.title,
            subtitle: e.section,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/${e.route}'),
          ),
      ],
    );
  }
}
