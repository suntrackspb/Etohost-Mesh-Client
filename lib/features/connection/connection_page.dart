import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_ble/universal_ble.dart';

import '../../app/providers.dart';
import '../../app/shell.dart';
import '../../core/proto/mesh.dart';
import '../../core/radio/endpoint.dart';
import '../../core/radio/radio_session.dart';
import '../../core/transport/ble_transport.dart';
import '../../core/transport/serial_transport.dart';
import '../../data/database.dart';
import '../../data/radio_stats.dart';
import '../../ui/kit/kit.dart';

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
    if (_scanning) UniversalBle.stopScan();
    _host.dispose();
    super.dispose();
  }

  Future<void> _toggleScan() async {
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
      setState(() => _error = 'Сканирование: $e');
    }
  }

  Future<void> _connect(RadioTarget target) async {
    if (_scanning) {
      await UniversalBle.stopScan();
      setState(() => _scanning = false);
    }
    await ref.read(radioProvider).connect(target);
  }

  void _connectTcp() {
    final h = _host.text.trim();
    if (h.isEmpty) return;
    final (host, port) = splitHostPort(h);
    _connect(Endpoint(EndpointKind.tcp, '$host:$port', '').toTarget());
  }

  @override
  Widget build(BuildContext context) {
    final radio = ref.watch(radioProvider);
    final theme = Theme.of(context);
    final devices = _devices.values.toList()
      ..sort((a, b) => (b.rssi ?? -200).compareTo(a.rssi ?? -200));

    return Scaffold(
      appBar: AppBar(title: const Text('Подключение')),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          _StatusCard(radio: radio),
          _RecentCard(onConnect: _connect),
          SectionCard(
            title: 'Wi-Fi (TCP)',
            children: [
              Padding(
                padding: const EdgeInsets.all(Tokens.s16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _host,
                        decoration: const InputDecoration(
                          labelText: 'IP или хост ноды',
                          hintText: '192.168.1.100',
                        ),
                        onSubmitted: (_) => _connectTcp(),
                      ),
                    ),
                    const SizedBox(width: Tokens.s12),
                    FilledButton(
                      onPressed: _connectTcp,
                      child: const Text('Подключить'),
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
                title: _scanning ? 'Идёт поиск нод…' : 'Найти ноды поблизости',
                leading: _scanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bluetooth_searching),
                trailing: TextButton(
                  onPressed: _toggleScan,
                  child: Text(_scanning ? 'Стоп' : 'Искать'),
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
                  subtitle: '${d.deviceId} · RSSI ${d.rssi ?? '?'}',
                  leading: const Icon(Icons.bluetooth),
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
          if (serialSupported) _SerialCard(onConnect: _connect),
          SectionCard(
            children: [
              MeshTile(
                title: 'Журнал',
                subtitle: 'События соединения, пакеты и лог ноды',
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
    return SectionCard(
      title: 'Нода',
      children: [
        Padding(
          padding: const EdgeInsets.all(Tokens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusDot(
                color: radioStateColor(radio.state),
                label: radioStateLabel(radio.state),
              ),
              if (target != null) ...[
                const SizedBox(height: Tokens.s8),
                Text(
                  target.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              if (radio.myNodeNum != null) Text(nodeIdString(radio.myNodeNum!)),
              const SizedBox(height: Tokens.s8),
              Wrap(
                spacing: Tokens.s16,
                runSpacing: Tokens.s4,
                children: [
                  if (radio.connectedSince != null)
                    Text(
                      'держится ${formatDuration(now.difference(radio.connectedSince!))}',
                    ),
                  if (radio.lastRx != null)
                    Text(
                      'пакет ${formatDuration(now.difference(radio.lastRx!))} назад',
                    ),
                  if (target != null) Text('пакетов ${radio.packetCount}'),
                  if (target != null) Text('разрывов ${radio.disconnects}'),
                ],
              ),
              if (stats != null) ...[
                const SizedBox(height: Tokens.s12),
                _StatsGrid(stats),
              ],
              if (target != null) ...[
                const SizedBox(height: Tokens.s12),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Автопереподключение'),
                        value: radio.autoReconnect,
                        onChanged: (v) => radio.autoReconnect = v,
                      ),
                    ),
                    const SizedBox(width: Tokens.s12),
                    if (radio.state == RadioState.idle)
                      FilledButton(
                        onPressed: radio.reconnect,
                        child: const Text('Подключить'),
                      )
                    else
                      OutlinedButton(
                        onPressed: radio.disconnect,
                        child: const Text('Отключить'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// USB Serial: список портов по кнопке (на десктопе порты не присылают событий).
class _SerialCard extends StatefulWidget {
  const _SerialCard({required this.onConnect});

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
      if (mounted) setState(() => _error = 'Порты: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ports = _ports ?? const <SerialPortInfo>[];
    return SectionCard(
      title: 'USB (Serial)',
      children: [
        MeshTile(
          title: _ports == null
              ? 'Поиск портов…'
              : ports.isEmpty
              ? 'Портов не найдено'
              : 'Портов: ${ports.length}',
          subtitle: 'Подключите ноду кабелем USB',
          leading: const Icon(Icons.usb),
          trailing: TextButton(
            onPressed: _refresh,
            child: const Text('Обновить'),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(Tokens.s16),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        for (final p in ports)
          MeshTile(
            title: p.title,
            subtitle: p.subtitle,
            leading: const Icon(Icons.cable),
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
    return SectionCard(
      title: 'Недавние',
      children: [
        SwitchListTile.adaptive(
          title: const Text('Подключаться к последней ноде при запуске'),
          value: auto,
          onChanged: (v) => db.setSetting(AppSettingKeys.autoConnect, '$v'),
        ),
        if (recent.isEmpty)
          const MeshTile(
            title: 'Пока пусто',
            subtitle: 'Здесь появятся ноды, к которым вы подключались',
          ),
        for (final r in recent)
          MeshTile(
            title: r.name.isEmpty ? r.address : r.name,
            subtitle: [
              EndpointKind.values.byName(r.kind).label,
              if (r.name.isNotEmpty) r.address,
              if (r.nodeNum != null) nodeIdString(r.nodeNum!),
            ].join(' · '),
            leading: Icon(switch (EndpointKind.values.byName(r.kind)) {
              EndpointKind.ble => Icons.bluetooth,
              EndpointKind.tcp => Icons.wifi,
              EndpointKind.serial => Icons.usb,
            }),
            trailing: IconButton(
              tooltip: 'Забыть',
              icon: const Icon(Icons.close),
              onPressed: () => db.forgetRecent(r.kind, r.address),
            ),
            onTap: () => onConnect(endpointOf(r).toTarget()),
          ),
      ],
    );
  }
}

String _pct(double? v) => v == null ? '—' : '${v.toStringAsFixed(1)}%';

/// Плитки сводки, как в iOS-клиенте Etohost.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid(this.s);

  final RadioStats s;

  @override
  Widget build(BuildContext context) {
    final b = s.battery;
    final tiles = [
      (Icons.cell_tower, Colors.lightBlue, '${s.onRadio}', 'Нод в эфире'),
      (Icons.circle, Colors.green, '${s.online}', 'Онлайн'),
      (Icons.tag, Colors.blue, '${s.channels}', 'Каналов'),
      s.onPower
          ? (Icons.power, Colors.green, 'Сеть', 'Батарея')
          : (
              Icons.battery_std,
              Colors.orange,
              b == null ? '—' : '$b%',
              'Батарея',
            ),
      (
        Icons.monitor_heart_outlined,
        Colors.pink,
        _pct(s.channelUtil),
        'Загрузка канала',
      ),
      (Icons.upload_outlined, Colors.purple, _pct(s.airUtilTx), 'Эфир TX'),
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
                padding: const EdgeInsets.all(Tokens.s12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(height: Tokens.s4),
                    FittedBox(
                      child: Text(value, style: theme.textTheme.titleLarge),
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
