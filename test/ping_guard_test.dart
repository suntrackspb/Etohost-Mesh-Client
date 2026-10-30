import 'package:meshex/data/ping_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('пинг — только всё сообщение целиком', () {
    for (final t in [
      'ping',
      ' Ping ',
      '/ping',
      'PING!',
      'пинг',
      'Пинг?',
      'test',
      'тест.',
      '/test',
    ]) {
      expect(PingGuard.isPing(t), isTrue, reason: t);
    }
    for (final t in [
      'я вчера отправил пинг',
      'ping me',
      'пинги',
      'testing',
      '',
      '🙂',
    ]) {
      expect(PingGuard.isPing(t), isFalse, reason: t);
    }
  });

  test('спрашиваем только в основном канале', () {
    expect(PingGuard.shouldAsk('ping', primary: true), isTrue);
    expect(PingGuard.shouldAsk('ping', primary: false), isFalse);
    expect(PingGuard.shouldAsk('привет', primary: true), isFalse);
  });
}
