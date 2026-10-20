import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Модуль «Удаленное оборудование»: в iOS экрана нет — поля и подписи из
/// Android (RemoteHardwareConfigItemList.kt, ru).
abstract final class RemoteHardwareSection {
  static const title = 'Удаленное устройство';
  static const saveConfirm = 'Сохранить настройки удаленного оборудования?';
  static const group = 'Настройка удаленного оборудования';

  /// Типы пинов — имена перечисления, как в Android.
  static final types = <Choice>[
    for (final t in RemoteHardwarePinType.values)
      (value: t.value, label: t.name),
  ];

  static List<FieldSpec<Object?>> fields() => [
    const BoolFieldSpec(
      'enabled',
      'Удаленное оборудование включено',
      group: group,
    ),
    const BoolFieldSpec(
      'allowUndefinedPinAccess',
      'Разрешить неопределённый контакт',
      group: group,
    ),
    PinListFieldSpec(
      'availablePins',
      'Доступные контакты',
      group: group,
      // available_pins max_count:4, name max_size:15 (Android).
      maxCount: 4,
      nameMaxBytes: 14,
      types: types,
    ),
  ];

  static Map<String, Object?> read(ModuleConfig_RemoteHardwareConfig c) => {
    'enabled': c.enabled,
    'allowUndefinedPinAccess': c.allowUndefinedPinAccess,
    'availablePins': RemotePins([
      for (final p in c.availablePins)
        (gpio: p.gpioPin, name: p.name, type: p.type.value),
    ]),
  };

  static ModuleConfig_RemoteHardwareConfig apply(
    ModuleConfig_RemoteHardwareConfig base,
    Map<String, Object?> v,
  ) {
    final c = base.deepCopy()
      ..enabled = v['enabled']! as bool
      ..allowUndefinedPinAccess = v['allowUndefinedPinAccess']! as bool;
    c.availablePins
      ..clear()
      ..addAll([
        for (final p in (v['availablePins']! as RemotePins).items)
          RemoteHardwarePin(
            gpioPin: p.gpio,
            name: p.name,
            type:
                RemoteHardwarePinType.valueOf(p.type) ??
                RemoteHardwarePinType.UNKNOWN,
          ),
      ]);
    return c;
  }

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_RemoteHardwareConfig base,
    Map<String, Object?> v,
  ) => saveModuleConfig(
    admin,
    db,
    'remoteHardware',
    ModuleConfig(remoteHardware: apply(base, v)),
  );
}
