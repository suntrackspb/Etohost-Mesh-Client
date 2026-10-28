import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mirror/avatar_frames.dart';

/// Кольцо с бейджем вокруг [child] (круглый аватар размером [size]).
/// Кольцо и бейдж выходят за край аватара; место в раскладке под ними
/// оставляется только снизу.
/// Без [decor] — просто [child].
class FramedAvatar extends StatelessWidget {
  const FramedAvatar({
    super.key,
    required this.child,
    required this.size,
    this.decor,
  });

  final Widget child;
  final double size;
  final AvatarDecor? decor;

  /// Толщины в [AvatarDecor] заданы для аватара 32 (как на сайте зеркала).
  static const _base = 32.0;
  static const _gapColor = Color(0xFF14171C);

  @override
  Widget build(BuildContext context) {
    final d = decor;
    if (d == null) return child;
    final k = size / _base;
    final gap = 1.5 * k;
    final ring = d.width * k;
    final outer = gap + ring;
    Widget ringWidget = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: d.colors.length == 1 ? d.colors.first : null,
        gradient: d.colors.length > 1 ? _gradient(d) : null,
      ),
    );
    if (d.animation != FrameAnimation.none) {
      ringWidget = _AnimatedRing(animation: d.animation, child: ringWidget);
    }
    Widget out = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -outer,
            top: -outer,
            right: -outer,
            bottom: -outer,
            child: ringWidget,
          ),
          Positioned(
            left: -gap,
            top: -gap,
            right: -gap,
            bottom: -gap,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gapColor,
              ),
            ),
          ),
          Positioned.fill(child: child),
          if (d.badge != null)
            Positioned(
              right: -3 * k,
              bottom: -5 * k,
              child: _Badge(decor: d, k: k),
            ),
        ],
      ),
    );
    // Снизу рамка и бейдж занимают место: соседи (пузырь в чате)
    // выравниваются по их низу, а не по низу аватара.
    final below = math.max(outer, d.badge != null ? 5 * k : 0.0);
    out = Padding(
      padding: EdgeInsets.only(bottom: below),
      child: out,
    );
    if (d.tooltip != null) out = Tooltip(message: d.tooltip!, child: out);
    return out;
  }

  /// CSS `linear-gradient(<angle>deg, …)`: 0° — снизу вверх, 90° — слева
  /// направо.
  static LinearGradient _gradient(AvatarDecor d) {
    final a = d.angle * math.pi / 180;
    final x = math.sin(a), y = -math.cos(a);
    return LinearGradient(
      begin: Alignment(-x, -y),
      end: Alignment(x, y),
      colors: d.colors,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.decor, required this.k});

  final AvatarDecor decor;
  final double k;

  @override
  Widget build(BuildContext context) {
    final text = decor.badge!;
    final h = 15 * k;
    return Container(
      constraints: BoxConstraints(minWidth: h, maxWidth: 60 * k),
      height: h,
      padding: EdgeInsets.symmetric(horizontal: text.length > 2 ? 3 * k : 0),
      decoration: BoxDecoration(
        color: decor.badgeBg,
        borderRadius: BorderRadius.circular(text.length > 2 ? 6 * k : h / 2),
        border: Border.all(color: decor.badgeBorder, width: 1.5 * k),
        boxShadow: [
          BoxShadow(color: FramedAvatar._gapColor, spreadRadius: 1.5 * k),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 3 * k,
            offset: Offset(0, k),
          ),
        ],
      ),
      // Ширина по тексту: без widthFactor Center растянул бы бейдж
      // на всю свободную ширину.
      child: Center(
        widthFactor: 1,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            color: decor.badgeFg,
            fontSize: 7.5 * k,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Вращение (3 с на оборот) или пульсация (1,6 с) кольца — как на сайте.
class _AnimatedRing extends StatefulWidget {
  const _AnimatedRing({required this.animation, required this.child});

  final FrameAnimation animation;
  final Widget child;

  @override
  State<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.animation == FrameAnimation.rotate
        ? const Duration(seconds: 3)
        : const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    // Тесты и «Уменьшение движения» — без бесконечной анимации.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
      _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) {
      if (widget.animation == FrameAnimation.rotate) {
        return Transform.rotate(angle: _c.value * 2 * math.pi, child: child);
      }
      // 0 → 1 → 0 по синусу: масштаб 1 → 1.12, прозрачность 1 → 0.6.
      final t = (1 - math.cos(_c.value * 2 * math.pi)) / 2;
      return Opacity(
        opacity: 1 - 0.4 * t,
        child: Transform.scale(scale: 1 + 0.12 * t, child: child),
      );
    },
  );
}
