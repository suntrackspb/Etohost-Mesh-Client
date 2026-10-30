import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';
import 'app_localizations_ru.dart';
import 'built_in_text.dart';

export 'app_localizations.dart';
export 'built_in_text.dart';

extension AppLocalizationContext on BuildContext {
  /// Only for built-in metadata, validation messages and service errors.
  /// Keep user messages, names, notes and input outside this adapter.
  String builtIn(String source) => localizeBuiltInText(l10n, source);
  String? builtInOrNull(String? source) =>
      source == null ? null : builtIn(source);

  // Fallback keeps small isolated widgets usable without a MaterialApp delegate.
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsRu();
}

/// Russian remains the fallback for system languages that are not supported.
Locale resolveAppLocale(List<Locale>? locales, Iterable<Locale> supported) {
  for (final locale in locales ?? const <Locale>[]) {
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode) return candidate;
    }
  }
  return const Locale('ru');
}

Locale? parseAppLocale(String? value) => AppLocalizations.supportedLocales
    .where((locale) => locale.languageCode == value)
    .firstOrNull;

/// Native language names. Add a name here when adding another ARB locale.
const appLanguageNames = {'ru': 'Русский', 'en': 'English'};

extension AppLocalizedFormatting on BuildContext {
  String dayLabel(DateTime date, DateTime now) {
    final day = DateTime(date.year, date.month, date.day);
    if (day == DateTime(now.year, now.month, now.day)) {
      return builtIn('Сегодня');
    }
    if (day == DateTime(now.year, now.month, now.day - 1)) {
      return builtIn('Вчера');
    }
    return date.year == now.year
        ? DateFormat.MMMd(l10n.localeName).format(date)
        : DateFormat.yMMMd(l10n.localeName).format(date);
  }

  String bearingLabel(double degrees) {
    final names = [
      l10n.cardinalNorth,
      l10n.cardinalNorthEast,
      l10n.cardinalEast,
      l10n.cardinalSouthEast,
      l10n.cardinalSouth,
      l10n.cardinalSouthWest,
      l10n.cardinalWest,
      l10n.cardinalNorthWest,
    ];
    return '${names[((degrees + 22.5) % 360) ~/ 45]} ${degrees.round() % 360}°';
  }
}
