import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/mirror_node_key.dart';
import 'package:etohost_mesh/mirror/mirror_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.nodes)
        .insert(
          NodesCompanion.insert(
            num: const Value(0x42),
            onMirror: const Value(true),
          ),
        );
  });
  tearDown(() => db.close());
  Future<Node> node() => db.select(db.nodes).getSingle();
  MirrorApi api(Object? key, {void Function()? beforeResponse}) => MirrorApi(
    Uri.parse('https://mirror.example'),
    client: MockClient((request) async {
      expect(request.url.path, '/api/nodes/!00000042/full');
      beforeResponse?.call();
      return http.Response(jsonEncode({'public_key': key}), 200);
    }),
  );
  test(
    'loads valid /full key without marking node as heard on radio',
    () async {
      final mirror = api(List.filled(32, 'ab').join());
      addTearDown(mirror.close);
      await loadMirrorNodeKey(db, mirror, 0x42);
      expect((await node()).publicKey, List.filled(32, 0xab));
      expect((await node()).onRadio, isFalse);
    },
  );
  test('does not replace a known radio key', () async {
    await db
        .update(db.nodes)
        .write(
          NodesCompanion(
            publicKey: Value(Uint8List.fromList(List.filled(32, 1))),
          ),
        );
    final mirror = api(List.filled(32, 'ab').join());
    addTearDown(mirror.close);
    await loadMirrorNodeKey(db, mirror, 0x42);
    expect((await node()).publicKey, List.filled(32, 1));
  });
  test('missing, malformed and zero keys leave the node unchanged', () async {
    for (final key in [null, 'bad', List.filled(64, '0').join()]) {
      final mirror = api(key);
      await loadMirrorNodeKey(db, mirror, 0x42);
      mirror.close();
      expect((await node()).publicKey, isNull);
    }
  });
  test('404 is reported and does not change the database', () async {
    final mirror = MirrorApi(
      Uri.parse('https://mirror.example'),
      client: MockClient((_) async => http.Response('{}', 404)),
    );
    addTearDown(mirror.close);
    await expectLater(
      loadMirrorNodeKey(db, mirror, 0x42),
      throwsA(isA<MirrorApiException>()),
    );
    expect((await node()).publicKey, isNull);
  });
}
