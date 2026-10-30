import 'dart:io';

import 'package:meshex/data/tile_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('tiles'));
  tearDown(() => dir.deleteSync(recursive: true));

  File put(String name, int size, int ageMin) {
    final f = File('${dir.path}/$name')
      ..createSync(recursive: true)
      ..writeAsBytesSync(List.filled(size, 0));
    f.setLastModifiedSync(DateTime.now().subtract(Duration(minutes: ageMin)));
    return f;
  }

  test('обрезка удаляет самые старые, пока не влезет', () {
    final old = put('a/old', 100, 30);
    final mid = put('b/mid', 100, 20);
    final fresh = put('fresh', 100, 10);
    expect(tileCacheSize(dir), 300);
    expect(trimTileCache(dir, 150), 200);
    expect(old.existsSync(), isFalse);
    expect(mid.existsSync(), isFalse);
    expect(fresh.existsSync(), isTrue);
  });

  test('в лимите и без каталога — ничего не удаляется', () {
    put('x', 10, 1);
    expect(trimTileCache(dir, 100), 0);
    expect(tileCacheSize(Directory('${dir.path}/none')), 0);
  });

  test('кэш CARTO: старше срока — удаляется', () {
    final old = put('carto/old', 10, 60 * 24 * 31);
    final fresh = put('carto/fresh', 10, 60 * 24 * 29);
    expect(dropOlderThan(dir, cartoCacheMaxAge), 10);
    expect(old.existsSync(), isFalse);
    expect(fresh.existsSync(), isTrue);
  });

  test('размер по-русски', () {
    expect(formatBytes(2048), '2 КБ');
    expect(formatBytes(5 * 1024 * 1024 + 300 * 1024), '5,3 МБ');
  });
}
