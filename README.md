# Etohost Mesh

Кроссплатформенный клиент для нод [Meshtastic](https://meshtastic.org) на Flutter:
iOS, Android, macOS, Windows, Linux. Подключение к ноде по BLE, TCP или USB

Поддерживаются прошивки 2.7 и 2.8.

## Возможности

- Интеграция с зеркалом эфира [Etohost](https://mirror.etohost.ru)
- Сообщения: каналы и личные чаты; длинный текст уходит несколькими частями `[1/N]`.
- Ноды: список с фильтрами, карточка ноды, избранное, игнор, traceroute.
- Карта с метками нод.
- Настройки радио и модулей; обмен каналами через QR-код и ссылку.
- Администрирование: перезагрузка, выключение, сброс NodeDB и настроек.
- Резервная копия закрытого ключа: в связке ключей или в файл.
- Светлая и тёмная темы.

## Скачать

### [Latest Releases: Android, iOS, MacOS, Linux, Windows](https://github.com/suntrackspb/Etohost-Mesh-Client/releases)

## Сборка

Папки платформ (`android/`, `ios/`, `macos/`, `linux/`, `windows/`) в репозиторий
не входят. Их создаёт `flutter create`, а права доступа (Bluetooth, камера, сеть,
файлы) дописывает `tool/patch_platforms.py`:

```sh
flutter create . --platforms=ios --project-name etohost_mesh --org ru.etohost
python3 tool/patch_platforms.py
flutter pub get
flutter run
```

Проверка:

```sh
flutter analyze
flutter test
```

На Linux нужен `libsecret-1-dev`.

## Релизы

Сборки для всех платформ делает GitHub Actions: при пуше тега `v*`
(версия приложения берётся из тега) или при ручном запуске workflow `build`.

## Лицензия

[GPL-3.0](LICENSE). Meshtastic® — зарегистрированная торговая марка Meshtastic LLC;
проект с ней не связан.
