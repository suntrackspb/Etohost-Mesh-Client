import 'package:etohost_mesh/data/chat_days.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 22, 4, 50);

  test('подписи дней', () {
    expect(dayLabel(DateTime(2026, 10, 22, 0, 1), now), 'Сегодня');
    expect(dayLabel(DateTime(2026, 10, 21, 23, 59), now), 'Вчера');
    expect(dayLabel(DateTime(2026, 10, 20), now), '20 окт.');
    expect(dayLabel(DateTime(2026, 5, 1), now), '1 мая');
    expect(dayLabel(DateTime(2025, 12, 31), now), '31 дек. 2025');
    // Вчера через границу месяца.
    expect(dayLabel(DateTime(2026, 9, 30), DateTime(2026, 10, 1)), 'Вчера');
  });
}
