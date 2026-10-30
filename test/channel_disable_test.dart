import 'package:drift/native.dart';
import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/core/radio/send_queue.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/settings/admin_settings.dart';
import 'package:meshex/data/settings/channel_edit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('удаление канала — роль «Отключен», настройки прежние', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final s = ChannelSettings(name: 'LiteSlow', psk: [1], uplinkEnabled: true);
    await db.upsertChannel(
      Channel(index: 2, role: Channel_Role.SECONDARY, settings: s),
    );
    final sent = <MeshPacket>[];
    final admin = AdminSettings(
      (p) async {
        sent.add(p);
        return const DeliveryResult(DeliveryStatus.acked);
      },
      () => 0xAA,
      () => 1,
    );
    final row = (await db.select(db.channels).get()).single;
    expect(await ChannelEdit.disable(admin, db, row), isTrue);
    final ch = AdminMessage.fromBuffer(sent.single.decoded.payload).setChannel;
    expect(ch.index, 2);
    expect(ch.role, Channel_Role.DISABLED);
    expect(ch.settings.name, 'LiteSlow');
    expect(ch.settings.uplinkEnabled, isTrue);
    expect((await db.select(db.channels).get()).single.role, 0);

    final primary = row.copyWith(index: 0, role: Channel_Role.PRIMARY.value);
    expect(() => ChannelEdit.disable(admin, db, primary), throwsStateError);
  });
}
