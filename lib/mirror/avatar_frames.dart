import 'dart:ui';

import 'mirror_models.dart';

/// Анимация кольца рамки.
enum FrameAnimation { none, rotate, pulse }

/// Как оформить аватар ноды: кольцо и бейдж. Общий вид для рамки
/// за болтливость и рамки из админки зеркала.
class AvatarDecor {
  const AvatarDecor({
    required this.colors,
    this.angle = 90,
    this.width = 2,
    this.animation = FrameAnimation.none,
    this.badge,
    this.badgeBg = _dark,
    this.badgeFg = const Color(0xFFFFD700),
    this.badgeBorder = const Color(0xFFFFD700),
    this.tooltip,
  });

  /// Один цвет — сплошное кольцо, два — градиент под углом [angle].
  final List<Color> colors;

  /// Угол градиента в градусах, как в CSS (90 — слева направо).
  final double angle;

  /// Толщина кольца в точках при аватаре 32.
  final double width;
  final FrameAnimation animation;
  final String? badge;
  final Color badgeBg;
  final Color badgeFg;
  final Color badgeBorder;
  final String? tooltip;

  @override
  bool operator ==(Object other) =>
      other is AvatarDecor &&
      _listEq(other.colors, colors) &&
      other.angle == angle &&
      other.width == width &&
      other.animation == animation &&
      other.badge == badge &&
      other.badgeBg == badgeBg &&
      other.badgeFg == badgeFg &&
      other.badgeBorder == badgeBorder &&
      other.tooltip == tooltip;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(colors),
    angle,
    width,
    animation,
    badge,
    badgeBg,
    badgeFg,
    badgeBorder,
    tooltip,
  );
}

const _dark = Color(0xFF14171C);

bool _listEq(List<Color> a, List<Color> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Место в топ-3 болтливых за [days] дней.
typedef ChattyRank = ({int rank, int days});

/// Рамка из админки зеркала (`avatar_frames`).
class CustomFrame {
  const CustomFrame({
    required this.color1,
    this.color2,
    this.gradient = false,
    this.angle = 90,
    this.width = 2,
    this.animation = FrameAnimation.none,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
    this.tooltip,
  });

  final Color color1;
  final Color? color2;
  final bool gradient;
  final double angle;
  final double width;
  final FrameAnimation animation;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final String? tooltip;

  static CustomFrame? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final c1 = parseCssColor(raw['color1']);
    if (c1 == null) return null;
    final badge = '${raw['badge_text'] ?? ''}'.trim();
    final tip = '${raw['tooltip_text'] ?? ''}'.trim();
    return CustomFrame(
      color1: c1,
      color2: parseCssColor(raw['color2']),
      gradient: raw['style'] == 'gradient',
      angle: (raw['gradient_angle'] as num?)?.toDouble() ?? 90,
      width: (raw['border_width'] as num?)?.toDouble() ?? 2,
      animation: switch (raw['animation']) {
        'rotate' => FrameAnimation.rotate,
        'pulse' => FrameAnimation.pulse,
        _ => FrameAnimation.none,
      },
      badge: badge.isEmpty ? null : badge,
      badgeColor: parseCssColor(raw['badge_color']),
      badgeTextColor: parseCssColor(raw['badge_text_color']),
      tooltip: tip.isEmpty ? null : tip,
    );
  }

  AvatarDecor get decor {
    final fg = badgeTextColor ?? color1;
    return AvatarDecor(
      colors: [color1, if (gradient && color2 != null) color2!],
      angle: angle,
      width: width,
      animation: animation,
      badge: badge,
      badgeBg: badgeColor ?? _dark,
      badgeFg: fg,
      badgeBorder: fg,
      tooltip: tooltip,
    );
  }
}

/// Оформление аватаров из зеркала: топ болтливых и рамки из админки.
class AvatarFrames {
  const AvatarFrames({this.ranks = const {}, this.custom = const {}});

  static const empty = AvatarFrames();

  final Map<int, ChattyRank> ranks;
  final Map<int, CustomFrame> custom;

  AvatarFrames copyWith({
    Map<int, ChattyRank>? ranks,
    Map<int, CustomFrame>? custom,
  }) => AvatarFrames(ranks: ranks ?? this.ranks, custom: custom ?? this.custom);

  /// Рамка из админки важнее места в топе — как на сайте зеркала.
  AvatarDecor? decorFor(int nodeNum) {
    final c = custom[nodeNum];
    if (c != null) return c.decor;
    final r = ranks[nodeNum];
    return r == null ? null : rankDecor(r);
  }
}

/// Кольцо и бейдж за место в топе: золото, серебро, бронза; на бейдже —
/// период в днях.
AvatarDecor? rankDecor(ChattyRank r) {
  final (ring, fg) = switch (r.rank) {
    1 => (const Color(0xFFFFD700), const Color(0xFFFFD700)),
    2 => (const Color(0xFFC0C0C0), const Color(0xFFD9D9D9)),
    3 => (const Color(0xFFCD7F32), const Color(0xFFE0995E)),
    _ => (null, null),
  };
  if (ring == null) return null;
  return AvatarDecor(
    colors: [ring],
    badge: '${r.days}',
    badgeFg: fg!,
    badgeBorder: r.rank == 3 ? ring : fg,
    tooltip: 'Топ-${r.rank} болтливых за ${r.days} дн.',
  );
}

/// `{"!a1b2c3d4": {"rank": 1, "days": 30}}`; непонятное пропускаем.
Map<int, ChattyRank> parseChattyRanks(Object? raw) => {
  if (raw is Map)
    for (final e in raw.entries)
      if (nodeNumFromId('${e.key}') case final num?)
        if (e.value case {'rank': final int rank, 'days': final int days})
          num: (rank: rank, days: days),
};

/// `{"!a1b2c3d4": {...рамка...}}`; непонятное пропускаем.
Map<int, CustomFrame> parseCustomFrames(Object? raw) => {
  if (raw is Map)
    for (final e in raw.entries)
      ?nodeNumFromId('${e.key}'): ?CustomFrame.tryParse(e.value),
};

/// `#rgb`, `#rrggbb`, `#rrggbbaa`; иначе null.
Color? parseCssColor(Object? raw) {
  if (raw is! String) return null;
  var s = raw.trim();
  if (!s.startsWith('#')) return null;
  s = s.substring(1);
  if (s.length == 3) s = s.split('').map((c) => '$c$c').join();
  if (s.length == 8) s = s.substring(6) + s.substring(0, 6);
  if (s.length == 6) s = 'ff$s';
  if (s.length != 8) return null;
  final v = int.tryParse(s, radix: 16);
  return v == null ? null : Color(v);
}
