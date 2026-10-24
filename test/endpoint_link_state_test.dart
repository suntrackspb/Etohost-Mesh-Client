import 'package:etohost_mesh/core/radio/endpoint.dart';
import 'package:etohost_mesh/core/radio/radio_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ble = Endpoint(EndpointKind.ble, 'AA:BB', 'SUNe');

  test('плашка текущей ноды получает состояние сессии', () {
    expect(
      endpointLinkState(ble, RadioState.connecting, EndpointKind.ble, 'AA:BB'),
      RadioState.connecting,
    );
    expect(
      endpointLinkState(ble, RadioState.ready, EndpointKind.ble, 'AA:BB'),
      RadioState.ready,
    );
  });

  test('другая нода, другой транспорт или отключено — null', () {
    expect(
      endpointLinkState(ble, RadioState.ready, EndpointKind.ble, 'CC:DD'),
      isNull,
    );
    expect(
      endpointLinkState(ble, RadioState.ready, EndpointKind.tcp, 'AA:BB'),
      isNull,
    );
    expect(
      endpointLinkState(ble, RadioState.idle, EndpointKind.ble, 'AA:BB'),
      isNull,
    );
    expect(
      endpointLinkState(null, RadioState.ready, EndpointKind.ble, 'AA:BB'),
      isNull,
    );
  });
}
