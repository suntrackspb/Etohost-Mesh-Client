import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'tokens.dart';

/// Пузырь с обращением ко мне: такой же насыщенности, как свой пузырь
/// (primaryContainer), но из своего цвета. При цвете, равном акценту,
/// совпадает со своим пузырём.
Color mentionBubble(Color color, Brightness brightness) =>
    _accentScheme(color, brightness).primaryContainer;

ColorScheme _accentScheme(Color seed, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  if (seed != Tokens.yellow) return scheme;
  final dark = brightness == Brightness.dark;
  return scheme.copyWith(
    primary: dark ? Tokens.yellow : const Color(0xFF735B00),
    onPrimary: dark ? const Color(0xFF262000) : Colors.white,
    primaryContainer: dark ? const Color(0xFF3C341A) : const Color(0xFFFFEDAD),
    onPrimaryContainer: dark
        ? const Color(0xFFFFE992)
        : const Color(0xFF292100),
    secondary: dark ? Tokens.green : const Color(0xFF176C39),
    onSecondary: dark ? const Color(0xFF003919) : Colors.white,
    secondaryContainer: dark
        ? const Color(0xFF173D29)
        : const Color(0xFFD6F3DF),
    onSecondaryContainer: dark
        ? const Color(0xFFB4F2C9)
        : const Color(0xFF103C23),
    tertiary: dark ? const Color(0xFF91BAFF) : const Color(0xFF1D5EB8),
    onTertiary: dark ? const Color(0xFF002E69) : Colors.white,
    tertiaryContainer: dark ? const Color(0xFF203755) : const Color(0xFFDCE9FF),
    onTertiaryContainer: dark
        ? const Color(0xFFD4E4FF)
        : const Color(0xFF12365E),
  );
}

/// [black] — тёмная тема с чистым чёрным фоном (экономия батареи на OLED):
/// экраны, шапка и нижнее меню #000, карточки и поля — очень тёмно-серые,
/// акценты остаются цветными.
ThemeData buildTheme(
  Brightness brightness, {
  Color seed = Tokens.seed,
  bool black = false,
}) {
  final dark = brightness == Brightness.dark;
  final branded = seed == Tokens.yellow;
  var scheme = _accentScheme(seed, brightness).copyWith(
    surface: dark ? const Color(0xFF111318) : const Color(0xFFF7F8FA),
    onSurface: dark ? const Color(0xFFF2F3F5) : const Color(0xFF191D24),
    onSurfaceVariant: dark ? const Color(0xFFADB3BE) : const Color(0xFF555E6D),
    surfaceDim: dark ? const Color(0xFF111318) : const Color(0xFFDADDE3),
    surfaceBright: dark ? const Color(0xFF353A44) : const Color(0xFFF7F8FA),
    surfaceContainerLowest: dark ? const Color(0xFF0C0E12) : Colors.white,
    surfaceContainerLow: dark ? const Color(0xFF191D24) : Colors.white,
    surfaceContainer: dark ? const Color(0xFF1E232C) : const Color(0xFFF0F2F6),
    surfaceContainerHigh: dark
        ? const Color(0xFF272D37)
        : const Color(0xFFE9ECF1),
    surfaceContainerHighest: dark
        ? const Color(0xFF303743)
        : const Color(0xFFE2E6ED),
    outline: dark ? const Color(0xFF818A99) : const Color(0xFF727C8C),
    outlineVariant: dark ? const Color(0xFF363E4B) : const Color(0xFFD4DAE3),
  );
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
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      selectedIconTheme: IconThemeData(color: scheme.primary),
      unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      selectedLabelTextStyle: TextStyle(
        color: scheme.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
    filledButtonTheme: branded
        ? FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: Tokens.yellow,
              foregroundColor: const Color(0xFF262000),
            ),
          )
        : null,
    floatingActionButtonTheme: branded
        ? const FloatingActionButtonThemeData(
            backgroundColor: Tokens.yellow,
            foregroundColor: Color(0xFF262000),
          )
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
