import 'database.dart';

/// Сколько сообщений ленты догружать при входе, чтобы дойти до первого
/// непрочитанного; дальше — открываем на самом старом из загруженных.
const maxUnreadLoad = 500;

/// Лимит ленты при входе: [unread] непрочитанных должны поместиться
/// (с запасом на реакции и контекст), но не больше [maxUnreadLoad].
int feedLimitForUnread(int current, int unread) {
  final need = (unread + 50).clamp(0, maxUnreadLoad);
  return need > current ? need : current;
}

/// Индекс самого старого непрочитанного входящего в [feed] (свежие первыми)
/// — над ним разделитель «Новые сообщения». null — непрочитанных нет или
/// переписку ещё не открывали ([mark] == null: не считаем всю историю новой).
int? firstUnreadIndex(List<Message> feed, DateTime? mark) {
  if (mark == null) return null;
  int? found;
  for (var i = 0; i < feed.length; i++) {
    final m = feed[i];
    if (!m.rxTime.isAfter(mark)) break;
    if (!m.isOutgoing) found = i;
  }
  return found;
}

/// До какого времени прочитано, если на экране самое свежее — [newestSeen]
/// (индекс в [feed], свежие первыми): самое свежее входящее не новее его.
DateTime? readUpTo(List<Message> feed, int newestSeen) {
  for (var i = newestSeen.clamp(0, feed.length); i < feed.length; i++) {
    if (!feed[i].isOutgoing) return feed[i].rxTime;
  }
  return null;
}

/// Отметка «прочитано» только двигается вперёд.
DateTime? advanceMark(DateTime? current, DateTime? seen) {
  if (seen == null) return current;
  if (current == null || seen.isAfter(current)) return seen;
  return current;
}
