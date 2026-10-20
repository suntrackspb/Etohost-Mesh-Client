/// Настройки зеркала. По умолчанию выключено и без адреса: пока пользователь
/// сам не включит, клиент не ходит ни на какие серверы.
class MirrorConfig {
  const MirrorConfig({this.enabled = false, this.address = ''});

  static const off = MirrorConfig();

  final bool enabled;

  /// Как ввёл пользователь (`m.example.org`, `https://…`, `http://10.0.0.5:8000`).
  final String address;

  /// Зеркало реально используется: включено и адрес разбирается.
  bool get active => enabled && baseUrl != null;

  Uri? get baseUrl => normalizeMirrorUrl(address);

  Uri? get webSocketUrl {
    final b = baseUrl;
    if (b == null) return null;
    return b.replace(
      scheme: b.scheme == 'http' ? 'ws' : 'wss',
      path: '/ws',
      queryParameters: {'history': '1'},
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MirrorConfig &&
      other.enabled == enabled &&
      other.address == address;

  @override
  int get hashCode => Object.hash(enabled, address);
}

/// `host` → `https://host`; поддерживаются только http/https; путь, query и
/// фрагмент отбрасываются. Невалидный или пустой ввод — null.
Uri? normalizeMirrorUrl(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final withScheme = s.contains('://') ? s : 'https://$s';
  final u = Uri.tryParse(withScheme);
  if (u == null) return null;
  final scheme = u.scheme.toLowerCase();
  if ((scheme != 'https' && scheme != 'http') || u.host.isEmpty) return null;
  return Uri(scheme: scheme, host: u.host, port: u.hasPort ? u.port : null);
}

/// Страница карты ретрансляций сообщения на зеркале (`/relay/<id>`).
Uri? relayMapUrl(MirrorConfig c, int mirrorId) =>
    c.active ? c.baseUrl!.replace(path: '/relay/$mirrorId') : null;
