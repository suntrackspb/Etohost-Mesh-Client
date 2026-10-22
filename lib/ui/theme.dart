import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'tokens.dart';

/// Пузырь с обращением ко мне: такой же насыщенности, как свой пузырь
/// (primaryContainer), но из своего цвета. При цвете, равном акценту,
/// совпадает со своим пузырём.
Color mentionBubble(Color color, Brightness brightness) => ColorScheme.fromSeed(
  seedColor: color,
  brightness: brightness,
).primaryContainer;

/// [black] — тёмная тема с чистым чёрным фоном (экономия батареи на OLED):
/// экраны, шапка и нижнее меню #000, карточки и поля — очень тёмно-серые,
/// акценты остаются цветными.
ThemeData buildTheme(
  Brightness brightness, {
  Color seed = Tokens.seed,
  bool black = false,
}) {
  var scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  if (black) {
    scheme = scheme.copyWith(
      surface: Colors.black,
      surfaceDim: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: const Color(0xFF0E0E0E),
      surfaceContainer: const Color(0xFF141414),
      surfaceContainerHigh: const Color(0xFF1B1B1B),
      surfaceContainerHighest: const Color(0xFF242424),
      surfaceBright: const Color(0xFF2A2A2A),
    );
  }
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: black ? Colors.black : null,
    appBarTheme: black
        ? const AppBarTheme(
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
          )
        : null,
    navigationBarTheme: black
        ? const NavigationBarThemeData(backgroundColor: Colors.black)
        : null,
    navigationRailTheme: black
        ? const NavigationRailThemeData(backgroundColor: Colors.black)
        : null,
    // «Назад» свайпом с любого места экрана, как в системных приложениях iOS;
    // на Android системный жест от края тоже работает.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: SwipeablePageTransitionsBuilder(),
        TargetPlatform.macOS: SwipeablePageTransitionsBuilder(),
        TargetPlatform.android: SwipeablePageTransitionsBuilder(),
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
