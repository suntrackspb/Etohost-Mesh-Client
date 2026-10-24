import 'dart:convert';

import '../core/geo/geo.dart';
import '../core/proto/mesh.dart';
import 'database.dart';
import 'jammer_zones.dart';
import 'node_position.dart';

enum NodeSort { lastHeard, name, snr, hops }

enum NodeSource { all, radio, mirror }

/// Роли в фильтре — в порядке таблицы Roles официальной документации
/// (meshtastic.org/docs/configuration/radio/device): CLIENT, CLIENT_MUTE,
/// CLIENT_HIDDEN, CLIENT_BASE, TRACKER, LOST_AND_FOUND, SENSOR, TAK,
/// TAK_TRACKER, REPEATER, ROUTER, ROUTER_LATE.
const filterRoles = [0, 1, 8, 12, 5, 9, 6, 7, 10, 4, 2, 11];

/// ROUTER_CLIENT: в документации нет (устарела в 2.3.15) — в фильтре
/// только если такие ноды есть.
const legacyFilterRoles = [3];

/// Роли для чипов фильтра: документированные, затем устаревшие из [present].
List<int> roleChoices(Set<int> present) => [
  ...filterRoles,
  for (final r in legacyFilterRoles)
    if (present.contains(r)) r,
];

/// Варианты «слышали за…» в часах; null — за всё время.
const onlineHoursOptions = <int?>[1, 2, 24, 168, null];

/// По умолчанию — за сутки.
const defaultOnlineHours = 24;

/// Область из настроек приложения: ноды дальше [km] от [center] скрываются.
typedef NodeArea = ({LatLon center, double km});

/// Фильтр и сортировка списка нод (как `NodeFilter` в официальном iOS).
/// Избранные всегда сверху; игнорируемые скрыты, пока их не попросили.
class NodeFilter {
  const NodeFilter({
    this.query = '',
    this.source = NodeSource.all,
    this.onlineHours = defaultOnlineHours,
    this.favoritesOnly = false,
    this.hideMqtt = false,
    this.showIgnored = false,
    this.maxHops,
    this.roles = const {},
    this.encryptedOnly = false,
    this.signedOnly = false,
    this.sort = NodeSort.lastHeard,
  });

  final String query;
  final NodeSource source;

  /// Слышали не позже N часов назад; null — без ограничения.
  final int? onlineHours;
  final bool favoritesOnly;
  final bool hideMqtt;
  final bool showIgnored;
  final int? maxHops;

  /// Роли ноды (Config.DeviceConfig.Role); пусто — все.
  final Set<int> roles;

  /// Только с публичным ключом (PKI).
  final bool encryptedOnly;

  /// Только подписывающие пакеты (XEdDSA, прошивка 2.8).
  final bool signedOnly;
  final NodeSort sort;

  /// Включено что-то кроме поиска и сортировки — для значка на кнопке.
  bool get active =>
      source != NodeSource.all ||
      onlineHours != defaultOnlineHours ||
      favoritesOnly ||
      hideMqtt ||
      showIgnored ||
      maxHops != null ||
      roles.isNotEmpty ||
      encryptedOnly ||
      signedOnly;

  NodeFilter copyWith({
    String? query,
    NodeSource? source,
    int? Function()? onlineHours,
    bool? favoritesOnly,
    bool? hideMqtt,
    bool? showIgnored,
    int? Function()? maxHops,
    Set<int>? roles,
    bool? encryptedOnly,
    bool? signedOnly,
    NodeSort? sort,
  }) => NodeFilter(
    query: query ?? this.query,
    source: source ?? this.source,
    onlineHours: onlineHours != null ? onlineHours() : this.onlineHours,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    hideMqtt: hideMqtt ?? this.hideMqtt,
    showIgnored: showIgnored ?? this.showIgnored,
    maxHops: maxHops != null ? maxHops() : this.maxHops,
    roles: roles ?? this.roles,
    encryptedOnly: encryptedOnly ?? this.encryptedOnly,
    signedOnly: signedOnly ?? this.signedOnly,
    sort: sort ?? this.sort,
  );

  /// Для сохранения в настройках; поиск не сохраняется.
  String encode() => jsonEncode({
    'source': source.name,
    'onlineHours': onlineHours,
    'favoritesOnly': favoritesOnly,
    'hideMqtt': hideMqtt,
    'showIgnored': showIgnored,
    'maxHops': maxHops,
    'roles': roles.toList()..sort(),
    'encryptedOnly': encryptedOnly,
    'signedOnly': signedOnly,
    'sort': sort.name,
  });

  /// Битое или пустое значение — фильтр по умолчанию.
  static NodeFilter decode(String? s) {
    if (s == null || s.isEmpty) return const NodeFilter();
    try {
      final j = jsonDecode(s) as Map<String, dynamic>;
      T? pick<T extends Enum>(List<T> all, Object? v) =>
          all.where((e) => e.name == v).firstOrNull;
      return NodeFilter(
        source: pick(NodeSource.values, j['source']) ?? NodeSource.all,
        onlineHours: j.containsKey('onlineHours')
            ? j['onlineHours'] as int?
            : defaultOnlineHours,
        favoritesOnly: j['favoritesOnly'] == true,
        hideMqtt: j['hideMqtt'] == true,
        showIgnored: j['showIgnored'] == true,
        maxHops: j['maxHops'] as int?,
        roles: {
          for (final r in (j['roles'] as List? ?? const []))
            if (r is int) r,
        },
        encryptedOnly: j['encryptedOnly'] == true,
        signedOnly: j['signedOnly'] == true,
        sort: pick(NodeSort.values, j['sort']) ?? NodeSort.lastHeard,
      );
    } catch (_) {
      return const NodeFilter();
    }
  }

  bool matches(Node n, DateTime now) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty &&
        !n.longName.toLowerCase().contains(q) &&
        !n.shortName.toLowerCase().contains(q) &&
        !nodeIdString(n.num).contains(q)) {
      return false;
    }
    if (source == NodeSource.radio && !n.onRadio) return false;
    if (source == NodeSource.mirror && !n.onMirror) return false;
    if (onlineHours != null &&
        (n.lastHeard == null ||
            now.difference(n.lastHeard!) > Duration(hours: onlineHours!))) {
      return false;
    }
    if (favoritesOnly && !n.isFavorite) return false;
    if (hideMqtt && n.viaMqtt) return false;
    if (!showIgnored && n.isIgnored) return false;
    if (maxHops != null && (n.hopsAway == null || n.hopsAway! > maxHops!)) {
      return false;
    }
    if (roles.isNotEmpty && !roles.contains(n.role)) {
      return false;
    }
    if (encryptedOnly && (n.publicKey?.isEmpty ?? true)) return false;
    if (signedOnly && !n.hasXeddsaSigned) return false;
    return true;
  }

  /// Отфильтровать и отсортировать; [me] (своя нода) всегда первой.
  /// [area] — скрыть ноды дальше радиуса; ноды без координат остаются
  /// (на 2.8 позиция по умолчанию выключена).
  List<Node> apply(
    List<Node> all, {
    int? me,
    DateTime? now,
    NodeArea? area,
    bool correction = false,
    JammerZones zones = JammerZones.none,
  }) {
    final t = now ?? DateTime.now();
    final out = all
        .where(
          (n) =>
              n.num == me ||
              (matches(n, t) && _inArea(n, area, correction, zones)),
        )
        .toList();
    int cmp(Node a, Node b) {
      if ((a.num == me) != (b.num == me)) return a.num == me ? -1 : 1;
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
      return switch (sort) {
        NodeSort.lastHeard => _desc(a.lastHeard, b.lastHeard),
        NodeSort.name => _name(a).compareTo(_name(b)),
        NodeSort.snr => _desc(a.snr, b.snr),
        NodeSort.hops => _asc(a.hopsAway, b.hopsAway),
      };
    }

    return out..sort(cmp);
  }

  /// Без координат — не отсекаем (положение неизвестно).
  static bool _inArea(Node n, NodeArea? a, bool correction, JammerZones zones) {
    if (a == null) return true;
    final p = nodePosition(n, correction: correction, zones: zones);
    return p == null || distanceKm(a.center, (lat: p.lat, lon: p.lon)) <= a.km;
  }

  static String _name(Node n) =>
      (n.longName.isEmpty ? nodeIdString(n.num) : n.longName).toLowerCase();

  /// Больше — выше, null в конце.
  static int _desc<T extends Comparable<Object>>(T? a, T? b) =>
      a == null ? (b == null ? 0 : 1) : (b == null ? -1 : b.compareTo(a));

  /// Меньше — выше, null в конце.
  static int _asc<T extends Comparable<Object>>(T? a, T? b) =>
      a == null ? (b == null ? 0 : 1) : (b == null ? -1 : a.compareTo(b));
}
