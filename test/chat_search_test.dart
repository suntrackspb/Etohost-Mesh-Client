import 'package:etohost_mesh/data/chat_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('без регистра, все слова в любом порядке', () {
    final w = ChatSearch.words('  Нода   СПАТЬ ');
    expect(w, ['нода', 'спать']);
    expect(ChatSearch.matches('Спать пойду, НОДА спит', w), isTrue);
    expect(ChatSearch.matches('нода работает', w), isFalse);
    expect(ChatSearch.matches('что угодно', ChatSearch.words('  ')), isFalse);
  });
}
