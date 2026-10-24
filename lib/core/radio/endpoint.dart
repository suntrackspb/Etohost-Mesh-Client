import '../transport/ble_transport.dart';
import '../transport/serial_transport.dart';
import '../transport/tcp_transport.dart';
import 'radio_session.dart';

enum EndpointKind { ble, tcp, serial }

/// Куда подключаться — в виде, который можно сохранить и восстановить
/// (недавние подключения, автоподключение при запуске).
class Endpoint {
  const Endpoint(this.kind, this.address, this.name);

  final EndpointKind kind;

  /// BLE — deviceId; TCP — `host:port`; Serial — имя порта / deviceId.
  final String address;
  final String name;

  String get title => '${kind.label} ${name.isEmpty ? address : name}';

  RadioTarget toTarget() => RadioTarget(title, switch (kind) {
    EndpointKind.ble => (log) => BleTransport(address, name, log),
    EndpointKind.tcp => (_) {
      final (host, port) = splitHostPort(address);
      return TcpTransport(host, port: port);
    },
    EndpointKind.serial => (_) => SerialTransport(
      SerialPortInfo(id: address, title: name),
    ),
  }, endpoint: this);
}

extension EndpointKindLabel on EndpointKind {
  String get label => switch (this) {
    EndpointKind.ble => 'BLE',
    EndpointKind.tcp => 'TCP',
    EndpointKind.serial => 'USB',
  };
}

/// `host`, `host:port`, `[v6]:port` → (host, port); порт по умолчанию 4403.
(String, int) splitHostPort(String s, {int defaultPort = 4403}) {
  s = s.trim();
  if (s.startsWith('[')) {
    final end = s.indexOf(']');
    if (end > 0) {
      final host = s.substring(1, end);
      final rest = s.substring(end + 1);
      return (
        host,
        rest.startsWith(':')
            ? int.tryParse(rest.substring(1)) ?? defaultPort
            : defaultPort,
      );
    }
  }
  final i = s.lastIndexOf(':');
  // Больше одного двоеточия без скобок — голый IPv6 без порта.
  if (i > 0 && s.indexOf(':') == i) {
    return (s.substring(0, i), int.tryParse(s.substring(i + 1)) ?? defaultPort);
  }
  return (s, defaultPort);
}

/// Состояние соединения для плашки [kind]/[address] в списке подключений:
/// `null`, если сессия не про неё или отключена.
RadioState? endpointLinkState(
  Endpoint? current,
  RadioState state,
  EndpointKind kind,
  String address,
) {
  if (current == null || state == RadioState.idle) return null;
  if (current.kind != kind || current.address != address) return null;
  return state;
}
