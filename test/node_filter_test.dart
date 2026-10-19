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
    expect(nums(const NodeFilter(), l, me: 4), [4, 3, 2, 1]);
  });

  test('игнорируемые скрыты по умолчанию', () {
    final l = [n(1), n(2, ignored: true)];
    expect(nums(const NodeFilter(), l), [1]);
    expect(nums(const NodeFilter(showIgnored: true), l), [1, 2]);
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
    expect(nums(const NodeFilter(maxHops: 1), l), [1, 3]);
    expect(nums(const NodeFilter(hideMqtt: true), l), [1, 2, 4]);
    expect(nums(const NodeFilter(source: NodeSource.mirror), l), [4]);
    expect(nums(const NodeFilter(query: 'bet'), l), [2]);
    expect(nums(const NodeFilter(query: '!00000003'), l), [3]);
  });

  test('сортировка по имени и SNR, null в конце', () {
    final l = [
      n(1, name: 'b', snr: -5),
      n(2, name: 'A'),
      n(3, name: 'c', snr: 4),
    ];
    expect(nums(const NodeFilter(sort: NodeSort.name), l), [2, 1, 3]);
    expect(nums(const NodeFilter(sort: NodeSort.snr), l), [3, 1, 2]);
  });
}
