import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meshex/ui/theme.dart';

void main() {
  testWidgets('iOS: свайп «назад» с середины экрана во вкладке', (t) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    Page<void> page(GoRouterState s, Widget w) =>
        MaterialPage(key: s.pageKey, child: w);
    final router = GoRouter(
      initialLocation: '/s',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => Scaffold(body: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/s',
                  pageBuilder: (c, s) => page(
                    s,
                    Scaffold(
                      body: Builder(
                        builder: (c) => TextButton(
                          onPressed: () => c.go('/s/x'),
                          child: const Text('open'),
                        ),
                      ),
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'x',
                      pageBuilder: (_, s) =>
                          page(s, const Scaffold(body: Text('child'))),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    await t.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: buildTheme(Brightness.light),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('child'), findsOneWidget);
    await t.timedDragFrom(
      const Offset(200, 300),
      const Offset(400, 0),
      const Duration(milliseconds: 300),
    );
    await t.pumpAndSettle();
    expect(find.text('child'), findsNothing);
    expect(router.state.uri.path, '/s');
    debugDefaultTargetPlatformOverride = null;
  });
}
