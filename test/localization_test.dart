import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshex/app/locale_provider.dart';
import 'package:meshex/app/providers.dart';
import 'package:meshex/data/database.dart';
import 'package:meshex/data/settings/fields.dart';
import 'package:meshex/data/settings/settings_form.dart';
import 'package:meshex/features/settings/radio/settings_form_view.dart';
import 'package:meshex/features/settings/settings_index.dart';
import 'package:meshex/l10n/app_localizations_en.dart';
import 'package:meshex/l10n/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('system language resolution and supported saved preferences', () {
    expect(
      resolveAppLocale([
        const Locale('en', 'GB'),
      ], AppLocalizations.supportedLocales),
      const Locale('en'),
    );
    expect(
      resolveAppLocale([
        const Locale('de'),
        const Locale('en'),
      ], AppLocalizations.supportedLocales),
      const Locale('en'),
    );
    expect(
      resolveAppLocale([const Locale('de')], AppLocalizations.supportedLocales),
      const Locale('ru'),
    );
    expect(parseAppLocale('system'), isNull);
    expect(parseAppLocale('en'), const Locale('en'));
    expect(parseAppLocale('garbage'), isNull);
  });

  test('catalogs have identical keys and all target messages translated', () {
    final ru =
        jsonDecode(File('lib/l10n/app_ru.arb').readAsStringSync()) as Map;
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map;
    Set<String> keys(Map arb) =>
        arb.keys.cast<String>().where((k) => !k.startsWith('@')).toSet();
    expect(keys(en), keys(ru));
    for (final key in keys(en)) {
      if (key != 'russian') {
        expect(
          RegExp('[А-Яа-яЁё]').hasMatch(en[key] as String),
          isFalse,
          reason: key,
        );
      }
    }
  });

  test('language persists in settings across provider recreation', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final first = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    first.listen(appLocaleProvider, (previous, next) {}, fireImmediately: true);
    expect(
      await first
          .read(appLocaleProvider.future)
          .timeout(const Duration(seconds: 3)),
      isNull,
    );
    await db.setSetting(AppSettingKeys.locale, 'en');
    first.dispose();
    final second = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    second.listen(
      appLocaleProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    expect(
      await second
          .read(appLocaleProvider.future)
          .timeout(const Duration(seconds: 3)),
      const Locale('en'),
    );
    await db.setSetting(AppSettingKeys.locale, 'system');
    second.dispose();
    await db.close();
  });

  testWidgets(
    'switches typed UI and schema labels without altering user input',
    (tester) async {
      final form = SettingsForm(
        [
          const BoolFieldSpec('enabled', 'Bluetooth включен'),
          const TextFieldSpec('name', 'Название', maxBytes: 40),
        ],
        {'enabled': true, 'name': 'Сеть'},
      );
      Widget app(String language) => MaterialApp(
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Column(
            children: [
              Builder(builder: (context) => Text(context.l10n.compassTitle)),
              SettingsFormView(form: form),
            ],
          ),
        ),
      );
      await tester.pumpWidget(app('ru'));
      await tester.pumpAndSettle();
      expect(find.text('Компас'), findsOneWidget);
      expect(find.text('Bluetooth включен'), findsOneWidget);
      await tester.pumpWidget(app('en'));
      await tester.pumpAndSettle();
      expect(find.text('Compass'), findsOneWidget);
      expect(find.text('Bluetooth enabled'), findsOneWidget);
      expect(
        find.text('Сеть'),
        findsOneWidget,
        reason: 'node names and editable values are user content',
      );
      form.dispose();
    },
  );

  testWidgets('English search finds localized settings and retains route IDs', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: SettingsSearchResults('language')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
  });

  test('service formatting preserves names and message content', () {
    final s = AppLocalizationsEn();
    expect(s.notificationReplyTitle('Сеть'), 'Сеть · reply');
    expect(s.notificationReactionBody('👍', 'Карта'), '👍 to “Карта”');
    expect(
      localizeBuiltInText(s, 'нет доступа к геолокации'),
      'location access denied',
    );
    expect(localizeBuiltInText(s, '250 м'), '250 m');
  });
}
