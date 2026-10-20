import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../ui/kit/kit.dart';
import 'about_section.dart';

/// Заготовка: структура разделов как в официальном клиенте. Наполнение — этапы 3 и 6.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mirror = ref.watch(mirrorConfigProvider).value;
    Widget soon(String title, IconData icon) => MeshTile(
      title: title,
      leading: Icon(icon),
      trailing: const Text('скоро'),
    );
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
              soon('Каналы', Icons.swap_horiz),
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
            ],
          ),
          const AboutSection(),
        ],
      ),
    );
  }
}
