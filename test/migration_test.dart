import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated_migrations/schema.dart';

/// Снимки схем — drift_schemas/; новая версия: `dart run drift_dev schema
/// dump lib/data/database.dart drift_schemas/drift_schema_vN.json`, затем
/// `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in [5, 6, 7, 8, 9, 10, 11, 12, 13]) {
    test('миграция $from → 14 даёт текущую схему', () async {
      final schema = await verifier.schemaAt(from);
      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 14);
      await db.close();
    });
  }

  test('данные переживают миграцию 5 → текущая', () async {
    final schema = await verifier.schemaAt(5);
    schema.rawDatabase.execute(
      "INSERT INTO app_settings (key, value) VALUES ('app.theme', 'dark')",
    );
    schema.rawDatabase.execute('INSERT INTO my_node (my_node_num) VALUES (42)');
    final db = AppDatabase(schema.newConnection());
    expect(await db.getSetting(AppSettingKeys.theme), 'dark');
    expect((await db.select(db.myNode).getSingle()).myNodeNum, 42);
    await db.close();
  });

  test(
    'обрыв посреди шага — откат целиком, повторный запуск проходит',
    () async {
      final schema = await verifier.schemaAt(7);
      final broken = _BrokenStep(schema.newConnection());
      await expectLater(
        broken.getSetting(AppSettingKeys.theme),
        throwsA(isA<StateError>()),
      );
      await broken.close();

      expect(schema.rawDatabase.userVersion, 7);
      final cols = schema.rawDatabase
          .select('PRAGMA table_info(nodes)')
          .map((r) => r['name'])
          .toList();
      expect(cols, isNot(contains('rssi')));

      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 14);
      await db.close();
    },
  );

  test('база новее сборки — не стирается', () async {
    final schema = await verifier.schemaAt(8);
    schema.rawDatabase.execute(
      "INSERT INTO app_settings (key, value) VALUES ('app.theme', 'dark')",
    );
    schema.rawDatabase.userVersion = 99;
    final db = AppDatabase(schema.newConnection());
    expect(await db.getSetting(AppSettingKeys.theme), 'dark');
    await db.close();
  });
}

/// Шаг к 8-й падает после первой колонки — как убитый посреди миграции
/// процесс.
class _BrokenStep extends AppDatabase {
  _BrokenStep(super.executor);

  @override
  Map<int, Future<void> Function(Migrator m)> get upgradeSteps => {
    ...super.upgradeSteps,
    8: (m) async {
      await m.addColumn(nodes, nodes.rssi);
      throw StateError('обрыв');
    },
  };
}
