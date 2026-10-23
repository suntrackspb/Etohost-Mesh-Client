import 'package:etohost_mesh/data/node_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('по умолчанию всё видно, кроме новых полей; битое — так же', () {
    for (final s in [null, '', 'xx', '["nope"]']) {
      final l = NodeLayout.decode(s);
      for (final f in NodeRowField.values) {
        expect(l.shows(f), !optInRowFields.contains(f), reason: '$s $f');
      }
    }
  });

  test('скрытие и обратно, сохранение', () {
    final l = const NodeLayout()
        .toggle(NodeRowField.signal, false)
        .toggle(NodeRowField.id, false)
        .toggle(NodeRowField.id, true);
    expect(l.shows(NodeRowField.signal), isFalse);
    expect(l.shows(NodeRowField.id), isTrue);
    expect(NodeLayout.decode(l.encode()).hidden, {
      NodeRowField.signal,
      ...optInRowFields,
    });
  });

  test('новые поля включаются и сохраняются', () {
    final l = const NodeLayout().toggle(NodeRowField.firmware, true);
    final back = NodeLayout.decode(l.encode());
    expect(back.shows(NodeRowField.firmware), isTrue);
    expect(back.shows(NodeRowField.hardware), isFalse);
  });

  test('старая сохранённая настройка: новые поля остаются выключены', () {
    final l = NodeLayout.decode('["signal"]');
    expect(l.shows(NodeRowField.signal), isFalse);
    expect(l.shows(NodeRowField.firmware), isFalse);
  });
}
