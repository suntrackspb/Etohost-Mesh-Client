import 'package:flutter/widgets.dart';

/// Прокрутка ленивого списка к элементу [target]: пока элемент не построен,
/// листаем на экран в его сторону (индексы растут вместе со смещением),
/// затем ставим через ensureVisible ([alignment] 0.5 — по центру).
/// [keyOf] — ключ элемента по индексу.
Future<bool> scrollToItem(
  ScrollController c,
  int target,
  int count,
  GlobalKey Function(int i) keyOf, {
  int maxSteps = 200,
  double alignment = 0.5,
  Duration duration = const Duration(milliseconds: 300),
}) async {
  for (var step = 0; step < maxSteps && c.hasClients; step++) {
    final ctx = keyOf(target).currentContext;
    if (ctx != null) {
      if (!ctx.mounted) return false;
      await Scrollable.ensureVisible(
        ctx,
        alignment: alignment,
        duration: duration,
        curve: Curves.easeOut,
      );
      return true;
    }
    int? lo, hi;
    for (var i = 0; i < count; i++) {
      if (keyOf(i).currentContext != null) {
        lo ??= i;
        hi = i;
      }
    }
    final p = c.position;
    final dir = lo == null || target > hi! ? 1 : -1;
    final next = (p.pixels + dir * p.viewportDimension).clamp(
      p.minScrollExtent,
      p.maxScrollExtent,
    );
    if (next == p.pixels) return false;
    c.jumpTo(next);
    await WidgetsBinding.instance.endOfFrame;
  }
  return false;
}
