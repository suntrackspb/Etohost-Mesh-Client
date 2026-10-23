/// Что делать с публичным ключом из NodeInfo.
enum KeyUpdate {
  /// Пустой ключ — ничего не меняем.
  ignore,

  /// Ключа ещё не было (или это своя нода) — записать.
  store,

  /// Совпал с записанным.
  match,

  /// Другой ключ при уже записанном — не менять, отметить несовпадение.
  mismatch,
}

/// «Первый ключ побеждает», как `applyInboundPublicKey` в официальном iOS:
/// ключ из эфира никто не заверял, и тихая замена позволила бы подменить
/// собеседника в личке. Ключ своей подключённой ноды приходит по BLE/USB/TCP —
/// его принимаем всегда (сброс или переход на 2.8 меняют ключ).
KeyUpdate keyUpdate(List<int>? stored, List<int> inbound, {bool own = false}) {
  if (inbound.isEmpty) return KeyUpdate.ignore;
  if (own) {
    return inbound.length == 32 ? KeyUpdate.store : KeyUpdate.ignore;
  }
  if (stored == null || stored.isEmpty) return KeyUpdate.store;
  return _same(stored, inbound) ? KeyUpdate.match : KeyUpdate.mismatch;
}

bool _same(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
