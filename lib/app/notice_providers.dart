import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/client_version.dart';
import '../core/notices/notices.dart';
import '../core/store_build.dart';
import '../core/update/update_checker.dart' show downloadsPage;
import '../data/database.dart';
import '../mirror/mirror_capabilities.dart';
import 'providers.dart';

/// Объявления с сервера отчётов, который указало подключённое зеркало
/// (без зеркала — никуда не ходим). Проверка — при запуске,
/// возврате на экран и подключении к ноде, не чаще [noticesInterval].
/// Ошибки сети молча пропускаем: объявления не главное.
class NoticesController extends Notifier<List<Notice>> {
  DateTime? _last;

  @override
  List<Notice> build() => const [];

  /// [force] — без учёта интервала (сменилось зеркало).
  Future<void> refresh({bool force = false}) async {
    final now = DateTime.now();
    if (!force && !noticesDue(_last, now)) return;
    final MirrorCapabilities? caps;
    try {
      caps = await ref.read(mirrorCapabilitiesProvider.future);
    } catch (_) {
      return;
    }
    final cap = caps?.reports;
    if (cap == null || !cap.notices) {
      state = const [];
      return;
    }
    _last = now;
    try {
      state = await fetchNotices(cap.baseUrl, cap.apiKey);
    } catch (_) {}
  }

  /// Скрываем сразу (critical — только до перезапуска), остальные ещё и
  /// запоминаем в базе.
  Future<void> dismiss(Notice n) async {
    final hidden = ref.read(_sessionDismissedProvider.notifier);
    hidden.state = {...hidden.state, n.id};
    if (n.level == NoticeLevel.critical) return;
    final db = ref.read(databaseProvider);
    final ids = {
      ..._decode(await db.getSetting(AppSettingKeys.noticesDismissed)),
      n.id,
    };
    await db.setSetting(AppSettingKeys.noticesDismissed, jsonEncode([...ids]));
  }
}

/// Закрытые в этом запуске.
final _sessionDismissedProvider = StateProvider<Set<String>>((ref) => {});

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
          // В магазинной сборке обновляет магазин — ссылки мимо него нет.
          linkUrl: storeBuild ? null : downloadsPage,
          linkLabel: storeBuild ? null : 'Скачать',
        );
});

/// Объявления для показа в этой сборке.
final visibleNoticesProvider = Provider<List<Notice>>((ref) {
  final outdated = ref.watch(outdatedNoticeProvider);
  final shown = ref.watch(_visibleServerNoticesProvider);
  final hidden = ref.watch(_sessionDismissedProvider);
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
      ...ref.watch(_sessionDismissedProvider),
    },
  );
});

/// Проверить при подключении к ноде; держать через ref.listen.
final noticesOnConnectProvider = Provider<void>((ref) {
  ref.listen(canSendProvider, (was, ready) {
    if (ready && was != true) ref.read(noticesProvider.notifier).refresh();
  });
  // Зеркало подключили или отключили — объявления с его сервера или никаких.
  ref.listen(mirrorCapabilitiesProvider, (_, _) {
    ref.read(noticesProvider.notifier).refresh(force: true);
  });
});
