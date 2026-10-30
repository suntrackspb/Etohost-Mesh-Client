import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../data/database.dart';
import '../l10n/l10n.dart';
import 'providers.dart';

/// App-wide settings store follows node database changes, preserving the language.
final appLocaleProvider = StreamProvider<Locale?>(
  (ref) => ref
      .watch(appDatabaseProvider)
      .watchSetting(AppSettingKeys.locale)
      .map(parseAppLocale)
      .distinct(),
);

/// Keeps service notifications and desktop menus in sync with system language.
final systemLocalesProvider = NotifierProvider<SystemLocales, List<Locale>>(
  SystemLocales.new,
);

class SystemLocales extends Notifier<List<Locale>> with WidgetsBindingObserver {
  @override
  List<Locale> build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return PlatformDispatcher.instance.locales;
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    state = locales ?? const [];
  }
}

final appStringsProvider = Provider<AppLocalizations>((ref) {
  final preferred = ref.watch(appLocaleProvider).value;
  final locale =
      preferred ??
      resolveAppLocale(
        ref.watch(systemLocalesProvider),
        AppLocalizations.supportedLocales,
      );
  return lookupAppLocalizations(locale);
});
