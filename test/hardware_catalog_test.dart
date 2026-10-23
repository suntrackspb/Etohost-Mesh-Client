import 'dart:io';

import 'package:etohost_mesh/data/hardware_catalog.dart';
import 'package:etohost_mesh/data/hardware_catalog.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('название из справочника, иначе из прошивки, иначе номер', () {
    expect(hardwareName(43), 'Heltec V3');
    expect(hardwareName(99999), '99999');
  });

  test('все картинки справочника лежат в ассетах', () {
    for (final i in hardwareCatalog.values) {
      for (final f in i.images) {
        expect(File('assets/hw/$f').existsSync(), isTrue, reason: f);
      }
    }
  });

  test('уровень поддержки и заголовок', () {
    expect(SupportLevel.of(1), SupportLevel.flagship);
    expect(SupportLevel.of(99), SupportLevel.discontinued);
    final v3 = hardwareInfo(43)!;
    expect(hardwareSectionTitle(43, v3), 'Поддерживаемое устройство');
    expect(
      hardwareSectionTitle(37, (name: 'x', images: const [], level: 1)),
      'Устройство сообщества',
    );
  });

  test('Portduino — Linux с пингвином', () {
    final p = hardwareInfo(37)!;
    expect(p.images, ['meshtasticd_tux.svg', 'rak6421.svg']);
    expect(hardwareSectionTitle(37, p), 'Устройство сообщества');
    expect(hardwareDescription(37, p), contains('сообществом'));
  });
}
