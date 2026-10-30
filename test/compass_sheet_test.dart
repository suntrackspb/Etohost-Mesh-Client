import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshex/app/providers.dart';
import 'package:meshex/data/jammer_zones.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/features/nodes/compass/compass_controller.dart';
import 'package:meshex/features/nodes/compass/compass_sheet.dart';
import 'package:meshex/features/nodes/node_provider.dart';
import 'package:meshex/l10n/l10n.dart';

import 'compass_test.dart' show FakeCompassInputs;
import 'node_filter_test.dart' show n;

void main() {
  test('only mobile platforms offer the compass', () {
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    for (final platform in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = platform;
      expect(
        supportsNodeCompass,
        platform == TargetPlatform.android || platform == TargetPlatform.iOS,
      );
    }
  });

  testWidgets('live target, sensor warnings and sheet disposal', (
    tester,
  ) async {
    final input = FakeCompassInputs();
    final target = StreamController<Node>.broadcast();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nodeProvider(1).overrideWith((ref) => target.stream),
          positionRulesProvider.overrideWithValue((
            correction: false,
            zones: JammerZones.none,
          )),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(body: NodeCompassSheet(num: 1, inputs: input)),
        ),
      ),
    );
    await tester.pump();
    target.add(
      n(1, name: 'Сеть').copyWith(
        latitude: const Value(0.0),
        longitude: const Value(1.0),
        precisionBits: const Value(32),
      ),
    );
    await tester.pump();
    input.location.add((
      position: (lat: 0, lon: 0),
      accuracy: 10,
      time: DateTime.now(),
    ));
    input.compass.add((degrees: 90, calibrate: true, available: true));
    await tester.pump();
    expect(find.text('Сеть'), findsOneWidget);
    expect(find.text('Bearing: 90°'), findsOneWidget);
    expect(find.textContaining('Compass accuracy is low'), findsOneWidget);
    expect(
      tester.widget<CompassDial>(find.byType(CompassDial)).bearing,
      closeTo(90, 0.01),
    );
    target.add(
      n(
        1,
        name: 'Сеть',
      ).copyWith(latitude: const Value(1.0), longitude: const Value(0.0)),
    );
    await tester.pump();
    expect(find.text('Bearing: 0°'), findsOneWidget);
    input.compass.add((degrees: null, calibrate: false, available: false));
    await tester.pump();
    expect(find.textContaining('no compass sensor'), findsOneWidget);
    expect(
      tester.widget<CompassDial>(find.byType(CompassDial)).heading,
      isNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(input.location.hasListener, isFalse);
    expect(input.compass.hasListener, isFalse);
    await target.close();
    await input.close();
  });

  testWidgets('permission explanation fits a narrow screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final input = FakeCompassInputs()
      ..result = CompassLocationAccess.deniedForever;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nodeProvider(1).overrideWith((ref) => Stream.value(n(1))),
          positionRulesProvider.overrideWithValue((
            correction: false,
            zones: JammerZones.none,
          )),
        ],
        child: MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(body: NodeCompassSheet(num: 1, inputs: input)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Открыть настройки'), findsOneWidget);
    expect(input.locationStarts, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await input.close();
  });
}
