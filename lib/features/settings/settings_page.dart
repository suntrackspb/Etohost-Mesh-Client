import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/diagnostics_providers.dart';
import '../../app/providers.dart';
import '../../ui/kit/kit.dart';
import '../../ui/meshex_wordmark.dart';
import 'about_section.dart';
import 'hardware_ids_dialog.dart';
import 'settings_index.dart';
import '../../app/link_badge.dart';

/// Заготовка: структура разделов как в официальном клиенте. Наполнение — этапы 3 и 6.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim();
    final mirror = ref.watch(mirrorConfigProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.configuration_7f17c7),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.s16),
            child: SearchBar(
              controller: _search,
              hintText: context.l10n.searchSettings_69a03f,
              leading: const Icon(Icons.search),
              trailing: [
                if (query.isNotEmpty)
                  IconButton(
                    tooltip: context.l10n.clear_98b207,
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(_search.clear),
                  ),
              ],
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (query.isNotEmpty)
            SettingsSearchResults(query)
          else ...[
            const Padding(
              padding: EdgeInsets.only(top: Tokens.s8, bottom: Tokens.s24),
              child: Center(child: MeshexWordmark()),
            ),
            const UpdateBanner(),
            SectionCard(
              children: [
                MeshTile(
                  title: context.l10n.app_f9886c,
                  leading: const Icon(Icons.tune),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/app'),
                ),
                MeshTile(
                  title: context.l10n.data_d8e5fd,
                  leading: const Icon(Icons.storage_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/data'),
                ),
                MeshTile(
                  title: context.l10n.messageFilter_cf2a46,
                  leading: const Icon(Icons.filter_alt_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/message-filter'),
                ),
                MeshTile(
                  title: context.l10n.mirror_66ace6,
                  leading: const Icon(Icons.public),
                  trailing: Text(
                    mirror?.enabled == true
                        ? (mirror!.baseUrl?.host ?? '')
                        : context.l10n.off_147380,
                  ),
                  onTap: () => context.go('/settings/mirror'),
                ),
              ],
            ),
            SectionCard(
              title: context.l10n.radioConfiguration_dbf9ae,
              children: [
                MeshTile(
                  title: 'LoRa',
                  leading: const Icon(Icons.cell_tower),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/lora'),
                ),
                MeshTile(
                  title: context.l10n.channels_88a8ec,
                  leading: const Icon(Icons.swap_horiz),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/channels'),
                ),
                MeshTile(
                  title: context.l10n.security_d4fab1,
                  leading: const Icon(Icons.shield_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/security'),
                ),
              ],
            ),
            SectionCard(
              title: context.l10n.deviceConfiguration_ccb937,
              children: [
                MeshTile(
                  title: context.l10n.user_51aff1,
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
                  title: context.l10n.device_bc791d,
                  leading: const Icon(Icons.memory),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/device'),
                ),
                MeshTile(
                  title: context.l10n.position_c139a7,
                  leading: const Icon(Icons.location_on_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/position'),
                ),
                MeshTile(
                  title: context.l10n.power_cea0d9,
                  leading: const Icon(Icons.battery_charging_full),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/power'),
                ),
                MeshTile(
                  title: context.l10n.network_b3c4b1,
                  leading: const Icon(Icons.wifi),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/network'),
                ),
                MeshTile(
                  title: context.l10n.display_0cca12,
                  leading: const Icon(Icons.screenshot_monitor),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/display'),
                ),
              ],
            ),
            SectionCard(
              title: context.l10n.moduleConfiguration_4b812e,
              children: [
                MeshTile(
                  title: 'MQTT',
                  leading: const Icon(Icons.dns_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/mqtt'),
                ),
                MeshTile(
                  title: context.l10n.serial_427dc5,
                  leading: const Icon(Icons.cable),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/serial'),
                ),
                MeshTile(
                  title: context.l10n.externalNotification_22860a,
                  leading: const Icon(Icons.notifications_active_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/external-notification'),
                ),
                MeshTile(
                  title: context.l10n.storeForward_05111b,
                  leading: const Icon(Icons.move_to_inbox_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/store-forward'),
                ),
                MeshTile(
                  title: context.l10n.rangeTest_c0e745,
                  leading: const Icon(Icons.social_distance_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/range-test'),
                ),
                MeshTile(
                  title: context.l10n.telemetry_c2d0b0,
                  leading: const Icon(Icons.query_stats),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/telemetry'),
                ),
                MeshTile(
                  title: context.l10n.cannedMessages_f068fb,
                  leading: const Icon(Icons.quickreply_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/canned-messages'),
                ),
                MeshTile(
                  title: context.l10n.audio_3bcc51,
                  leading: const Icon(Icons.graphic_eq),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/audio'),
                ),
                MeshTile(
                  title: context.l10n.remoteHardware_9cd039,
                  leading: const Icon(Icons.settings_input_component_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/remote-hardware'),
                ),
                MeshTile(
                  title: context.l10n.neighborInformation_2b7dad,
                  leading: const Icon(Icons.hub_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/neighbor-info'),
                ),
                MeshTile(
                  title: context.l10n.ambientLighting_d3a18a,
                  leading: const Icon(Icons.lightbulb_outline),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/ambient-lighting'),
                ),
                MeshTile(
                  title: context.l10n.detectionSensor_ef8fca,
                  leading: const Icon(Icons.sensors),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/detection-sensor'),
                ),
                MeshTile(
                  title: context.l10n.paxCounter_34f998,
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
                  title: context.l10n.trafficManagement_c0dc15,
                  leading: const Icon(Icons.traffic_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/traffic-management'),
                ),
              ],
            ),
            SectionCard(
              title: context.l10n.maintenance_3c5bdd,
              children: [
                MeshTile(
                  title: context.l10n.backupRestore_e10c3e,
                  leading: const Icon(Icons.settings_backup_restore),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/backup'),
                ),
              ],
            ),
            SectionCard(
              title: context.l10n.support_6ae569,
              children: [
                if (ref.watch(reportUploaderProvider) != null)
                  MeshTile(
                    title: context.l10n.sendReportToTheDeveloper_d46fe6,
                    subtitle:
                        context.l10n.applicationAndNodeLogsAndDetails_395cd3,
                    leading: const Icon(Icons.bug_report_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/settings/report'),
                  ),
                MeshTile(
                  title: context.l10n.nodeHardwareIds_a78041,
                  subtitle: context.l10n.macAndDeviceIdOfThe_018be2,
                  leading: const Icon(Icons.memory),
                  onTap: () => showHardwareIds(context),
                ),
              ],
            ),
            const AboutSection(),
          ],
        ],
      ),
    );
  }
}
