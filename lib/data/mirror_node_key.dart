import 'package:drift/drift.dart';

import '../mirror/mirror_api.dart';
import '../core/proto/mesh.dart';
import 'database.dart';

/// Зеркало дополняет отсутствующий ключ, но не заменяет уже известный.
Future<void> loadMirrorNodeKey(AppDatabase db, MirrorApi api, int num) async {
  final identity = await api.nodeIdentity(nodeIdString(num));
  final key = identity.publicKey;
  if (key == null || key.length != 32 || key.every((b) => b == 0)) return;
  await db.transaction(() async {
    final node = await (db.select(
      db.nodes,
    )..where((n) => n.num.equals(num))).getSingleOrNull();
    if (node == null ||
        !node.onMirror ||
        (node.publicKey?.isNotEmpty ?? false)) {
      return;
    }
    await (db.update(db.nodes)..where((n) => n.num.equals(num))).write(
      NodesCompanion(publicKey: Value(Uint8List.fromList(key))),
    );
  });
}
