import 'package:meshex/features/chat/scroll_to_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final reverse in [false, true]) {
    testWidgets('доводит до непостроенного элемента (reverse: $reverse)', (
      t,
    ) async {
      final c = ScrollController();
      final keys = List.generate(500, (_) => GlobalKey());
      await t.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: c,
            reverse: reverse,
            itemCount: 500,
            itemBuilder: (_, i) => SizedBox(
              key: keys[i],
              height: 40 + (i % 3) * 20.0,
              child: Text('m$i'),
            ),
          ),
        ),
      );
      expect(find.text('m300'), findsNothing);
      final done = scrollToItem(c, 300, 500, (i) => keys[i]);
      await t.pumpAndSettle();
      expect(await done, isTrue);
      expect(find.text('m300'), findsOneWidget);
      // и обратно вниз
      final back = scrollToItem(c, 2, 500, (i) => keys[i]);
      await t.pumpAndSettle();
      expect(await back, isTrue);
      expect(find.text('m2'), findsOneWidget);
    });
  }
}
