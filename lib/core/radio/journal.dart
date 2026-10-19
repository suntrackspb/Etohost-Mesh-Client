import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../proto/mesh.dart';

enum JournalKind { app, radio, node }

class JournalLine {
  JournalLine(this.time, this.kind, this.text);
  final DateTime time;
  final JournalKind kind;
  final String text;
}

/// Кольцевой журнал событий соединения, пакетов и лога ноды (экран «Журнал»).
class Journal extends ChangeNotifier {
  static const maxLines = 5000;

  final _lines = <JournalLine>[];
  List<JournalLine> get lines => List.unmodifiable(_lines);

  void add(JournalKind kind, String text) {
    _lines.add(JournalLine(DateTime.now(), kind, text));
    if (_lines.length > maxLines) {
      _lines.removeRange(0, _lines.length - maxLines);
    }
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}

/// Короткое описание FromRadio для журнала.
String describeFromRadio(FromRadio f) {
  switch (f.whichPayloadVariant()) {
    case FromRadio_PayloadVariant.packet:
      return describePacket(f.packet);
    case FromRadio_PayloadVariant.myInfo:
      return 'моя нода ${nodeIdString(f.myInfo.myNodeNum)}';
    case FromRadio_PayloadVariant.nodeInfo:
      final n = f.nodeInfo;
      return '${nodeIdString(n.num)} ${n.user.longName} (${n.user.shortName})';
    case FromRadio_PayloadVariant.config:
      return 'config ${f.config.whichPayloadVariant().name}';
    case FromRadio_PayloadVariant.moduleConfig:
      return 'module config ${f.moduleConfig.whichPayloadVariant().name}';
    case FromRadio_PayloadVariant.channel:
      final c = f.channel;
      return 'канал ${c.index} ${c.role.name} «${c.settings.name}»';
    case FromRadio_PayloadVariant.configCompleteId:
      return 'конфигурация получена (id ${f.configCompleteId})';
    case FromRadio_PayloadVariant.rebooted:
      return 'нода перезагрузилась';
    case FromRadio_PayloadVariant.queueStatus:
      return 'очередь: свободно ${f.queueStatus.free}/${f.queueStatus.maxlen}';
    case FromRadio_PayloadVariant.metadata:
      return 'прошивка ${f.metadata.firmwareVersion}';
    case FromRadio_PayloadVariant.mqttClientProxyMessage:
      return 'MQTT proxy ${f.mqttClientProxyMessage.topic}';
    case FromRadio_PayloadVariant.fileInfo:
      return 'файл ${f.fileInfo.fileName} (${f.fileInfo.sizeBytes} байт)';
    case FromRadio_PayloadVariant.clientNotification:
      return 'уведомление: ${f.clientNotification.message}';
    case FromRadio_PayloadVariant.deviceuiConfig:
      return 'настройки экрана (deviceUIConfig)';
    case FromRadio_PayloadVariant.logRecord:
      return describeLogRecord(f.logRecord);
    default:
      return 'FromRadio ${f.whichPayloadVariant().name}';
  }
}

String describePacket(MeshPacket p) {
  final to = p.to == broadcastNum ? '^all' : nodeIdString(p.to);
  final b = StringBuffer('${nodeIdString(p.from)} → $to');
  if (p.hasDecoded()) {
    final port = p.decoded.portnum;
    b.write(' ${port.name}');
    if (port == PortNum.TEXT_MESSAGE_APP) {
      b.write(': ${utf8.decode(p.decoded.payload, allowMalformed: true)}');
    }
  } else if (p.hasEncrypted()) {
    b.write(' (зашифровано)');
  }
  if (p.rxRssi != 0) b.write(' rssi ${p.rxRssi}');
  if (p.viaMqtt) b.write(' via MQTT');
  return b.toString();
}

String describeLogRecord(LogRecord r) {
  final lvl = r.level == LogRecord_Level.UNSET ? '' : '${r.level.name} ';
  final src = r.source.isEmpty ? '' : '[${r.source}] ';
  return '$lvl$src${r.message.trimRight()}';
}
