import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:etohost_mesh/core/proto/mesh.dart';
import 'package:etohost_mesh/core/radio/send_queue.dart';
import 'package:etohost_mesh/data/database.dart';
import 'package:etohost_mesh/data/settings/admin_settings.dart';
import 'package:etohost_mesh/data/settings/fields.dart';
import 'package:etohost_mesh/data/settings/settings_form.dart';
import 'package:etohost_mesh/data/settings/user_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('обрезка по байтам не рвёт символ', () {
    expect(trimToBytes('Привет', 5), 'Пр'); // 2 байта на букву
    expect(trimToBytes('ab😀', 5), 'ab'); // эмодзи — 4 байта
    expect(trimToBytes('abc', 4), 'abc');
  });

  test('версия прошивки и лимит длинного имени', () {
    expect(UserSection.longNameBytes('2.7.23.d8f59ce'), 39);
    expect(UserSection.longNameBytes('2.8.1.abc'), 24);
    expect(firmwareAtLeast('3.0.0', 2, 8), isTrue);
    expect(firmwareAtLeast('', 2, 8), isFalse);
  });

  test('форма: правки, обрезка, сохранение, перезагрузка данных', () async {
    final form = SettingsForm(UserSection.fields('2.8.1'), {
      'longName': 'Old',
      'shortName': 'OLD',
      'isUnmessagable': false,
    });
    expect(form.dirty, isFalse);
    form.set('shortName', 'ABCDE');
    expect(form.value<String>('shortName'), 'ABCD');
    form.set('longName', 'x' * 30);
    expect(form.value<String>('longName'), hasLength(24));
    expect(form.canSave, isTrue);

    // Новые данные с ноды не затирают правки пользователя.
    form.reload({
      'longName': 'Old',
      'shortName': 'OLD',
      'isUnmessagable': true,
    });
    expect(form.value<bool>('isUnmessagable'), isTrue);
    expect(form.value<String>('shortName'), 'ABCD');

    expect(await form.submit((_, _) async => false), isFalse);
    expect(form.saveError, isNotNull);
    expect(await form.submit((_, _) async => true), isTrue);
    expect(form.dirty, isFalse);
  });

  test('сохранение пользователя: set_owner своей ноде, БД после ACK', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.nodes)
        .insert(NodesCompanion.insert(num: const Value(0xAA)));
    final sent = <MeshPacket>[];
    final admin = AdminSettings(
      (p) async {
        sent.add(p);
        return const DeliveryResult(DeliveryStatus.acked);
      },
      () => 0xAA,
      () => 1,
    );
    expect(
      await UserSection.save(admin, db, 0xAA, {
        'longName': 'New name',
        'shortName': 'NEW',
        'isUnmessagable': true,
      }),
      isTrue,
    );
    final p = sent.single;
    expect(p.to, 0xAA);
    expect(p.wantAck, isTrue);
    expect(p.hopLimit, 0);
    final owner = AdminMessage.fromBuffer(p.decoded.payload).setOwner;
    expect(owner.longName, 'New name');
    expect(owner.isUnmessagable, isTrue);
    final me = await db.select(db.nodes).getSingle();
    expect(me.shortName, 'NEW');
  });

  test('транзакция: begin, команды, commit', () async {
    final sent = <AdminMessage>[];
    final admin = AdminSettings(
      (p) async {
        sent.add(AdminMessage.fromBuffer(p.decoded.payload));
        return const DeliveryResult(DeliveryStatus.acked);
      },
      () => 1,
      () => 1,
    );
    await admin.transaction([AdminMessage(setOwner: User(longName: 'a'))]);
    expect(sent.first.beginEditSettings, isTrue);
    expect(sent[1].hasSetOwner(), isTrue);
    expect(sent.last.commitEditSettings, isTrue);
  });

  test(
    'сообщение статуса: только изменённая часть, поддержка по версии',
    () async {
      expect(
        UserSection.supportsStatusMessage('2.7.19.x', null, true),
        isFalse,
      );
      expect(UserSection.supportsStatusMessage('2.7.23.x', null, true), isTrue);
      expect(
        UserSection.supportsStatusMessage('2.7.23.x', null, false),
        isFalse,
      );
      expect(
        UserSection.supportsStatusMessage(
          '2.8.1',
          DeviceMetadata(
            excludedModules: ExcludedModules.STATUSMESSAGE_CONFIG.value,
          ),
          true,
        ),
        isFalse,
      );

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final sent = <AdminMessage>[];
      final admin = AdminSettings(
        (p) async {
          sent.add(AdminMessage.fromBuffer(p.decoded.payload));
          return const DeliveryResult(DeliveryStatus.acked);
        },
        () => 1,
        () => 1,
      );
      final initial = {
        'longName': 'a',
        'shortName': 'b',
        'isUnmessagable': false,
        'statusMessage': '',
      };
      await UserSection.save(admin, db, 1, {
        ...initial,
        'statusMessage': 'На связи',
      }, initial: initial);
      expect(sent.single.setModuleConfig.statusmessage.nodeStatus, 'На связи');
    },
  );

  test(
    'связь пропала при сохранении — понятный текст без «Bad state»',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db
          .into(db.nodes)
          .insert(NodesCompanion.insert(num: const Value(0xAA)));
      final admin = AdminSettings(
        (p) async => const DeliveryResult(DeliveryStatus.disconnected),
        () => 0xAA,
        () => 1,
      );
      final e = await UserSection.save(admin, db, 0xAA, {
        'longName': 'X',
        'shortName': 'X',
        'isUnmessagable': false,
      }).then<Object?>((_) => null, onError: (Object e) => e);
      expect(e, isA<SaveError>());
      expect('$e', rebooting);
    },
  );
}
