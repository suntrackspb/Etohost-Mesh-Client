import 'dart:async';
import 'dart:io';

import 'package:etohost_mesh/core/desktop/single_instance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('inst'));
  tearDown(() => dir.delete(recursive: true));

  test('второй запуск просит первый показать окно', () async {
    final shown = Completer<void>();
    final server = await SingleInstance.serve(dir, shown.complete);
    expect(await SingleInstance.activateExisting(dir), isTrue);
    await shown.future.timeout(const Duration(seconds: 2));
    await server.close();
  });

  test('первый не отвечает — false, без исключения', () async {
    expect(await SingleInstance.activateExisting(dir), isFalse);
  });
}
