import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/diagnostics/device_model.dart';
import '../core/diagnostics/report_uploader.dart';
import '../core/proto/mesh.dart';
import '../data/diagnostics/report.dart';
import '../mirror/mirror_capabilities.dart';
import 'providers.dart';

/// Сервер отчётов, который указало подключённое зеркало; null — зеркала
/// нет или оно отчётов не объявило.
final reportsCapabilityProvider = Provider<ReportsCapability?>(
  (ref) => ref.watch(mirrorCapabilitiesProvider).value?.reports,
);

/// Отправка отчётов; null — отправлять некуда.
final reportUploaderProvider = Provider<ReportUploader?>((ref) {
  final cap = ref.watch(reportsCapabilityProvider);
  return cap == null ? null : ReportUploader(cap.baseUrl, cap.apiKey);
});

/// Собрать отчёт: сведения из системы, соединения и базы + файл журнала.
Future<DiagnosticReport> collectReport(Ref ref) async {
  final db = ref.read(databaseProvider);
  final radio = ref.read(radioProvider);
  final pkg = await PackageInfo.fromPlatform();

  final me = radio.myNodeNum;
  final my = await (db.select(
    db.myNode,
  )..where((m) => m.id.equals(0))).getSingleOrNull();
  final node = me == null
      ? null
      : await (db.select(
          db.nodes,
        )..where((n) => n.num.equals(me))).getSingleOrNull();
  final blobs = {
    for (final r in await db.select(db.configBlobs).get()) r.key: r.data,
  };
  Config? config(String name) {
    final b = blobs['config.$name'];
    return b == null ? null : Config.fromBuffer(b);
  }

  final nodes = await db.select(db.nodes).get();
  final channels = await db.select(db.channels).get();
  final mirror = ref.read(mirrorConfigProvider).value;

  return DiagnosticReport(
    info: {
      'app': {
        'name': pkg.appName,
        'version': pkg.version,
        'build': pkg.buildNumber,
      },
      'system': {
        'platform': Platform.operatingSystem,
        'osVersion': Platform.operatingSystemVersion,
        'device': await deviceModel(),
        'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
        'utcOffset': utcOffset(DateTime.now().timeZoneOffset),
      },
      'radio': {
        'state': radio.state.name,
        'target': radio.target?.title,
        'attempts': radio.attempts,
        'disconnects': radio.disconnects,
        'connectedSince': radio.connectedSince?.toIso8601String(),
        'mirror': mirror?.active ?? false,
      },
      'node': nodeInfoSection(
        myNodeNum: me ?? my?.myNodeNum,
        hwModel: node?.hwModel,
        firmware: my?.firmwareVersion,
        role: config('device')?.device.role.value ?? node?.role,
        rebootCount: my?.rebootCount,
        lora: config('lora')?.lora,
        nodesKnown: nodes.length,
        nodesOnRadio: nodes.where((n) => n.onRadio).length,
        channels: channels.where((c) => c.role != 0).length,
      ),
    },
    log: DiagnosticReport.tail(await ref.read(journalFileProvider).readAll()),
  );
}

enum ReportStage { collecting, ready, sending, sent, failed }

/// Ход отправки отчёта (экран «Отправить отчёт»).
class ReportFlow extends ChangeNotifier {
  ReportFlow(this._collect, this._uploader);

  final Future<DiagnosticReport> Function() _collect;
  final ReportUploader? _uploader;

  ReportStage stage = ReportStage.collecting;
  DiagnosticReport? report;
  String? reportId;
  String? error;

  bool get canSend =>
      _uploader != null &&
      report != null &&
      (stage == ReportStage.ready || stage == ReportStage.failed);

  Future<void> collect() async {
    _go(ReportStage.collecting);
    try {
      report = await _collect();
      _go(ReportStage.ready);
    } catch (e) {
      error = 'не удалось собрать отчёт: $e';
      _go(ReportStage.failed);
    }
  }

  Future<void> send({String comment = '', String contact = ''}) async {
    final r = report, up = _uploader;
    if (r == null || up == null) return;
    error = null;
    _go(ReportStage.sending);
    try {
      reportId = await up.send(
        info: r.toJson(),
        log: r.log,
        comment: comment.trim(),
        contact: contact.trim(),
      );
      _go(ReportStage.sent);
    } catch (e) {
      error = '$e';
      _go(ReportStage.failed);
    }
  }

  void _go(ReportStage s) {
    stage = s;
    notifyListeners();
  }
}

final reportFlowProvider = ChangeNotifierProvider.autoDispose<ReportFlow>(
  (ref) =>
      ReportFlow(() => collectReport(ref), ref.read(reportUploaderProvider))
        ..collect(),
);
