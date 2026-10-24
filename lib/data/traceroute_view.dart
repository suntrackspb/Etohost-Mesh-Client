import 'dart:math' as math;

import 'node_actions.dart';

/// Сколько ждём ответ на трассировку; дольше — «нет ответа».
const traceTimeout = Duration(minutes: 2);

enum TraceStatus { pending, noAnswer, answered }

TraceStatus traceStatus(TracerouteResult r, DateTime now) => r.answered
    ? TraceStatus.answered
    : now.difference(r.time) < traceTimeout
    ? TraceStatus.pending
    : TraceStatus.noAnswer;

/// «2 хопа», «напрямую» — промежуточных нод в пути [path]
/// (путь включает начало и конец).
String hopsText(List<Hop> path) {
  final n = math.max(0, path.length - 2);
  if (n == 0) return 'напрямую';
  final mod10 = n % 10, mod100 = n % 100;
  final word = mod10 == 1 && mod100 != 11
      ? 'хоп'
      : mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)
      ? 'хопа'
      : 'хопов';
  return '$n $word';
}

/// Итог одной строкой: «туда 2 хопа · обратно 3 хопа», «нет ответа».
String traceSummary(TracerouteResult r, DateTime now) =>
    switch (traceStatus(r, now)) {
      TraceStatus.pending => 'ждём ответ',
      TraceStatus.noAnswer => 'нет ответа',
      TraceStatus.answered => [
        'туда ${hopsText(r.towards)}',
        if (r.back.isNotEmpty) 'обратно ${hopsText(r.back)}',
      ].join(' · '),
    };

/// Точка ноды на карте маршрута. [approx] — положение не из координат
/// ноды, а вычислено (задел под оценку положения с сервера зеркала).
typedef RoutePoint = ({double lat, double lon, bool approx});

/// Отрезок маршрута между соседними нодами с известным положением;
/// [skipped] — сколько нод без координат между ними пропущено.
typedef RouteLeg = ({
  int from,
  int to,
  RoutePoint a,
  RoutePoint b,
  int skipped,
});

/// Отрезки пути [path] по точкам из [pos] (null — положение неизвестно).
List<RouteLeg> routeLegs(List<Hop> path, RoutePoint? Function(int num) pos) {
  final legs = <RouteLeg>[];
  int? prev;
  RoutePoint? prevP;
  var skipped = 0;
  for (final h in path) {
    final p = pos(h.num);
    if (p == null) {
      if (prev != null) skipped++;
      continue;
    }
    if (prev != null && prev != h.num) {
      legs.add((from: prev, to: h.num, a: prevP!, b: p, skipped: skipped));
    }
    prev = h.num;
    prevP = p;
    skipped = 0;
  }
  return legs;
}

/// Отрезки, пройденные и туда, и обратно (в любом направлении): их линии
/// раздвигаем, чтобы не легли одна на другую.
Set<(int, int)> sharedLegs(List<RouteLeg> towards, List<RouteLeg> back) {
  (int, int) key(RouteLeg l) => l.from < l.to ? (l.from, l.to) : (l.to, l.from);
  final t = {for (final l in towards) key(l)};
  return {for (final l in back) key(l)}.intersection(t);
}

bool isShared(RouteLeg l, Set<(int, int)> shared) =>
    shared.contains(l.from < l.to ? (l.from, l.to) : (l.to, l.from));

/// Сдвиг отрезка [a]→[b] (экранные координаты) на [d] влево по ходу
/// движения. Встречные отрезки с одним [d] расходятся в разные стороны.
((double, double), (double, double)) shiftSegment(
  (double, double) a,
  (double, double) b,
  double d,
) {
  final dx = b.$1 - a.$1, dy = b.$2 - a.$2;
  final len = math.sqrt(dx * dx + dy * dy);
  if (len == 0) return (a, b);
  final nx = dy / len * d, ny = -dx / len * d;
  return ((a.$1 + nx, a.$2 + ny), (b.$1 + nx, b.$2 + ny));
}
