import '../core/proto/mesh.dart';
import 'database.dart';

enum NodeSort { lastHeard, name, snr, hops }

enum NodeSource { all, radio, mirror }

/// Фильтр и сортировка списка нод (как `NodeFilter` в официальном iOS).
/// Избранные всегда сверху; игнорируемые скрыты, пока их не попросили.
class NodeFilter {
  const NodeFilter({
    this.query = '',
    this.source = NodeSource.all,
    this.onlineHours,
    this.favoritesOnly = false,
    this.hideMqtt = false,
    this.showIgnored = false,
    this.maxHops,
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
  final NodeSort sort;

  /// Включено что-то кроме поиска и сортировки — для значка на кнопке.
  bool get active =>
      source != NodeSource.all ||
      onlineHours != null ||
      favoritesOnly ||
      hideMqtt ||
      showIgnored ||
      maxHops != null;

  NodeFilter copyWith({
    String? query,
    NodeSource? source,
    int? Function()? onlineHours,
    bool? favoritesOnly,
    bool? hideMqtt,
    bool? showIgnored,
    int? Function()? maxHops,
    NodeSort? sort,
  }) => NodeFilter(
    query: query ?? this.query,
    source: source ?? this.source,
    onlineHours: onlineHours != null ? onlineHours() : this.onlineHours,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    hideMqtt: hideMqtt ?? this.hideMqtt,
    showIgnored: showIgnored ?? this.showIgnored,
    maxHops: maxHops != null ? maxHops() : this.maxHops,
    sort: sort ?? this.sort,
  );

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
    return true;
  }

  /// Отфильтровать и отсортировать; [me] (своя нода) всегда первой.
  List<Node> apply(List<Node> all, {int? me, DateTime? now}) {
    final t = now ?? DateTime.now();
    final out = all.where((n) => n.num == me || matches(n, t)).toList();
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

  static String _name(Node n) =>
      (n.longName.isEmpty ? nodeIdString(n.num) : n.longName).toLowerCase();

  /// Больше — выше, null в конце.
  static int _desc<T extends Comparable<Object>>(T? a, T? b) =>
      a == null ? (b == null ? 0 : 1) : (b == null ? -1 : b.compareTo(a));

  /// Меньше — выше, null в конце.
  static int _asc<T extends Comparable<Object>>(T? a, T? b) =>
      a == null ? (b == null ? 0 : 1) : (b == null ? -1 : a.compareTo(b));
}
