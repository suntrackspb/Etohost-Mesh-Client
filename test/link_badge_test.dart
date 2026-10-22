import 'package:etohost_mesh/app/link_badge.dart';
import 'package:etohost_mesh/core/radio/radio_session.dart';
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
}
