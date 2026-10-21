import 'database.dart';
import 'message_meta.dart';

/// Реакции одним эмодзи: кто поставил, по одной от каждой ноды.
class ReactionGroup {
  const ReactionGroup(this.emoji, this.items);

  final String emoji;

  /// Реакции в порядке ленты; одна нода — одна запись (первая).
  final List<Message> items;

  int get count => items.length;
}

/// Группирует реакции на сообщение по эмодзи — в порядке первой реакции.
/// Повтор того же эмодзи от той же ноды (переотправка, эфир + зеркало)
/// не считается.
List<ReactionGroup> groupReactions(Iterable<Message> reactions) {
  final sorted = [...reactions]..sort((a, b) => a.rxTime.compareTo(b.rxTime));
  final groups = <String, List<Message>>{};
  for (final r in sorted) {
    final emoji = r.body.trim();
    if (emoji.isEmpty) continue;
    final items = groups[emoji] ??= [];
    if (items.every((m) => m.fromNum != r.fromNum)) items.add(r);
  }
  return [for (final e in groups.entries) ReactionGroup(e.key, e.value)];
}

/// Все реакции подряд (для вкладки «Все»): по времени, без повторов
/// одного эмодзи от одной ноды.
List<Message> allReactions(List<ReactionGroup> groups) =>
    [for (final g in groups) ...g.items]
      ..sort((a, b) => a.rxTime.compareTo(b.rxTime));

/// Откуда пришла реакция, коротко: «RX · 2 хопа», «RX · S -5.5 · R -80»,
/// «NET», «TX» для своей. null — неизвестно.
String? reactionSource(Message m) {
  if (m.isOutgoing) return 'TX';
  if (m.heardOnRadio) {
    final hops = messageHops(m);
    final signal = directSignal(m);
    return [
      'RX',
      if (signal != null) signal else if (hops != null) _hops(hops),
    ].join(' · ');
  }
  if (m.heardOnMirror) return 'NET';
  return null;
}

String _hops(int n) {
  final mod10 = n % 10, mod100 = n % 100;
  final word = mod10 == 1 && mod100 != 11
      ? 'хоп'
      : mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)
      ? 'хопа'
      : 'хопов';
  return '$n $word';
}
