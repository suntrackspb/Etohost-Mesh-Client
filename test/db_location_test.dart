import 'package:meshex/data/db_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('переносим базы со спутниками, чужое не трогаем', () {
    final plan = dbMovePlan([
      'meshtastic.sqlite',
      'meshtastic.sqlite-wal',
      'node_123.sqlite',
      'node_123.sqlite-shm',
      'node_9.sqlite-wal', // без самой базы
      'export.tmp.sqlite',
      'Отчёт.docx',
    ], {});
    expect(
      plan.keys,
      unorderedEquals(['meshtastic.sqlite', 'node_123.sqlite']),
    );
    expect(plan['meshtastic.sqlite'], [
      'meshtastic.sqlite',
      'meshtastic.sqlite-wal',
    ]);
  });

  test('база уже есть на новом месте — старую не переносим', () {
    final plan = dbMovePlan(
      ['meshtastic.sqlite', 'node_1.sqlite'],
      {'meshtastic.sqlite'},
    );
    expect(plan.keys, ['node_1.sqlite']);
  });
}
