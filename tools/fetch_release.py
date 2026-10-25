#!/usr/bin/env python3
"""Выкладка релиза на etohost.ru/downloads: сервер сам качает файлы с GitHub.

На g4 лежит в /usr/local/bin/etohost-fetch-release (владелец root); ключ пользователя releases
в authorized_keys привязан к нему (command=...), тег приходит в
SSH_ORIGINAL_COMMAND. Вызов из .github/workflows/publish.yml:
    ssh releases@192.168.1.10 v0.1.12
Вручную на сервере:
    sudo -u releases /usr/local/bin/etohost-fetch-release v0.1.12

Порядок: файлы во временную папку → проверка размера и sha256 → папка
версии → постоянные имена жёсткими ссылками → release.json последним.
При любой ошибке текущие файлы сайта не меняются.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import sys
import urllib.request
from pathlib import Path

REPO = "suntrackspb/Etohost-Mesh-Client"
ROOT = Path(os.environ.get("RELEASES_ROOT", "/var/www/etohost.ru/etohostmesh"))
KEEP = 3
TAG_RE = re.compile(r"^v(\d+\.\d+\.\d+)$")
VER_RE = re.compile(r"^\d+\.\d+\.\d+$")

# Ключ в release.json = data-os строки на странице загрузок.
KEYS = {
    "etohost-mesh-android.apk": "android",
    "etohost-mesh-android-universal.apk": "android-universal",
    "etohost-mesh-ios.ipa": "ios",
    "etohost-mesh-windows.zip": "windows",
    "etohost-mesh-macos.zip": "macos",
    "etohost-mesh-linux.tar.gz": "linux",
}


def log(msg: str) -> None:
    print(msg, flush=True)


def get_json(url: str) -> dict:
    req = urllib.request.Request(
        url, headers={"Accept": "application/vnd.github+json", "User-Agent": "etohost-releases"}
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


def download(url: str, dest: Path) -> str:
    """Скачать в dest; вернуть sha256."""
    h = hashlib.sha256()
    req = urllib.request.Request(url, headers={"User-Agent": "etohost-releases"})
    with urllib.request.urlopen(req, timeout=60) as r, open(dest, "wb") as f:
        while chunk := r.read(1 << 20):
            h.update(chunk)
            f.write(chunk)
    return h.hexdigest()


def ver_key(v: str) -> tuple[int, ...]:
    return tuple(int(x) for x in v.split("."))


def to_prune(names: list[str], keep: int = KEEP) -> list[str]:
    """Папки версий сверх keep последних."""
    vers = sorted((n for n in names if VER_RE.match(n)), key=ver_key)
    return vers[:-keep] if len(vers) > keep else []


def build_release(version: str, rel: dict, files: dict[str, dict]) -> dict:
    return {
        "version": version,
        # Дата — публикации релиза, не прогона (перезаливка старого тега).
        "date": str(rel.get("published_at") or "")[:10],
        "notes_url": rel.get("html_url", ""),
        "files": {KEYS[n]: files[n] for n in KEYS if n in files},
    }


def publish(tag: str) -> int:
    m = TAG_RE.match(tag)
    if not m:
        log(f"Не тег версии: {tag!r}")
        return 2
    version = m.group(1)
    rel = get_json(f"https://api.github.com/repos/{REPO}/releases/tags/{tag}")
    if rel.get("draft") or rel.get("prerelease"):
        log("Черновик или пре-релиз — не выкладываю")
        return 1
    assets = {a["name"]: a for a in rel.get("assets", []) if a.get("name") in KEYS}
    if "etohost-mesh-android.apk" not in assets:
        log("В релизе нет etohost-mesh-android.apk")
        return 1

    staging = ROOT / f".incoming-{version}"
    shutil.rmtree(staging, ignore_errors=True)
    staging.mkdir()
    try:
        files: dict[str, dict] = {}
        for name, a in sorted(assets.items()):
            dest = staging / name
            sha = download(a["browser_download_url"], dest)
            size = dest.stat().st_size
            if size != a.get("size"):
                raise RuntimeError(f"{name}: размер {size}, ожидался {a.get('size')}")
            digest = a.get("digest") or ""
            if digest.startswith("sha256:") and digest[7:] != sha:
                raise RuntimeError(f"{name}: sha256 не совпал")
            os.chmod(dest, 0o644)
            files[name] = {"name": name, "size": size, "sha256": sha}
            log(f"{name}: {size} байт")
        release = build_release(version, rel, files)

        # Папка версии целиком (перезаливка тега заменяет её).
        target = ROOT / version
        if target.exists():
            shutil.rmtree(target)
        staging.rename(target)
        os.chmod(target, 0o755)
        # Постоянные имена: жёсткая ссылка во временное имя → атомарная замена.
        for name in files:
            tmp = ROOT / f".{name}.new"
            tmp.unlink(missing_ok=True)
            os.link(target / name, tmp)
            os.replace(tmp, ROOT / name)
        # Файл, которого нет в новом релизе, на сайте не оставляем.
        for name in KEYS:
            if name not in files:
                (ROOT / name).unlink(missing_ok=True)
        tmp = ROOT / ".release.json.new"
        tmp.write_text(json.dumps(release, ensure_ascii=False, indent=2), "utf-8")
        os.chmod(tmp, 0o644)
        os.replace(tmp, ROOT / "release.json")
    finally:
        shutil.rmtree(staging, ignore_errors=True)

    for old in to_prune([p.name for p in ROOT.iterdir() if p.is_dir()]):
        shutil.rmtree(ROOT / old)
        log(f"Удалена старая версия {old}")
    log(json.dumps(release, ensure_ascii=False, indent=2))
    return 0


def main() -> int:
    args = sys.argv[1:] or os.environ.get("SSH_ORIGINAL_COMMAND", "").split()
    if len(args) != 1:
        log("Нужен один аргумент — тег релиза, например v0.1.12")
        return 2
    try:
        return publish(args[0])
    except Exception as e:  # noqa: BLE001 — сеть, GitHub, диск: сообщить и выйти
        log(f"Ошибка: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
