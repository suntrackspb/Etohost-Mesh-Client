import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/mqtt_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('публичный сервер — по хосту, не по подстроке', () {
    expect(MqttSection.usesPublicServer('mqtt.meshtastic.org'), isTrue);
    expect(MqttSection.usesPublicServer(' MQTT.meshtastic.org:1883'), isTrue);
    expect(
      MqttSection.usesPublicServer('mqtt.meshtastic.org.example.com'),
      isFalse,
    );
  });

  test('TLS обязателен с 2.7.4', () {
    expect(MqttSection.tlsRequired('2.7.3.abc'), isFalse);
    expect(MqttSection.tlsRequired('2.7.4.abc'), isTrue);
    expect(MqttSection.tlsRequired('2.8.0'), isTrue);
  });

  test('read нормализует интервал, точность и корневую тему', () {
    final v = MqttSection.read(
      ModuleConfig_MQTTConfig(
        mapReportSettings: ModuleConfig_MapReportSettings(
          publishIntervalSecs: 60,
          positionPrecision: 32,
        ),
      ),
    );
    expect(v['publishIntervalSecs'], 3600);
    expect(v['positionPrecision'], 14);
    expect(v['root'], 'msh');
  });

  test('публичный сервер: свои учётные данные и TLS по прошивке', () {
    final base = ModuleConfig_MQTTConfig(jsonEnabled: true);
    final v = MqttSection.read(base)
      ..['address'] = 'mqtt.meshtastic.org'
      ..['username'] = 'x'
      ..['tlsEnabled'] = false;
    MqttSection.adjust(v);
    expect(v['username'], MqttSection.publicUser);
    final old = MqttSection.apply(base, v, firmware: '2.7.3');
    expect(old.tlsEnabled, isFalse);
    final now = MqttSection.apply(base, v, firmware: '2.8.0');
    expect(now.tlsEnabled, isTrue);
    expect(now.password, MqttSection.publicPassword);
  });

  test('свой сервер: TLS и данные как ввели', () {
    final v = MqttSection.read(ModuleConfig_MQTTConfig())
      ..['address'] = 'mqtt.example.org'
      ..['username'] = 'u'
      ..['password'] = 'p'
      ..['tlsEnabled'] = true;
    final out = MqttSection.apply(
      ModuleConfig_MQTTConfig(),
      v,
      firmware: '2.8.0',
    );
    expect([out.username, out.password, out.tlsEnabled], ['u', 'p', true]);
  });

  test('подписи точности', () {
    expect(MqttSection.precisionLabel(12), 'В пределах 5,8 км');
    expect(MqttSection.precisionLabel(15), 'В пределах 730 м');
  });
}
