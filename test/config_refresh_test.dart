import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/data/settings/admin_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('раздел конфига → тип get_config', () {
    expect(
      configTypeOf(Config(lora: Config_LoRaConfig())),
      AdminMessage_ConfigType.LORA_CONFIG,
    );
    expect(
      configTypeOf(Config(security: Config_SecurityConfig())),
      AdminMessage_ConfigType.SECURITY_CONFIG,
    );
    expect(configTypeOf(Config()), isNull);
  });

  test('раздел модуля → тип get_module_config', () {
    expect(
      moduleTypeOf(ModuleConfig(mqtt: ModuleConfig_MQTTConfig())),
      AdminMessage_ModuleConfigType.MQTT_CONFIG,
    );
    expect(
      moduleTypeOf(
        ModuleConfig(
          externalNotification: ModuleConfig_ExternalNotificationConfig(),
        ),
      ),
      AdminMessage_ModuleConfigType.EXTNOTIF_CONFIG,
    );
    expect(
      moduleTypeOf(ModuleConfig(tak: ModuleConfig_TAKConfig())),
      AdminMessage_ModuleConfigType.TAK_CONFIG,
    );
  });
}
