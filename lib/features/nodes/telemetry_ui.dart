import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/proto/mesh.dart';
import '../../data/database.dart';
import '../../data/node_details.dart';
import '../../data/telemetry.dart';
import '../../ui/kit/kit.dart';
import 'node_actions_ui.dart';
import 'node_detail_page.dart';
import 'nodes_page.dart';

/// Раздел «Телеметрия» карточки ноды: типы, по которым есть замеры, —
/// строка со временем последнего замера ведёт к графикам; внизу —
/// запрос любого типа.
class TelemetrySection extends ConsumerWidget {
  const TelemetrySection(this.n, {super.key});

  final Node n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSend = ref.watch(canSendProvider) && n.onRadio;
    final last = {
      for (final k in TelemetryKind.values)
        k: ?ref.watch(telemetryProvider((n.num, k))).value?.lastOrNull,
    };
    final a = ref.read(nodeActionsProvider);
    return SectionCard(
      title: 'Телеметрия',
      children: [
        for (final MapEntry(key: k, value: s) in last.entries)
          MeshTile(
            title: k.title,
            subtitle: lastHeardText(s.time),
            trailing: const Icon(Icons.show_chart),
            onTap: () => context.push(TelemetryPage.location(n.num, k)),
          ),
        MeshTile(
          title: 'Запросить телеметрию',
          subtitle: last.isEmpty
              ? 'Замеров по радио пока нет'
              : 'Нода ответит текущими значениями',
          // Не тип телеметрии — «Локальная статистика» (LocalStats).
          trailing: PopupMenuButton<Object>(
            enabled: canSend,
            icon: const Icon(Icons.refresh),
            onSelected: (k) => runNodeAction(
              context,
              () => k is TelemetryKind
                  ? a.requestTelemetry(n.num, k)
                  : a.requestLocalStats(n.num),
              'Запрос отправлен — ждём ответ',
            ),
            itemBuilder: (_) => [
              for (final k in TelemetryKind.values)
                PopupMenuItem(value: k, child: Text(k.title)),
              const PopupMenuItem(
                value: 'localStats',
                child: Text('Локальная статистика'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Значения замера для [InfoGrid]; сомнительные — цветом ошибки и «?».
List<(String, String, Color?)> sampleItems(
  TelemetryKind kind,
  TelemetrySample s,
  Color error,
) => [
  if (s.externalPower) ('Уровень заряда', 'Внешнее питание', null),
  for (final m in telemetryMetrics[kind]!)
    if (s.values[m.key] case final v?)
      (m.label, valueText(m, v), null)
    else if (s.suspect[m.key] case final v?)
      (m.label, '${m.format(v)} ?', error),
];

/// Значение для показа: время работы — словами, остальное — с единицей.
String valueText(Metric m, double v) =>
    m.key == uptimeKey ? uptimeText(v.round()) : m.format(v);

/// Экран одного типа телеметрии: период, графики, журнал замеров.
class TelemetryPage extends ConsumerStatefulWidget {
  const TelemetryPage({super.key, required this.num, required this.kind});

  final int num;
  final TelemetryKind kind;

  static String location(int num, TelemetryKind kind) =>
      '/node/$num/telemetry/${kind.name}';

  @override
  ConsumerState<TelemetryPage> createState() => _TelemetryPageState();
}

/// Периоды: 1 ч, сутки, неделя, всё.
const _periods = <(String, Duration?)>[
  ('1Ч', Duration(hours: 1)),
  ('24Ч', Duration(days: 1)),
  ('7Д', Duration(days: 7)),
  ('Всё', null),
];

class _TelemetryPageState extends ConsumerState<TelemetryPage> {
  Duration? _period = const Duration(days: 1);

  @override
  Widget build(BuildContext context) {
    final all =
        ref.watch(telemetryProvider((widget.num, widget.kind))).value ??
        const <TelemetrySample>[];
    final node = ref.watch(nodeProvider(widget.num)).value;
    final canSend = ref.watch(canSendProvider) && (node?.onRadio ?? false);
    final now = DateTime.now();
    final samples = inPeriod(all, _period, now);
    final from = _period == null
        ? (samples.firstOrNull?.time ?? now)
        : now.subtract(_period!);
    final groups = chartGroups(widget.kind, samples);
    final a = ref.read(nodeActionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kind.title),
        actions: [
          IconButton(
            tooltip: 'Запросить',
            icon: const Icon(Icons.refresh),
            onPressed: canSend
                ? () => runNodeAction(
                    context,
                    () => a.requestTelemetry(widget.num, widget.kind),
                    'Запрос отправлен — ждём ответ',
                  )
                : null,
          ),
        ],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          if (node != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Tokens.s8),
              child: Text(
                node.longName.isEmpty ? nodeIdString(node.num) : node.longName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          SegmentedButton<Duration?>(
            showSelectedIcon: false,
            segments: [
              for (final (t, d) in _periods)
                ButtonSegment(value: d, label: Text(t)),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: Tokens.s8),
          if (samples.isEmpty)
            const Padding(
              padding: EdgeInsets.all(Tokens.s16),
              child: Text('Нет замеров за этот период'),
            ),
          for (final e in groups.entries)
            _ChartCard(
              key: ValueKey(e.key),
              title: e.key,
              metrics: e.value,
              samples: samples,
              from: from,
              to: now,
            ),
          if (samples.isNotEmpty) _Journal(widget.kind, samples),
        ],
      ),
    );
  }
}

String _two(int v) => v.toString().padLeft(2, '0');

/// «23.10 14:05».
String dateTimeText(DateTime t) =>
    '${_two(t.day)}.${_two(t.month)} ${_two(t.hour)}:${_two(t.minute)}';

const _palette = [
  Color(0xFF43A047),
  Color(0xFF1E88E5),
  Color(0xFFFB8C00),
  Color(0xFF8E24AA),
  Color(0xFFE53935),
  Color(0xFF00ACC1),
  Color(0xFFC0CA33),
  Color(0xFF6D4C41),
];

const _axisWidth = 44.0;

/// График группы величин с общей единицей; легенда скрывает линии.
class _ChartCard extends StatefulWidget {
  const _ChartCard({
    super.key,
    required this.title,
    required this.metrics,
    required this.samples,
    required this.from,
    required this.to,
  });

  final String title;
  final List<Metric> metrics;
  final List<TelemetrySample> samples;
  final DateTime from;
  final DateTime to;

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard> {
  final _hidden = <String>{};

  @override
  Widget build(BuildContext context) {
    final metrics = widget.metrics;
    final unit = metrics.first.unit;
    final color = {
      for (var i = 0; i < metrics.length; i++)
        metrics[i].key: _palette[i % _palette.length],
    };
    final raw = {for (final m in metrics) m.key: series(widget.samples, m.key)};
    final shown = [
      for (final m in metrics)
        if (!_hidden.contains(m.key) && raw[m.key]!.isNotEmpty) m,
    ];
    final total = [for (final m in shown) ...raw[m.key]!];
    final t = Theme.of(context);
    return SectionCard(
      title: unit.isEmpty ? widget.title : '${widget.title}, $unit',
      children: [
        if (metrics.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: Tokens.s8),
            child: Wrap(
              spacing: Tokens.s16,
              runSpacing: Tokens.s4,
              children: [
                for (final m in metrics)
                  InkWell(
                    onTap: () => setState(
                      () => _hidden.contains(m.key)
                          ? _hidden.remove(m.key)
                          : _hidden.add(m.key),
                    ),
                    child: Opacity(
                      opacity: _hidden.contains(m.key) ? 0.35 : 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color[m.key],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: Tokens.s4),
                          Text(m.label, style: t.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (total.length == 1)
          // Одна точка — линии нет, показываем значение.
          Padding(
            padding: const EdgeInsets.all(Tokens.s8),
            child: Text(
              '${valueText(shown.first, total.first.value)} · '
              '${dateTimeText(total.first.time)}',
              style: t.textTheme.titleMedium,
            ),
          )
        else if (total.length > 1)
          _chart(context, shown, raw, color),
      ],
    );
  }

  Widget _chart(
    BuildContext context,
    List<Metric> shown,
    Map<String, List<SeriesPoint>> raw,
    Map<String, Color> color,
  ) {
    final from = widget.from, to = widget.to;
    final data = {
      for (final m in shown) m.key: chartSeries(raw[m.key]!, from, to),
    };
    final ys = [
      for (final m in shown)
        for (final p in data[m.key]!)
          if (p != null) p.value,
    ];
    final axis = niceAxis(
      ys.reduce(math.min),
      ys.reduce(math.max),
      floorZero: shown.every((m) => m.min >= 0),
    );
    double x(DateTime d) => d.millisecondsSinceEpoch.toDouble();
    final minX = x(from), maxX = x(to);
    final step = timeStep(to.difference(from));
    final ticks = timeTicks(from, to, step);
    final style = Theme.of(context).textTheme.labelSmall;
    final grid = Theme.of(context).colorScheme.outlineVariant;
    String tickText(DateTime d) => step >= const Duration(days: 1)
        ? '${_two(d.day)}.${_two(d.month)}'
        : '${_two(d.hour)}:${_two(d.minute)}';

    final chart = LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: axis.min,
        maxY: axis.max,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: axis.step,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: grid, strokeWidth: 0.5),
        ),
        extraLinesData: ExtraLinesData(
          verticalLines: [
            for (final d in ticks)
              VerticalLine(x: x(d), color: grid, strokeWidth: 0.5),
          ],
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: _axisWidth,
              interval: axis.step,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                meta: meta,
                child: Text(v.toStringAsFixed(axis.digits), style: style),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  '${shown[s.barIndex].short}: '
                  '${shown[s.barIndex].format(s.y)}'
                  '${s == spots.last ? '\n${dateTimeText(DateTime.fromMillisecondsSinceEpoch(s.x.round()))}' : ''}',
                  TextStyle(color: color[shown[s.barIndex].key], fontSize: 12),
                ),
            ],
          ),
        ),
        lineBarsData: [
          for (final m in shown)
            LineChartBarData(
              spots: [
                for (final p in data[m.key]!)
                  p == null ? FlSpot.nullSpot : FlSpot(x(p.time), p.value),
              ],
              color: color[m.key],
              barWidth: 2,
              isCurved: false,
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );

    // Подписи времени — свои: ровно под засечками, без обрезанных краёв.
    return Column(
      children: [
        SizedBox(height: 180, child: chart),
        SizedBox(
          height: 18,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth - _axisWidth;
              const labelW = 40.0;
              return Stack(
                children: [
                  for (final d in ticks)
                    Positioned(
                      left:
                          (_axisWidth +
                                  w * (x(d) - minX) / (maxX - minX) -
                                  labelW / 2)
                              .clamp(
                                _axisWidth - labelW / 2,
                                c.maxWidth - labelW,
                              ),
                      width: labelW,
                      child: Text(
                        tickText(d),
                        style: style,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Журнал замеров таблицей: строка — замер, столбцы — величины. Время работы
/// не повторяем (оно в карточке ноды), внешнее питание — «сеть» в столбце
/// заряда. Длинный журнал — порциями.
class _Journal extends StatefulWidget {
  const _Journal(this.kind, this.samples);

  final TelemetryKind kind;
  final List<TelemetrySample> samples;

  @override
  State<_Journal> createState() => _JournalState();
}

class _JournalState extends State<_Journal> {
  static const _page = 30;
  int _shown = _page;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final rows = widget.samples.reversed.take(_shown).toList();
    final hasExternal = widget.samples.any((s) => s.externalPower);
    final cols = [
      for (final m in telemetryMetrics[widget.kind]!)
        if (m.key != uptimeKey &&
            (widget.samples.any(
                  (s) =>
                      s.values.containsKey(m.key) ||
                      s.suspect.containsKey(m.key),
                ) ||
                (m.key == batteryKey && hasExternal)))
          m,
    ];
    final head = t.textTheme.labelSmall?.copyWith(
      color: t.colorScheme.onSurfaceVariant,
    );
    final body = t.textTheme.bodySmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    Widget cell(String s, {TextStyle? style, bool right = true}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text(
        s,
        style: style ?? body,
        textAlign: right ? TextAlign.right : TextAlign.left,
      ),
    );
    String value(Metric m, TelemetrySample s) {
      if (m.key == batteryKey && s.externalPower) return 'сеть';
      if (s.values[m.key] case final v?) return v.toStringAsFixed(m.digits);
      if (s.suspect[m.key] case final v?) {
        return '${v.toStringAsFixed(m.digits)}?';
      }
      return '—';
    }

    return SectionCard(
      title: 'Журнал · ${widget.samples.length}',
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                children: [
                  cell('Время', style: head, right: false),
                  for (final m in cols)
                    cell(
                      m.unit.isEmpty ? m.short : '${m.short}, ${m.unit}',
                      style: head,
                    ),
                ],
              ),
              for (final s in rows)
                TableRow(
                  children: [
                    cell(dateTimeText(s.time), right: false),
                    for (final m in cols)
                      cell(
                        value(m, s),
                        style: s.suspect.containsKey(m.key)
                            ? body?.copyWith(color: t.colorScheme.error)
                            : null,
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (widget.samples.length > _shown)
          TextButton(
            onPressed: () => setState(() => _shown += _page),
            child: const Text('Показать ещё'),
          ),
      ],
    );
  }
}
