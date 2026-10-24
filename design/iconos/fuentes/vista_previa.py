"""Vistas previas del paquete: los íconos (todos, a 16/20/24/32 en claro y oscuro, con zoom de 16 px) y
las insignias (12/16/24), y las ilustraciones (claro y oscuro, lado a lado)."""
from __future__ import annotations
import io, os, sys
from PIL import Image, ImageDraw, ImageFont
import resvg_py

TEMAS = {'claro': ('#F5F8FC', '#10243F'), 'oscuro': ('#07111F', '#EAF0F9')}


def raster(svg: str, w: int, h: int | None = None):
    png = resvg_py.svg_to_bytes(svg_string=svg, width=w, height=h or w)
    return Image.open(io.BytesIO(bytes(png))).convert('RGBA')


def fuente(tam):
    try:
        return ImageFont.load_default(size=tam)
    except TypeError:
        return ImageFont.load_default()


def iconos(iconos: dict, insignias: dict, salida: str, titulo: str = 'BayStream · iconos del dominio (estilo B solido) · Nube'):
    tams, zoom = [16, 20, 24, 32], 4
    etiqueta_w, celda = 176, 46
    tema_w = 12 + len(tams) * celda + 12 + 16 * zoom + 12
    fila_h = 16 * zoom + 10
    filas = [('icono', n, ic) for n, ic in iconos.items()] + [('insignia', n, ic) for n, ic in insignias.items()]
    W = etiqueta_w + 2 * tema_w + 8
    H = 48 + fila_h * len(filas) + 8
    img = Image.new('RGB', (W, H), '#DDE3EA')
    dib = ImageDraw.Draw(img)
    f, f2 = fuente(14), fuente(11)
    dib.text((8, 8), titulo, fill='#10243F', font=f)
    dib.text((etiqueta_w + 12, 28), 'claro: 16 20 24 32 y zoom x4 (insignias: 12 16 24 32)', fill='#4A5B73', font=f2)
    dib.text((etiqueta_w + tema_w + 12, 28), 'oscuro', fill='#4A5B73', font=f2)
    for i, (tipo, nombre, ic) in enumerate(filas):
        y0 = 48 + i * fila_h
        dib.rectangle([0, y0, etiqueta_w, y0 + fila_h], fill='#DDE3EA' if tipo == 'icono' else '#CFD8E3')
        dib.text((8, y0 + 8), nombre if tipo == 'icono' else f'insignia · {nombre}', fill='#10243F', font=f2)
        ts = tams if tipo == 'icono' else [12, 16, 24, 32]
        for j, (tema, (fondo, tinta)) in enumerate(TEMAS.items()):
            x0 = etiqueta_w + 4 + j * tema_w
            dib.rectangle([x0, y0, x0 + tema_w - 4, y0 + fila_h], fill=fondo)
            svg = ic.svg(color=tinta)
            x = x0 + 12
            for t in ts:
                r = raster(svg, t)
                img.paste(r, (x + (celda - t) // 2, y0 + (fila_h - t) // 2), r)
                x += celda
            x += 12
            tz = 16 if tipo == 'icono' else 12
            r = raster(svg, tz).resize((tz * zoom, tz * zoom), Image.NEAREST)
            img.paste(r, (x, y0 + (fila_h - tz * zoom) // 2), r)
    img.save(salida, optimize=True)
    return salida


def ilustraciones(ils: dict, salida: str, titulo: str = 'BayStream · ilustraciones · Nube'):
    filas = []
    for nombre, il in ils.items():
        esc = 0.5 if il.ancho > 400 else 1.0
        w, h = int(il.ancho * esc), int(il.alto * esc)
        filas.append((nombre, raster(il.svg('claro'), w, h), raster(il.svg('oscuro'), w, h)))
    W = max(2 * r[1].width + 48 for r in filas)
    H = 40 + sum(r[1].height + 36 for r in filas)
    img = Image.new('RGB', (W, H), '#DDE3EA')
    dib = ImageDraw.Draw(img)
    f, f2 = fuente(14), fuente(11)
    dib.text((16, 10), titulo, fill='#10243F', font=f)
    y = 40
    for nombre, c, o in filas:
        dib.text((16, y), f'{nombre} · claro', fill='#4A5B73', font=f2)
        dib.text((16 + c.width + 16, y), f'{nombre} · oscuro', fill='#4A5B73', font=f2)
        y += 18
        img.paste(c, (16, y), c); img.paste(o, (16 + c.width + 16, y), o)
        y += c.height + 18
    img.save(salida, optimize=True)
    return salida
