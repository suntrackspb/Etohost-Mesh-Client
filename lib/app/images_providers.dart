import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drift/drift.dart';

import '../core/proto/mesh.dart';
import '../data/database.dart';
import '../data/images/image_uploader.dart';
import '../mirror/mirror_capabilities.dart';
import 'providers.dart';

/// Сервис картинок подключённого зеркала; null — зеркала нет или оно
/// картинок не объявило: ни кнопки загрузки, ни превью.
final imagesCapabilityProvider = Provider<ImagesCapability?>(
  (ref) => ref.watch(mirrorCapabilitiesProvider).value?.images,
);

/// Хосты, с которых показываем превью; пусто — превью нет.
final imagePreviewHostsProvider = Provider<Set<String>>(
  (ref) => ref.watch(imagesCapabilityProvider)?.previewHosts ?? const {},
);

final imageUploaderProvider = Provider<ImageUploader?>((ref) {
  final cap = ref.watch(imagesCapabilityProvider);
  return cap == null ? null : ImageUploader(cap.baseUrl, cap.publicKey);
});

final imageUploadsProvider = Provider<ImageUploads?>((ref) {
  final cap = ref.watch(imagesCapabilityProvider);
  final up = ref.watch(imageUploaderProvider);
  if (cap == null || up == null) return null;
  return ImageUploads(ref, up, cap);
});

/// Загрузка своей картинки: подпись ключом подключённой ноды, токены
/// удаления — в настройках приложения.
class ImageUploads {
  ImageUploads(this._ref, this._up, this.capability);

  final Ref _ref;
  final ImageUploader _up;

  /// Что объявил сервис: лимит, хост, есть ли жалобы и удаление.
  final ImagesCapability capability;

  /// Вся операция целиком: чтобы колесо не крутилось вечно.
  static const timeout = Duration(minutes: 2);

  Future<UploadedImage> upload(Uint8List body) => _upload(body).timeout(
    timeout,
    onTimeout: () => throw const ImageError('Сервис не ответил вовремя'),
  );

  /// Своя нода и её приватный ключ — ими подписываются запросы.
  Future<(String, List<int>)> _me() async {
    final me = _ref.read(radioProvider).myNodeNum;
    // Прямо из базы: `configProvider` без подписчиков в Riverpod 3 стоит
    // на паузе, и его `.future` может не завершиться.
    final db = _ref.read(databaseProvider);
    final blob = await (db.select(
      db.configBlobs,
    )..where((c) => c.key.equals('config.security'))).getSingleOrNull();
    final key = blob == null
        ? null
        : Config.fromBuffer(blob.data).security.privateKey;
    if (me == null || key == null || key.length != 32) {
      throw const ImageError('Нет ключа ноды — подключитесь к своей ноде');
    }
    return (nodeIdString(me), key);
  }

  Future<UploadedImage> _upload(Uint8List body) async {
    final max = capability.maxBytes;
    if (body.length > max) {
      throw ImageError('Картинка больше ${max ~/ (1024 * 1024)} МБ');
    }
    final (node, key) = await _me();
    final img = await _up.upload(body: body, node: node, nodePrivateKey: key);
    await _save([...await _list(), img]);
    return img;
  }

  Future<List<UploadedImage>> _list() async {
    final raw = await _ref
        .read(databaseProvider)
        .getSetting(AppSettingKeys.imageUploads);
    if (raw == null) return [];
    try {
      return [
        for (final j in jsonDecode(raw) as List)
          UploadedImage.fromJson((j as Map).cast()),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<UploadedImage> all) {
    final now = DateTime.now();
    final live = all.where((i) => i.expiresAt.isAfter(now)).toList();
    return _ref
        .read(databaseProvider)
        .setSetting(
          AppSettingKeys.imageUploads,
          jsonEncode([for (final i in live) i.toJson()]),
        );
  }

  /// Своя ли картинка (есть токен удаления).
  Future<UploadedImage?> own(String id) async {
    for (final i in await _list()) {
      if (i.id == id) return i;
    }
    return null;
  }

  Future<void> delete(UploadedImage img) async {
    await _up.delete(img.id, img.deleteToken);
    await _save([
      for (final i in await _list())
        if (i.id != img.id) i,
    ]);
  }

  Future<void> report(String id, String reason) async {
    final (node, key) = await _me();
    await _up.report(id, reason, node: node, nodePrivateKey: key);
  }
}
