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
      if (mac != null && macNodeNum(mac) == me) return IdBugPending(me, mac);
    } catch (_) {}
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
