import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/desktop/desktop_tray.dart';
import '../core/radio/journal.dart';
import '../data/database.dart';
import 'providers.dart';

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
