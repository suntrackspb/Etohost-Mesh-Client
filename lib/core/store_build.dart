/// Сборка для App Store и Google Play (`--dart-define=STORE_BUILD=true`).
/// Обновляет магазин: своя проверка версий через GitHub и ссылки на
/// скачивание сборок мимо магазина по их правилам запрещены.
const storeBuild = bool.fromEnvironment('STORE_BUILD');
