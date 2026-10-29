import 'dart:ui';

import 'package:etohost_mesh/mirror/avatar_frames.dart';
import 'package:etohost_mesh/mirror/mirror_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('css colors', () {
    expect(parseCssColor('#ffd700'), const Color(0xFFFFD700));
    expect(parseCssColor('#fff'), const Color(0xFFFFFFFF));
    expect(parseCssColor('#11223380'), const Color(0x80112233));
    expect(parseCssColor('red'), isNull);
    expect(parseCssColor(null), isNull);
  });

  test('chatty ranks: bad entries skipped', () {
    final r = parseChattyRanks({
      '!0000000a': {'rank': 1, 'days': 30},
      'oops': {'rank': 2, 'days': 7},
      '!0000000b': {'rank': 'x'},
    });
    expect(r, {10: (rank: 1, days: 30)});
  });

  test('custom frame parse', () {
    final f = parseCustomFrames({
      '!0000000a': {
        'style': 'gradient',
        'color1': '#0068ff',
        'color2': '#ff00fc',
        'gradient_angle': 90,
        'border_width': 3,
        'animation': 'rotate',
        'badge_text': 'A',
        'badge_color': '#14171c',
        'badge_text_color': '#ff00e7',
        'tooltip_text': 'Admin',
      },
      '!0000000b': {'color1': null},
    });
    expect(f.keys, [10]);
    final d = f[10]!.decor;
    expect(d.colors, [const Color(0xFF0068FF), const Color(0xFFFF00FC)]);
    expect(d.animation, FrameAnimation.rotate);
    expect(d.width, 3);
    expect(d.badge, 'A');
    expect(d.badgeFg, const Color(0xFFFF00E7));
    expect(d.tooltip, 'Admin');
  });

  test('solid frame ignores color2; badge colors default to color1', () {
    final d = CustomFrame.tryParse({
      'style': 'solid',
      'color1': '#ffffff',
      'color2': '#000000',
    })!.decor;
    expect(d.colors, [const Color(0xFFFFFFFF)]);
    expect(d.badge, isNull);
    expect(d.badgeFg, const Color(0xFFFFFFFF));
  });

  test('custom frame wins over rank', () {
    final frames = AvatarFrames(
      ranks: {1: (rank: 1, days: 7), 2: (rank: 3, days: 90)},
      custom: {
        1: CustomFrame.tryParse({'color1': '#ff0000'})!,
      },
    );
    expect(frames.decorFor(1)!.colors, [const Color(0xFFFF0000)]);
    final r = frames.decorFor(2)!;
    expect(r.colors, [const Color(0xFFCD7F32)]);
    expect(r.badge, '90');
    expect(r.tooltip, 'Топ-3 болтливых за 90 дн.');
    expect(frames.decorFor(3), isNull);
  });

  test('ws events', () {
    final init = MirrorEvent.parse({
      'type': 'init',
      'messages': [],
      'chatty_ranks': {
        '!0000000a': {'rank': 2, 'days': 7},
      },
    });
    expect(init, isA<MirrorInit>());
    expect((init as MirrorInit).ranks, {10: (rank: 2, days: 7)});
    expect(init.frames, isNull);
    expect(
      MirrorEvent.parse({'type': 'chatty_ranks', 'ranks': {}}),
      isA<MirrorChattyRanks>(),
    );
    expect(
      MirrorEvent.parse({'type': 'avatar_frames', 'frames': {}}),
      isA<MirrorAvatarFrames>(),
    );
  });
}
