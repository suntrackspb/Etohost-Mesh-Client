import 'package:drift/drift.dart' show Value;
import 'package:etohost_mesh/data/jammer_zones.dart';
import 'package:etohost_mesh/data/node_position.dart';
import 'package:etohost_mesh/mirror/mirror_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'node_filter_test.dart' show n;

/// Ответ `GET /api/jammer-zones` как на проде.
const zonesJson = {
  'zones': [
    {
      'lat_min': 59.952947,
      'lat_max': 60.21458,
      'lon_min': 31.15448,
      'lon_max': 31.511536,
    },
  ],
  'null_island': {'abs_lat_lt': 20.0, 'abs_lon_lt': 20.0},
  'exclude_zero': true,
};

void main() {
  final zones = JammerZones.fromJson(zonesJson)!;
  final now = DateTime(2026, 10, 24, 12);
  // Точка спуфинга у Ладоги и настоящая точка KolN.
  const spoofLat = 60.1096192, spoofLon = 31.3786368;
  const homeLat = 60.0047616, homeLon = 30.277632;

  group('зоны', () {
    test('плохая точка: зона, «нулевой остров», (0, 0)', () {
      expect(zones.isBad(spoofLat, spoofLon), isTrue);
      expect(zones.isBad(homeLat, homeLon), isFalse);
      expect(zones.isBad(1.5, -3), isTrue);
      expect(zones.isBad(0, 0), isTrue);
      expect(zones.isBad(59.952947, 31.15448), isTrue); // граница
    });

    test('сохраняются в настройках и читаются обратно', () {
      final back = JammerZones.decode(zones.encode());
      expect(back.zones, zones.zones);
      expect((back.nullLat, back.nullLon, back.excludeZero), (20, 20, true));
    });

    test('пусто, мусор или чужой формат — зон нет', () {
      expect(JammerZones.decode(null).isEmpty, isTrue);
      expect(JammerZones.decode('{oops').isEmpty, isTrue);
      expect(JammerZones.fromJson({'zones': 'x'}), isNull);
      expect(JammerZones.none.isBad(spoofLat, spoofLon), isFalse);
    });
  });

  group('спуфинг', () {
    final spoofed = n(1).copyWith(
      latitude: const Value(spoofLat),
      longitude: const Value(spoofLon),
      mirrorLat: const Value(homeLat),
      mirrorLon: const Value(homeLon),
    );
    NodePosition? pos(dynamic node, {bool correction = true}) =>
        nodePosition(node, correction: correction, zones: zones, now: now);

    test('точка вне зон — как есть, даже если зеркало её исправило', () {
      final ok = spoofed.copyWith(
        latitude: const Value(homeLat),
        longitude: const Value(homeLon),
        mirrorLat: const Value(59.9),
        mirrorCorrected: true,
      );
      final p = pos(ok)!;
      expect((p.lat, p.spoofed, p.corrected), (homeLat, false, false));
    });

    test('замена — своя свежая точка из эфира', () {
      final at = now.subtract(const Duration(hours: 2));
      final p = pos(
        spoofed.copyWith(
          radioGoodLat: const Value(homeLat),
          radioGoodLon: const Value(homeLon),
          radioGoodAt: Value(at),
        ),
      )!;
      expect((p.lat, p.mirror, p.spoofed, p.at), (homeLat, false, false, at));
    });

    test('своя точка старше 5 дней — дальше исправленная зеркалом', () {
      final p = pos(
        spoofed.copyWith(
          radioGoodLat: const Value(homeLat),
          radioGoodLon: const Value(homeLon),
          radioGoodAt: Value(now.subtract(const Duration(days: 6))),
          mirrorLat: const Value(59.95),
          mirrorCorrected: true,
        ),
      )!;
      expect((p.lat, p.corrected, p.mirror), (59.95, true, true));
    });

    test('затем — свежая точка зеркала вне зон', () {
      final at = now.subtract(const Duration(days: 4));
      final p = pos(
        spoofed.copyWith(
          mirrorGoodLat: const Value(homeLat),
          mirrorGoodLon: const Value(homeLon),
          mirrorGoodAt: Value(at),
        ),
      )!;
      expect((p.lat, p.mirror, p.at), (homeLat, true, at));
    });

    test('заменить нечем — точка эфира с пометкой', () {
      // Неисправленная точка зеркала без даты — не замена.
      final p = pos(
        spoofed.copyWith(
          mirrorGoodLat: const Value(homeLat),
          mirrorGoodLon: const Value(homeLon),
          mirrorGoodAt: Value(now.subtract(const Duration(days: 12))),
        ),
      )!;
      expect((p.lat, p.spoofed, p.at), (spoofLat, true, null));
    });

    test('корректировка выключена — не заменяем, только помечаем', () {
      final p = pos(
        spoofed.copyWith(
          radioGoodLat: const Value(homeLat),
          radioGoodLon: const Value(homeLon),
          radioGoodAt: Value(now),
        ),
        correction: false,
      )!;
      expect((p.lat, p.spoofed), (spoofLat, true));
    });

    test('запасная точка, оказавшаяся в зоне, не годится', () {
      final p = pos(
        spoofed.copyWith(
          radioGoodLat: const Value(spoofLat),
          radioGoodLon: const Value(spoofLon),
          radioGoodAt: Value(now),
        ),
      )!;
      expect(p.spoofed, isTrue);
    });

    test('нет эфира — проверяем точку зеркала так же', () {
      final mirrorOnly = n(2).copyWith(
        mirrorLat: const Value(spoofLat),
        mirrorLon: const Value(spoofLon),
      );
      final p = pos(mirrorOnly)!;
      expect((p.mirror, p.spoofed), (true, true));
    });

    test('подпись в карточке', () {
      String ago(DateTime t) => '2 ч назад';
      final base = pos(spoofed)!;
      expect(positionNote(base, ago), contains('подменённая'));
      final replaced = pos(
        spoofed.copyWith(
          radioGoodLat: const Value(homeLat),
          radioGoodLon: const Value(homeLon),
          radioGoodAt: Value(now),
        ),
      )!;
      expect(positionNote(replaced, ago), endsWith('2 ч назад'));
      expect(
        positionNote(
          pos(
            n(3).copyWith(
              latitude: const Value(59.9),
              longitude: const Value(30.3),
            ),
          )!,
          ago,
        ),
        isNull,
      );
    });
  });

  test('поля времени и точки вне зон из ответа зеркала', () {
    final m = MirrorNode.tryParse({
      'node_id': '!853113ca',
      'last_lat': homeLat,
      'last_lon': homeLon,
      'position_at': '2026-10-12T02:24:23+00:00',
      'last_good_lat': homeLat,
      'last_good_lon': homeLon,
      'last_good_at': '2026-10-12T02:24:23+00:00',
    })!;
    expect(
      m.positionAt!.isAtSameMomentAs(DateTime.utc(2026, 10, 12, 2, 24, 23)),
      isTrue,
    );
    expect((m.goodLat, m.goodLon), (homeLat, homeLon));
    expect(m.goodAt, m.positionAt);
    final empty = MirrorNode.tryParse({'node_id': '!b2a786e4'})!;
    expect((empty.positionAt, empty.goodLat, empty.goodAt), (null, null, null));
  });
}
