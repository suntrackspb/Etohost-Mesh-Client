import 'dart:convert';

import 'package:etohost_mesh/core/notices/notices.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 25, 12);

  List<Notice> parse(List<Object?> raw) => parseNotices(jsonEncode(raw));

  test('разбор: битые пропускаются, ссылка только https', () {
    final list = parse([
      {
        'id': 'a',
        'level': 'critical',
        'text': ' Срочно ',
        'link': {'url': 'https://etohost.ru', 'label': 'Сайт'},
      },
      {
        'id': 'b',
        'text': 'x',
        'level': 'panic',
        'link': {'url': 'http://x'},
      },
      {'id': '', 'text': 'нет id'},
      {'id': 'c'},
      'мусор',
    ]);
    expect(list.map((n) => n.id), ['a', 'b']);
    expect(list[0].level, NoticeLevel.critical);
    expect(list[0].text, 'Срочно');
    expect(list[0].linkUrl.toString(), 'https://etohost.ru');
    expect(list[1].level, NoticeLevel.info);
    expect(list[1].linkUrl, isNull);
  });

  bool applies(Map<String, Object?> raw, {String version = '0.1.10'}) =>
      noticeApplies(
        Notice.tryParse({'id': 'a', 'text': 'x', ...raw})!,
        version: version,
        platform: 'ios',
        now: now,
      );

  test('версии включительно, платформа, срок', () {
    expect(applies({}), isTrue);
    expect(applies({'min_version': '0.1.10', 'max_version': '0.1.10'}), isTrue);
    expect(applies({'min_version': '0.1.11'}), isFalse);
    expect(applies({'max_version': '0.1.9'}), isFalse);
    expect(
      applies({
        'platforms': ['android'],
      }),
      isFalse,
    );
    expect(
      applies({
        'platforms': ['ios', 'android'],
      }),
      isTrue,
    );
    expect(applies({'expires': '2026-10-25T12:00:00Z'}), isFalse);
    expect(applies({'expires': '2026-10-26T00:00:00Z'}), isTrue);
  });

  test('показ: без закрытых, важные сверху', () {
    final list = parse([
      {'id': 'i', 'text': 'x'},
      {'id': 'c', 'text': 'x', 'level': 'critical'},
      {'id': 'w', 'text': 'x', 'level': 'warning'},
    ]);
    final v = visibleNotices(
      list,
      version: '0.1.10',
      platform: 'ios',
      now: now,
      dismissed: {'w'},
    );
    expect(v.map((n) => n.id), ['c', 'i']);
  });

  test('проверка не чаще интервала', () {
    expect(noticesDue(null, now), isTrue);
    expect(noticesDue(now.subtract(const Duration(minutes: 9)), now), isFalse);
    expect(noticesDue(now.subtract(noticesInterval), now), isTrue);
  });
}
