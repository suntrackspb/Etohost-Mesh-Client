import 'dart:convert';

/// Что объявило подключённое зеркало (`GET /api/v1/capabilities`).
/// Чего в ответе нет — того в клиенте нет: адреса и ключи сервисов в
/// сборку не зашиваются, у каждого экземпляра свои.
class MirrorCapabilities {
  const MirrorCapabilities({
    this.name,
    this.contact,
    this.images,
    this.reports,
  });

  /// Зеркало без ответа (старая версия или ошибка) — ничего не умеет.
  static const none = MirrorCapabilities();

  final String? name;

  /// Контакт оператора экземпляра — показываем рядом с жалобой.
  final String? contact;

  final ImagesCapability? images;
  final ReportsCapability? reports;

  static MirrorCapabilities parse(Object? j) {
    if (j is! Map) return none;
    String? str(Object? v) => v is String && v.trim().isNotEmpty ? v : null;
    final op = j['operator'];
    return MirrorCapabilities(
      name: str(j['name']),
      contact: op is Map ? str(op['contact']) : null,
      images: ImagesCapability.tryParse(j['images']),
      reports: ReportsCapability.tryParse(j['reports']),
    );
  }
}

/// Сервис картинок экземпляра.
class ImagesCapability {
  const ImagesCapability({
    required this.baseUrl,
    required this.publicKey,
    required this.maxBytes,
    required this.previewHosts,
    this.report = false,
    this.delete = false,
  });

  final Uri baseUrl;

  /// Публичный ключ сервиса X25519, 32 байта.
  final List<int> publicKey;
  final int maxBytes;

  /// Хосты, с которых показываем превью в ленте (в нижнем регистре).
  final Set<String> previewHosts;
  final bool report;
  final bool delete;

  /// Хост API сервиса: его картинки можно удалить и на них пожаловаться.
  String get host => baseUrl.host.toLowerCase();

  static ImagesCapability? tryParse(Object? j) {
    if (j is! Map || j['enabled'] != true) return null;
    final base = Uri.tryParse(j['base_url'] is String ? j['base_url'] : '');
    if (base == null || base.scheme != 'https' || base.host.isEmpty) {
      return null;
    }
    List<int> key;
    try {
      key = base64.decode(j['public_key'] as String);
    } catch (_) {
      return null;
    }
    if (key.length != 32) return null;
    final hosts = j['preview_hosts'];
    final max = j['max_bytes'];
    final listed = {
      if (hosts is List)
        for (final h in hosts)
          if (h is String && h.isNotEmpty) h.toLowerCase(),
    };
    return ImagesCapability(
      baseUrl: base.path.endsWith('/')
          ? base
          : base.replace(path: '${base.path}/'),
      publicKey: key,
      maxBytes: max is int && max > 0 ? max : 10 * 1024 * 1024,
      previewHosts: listed.isEmpty ? {base.host.toLowerCase()} : listed,
      report: j['report'] == true,
      delete: j['delete'] == true,
    );
  }
}

/// Сервер отчётов и объявлений, который указал экземпляр.
class ReportsCapability {
  const ReportsCapability({
    required this.baseUrl,
    this.apiKey = '',
    this.notices = false,
  });

  final Uri baseUrl;
  final String apiKey;

  /// Можно ли брать с этого сервера объявления.
  final bool notices;

  static ReportsCapability? tryParse(Object? j) {
    if (j is! Map) return null;
    final base = Uri.tryParse(j['base_url'] is String ? j['base_url'] : '');
    if (base == null || base.scheme != 'https' || base.host.isEmpty) {
      return null;
    }
    final key = j['api_key'];
    return ReportsCapability(
      baseUrl: base.path.endsWith('/')
          ? base
          : base.replace(path: '${base.path}/'),
      apiKey: key is String ? key : '',
      notices: j['notices'] == true,
    );
  }
}
