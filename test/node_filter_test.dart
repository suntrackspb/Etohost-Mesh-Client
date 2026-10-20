import 'package:drift/drift.dart' show Value;
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/node_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Node n(
  int num, {
  String name = '',
  DateTime? heard,
  bool fav = false,
  bool ignored = false,
  bool mqtt = false,
  bool radio = true,
  bool mirror = false,
  int? hops,
  double? snr,
}) => Node(
  num: num,
  userId: '',
  longName: name,
  shortName: '',
  hwModel: 0,
  role: 0,
  isUnmessagable: false,
  hasXeddsaSigned: false,
  lastHeard: heard,
  snr: snr,
  hopsAway: hops,
  viaMqtt: mqtt,
  isFavorite: fav,
  isIgnored: ignored,
  onRadio: radio,
  onMirror: mirror,
);

void main() {
  final now = DateTime(2026, 10, 20, 12);
  List<int> nums(NodeFilter f, List<Node> l, {int? me}) =>
      f.apply(l, me: me, now: now).map((e) => e.num).toList();

  test('своя нода и избранные сверху, затем по свежести', () {
    final l = [
      n(1, heard: now.subtract(const Duration(hours: 2))),
      n(2, heard: now),
      n(3, fav: true),
      n(4),
    ];
    expect(nums(const NodeFilter(onlineHours: null), l, me: 4), [4, 3, 2, 1]);
  });

  test('игнорируемые скрыты по умолчанию', () {
    final l = [n(1), n(2, ignored: true)];
    const all = NodeFilter(onlineHours: null);
    expect(nums(all, l), [1]);
    expect(nums(const NodeFilter(onlineHours: null, showIgnored: true), l), [
      1,
      2,
    ]);
  });

  test('онлайн за N часов, хопы, MQTT, источник, поиск', () {
    final l = [
      n(1, name: 'Alpha', heard: now, hops: 0),
      n(
        2,
        name: 'Beta',
        heard: now.subtract(const Duration(hours: 5)),
        hops: 3,
      ),
      n(3, name: 'Gamma', heard: now, mqtt: true, hops: 1),
      n(4, name: 'Delta', radio: false, mirror: true),
    ];
    expect(nums(const NodeFilter(onlineHours: 1), l), [1, 3]);
    expect(nums(const NodeFilter(onlineHours: null, maxHops: 1), l), [1, 3]);
    expect(nums(const NodeFilter(onlineHours: null, hideMqtt: true), l), [
      1,
      2,
      4,
    ]);
    expect(
      nums(const NodeFilter(onlineHours: null, source: NodeSource.mirror), l),
      [4],
    );
    expect(nums(const NodeFilter(query: 'bet'), l), [2]);
    expect(nums(const NodeFilter(query: '!00000003'), l), [3]);
    // По умолчанию — за сутки: Delta без времени скрыта.
    expect(nums(const NodeFilter(), l), [1, 3, 2]);
    expect(const NodeFilter().active, isFalse);
    expect(const NodeFilter(onlineHours: null).active, isTrue);
  });

  test('сортировка по имени и SNR, null в конце', () {
    final l = [
      n(1, name: 'b', snr: -5),
      n(2, name: 'A'),
      n(3, name: 'c', snr: 4),
    ];
    const f = NodeFilter(onlineHours: null);
    expect(nums(f.copyWith(sort: NodeSort.name), l), [2, 1, 3]);
    expect(nums(f.copyWith(sort: NodeSort.snr), l), [3, 1, 2]);
  });

  test('дальние ноды скрываются, без координат и своя — остаются', () {
    Node at(int num, double lat, double lon) =>
        n(num).copyWith(latitude: Value(lat), longitude: Value(lon));
    final l = [
      at(1, 59.94, 30.31), // Петербург
      at(2, 55.75, 37.62), // Москва
      n(3),
      at(4, 55.75, 37.62),
    ];
    const area = (center: (lat: 59.9, lon: 30.3), km: 100.0);
    expect(
      const NodeFilter(
        onlineHours: null,
      ).apply(l, me: 4, area: area).map((e) => e.num),
      [4, 1, 3],
    );
  });
}
