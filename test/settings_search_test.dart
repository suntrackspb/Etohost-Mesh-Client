import 'package:etohost_mesh/data/settings_search.dart';
import 'package:etohost_mesh/features/settings/settings_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const all = [
    SettingsEntry(title: 'MQTT', route: 'mqtt'),
    SettingsEntry(
      title: 'Адрес сервера',
      route: 'mqtt',
      section: 'MQTT',
      help: 'Хост брокера',
    ),
    SettingsEntry(title: 'Сеть', route: 'network'),
    SettingsEntry(title: 'Включить Wi-Fi', route: 'network', section: 'Сеть'),
    SettingsEntry(
      title: 'Своё сообщение',
      route: 'canned-messages',
      section: 'Сохраненные сообщения',
    ),
  ];

  List<String> q(String s) => [for (final e in searchSettings(all, s)) e.title];

  test('пусто — ничего', () => expect(q('  '), isEmpty));

  test('регистр и ё не важны', () {
    expect(q('СВОЕ'), ['Своё сообщение']);
    expect(q('wi-fi'), ['Включить Wi-Fi']);
  });

  test('раздел выше полей, поиск по разделу и подсказке', () {
    expect(q('mqtt'), ['MQTT', 'Адрес сервера']);
    expect(q('брокер'), ['Адрес сервера']);
  });

  test('все слова должны встретиться', () {
    expect(q('сеть wi'), ['Включить Wi-Fi']);
    expect(q('сеть брокер'), isEmpty);
  });

  test('индекс: все разделы и поля, пути существуют у каждого', () {
    final idx = settingsIndex();
    expect(idx.where((e) => e.section == null).length, 32);
    expect(idx.where((e) => e.section != null).length, greaterThan(100));
    final hits = searchSettings(idx, 'wifi');
    expect(hits.map((e) => e.route), contains('network'));
  });
}
