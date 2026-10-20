import 'package:drift/drift.dart';

import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Раздел «Пользователь»: UserConfig.swift (iOS) + UserConfigItemList.kt
/// (Android: ID ноды, модель, сообщение статуса). Режим лицензированного
/// оператора (ham) пока не перенесён.
abstract final class UserSection {
  static const title = 'Настройки пользователя';
  static const header = 'Сведения о пользователе';
  static const saveConfirm = 'Сохранить конфигурацию пользователя в %s?';
  static const rebootNote = 'После сохранения значений нода перезагрузится.';

  /// Начиная с 2.8 нода хранит длинное имя в 24 байтах (NodeInfoLite).
  static int longNameBytes(String firmware) =>
      firmwareAtLeast(firmware, 2, 8) ? 24 : 39;

  /// Сообщение статуса (Android): прошивка от 2.7.20, если нода прислала
  /// этот модуль и не исключила его в metadata.
  static const statusMessageBytes = 80;

  static List<FieldSpec<Object?>> fields(
    String firmware, {
    bool statusMessage = false,
  }) {
    final long = longNameBytes(firmware);
    return [
      TextFieldSpec(
        'longName',
        'Длинное имя',
        help: 'Long Name can be up to $long bytes long.',
        maxBytes: long,
      ),
      const TextFieldSpec(
        'shortName',
        'Короткое имя',
        help:
            'Последние 4 символа MAC-адреса устройства будут добавлены к '
            'короткому имени для установки имени BLE устройства. Короткое имя '
            'может быть длиной до 4 байт.',
        maxBytes: 4,
      ),
      const BoolFieldSpec(
        'isUnmessagable',
        'Невозможно отправить сообщение',
        help:
            'Используется для идентификации неотслеживаемых или '
            'инфраструктурных нод, чтобы обмен сообщениями был недоступен для '
            'нод, которые никогда не ответят.',
      ),
      if (statusMessage)
        const TextFieldSpec(
          'statusMessage',
          'Состояние сообщения',
          help:
              'Публичное сообщение о статусе, которое отправляется в сеть при '
              'изменении и каждые 12 часов.',
          maxBytes: statusMessageBytes,
        ),
    ];
  }

  static Map<String, Object?> read(Node me, {String? statusMessage}) => {
    'longName': me.longName,
    'shortName': me.shortName,
    'isUnmessagable': me.isUnmessagable,
    'statusMessage': ?statusMessage,
  };

  /// Поддерживает ли нода сообщение статуса.
  static bool supportsStatusMessage(
    String firmware,
    DeviceMetadata? meta,
    bool haveConfig,
  ) {
    final p = firmware.split('.');
    final patch = int.tryParse(p.length > 2 ? p[2] : '') ?? 0;
    final version =
        firmwareAtLeast(firmware, 2, 8) ||
        (firmwareAtLeast(firmware, 2, 7) && patch >= 20);
    final excluded =
        meta != null &&
        meta.excludedModules & ExcludedModules.STATUSMESSAGE_CONFIG.value != 0;
    return version && haveConfig && !excluded;
  }

  /// set_owner своей ноде (и сообщение статуса, если менялось — как в Android:
  /// отправляется только изменённая часть); при подтверждении — обновить БД.
  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    int me,
    Map<String, Object?> v, {
    Map<String, Object?> initial = const {},
  }) async {
    if (v.containsKey('statusMessage') &&
        v['statusMessage'] != initial['statusMessage']) {
      final ok = await admin.send(
        AdminMessage(
          setModuleConfig: ModuleConfig(
            statusmessage: ModuleConfig_StatusMessageConfig(
              nodeStatus: v['statusMessage']! as String,
            ),
          ),
        ),
      );
      if (!ok) return false;
      final userChanged = [
        'longName',
        'shortName',
        'isUnmessagable',
      ].any((k) => v[k] != initial[k]);
      if (initial.isNotEmpty && !userChanged) return true;
    }
    final ok = await admin.send(
      AdminMessage(
        setOwner: User(
          longName: v['longName']! as String,
          shortName: v['shortName']! as String,
          isUnmessagable: v['isUnmessagable']! as bool,
        ),
      ),
    );
    if (ok) {
      await (db.update(db.nodes)..where((n) => n.num.equals(me))).write(
        NodesCompanion(
          longName: Value(v['longName']! as String),
          shortName: Value(v['shortName']! as String),
          isUnmessagable: Value(v['isUnmessagable']! as bool),
        ),
      );
    }
    return ok;
  }
}

/// Версия прошивки «2.7.23.d8f59ce» не ниже major.minor.
bool firmwareAtLeast(String version, int major, int minor, [int patch = 0]) {
  final p = version.split('.');
  final a = int.tryParse(p.isNotEmpty ? p[0] : '') ?? 0;
  final b = int.tryParse(p.length > 1 ? p[1] : '') ?? 0;
  final c = int.tryParse(p.length > 2 ? p[2] : '') ?? 0;
  return a > major || (a == major && (b > minor || (b == minor && c >= patch)));
}
