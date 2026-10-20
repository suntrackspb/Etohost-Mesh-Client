import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'intervals.dart';
import 'user_section.dart' show firmwareAtLeast;

/// Модуль «MQTT»: MQTTConfig.swift (iOS). Подписи — iOS ru, затем Android ru.
/// json_enabled не показывается (устарел) и сохраняется как есть.
/// Подбор ближних тем по геокодированию из iOS пока не перенесён.
abstract final class MqttSection {
  static const title = 'Настройка MQTT';
  static const saveConfirm = 'Сохранить настройки MQTT?';
  static const groupOptions = 'Параметры';
  static const groupMap = 'Отчет карты';
  static const groupRoot = 'Основная тема';
  static const groupServer = 'Сервер';

  static const publicServer = 'mqtt.meshtastic.org';
  static const publicUser = 'meshdev';
  static const publicPassword = 'large4cats';

  static const channelsNote =
      'Для всей функциональности MQTT, кроме отчета карты, вы также должны '
      'настроить восходящую и нисходящую связь для каждого канала, который '
      'хотите мостить через MQTT.';
  static const proxyNote =
      'Etohost Mesh пока не умеет быть MQTT-прокси: при включённом '
      'клиент-прокси нода не выйдет в MQTT через это приложение.';

  static String dutyCycleWarning(int percent) =>
      'В вашем регионе действует режим работы $percent%. Не рекомендуется '
      'использовать MQTT, если у вас ограничен режим работы, так как '
      'дополнительный трафик быстро перегрузит вашу сеть LoRa.';

  /// Совпадение хоста, не подстроки: `mqtt.meshtastic.org.example.com` — чужой.
  static bool usesPublicServer(String address) =>
      address.trim().toLowerCase().split(':').first == publicServer;

  static bool _public(Map<String, Object?> v) =>
      usesPublicServer(v['address'] as String? ?? '');

  /// С 2.7.4 публичный сервер требует TLS; до этого прошивка отвергает весь
  /// конфиг с TLS на публичном сервере — поэтому там переключатель скрыт.
  static bool tlsRequired(String fw) {
    if (firmwareAtLeast(fw, 2, 8)) return true;
    final p = fw.split('.');
    final patch = int.tryParse(p.length > 2 ? p[2] : '') ?? 0;
    return firmwareAtLeast(fw, 2, 7) && patch >= 4;
  }

  static bool _consented(Map<String, Object?> v) =>
      v['mapReportingEnabled'] == true && v['shouldReportLocation'] == true;

  /// Примерная точность (м) для 12–15 бит, PositionPrecision в iOS.
  static const _precisionMeters = {
    12: 5836.362884000802,
    13: 2918.1758760007315,
    14: 1459.0823719999053,
    15: 729.5356200010741,
  };

  static String precisionLabel(int bits) {
    final m = _precisionMeters[bits];
    if (m == null) return '$bits';
    return m >= 1000
        ? 'В пределах ${(m / 1000).toStringAsFixed(1).replaceAll('.', ',')} км'
        : 'В пределах ${m.round()} м';
  }

  static List<FieldSpec<Object?>> fields({required String firmware}) => [
    const BoolFieldSpec(
      'enabled',
      'MQTT включен',
      group: groupOptions,
      help: 'Включить MQTT-шлюз',
    ),
    const BoolFieldSpec(
      'proxyToClientEnabled',
      'MQTT клиент-прокси',
      group: groupOptions,
      help:
          'Использует сетевое подключение вашего телефона для подключения к MQTT.',
    ),
    const BoolFieldSpec(
      'encryptionEnabled',
      'Шифрование включено',
      group: groupOptions,
      help: 'Отправлять зашифрованные пакеты в MQTT',
    ),
    const BoolFieldSpec(
      'mapReportingEnabled',
      'Публикация на карте',
      group: groupMap,
      help:
          'Ваша нода будет периодически отправлять незашифрованный пакет '
          'местоположения на настроенный сервер MQTT, включающий '
          'идентификатор, короткое и длинное имя, приблизительное '
          'местоположение, модель оборудования, роль, версию встроенного ПО, '
          'регион LoRa, предустановку модема и название основного канала.',
    ),
    BoolFieldSpec(
      'shouldReportLocation',
      'Согласие на передачу незашифрованных данных ноды через MQTT',
      group: groupMap,
      visibleWhen: (v) => v['mapReportingEnabled'] == true,
      help:
          'Включив эту функцию, вы подтверждаете и даете явное согласие на '
          'передачу данных о географическом местоположении вашего устройства '
          'в режиме реального времени по протоколу MQTT без шифрования. Эти '
          'данные о местоположении могут использоваться для таких целей, как '
          'создание отчетов по карте в режиме реального времени, '
          'отслеживание устройства и связанные с этим функции телеметрии.\n\n'
          'Имейте в виду, что поскольку отчет карты не зашифрован, ваши '
          'данные могут быть постоянно сохранены и отображены третьими '
          'сторонами. Meshtastic не несет ответственности за такое хранение, '
          'отображение или раскрытие этих данных.\n\n'
          'Я прочитал и понимаю вышеизложенное. Я добровольно даю согласие на '
          'незашифрованную передачу данных моей ноды через MQTT.',
    ),
    ChoiceFieldSpec(
      'publishIntervalSecs',
      'Интервал публикации на карте',
      Intervals.choices(Intervals.broadcastMedium),
      group: groupMap,
      visibleWhen: _consented,
      unknownLabel: Intervals.label,
    ),
    ChoiceFieldSpec(
      'positionPrecision',
      'Приблизительное местоположение',
      [for (var b = 12; b <= 15; b++) (value: b, label: precisionLabel(b))],
      group: groupMap,
      visibleWhen: _consented,
      help:
          'Для соблюдения законов о конфиденциальности, таких как CCPA и '
          'GDPR, мы избегаем передачи точных данных о местоположении. Вместо '
          'этого мы используем анонимизированную или приблизительную '
          '(неточную) информацию о местоположении для защиты вашей '
          'конфиденциальности.',
    ),
    const TextFieldSpec(
      'root',
      'Основная тема',
      group: groupRoot,
      maxBytes: 31,
      help: 'Корневая тема для использования MQTT.',
    ),
    const TextFieldSpec(
      'address',
      'Адрес',
      group: groupServer,
      maxBytes: 63,
      help: 'Адрес MQTT-сервера',
    ),
    TextFieldSpec(
      'username',
      'Имя пользователя',
      group: groupServer,
      maxBytes: 63,
      visibleWhen: (v) => !_public(v),
    ),
    TextFieldSpec(
      'password',
      'Пароль',
      group: groupServer,
      maxBytes: 31,
      secure: true,
      visibleWhen: (v) => !_public(v),
    ),
    BoolFieldSpec(
      'tlsEnabled',
      'TLS включен',
      group: groupServer,
      visibleWhen: (v) => !_public(v) || tlsRequired(firmware),
      enabledWhen: (v) => !_public(v),
      help: 'TLS is required for the public Meshtastic MQTT server.',
    ),
  ];

  /// Публичный сервер принимает только свои учётные данные.
  static void adjust(Map<String, Object?> v) {
    if (!_public(v)) return;
    v['username'] = publicUser;
    v['password'] = publicPassword;
  }

  static Map<String, Object?> read(ModuleConfig_MQTTConfig c) {
    final m = c.mapReportSettings;
    final precision = m.positionPrecision;
    return {
      'enabled': c.enabled,
      'proxyToClientEnabled': c.proxyToClientEnabled,
      'encryptionEnabled': c.encryptionEnabled,
      'mapReportingEnabled': c.mapReportingEnabled,
      'shouldReportLocation': m.shouldReportLocation,
      // Прошивка требует не чаще раза в час и 12–15 бит (как normalize в iOS).
      'publishIntervalSecs': m.publishIntervalSecs < 3600
          ? 3600
          : m.publishIntervalSecs,
      'positionPrecision': precision < 12 || precision > 15 ? 14 : precision,
      'root': c.root.isEmpty ? 'msh' : c.root,
      'address': c.address,
      'username': c.username,
      'password': c.password,
      'tlsEnabled': c.tlsEnabled,
    };
  }

  /// [firmware] нужна для TLS публичного сервера.
  static ModuleConfig_MQTTConfig apply(
    ModuleConfig_MQTTConfig base,
    Map<String, Object?> v, {
    required String firmware,
  }) {
    final out = base.deepCopy()
      ..enabled = v['enabled']! as bool
      ..proxyToClientEnabled = v['proxyToClientEnabled']! as bool
      ..encryptionEnabled = v['encryptionEnabled']! as bool
      ..mapReportingEnabled = v['mapReportingEnabled']! as bool
      ..root = v['root']! as String
      ..address = v['address']! as String
      ..username = v['username']! as String
      ..password = v['password']! as String
      ..tlsEnabled = v['tlsEnabled']! as bool;
    out.mapReportSettings = out.mapReportSettings.deepCopy()
      ..shouldReportLocation = v['shouldReportLocation']! as bool
      ..publishIntervalSecs = v['publishIntervalSecs']! as int
      ..positionPrecision = v['positionPrecision']! as int;
    if (usesPublicServer(out.address)) {
      out
        ..username = publicUser
        ..password = publicPassword
        ..tlsEnabled = tlsRequired(firmware);
    }
    return out;
  }

  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    ModuleConfig_MQTTConfig base,
    Map<String, Object?> v, {
    required String firmware,
  }) => saveModuleConfig(
    admin,
    db,
    'mqtt',
    ModuleConfig(mqtt: apply(base, v, firmware: firmware)),
  );
}
