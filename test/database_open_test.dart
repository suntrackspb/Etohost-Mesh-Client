import 'package:drift/native.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('база после прерванного первого запуска открывается', () async {
    // Остатки createAll: таблица и индекс есть, user_version = 0.
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(
            'CREATE TABLE messages (id INTEGER, channel_key TEXT, rx_time INTEGER)',
          );
          raw.execute(
            'CREATE INDEX messages_channel_time ON messages (channel_key, rx_time)',
          );
        },
      ),
    );
    expect(await db.select(db.messages).get(), isEmpty);
    expect(await db.select(db.nodes).get(), isEmpty);
    await db.close();
  });
}
