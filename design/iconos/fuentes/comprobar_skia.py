#!/usr/bin/env python3
"""Comprueba los glifos de la TTF con Skia (Chromium por Playwright), el motor de texto de Flutter.

    python3 comprobar_skia.py <ttf> <iconos.py> <insignias.py> <carpeta_salida>

Por glifo y tamaño (16 y 24 px) captura tres celdas: el glifo como texto de la fuente, el mismo SVG del
ícono en línea (ambos en Chromium) y compara con el SVG rasterizado por resvg. Escribe
comprobacion-skia.md (tabla) y comprobacion-skia.png (hoja). Necesita Node con Playwright y Chromium.
"""
import base64, io, os, subprocess, sys, json
from PIL import Image, ImageDraw, ImageFont
import resvg_py
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from dsl import cargar

TAMS = (16, 24)
TINTA, FONDO = '#10243F', '#F5F8FC'


def main():
    ttf, ic_py, ins_py, out = sys.argv[1:5]
    os.makedirs(out, exist_ok=True)
    iconos = cargar(ic_py); insignias = cargar(ins_py)
    todos = dict(iconos); todos.update({f'insignia_{k}': v for k, v in insignias.items()})
    codigos = json.load(open(os.path.join(os.path.dirname(ttf), '..', '..', '..', 'design', 'iconos', 'codigos.json'), encoding='utf-8'))['codigos'] \
        if os.path.exists(os.path.join(os.path.dirname(ttf), '..', '..', '..', 'design', 'iconos', 'codigos.json')) else None
    if codigos is None:
        codigos = {n: f'U+{0xE000 + i:04X}' for i, n in enumerate(todos)}
    b64 = base64.b64encode(open(ttf, 'rb').read()).decode()
    partes = [f'<!doctype html><html><head><meta charset="utf-8"><style>@font-face{{font-family:BS;src:url(data:font/ttf;base64,{b64}) format("truetype");}}'
              f'body{{margin:16px;background:{FONDO};color:{TINTA};font-family:BS;}} .t{{display:block;line-height:1;font-family:BS;}}'
              f'.c{{display:inline-block;vertical-align:top;margin:0 8px 8px 0;background:{FONDO};}} svg{{display:block}}</style></head><body>']
    for n, ic in todos.items():
        cp = int(codigos[n][2:], 16)
        for px in TAMS:
            partes.append(f'<div class="c" data-celda="{n}_{px}_texto" style="width:{px}px;height:{px}px"><span class="t" style="font-size:{px}px;width:{px}px;height:{px}px">&#x{cp:X};</span></div>')
            svg = ic.svg(tam=px, titulo=False).replace('<svg ', f'<svg data-celda="{n}_{px}_svg" ', 1)
            partes.append(f'<div class="c" style="width:{px}px;height:{px}px">{svg}</div>')
        partes.append('<br>')
    partes.append('</body></html>')
    html = os.path.join(out, '_skia.html')
    open(html, 'w', encoding='utf-8').write(''.join(partes))
    env = dict(os.environ, NODE_PATH=subprocess.run(['npm', 'root', '-g'], capture_output=True, text=True).stdout.strip())
    r = subprocess.run(['node', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'comprobar_skia.js'), html, out], env=env, capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stdout, r.stderr); sys.exit(1)
    filas = []
    celdas = []
    for n, ic in todos.items():
        fila = {'nombre': n}
        for px in TAMS:
            t = Image.open(os.path.join(out, f'{n}_{px}_texto.png')).convert('RGB')
            s = Image.open(os.path.join(out, f'{n}_{px}_svg.png')).convert('RGB')
            r_ = Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_string=ic.svg(color=TINTA), width=px, height=px)))).convert('RGBA')
            fondo = Image.new('RGB', (px, px), FONDO); fondo.paste(r_, (0, 0), r_); r_ = fondo
            def tinta(img):
                # proporción de tinta por píxel: 0 = fondo, 255 = tinta
                g = img.convert('L').tobytes()
                lo, hi = Image.new('RGB', (1, 1), TINTA).convert('L').tobytes()[0], Image.new('RGB', (1, 1), FONDO).convert('L').tobytes()[0]
                return [max(0, min(255, int(255 * (hi - v) / (hi - lo)))) for v in g]
            A, B, C = tinta(t), tinta(s), tinta(r_)
            def estado(X, Y): return sum(1 for x, y in zip(X, Y) if (x >= 128) != (y >= 128))
            def media(X, Y): return sum(abs(x - y) for x, y in zip(X, Y)) / len(X)
            fila[f'texto_vs_svg_{px}'] = (estado(A, B), round(100 * estado(A, B) / (px * px), 1), round(media(A, B), 2))
            fila[f'texto_vs_resvg_{px}'] = (estado(A, C), round(100 * estado(A, C) / (px * px), 1), round(media(A, C), 2))
            celdas.append((n, px, t, s, r_))
        fila['ok'] = all(fila[f'texto_vs_svg_{px}'][1] <= 4 or fila[f'texto_vs_svg_{px}'][2] <= 12 for px in TAMS)
        filas.append(fila)
    # tabla
    md = ['| Glifo | 16 px: texto vs SVG en Chromium (cambian · % · Δ medio) | 16 px: texto vs resvg | 24 px: texto vs SVG en Chromium | 24 px: texto vs resvg | Coincide |', '|---|---|---|---|---|---|']
    for f in filas:
        a, b, c, d = f['texto_vs_svg_16'], f['texto_vs_resvg_16'], f['texto_vs_svg_24'], f['texto_vs_resvg_24']
        md.append(f"| `{f['nombre']}` | {a[0]} · {a[1]} % · {a[2]} | {b[0]} · {b[1]} % · {b[2]} | {c[0]} · {c[1]} % · {c[2]} | {d[0]} · {d[1]} % · {d[2]} | {'sí' if f['ok'] else 'no'} |")
    open(os.path.join(out, 'comprobacion-skia.md'), 'w', encoding='utf-8', newline='\n').write('\n'.join(md) + '\n')
    # hoja
    z = {16: 6, 24: 4}
    nombres = list(todos)
    fila_h = 24 * 4 + 12; col_w = 3 * (24 * 4 + 6) + 24
    img = Image.new('RGB', (170 + 2 * col_w, 30 + fila_h * len(nombres)), '#DDE3EA')
    dib = ImageDraw.Draw(img)
    try: f = ImageFont.load_default(size=12)
    except TypeError: f = ImageFont.load_default()
    dib.text((8, 8), 'glifo', fill='#000', font=f)
    dib.text((170, 8), '16 px: texto (Skia) | SVG (Skia) | SVG (resvg)  x6', fill='#000', font=f)
    dib.text((170 + col_w, 8), '24 px: texto (Skia) | SVG (Skia) | SVG (resvg)  x4', fill='#000', font=f)
    for i, n in enumerate(nombres):
        y = 30 + i * fila_h
        dib.text((8, y + 8), n, fill='#10243F', font=f)
        for (nn, px, a, b, c) in celdas:
            if nn != n: continue
            x = 170 + (0 if px == 16 else col_w)
            for im in (a, b, c):
                img.paste(im.resize((px * z[px], px * z[px]), Image.NEAREST), (x, y + 4)); x += px * z[px] + 6
    img.save(os.path.join(out, 'comprobacion-skia.png'), optimize=True)
    for p in os.listdir(out):
        if p.endswith('_texto.png') or p.endswith('_svg.png') or p == '_skia.html':
            os.remove(os.path.join(out, p))
    malos = [f['nombre'] for f in filas if not f['ok']]
    print(f"skia: {len(filas) - len(malos)} de {len(filas)} glifos coinciden" + (f" (revisar: {', '.join(malos)})" if malos else ''))
    sys.exit(1 if malos else 0)


if __name__ == '__main__':
    main()
