import 'package:etohost_mesh/data/node_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('по умолчанию всё видно, битое значение — тоже', () {
    for (final s in [null, '', 'xx', '["nope"]']) {
      final l = NodeLayout.decode(s);
      expect(NodeRowField.values.every(l.shows), isTrue, reason: '$s');
    }
  });

  test('скрытие и обратно, сохранение', () {
    final l = const NodeLayout()
        .toggle(NodeRowField.signal, false)
        .toggle(NodeRowField.id, false)
        .toggle(NodeRowField.id, true);
    expect(l.shows(NodeRowField.signal), isFalse);
    expect(l.shows(NodeRowField.id), isTrue);
    expect(NodeLayout.decode(l.encode()).hidden, {NodeRowField.signal});
  });
}
