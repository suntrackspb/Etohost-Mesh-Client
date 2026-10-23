import 'message_filter.dart';

/// Поля строки в списке нод, которые можно скрыть (Node Layout в Android).
enum NodeRowField {
  id('Идентификатор'),
  role('Роль устройства'),
  preset('Пресет'),
  lastHeard('Время последнего вещания'),
  hops('Прыжков'),
  position('Позиция'),
  signal('Сигнал'),
  mqtt('MQTT'),
  publicKey('Публичный ключ');

  const NodeRowField(this.label);
  final String label;
}

/// Какие поля строки ноды показывать; по умолчанию — все.
class NodeLayout {
  const NodeLayout([this.hidden = const {}]);

  final Set<NodeRowField> hidden;

  bool shows(NodeRowField f) => !hidden.contains(f);

  NodeLayout toggle(NodeRowField f, bool on) =>
      NodeLayout(on ? ({...hidden}..remove(f)) : {...hidden, f});

  String encode() => encodeStringList([
    for (final f in NodeRowField.values)
      if (!shows(f)) f.name,
  ]);

  /// Неизвестные имена пропускаются; пусто или битое — всё видно.
  static NodeLayout decode(String? s) => NodeLayout({
    for (final n in decodeStringList(s))
      for (final f in NodeRowField.values)
        if (f.name == n) f,
  });
}
