import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/fields.dart';
import 'package:meshex/data/settings/range_test_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool enabled(List<FieldSpec<Object?>> fields, String key) =>
      fields
          .firstWhere((f) => f.key == key)
          .enabledWhen
          ?.call(<String, Object?>{}) ??
      true;

  test('read/apply сохраняют все поля', () {
    final c = ModuleConfig_RangeTestConfig(
      enabled: true,
      sender: 60,
      save: true,
    );
    final v = RangeTestSection.read(c);
    final out = RangeTestSection.apply(c, v, primaryPublic: false);
    expect(RangeTestSection.read(out), v);
  });

  test('публичный ключ: пустой или однобайтовый', () {
    expect(isPublicPsk(null), isTrue);
    expect(isPublicPsk([]), isTrue);
    expect(isPublicPsk([1]), isTrue);
    expect(isPublicPsk(List.filled(16, 7)), isFalse);
  });

  test('на публичном канале модуль выключается и поля заблокированы', () {
    final c = ModuleConfig_RangeTestConfig(enabled: true, sender: 60);
    final out = RangeTestSection.apply(
      c,
      RangeTestSection.read(c),
      primaryPublic: true,
    );
    expect(out.enabled, isFalse);
    final f = RangeTestSection.fields(hasWifi: true, primaryPublic: true);
    expect(enabled(f, 'enabled'), isFalse);
    expect(enabled(f, 'save'), isFalse);
  });

  test('CSV только при Wi-Fi', () {
    final f = RangeTestSection.fields(hasWifi: false, primaryPublic: false);
    expect(enabled(f, 'save'), isFalse);
    expect(enabled(f, 'enabled'), isTrue);
  });
}
