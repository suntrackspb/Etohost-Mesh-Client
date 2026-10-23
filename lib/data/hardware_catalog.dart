import '../core/proto/mesh.dart';
import 'hardware_catalog.g.dart';

/// Плата из справочника: название, SVG в assets/hw/ (0–4, как в iOS)
/// и уровень поддержки (номер [SupportLevel]).
typedef HardwareInfo = ({String name, List<String> images, int level});

/// Уровень поддержки платы — как SupportLevel в официальном iOS.
enum SupportLevel {
  discontinued(
    'Снято с поддержки',
    'Устройство больше не поддерживается и не получает обновлений прошивки.',
  ),
  flagship(
    'Поддерживаемое устройство',
    'Рекомендуемое устройство: все функции, активная разработка.',
  ),
  niche(
    'Нишевое устройство',
    'Поддерживается, прошивка обновляется; специализированный форм-фактор.',
  ),
  legacy(
    'Устаревшее устройство',
    'Прошивка ещё обновляется, но часть функций может быть недоступна.',
  );

  const SupportLevel(this.title, this.description);

  final String title;
  final String description;

  static SupportLevel of(int v) =>
      v >= 0 && v < values.length ? values[v] : discontinued;
}

/// Заголовок блока платы, как в iOS: Portduino (meshtasticd) — устройство
/// сообщества, иначе по уровню поддержки.
String hardwareSectionTitle(int hwModel, HardwareInfo info) =>
    hwModel == HardwareModel.PORTDUINO.value
    ? 'Устройство сообщества'
    : SupportLevel.of(info.level).title;

/// Справочник для [hwModel]; null — модели нет в справочнике.
HardwareInfo? hardwareInfo(int hwModel) => hardwareCatalog[hwModel];

/// Название платы: из справочника, иначе имя из прошивки (HELTEC_V3).
String hardwareName(int hwModel) =>
    hardwareInfo(hwModel)?.name ??
    HardwareModel.valueOf(hwModel)?.name ??
    '$hwModel';

/// Пути к ассетам картинок платы; пусто — картинок нет.
List<String> hardwareImageAssets(int hwModel) => [
  for (final i in hardwareInfo(hwModel)?.images ?? const <String>[])
    'assets/hw/$i',
];

/// Пояснение под названием платы; Portduino — отдельно, как в iOS.
String hardwareDescription(int hwModel, HardwareInfo info) =>
    hwModel == HardwareModel.PORTDUINO.value
    ? 'Linux-устройство, поддерживается сообществом.'
    : SupportLevel.of(info.level).description;
