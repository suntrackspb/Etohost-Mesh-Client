#!/usr/bin/env python3
"""Справочник плат для карточки ноды (п. 53 PLAN).

Источник: Meshtastic-Apple/Meshtastic/Resources/DeviceHardware.json,
картинки — mesh-mirror-v2/templates/dist/hw и tool/hw_extra (недостающие,
из github.com/meshtastic/web-flasher public/img/devices; всё — GPL-3).
Пишет lib/data/hardware_catalog.g.dart и копирует нужные SVG в assets/hw/.
Запуск из корня проекта: python3 tool/gen_hardware.py
"""
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_JSON = os.path.join(ROOT, '..', 'Meshtastic-Apple', 'Meshtastic', 'Resources',
                        'DeviceHardware.json')
SRC_IMG = os.path.join(ROOT, '..', 'mesh-mirror-v2', 'templates', 'dist', 'hw')
EXTRA_IMG = os.path.join(ROOT, 'tool', 'hw_extra')
OUT_IMG = os.path.join(ROOT, 'assets', 'hw')
OUT_DART = os.path.join(ROOT, 'lib', 'data', 'hardware_catalog.g.dart')

PORTDUINO = 37

_RULE = re.compile(r'([^{}]+)\{([^}]*)\}')


def inline_styles(svg):
    """flutter_svg не понимает <style>: переносим правила .класс{...}
    в атрибуты элементов. Свои атрибуты элемента важнее."""
    css = ''.join(re.findall(r'<style[^>]*>(.*?)</style>', svg, re.S))
    rules = {}
    for sel, body in _RULE.findall(css):
        props = {}
        for decl in body.split(';'):
            if ':' in decl:
                k, v = decl.split(':', 1)
                props[k.strip()] = v.strip()
        for one in sel.split(','):
            one = one.strip()
            if one.startswith('.'):
                rules.setdefault(one[1:], {}).update(props)
    svg = re.sub(r'<style[^>]*>.*?</style>', '', svg, flags=re.S)

    def fix(m):
        tag = m.group(0)
        cls = re.search(r'\sclass="([^"]*)"', tag)
        if not cls:
            return tag
        props = {}
        for c in cls.group(1).split():
            props.update(rules.get(c, {}))
        tag = tag.replace(cls.group(0), '')
        extra = ''.join(f' {k}="{v}"' for k, v in props.items()
                        if not re.search(rf'\s{re.escape(k)}=', tag))
        end = '/>' if tag.endswith('/>') else '>'
        return tag[:-len(end)] + extra + end

    return re.sub(r'<[a-zA-Z][^<>]*>', fix, svg)


def main():
    entries = json.load(open(SRC_JSON))
    src = {f: os.path.join(SRC_IMG, f) for f in os.listdir(SRC_IMG)}
    src.update({f: os.path.join(EXTRA_IMG, f) for f in os.listdir(EXTRA_IMG)})
    have = set(src)
    best = {}
    for d in entries:
        # Как в iOS: все картинки варианта (до 4), по имени файла.
        imgs = sorted(i for i in d.get('images') or [] if i in have)[:4]
        # Поддерживаемая и с картинкой — лучше.
        score = (bool(d.get('activelySupported')), bool(imgs))
        m = d['hwModel']
        if m not in best or score > best[m][0]:
            best[m] = (score, d, imgs)
    # PORTDUINO (Linux, meshtasticd) в справочнике нет — как в iOS,
    # показываем картинки плат с прошивкой native (Tux и RAK6421 Hat+).
    if PORTDUINO not in best:
        native = sorted({i for d in entries if d['platformioTarget'] == 'native'
                         for i in d.get('images') or [] if i in have})[:4]
        best[PORTDUINO] = ((True, True), {'displayName': 'PORTDUINO',
                                          'supportLevel': 1}, native)
    os.makedirs(OUT_IMG, exist_ok=True)
    for f in os.listdir(OUT_IMG):
        os.remove(os.path.join(OUT_IMG, f))
    lines = []
    for m in sorted(best):
        _, d, imgs = best[m]
        for img in imgs:
            with open(src[img]) as f:
                svg = inline_styles(f.read())
            with open(os.path.join(OUT_IMG, img), 'w') as f:
                f.write(svg)
        name = d['displayName'].replace("\\", "\\\\").replace("'", "\\'")
        images = ', '.join(f"'{i}'" for i in imgs)
        # Как SupportLevel в iOS; нет поля — снята с поддержки (0).
        level = d.get('supportLevel') or 0
        lines.append(f"  {m}: (name: '{name}', images: [{images}], level: {level}),")
    with open(OUT_DART, 'w') as f:
        f.write('// Сгенерировано tool/gen_hardware.py — не править вручную.\n\n')
        f.write("import 'hardware_catalog.dart';\n\n")
        f.write('const hardwareCatalog = <int, HardwareInfo>{\n')
        f.write('\n'.join(lines))
        f.write('\n};\n')
    print(f'{len(best)} моделей, картинок {len(os.listdir(OUT_IMG))}')


if __name__ == '__main__':
    main()
