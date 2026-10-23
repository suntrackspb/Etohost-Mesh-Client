import 'package:etohost_mesh/data/node_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final a = List.filled(32, 1), b = List.filled(32, 2);

  test('первый ключ записывается, тот же — совпадение', () {
    expect(keyUpdate(null, a), KeyUpdate.store);
    expect(keyUpdate(a, a), KeyUpdate.match);
  });

  test('другой ключ — несовпадение, пустой — игнор', () {
    expect(keyUpdate(a, b), KeyUpdate.mismatch);
    expect(keyUpdate(a, const []), KeyUpdate.ignore);
  });

  test('ключ своей ноды принимается всегда, но только 32 байта', () {
    expect(keyUpdate(a, b, own: true), KeyUpdate.store);
    expect(keyUpdate(a, [1, 2], own: true), KeyUpdate.ignore);
  });
}
