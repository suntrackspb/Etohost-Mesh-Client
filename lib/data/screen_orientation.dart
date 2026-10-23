import 'package:flutter/services.dart' show DeviceOrientation;

/// Ориентация экрана. [auto] — поворот по датчику; остальные — экран
/// закреплён и на поворот телефона не реагирует.
enum ScreenOrientation {
  auto('Авто', null),
  portrait('Книжная', DeviceOrientation.portraitUp),
  landscape('Альбомная', DeviceOrientation.landscapeLeft),
  portraitDown('Книжная перевёрнутая', DeviceOrientation.portraitDown),
  landscapeDown('Альбомная перевёрнутая', DeviceOrientation.landscapeRight);

  const ScreenOrientation(this.title, this.device);
  final String title;
  final DeviceOrientation? device;

  /// Для SystemChrome.setPreferredOrientations: пустой список — все
  /// ориентации, которые разрешает платформа.
  List<DeviceOrientation> get preferred => [?device];

  /// Неизвестное значение — авто.
  static ScreenOrientation parse(String? v) =>
      values.where((o) => o.name == v).firstOrNull ?? auto;
}
