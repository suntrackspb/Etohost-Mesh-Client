import 'package:meshex/l10n/l10n.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:universal_ble/universal_ble.dart';

import '../../app/providers.dart';
import '../../app/shell.dart';
import '../../core/proto/mesh.dart';
import '../../core/radio/endpoint.dart';
import '../../core/radio/radio_session.dart';
import '../../core/transport/ble_transport.dart';
import '../../core/transport/net_discovery.dart';
import '../../core/transport/serial_transport.dart';
import '../../data/database.dart';
import '../../data/radio_stats.dart';
import '../settings/radio/administration_page.dart';
import '../../ui/kit/kit.dart';
import '../../app/link_badge.dart';

class ConnectionPage extends ConsumerStatefulWidget {
  const ConnectionPage({super.key});

  @override
  ConsumerState<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends ConsumerState<ConnectionPage> {
  final _devices = <String, BleDevice>{};
  final _host = TextEditingController();
  StreamSubscription? _scanSub;
  Timer? _tick;
  bool _scanning = false;
  String? _error;
  final _net = NetDiscovery();
  List<NetNode> _netNodes = const [];
  String? _netError;

  @override
  void initState() {
    super.initState();
    // Обновляем «держится N» раз в секунду.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _scanSub?.cancel();
    _net.stop();
    if (_scanning) UniversalBle.stopScan();
    _host.dispose();
    super.dispose();
  }

  Future<void> _toggleScan() async {
    final strings = context.l10n;
    if (_scanning) {
      await UniversalBle.stopScan();
      setState(() => _scanning = false);
      return;
    }
    setState(() => _error = null);
    try {
      await UniversalBle.requestPermissions(withAndroidFineLocation: false);
      final st = await UniversalBle.getBluetoothAvailabilityState();
      if (st != AvailabilityState.poweredOn) {
        setState(() => _error = 'Bluetooth: ${st.name}');
        return;
      }
      _devices.clear();
      _scanSub ??= UniversalBle.scanStream.listen((d) {
        if (mounted) setState(() => _devices[d.deviceId] = d);
      });
      await UniversalBle.startScan(
        scanFilter: ScanFilter(withServices: [MeshBle.service]),
      );
      setState(() => _scanning = true);
    } catch (e) {
      setState(() => _error = strings.scan_603ff2((e).toString()));
    }
  }

  Future<void> _toggleNet() async {
    final strings = context.l10n;
    if (_net.running) {
      await _net.stop();
      setState(() {});
      return;
    }
    setState(() {
      _netError = null;
      _netNodes = const [];
    });
    try {
      await _net.start((nodes) {
        if (mounted) setState(() => _netNodes = nodes);
      });
      if (mounted) setState(() {});
    } catch (e) {
      await _net.stop();
      if (mounted) {
        setState(
          () => _netError = strings.networkSearch_a3c1c6((e).toString()),
        );
      }
    }
  }

  Future<void> _connect(RadioTarget target) async {
    if (_scanning) {
      await UniversalBle.stopScan();
      setState(() => _scanning = false);
    }
    if (_net.running) await _net.stop();
    await ref.read(radioProvider).connect(target);
  }

  void _connectTcp() {
    final h = _host.text.trim();
    if (h.isEmpty) return;
    final (host, port) = splitHostPort(h);
    _connect(
      Endpoint(EndpointKind.tcp, joinHostPort(host, port), '').toTarget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radio = ref.watch(radioProvider);
    final theme = Theme.of(context);
    // В порядке появления: RSSI скачет, сортировка по нему дёргает список.
    final devices = _devices.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.connecting_79e350),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          _StatusCard(radio: radio),
          if (radio.pairingHint != null)
            SectionCard(
              title: context.l10n.bluetoothPairingOnLinux_5f59c4,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Tokens.s16),
                  child: SelectableText(context.builtIn(radio.pairingHint!)),
                ),
              ],
            ),
          _RecentCard(onConnect: _connect),
          SectionCard(
            title: 'Wi-Fi (TCP)',
            children: [
              if (netDiscoverySupported) ...[
                MeshTile(
                  title: _net.running
                      ? context.l10n.searchingTheNetwork_bdab2d
                      : context.l10n.findNodesOnTheLocalNetwork_9f4117,
                  leading: _net.running
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_find),
                  trailing: TextButton(
                    onPressed: _toggleNet,
                    child: Text(
                      _net.running
                          ? context.l10n.stop_6d714e
                          : context.l10n.search_58212e,
                    ),
                  ),
                ),
                if (_netError != null)
                  Padding(
                    padding: const EdgeInsets.all(Tokens.s16),
                    child: Text(
                      _netError!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                for (final n in _netNodes)
                  MeshTile(
                    title: n.name,
                    subtitle: _withState(
                      n.address,
                      _linkOf(radio, EndpointKind.tcp, n.address),
                    ),
                    leading: _linkIcon(
                      _linkOf(radio, EndpointKind.tcp, n.address),
                      Icons.wifi,
                    ),
                    onTap: () => _connect(
                      Endpoint(EndpointKind.tcp, n.address, n.name).toTarget(),
                    ),
                  ),
              ],
              Padding(
                padding: const EdgeInsets.all(Tokens.s16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _host,
                        decoration: InputDecoration(
                          labelText: context.l10n.nodeIpOrHostname_4e0881,
                          hintText: '192.168.1.100',
                        ),
                        onSubmitted: (_) => _connectTcp(),
                      ),
                    ),
                    const SizedBox(width: Tokens.s12),
                    FilledButton(
                      onPressed: _connectTcp,
                      child: Text(context.l10n.connect_124298),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SectionCard(
            title: 'Bluetooth',
            children: [
              MeshTile(
                title: _scanning
                    ? context.l10n.searchingForNodes_ba19cf
                    : context.l10n.findNearbyNodes_37deaa,
                leading: _scanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bluetooth_searching),
                trailing: TextButton(
                  onPressed: _toggleScan,
                  child: Text(
                    _scanning
                        ? context.l10n.stop_6d714e
                        : context.l10n.search_58212e,
                  ),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(Tokens.s16),
                  child: Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              for (final d in devices)
                MeshTile(
                  title: d.name?.isNotEmpty == true ? d.name! : d.deviceId,
                  subtitle: _withState(
                    '${d.deviceId} · RSSI ${d.rssi ?? '?'}',
                    _linkOf(radio, EndpointKind.ble, d.deviceId),
                  ),
                  leading: _linkIcon(
                    _linkOf(radio, EndpointKind.ble, d.deviceId),
                    Icons.bluetooth,
                  ),
                  onTap: () {
                    final name = d.name?.isNotEmpty == true
                        ? d.name!
                        : d.deviceId;
                    _connect(
                      Endpoint(EndpointKind.ble, d.deviceId, name).toTarget(),
                    );
                  },
                ),
            ],
          ),
          if (serialSupported) _SerialCard(radio: radio, onConnect: _connect),
          SectionCard(
            children: [
              MeshTile(
                title: context.l10n.journal_67ade7,
                subtitle: context.l10n.connectionEventsPacketsAndNodeLog_745e44,
                leading: const Icon(Icons.receipt_long),
                onTap: () => context.go('/connection/journal'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends ConsumerWidget {
  const _StatusCard({required this.radio});

  final RadioSession radio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(radioStatsProvider);
    final now = DateTime.now();
    final target = radio.target;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return SectionCard(
      title: context.l10n.node_2409cc,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Tokens.s16,
            Tokens.s12,
            Tokens.s12,
            Tokens.s12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: radioStateColor(radio.state),
                  ),
                  const SizedBox(width: Tokens.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          target?.title ?? radioStateLabel(radio.state),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        // Строка есть всегда — высота карточки не меняется.
                        Text(
                          target == null
                              ? '—'
                              : [
                                  if (radio.myNodeNum != null)
                                    nodeIdString(radio.myNodeNum!),
                                  radioStateLabel(radio.state),
                                ].join(' · '),
                          style: muted,
                        ),
                      ],
                    ),
                  ),
                  if (target != null && radio.state == RadioState.idle)
                    FilledButton(
                      onPressed: radio.reconnect,
                      child: Text(context.l10n.connect_124298),
                    )
                  else if (target != null)
                    OutlinedButton(
                      onPressed: radio.disconnect,
                      child: Text(context.l10n.disconnect_94d07a),
                    ),
                ],
              ),
              // Счётчики и плитки не прячем: при переподключении без них
              // список прыгал на их высоту. Нет данных — прочерки.
              const SizedBox(height: Tokens.s8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Metric(
                    Icons.timer_outlined,
                    radio.connectedSince == null
                        ? '—'
                        : formatDuration(now.difference(radio.connectedSince!)),
                    context.l10n.connectionDuration_c69bbf,
                  ),
                  _Metric(
                    Icons.south_west,
                    radio.lastRx == null
                        ? '—'
                        : formatDuration(now.difference(radio.lastRx!)),
                    context.l10n.timeSinceTheLastPacketFrom_b027b2,
                  ),
                  _Metric(
                    Icons.swap_vert,
                    target == null ? '—' : '${radio.packetCount}',
                    context.l10n.packetsReceived_83d955,
                  ),
                  _Metric(
                    Icons.link_off,
                    target == null ? '—' : '${radio.disconnects}',
                    context.l10n.connectionDrops_1da695,
                  ),
                ],
              ),
              const SizedBox(height: Tokens.s8),
              _StatsGrid(stats),
            ],
          ),
        ),
        // Строка остаётся на месте при обрыве, как и статистика выше.
        ListTile(
          title: Text(context.l10n.administration_d838aa),
          leading: const Icon(Icons.admin_panel_settings_outlined),
          trailing: const Icon(Icons.chevron_right),
          enabled: radio.state == RadioState.ready && radio.myNodeNum != null,
          onTap: radio.state == RadioState.ready && radio.myNodeNum != null
              ? () => Navigator.of(context).push(
                  SwipeablePageRoute<void>(
                    builder: (_) => const AdministrationPage(),
                  ),
                )
              : null,
        ),
        SwitchListTile.adaptive(
          dense: true,
          title: Text(context.l10n.reconnect_a8e2cf),
          subtitle: Text(context.l10n.onConnectionLoss_24be13),
          value: radio.autoReconnect,
          onChanged: (v) => setAutoReconnect(ref, v),
        ),
      ],
    );
  }
}

/// Счётчик соединения: иконка и значение, пояснение — в подсказке.
class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.value, this.hint);

  final IconData icon;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Tooltip(
      message: hint,
      triggerMode: TooltipTriggerMode.tap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: Tokens.s4),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// USB Serial: список портов по кнопке (на десктопе порты не присылают событий).
class _SerialCard extends StatefulWidget {
  const _SerialCard({required this.radio, required this.onConnect});

  final RadioSession radio;
  final Future<void> Function(RadioTarget target) onConnect;

  @override
  State<_SerialCard> createState() => _SerialCardState();
}

class _SerialCardState extends State<_SerialCard> {
  List<SerialPortInfo>? _ports;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final ports = await listSerialPorts();
      if (mounted) {
        setState(() {
          _ports = ports;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ports = _ports ?? const <SerialPortInfo>[];
    final radio = widget.radio;
    return SectionCard(
      title: 'USB (Serial)',
      children: [
        MeshTile(
          title: _ports == null
              ? context.l10n.searchingForPorts_eea068
              : ports.isEmpty
              ? context.l10n.noPortsFound_cc35ea
              : context.l10n.ports_50f8c3((ports.length).toString()),
          subtitle: context.l10n.connectTheNodeUsingAUsb_c6b502,
          leading: const Icon(Icons.usb),
          trailing: TextButton(
            onPressed: _refresh,
            child: Text(context.l10n.refresh_c2f668),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(Tokens.s16),
            child: Text(
              context.l10n.ports_1b477b(_error!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        for (final p in ports)
          MeshTile(
            title: p.title,
            subtitle: _withState(
              p.subtitle,
              _linkOf(radio, EndpointKind.serial, p.id),
            ),
            leading: _linkIcon(
              _linkOf(radio, EndpointKind.serial, p.id),
              Icons.cable,
            ),
            onTap: () => widget.onConnect(
              Endpoint(EndpointKind.serial, p.id, p.title).toTarget(),
            ),
          ),
      ],
    );
  }
}

/// Недавние подключения + «подключаться при запуске».
class _RecentCard extends ConsumerWidget {
  const _RecentCard({required this.onConnect});

  final Future<void> Function(RadioTarget target) onConnect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentConnectionsProvider).value ?? const [];
    final auto = ref.watch(autoConnectProvider).value ?? true;
    final db = ref.read(databaseProvider);
    final radio = ref.watch(radioProvider);
    return SectionCard(
      title: context.l10n.recent_1328d8,
      children: [
        SwitchListTile.adaptive(
          title: Text(context.l10n.connectToTheLastNodeOn_98c221),
          value: auto,
          onChanged: (v) => db.setSetting(AppSettingKeys.autoConnect, '$v'),
        ),
        if (recent.isEmpty)
          MeshTile(
            title: context.l10n.nothingHereYet_ea91cf,
            subtitle: context.l10n.nodesYouHaveConnectedToWill_436ad0,
          ),
        for (final r in recent)
          MeshTile(
            title: r.name.isEmpty ? r.address : r.name,
            subtitle: _withState(
              [
                [
                  EndpointKind.values.byName(r.kind).label,
                  if (r.name.isNotEmpty) r.address,
                ].join(' · '),
                if (r.nodeNum != null) nodeIdString(r.nodeNum!),
              ].join('\n'),
              _linkOf(radio, EndpointKind.values.byName(r.kind), r.address),
            ),
            leading: _linkIcon(
              _linkOf(radio, EndpointKind.values.byName(r.kind), r.address),
              switch (EndpointKind.values.byName(r.kind)) {
                EndpointKind.ble => Icons.bluetooth,
                EndpointKind.tcp => Icons.wifi,
                EndpointKind.serial => Icons.usb,
              },
            ),
            trailing: IconButton(
              tooltip: context.l10n.forget_90bc7d,
              icon: const Icon(Icons.close),
              onPressed: () => db.forgetRecent(r.kind, r.address),
            ),
            onTap: () => onConnect(endpointOf(r).toTarget()),
          ),
      ],
    );
  }
}

RadioState? _linkOf(RadioSession radio, EndpointKind kind, String address) =>
    endpointLinkState(radio.target?.endpoint, radio.state, kind, address);

/// Иконка плашки: крутилка, пока идёт подключение к ней, галочка — готово.
Widget _linkIcon(RadioState? s, IconData icon) => switch (s) {
  null => Icon(icon),
  RadioState.ready => Icon(Icons.check_circle, color: radioStateColor(s)),
  _ => const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
};

String _withState(String subtitle, RadioState? s) =>
    s == null ? subtitle : '$subtitle\n${radioStateLabel(s)}';

String _pct(double? v) => v == null ? '—' : '${v.toStringAsFixed(1)}%';

/// Плитки сводки, как в исходном iOS-клиенте.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid(this.s);

  /// null — нет подключения: плитки с прочерками.
  final RadioStats? s;

  @override
  Widget build(BuildContext context) {
    final s = this.s;
    final b = s?.battery;
    String n(int? v) => v == null ? '—' : '$v';
    final tiles = [
      (
        Icons.cell_tower,
        Colors.lightBlue,
        n(s?.onRadio),
        context.l10n.nodesOnRadio_f76516,
      ),
      (Icons.circle, Colors.green, n(s?.online), context.l10n.online_76e9fb),
      (Icons.tag, Colors.blue, n(s?.channels), context.l10n.channels_5488bf),
      s?.onPower ?? false
          ? (
              Icons.power,
              Colors.green,
              context.l10n.network_b3c4b1,
              context.l10n.battery_96a4c3,
            )
          : (
              Icons.battery_std,
              Colors.orange,
              b == null ? '—' : '$b%',
              context.l10n.battery_96a4c3,
            ),
      (
        Icons.monitor_heart_outlined,
        Colors.pink,
        _pct(s?.channelUtil),
        'ChUtil',
      ),
      (Icons.upload_outlined, Colors.purple, _pct(s?.airUtilTx), 'AirUtil'),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        const gap = Tokens.s8;
        final w = (c.maxWidth - gap * 2) / 3;
        final theme = Theme.of(context);
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (icon, color, value, label) in tiles)
              Container(
                width: w,
                padding: const EdgeInsets.symmetric(
                  horizontal: Tokens.s12,
                  vertical: Tokens.s8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color, size: 16),
                        const SizedBox(width: Tokens.s4),
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              value,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
