import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'tokens.dart';

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: Tokens.seed,
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    // iOS/macOS: «назад» свайпом с любого места экрана, как в системных приложениях.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: SwipeablePageTransitionsBuilder(),
        TargetPlatform.macOS: SwipeablePageTransitionsBuilder(),
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.radiusL),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Tokens.s16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.radiusM),
      ),
      isDense: true,
    ),
  );
}
