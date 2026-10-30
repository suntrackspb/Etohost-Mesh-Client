import 'package:meshex/features/chat/swipe_to_reply.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<int> swipe(WidgetTester t, Offset by) async {
    var n = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Center(
          child: SwipeToReply(
            onReply: () => n++,
            child: const SizedBox(width: 200, height: 50, child: Text('msg')),
          ),
        ),
      ),
    );
    await t.drag(find.text('msg'), by);
    await t.pumpAndSettle();
    return n;
  }

  testWidgets('свайп влево дальше порога — ответ', (t) async {
    expect(await swipe(t, const Offset(-100, 0)), 1);
  });
  testWidgets('короткий свайп влево — ничего', (t) async {
    expect(await swipe(t, const Offset(-30, 0)), 0);
  });
  testWidgets('свайп вправо не перехватывается', (t) async {
    expect(await swipe(t, const Offset(100, 0)), 0);
  });
}
