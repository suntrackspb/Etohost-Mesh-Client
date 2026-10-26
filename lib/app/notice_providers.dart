import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/client_version.dart';
import '../core/diagnostics/report_uploader.dart';
import '../core/notices/notices.dart';
import '../core/update/update_checker.dart' show downloadsPage;
import '../data/database.dart';
import 'providers.dart';

/// Объявления разработчика с сервиса отчётов. Проверка — при запуске,
/// возврате на экран и подключении к ноде, не чаще [noticesInterval].
/// Ошибки сети молча пропускаем: объявления не главное.
class NoticesController extends Notifier<List<Notice>> {
  DateTime? _last;

  /// Закрытые critical — только до перезапуска.
  final _session = <String>{};

  @override
  List<Notice> build() => const [];

  Future<void> refresh() async {
    const url = ReportUploader.configuredUrl;
    final now = DateTime.now();
    if (url.isEmpty || !noticesDue(_last, now)) return;
    _last = now;
    try {
      state = await fetchNotices(Uri.parse(url), ReportUploader.configuredKey);
    } catch (_) {}
  }

  Future<void> dismiss(Notice n) async {
    if (n.level == NoticeLevel.critical) {
      _session.add(n.id);
      state = [...state];
      return;
    }
    final db = ref.read(databaseProvider);
    final ids = {
      ..._decode(await db.getSetting(AppSettingKeys.noticesDismissed)),
      n.id,
    };
    await db.setSetting(AppSettingKeys.noticesDismissed, jsonEncode([...ids]));
  }

  Set<String> get sessionDismissed => _session;
}

Set<String> _decode(String? v) {
  try {
    return {...(jsonDecode(v ?? '[]') as List).whereType<String>()};
  } catch (_) {
    return {};
  }
}

final noticesProvider = NotifierProvider<NoticesController, List<Notice>>(
  NoticesController.new,
);

final _noticesDismissedProvider = StreamProvider<Set<String>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchSetting(AppSettingKeys.noticesDismissed)
      .map(_decode),
);

/// Сервер отказал этой версии (426) — своя красная плашка, сверху.
final outdatedNoticeProvider = Provider<Notice?>((ref) {
  void update() => ref.invalidateSelf();
  outdatedMessage.addListener(update);
  ref.onDispose(() => outdatedMessage.removeListener(update));
  final text = outdatedMessage.value;
  return text == null
      ? null
      : Notice(
          id: 'outdated',
          text: text,
          level: NoticeLevel.critical,
          linkUrl: downloadsPage,
          linkLabel: 'Скачать',
        );
});

/// Объявления для показа в этой сборке.
final visibleNoticesProvider = Provider<List<Notice>>((ref) {
  final outdated = ref.watch(outdatedNoticeProvider);
  final shown = ref.watch(_visibleServerNoticesProvider);
  final hidden = ref.read(noticesProvider.notifier).sessionDismissed;
  return [
    if (outdated != null && !hidden.contains(outdated.id)) outdated,
    ...shown,
  ];
});

final _visibleServerNoticesProvider = Provider<List<Notice>>((ref) {
  final all = ref.watch(noticesProvider);
  final version = ref.watch(appVersionProvider).value;
  if (all.isEmpty || version == null) return const [];
  return visibleNotices(
    all,
    version: version,
    platform: Platform.operatingSystem,
    now: DateTime.now(),
    dismissed: {
      ...?ref.watch(_noticesDismissedProvider).value,
      ...ref.read(noticesProvider.notifier).sessionDismissed,
    },
  );
});

/// Проверить при подключении к ноде; держать через ref.listen.
final noticesOnConnectProvider = Provider<void>((ref) {
  ref.listen(canSendProvider, (was, ready) {
    if (ready && was != true) ref.read(noticesProvider.notifier).refresh();
  });
});
