/// Каналы уведомлений Android: их можно выключить прямо из шторки или
/// системных настроек приложения. На iOS, macOS, Windows и Linux каналов
/// нет — там это ни на что не влияет. Подписи — из Meshtastic-Android (ru),
/// где у Android такого нет — свои.
enum NotifyGroup {
  messages('group_messages', 'Сообщения'),
  mesh('group_mesh', 'Меш');

  const NotifyGroup(this.id, this.name);

  final String id;
  final String name;
}

enum NotifyChannel {
  direct(
    'direct_messages',
    'Уведомления о личных сообщениях',
    'Сообщения, отправленные тебе напрямую.',
    NotifyGroup.messages,
  ),
  replies(
    'replies_mentions',
    'Ответы и упоминания',
    'Ответы на твои сообщения и упоминания в каналах.',
    NotifyGroup.messages,
  ),
  reactions(
    'reactions',
    'Уведомления о реакциях',
    'Реакции на твои сообщения.',
    NotifyGroup.messages,
  ),
  traceroutes(
    'traceroutes',
    'Трассировки',
    'Ответы на отправленные трассировки.',
    NotifyGroup.mesh,
  );

  const NotifyChannel(this.id, this.name, this.description, this.group);

  final String id;
  final String name;
  final String description;
  final NotifyGroup group;

  /// Прежний общий канал — удаляется, чтобы не висел пустым.
  static const legacyId = 'messages';
}
