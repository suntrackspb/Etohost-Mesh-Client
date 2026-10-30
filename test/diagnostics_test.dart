import 'dart:convert';
import 'dart:io';

import 'package:meshex/core/diagnostics/journal_file.dart';
import 'package:meshex/core/diagnostics/report_uploader.dart';
import 'package:meshex/core/proto/mesh.dart';
import 'package:meshex/core/radio/journal.dart';
import 'package:meshex/data/diagnostics/report.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('в файл журнала не попадает текст сообщений и название канала', () {
    final text = FromRadio(
      packet: MeshPacket(
        from: 1,
        to: broadcastNum,
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: utf8.encode('секрет'),
        ),
      ),
    );
    expect(describeFromRadio(text), contains('секрет'));
    expect(describeFromRadio(text, private: true), isNot(contains('секрет')));
    final ch = FromRadio(
      channel: Channel(index: 1, settings: ChannelSettings(name: 'Дача')),
    );
    expect(describeFromRadio(ch, private: true), isNot(contains('Дача')));
  });

  test('toFile: false — только на экране, fileOnly — только в файл', () {
    final file = <String>[];
    final j = Journal()..sink = (l) => file.add(l.fileText);
    j.add(JournalKind.radio, 'нода 1', toFile: false);
    j.fileOnly(JournalKind.radio, 'база нод: 1 записей');
    j.add(JournalKind.app, 'обычная');
    expect(j.lines.map((l) => l.text), ['нода 1', 'обычная']);
    expect(file, ['база нод: 1 записей', 'обычная']);
  });

  test('координаты вырезаются из лога прошивки', () {
    expect(
      redactNodeLog('GPS lat=599123456 lon=-30123 alt=10'),
      'GPS lat=… lon=… alt=10',
    );
    expect(redactNodeLog('latitude: 59.91, sats 7'), 'latitude: …, sats 7');
  });

  test('файл журнала: ротация и чтение обоих файлов', () async {
    final dir = await Directory.systemTemp.createTemp('journal');
    addTearDown(() => dir.delete(recursive: true));
    final f = JournalFile(Future.value(dir), maxBytes: 200);
    for (var i = 0; i < 10; i++) {
      f.add(JournalLine(DateTime(2026), JournalKind.app, 'строка $i'));
      await f.flush();
    }
    final all = await f.readAll();
    expect(all, contains('строка 9'));
    expect(File('${dir.path}/journal.1.log').existsSync(), isTrue);
    expect(utf8.encode(all).length, lessThanOrEqualTo(400));
  });

  test('tail обрезает начало по границе строки', () {
    final log = List.filled(300000, 'строка журнала').join('\n');
    final t = DiagnosticReport.tail(log);
    expect(
      utf8.encode(t).length,
      lessThanOrEqualTo(DiagnosticReport.maxLogBytes),
    );
    expect(t.startsWith('строка журнала'), isTrue);
  });

  test('раздел ноды: имена перечислений, ID, пресет', () {
    final n = nodeInfoSection(
      myNodeNum: 0xdeadbeef,
      hwModel: 9,
      firmware: '2.7.15',
      role: 2,
      lora: Config_LoRaConfig(
        usePreset: true,
        modemPreset: Config_LoRaConfig_ModemPreset.LONG_FAST,
      ),
    );
    expect(n['id'], '!deadbeef');
    expect(n['hwModel'], 'RAK4631');
    expect(n['role'], 'ROUTER');
    expect(n['modemPreset'], 'LONG_FAST');
    expect(utcOffset(const Duration(hours: 3)), 'UTC+3');
    expect(utcOffset(const Duration(hours: -5, minutes: -30)), 'UTC-5:30');
  });

  test('отправка: ключ, поля, gzip, номер из ответа', () async {
    late http.Request got;
    final client = MockClient((r) async {
      got = r;
      return http.Response('{"id":"R-7K3M-Q9TX"}', 201);
    });
    final up = ReportUploader(
      Uri.parse('https://example.org/'),
      'k',
      client: client,
    );
    final id = await up.send(info: {'app': {}}, log: 'журнал', comment: 'c');
    expect(id, 'R-7K3M-Q9TX');
    expect(got.url.path, '/v1/reports');
    expect(got.headers['X-Api-Key'], 'k');
    expect(got.headers['content-type'], startsWith('multipart/form-data'));
  });

  test('отправка: 429 — понятная ошибка', () async {
    final up = ReportUploader(
      Uri.parse('https://example.org/'),
      'k',
      client: MockClient((_) async => http.Response('', 429)),
    );
    expect(() => up.send(info: {}, log: ''), throwsA(isA<ReportError>()));
  });
}
