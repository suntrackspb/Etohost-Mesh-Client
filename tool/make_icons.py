"""Производные от assets/icon/app_icon.png: иконки трея (Windows .ico с PNG
внутри, Linux .png), окна Linux и пустой передний слой Android. Нужен macOS (sips); запускать при смене иконки приложения."""
import pathlib, struct, subprocess, tempfile, zlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/icon/app_icon.png"
OUT = ROOT / "assets/tray"


def scaled(size: int) -> bytes:
    with tempfile.TemporaryDirectory() as d:
        out = pathlib.Path(d) / "i.png"
        subprocess.run(["sips", "-z", str(size), str(size), str(SRC), "--out", str(out)],
                       check=True, capture_output=True)
        return out.read_bytes()


def ico(sizes):
    imgs = [scaled(s) for s in sizes]
    head = struct.pack("<HHH", 0, 1, len(imgs))
    off = 6 + 16 * len(imgs)
    dirs = b""
    for s, d in zip(sizes, imgs):
        dirs += struct.pack("<BBBBHHII", s % 256, s % 256, 0, 0, 1, 32, len(d), off)
        off += len(d)
    return head + dirs + b"".join(imgs)


def transparent_png(size: int) -> bytes:
    """Пустой передний слой адаптивной иконки Android: рисунок — в фоне."""
    raw = (b"\0" + b"\0" * 4 * size) * size

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))
    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


OUT.mkdir(parents=True, exist_ok=True)
(OUT / "icon.png").write_bytes(scaled(64))
# Иконка окна Linux (у Flutter-шаблона её нет).
(ROOT / "assets/icon/window.png").write_bytes(scaled(256))
(OUT / "icon.ico").write_bytes(ico([16, 24, 32, 48, 64]))
(ROOT / "assets/icon/android_foreground.png").write_bytes(transparent_png(432))
