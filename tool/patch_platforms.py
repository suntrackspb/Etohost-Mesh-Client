#!/usr/bin/env python3
"""Прописывает имя приложения и разрешения Bluetooth/сети/USB в папки, созданные `flutter create`.
Запускается в CI после `flutter create`; повторный запуск безопасен."""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP_NAME = "Etohost Mesh"
# Идентификатор приложения на всех платформах. После публикации в сторах не менять:
# с другим id приложение считается новым, обновление поверх старого не встанет.
APP_ID = "ru.etohost.mesh"
# Имя проекта Flutter (`--project-name` в CI), оно же имя exe/бинарника.
PROJECT = "etohost_mesh"
BT_TEXT = "Bluetooth нужен для подключения к ноде Meshtastic."
NET_TEXT = "Локальная сеть нужна для подключения к ноде Meshtastic по Wi-Fi."
LOC_TEXT = "Позиция телефона передаётся вашей ноде, если это включено в настройках приложения."


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
    ]
    # Раньше геолокация была ограничена Android 11 — снимаем ограничение.
    s = re.sub(r'(android\.permission\.ACCESS_(?:FINE|COARSE)_LOCATION")\s+android:maxSdkVersion="30"', r"\1", s)
    add = "".join(f"    {p}\n" for p in perms if p.split('"')[1] not in s)
    if add:
        s = s.replace("<application", add + "    <application", 1)
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
    """Отображаемое имя «Etohost Mesh» на всех платформах."""
    replace_in(ROOT / "android/app/src/main/AndroidManifest.xml",
               [(f'android:label="{PROJECT}"', f'android:label="{APP_NAME}"')])
    for plist in ("ios/Runner/Info.plist", "macos/Runner/Info.plist"):
        plist_set(ROOT / plist, "CFBundleDisplayName", APP_NAME)
    plist_set(ROOT / "ios/Runner/Info.plist", "CFBundleName", APP_NAME)
    # macOS: имя .app и пункта меню берётся из PRODUCT_NAME.
    replace_in(ROOT / "macos/Runner/Configs/AppInfo.xcconfig",
               [(f"PRODUCT_NAME = {PROJECT}", f"PRODUCT_NAME = {APP_NAME}")])
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
    проекта (ru.etohost.etohostMesh, ru.etohost.etohost_mesh) — заменяем оба варианта.
    Android namespace (пакет MainActivity) не трогаем: applicationId от него не зависит."""
    camel = re.sub(r"_(.)", lambda m: m.group(1).upper(), PROJECT)
    generated = [f"ru.etohost.{camel}", f"ru.etohost.{PROJECT}"]

    def sub_ids(f: pathlib.Path, pattern: str):
        if not f.exists():
            return
        s = f.read_text(encoding="utf-8")
        new = s
        for old in generated:
            # ...RunnerTests и прочие суффиксы сохраняются: ru.etohost.mesh.RunnerTests
            new = re.sub(pattern.format(re.escape(old)), lambda m: m.group(0).replace(old, APP_ID), new)
        if new != s:
            f.write_text(new, encoding="utf-8")

    for pbx in ("ios/Runner.xcodeproj/project.pbxproj", "macos/Runner.xcodeproj/project.pbxproj"):
        sub_ids(ROOT / pbx, r"PRODUCT_BUNDLE_IDENTIFIER = {}\b")
    sub_ids(ROOT / "macos/Runner/Configs/AppInfo.xcconfig", r"PRODUCT_BUNDLE_IDENTIFIER = {}\b")
    for gradle in ("android/app/build.gradle.kts", "android/app/build.gradle"):
        sub_ids(ROOT / gradle, r'applicationId\s*=?\s*"{}"')
    sub_ids(ROOT / "linux/CMakeLists.txt", r'set\(APPLICATION_ID "{}"\)')
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
    })
    plist_add(ROOT / "macos/Runner/Info.plist", {
        "NSBluetoothAlwaysUsageDescription": BT_TEXT,
        "NSLocationUsageDescription": LOC_TEXT,
    })
    for name in ("DebugProfile.entitlements", "Release.entitlements"):
        entitlements_add(ROOT / "macos/Runner" / name, [
            "com.apple.security.device.bluetooth",
            "com.apple.security.network.client",
            "com.apple.security.device.serial",
            "com.apple.security.personal-information.location",
        ])
    print("apple: ok")


COMPILE_SDK = 36


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


if __name__ == "__main__":
    patch_name()
    patch_app_id()
    patch_android()
    patch_apple()
    patch_plugins()
