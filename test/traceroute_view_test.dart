import 'package:etohost_mesh/data/node_actions.dart';
import 'package:etohost_mesh/data/traceroute_view.dart';
import 'package:flutter_test/flutter_test.dart';

List<Hop> path(List<int> nums) => [for (final n in nums) (num: n, snr: null)];

RoutePoint pt(double lat) => (lat: lat, lon: 30, approx: false);

void main() {
  final t0 = DateTime(2026, 10, 24, 12);

  TracerouteResult trace({bool answered = true, List<int>? back}) =>
      TracerouteResult(
        time: t0,
        towards: answered ? path([1, 2, 3]) : const [],
        back: answered ? path(back ?? [3, 1]) : const [],
        answered: answered,
      );

  test('статус: ждём, пока не вышел таймаут, потом «нет ответа»', () {
    final r = trace(answered: false);
    expect(
      traceStatus(r, t0.add(const Duration(seconds: 30))),
      TraceStatus.pending,
    );
    expect(traceStatus(r, t0.add(traceTimeout)), TraceStatus.noAnswer);
    expect(traceSummary(r, t0.add(traceTimeout)), 'нет ответа');
  });

  test('итог: хопы туда и обратно, напрямую', () {
    expect(traceSummary(trace(), t0), 'туда 1 хоп · обратно напрямую');
    expect(hopsText(path([1, 2, 3, 4, 5, 6, 7])), '5 хопов');
    expect(hopsText(path([1, 2, 3, 4])), '2 хопа');
  });

  test('отрезки: ноды без координат пропускаются и считаются', () {
    final pos = {1: pt(1), 4: pt(4), 5: pt(5)};
    final legs = routeLegs(path([1, 2, 3, 4, 5]), (n) => pos[n]);
    expect(
      [for (final l in legs) (l.from, l.to, l.skipped)],
      [(1, 4, 2), (4, 5, 0)],
    );
  });

  test('общие отрезки — в любом направлении', () {
    final pos = {1: pt(1), 2: pt(2), 3: pt(3)};
    final t = routeLegs(path([1, 2, 3]), (n) => pos[n]);
    final b = routeLegs(path([3, 1]), (n) => pos[n]);
    final b2 = routeLegs(path([3, 2, 1]), (n) => pos[n]);
    expect(sharedLegs(t, b), isEmpty);
    expect(sharedLegs(t, b2), {(1, 2), (2, 3)});
  });

  test('встречные отрезки сдвигаются в разные стороны', () {
    final (a1, _) = shiftSegment((0, 0), (10, 0), 3);
    final (_, b2) = shiftSegment((10, 0), (0, 0), 3);
    expect(a1.$2, -3);
    expect(b2.$2, 3);
    expect(a1.$1, 0);
  });
}
