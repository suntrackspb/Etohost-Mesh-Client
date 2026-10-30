import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:meshex/data/position_sharer.dart';
import 'package:meshex/features/map/phone_location.dart';

void main() {
  final fix = (
    lat: 59.94,
    lon: 30.31,
    altitude: null,
    time: DateTime(2026, 10, 30),
  );

  testWidgets('requests only on tap, blocks duplicates and allows refresh', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<Fix>();
    LatLng? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhoneLocationButton(
            locate: () {
              calls++;
              return pending.future;
            },
            onLocated: (position) => selected = position,
          ),
        ),
      ),
    );
    expect(calls, 0);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    expect(calls, 1);
    pending.complete(fix);
    await tester.pump();
    expect(selected, const LatLng(59.94, 30.31));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(calls, 2);
  });

  testWidgets('shows location error and permits retry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhoneLocationButton(
            locate: () async => throw StateError('нет доступа к геолокации'),
            onLocated: (_) => fail('must not locate after denial'),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.textContaining('нет доступа к геолокации'), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('ignores a fix received after leaving the map', (tester) async {
    final pending = Completer<Fix>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhoneLocationButton(
            locate: () => pending.future,
            onLocated: (_) => fail('callback after disposal'),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpWidget(const SizedBox());
    pending.complete(fix);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
