import 'dart:convert';

import '../../core/proto/mesh.dart';

/// Отчёт для разработчика: сведения о системе, приложении и ноде + журнал.
/// Чего здесь нет (и в журнале файлов тоже): текст сообщений, координаты,
/// ключи и PSK, названия каналов, адрес зеркала.
class DiagnosticReport {
  DiagnosticReport({required this.info, required this.log});

  /// Разделы → поля (ключи — для сервера, подписи — [labels]).
  final Map<String, Map<String, Object?>> info;
  final String log;

  /// Не больше [maxLogBytes] с конца: старое отрезается.
  static const maxLogBytes = 2 * 1024 * 1024;

  static String tail(String log) {
    final b = utf8.encode(log);
    if (b.length <= maxLogBytes) return log;
    final cut = utf8.decode(
      b.sublist(b.length - maxLogBytes),
      allowMalformed: true,
    );
    final nl = cut.indexOf('\n');
    return nl < 0 ? cut : cut.substring(nl + 1);
  }

  int get logLines => log.isEmpty ? 0 : '\n'.allMatches(log).length;

  Map<String, Object?> toJson() => info;

  /// Человекочитаемый вид для предпросмотра.
  String describe() {
    final b = StringBuffer();
    for (final MapEntry(key: section, value: fields) in info.entries) {
      b.writeln(labels[section] ?? section);
      for (final MapEntry(:key, :value) in fields.entries) {
        if (value == null) continue;
        b.writeln('  ${labels[key] ?? key}: $value');
      }
    }
    return b.toString().trimRight();
  }

  static const labels = {
    'app': 'Приложение',
    'system': 'Система',
    'radio': 'Соединение',
    'node': 'Своя нода',
    'name': 'Название',
    'version': 'Версия',
    'build': 'Сборка',
    'platform': 'Платформа',
    'osVersion': 'Версия ОС',
    'device': 'Устройство',
    'locale': 'Язык',
    'utcOffset': 'Часовой пояс',
    'state': 'Состояние',
    'target': 'Подключение',
    'attempts': 'Попыток',
    'disconnects': 'Разрывов',
    'connectedSince': 'Подключено с',
    'mirror': 'Зеркало',
    'id': 'ID',
    'hwModel': 'Модель',
    'firmware': 'Прошивка',
    'role': 'Роль',
    'region': 'Регион',
    'modemPreset': 'Пресет',
    'rebootCount': 'Перезагрузок',
    'nodesKnown': 'Нод в базе',
    'nodesOnRadio': 'Нод в эфире',
    'channels': 'Каналов',
  };
}

/// Раздел «Своя нода» из того, что лежит в базе.
Map<String, Object?> nodeInfoSection({
  required int? myNodeNum,
  int? hwModel,
  String? firmware,
  int? role,
  int? rebootCount,
  Config_LoRaConfig? lora,
  int? nodesKnown,
  int? nodesOnRadio,
  int? channels,
}) => {
  'id': myNodeNum == null ? null : nodeIdString(myNodeNum),
  'hwModel': hwModel == null
      ? null
      : HardwareModel.valueOf(hwModel)?.name ?? '$hwModel',
  'firmware': (firmware?.isEmpty ?? true) ? null : firmware,
  'role': role == null
      ? null
      : Config_DeviceConfig_Role.valueOf(role)?.name ?? '$role',
  'region': lora?.region.name,
  'modemPreset': lora == null
      ? null
      : lora.usePreset
      ? lora.modemPreset.name
      : 'custom (bw ${lora.bandwidth}, sf ${lora.spreadFactor}, '
            'cr ${lora.codingRate})',
  'rebootCount': rebootCount,
  'nodesKnown': nodesKnown,
  'nodesOnRadio': nodesOnRadio,
  'channels': channels,
};

/// Смещение пояса: «UTC+3», «UTC-5:30».
String utcOffset(Duration d) {
  final sign = d.isNegative ? '-' : '+';
  final h = d.inHours.abs(), m = d.inMinutes.abs() % 60;
  return 'UTC$sign$h${m == 0 ? '' : ':${m.toString().padLeft(2, '0')}'}';
}
