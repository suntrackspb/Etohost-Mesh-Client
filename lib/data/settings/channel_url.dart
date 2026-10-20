import 'dart:convert';

import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'channel_edit.dart';

/// Ссылка на набор каналов `https://meshtastic.org/e/#<ChannelSet>`
/// (MeshtasticChannelURL.swift, iOS). `add=true` в query или во фрагменте —
/// добавить каналы, иначе заменить (с LoRa из ссылки).
class ChannelLink {
  const ChannelLink(this.set, {required this.add});

  final ChannelSet set;
  final bool add;

  static const prefix = 'https://meshtastic.org/e/';
  static const _maxPayload = 16 * 1024;

  static String encode(ChannelSet set, {bool add = false}) {
    final s = set.deepCopy();
    if (add) s.clearLoraConfig();
    final payload = base64Url.encode(s.writeToBuffer()).replaceAll('=', '');
    return '$prefix${add ? '?add=true' : ''}#$payload';
  }

  /// Ссылка или голый base64; ошибка — [FormatException] с текстом для UI.
  static ChannelLink parse(String text, {bool defaultAdd = false}) {
    final t = text.trim().replaceAll(RegExp(r'^<|>$'), '');
    if (t.isEmpty) throw const FormatException('Ссылка пуста');
    var payload = t;
    var add = defaultAdd;
    final uri = Uri.tryParse(t);
    if (uri != null && (uri.hasScheme || uri.host.isNotEmpty)) {
      if (!_isChannelUri(uri)) {
        throw const FormatException('Это не ссылка на каналы Meshtastic');
      }
      final parts = uri.fragment.split('?');
      payload = parts.first;
      add =
          _flag(parts.length > 1 ? parts[1] : null) ??
          _flag(uri.query) ??
          defaultAdd;
    }
    if (payload.isEmpty) {
      throw const FormatException('В ссылке нет данных каналов');
    }
    if (payload.length > _maxPayload) {
      throw const FormatException('Ссылка слишком длинная');
    }
    final List<int> bytes;
    try {
      bytes = base64Url.decode(
        base64Url.normalize(payload.replaceAll('+', '-').replaceAll('/', '_')),
      );
    } on FormatException {
      throw const FormatException('Неверные данные каналов в ссылке');
    }
    final ChannelSet set;
    try {
      set = ChannelSet.fromBuffer(bytes);
    } catch (_) {
      throw const FormatException('Не удалось прочитать данные каналов');
    }
    if (add) set.clearLoraConfig();
    return ChannelLink(set, add: add);
  }

  static bool _isChannelUri(Uri u) {
    if (u.userInfo.isNotEmpty || u.hasPort) return false;
    final segs = [
      for (final s in u.pathSegments)
        if (s.isNotEmpty) s.toLowerCase(),
    ];
    final scheme = u.scheme.toLowerCase();
    if (scheme == 'meshtastic') {
      return u.host.isEmpty
          ? segs.length == 1 && segs.first == 'e'
          : u.host.toLowerCase() == 'e' && segs.isEmpty;
    }
    final host = u.host.toLowerCase();
    return scheme == 'https' &&
        (host == 'meshtastic.org' || host == 'www.meshtastic.org') &&
        segs.length == 1 &&
        segs.first == 'e';
  }

  static bool? _flag(String? query) {
    if (query == null || query.isEmpty) return null;
    for (final pair in query.split('&')) {
      final kv = pair.split('=');
      if (kv.first.toLowerCase() != 'add') continue;
      final raw = kv.length > 1 ? Uri.decodeComponent(kv[1]) : 'true';
      return switch (raw.toLowerCase()) {
        '1' || 'true' || 'yes' => true,
        '0' || 'false' || 'no' => false,
        _ => null,
      };
    }
    return null;
  }
}

/// Что отправить в ноду при импорте: каналы по слотам и (при замене) LoRa.
class ChannelImportPlan {
  const ChannelImportPlan({
    required this.channels,
    this.lora,
    this.error,
    this.usedSlots = 0,
  });

  final List<Channel> channels;
  final Config_LoRaConfig? lora;

  /// Почему импорт невозможен; null — можно.
  final String? error;

  /// Сколько из 8 слотов будет занято.
  final int usedSlots;

  bool get ok => error == null;
}

abstract final class ChannelImport {
  static const maxSlots = ChannelEdit.maxSlots;

  /// Канал из ссылки в слот [index]. Без moduleSettings прошивка поставит
  /// точность 32 и раскроет координаты — явно 0, как в iOS.
  static Channel channel(ChannelSettings s, int index) {
    final settings = s.deepCopy();
    if (!s.hasModuleSettings()) {
      settings.moduleSettings = ModuleSettings(positionPrecision: 0);
    }
    return Channel(
      index: index,
      role: index == 0 ? Channel_Role.PRIMARY : Channel_Role.SECONDARY,
      settings: settings,
    );
  }

  static ChannelImportPlan plan(
    ChannelSet set,
    Iterable<MeshChannel> current,
    Config_LoRaConfig? currentLora, {
    required bool add,
  }) {
    final incoming = set.settings;
    if (incoming.isEmpty) {
      return const ChannelImportPlan(
        channels: [],
        error: 'В ссылке нет каналов',
      );
    }
    final names = incoming.map((s) => s.name).toList();
    if (names.toSet().length != names.length) {
      return const ChannelImportPlan(
        channels: [],
        error: 'Имена каналов в ссылке повторяются',
      );
    }
    if (add) return _planAdd(incoming, current);
    if (incoming.length > maxSlots) {
      return const ChannelImportPlan(
        channels: [],
        error: 'В ссылке больше 8 каналов',
      );
    }
    if (!set.hasLoraConfig()) {
      return const ChannelImportPlan(
        channels: [],
        error: 'В ссылке нет настроек LoRa — каналы можно только добавить',
      );
    }
    final lora = set.loraConfig.deepCopy();
    if (currentLora != null) {
      lora
        ..configOkToMqtt = currentLora.configOkToMqtt
        ..txPower = currentLora.txPower;
    }
    return ChannelImportPlan(
      channels: [
        for (var i = 0; i < incoming.length; i++) channel(incoming[i], i),
        for (var i = incoming.length; i < maxSlots; i++)
          Channel(index: i, role: Channel_Role.DISABLED),
      ],
      lora: lora,
      usedSlots: incoming.length,
    );
  }

  static ChannelImportPlan _planAdd(
    List<ChannelSettings> incoming,
    Iterable<MeshChannel> current,
  ) {
    final active = [
      for (final c in current)
        if (c.role > 0) c,
    ];
    final existing = {for (final c in active) c.name};
    final dup = incoming.where((s) => existing.contains(s.name)).toList();
    if (dup.isNotEmpty) {
      return ChannelImportPlan(
        channels: const [],
        error:
            'На ноде уже есть канал «${dup.first.name.isEmpty ? 'по умолчанию' : dup.first.name}»',
      );
    }
    final busy = {for (final c in active) c.index};
    final free = [
      for (var i = 1; i < maxSlots; i++)
        if (!busy.contains(i)) i,
    ];
    final used = busy.length + incoming.length;
    if (incoming.length > free.length) {
      return ChannelImportPlan(
        channels: const [],
        error:
            'Не хватает свободных слотов: нужно ${incoming.length}, '
            'свободно ${free.length}',
        usedSlots: used,
      );
    }
    return ChannelImportPlan(
      channels: [
        for (var i = 0; i < incoming.length; i++) channel(incoming[i], free[i]),
      ],
      usedSlots: used,
    );
  }

  /// Каналы (и LoRa) одной транзакцией; после подтверждения — в свою БД.
  static Future<bool> apply(
    AdminSettings admin,
    AppDatabase db,
    ChannelImportPlan plan,
  ) async {
    if (!plan.ok) return false;
    final lora = plan.lora;
    final ok = await admin.transaction([
      for (final c in plan.channels) AdminMessage(setChannel: c),
      if (lora != null) AdminMessage(setConfig: Config(lora: lora)),
    ]);
    if (!ok) return false;
    for (final c in plan.channels) {
      await db.upsertChannel(c);
    }
    if (lora != null) await storeConfig(db, 'lora', Config(lora: lora));
    return true;
  }

  /// Набор для «Поделиться»: выбранные каналы и LoRa ноды.
  static ChannelSet share(
    Iterable<MeshChannel> channels,
    Set<int> include,
    Config_LoRaConfig? lora,
  ) {
    final picked = [
      for (final c in channels)
        if (c.role > 0 && include.contains(c.index)) c,
    ]..sort((a, b) => a.index.compareTo(b.index));
    return ChannelSet(
      settings: [for (final c in picked) ChannelEdit.settingsOf(c)],
      loraConfig: lora,
    );
  }
}
