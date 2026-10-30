#!/usr/bin/env python3
"""Прописывает имя приложения и разрешения Bluetooth/сети/USB/камеры/файлов в папки, созданные `flutter create`.
Запускается в CI после `flutter create`; повторный запуск безопасен."""
import json
import os
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP_NAME = "Meshex"
# Идентификатор приложения на всех платформах. После публикации в сторах не менять:
# с другим id приложение считается новым, обновление поверх старого не встанет.
APP_ID = "ru.meshex.app"
# Имя проекта Flutter (`--project-name` в CI), оно же имя exe/бинарника.
PROJECT = "meshex"
ORG = "ru.meshex"
BT_TEXT = "Bluetooth нужен для подключения к ноде Meshtastic."
NET_TEXT = "Локальная сеть нужна для подключения к ноде Meshtastic по Wi-Fi."
CAM_TEXT = "Камера нужна, чтобы сканировать QR-код каналов Meshtastic."
LOC_TEXT = "Позиция телефона используется на карте и в компасе. Передача своей ноде — только если включена в настройках приложения."


def patch_android():
    f = ROOT / "android/app/src/main/AndroidManifest.xml"
    if not f.exists():
        return
    orig = s = f.read_text()
    perms = [
        '<uses-permission android:name="android.permission.INTERNET"/>',
        '<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30"/>',
        '<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30"/>',
        '<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation"/>',
        '<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>',
        # Геолокация — для передачи позиции телефона ноде (и BLE-скана до Android 12).
        '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>',
        '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>',
        # Камера — сканер QR-кода каналов.
        '<uses-permission android:name="android.permission.CAMERA"/>',
        # Foreground service — держит связь с нодой в фоне (тип connectedDevice).
        '<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>',
        '<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE"/>',
        '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>',
        '<uses-permission android:name="android.permission.WAKE_LOCK"/>',
        # connectedDevice по TCP: Android 14 требует одно из «сетевых» разрешений.
        '<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>',
        # Поиск нод в локальной сети (mDNS _meshtastic._tcp).
        '<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE"/>',
    ]
    # Раньше геолокация была ограничена Android 11 — снимаем ограничение.
    s = re.sub(r'(android\.permission\.ACCESS_(?:FINE|COARSE)_LOCATION")\s+android:maxSdkVersion="30"', r"\1", s)
    add = "".join(f"    {p}\n" for p in perms if p.split('"')[1] not in s)
    if add:
        s = s.replace("<application", add + "    <application", 1)
    # Системный жест «назад» Android 13+ через OnBackInvokedCallback
    # (иначе Flutter не получает predictive back).
    if "enableOnBackInvokedCallback" not in s:
        s = s.replace("<application", '<application\n        android:enableOnBackInvokedCallback="true"', 1)
    # Служба flutter_foreground_task; имя менять нельзя. stopWithTask — смахнули
    # приложение, соединения уже нет, уведомление не нужно.
    if "flutter_foreground_task.service.ForegroundService" not in s:
        s = s.replace("</application>", '''    <service
            android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
            android:foregroundServiceType="connectedDevice"
            android:stopWithTask="true"
            android:exported="false" />
    </application>''', 1)
    if s != orig:
        f.write_text(s)
    print("android: ok")


def replace_in(f: pathlib.Path, pairs):
    if not f.exists():
        return
    s = f.read_text(encoding="utf-8")
    new = s
    for a, b in pairs:
        new = new.replace(a, b)
    if new != s:
        f.write_text(new, encoding="utf-8")


def plist_set(f: pathlib.Path, key: str, value: str):
    """Заменить значение строкового ключа (или добавить ключ)."""
    if not f.exists():
        return
    s = f.read_text()
    pat = re.compile(rf"(<key>{key}</key>\s*<string>)[^<]*(</string>)")
    if pat.search(s):
        s = pat.sub(rf"\g<1>{value}\g<2>", s)
    else:
        s = re.sub(r"</dict>\s*</plist>\s*$", f"\t<key>{key}</key>\n\t<string>{value}</string>\n</dict>\n</plist>\n", s)
    f.write_text(s)


def patch_name():
    """Отображаемое имя «Meshex» на всех платформах."""
    manifest = ROOT / "android/app/src/main/AndroidManifest.xml"
    if manifest.exists():
        text = manifest.read_text()
        manifest.write_text(re.sub(r'android:label="[^"]*"',
                                  f'android:label="{APP_NAME}"', text))
    for plist in ("ios/Runner/Info.plist", "macos/Runner/Info.plist"):
        plist_set(ROOT / plist, "CFBundleDisplayName", APP_NAME)
    plist_set(ROOT / "ios/Runner/Info.plist", "CFBundleName", APP_NAME)
    # macOS: имя .app и пункта меню берётся из PRODUCT_NAME.
    appinfo = ROOT / "macos/Runner/Configs/AppInfo.xcconfig"
    if appinfo.exists():
        text = appinfo.read_text()
        text = re.sub(r"(?m)^PRODUCT_NAME = .*", f"PRODUCT_NAME = {APP_NAME}", text)
        text = re.sub(r"(?m)^PRODUCT_COPYRIGHT = .*", "PRODUCT_COPYRIGHT = Copyright © 2026 Meshex. All rights reserved.", text)
        appinfo.write_text(text)
    # Обновляем ссылки Xcode на продукт, в том числе в локальных проектах.
    for relative in ("macos/Runner.xcodeproj/project.pbxproj",
                     "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme"):
        f = ROOT / relative
        if f.exists():
            text = re.sub(r"[A-Za-z_][A-Za-z_0-9]*\.app\b", f"{APP_NAME}.app", f.read_text())
            text = re.sub(r'(TEST_HOST = "[^"\n]*/\$\(BUNDLE_EXECUTABLE_FOLDER_PATH\)/)[^"\n]+',
                          rf"\g<1>{APP_NAME}", text)
            f.write_text(text)
    for platform in ("linux", "windows"):
        f = ROOT / platform / "CMakeLists.txt"
        if f.exists():
            f.write_text(re.sub(r'set\(BINARY_NAME "[^" ]+"\)',
                                f'set(BINARY_NAME "{PROJECT}")', f.read_text()))
    # Windows: заголовок окна и описание в свойствах exe.
    replace_in(ROOT / "windows/runner/main.cpp", [(f'L"{PROJECT}"', f'L"{APP_NAME}"')])
    replace_in(ROOT / "windows/runner/Runner.rc", [
        (f'"FileDescription", "{PROJECT}"', f'"FileDescription", "{APP_NAME}"'),
        (f'"ProductName", "{PROJECT}"', f'"ProductName", "{APP_NAME}"'),
    ])
    # Linux: заголовок окна.
    replace_in(ROOT / "linux/runner/my_application.cc", [(f'"{PROJECT}"', f'"{APP_NAME}"')])
    replace_in(ROOT / "linux/my_application.cc", [(f'"{PROJECT}"', f'"{APP_NAME}"')])
    print("name: ok")


def patch_app_id():
    """Bundle id / applicationId → APP_ID. `flutter create` строит их из --org и имени
    проекта — заменяем полученные значения на APP_ID.
    Android namespace (пакет MainActivity) не трогаем: applicationId от него не зависит."""
    for relative in ("ios/Runner.xcodeproj/project.pbxproj",
                     "macos/Runner.xcodeproj/project.pbxproj",
                     "macos/Runner/Configs/AppInfo.xcconfig"):
        f = ROOT / relative
        if f.exists():
            text = f.read_text()
            text = re.sub(r"PRODUCT_BUNDLE_IDENTIFIER = [\w.]+(;) ?",
                          lambda m: f"PRODUCT_BUNDLE_IDENTIFIER = {APP_ID}" +
                          (".RunnerTests" if "RunnerTests" in m.group(0) else "") + ";", text)
            text = re.sub(r"(?m)^PRODUCT_BUNDLE_IDENTIFIER = [\w.]+$",
                          f"PRODUCT_BUNDLE_IDENTIFIER = {APP_ID}", text)
            f.write_text(text)
    for relative in ("android/app/build.gradle.kts", "android/app/build.gradle"):
        f = ROOT / relative
        if f.exists():
            text = re.sub(r'applicationId\s*=?\s*"[^" ]+"',
                          f'applicationId = "{APP_ID}"' if relative.endswith('.kts')
                          else f'applicationId "{APP_ID}"', f.read_text())
            f.write_text(text)
    f = ROOT / "linux/CMakeLists.txt"
    if f.exists():
        f.write_text(re.sub(r'set\(APPLICATION_ID "[^"]+"\)',
                            f'set(APPLICATION_ID "{APP_ID}")', f.read_text()))
    print("app id: ok")


def plist_add(f: pathlib.Path, entries: dict):
    if not f.exists():
        return
    s = f.read_text()
    add = "".join(
        f"\t<key>{k}</key>\n\t<string>{v}</string>\n" for k, v in entries.items() if k not in s
    )
    if add:
        s = re.sub(r"</dict>\s*</plist>\s*$", add + "</dict>\n</plist>\n", s)
        f.write_text(s)


def entitlements_add(f: pathlib.Path, keys):
    if not f.exists():
        return
    s = f.read_text()
    add = "".join(f"\t<key>{k}</key>\n\t<true/>\n" for k in keys if k not in s)
    if add:
        s = re.sub(r"</dict>\s*</plist>\s*$", add + "</dict>\n</plist>\n", s)
        f.write_text(s)


def patch_apple():
    ios_plist = ROOT / "ios/Runner/Info.plist"
    if ios_plist.exists() and "UIBackgroundModes" not in ios_plist.read_text():
        # Фоновый BLE: iOS будит приложение на пакеты от ноды после сворачивания.
        s = ios_plist.read_text()
        s = re.sub(r"</dict>\s*</plist>\s*$",
                   "\t<key>UIBackgroundModes</key>\n\t<array>\n\t\t<string>bluetooth-central</string>\n\t</array>\n"
                   "</dict>\n</plist>\n", s)
        ios_plist.write_text(s)
    plist_add(ROOT / "ios/Runner/Info.plist", {
        "NSBluetoothAlwaysUsageDescription": BT_TEXT,
        "NSLocalNetworkUsageDescription": NET_TEXT,
        "NSLocationWhenInUseUsageDescription": LOC_TEXT,
        "NSMotionUsageDescription": "Датчики движения помогают определять направление к ноде.",
        "NSCameraUsageDescription": CAM_TEXT,
    })
    # Поиск нод в локальной сети: iOS показывает только объявленные типы Bonjour.
    for f in (ROOT / "ios/Runner/Info.plist", ROOT / "macos/Runner/Info.plist"):
        if f.exists() and "NSBonjourServices" not in f.read_text():
            s = re.sub(r"</dict>\s*</plist>\s*$",
                       "\t<key>NSBonjourServices</key>\n\t<array>\n\t\t<string>_meshtastic._tcp</string>\n"
                       "\t</array>\n</dict>\n</plist>\n", f.read_text())
            f.write_text(s)
    # Настройка «Ориентация»: перевёрнутая книжная и на iPhone (по умолчанию
    # только на iPad). iPhone с Face ID её всё равно не поддерживают.
    if ios_plist.exists():
        s = ios_plist.read_text()
        m = re.search(r"(<key>UISupportedInterfaceOrientations</key>\s*<array>)(.*?)(</array>)", s, re.S)
        if m and "PortraitUpsideDown" not in m.group(2):
            s = s[:m.end(1)] + m.group(2).replace(
                "<string>UIInterfaceOrientationPortrait</string>",
                "<string>UIInterfaceOrientationPortrait</string>\n\t\t<string>UIInterfaceOrientationPortraitUpsideDown</string>",
                1) + s[m.start(3):]
            ios_plist.write_text(s)
    plist_add(ROOT / "macos/Runner/Info.plist", {
        "NSBluetoothAlwaysUsageDescription": BT_TEXT,
        "NSLocationUsageDescription": LOC_TEXT,
        "NSCameraUsageDescription": CAM_TEXT,
    })
    for name in ("DebugProfile.entitlements", "Release.entitlements"):
        entitlements_add(ROOT / "macos/Runner" / name, [
            "com.apple.security.device.bluetooth",
            "com.apple.security.network.client",
            "com.apple.security.device.serial",
            "com.apple.security.personal-information.location",
            "com.apple.security.device.camera",
            # Резервная копия ключей в файл: выбор и сохранение через диалог.
            "com.apple.security.files.user-selected.read-write",
        ])
    print("apple: ok")


def patch_notifications():
    """flutter_local_notifications: на Android нужен desugaring и иконка,
    которую R8 не выкинет; на iOS — делегат центра уведомлений, иначе
    уведомление не показывается, пока приложение на экране, и нажатие
    на него не доходит до приложения."""
    g = ROOT / "android/app/build.gradle.kts"
    if g.exists():
        s = orig = g.read_text()
        if "isCoreLibraryDesugaringEnabled" not in s:
            s = re.sub(r"(compileOptions\s*\{)", r"\1\n        isCoreLibraryDesugaringEnabled = true", s, count=1)
        if "desugar_jdk_libs" not in s:
            s = s.rstrip() + '\n\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
        if s != orig:
            g.write_text(s)
        keep = ROOT / "android/app/src/main/res/raw/keep.xml"
        if not keep.exists():
            keep.parent.mkdir(parents=True, exist_ok=True)
            keep.write_text(
                '<?xml version="1.0" encoding="utf-8"?>\n'
                '<resources xmlns:tools="http://schemas.android.com/tools"\n'
                '    tools:keep="@mipmap/ic_launcher" />\n'
            )
    d = ROOT / "ios/Runner/AppDelegate.swift"
    if d.exists():
        s = orig = d.read_text()
        if "UNUserNotificationCenter" not in s:
            s = s.replace("import UIKit", "import UIKit\nimport UserNotifications", 1)
            s = re.sub(
                r"(didFinishLaunchingWithOptions[^{]*\{\n)",
                r"\1    UNUserNotificationCenter.current().delegate = self\n",
                s, count=1)
        if s != orig:
            d.write_text(s)
    print("notifications: ok")


def patch_android_signing():
    """Релизный APK — постоянным ключом из секретов CI. Без него Flutter
    подписывает отладочным ключом, а тот на каждой машине CI свой: новая
    версия не ставится поверх старой («конфликтует с другим пакетом»)."""
    g = ROOT / "android/app/build.gradle.kts"
    if not g.exists():
        return
    if not os.environ.get("ANDROID_KEYSTORE_FILE"):
        print("android signing: no key, debug signature")
        return
    s = g.read_text()
    if 'create("release")' not in s:
        s = re.sub(r"(\n    buildTypes\s*\{)", """
    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("ANDROID_KEYSTORE_FILE"))
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")
            keyPassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
        }
    }
\\1""", s, count=1)
        s = s.replace('signingConfig = signingConfigs.getByName("debug")',
                      'signingConfig = signingConfigs.getByName("release")')
        if 'getByName("release")' not in s:
            sys.exit("android signing: не нашёл signingConfig в build.gradle.kts")
        g.write_text(s)
    print("android signing: ok")


COMPILE_SDK = 36


LINUX_ICON = """
  // Иконка окна: data/flutter_assets рядом с исполняемым файлом.
  {
    g_autofree gchar* exe = g_file_read_link("/proc/self/exe", nullptr);
    if (exe != nullptr) {
      g_autofree gchar* dir = g_path_get_dirname(exe);
      g_autofree gchar* icon = g_build_filename(
          dir, "data", "flutter_assets", "assets", "icon", "window.png",
          nullptr);
      gtk_window_set_icon_from_file(window, icon, nullptr);
    }
  }
"""


def patch_linux_icon():
    anchor = "gtk_window_set_default_size(window, 1280, 720);"
    for f in (ROOT / "linux/runner/my_application.cc", ROOT / "linux/my_application.cc"):
        if not f.exists():
            continue
        s = f.read_text()
        if "window.png" not in s and anchor in s:
            f.write_text(s.replace(anchor, anchor + "\n" + LINUX_ICON, 1))
    print("linux icon: ok")


def patch_linux_warnings():
    """tray_manager зовёт app_indicator_new, устаревший в свежих Ubuntu;
    шаблон Flutter собирает плагины с -Werror — отключаем только это."""
    f = ROOT / "linux/CMakeLists.txt"
    if not f.exists():
        return
    s = f.read_text(encoding="utf-8")
    flag = "-Wno-deprecated-declarations"
    if flag not in s and "-Wall -Werror" in s:
        f.write_text(s.replace("-Wall -Werror", f"-Wall -Werror {flag}"), encoding="utf-8")
    print("linux warnings: ok")


def patch_plugins():
    """usb_serial и flutter_libserialport устарели: вызывают jcenter() (убран в
    Gradle 9) и собираются под старый compileSdk (androidx требует >= 34).
    Правим их копии в pub-кэше (нужен уже выполненный pub get)."""
    cfg = ROOT / ".dart_tool/package_config.json"
    if not cfg.exists():
        print("plugins: нет package_config.json — сначала flutter pub get")
        return
    for pkg in json.loads(cfg.read_text())["packages"]:
        if pkg["name"] not in ("usb_serial", "flutter_libserialport"):
            continue
        base = pathlib.Path(pkg["rootUri"].removeprefix("file://"))
        if not base.is_absolute():
            base = (cfg.parent / base).resolve()
        for f in (base / "android").glob("build.gradle*"):
            s = f.read_text()
            new = s.replace("jcenter()", "mavenCentral()")
            new = re.sub(r"compileSdk(Version)? \d+", f"compileSdk {COMPILE_SDK}", new)
            if new != s:
                f.write_text(new)
    print("plugins: ok")


def patch_icons_config():
    """flutter_launcher_icons падает на платформе без папки (CI создаёт только
    свою). Пишем flutter_launcher_icons.yaml — его утилита берёт раньше
    pubspec — только с существующими платформами; настройки из pubspec."""
    lines = pathlib.Path("pubspec.yaml").read_text(encoding="utf-8").splitlines()
    start = lines.index("flutter_launcher_icons:")
    section = ["flutter_launcher_icons:"]
    for line in lines[start + 1:]:
        if line and not line.startswith((" ", "#")):
            break
        section.append(line)
    skip = None
    out = []
    for line in section:
        m = re.match(r"  (\w+):", line)
        if m:
            key = m.group(1)
            skip = key in ("ios", "macos", "windows", "android") and \
                not pathlib.Path(key).is_dir()
            if skip and key in ("ios", "android"):
                out.append(f"  {key}: false")
                continue
        elif not line.startswith("    "):
            skip = False
        if not skip:
            out.append(line)
    cfg = pathlib.Path("flutter_launcher_icons.yaml")
    # Linux: иконку кладёт patch_linux_icon, утилите делать нечего.
    if not any(pathlib.Path(p).is_dir() for p in ("android", "ios", "macos", "windows")):
        cfg.unlink(missing_ok=True)
        print("icons config: нет платформ для утилиты")
        return
    cfg.write_text("\n".join(out) + "\n", encoding="utf-8")
    print("icons config: ok")


if __name__ == "__main__":
    # Консоль Windows в CI — cp1252: кириллица в print роняет скрипт.
    sys.stdout.reconfigure(encoding="utf-8")
    patch_name()
    patch_app_id()
    patch_android()
    patch_apple()
    patch_notifications()
    patch_android_signing()
    patch_linux_icon()
    patch_linux_warnings()
    patch_plugins()
    patch_icons_config()
