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
  publicKey('Публичный ключ'),
  hardware('Модель устройства'),
  firmware('Версия прошивки');

  const NodeRowField(this.label);
  final String label;
}

/// Поля, выключенные по умолчанию: добавлены позже, привычный список не меняем.
const optInRowFields = {NodeRowField.hardware, NodeRowField.firmware};

/// Какие поля строки ноды показывать; по умолчанию — все, кроме [optInRowFields].
class NodeLayout {
  const NodeLayout([this.hidden = optInRowFields]);

  final Set<NodeRowField> hidden;

  bool shows(NodeRowField f) => !hidden.contains(f);

  NodeLayout toggle(NodeRowField f, bool on) =>
      NodeLayout(on ? ({...hidden}..remove(f)) : {...hidden, f});

  /// Скрытые — по имени; включённые поля из [optInRowFields] — «+имя».
  String encode() => encodeStringList([
    for (final f in NodeRowField.values)
      if (optInRowFields.contains(f))
        if (shows(f)) '+${f.name}' else ...[]
      else if (!shows(f))
        f.name,
  ]);

  /// Неизвестные имена пропускаются; пусто или битое — по умолчанию.
  static NodeLayout decode(String? s) {
    final names = decodeStringList(s).toSet();
    return NodeLayout({
      for (final f in NodeRowField.values)
        if (optInRowFields.contains(f)
            ? !names.contains('+${f.name}')
            : names.contains(f.name))
          f,
    });
  }
}
