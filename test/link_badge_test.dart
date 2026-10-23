import 'package:etohost_mesh/app/link_badge.dart';
import 'package:etohost_mesh/core/radio/radio_session.dart';
import 'package:etohost_mesh/mirror/mirror_realtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('цвет бейджа по состоянию связи', () {
    expect(linkLevel(RadioState.ready), LinkLevel.connected);
    expect(linkLevel(RadioState.idle), LinkLevel.disconnected);
    for (final s in [
      RadioState.connecting,
      RadioState.configuring,
      RadioState.loadingNodes,
      RadioState.waitingReconnect,
    ]) {
      expect(linkLevel(s), LinkLevel.connecting, reason: '$s');
    }
  });

  test('значок зеркала: нет при выключенном, цвет по состоянию', () {
    expect(mirrorLevel(null), isNull);
    expect(mirrorLevel(MirrorState.connected), LinkLevel.connected);
    expect(mirrorLevel(MirrorState.waiting), LinkLevel.disconnected);
    expect(mirrorLevel(MirrorState.connecting), LinkLevel.connecting);
    expect(mirrorLevel(MirrorState.idle), LinkLevel.connecting);
  });
}
