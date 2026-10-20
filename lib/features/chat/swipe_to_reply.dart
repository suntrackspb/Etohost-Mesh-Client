import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Свайп сообщения влево — ответ (как в Telegram). Жест вправо не
/// перехватываем: он остаётся свайпу «назад» между экранами.
class SwipeToReply extends StatefulWidget {
  const SwipeToReply({super.key, required this.onReply, required this.child});

  /// null — ответ недоступен, жест выключен.
  final VoidCallback? onReply;
  final Widget child;

  static const threshold = 64.0;
  static const maxShift = 96.0;

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  late final AnimationController _back = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  )..addListener(() => setState(() => _shift = _from * (1 - _back.value)));
  double _shift = 0, _from = 0;
  bool _armed = false;

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails d) {
    _back.stop();
    setState(() {
      _shift = (_shift - d.delta.dx).clamp(0.0, SwipeToReply.maxShift);
    });
    final armed = _shift >= SwipeToReply.threshold;
    if (armed && !_armed) HapticFeedback.lightImpact();
    _armed = armed;
  }

  void _end([DragEndDetails? _]) {
    if (_armed) widget.onReply?.call();
    _armed = false;
    _from = _shift;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onReply == null) return widget.child;
    final p = math.min(_shift / SwipeToReply.threshold, 1.0);
    return RawGestureDetector(
      gestures: {
        _LeftDragRecognizer:
            GestureRecognizerFactoryWithHandlers<_LeftDragRecognizer>(
              _LeftDragRecognizer.new,
              (r) => r
                ..onUpdate = _update
                ..onEnd = _end
                ..onCancel = _end,
            ),
      },
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          if (_shift > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Opacity(
                opacity: p,
                child: Transform.scale(
                  scale: 0.6 + 0.4 * p,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.reply, size: 18),
                  ),
                ),
              ),
            ),
          Transform.translate(offset: Offset(-_shift, 0), child: widget.child),
        ],
      ),
    );
  }
}

/// Горизонтальный drag, который сразу отказывается от движения вправо —
/// чтобы не отнимать жест у свайпа «назад».
class _LeftDragRecognizer extends HorizontalDragGestureRecognizer {
  _LeftDragRecognizer() : super(debugOwner: null);

  final _start = <int, Offset>{};

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _start[event.pointer] = event.position;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    final s = _start[event.pointer];
    if (s != null && event is PointerMoveEvent) {
      final d = event.position - s;
      if (d.distance > kTouchSlop / 2) {
        _start.remove(event.pointer);
        if (d.dx > 0 || d.dy.abs() > d.dx.abs()) {
          resolvePointer(event.pointer, GestureDisposition.rejected);
          stopTrackingPointer(event.pointer);
          return;
        }
      }
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _start.remove(event.pointer);
    }
    super.handleEvent(event);
  }
}
