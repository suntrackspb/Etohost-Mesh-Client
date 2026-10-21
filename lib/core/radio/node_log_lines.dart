/// Текстовый лог ноды (USB/TCP) приходит кусками как попало — иногда по
/// одной букве. Склеивает куски в целые строки и убирает цветовые коды.
class NodeLogLines {
  /// Строка без перевода дольше этого — отдаётся как есть.
  static const maxPending = 2000;

  static final _ansi = RegExp(r'\x1B\[[0-9;]*[A-Za-z]');

  final _pending = StringBuffer();

  /// Новые законченные строки (без пустых).
  List<String> add(String chunk) {
    _pending.write(chunk);
    final text = _pending.toString();
    final cut = text.lastIndexOf('\n');
    final String done;
    if (cut >= 0) {
      done = text.substring(0, cut);
      _pending
        ..clear()
        ..write(text.substring(cut + 1));
    } else if (text.length > maxPending) {
      done = text;
      _pending.clear();
    } else {
      return const [];
    }
    return [
      for (final l in done.split('\n'))
        if (l.replaceAll(_ansi, '').trim() case final s when s.isNotEmpty) s,
    ];
  }

  void clear() => _pending.clear();
}
