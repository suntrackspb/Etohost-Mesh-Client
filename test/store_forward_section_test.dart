import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/store_forward_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fields = StoreForwardSection.fields();
  bool visible(String key, Map<String, Object?> v) =>
      fields.firstWhere((f) => f.key == key).visibleWhen?.call(v) ?? true;

  test('read/apply сохраняют все поля', () {
    final c = ModuleConfig_StoreForwardConfig(
      enabled: true,
      heartbeat: true,
      records: 300,
      historyReturnMax: 50,
      historyReturnWindow: 120,
      isServer: true,
    );
    final v = StoreForwardSection.read(c);
    expect(fields.map((f) => f.key).toSet(), v.keys.toSet());
    expect(StoreForwardSection.read(StoreForwardSection.apply(c, v)), v);
  });

  test('настройки и сервер видны только при включённом модуле (iOS)', () {
    final v = StoreForwardSection.read(ModuleConfig_StoreForwardConfig());
    for (final k in [
      'heartbeat',
      'records',
      'historyReturnWindow',
      'isServer',
    ]) {
      expect(visible(k, v), isFalse, reason: k);
    }
    expect(visible('enabled', v), isTrue);
    v['enabled'] = true;
    expect(visible('isServer', v), isTrue);
    expect(StoreForwardSection.showServerNote(v), isFalse);
    v['isServer'] = true;
    expect(StoreForwardSection.showServerNote(v), isTrue);
  });
}
