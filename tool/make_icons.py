"""Иконки из SVG-исходников assets/icon/src: app.svg — приложение,
tray.svg (монохромная) — трей. Рендер — headless Chrome (sips рисует SVG
с ошибками), масштаб — sips. Нужен macOS с Google Chrome; запускать при
смене исходников, затем `dart run flutter_launcher_icons`."""
import pathlib, struct, subprocess, tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/icon/src"
ICON = ROOT / "assets/icon"
TRAY = ROOT / "assets/tray"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
SIZE = 1024
BG = "#FFFFFF"


def render(svg: pathlib.Path, out: pathlib.Path, scale: float, bg: str | None):
    """SVG по центру холста SIZE×SIZE, занимает долю scale; фон bg или прозрачный."""
    side = round(SIZE * scale)
    html = (f'<html><body style="margin:0;width:{SIZE}px;height:{SIZE}px;'
            f'display:flex;align-items:center;justify-content:center;'
            f'background:{bg or "transparent"}">'
            f'<img src="{svg.as_uri()}" width="{side}" height="{side}"></body></html>')
    with tempfile.TemporaryDirectory() as d:
        page = pathlib.Path(d) / "i.html"
        page.write_text(html)
        subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                        "--allow-file-access-from-files",
                        "--default-background-color=00000000",
                        f"--window-size={SIZE},{SIZE}", f"--screenshot={out}",
                        page.as_uri()], check=True, capture_output=True)


def scaled(src: pathlib.Path, size: int) -> bytes:
    with tempfile.TemporaryDirectory() as d:
        out = pathlib.Path(d) / "i.png"
        subprocess.run(["sips", "-z", str(size), str(size), str(src), "--out", str(out)],
                       check=True, capture_output=True)
        return out.read_bytes()


def ico(src: pathlib.Path, sizes):
    imgs = [scaled(src, s) for s in sizes]
    head = struct.pack("<HHH", 0, 1, len(imgs))
    off = 6 + 16 * len(imgs)
    dirs = b""
    for s, d in zip(sizes, imgs):
        dirs += struct.pack("<BBBBHHII", s % 256, s % 256, 0, 0, 1, 32, len(d), off)
        off += len(d)
    return head + dirs + b"".join(imgs)


TRAY.mkdir(parents=True, exist_ok=True)
app = ICON / "app_icon.png"
# iOS не допускает прозрачности: фон сплошной, вокруг рисунка поля.
render(SRC / "app.svg", app, 0.82, BG)
# Адаптивная иконка Android: фон — цвет BG (pubspec), рисунок в безопасной
# зоне маски (круг ~66% холста).
render(SRC / "app.svg", ICON / "android_foreground.png", 0.6, None)
# Иконка окна Linux (у Flutter-шаблона её нет).
(ICON / "window.png").write_bytes(scaled(app, 256))
with tempfile.TemporaryDirectory() as d:
    tray = pathlib.Path(d) / "tray.png"
    render(SRC / "tray.svg", tray, 1.0, None)
    (TRAY / "icon.png").write_bytes(scaled(tray, 64))
    (TRAY / "icon.ico").write_bytes(ico(tray, [16, 24, 32, 48, 64]))
