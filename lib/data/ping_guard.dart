/// Пинги и тесты в основном канале: принято отправлять их в сервисный
/// канал, где отвечают боты. Перехватываем, только если всё сообщение —
/// команда; «я вчера отправил пинг» уходит как обычно.
abstract final class PingGuard {
  static const _commands = {'ping', 'пинг', 'test', 'тест'};

  /// Имя сервисного канала (ключ чата — имя в нижнем регистре).
  static const servicesKey = 'services';

  /// Всё сообщение — пинг: без регистра, пробелов и знаков («/Ping!»).
  static bool isPing(String text) => _commands.contains(
    text.toLowerCase().replaceAll(RegExp(r'[^a-zа-яё]'), ''),
  );

  /// Спросить перед отправкой: основной канал и сообщение-пинг.
  static bool shouldAsk(String text, {required bool primary}) =>
      primary && isPing(text);
}
