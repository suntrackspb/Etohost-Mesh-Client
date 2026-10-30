import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/toasts.dart';
import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../data/settings/device_actions.dart';
import '../../../ui/kit/kit.dart';
import '../../../app/link_badge.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(
        title: Text(context.l10n.administration_d838aa),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          if (me == null) WarningNote(context.l10n.connectToYourOwnNode_d2f276),
          SectionCard(
            children: [
              tile(context.l10n.reboot_a40813, Icons.restart_alt, _reboot),
              tile(context.l10n.shutdown_468972, Icons.power_settings_new, () {
                if (!canShutdown) {
                  _snack(context.l10n.shutdownNotSupportedOnThisDevice_04502f);
                  return;
                }
                _shutdown();
              }),
              tile(
                context.l10n.resetNodedb_58a887,
                Icons.storage,
                () => _nodeDb(role),
              ),
              tile(context.l10n.factoryReset_5dbd37, Icons.restore, _factory),
            ],
          ),
          const SizedBox(height: Tokens.s16),
          SectionCard(
            children: [
              MeshTile(
                title: context.l10n.repairNodeId_47d759,
                leading: Icon(Icons.healing, color: danger),
                onTap: me == null ? null : () => context.go('/settings/id-fix'),
              ),
            ],
          ),
          if (_busy) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  void _snack(String text) => toasts.show(text);

  Future<void> _run(DeviceAction a, {bool preserveFavorites = true}) async {
    final strings = context.l10n;
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
    _snack(
      ok ? strings.commandSent_d331b9 : strings.notAcknowledgedByTheNode_90929d,
    );
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
              child: Text(context.l10n.cancel_0ec753),
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
    final strings = context.l10n;
    if (await _ask(strings.areYouSure_b0069b, null, strings.reboot_a40813)) {
      await _run(DeviceAction.reboot);
    }
  }

  Future<void> _shutdown() async {
    final strings = context.l10n;
    if (await _ask(
      strings.shutDownNode_6cff20,
      strings.thisWillShutdownTheNodePhysical_dda266,
      strings.shutdown_468972,
    )) {
      await _run(DeviceAction.shutdown);
    }
  }

  Future<void> _nodeDb(int role) async {
    final strings = context.l10n;
    final forced = DeviceActions.keepsFavorites(role);
    var keep = true;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text(strings.areYouSure_b0069b),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.preserveFavorites_8bd086),
                value: forced || keep,
                onChanged: forced ? null : (v) => set(() => keep = v ?? true),
              ),
              if (forced)
                Text(strings.theFirmwareAlwaysPreservesFavoritesIn_0ef245),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(strings.cancel_0ec753),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: Text(strings.resetNodedb_58a887),
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
    final strings = context.l10n;
    final a = await showDialog<DeviceAction>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(strings.factoryReset_5dbd37),
        content: Text(strings.factoryResetWillDeleteDeviceAnd_cd2c63),
        actionsOverflowDirection: VerticalDirection.down,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, DeviceAction.factoryResetConfig),
            child: Text(strings.deleteAllConfig_8a83a4),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, DeviceAction.factoryResetDevice),
            child: Text(strings.deleteAllConfigKeysAndBle_cca1f1),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(strings.cancel_0ec753),
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
