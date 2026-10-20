import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';

/// Рингтон RTTTL внешних уведомлений (как в Android): хранится в ноде
/// отдельно от ModuleConfig, читается get_ringtone_request, пишется
/// set_ringtone_message. Ответ ноды PacketRouter кладёт в БД под [key].
abstract final class Ringtone {
  static const key = 'ringtone';
  static const maxLength = 230;
  static const label = 'Рингтон';
  static const help =
      'Язык передачи рингтона (RTTTL) - строка рингтона, используемая '
      'поддерживаемыми зуммерами во внешних уведомлениях.';
  static const tooLong = 'Не длиннее $maxLength символов';

  static String? check(String s) => s.length > maxLength ? tooLong : null;

  static String decode(List<int> data) =>
      utf8.decode(data, allowMalformed: true);

  /// Попросить ноду прислать рингтон.
  static Future<bool> request(AdminSettings admin) =>
      admin.send(AdminMessage(getRingtoneRequest: true), response: true);

  /// Записать рингтон; после ACK — в БД.
  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    String s,
  ) async {
    if (check(s) != null) throw ArgumentError(tooLong);
    final ok = await admin.send(AdminMessage(setRingtoneMessage: s));
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
