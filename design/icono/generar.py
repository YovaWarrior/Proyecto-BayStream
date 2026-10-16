#!/usr/bin/env python3
"""Genera todos los archivos del ícono de BayStream a partir de los SVG de esta carpeta y los verifica.

Uso, desde la raíz del repositorio:

    python -m pip install resvg-py==0.5.0 Pillow
    python design/icono/generar.py               # escribe los archivos y los verifica
    python design/icono/generar.py --verificar   # solo verifica lo que ya está escrito
    python design/icono/generar.py --salida X    # escribe en otra carpeta, con la misma estructura

Los SVG se rasterizan con resvg (resvg-py 0.5.0), que da el mismo resultado en Windows, Linux y macOS.
"""
import argparse, hashlib, io, math, os, struct, sys
from pathlib import Path

try:
    import resvg_py
    from PIL import Image
except ImportError as e:  # pragma: no cover
    sys.exit(f'Falta una dependencia ({e.name}). Instala con: python -m pip install resvg-py==0.5.0 Pillow')

AQUI = Path(__file__).resolve().parent
RAIZ = AQUI.parent.parent
FONDO = '#0D47A1'                       # capa de fondo del ícono adaptativo
ZONA_SEGURA_DP, LIENZO_DP = 66, 108     # Android: el frente cabe en un círculo de 66 dp de 108
MASKABLE = 0.80                         # Web: lo importante dentro del círculo del 80 %
RADIO_PLAY = 0.20                       # Play redondea las esquinas un 20 % del lado
LIMITE_PLAY_KB = 1024

RES = 'android/app/src/main/res'
DENSIDADES = [('mdpi', 1), ('hdpi', 1.5), ('xhdpi', 2), ('xxhdpi', 3), ('xxxhdpi', 4)]

# (ruta, svg fuente, ancho, alto, modo, tipo de comprobación)
PNGS = []
for dens, f in DENSIDADES:
    PNGS += [
        (f'{RES}/mipmap-{dens}/ic_launcher_foreground.png', 'baystream_frente.svg', int(108*f), int(108*f), 'RGBA', 'adaptativo'),
        (f'{RES}/mipmap-{dens}/ic_launcher_monochrome.png', 'baystream_monocromo.svg', int(108*f), int(108*f), 'RGBA', 'adaptativo'),
        (f'{RES}/mipmap-{dens}/ic_launcher.png', 'baystream_forma.svg', int(48*f), int(48*f), 'RGBA', 'forma'),
    ]
PNGS += [
    ('web/favicon.png', 'baystream_32.svg', 32, 32, 'RGBA', 'forma'),
    ('web/icons/Icon-192.png', 'baystream_forma.svg', 192, 192, 'RGBA', 'forma'),
    ('web/icons/Icon-512.png', 'baystream_forma.svg', 512, 512, 'RGBA', 'forma'),
    ('web/icons/Icon-maskable-192.png', 'baystream.svg', 192, 192, 'RGBA', 'maskable'),
    ('web/icons/Icon-maskable-512.png', 'baystream.svg', 512, 512, 'RGBA', 'maskable'),
    ('play/icono-512.png', 'baystream.svg', 512, 512, 'RGBA', 'play'),
    ('play/grafico-1024x500.png', 'grafico_play.svg', 1024, 500, 'RGB', 'grafico'),
]
ICO = 'windows/runner/resources/app_icon.ico'
ICO_TAMANOS = [(16, 'baystream_16.svg'), (20, 'baystream_20.svg'), (24, 'baystream_24.svg'), (32, 'baystream_32.svg'),
               (40, 'baystream_forma.svg'), (48, 'baystream_forma.svg'), (64, 'baystream_forma.svg'),
               (128, 'baystream_forma.svg'), (256, 'baystream_forma.svg')]

XMLS = {
    f'{RES}/mipmap-anydpi-v26/ic_launcher.xml':
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
        '</adaptive-icon>\n',
    f'{RES}/values/ic_launcher_background.xml':
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<resources>\n'
        f'    <color name="ic_launcher_background">{FONDO}</color>\n'
        '</resources>\n',
}


def rasterizar(svg, ancho, alto):
    png = resvg_py.svg_to_bytes(svg_path=str(AQUI / svg), width=ancho, height=alto)
    return Image.open(io.BytesIO(bytes(png))).convert('RGBA')


def guardar_png(img, ruta, modo):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    (img.convert('RGB') if modo == 'RGB' else img).save(ruta, 'PNG', optimize=True)


def _dib(img):
    """Entrada BMP de 32 bits para .ico: BITMAPINFOHEADER, píxeles BGRA de abajo arriba y máscara AND vacía."""
    w, h = img.size
    cab = struct.pack('<IiiHHIIiiII', 40, w, h*2, 1, 32, 0, 0, 0, 0, 0, 0)
    filas = img.transpose(Image.FLIP_TOP_BOTTOM).tobytes('raw', 'BGRA')
    mascara = bytes(((w + 31)//32)*4*h)
    return cab + filas + mascara


def guardar_ico(ruta):
    """Cada tamaño lleva su propio dibujo; BMP hasta 128 px y PNG en 256, como es costumbre en Windows."""
    datos = []
    for px, svg in ICO_TAMANOS:
        img = rasterizar(svg, px, px)
        if px >= 256:
            b = io.BytesIO(); img.save(b, 'PNG', optimize=True); datos.append((px, b.getvalue()))
        else:
            datos.append((px, _dib(img)))
    cab = struct.pack('<HHH', 0, 1, len(datos))
    off = 6 + 16*len(datos); dirs = b''
    for px, d in datos:
        dirs += struct.pack('<BBBBHHII', px % 256, px % 256, 0, 0, 1, 32, len(d), off)
        off += len(d)
    ruta.parent.mkdir(parents=True, exist_ok=True)
    ruta.write_bytes(cab + dirs + b''.join(d for _, d in datos))


def generar(raiz):
    for ruta, svg, w, h, modo, _ in PNGS:
        guardar_png(rasterizar(svg, w, h), raiz / ruta, modo)
    guardar_ico(raiz / ICO)
    for ruta, txt in XMLS.items():
        p = raiz / ruta
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(txt, encoding='utf-8', newline='\n')


# ---------------------------------------------------------------- verificación
def _hex(c): return tuple(int(c[i:i+2], 16) for i in (1, 3, 5))


def _radio_max(img):
    """Distancia máxima al centro, en píxeles, de un píxel con alfa > 0."""
    w, h = img.size; a = img.getchannel('A').load(); cx, cy = w/2, h/2; m = 0.0
    for y in range(h):
        for x in range(w):
            if a[x, y]:
                m = max(m, math.hypot(x + 0.5 - cx, y + 0.5 - cy))
    return m


def _fuera_es_fondo(img, dentro):
    """True si todo píxel para el que dentro(x, y) es falso tiene exactamente el color de fondo."""
    w, h = img.size; px = img.convert('RGBA').load(); fondo = _hex(FONDO) + (255,)
    return all(px[x, y] == fondo for y in range(h) for x in range(w) if not dentro(x + 0.5, y + 0.5))


def _dentro_redondeado(w, r):
    def f(x, y):
        dx = max(r - x, 0, x - (w - r)); dy = max(r - y, 0, y - (w - r))
        return dx*dx + dy*dy <= r*r
    return f


def _entradas_ico(ruta):
    datos = ruta.read_bytes()
    _, tipo, n = struct.unpack_from('<HHH', datos, 0)
    out = []
    for i in range(n):
        w, h, _, _, _, bpp, tam, off = struct.unpack_from('<BBBBHHII', datos, 6 + 16*i)
        formato = 'PNG' if datos[off:off+8] == b'\x89PNG\r\n\x1a\n' else 'BMP'
        out.append((w or 256, h or 256, bpp, formato))
    return tipo, out


def verificar(raiz):
    fallas, filas = [], []

    def ok(cond, que):
        filas.append(('✓' if cond else '✗', que))
        if not cond:
            fallas.append(que)

    for ruta, svg, w, h, modo, tipo in PNGS:
        p = raiz / ruta
        if not p.exists():
            ok(False, f'{ruta}: no existe'); continue
        img = Image.open(p)
        ok(img.size == (w, h) and img.mode == modo, f'{ruta}: {img.size[0]}×{img.size[1]} {img.mode} (esperado {w}×{h} {modo})')
        img = img.convert('RGBA')
        if tipo == 'adaptativo':
            limite = ZONA_SEGURA_DP/2 * w/LIENZO_DP
            r = _radio_max(img)
            ok(r <= limite + 0.75, f'{ruta}: el frente llega a {r*LIENZO_DP/w:.1f} dp del centro (límite {ZONA_SEGURA_DP/2:.0f} dp)')
        elif tipo == 'maskable':
            ok(img.getextrema()[3] == (255, 255), f'{ruta}: a sangre, sin transparencia')
            rr = MASKABLE*w/2
            ok(_fuera_es_fondo(img, lambda x, y: math.hypot(x - w/2, y - h/2) <= rr), f'{ruta}: fuera del círculo del 80 % solo hay fondo')
        elif tipo == 'play':
            kb = p.stat().st_size/1024
            ok(kb < LIMITE_PLAY_KB, f'{ruta}: pesa {kb:.1f} KB (límite {LIMITE_PLAY_KB} KB)')
            ok(img.getextrema()[3] == (255, 255), f'{ruta}: a sangre, sin esquinas ni transparencia')
            ok(_fuera_es_fondo(img, _dentro_redondeado(w, RADIO_PLAY*w)), f'{ruta}: las esquinas que recorta Play solo tienen fondo')
        elif tipo == 'forma':
            ok(img.getpixel((0, 0))[3] == 0, f'{ruta}: esquinas transparentes (forma propia)')

    p = raiz / ICO
    if p.exists():
        tipo, entradas = _entradas_ico(p)
        tam = sorted(w for w, h, _, _ in entradas)
        esperado = sorted(px for px, _ in ICO_TAMANOS)
        ok(tipo == 1 and tam == esperado, f'{ICO}: trae {", ".join(map(str, tam))} px')
        ok(all(bpp == 32 for _, _, bpp, _ in entradas), f'{ICO}: 32 bits con alfa; ' + ', '.join(f'{w} {fmt}' for w, _, _, fmt in entradas))
        ico = Image.open(p)
        iguales = all(ico.ico.getimage((px, px)).convert('RGBA').tobytes() == rasterizar(svg, px, px).tobytes()
                      for px, svg in ICO_TAMANOS)
        ok(iguales, f'{ICO}: cada tamaño es su dibujo propio, sin reescalar')
    else:
        ok(False, f'{ICO}: no existe')
    for ruta in XMLS:
        ok((raiz / ruta).exists(), f'{ruta}: existe')
    return fallas, filas


def sha256(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def archivos(raiz):
    return [r for r, *_ in PNGS] + [ICO] + list(XMLS)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('--salida', type=Path, default=RAIZ, help='raíz donde escribir (por defecto, la del repositorio)')
    ap.add_argument('--verificar', action='store_true', help='no genera; solo verifica')
    a = ap.parse_args()
    if not a.verificar:
        generar(a.salida)
    fallas, filas = verificar(a.salida)
    for marca, que in filas:
        print(f' {marca} {que}')
    print(f'\n{len(filas) - len(fallas)} de {len(filas)} comprobaciones correctas.')
    sys.exit(1 if fallas else 0)


if __name__ == '__main__':
    main()
