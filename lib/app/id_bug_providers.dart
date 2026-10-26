import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/radio/radio_session.dart';
import '../data/id_bug.dart';
import '../data/node_actions.dart' show nodeIdOf;
import 'providers.dart';

/// Подвержена ли подключённая нода ошибке со сменой ID (см. id_bug.dart).
/// Считается после загрузки конфигурации; повторно — при переподключении.
final idBugProvider = FutureProvider<IdBug?>((ref) async {
  final ready = ref.watch(
    radioProvider.select((r) => r.state == RadioState.ready),
  );
  if (!ready) return null;
  final radio = ref.read(radioProvider);
  final me = radio.myNodeNum;
  if (me == null) return null;
  // Своя NodeInfo приходит заново при перечитывании базы нод.
  ref.watch(radioProvider.select((r) => r.ownUser));
  final db = ref.read(databaseProvider);
  final own = await (db.select(
    db.nodes,
  )..where((n) => n.num.equals(me))).getSingleOrNull();
  final bug = detectIdBug(
    me: me,
    radio: radio.ownUser,
    firmware: radio.metadata?.firmwareVersion,
    savedMac: own?.macaddr,
  );
  // MAC нет в базе (приложение переустанавливали) — спросить зеркало,
  // оно видело настоящий MAC в NodeInfo до поломки.
  if (bug is IdBugPending && bug.mac == null) {
    try {
      final mac = await ref.read(mirrorApiProvider)?.nodeMac(nodeIdOf(me));
      if (mac != null && macFitsNode(mac, me, idFromKey: bug.idFromKey)) {
        return IdBugPending(me, mac, idFromKey: bug.idFromKey);
      }
    } catch (_) {}
    // На 2.8 без MAC ничего не сломается — не пугаем.
    if (bug.idFromKey) return null;
  }
  return bug;
});

/// После починки сбросом — вернуть имя ноды, когда она снова на связи.
/// Держится живым из оболочки приложения.
final ownerRestoreProvider = FutureProvider<void>((ref) async {
  final ready = ref.watch(
    radioProvider.select((r) => r.state == RadioState.ready),
  );
  if (!ready) return;
  try {
    await ref.read(nodeActionsProvider).restorePendingOwner();
  } catch (_) {
    // Не вышло — попробуем при следующем подключении.
  }
});

/// Ноды, которым мягкая починка уже отправлена в этом запуске.
final _autoFixed = <int>{};

/// Мягкая починка сама: нода ещё не перезагружалась, а настоящий MAC
/// известен (из базы или зеркала). Безвредна и при ложной тревоге — MAC
/// проверен на совпадение с номером. Один раз за запуск на ноду; не
/// помогло — останется экран «Исправить ID ноды». Держится из оболочки.
final autoIdFixProvider = FutureProvider<void>((ref) async {
  final bug = await ref.watch(idBugProvider.future);
  if (bug is! IdBugPending) return;
  final mac = bug.mac;
  if (mac == null || !_autoFixed.add(bug.num)) return;
  try {
    await ref
        .read(nodeActionsProvider)
        .fixIdBugWithMac(mac, idFromKey: bug.idFromKey);
    // Нода пришлёт свою запись заново — проверка пересчитается.
    ref.read(radioProvider).refreshNodes();
  } catch (_) {}
});
