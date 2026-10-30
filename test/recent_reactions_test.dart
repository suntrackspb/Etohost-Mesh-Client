import 'package:meshex/data/recent_reactions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('без недавних — набор по умолчанию', () {
    expect(quickReactions(const []), defaultReactions);
  });

  test('недавние первыми, остальное добирается по умолчанию', () {
    expect(quickReactions(['🍺', '👍']).take(4), ['🍺', '👍', '❤️', '😂']);
    expect(quickReactions(['🍺', '👍']), hasLength(quickReactionCount));
  });

  test('поставленный поднимается наверх без повторов, лимит', () {
    final r = useReaction(['1', '2', '3', '4', '5', '6'], '4', max: 6);
    expect(r, ['4', '1', '2', '3', '5', '6']);
    expect(useReaction(r, '🔥', max: 6), ['🔥', '4', '1', '2', '3', '5']);
  });

  test('parse терпит мусор', () {
    expect(parseRecentReactions(null), isEmpty);
    expect(parseRecentReactions('oops'), isEmpty);
    expect(parseRecentReactions('["🔥", 1, ""]'), ['🔥']);
    expect(parseRecentReactions(encodeRecentReactions(['🔥'])), ['🔥']);
  });
}
