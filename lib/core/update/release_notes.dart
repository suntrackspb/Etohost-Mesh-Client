/// Заметки к релизу с GitHub (markdown) — в простые блоки для показа без
/// markdown-движка: заголовки, пункты списка, абзацы.
sealed class NotesBlock {
  const NotesBlock(this.text);
  final String text;
}

class NotesHeading extends NotesBlock {
  const NotesHeading(super.text);
}

class NotesBullet extends NotesBlock {
  const NotesBullet(super.text);
}

class NotesParagraph extends NotesBlock {
  const NotesParagraph(super.text);
}

class ReleaseNotes {
  const ReleaseNotes(this.blocks);

  final List<NotesBlock> blocks;

  /// Разбор. Заголовок «Meshex x.y.z» отбрасывается — версия и так
  /// в шапке плашки. Строки абзаца и пункта склеиваются.
  factory ReleaseNotes.parse(String md) {
    final out = <NotesBlock>[];
    String? para;
    String? bullet;
    void flush() {
      if (para != null) out.add(NotesParagraph(para!));
      if (bullet != null) out.add(NotesBullet(bullet!));
      para = bullet = null;
    }

    for (final raw in md.replaceAll('\r', '').split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) {
        flush();
        continue;
      }
      final h = RegExp(r'^#{1,6}\s+(.*)$').firstMatch(line);
      if (h != null) {
        flush();
        final t = inline(h.group(1)!);
        if (!RegExp(r'^Meshex\b', caseSensitive: false).hasMatch(t)) {
          out.add(NotesHeading(t));
        }
        continue;
      }
      final b = RegExp(r'^[-*+]\s+(.*)$').firstMatch(line);
      if (b != null) {
        flush();
        bullet = inline(b.group(1)!);
        continue;
      }
      if (bullet != null) {
        bullet = '$bullet ${inline(line)}';
      } else {
        para = para == null ? inline(line) : '$para ${inline(line)}';
      }
    }
    flush();
    return ReleaseNotes(out);
  }

  /// Кратко для плашки: первый абзац и разделы через «·».
  String get summary {
    final first = blocks.whereType<NotesParagraph>().firstOrNull?.text;
    final sections = blocks.whereType<NotesHeading>().map((h) => h.text);
    return [?first, if (sections.isNotEmpty) sections.join(' · ')].join('\n');
  }

  bool get isEmpty => blocks.isEmpty;

  /// Убрать разметку внутри строки: `код`, **жирный**, _курсив_, [текст](ссылка).
  static String inline(String s) => s
      .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]*\)'), (m) => m[1]!)
      .replaceAll(RegExp(r'\*\*|__|`'), '')
      .replaceAllMapped(
        RegExp(r'(^|\s)[*_](\S[^*_]*\S|\S)[*_](?=\s|$|[.,;:!?])'),
        (m) => '${m[1]}${m[2]}',
      )
      .trim();
}
