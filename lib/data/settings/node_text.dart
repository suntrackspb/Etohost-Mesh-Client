import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';

/// Текстовая настройка, которую нода хранит отдельно от ModuleConfig и
/// пишет/читает своими админ-командами (рингтон, заготовленные сообщения).
/// Ответ ноды PacketRouter кладёт в БД под [key].
class NodeText {
  const NodeText({
    required this.key,
    required this.label,
    required this.help,
    required this.max,
    required this.request,
    required this.set,
    this.bytes = false,
  });

  final String key;
  final String label;
  final String help;

  /// Предел длины: символов или байт UTF-8 ([bytes]).
  final int max;
  final bool bytes;
  final AdminMessage Function() request;
  final AdminMessage Function(String s) set;

  int lengthOf(String s) => bytes ? utf8.encode(s).length : s.length;

  String? check(String s) => lengthOf(s) > max
      ? 'Не длиннее $max ${bytes ? 'байт' : 'символов'}'
      : null;

  static String decode(List<int> data) =>
      utf8.decode(data, allowMalformed: true);

  /// Попросить ноду прислать значение.
  Future<bool> fetch(AdminSettings admin) =>
      admin.send(request(), response: true);

  /// Записать значение; после ACK — в БД.
  Future<bool> save(AdminSettings admin, AppDatabase db, String s) async {
    final err = check(s);
    if (err != null) throw ArgumentError(err);
    final ok = await admin.send(set(s));
    if (ok) {
      await db
          .into(db.configBlobs)
          .insertOnConflictUpdate(
            ConfigBlobsCompanion.insert(
              key: key,
              data: Uint8List.fromList(utf8.encode(s)),
              updated: DateTime.now(),
            ),
          );
    }
    return ok;
  }
}

/// Рингтон RTTTL внешних уведомлений (как в Android).
final ringtone = NodeText(
  key: 'ringtone',
  label: 'Рингтон',
  help:
      'Язык передачи рингтона (RTTTL) - строка рингтона, используемая '
      'поддерживаемыми зуммерами во внешних уведомлениях.',
  max: 230,
  request: () => AdminMessage(getRingtoneRequest: true),
  set: (s) => AdminMessage(setRingtoneMessage: s),
);

/// Заготовленные сообщения через «|» (iOS: не больше 200 байт).
final cannedMessages = NodeText(
  key: 'cannedMessages',
  label: 'Сообщения',
  help: 'Сообщения разделяются |',
  max: 200,
  bytes: true,
  request: () => AdminMessage(getCannedMessageModuleMessagesRequest: true),
  set: (s) => AdminMessage(setCannedMessageModuleMessages: s),
);
