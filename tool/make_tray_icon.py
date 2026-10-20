"""Иконка трея (Windows .ico, Linux .png): бирюзовый круг с тремя
связанными узлами. Без внешних библиотек; запускать при изменении рисунка."""
import math, pathlib, struct, zlib

OUT = pathlib.Path(__file__).resolve().parent.parent / "assets/tray"
SEED = (0x2E, 0x9E, 0x8F)
NODES = [(0.50, 0.28), (0.28, 0.68), (0.72, 0.68)]


def seg(px, py, a, b):
    ax, ay = a; bx, by = b
    dx, dy = bx - ax, by - ay
    t = max(0, min(1, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)))
    return math.hypot(px - ax - t * dx, py - ay - t * dy)


def sample(x, y):
    if math.hypot(x - 0.5, y - 0.5) > 0.48:
        return None
    white = any(math.hypot(x - nx, y - ny) < 0.105 for nx, ny in NODES) or any(
        seg(x, y, NODES[i], NODES[(i + 1) % 3]) < 0.035 for i in range(3))
    return (255, 255, 255) if white else SEED


def png(size):
    ss = 4
    rows = b""
    for j in range(size):
        rows += b"\0"
        for i in range(size):
            acc = [0, 0, 0, 0]
            for sj in range(ss):
                for si in range(ss):
                    c = sample((i + (si + .5) / ss) / size, (j + (sj + .5) / ss) / size)
                    if c:
                        for k in range(3):
                            acc[k] += c[k]
                        acc[3] += 1
            n = acc[3]
            rows += bytes([acc[0] // n, acc[1] // n, acc[2] // n] if n else [0, 0, 0])
            rows += bytes([n * 255 // (ss * ss)])

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))
    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b""))


def ico(sizes):
    imgs = [png(s) for s in sizes]
    head = struct.pack("<HHH", 0, 1, len(imgs))
    off = 6 + 16 * len(imgs)
    dirs = b""
    for s, d in zip(sizes, imgs):
        dirs += struct.pack("<BBBBHHII", s % 256, s % 256, 0, 0, 1, 32, len(d), off)
        off += len(d)
    return head + dirs + b"".join(imgs)


OUT.mkdir(parents=True, exist_ok=True)
(OUT / "icon.png").write_bytes(png(64))
(OUT / "icon.ico").write_bytes(ico([16, 24, 32, 48, 64]))
