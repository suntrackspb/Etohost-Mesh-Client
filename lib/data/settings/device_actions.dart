import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';

/// Админ-команды своей ноде: перезагрузка, выключение, сбросы
/// (DeviceConfig.swift + Connect.swift, iOS; AdministrationScreen, Android).
enum DeviceAction {
  reboot,
  shutdown,
  nodeDbReset,
  factoryResetConfig,
  factoryResetDevice,
}

abstract final class DeviceActions {
  /// Задержка перед перезагрузкой / выключением, как в iOS.
  static const delaySeconds = 5;

  static AdminMessage message(
    DeviceAction a, {
    bool preserveFavorites = true,
  }) => switch (a) {
    DeviceAction.reboot => AdminMessage(rebootSeconds: delaySeconds),
    DeviceAction.shutdown => AdminMessage(shutdownSeconds: delaySeconds),
    DeviceAction.nodeDbReset => AdminMessage(nodedbReset: preserveFavorites),
    DeviceAction.factoryResetConfig => AdminMessage(
      factoryResetConfig: delaySeconds,
    ),
    DeviceAction.factoryResetDevice => AdminMessage(
      factoryResetDevice: delaySeconds,
    ),
  };

  static bool isReset(DeviceAction a) =>
      a == DeviceAction.nodeDbReset ||
      a == DeviceAction.factoryResetConfig ||
      a == DeviceAction.factoryResetDevice;

  /// Роли, у которых прошивка всегда сохраняет избранное при сбросе NodeDB.
  static bool keepsFavorites(int role) =>
      role == Config_DeviceConfig_Role.CLIENT_BASE.value ||
      role == Config_DeviceConfig_Role.ROUTER.value ||
      role == Config_DeviceConfig_Role.ROUTER_LATE.value;

  /// Отправить команду. При сбросах прошивка сразу выключает Bluetooth и
  /// подтверждение может не дойти — как iOS и Android, не ждём его и
  /// чистим свою БД (иначе она расходится с нодой).
  static Future<bool> run(
    AdminSettings admin,
    AppDatabase db,
    int me,
    DeviceAction a, {
    bool preserveFavorites = true,
    int role = 0,
  }) async {
    final ok = await admin.send(
      message(a, preserveFavorites: preserveFavorites),
    );
    if (!isReset(a)) return ok;
    await db.resetRadioNodes(
      me,
      keepFavorites:
          a == DeviceAction.nodeDbReset &&
          (preserveFavorites || keepsFavorites(role)),
    );
    if (a != DeviceAction.nodeDbReset) await db.clearDeviceConfig();
    return true;
  }
}
