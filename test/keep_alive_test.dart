import 'package:meshex/core/background/keep_alive.dart';
import 'package:meshex/core/radio/radio_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no service when idle', () {
    expect(keepAliveStatus(RadioState.idle, 'T-Beam'), isNull);
  });

  test('status text follows radio state', () {
    expect(keepAliveStatus(RadioState.ready, 'T-Beam'), (
      title: 'Meshex: T-Beam',
      text: 'Подключено',
    ));
    expect(keepAliveStatus(RadioState.configuring, null)?.text, 'Подключение');
    expect(keepAliveStatus(RadioState.waitingReconnect, '')?.title, 'Meshex');
    expect(
      keepAliveStatus(RadioState.ready, 'X', mqtt: 'Подключено')?.text,
      'Подключено · MQTT: Подключено',
    );
  });
}
