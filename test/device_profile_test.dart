import 'dart:typed_data';

import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/data/settings/channel_url.dart';
import 'package:etohost_mesh/data/settings/device_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lora = Config_LoRaConfig(
    usePreset: true,
    region: Config_LoRaConfig_RegionCode.RU,
  );
  final source = ProfileSource(
    longName: 'Test node',
    shortName: 'TST',
    configs: {
      'device': Config(device: Config_DeviceConfig(nodeInfoBroadcastSecs: 900)),
      'position': Config(position: Config_PositionConfig(fixedPosition: true)),
      'lora': Config(lora: lora),
      'network': Config(network: Config_NetworkConfig(wifiSsid: 'home')),
      'security': Config(security: Config_SecurityConfig(isManaged: false)),
    },
    modules: {
      'mqtt': ModuleConfig(mqtt: ModuleConfig_MQTTConfig(enabled: true)),
      'telemetry': ModuleConfig(
        telemetry: ModuleConfig_TelemetryConfig(deviceUpdateInterval: 600),
      ),
      'tak': ModuleConfig(tak: ModuleConfig_TAKConfig()),
    },
    channelUrl: ChannelLink.encode(
      ChannelSet(
        settings: [
          ChannelSettings(name: 'A'),
          ChannelSettings(name: 'B'),
        ],
        loraConfig: lora,
      ),
    ),
    fixed: Position(latitudeI: 599000000, longitudeI: 303000000),
    ringtone: 'tone:d=4',
    cannedMessages: 'Да|Нет',
  );

  test('export round-trips through bytes', () {
    final p = buildProfile(source);
    final back = parseProfile(Uint8List.fromList(p.writeToBuffer()));
    expect(back.longName, 'Test node');
    expect(back.config.device.nodeInfoBroadcastSecs, 900);
    expect(back.moduleConfig.telemetry.deviceUpdateInterval, 600);
    expect(back.fixedPosition.latitudeI, 599000000);
    expect(back.cannedMessages, 'Да|Нет');
  });

  test('fixed position only when the flag is on', () {
    final p = buildProfile(
      ProfileSource(fixed: Position(latitudeI: 1, longitudeI: 1)),
    );
    expect(p.hasFixedPosition(), isFalse);
  });

  test('bad files are rejected', () {
    expect(() => parseProfile(Uint8List(0)), throwsFormatException);
    expect(
      () => parseProfile(Uint8List.fromList([0xff, 0xff, 0xff])),
      throwsFormatException,
    );
    expect(
      () => parseProfile(Uint8List(maxProfileBytes + 1)),
      throwsFormatException,
    );
  });

  test('file name', () {
    expect(
      profileFileName('T/1', DateTime(2026, 3, 5)),
      'Meshtastic_T1_20260305_nodeConfig.cfg',
    );
    expect(
      profileFileName(null, DateTime(2026, 3, 5)),
      'Meshtastic_Node_20260305_nodeConfig.cfg',
    );
  });

  test('plan order, gating and after-commit modules', () {
    final plan = planProfile(
      buildProfile(source),
      owner: User(longName: 'Old', shortName: 'OLD', isLicensed: true),
      firmware: '2.7.15',
    );
    final sections = plan.items.map((i) => i.section).toList();
    expect(sections.first, ProfileSection.owner);
    expect(sections.last, ProfileSection.channels);
    expect(
      sections.indexOf(ProfileSection.network),
      lessThan(sections.indexOf(ProfileSection.security)),
    );
    final owner = plan.items.first.messages.single.setOwner;
    expect(owner.longName, 'Test node');
    expect(owner.isLicensed, isTrue);
    expect(plan.unsupported.single, startsWith('TAK'));
    expect(plan.items.where((i) => i.afterCommit).map((i) => i.label), [
      'MQTT',
    ]);
    expect(plan.items.last.messages.length, 9); // 8 слотов + LoRa
    expect(plan.items.last.label, contains("(2)"));
    expect(plan.selected({ProfileSection.owner}).length, 1);
  });

  test('security keeps own keys when the file has none', () {
    final base = Config_SecurityConfig(
      privateKey: [1],
      publicKey: [2],
      adminKey: [
        [3],
      ],
    );
    final m = mergeSecurity(Config_SecurityConfig(), base);
    expect(m.privateKey, [1]);
    expect(m.adminKey.single, [3]);
    final own = mergeSecurity(Config_SecurityConfig(privateKey: [9]), base);
    expect(own.privateKey, [9]);
  });

  test('apply: begin twice, commit, then after-commit items', () async {
    final plan = planProfile(buildProfile(source), owner: User());
    final log = <String>[];
    final r = await applyProfile(
      plan.items,
      send: (m) async {
        log.add(
          m.hasBeginEditSettings()
              ? 'begin'
              : m.hasCommitEditSettings()
              ? 'commit'
              : m.hasSetModuleConfig() && m.setModuleConfig.hasMqtt()
              ? 'mqtt'
              : 'x',
        );
        return true;
      },
      sleep: (_) async {},
    );
    expect(r.ok, isTrue);
    expect(log.take(2), ['begin', 'begin']);
    expect(log.sublist(log.length - 2), ['commit', 'mqtt']);
  });

  test('apply stops on the first refusal', () async {
    final plan = planProfile(buildProfile(source), owner: User());
    var n = 0;
    final r = await applyProfile(
      plan.items,
      send: (m) async => m.hasBeginEditSettings() || ++n < 2,
      sleep: (_) async {},
    );
    expect(r.ok, isFalse);
    expect(r.committed, isFalse);
    expect(r.sent, 1);
  });

  test('unchanged MQTT is not sent', () {
    final plan = planProfile(
      buildProfile(source),
      owner: User(),
      currentModules: {'mqtt': source.modules['mqtt']!},
    );
    expect(plan.items.where((i) => i.afterCommit), isEmpty);
  });

  test('after commit: no link — pending, not failed', () async {
    final plan = planProfile(buildProfile(source), owner: User());
    final r = await applyProfile(
      plan.items,
      send: (m) async {
        if (m.hasSetModuleConfig() && m.setModuleConfig.hasMqtt()) {
          throw StateError('link lost');
        }
        return true;
      },
      sleep: (_) async {},
    );
    expect(r.failed, isNull);
    expect(r.committed, isTrue);
    expect(r.pending, ['MQTT']);
  });

  test('Bluetooth is never restored', () {
    final p = buildProfile(
      ProfileSource(
        configs: {
          'bluetooth': Config(bluetooth: Config_BluetoothConfig(enabled: true)),
        },
      ),
    );
    expect(p.config.hasBluetooth(), isTrue); // в файл попадает
    expect(planProfile(p).items, isEmpty);
  });
}
