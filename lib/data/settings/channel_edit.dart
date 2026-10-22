import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';

/// Редактор канала: Channels.swift + ChannelForm.swift (iOS). Подписи — iOS ru,
/// иначе английские. Поведение полей (размер ключа → новый ключ, точная
/// позиция только с сильным ключом, точность 12–15) — как в iOS.
abstract final class ChannelEdit {
  static const title = 'Каналы';
  static const groupDetails = 'Сведения о канале';
  static const groupPosition = 'Позиция';
  static const groupMqtt = 'MQTT';
  static const maxSlots = 8;
  static const defaultKey = 'AQ==';
  static const badKey = 'Ключ не соответствует выбранному размеру';

  /// Имена каналов модулей: в списке сообщений такие не показываются (iOS).
  static const reservedNames = ['admin', 'gpio', 'serial', 'mqtt'];
  static bool isReserved(String name) =>
      reservedNames.contains(name.toLowerCase());
  static String reservedNote(String name) =>
      '"$name" is a reserved module channel name and will not appear in the '
      'Messages channel list. Pick a different name for a messaging channel.';

  static const keySizes = <Choice>[
    (value: 0, label: 'Пустой'),
    (value: -1, label: 'По умолчанию'),
    (value: 1, label: '1 байт'),
    (value: 16, label: '128 бит'),
    (value: 32, label: '256 бит'),
  ];

  /// Точность позиции → метры (PositionPrecision, iOS).
  static const precisionMeters = <int, double>{
    10: 23345.48,
    11: 11672.74,
    12: 5836.36,
    13: 2918.18,
    14: 1459.08,
    15: 729.54,
    16: 364.76,
    17: 182.38,
    18: 91.18,
    19: 45.59,
    20: 22.79,
  };

  static String precisionLabel(int bits) {
    final m = precisionMeters[bits];
    if (m == null) return '$bits бит';
    final d = m >= 1000
        ? '${(m / 1000).toStringAsFixed(1)} km'
        : '${m.round()} m';
    return 'Within $d';
  }

  // Служебные ключи формы (не поля): прежние значения, чтобы adjust знал,
  // что именно изменилось — как onChange в iOS.
  static const _ks = '_keySize', _pl = '_precise', _pe = '_positions';

  static bool _weakKey(Map<String, Object?> v) =>
      (v['keySize']! as int) <= 1 || v['key'] == defaultKey;

  static bool _primary(Map<String, Object?> v) => v['role'] == 1;

  static List<FieldSpec<Object?>> fields() => [
    TextFieldSpec('name', 'Имя', group: groupDetails, maxBytes: 11),
    const ChoiceFieldSpec(
      'keySize',
      'Размер ключа',
      keySizes,
      group: groupDetails,
      unknownLabel: _bytesLabel,
    ),
    TextFieldSpec(
      'key',
      'Ключ',
      group: groupDetails,
      maxBytes: 44,
      enabledWhen: (v) => (v['keySize']! as int) > 0,
    ),
    ChoiceFieldSpec(
      'role',
      'Роль канала',
      const [(value: 0, label: 'Отключен'), (value: 2, label: 'Второй')],
      group: groupDetails,
      optionsFor: (v) => _primary(v)
          ? const [(value: 1, label: 'Первичный')]
          : const [(value: 0, label: 'Отключен'), (value: 2, label: 'Второй')],
      enabledWhen: (v) => !_primary(v),
    ),
    const BoolFieldSpec(
      'positionsEnabled',
      'Позиции включены',
      group: groupPosition,
      visibleWhen: _primary,
    ),
    BoolFieldSpec(
      'positionsEnabled',
      'Разрешить запрос позиции',
      group: groupPosition,
      visibleWhen: (v) => !_primary(v),
    ),
    BoolFieldSpec(
      'preciseLocation',
      'Точное местоположение',
      group: groupPosition,
      visibleWhen: (v) =>
          v['positionsEnabled'] == true &&
          !_weakKey(v) &&
          (v['role']! as int) > 0,
    ),
    ChoiceFieldSpec(
      'positionPrecision',
      'Приблизительное местоположение',
      [for (var b = 12; b <= 19; b++) (value: b, label: precisionLabel(b))],
      group: groupPosition,
      unknownLabel: precisionLabel,
      visibleWhen: (v) =>
          v['positionsEnabled'] == true && v['preciseLocation'] != true,
    ),
    const BoolFieldSpec(
      'uplink',
      'MQTT Включена восходящая связь',
      group: groupMqtt,
    ),
    const BoolFieldSpec(
      'downlink',
      'MQTT Нисходящая связь включена',
      group: groupMqtt,
    ),
  ];

  static String _bytesLabel(int n) => '$n байт';

  static String generateKey(int size, [Random? rnd]) {
    final r = rnd ?? Random.secure();
    return base64.encode([for (var i = 0; i < size; i++) r.nextInt(256)]);
  }

  static List<int>? _decode(String s) {
    try {
      return base64.decode(s.trim());
    } on FormatException {
      return null;
    }
  }

  static int _sizeOf(List<int> psk) =>
      psk.length == 1 && psk.first == 1 ? -1 : psk.length;

  /// Ключ подходит к размеру (iOS hasValidKey).
  static bool keyValid(Map<String, Object?> v) {
    final size = v['keySize']! as int;
    if (size == -1) return true;
    return _decode(v['key']! as String)?.length == size;
  }

  static String? check(Map<String, Object?> v) => keyValid(v) ? null : badKey;

  static void adjust(Map<String, Object?> v, {Random? rnd}) {
    v['name'] = (v['name']! as String).replaceAll(' ', '');
    final size = v['keySize']! as int;
    if (size != v[_ks]) {
      v['key'] = switch (size) {
        -1 => defaultKey,
        0 => '',
        _ => generateKey(size, rnd),
      };
      v[_ks] = size;
    }
    if (v['positionsEnabled'] != v[_pe]) {
      if (v['positionsEnabled'] == true) {
        if (v['positionPrecision'] == 0) v['positionPrecision'] = 15;
      } else {
        v['positionPrecision'] = 0;
        v['preciseLocation'] = false;
      }
    }
    if (v['preciseLocation'] != v[_pl]) {
      v['positionPrecision'] = v['preciseLocation'] == true ? 32 : 14;
    }
    // Точная позиция — только с сильным ключом.
    if (v['preciseLocation'] == true && _weakKey(v)) {
      v['preciseLocation'] = false;
      v['positionPrecision'] = 14;
    }
    v[_pe] = v['positionsEnabled'];
    v[_pl] = v['preciseLocation'];
  }

  static ChannelSettings settingsOf(MeshChannel c) {
    final raw = c.settings;
    if (raw != null) return ChannelSettings.fromBuffer(raw);
    return ChannelSettings(name: c.name, psk: c.psk ?? const []);
  }

  static Map<String, Object?> read(ChannelSettings s, int role) {
    final psk = s.psk;
    final size = _sizeOf(psk);
    var p = s.moduleSettings.positionPrecision;
    final weak = size <= 1;
    if (weak && p == 32) p = 14;
    final v = <String, Object?>{
      'name': s.name,
      'keySize': size,
      'key': base64.encode(psk),
      'role': role,
      'positionsEnabled': p > 0,
      'preciseLocation': p == 32,
      'positionPrecision': p,
      'uplink': s.uplinkEnabled,
      'downlink': s.downlinkEnabled,
    };
    v[_ks] = size;
    v[_pe] = v['positionsEnabled'];
    v[_pl] = v['preciseLocation'];
    return v;
  }

  /// Новый второй канал (iOS «Добавить канал»): ключ 128 бит, без позиций.
  static Map<String, Object?> fresh([Random? rnd]) {
    final key = generateKey(16, rnd);
    return read(
      ChannelSettings(psk: base64.decode(key)),
      Channel_Role.SECONDARY.value,
    );
  }

  /// Первый свободный индекс второго канала или null (слотов 8).
  static int? nextFreeIndex(Iterable<MeshChannel> channels) {
    final busy = {
      for (final c in channels)
        if (c.role > 0) c.index,
    };
    for (var i = 1; i < maxSlots; i++) {
      if (!busy.contains(i)) return i;
    }
    return null;
  }

  static Channel apply(
    ChannelSettings base,
    int index,
    Map<String, Object?> v,
  ) {
    final p = v['positionsEnabled'] != true
        ? 0
        : v['preciseLocation'] == true
        ? 32
        : v['positionPrecision']! as int;
    final psk = v['keySize'] == -1
        ? [1]
        : _decode(v['key']! as String) ?? const <int>[];
    final s = base.deepCopy()
      ..name = v['name']! as String
      ..psk = Uint8List.fromList(psk)
      ..uplinkEnabled = v['uplink']! as bool
      ..downlinkEnabled = v['downlink']! as bool;
    s.moduleSettings = s.moduleSettings.deepCopy()..positionPrecision = p;
    return Channel(
      index: index,
      role: Channel_Role.valueOf(v['role']! as int) ?? Channel_Role.SECONDARY,
      settings: s,
    );
  }

  /// set_channel; после подтверждения — в свою БД (нода не пришлёт канал
  /// сама до следующего подключения).
  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ChannelSettings base,
    int index,
    Map<String, Object?> v,
  ) async {
    final ch = apply(base, index, v);
    final ok = await admin.send(AdminMessage(setChannel: ch));
    if (ok) await db.upsertChannel(ch);
    return ok;
  }
}
