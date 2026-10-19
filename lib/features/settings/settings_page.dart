import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';

import '../../ui/kit/kit.dart';

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
          SectionCard(
            children: [
              soon('Приложение', Icons.tune),
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
              soon('LoRa', Icons.cell_tower),
              soon('Каналы', Icons.swap_horiz),
              soon('Безопасность', Icons.shield_outlined),
            ],
          ),
          SectionCard(
            title: 'Конфигурация устройства',
            children: [
              soon('Пользователь', Icons.person_outline),
              soon('Устройство', Icons.memory),
            ],
          ),
        ],
      ),
    );
  }
}
