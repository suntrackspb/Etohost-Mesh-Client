import '../../core/proto/generated/meshtastic/atak.pbenum.dart';
import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Модуль TAK: TAKModuleConfig.swift (iOS), те же поля в Android (его
/// локальный TAK-сервер — функция приложения, не ноды). Подписи — iOS ru,
/// иначе английские (в Android ru «Командой» — ошибка перевода);
/// варианты — английские, как в iOS.
abstract final class TakSection {
  static const title = 'Настройка TAK';
  static const saveConfirm = 'Сохранить настройки TAK?';
  static const group = 'Identity';
  static const footer =
      'These values are included in TAK position reports. Leaving either at '
      'its default lets the firmware choose Cyan and Team Member.';
  static const roleWarning =
      'These settings only apply when the device role is TAK or TAK Tracker.';

  static const teams = <Choice>[
    (value: 0, label: 'Default (Cyan)'),
    (value: 1, label: 'White'),
    (value: 2, label: 'Yellow'),
    (value: 3, label: 'Orange'),
    (value: 4, label: 'Magenta'),
    (value: 5, label: 'Red'),
    (value: 6, label: 'Maroon'),
    (value: 7, label: 'Purple'),
    (value: 8, label: 'Dark Blue'),
    (value: 9, label: 'Blue'),
    (value: 10, label: 'Cyan'),
    (value: 11, label: 'Teal'),
    (value: 12, label: 'Green'),
    (value: 13, label: 'Dark Green'),
    (value: 14, label: 'Brown'),
  ];

  static const roles = <Choice>[
    (value: 0, label: 'Default (Team Member)'),
    (value: 1, label: 'Team Member'),
    (value: 2, label: 'Team Lead'),
    (value: 3, label: 'HQ'),
    (value: 4, label: 'Sniper'),
    (value: 5, label: 'Medic'),
    (value: 6, label: 'Forward Observer'),
    (value: 7, label: 'RTO'),
    (value: 8, label: 'K9'),
  ];

  /// Настройки действуют только в ролях TAK и TAK Tracker (iOS).
  static bool appliesTo(int deviceRole) =>
      deviceRole == Config_DeviceConfig_Role.TAK.value ||
      deviceRole == Config_DeviceConfig_Role.TAK_TRACKER.value;

  static List<FieldSpec<Object?>> fields() => const [
    ChoiceFieldSpec('team', 'Team', teams, group: group, help: footer),
    ChoiceFieldSpec('role', 'Роль', roles, group: group),
  ];

  static Map<String, Object?> read(ModuleConfig_TAKConfig c) => {
    'team': c.team.value,
    'role': c.role.value,
  };

  static ModuleConfig_TAKConfig apply(
    ModuleConfig_TAKConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..team = Team.valueOf(v['team']! as int) ?? base.team
    ..role = MemberRole.valueOf(v['role']! as int) ?? base.role;

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_TAKConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(admin, db, 'tak', ModuleConfig(tak: apply(base, v)));
}
