import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/proto/mesh.dart';
import '../data/database.dart';
import '../data/images/image_uploader.dart';
import 'providers.dart';
import 'settings_providers.dart';

/// Сервис картинок; null — сборка без IMAGES_URL, кнопки нет.
final imageUploaderProvider = Provider<ImageUploader?>(
  (ref) => ImageUploader.fromEnvironment(),
);

final imageUploadsProvider = Provider<ImageUploads?>((ref) {
  final up = ref.watch(imageUploaderProvider);
  if (up == null) return null;
  return ImageUploads(ref, up);
});

/// Загрузка своей картинки: подпись ключом подключённой ноды, токены
/// удаления — в настройках приложения.
class ImageUploads {
  ImageUploads(this._ref, this._up);

  final Ref _ref;
  final ImageUploader _up;

  static const maxBytes = 10 * 1024 * 1024;

  Future<UploadedImage> upload(Uint8List body) async {
    if (body.length > maxBytes) {
      throw const ImageError('Картинка больше 10 МБ');
    }
    final me = _ref.read(radioProvider).myNodeNum;
    final key = (await _ref.read(
      configProvider('security').future,
    ))?.security.privateKey;
    if (me == null || key == null || key.length != 32) {
      throw const ImageError('Нет ключа ноды — подключитесь к своей ноде');
    }
    final img = await _up.upload(
      body: body,
      node: nodeIdString(me),
      nodePrivateKey: key,
    );
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

  Future<void> report(String id, String reason) => _up.report(id, reason);
}
