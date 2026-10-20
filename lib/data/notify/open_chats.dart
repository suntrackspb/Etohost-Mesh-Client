/// Какие ленты сейчас открыты (на широком экране может быть несколько
/// экземпляров одной). Уведомления о них не показываем, пока приложение
/// на экране.
class OpenChats {
  final _count = <String, int>{};

  void open(String id) => _count[id] = (_count[id] ?? 0) + 1;

  void close(String id) {
    final n = (_count[id] ?? 0) - 1;
    if (n <= 0) {
      _count.remove(id);
    } else {
      _count[id] = n;
    }
  }

  bool isOpen(String id) => _count.containsKey(id);
}
