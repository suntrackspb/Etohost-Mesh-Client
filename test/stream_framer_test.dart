import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:etohost_mesh/core/transport/transport.dart';

void main() {
  late List<Uint8List> frames;
  late List<String> texts;
  late StreamFramer framer;

  setUp(() {
    frames = [];
    texts = [];
    framer = StreamFramer(
      onFrame: frames.add,
      onText: (t) => texts.add(String.fromCharCodes(t)),
    );
  });

  test('frame() добавляет заголовок 0x94 0xC3 и длину', () {
    expect(StreamFramer.frame(Uint8List.fromList([1, 2, 3])), [
      0x94,
      0xC3,
      0,
      3,
      1,
      2,
      3,
    ]);
  });

  test('кадр, разрезанный на куски, собирается', () {
    final f = StreamFramer.frame(
      Uint8List.fromList(List.generate(10, (i) => i)),
    );
    for (final b in f) {
      framer.add([b]);
    }
    expect(frames, hasLength(1));
    expect(frames.single, List.generate(10, (i) => i));
  });

  test('текст до и между кадрами уходит в onText', () {
    framer.add([
      ...'boot\n'.codeUnits,
      ...StreamFramer.frame(Uint8List.fromList([7])),
      ...'log'.codeUnits,
    ]);
    expect(frames.single, [7]);
    expect(texts.join(), 'boot\nlog');
  });
}
