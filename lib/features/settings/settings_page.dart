import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../ui/kit/kit.dart';
import 'about_section.dart';
import 'hardware_ids_dialog.dart';

/// Заготовка: структура разделов как в официальном клиенте. Наполнение — этапы 3 и 6.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mirror = ref.watch(mirrorConfigProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          const UpdateBanner(),
          SectionCard(
            children: [
              MeshTile(
                title: 'Приложение',
                leading: const Icon(Icons.tune),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/app'),
              ),
              MeshTile(
                title: 'Зеркало',
                leading: const Icon(Icons.public),
                trailing: Text(
                  mirror?.enabled == true
                      ? (mirror!.baseUrl?.host ?? '')
                      : 'выкл.',
                ),
                onTap: () => context.go('/settings/mirror'),
              ),
            ],
          ),
          SectionCard(
            title: 'Настройка радио',
            children: [
              MeshTile(
                title: 'LoRa',
                leading: const Icon(Icons.cell_tower),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/lora'),
              ),
              MeshTile(
                title: 'Каналы',
                leading: const Icon(Icons.swap_horiz),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/channels'),
              ),
              MeshTile(
                title: 'Безопасность',
                leading: const Icon(Icons.shield_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/security'),
              ),
            ],
          ),
          SectionCard(
            title: 'Конфигурация устройства',
            children: [
              MeshTile(
                title: 'Пользователь',
                leading: const Icon(Icons.person_outline),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/user'),
              ),
              MeshTile(
                title: 'Bluetooth',
                leading: const Icon(Icons.bluetooth),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/bluetooth'),
              ),
              MeshTile(
                title: 'Устройство',
                leading: const Icon(Icons.memory),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/device'),
              ),
              MeshTile(
                title: 'Позиция',
                leading: const Icon(Icons.location_on_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/position'),
              ),
              MeshTile(
                title: 'Питание',
                leading: const Icon(Icons.battery_charging_full),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/power'),
              ),
              MeshTile(
                title: 'Сеть',
                leading: const Icon(Icons.wifi),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/network'),
              ),
              MeshTile(
                title: 'Экран',
                leading: const Icon(Icons.screenshot_monitor),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/display'),
              ),
            ],
          ),
          SectionCard(
            title: 'Конфигурация модуля',
            children: [
              MeshTile(
                title: 'MQTT',
                leading: const Icon(Icons.dns_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/mqtt'),
              ),
              MeshTile(
                title: 'Последовательный порт',
                leading: const Icon(Icons.cable),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/serial'),
              ),
              MeshTile(
                title: 'Внешние уведомления',
                leading: const Icon(Icons.notifications_active_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/external-notification'),
              ),
              MeshTile(
                title: 'Сохранить и переслать',
                leading: const Icon(Icons.move_to_inbox_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/store-forward'),
              ),
              MeshTile(
                title: 'Тест дальности',
                leading: const Icon(Icons.social_distance_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/range-test'),
              ),
              MeshTile(
                title: 'Телеметрия',
                leading: const Icon(Icons.query_stats),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/telemetry'),
              ),
              MeshTile(
                title: 'Сохраненные сообщения',
                leading: const Icon(Icons.quickreply_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/canned-messages'),
              ),
              MeshTile(
                title: 'Звук',
                leading: const Icon(Icons.graphic_eq),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/audio'),
              ),
              MeshTile(
                title: 'Удаленное оборудование',
                leading: const Icon(Icons.settings_input_component_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/remote-hardware'),
              ),
              MeshTile(
                title: 'Информация о соседях',
                leading: const Icon(Icons.hub_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/neighbor-info'),
              ),
              MeshTile(
                title: 'Окружающее освещение',
                leading: const Icon(Icons.lightbulb_outline),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/ambient-lighting'),
              ),
              MeshTile(
                title: 'Датчик обнаружения',
                leading: const Icon(Icons.sensors),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/detection-sensor'),
              ),
              MeshTile(
                title: 'Счетчик прохожих',
                leading: const Icon(Icons.directions_walk),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/pax-counter'),
              ),
              MeshTile(
                title: 'TAK',
                leading: const Icon(Icons.military_tech_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/tak'),
              ),
              MeshTile(
                title: 'Управление движением',
                leading: const Icon(Icons.traffic_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/traffic-management'),
              ),
            ],
          ),
          SectionCard(
            children: [
              MeshTile(
                title: 'Администрирование',
                leading: const Icon(Icons.admin_panel_settings_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/admin'),
              ),
            ],
          ),
          SectionCard(
            title: 'Поддержка',
            children: [
              MeshTile(
                title: 'Отправить отчёт разработчику',
                subtitle: 'Журнал и сведения о приложении и ноде',
                leading: const Icon(Icons.bug_report_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/report'),
              ),
              MeshTile(
                title: 'Аппаратные id ноды',
                subtitle: 'MAC и device_id подключённой ноды',
                leading: const Icon(Icons.memory),
                onTap: () => showHardwareIds(context),
              ),
            ],
          ),
          const AboutSection(),
        ],
      ),
    );
  }
}
