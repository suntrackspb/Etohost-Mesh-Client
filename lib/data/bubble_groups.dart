import 'database.dart';

/// Место сообщения в серии подряд идущих от одного автора: у серии одна
/// подпись и один аватар, пузыри стоят плотно, внутренние углы острые.
enum BubblePos {
  single,
  first,
  middle,
  last;

  /// Верх пузыря примыкает к предыдущему.
  bool get joinedAbove => this == middle || this == last;

  /// Низ пузыря примыкает к следующему.
  bool get joinedBelow => this == first || this == middle;
}

/// Сообщения дальше этого — уже новая серия.
const bubbleGroupGap = Duration(minutes: 5);

/// Одна серия: тот же автор (своё — со своим), тот же день, пауза не
/// больше [bubbleGroupGap].
bool sameBubbleGroup(Message a, Message b) {
  if (a.isOutgoing != b.isOutgoing) return false;
  if (!a.isOutgoing && a.fromNum != b.fromNum) return false;
  final ta = a.rxTime, tb = b.rxTime;
  if (ta.year != tb.year || ta.month != tb.month || ta.day != tb.day) {
    return false;
  }
  return ta.difference(tb).abs() <= bubbleGroupGap;
}

/// Позиции для ленты, отсортированной от новых к старым (как в чате).
List<BubblePos> bubblePositions(List<Message> newestFirst) {
  final n = newestFirst.length;
  return [
    for (var i = 0; i < n; i++)
      () {
        final above =
            i + 1 < n && sameBubbleGroup(newestFirst[i], newestFirst[i + 1]);
        final below =
            i > 0 && sameBubbleGroup(newestFirst[i], newestFirst[i - 1]);
        return above
            ? (below ? BubblePos.middle : BubblePos.last)
            : (below ? BubblePos.first : BubblePos.single);
      }(),
  ];
}
