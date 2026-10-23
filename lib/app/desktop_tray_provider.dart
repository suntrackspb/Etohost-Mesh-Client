import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/desktop/desktop_tray.dart';
import '../core/radio/journal.dart';
import '../data/database.dart';
import 'providers.dart';
import 'router.dart';

/// Сворачивать в трей при закрытии (по умолчанию — да).
final closeToTrayProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(databaseProvider)
      .watchSetting(AppSettingKeys.closeToTray)
      .map((v) => v != 'false'),
);

/// Трей на Windows и Linux; на остальных платформах — ничего.
final desktopTrayProvider = Provider<DesktopTray?>((ref) {
  if (!DesktopTray.supported) return null;
  final journal = ref.read(journalProvider);
  final tray = DesktopTray(
    onError: (e) => journal.add(JournalKind.error, 'Трей недоступен: $e'),
    onFirstClose: () => _askOnce(ref),
  );
  ref.listen(
    closeToTrayProvider,
    (_, v) => tray.setCloseToTray(v.value ?? true),
    fireImmediately: true,
  );
  tray.init().catchError(
    (Object e) => journal.add(JournalKind.error, 'Трей: $e'),
  );
  ref.onDispose(tray.dispose);
  return tray;
});

/// Первое закрытие окна: объяснить, что приложение остаётся в трее
/// (иначе кажется, что оно закрылось, а повторный запуск ловит
/// «database is locked»). Ответ запоминается; дальше — без вопроса.
Future<bool?> _askOnce(Ref ref) async {
  final db = ref.read(databaseProvider);
  if (await db.getSetting(AppSettingKeys.trayAsked) == 'true') return true;
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null || !ctx.mounted) return true;
  final toTray = await showDialog<bool>(
    context: ctx,
    builder: (c) => AlertDialog(
      title: const Text('Свернуть в трей?'),
      content: const Text(
        'Приложение продолжит работать в фоне: принимать сообщения и '
        'держать связь с нодой. Вернуть окно — значок в трее, выйти — '
        '«Выход» в его меню. Изменить это можно в настройках приложения.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Выйти'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Свернуть в трей'),
        ),
      ],
    ),
  );
  if (toTray == null) return null;
  await db.setSetting(AppSettingKeys.trayAsked, 'true');
  if (!toTray) await db.setSetting(AppSettingKeys.closeToTray, 'false');
  return toTray;
}
