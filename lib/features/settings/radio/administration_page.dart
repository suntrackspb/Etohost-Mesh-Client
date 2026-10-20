import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../data/settings/device_actions.dart';
import '../../../ui/kit/kit.dart';

/// «Администрирование» (AdministrationScreen, Android): перезагрузка,
/// выключение, сбросы. Подписи — iOS ru, иначе Android ru.
class AdministrationPage extends ConsumerStatefulWidget {
  const AdministrationPage({super.key});

  @override
  ConsumerState<AdministrationPage> createState() => _AdministrationPageState();
}

class _AdministrationPageState extends ConsumerState<AdministrationPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final canSend = ref.watch(canSendProvider);
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    final role = ref.watch(ownNodeProvider).value?.role ?? 0;
    final canShutdown =
        ref.watch(ownDeviceProvider).value?.metadata?.canShutdown ?? false;
    final enabled = canSend && me != null && !_busy;
    final danger = Theme.of(context).colorScheme.error;

    Widget tile(String title, IconData icon, VoidCallback onTap) => MeshTile(
      title: title,
      leading: Icon(icon, color: enabled ? danger : null),
      trailing: const SizedBox.shrink(),
      onTap: enabled ? onTap : null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Администрирование')),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          if (me == null) const WarningNote('Подключитесь к своей ноде'),
          SectionCard(
            children: [
              tile('Перезагрузка', Icons.restart_alt, _reboot),
              tile('Выключение', Icons.power_settings_new, () {
                if (!canShutdown) {
                  _snack('Выключение не поддерживается на этом устройстве');
                  return;
                }
                _shutdown();
              }),
              tile('Сброс NodeDB', Icons.storage, () => _nodeDb(role)),
              tile('Сброс настроек', Icons.restore, _factory),
            ],
          ),
          if (_busy) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _run(DeviceAction a, {bool preserveFavorites = true}) async {
    final me = ref.read(radioProvider).myNodeNum;
    if (me == null) return;
    setState(() => _busy = true);
    final ok = await DeviceActions.run(
      ref.read(adminSettingsProvider),
      ref.read(databaseProvider),
      me,
      a,
      preserveFavorites: preserveFavorites,
      role: ref.read(ownNodeProvider).value?.role ?? 0,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    _snack(ok ? 'Команда отправлена' : 'Нода не подтвердила');
  }

  Future<bool> _ask(String title, String? text, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(title),
          content: text == null ? null : Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: Text(action),
            ),
          ],
        ),
      ) ==
      true;

  Future<void> _reboot() async {
    if (await _ask('Вы уверены?', null, 'Перезагрузка')) {
      await _run(DeviceAction.reboot);
    }
  }

  Future<void> _shutdown() async {
    if (await _ask(
      'Выключить ноду?',
      '⚠️ Эта нода будет ВЫКЛЮЧЕНА. Для её включения потребуется '
          'физическое взаимодействие.',
      'Выключение',
    )) {
      await _run(DeviceAction.shutdown);
    }
  }

  Future<void> _nodeDb(int role) async {
    final forced = DeviceActions.keepsFavorites(role);
    var keep = true;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: const Text('Вы уверены?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Сохранить избранное?'),
                value: forced || keep,
                onChanged: forced ? null : (v) => set(() => keep = v ?? true),
              ),
              if (forced)
                const Text(
                  'При этой роли прошивка всегда сохраняет избранное.',
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Сброс NodeDB'),
            ),
          ],
        ),
      ),
    );
    if (yes == true) {
      await _run(DeviceAction.nodeDbReset, preserveFavorites: keep);
    }
  }

  Future<void> _factory() async {
    final a = await showDialog<DeviceAction>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Сброс настроек'),
        content: const Text(
          'Сброс к заводским настройкам удалит данные устройства и приложения.',
        ),
        actionsOverflowDirection: VerticalDirection.down,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, DeviceAction.factoryResetConfig),
            child: const Text('Удалить все настройки?'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, DeviceAction.factoryResetDevice),
            child: const Text('Удалить все настройки, ключи и BLE-соединения?'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
    if (a == null) return;
    await _run(a);
    // Полный сброс стирает ключи и BLE-пару — переподключаться бессмысленно,
    // как в iOS: отключаемся.
    if (a == DeviceAction.factoryResetDevice) {
      await ref.read(radioProvider).disconnect();
    }
  }
}
