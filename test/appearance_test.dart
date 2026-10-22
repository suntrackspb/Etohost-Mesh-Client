import 'package:etohost_mesh/data/appearance.dart';
import 'package:etohost_mesh/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('theme setting parses, unknown is system', () {
    expect(AppTheme.parse('black'), AppTheme.black);
    expect(AppTheme.parse('dark'), AppTheme.dark);
    expect(AppTheme.parse(null), AppTheme.system);
    expect(AppTheme.parse('мусор'), AppTheme.system);
  });

  test('accent parses, unknown is teal', () {
    expect(parseAccent('green').color, const Color(0xFF22C55E));
    expect(parseAccent(null).id, 'teal');
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
}
