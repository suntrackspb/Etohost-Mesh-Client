import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

import '../../core/proto/generated/meshtastic/clientonly.pb.dart';
import '../../core/proto/generated/meshtastic/localonly.pb.dart';
import '../../core/proto/mesh.dart';
import 'channel_url.dart';
import 'user_section.dart' show firmwareAtLeast;

export '../../core/proto/generated/meshtastic/clientonly.pb.dart'
    show DeviceProfile;

/// Резервная копия конфигурации ноды: файл `.cfg` — protobuf DeviceProfile,
/// тот же формат, что у официальных iOS/Android и CLI (`--export-config`
/// пишет YAML, его не делаем). Порядок и правила восстановления — как в
/// Meshtastic-Apple (DeviceProfileImport/Importer).

/// Модули без команды сохранения в прошивке — не выгружаем и не шлём.
const _skipModules = {'remoteHardware', 'meshBeacon'};

/// Что есть у ноды для копии (из своей БД).
class ProfileSource {
  const ProfileSource({
    this.longName,
    this.shortName,
    this.isUnmessagable = false,
    this.configs = const {},
    this.modules = const {},
    this.channelUrl,
    this.fixed,
    this.ringtone = '',
    this.cannedMessages = '',
  });

  final String? longName;
  final String? shortName;
  final bool isUnmessagable;

  /// Разделы Config по имени варианта (`device`, `lora`, …).
  final Map<String, Config> configs;

  /// Разделы ModuleConfig по имени варианта (`mqtt`, `serial`, …).
  final Map<String, ModuleConfig> modules;
  final String? channelUrl;

  /// Координаты — только если у ноды включена фиксированная позиция.
  final Position? fixed;
  final String ringtone;
  final String cannedMessages;
}

/// Собрать DeviceProfile (как exportDeviceProfile в iOS).
DeviceProfile buildProfile(ProfileSource s) {
  final local = LocalConfig();
  for (final c in s.configs.values) {
    _copyVariant(c, local);
  }
  final modules = LocalModuleConfig();
  for (final e in s.modules.entries) {
    if (_skipModules.contains(e.key)) continue;
    _copyVariant(e.value, modules);
  }
  final p = DeviceProfile(config: local, moduleConfig: modules);
  if (s.longName != null) p.longName = s.longName!;
  if (s.shortName != null) p.shortName = s.shortName!;
  p.isUnmessagable = s.isUnmessagable;
  if (s.channelUrl != null && s.channelUrl!.isNotEmpty) {
    p.channelUrl = s.channelUrl!;
  }
  final fixedOn = s.configs['position']?.position.fixedPosition ?? false;
  final f = s.fixed;
  if (fixedOn && f != null && (f.latitudeI != 0 || f.longitudeI != 0)) {
    p.fixedPosition = Position(
      latitudeI: f.latitudeI,
      longitudeI: f.longitudeI,
      altitude: f.altitude,
    );
  }
  if (s.ringtone.isNotEmpty) p.ringtone = s.ringtone;
  if (s.cannedMessages.isNotEmpty) p.cannedMessages = s.cannedMessages;
  return p;
}

/// Вариант oneof из [from] (Config/ModuleConfig) в одноимённое поле [to]
/// (LocalConfig/LocalModuleConfig).
void _copyVariant(GeneratedMessage from, GeneratedMessage to) {
  for (final f in from.info_.fieldInfo.values) {
    if (!from.hasField(f.tagNumber)) continue;
    final target = to.info_.byName[f.name];
    if (target == null) continue;
    to.setField(target.tagNumber, from.getField(f.tagNumber));
  }
}

/// Варианты LocalConfig/LocalModuleConfig в виде отдельных Config/ModuleConfig.
Map<String, T> _split<T extends GeneratedMessage>(
  GeneratedMessage local,
  T Function() create,
) {
  final out = <String, T>{};
  final probe = create();
  for (final f in local.info_.fieldInfo.values) {
    if (!local.hasField(f.tagNumber)) continue;
    final target = probe.info_.byName[f.name];
    if (target == null) continue;
    out[f.name] = create()
      ..setField(target.tagNumber, local.getField(f.tagNumber));
  }
  return out;
}

/// Имя файла как у iOS/Android: `Meshtastic_<short>_<yyyyMMdd>_nodeConfig.cfg`.
String profileFileName(String? shortName, DateTime now) {
  final safe = (shortName ?? '').replaceAll(
    RegExp(r'[^\p{L}\p{N}_-]', unicode: true),
    '',
  );
  String two(int v) => v.toString().padLeft(2, '0');
  final date = '${now.year}${two(now.month)}${two(now.day)}';
  return 'Meshtastic_${safe.isEmpty ? 'Node' : safe}_${date}_nodeConfig.cfg';
}

/// Настоящий профиль — несколько КБ; больше — не профиль.
const maxProfileBytes = 256 * 1024;

/// Разобрать чужой файл. FormatException — не конфигурация Meshtastic.
DeviceProfile parseProfile(Uint8List bytes) {
  if (bytes.isEmpty) throw const FormatException('Файл пустой');
  if (bytes.length > maxProfileBytes) {
    throw const FormatException('Файл слишком большой для конфигурации');
  }
  try {
    return DeviceProfile.fromBuffer(bytes);
  } on InvalidProtocolBufferException {
    throw const FormatException('Это не файл конфигурации Meshtastic');
  }
}

/// Группы, которые можно выключить перед восстановлением (как в iOS).
enum ProfileSection {
  owner('Владелец'),
  device('Настройки устройства'),
  modules('Настройки модуля'),
  personalization('Рингтон и сохраненные сообщения'),
  fixedPosition('Фиксированная позиция'),
  network('Сеть'),
  security('Безопасность'),
  channels('Каналы и LoRa');

  const ProfileSection(this.title);
  final String title;

  /// Безопасность — только по явному выбору: чужой приватный ключ меняет
  /// личность ноды и доверие админ-ключам.
  bool get defaultOn => this != security;
}

/// Одна команда восстановления.
class ProfileItem {
  const ProfileItem(
    this.section,
    this.label,
    this.messages, {
    this.afterCommit = false,
    this.sensitive = false,
  });

  final ProfileSection section;
  final String label;
  final List<AdminMessage> messages;

  /// MQTT и Serial: прошивка рвёт Bluetooth на них даже внутри транзакции
  /// (AdminModule.cpp) — шлём после commit, чтобы остальное уже сохранилось.
  final bool afterCommit;

  /// Пароли/ключи — для подсказки в списке.
  final bool sensitive;
}

/// План восстановления: что отправим и что эта прошивка не примет.
class ProfilePlan {
  const ProfilePlan(this.items, this.unsupported);
  final List<ProfileItem> items;
  final List<String> unsupported;

  Set<ProfileSection> get sections => {for (final i in items) i.section};

  List<ProfileItem> selected(Set<ProfileSection> on) => [
    for (final i in items)
      if (on.contains(i.section)) i,
  ];
}

const _moduleLabels = {
  'mqtt': 'MQTT',
  'serial': 'Серийный порт',
  'externalNotification': 'Внешние уведомления',
  'storeForward': 'Хранение и пересылка',
  'rangeTest': 'Проверка дальности',
  'telemetry': 'Телеметрия',
  'cannedMessage': 'Сохраненные сообщения',
  'audio': 'Звук',
  'neighborInfo': 'Информация о соседях',
  'ambientLighting': 'Окружающее освещение',
  'detectionSensor': 'Датчик обнаружения',
  'paxcounter': 'Счетчик прохожих',
  'statusmessage': 'Статус',
  'trafficManagement': 'Управление движением',
  'tak': 'TAK',
};

const _configLabels = {
  'device': 'Устройство',
  'display': 'Дисплей',
  'position': 'Местоположение',
  'power': 'Питание',
  'network': 'Сеть',
  'bluetooth': 'Bluetooth',
  'security': 'Безопасность',
  'lora': 'LoRa',
};

/// Почему прошивка [fw] не применит модуль; null — применит. Прошивка
/// отвечает «успех» и на неизвестный модуль, поэтому проверяем заранее.
String? _moduleUnsupported(String name, String fw) => switch (name) {
  'tak' => 'не поддерживается прошивкой',
  'statusmessage' when fw.isNotEmpty && !firmwareAtLeast(fw, 2, 7, 20) =>
    'нужна прошивка 2.7.20+',
  'trafficManagement' when fw.isNotEmpty && !firmwareAtLeast(fw, 2, 8) =>
    'нужна прошивка 2.8+',
  _ => null,
};

/// Ключи ноды сохраняются, если в файле их нет (частичный/«событийный»
/// конфиг): пустой ключ не бывает личностью. Админ-ключи — так же.
Config_SecurityConfig mergeSecurity(
  Config_SecurityConfig from,
  Config_SecurityConfig? base,
) {
  final s = from.deepCopy();
  if (base == null) return s;
  if (s.privateKey.isEmpty && s.publicKey.isEmpty) {
    s
      ..privateKey = base.privateKey
      ..publicKey = base.publicKey;
  }
  if (s.adminKey.every((k) => k.isEmpty)) {
    s.adminKey
      ..clear()
      ..addAll(base.adminKey);
  }
  return s;
}

/// Построить план (порядок — как в iOS: владелец, устройство, модули,
/// тексты, фикс. позиция, сеть, Bluetooth, безопасность, каналы и LoRa
/// последними — они меняют связь, по которой идёт восстановление).
/// [owner] — текущий пользователь ноды: имена из файла кладём поверх него.
ProfilePlan planProfile(
  DeviceProfile p, {
  User? owner,
  Config_SecurityConfig? security,
  String firmware = '',
  Map<String, ModuleConfig> currentModules = const {},
}) {
  final items = <ProfileItem>[];
  final unsupported = <String>[];
  final configs = p.hasConfig()
      ? _split(p.config, Config.new)
      : <String, Config>{};
  final modules = p.hasModuleConfig()
      ? _split(p.moduleConfig, ModuleConfig.new)
      : <String, ModuleConfig>{};

  if ((p.hasLongName() || p.hasShortName()) && owner != null) {
    final u = owner.deepCopy();
    if (p.hasLongName() && p.longName.isNotEmpty) u.longName = p.longName;
    if (p.hasShortName() && p.shortName.isNotEmpty) u.shortName = p.shortName;
    if (p.hasIsUnmessagable()) u.isUnmessagable = p.isUnmessagable;
    // is_licensed не трогаем: режим радиолюбителя — отдельная процедура.
    items.add(
      ProfileItem(ProfileSection.owner, 'Владелец: ${u.longName}', [
        AdminMessage(setOwner: u),
      ]),
    );
  }

  for (final name in ['device', 'display', 'position', 'power']) {
    final c = configs[name];
    if (c == null) continue;
    items.add(
      ProfileItem(ProfileSection.device, _configLabels[name]!, [
        AdminMessage(setConfig: c),
      ]),
    );
  }

  for (final e in modules.entries) {
    if (_skipModules.contains(e.key)) continue;
    final label = _moduleLabels[e.key] ?? e.key;
    final why = _moduleUnsupported(e.key, firmware);
    if (why != null) {
      unsupported.add('$label — $why');
      continue;
    }
    final after = e.key == 'mqtt' || e.key == 'serial';
    // MQTT/Serial рвут Bluetooth — без изменений их не шлём.
    if (after && currentModules[e.key] == e.value) continue;
    items.add(
      ProfileItem(
        ProfileSection.modules,
        label,
        [AdminMessage(setModuleConfig: e.value)],
        afterCommit: after,
        sensitive: e.key == 'mqtt',
      ),
    );
  }

  // После модуля сохранённых сообщений — чтобы он не затёр текст.
  if (p.hasRingtone() && p.ringtone.isNotEmpty) {
    items.add(
      ProfileItem(ProfileSection.personalization, 'Рингтон', [
        AdminMessage(setRingtoneMessage: p.ringtone),
      ]),
    );
  }
  if (p.hasCannedMessages() && p.cannedMessages.isNotEmpty) {
    items.add(
      ProfileItem(ProfileSection.personalization, 'Сохраненные сообщения', [
        AdminMessage(setCannedMessageModuleMessages: p.cannedMessages),
      ]),
    );
  }

  // После настроек местоположения — они несут флаг fixed_position.
  if (p.hasFixedPosition() &&
      (p.fixedPosition.latitudeI != 0 || p.fixedPosition.longitudeI != 0)) {
    items.add(
      ProfileItem(ProfileSection.fixedPosition, 'Фиксированная позиция', [
        AdminMessage(setFixedPosition: p.fixedPosition),
      ]),
    );
  }

  // Сеть поздно: включение Wi-Fi может уронить TCP-подключение.
  final network = configs['network'];
  if (network != null) {
    final ssid = network.network.wifiSsid;
    items.add(
      ProfileItem(
        ProfileSection.network,
        ssid.isEmpty ? 'Wi-Fi / Ethernet' : 'Wi-Fi: $ssid',
        [AdminMessage(setConfig: network)],
        sensitive: true,
      ),
    );
  }
  // Bluetooth не восстанавливаем: смена режима/PIN (и даже запись того же)
  // ломает сопряжение с телефоном, а оно у пользователя уже настроено.
  final sec = configs['security'];
  if (sec != null) {
    final merged = mergeSecurity(sec.security, security);
    final keeps =
        security != null &&
        sec.security.privateKey.isEmpty &&
        sec.security.publicKey.isEmpty;
    items.add(
      ProfileItem(
        ProfileSection.security,
        keeps
            ? 'Админ-доступ и флаги (ключи ноды сохранятся)'
            : 'Ключи ноды и админ-доступ',
        [AdminMessage(setConfig: Config(security: merged))],
        sensitive: true,
      ),
    );
  }

  // Каналы и LoRa: ссылка несёт и каналы, и LoRa — берём её; полный LoRa из
  // конфига точнее (в ссылке те же поля). Нет ссылки — только LoRa.
  final lora = configs['lora']?.lora;
  ChannelSet? set;
  if (p.hasChannelUrl() && p.channelUrl.isNotEmpty) {
    try {
      final link = ChannelLink.parse(p.channelUrl);
      if (!link.add && link.set.hasLoraConfig()) set = link.set;
    } on FormatException {
      set = null;
    }
  }
  if (set != null) {
    final plan = ChannelImport.plan(set, const [], null, add: false);
    if (plan.ok) {
      items.add(
        ProfileItem(
          ProfileSection.channels,
          'Каналы (${plan.usedSlots}) и LoRa',
          [
            for (final c in plan.channels) AdminMessage(setChannel: c),
            AdminMessage(setConfig: Config(lora: lora ?? plan.lora)),
          ],
          sensitive: true,
        ),
      );
    } else {
      set = null;
    }
  }
  if (set == null && lora != null) {
    items.add(
      ProfileItem(ProfileSection.channels, 'LoRa: ${lora.region.name}', [
        AdminMessage(setConfig: Config(lora: lora)),
      ]),
    );
  }

  return ProfilePlan(items, unsupported);
}

/// Итог восстановления.
class ProfileResult {
  const ProfileResult({
    required this.sent,
    this.failed,
    this.error,
    this.committed = false,
    this.pending = const [],
  });

  /// Сколько команд нода подтвердила.
  final int sent;

  /// На чём остановились (null — всё прошло).
  final String? failed;
  final Object? error;

  /// commit_edit_settings отправлен — основная часть сохранена.
  final bool committed;

  /// Не дослали после commit: связь оборвалась.
  final List<String> pending;

  bool get ok => failed == null && pending.isEmpty;
}

/// Пауза между командами: без неё нода теряет часть записей и всё равно
/// отвечает ACK (замер iOS на Heltec V4).
const profileSendInterval = Duration(milliseconds: 150);

/// Применить план: begin_edit (дважды — нода его не подтверждает, потерянный
/// begin превращает всё в отдельные записи с перезагрузками) → команды →
/// commit → MQTT/Serial. Останавливается на первой ошибке.
/// По BLE commit выключает Bluetooth, и MQTT/Serial не уходят — они в
/// [ProfileResult.pending]. Сами не досылаем: запись MQTT по BLE сбрасывает
/// сопряжение ноды с телефоном (проверено на T3S3, 2.7.26).
Future<ProfileResult> applyProfile(
  List<ProfileItem> items, {
  required Future<bool> Function(AdminMessage m) send,
  Future<void> Function(Duration d) sleep = Future<void>.delayed,
  void Function(int done, int total, String label)? progress,
}) async {
  final inside = [
    for (final i in items)
      if (!i.afterCommit) i,
  ];
  final after = [
    for (final i in items)
      if (i.afterCommit) i,
  ];
  final total = items.length;
  var done = 0;
  var sent = 0;

  Future<ProfileResult?> run(ProfileItem item, bool committed) async {
    progress?.call(done, total, item.label);
    try {
      for (final m in item.messages) {
        if (!await send(m)) {
          return ProfileResult(
            sent: sent,
            failed: item.label,
            committed: committed,
          );
        }
        sent++;
        await sleep(profileSendInterval);
      }
    } catch (e) {
      return ProfileResult(
        sent: sent,
        failed: item.label,
        error: e,
        committed: committed,
      );
    }
    done++;
    return null;
  }

  try {
    await send(AdminMessage(beginEditSettings: true));
    await sleep(profileSendInterval);
    await send(AdminMessage(beginEditSettings: true));
    await sleep(profileSendInterval);
  } catch (e) {
    return ProfileResult(sent: 0, failed: 'Начало редактирования', error: e);
  }
  for (final item in inside) {
    final r = await run(item, false);
    if (r != null) return r;
  }
  progress?.call(done, total, 'Сохранение на ноде');
  try {
    // Нода сохраняет и уходит в перезагрузку — ACK может не успеть.
    await send(AdminMessage(commitEditSettings: true));
  } catch (_) {}
  for (var k = 0; k < after.length; k++) {
    final r = await run(after[k], true);
    if (r == null) continue;
    // Обрыв связи — не ошибка: остальное уже сохранено (так и iOS).
    if (r.error != null) {
      return ProfileResult(
        sent: sent,
        committed: true,
        pending: [for (final i in after.skip(k)) i.label],
      );
    }
    return r;
  }
  progress?.call(total, total, '');
  return ProfileResult(sent: sent, committed: true);
}
