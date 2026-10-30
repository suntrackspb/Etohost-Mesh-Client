import 'package:meshex/core/update/release_notes.dart';
import 'package:flutter_test/flutter_test.dart';

const md = '''## Meshex 0.1.8

Исправления после 0.1.7.

### Запуск

- Приложение снова открывается. Ошибка `index already exists`,
  и даже **отчёт** не отправлялся.

### Linux

- Работает трей.
* Ярлык в `~/.local/share/applications`, см. [релиз](https://x.y).
''';

void main() {
  test('разбор: без заголовка версии, пункты склеены, разметка убрана', () {
    final n = ReleaseNotes.parse(md);
    expect(n.blocks.map((b) => '${b.runtimeType}:${b.text}').toList(), [
      'NotesParagraph:Исправления после 0.1.7.',
      'NotesHeading:Запуск',
      'NotesBullet:Приложение снова открывается. Ошибка index already exists, и даже отчёт не отправлялся.',
      'NotesHeading:Linux',
      'NotesBullet:Работает трей.',
      'NotesBullet:Ярлык в ~/.local/share/applications, см. релиз.',
    ]);
  });

  test('кратко: первый абзац и разделы', () {
    expect(
      ReleaseNotes.parse(md).summary,
      'Исправления после 0.1.7.\nЗапуск · Linux',
    );
    expect(ReleaseNotes.parse('').isEmpty, isTrue);
  });
}
