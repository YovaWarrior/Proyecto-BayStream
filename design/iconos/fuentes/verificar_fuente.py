"""Comprueba que cada glifo de la TTF, rasterizado a 16 y 24 px, coincide con su SVG.

Dos comparaciones por glifo y tamaño:
  1. «contorno»: el contorno TrueType (ya cuadrático y redondeado al entero) vuelto a SVG y rasterizado
     con resvg, frente al SVG original rasterizado con resvg. Mide solo el error de la conversión.
  2. «FreeType»: el glifo dibujado desde la TTF con FreeType sin hinting (freetype-py), que es lo más
     parecido a lo que hace Skia en Flutter, frente al SVG con resvg: dos rasterizadores sobre la misma forma.
  3. «FreeType con hinting»: lo mismo con el autohinter de FreeType, como un escritorio que ajusta los
     trazos al píxel; se informa, pero no decide.
Métricas: diferencia media de alfa (0–255), píxeles que cambian de estado (alfa ≥ 128 en uno y no en el
otro) y píxeles con |Δalfa| ≥ 96 (resvg cuantiza la cobertura en pasos de 64: un borde que cae justo en un
subpíxel salta un paso sin que cambie la forma). Umbral de «coincide»: contorno ≤ 4 píxeles con |Δalfa| ≥ 96 y Δ medio ≤ 2; FreeType ≤ 4 % de píxeles
cambiados de estado o Δ medio ≤ 12.
"""
from __future__ import annotations
import io, os, sys
from PIL import Image, ImageDraw, ImageFont
import resvg_py
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from fuente import glifo_a_svg_path, REJILLA

TAMS = (16, 24)


def raster_svg(svg: str, px: int):
    png = resvg_py.svg_to_bytes(svg_string=svg, width=px, height=px)
    return Image.open(io.BytesIO(bytes(png))).convert('RGBA').getchannel('A')


def svg_de_ruta(d: str) -> str:
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {REJILLA} {REJILLA}">'
            f'<path fill="#000" d="{d}"/></svg>')


def raster_freetype(ttf: str, codigo: int, px: int, hinting: bool = False):
    import freetype
    face = freetype.Face(ttf)
    face.set_pixel_sizes(0, px)
    flags = freetype.FT_LOAD_RENDER | freetype.FT_LOAD_TARGET_NORMAL
    flags |= (freetype.FT_LOAD_FORCE_AUTOHINT if hinting else freetype.FT_LOAD_NO_HINTING)
    face.load_char(codigo, flags)
    g = face.glyph; bm = g.bitmap
    img = Image.new('L', (px, px), 0)
    if bm.width and bm.rows:
        tile = Image.frombytes('L', (bm.width, bm.rows), bytes(bm.buffer)) if bm.pitch == bm.width else \
            Image.frombytes('L', (bm.width, bm.rows), b''.join(bytes(bm.buffer[r * bm.pitch:r * bm.pitch + bm.width]) for r in range(bm.rows)))
        ascender_px = round(face.size.ascender / 64)
        img.paste(tile, (g.bitmap_left, ascender_px - g.bitmap_top))
    return img


def comparar(a: Image.Image, b: Image.Image):
    A, B = a.tobytes(), b.tobytes()
    n = len(A)
    media = sum(abs(x - y) for x, y in zip(A, B)) / n
    estado = sum(1 for x, y in zip(A, B) if (x >= 128) != (y >= 128))
    fuertes = sum(1 for x, y in zip(A, B) if abs(x - y) >= 96)
    return media, estado, fuertes


def verificar(iconos_todos: dict, codigos: dict, ttf: str, hoja: str | None = None):
    """iconos_todos: nombre de glifo → Icono (incluye insignia_*). Devuelve filas y si todo coincide."""
    filas = []
    celdas = []
    for nombre, ic in iconos_todos.items():
        d = glifo_a_svg_path(ttf, nombre)
        fila = {'nombre': nombre, 'codigo': f'U+{codigos[nombre]:04X}'}
        ok = True
        for px in TAMS:
            svg_orig = raster_svg(ic.svg(color='#000000'), px)
            svg_ttf = raster_svg(svg_de_ruta(d), px)
            ft = raster_freetype(ttf, codigos[nombre], px)
            fth = raster_freetype(ttf, codigos[nombre], px, hinting=True)
            m1, e1, f1 = comparar(svg_orig, svg_ttf)
            m2, e2, f2 = comparar(svg_orig, ft)
            m3, e3, f3 = comparar(svg_orig, fth)
            fila[f'contorno_{px}'] = (round(m1, 2), e1, f1)
            fila[f'freetype_{px}'] = (round(m2, 2), e2, f2, round(100 * e2 / (px * px), 1))
            fila[f'hinting_{px}'] = (round(m3, 2), e3, f3, round(100 * e3 / (px * px), 1))
            if f1 > 4 or m1 > 2:          # contorno: píxeles con |Δ| ≥ 64 (los bordes a medio píxel parpadean en el umbral de 128)
                ok = False
            if 100 * e2 / (px * px) > 4 and m2 > 12:
                ok = False
            celdas.append((nombre, px, svg_orig, svg_ttf, ft))
        fila['ok'] = ok
        filas.append(fila)
    if hoja:
        _hoja(celdas, hoja)
    return filas


def _hoja(celdas, salida):
    """Hoja visual: por glifo y tamaño, SVG | contorno TTF | FreeType, ampliados ×6 (16) y ×4 (24)."""
    z = {16: 6, 24: 4}
    nombres = []
    for n, px, *_ in celdas:
        if n not in nombres:
            nombres.append(n)
    fila_h = 24 * 4 + 12
    col_w = 3 * (24 * 4 + 6) + 24
    W = 170 + 2 * col_w
    H = 30 + fila_h * len(nombres)
    img = Image.new('RGB', (W, H), '#DDE3EA')
    dib = ImageDraw.Draw(img)
    try:
        f = ImageFont.load_default(size=12)
    except TypeError:
        f = ImageFont.load_default()
    dib.text((8, 8), 'glifo', fill='#000', font=f)
    dib.text((170, 8), '16 px: SVG | contorno TTF | FreeType  (x6)', fill='#000', font=f)
    dib.text((170 + col_w, 8), '24 px: SVG | contorno TTF | FreeType  (x4)', fill='#000', font=f)
    for i, n in enumerate(nombres):
        y = 30 + i * fila_h
        dib.text((8, y + 8), n, fill='#10243F', font=f)
        for (nn, px, a, b, c) in celdas:
            if nn != n:
                continue
            x = 170 + (0 if px == 16 else col_w)
            for im in (a, b, c):
                big = im.resize((px * z[px], px * z[px]), Image.NEAREST)
                fondo = Image.new('RGB', big.size, '#F5F8FC')
                fondo.paste(Image.new('RGB', big.size, '#10243F'), (0, 0), big)
                img.paste(fondo, (x, y + 4))
                x += px * z[px] + 6
    img.save(salida)
