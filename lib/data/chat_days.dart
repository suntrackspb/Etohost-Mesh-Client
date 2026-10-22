import 'database.dart';

/// Сообщение [i] ленты (от новых к старым) — первое за свой день:
/// над ним нужна плашка с датой.
bool startsDay(List<Message> newestFirst, int i) {
  if (i == newestFirst.length - 1) return true;
  return !sameDay(newestFirst[i].rxTime, newestFirst[i + 1].rxTime);
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const _months = [
  'янв.',
  'февр.',
  'марта',
  'апр.',
  'мая',
  'июня',
  'июля',
  'авг.',
  'сент.',
  'окт.',
  'нояб.',
  'дек.',
];

/// «Сегодня», «Вчера», «20 окт.», в другом году — «20 окт. 2025».
String dayLabel(DateTime d, DateTime now) {
  if (sameDay(d, now)) return 'Сегодня';
  if (sameDay(d, DateTime(now.year, now.month, now.day - 1))) return 'Вчера';
  final s = '${d.day} ${_months[d.month - 1]}';
  return d.year == now.year ? s : '$s ${d.year}';
}
