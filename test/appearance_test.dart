import 'package:meshex/data/appearance.dart';
import 'package:meshex/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme setting parses, unknown is system', () {
    expect(AppTheme.parse('black'), AppTheme.black);
    expect(AppTheme.parse('dark'), AppTheme.dark);
    expect(AppTheme.parse(null), AppTheme.system);
    expect(AppTheme.parse('мусор'), AppTheme.system);
  });

  test('accent parses, unknown is Meshex', () {
    expect(parseAccent('green').color, const Color(0xFF22C55E));
    expect(parseAccent(null).id, 'meshex');
    expect(accents.map((a) => a.id).toSet(), hasLength(accents.length));
  });

  test('black theme: pure black screens, dark grey cards', () {
    final t = buildTheme(Brightness.dark, black: true);
    expect(t.scaffoldBackgroundColor, Colors.black);
    expect(t.colorScheme.surface, Colors.black);
    expect(t.cardTheme.color, isNot(Colors.black));
    expect(
      buildTheme(Brightness.dark).scaffoldBackgroundColor,
      isNot(Colors.black),
    );
  });

  test('accent drives the primary color', () {
    final a = buildTheme(Brightness.light, seed: parseAccent('teal').color);
    final b = buildTheme(Brightness.light, seed: parseAccent('pink').color);
    expect(a.colorScheme.primary, isNot(b.colorScheme.primary));
  });

  test('Meshex text and container colours remain readable in both themes', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance();
      final y = b.computeLuminance();
      return ((x > y ? x : y) + 0.05) / ((x > y ? y : x) + 0.05);
    }

    for (final brightness in Brightness.values) {
      final s = buildTheme(brightness).colorScheme;
      for (final pair in [
        (s.primary, s.surface),
        (s.secondary, s.surface),
        (s.tertiary, s.surface),
        (s.onSurfaceVariant, s.surface),
        (s.onPrimaryContainer, s.primaryContainer),
        (s.onSecondaryContainer, s.secondaryContainer),
        (s.onTertiaryContainer, s.tertiaryContainer),
      ]) {
        expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
      }
    }
  });

  test('mention colour: green by default, off, any accent', () {
    expect(parseMentionColor(null)!.id, 'green');
    expect(parseMentionColor('мусор')!.id, 'green');
    expect(parseMentionColor(mentionOff), isNull);
    expect(parseMentionColor('blue')!.id, 'blue');
  });

  test('mention bubble equals own bubble when colours match', () {
    final seed = parseAccent('blue').color;
    expect(
      mentionBubble(seed, Brightness.dark),
      buildTheme(Brightness.dark, seed: seed).colorScheme.primaryContainer,
    );
  });
}
