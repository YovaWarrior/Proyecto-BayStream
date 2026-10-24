#!/usr/bin/env python3
"""Mide cuánto se distinguen dos íconos a 16 y 20 px (parientes: contenedor_20/40/45, descarga/carga…).

    python3 parejas.py archivo.py a:b c:d ...          # los nombres pueden venir de un solo archivo
    python3 parejas.py archivo.py --todos               # todas las parejas del archivo

Por pareja imprime, a 16 y a 20 px: el porcentaje de píxeles que cambian (|Δalfa| ≥ 64 de 255) y cuántos
píxeles enteros (alfa ≥ 128) tiene uno y no el otro. Regla práctica: a 16 px, por debajo de un 6 % de
píxeles cambiados o de 8 píxeles enteros distintos, dos íconos se confunden de un vistazo.
"""
import io, os, sys, itertools
from PIL import Image
import resvg_py
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dsl import cargar


def alfa(ic, px):
    png = resvg_py.svg_to_bytes(svg_string=ic.svg(color='#000000'), width=px, height=px)
    return list(Image.open(io.BytesIO(bytes(png))).convert('RGBA').getchannel('A').tobytes())


def medir(a, b, px):
    A, B = alfa(a, px), alfa(b, px)
    cambian = sum(1 for x, y in zip(A, B) if abs(x - y) >= 64)
    enteros = sum(1 for x, y in zip(A, B) if (x >= 128) != (y >= 128))
    return 100 * cambian / (px * px), enteros


def main():
    iconos = cargar(sys.argv[1])
    if '--todos' in sys.argv:
        parejas = list(itertools.combinations(iconos.keys(), 2))
    else:
        parejas = [tuple(p.split(':')) for p in sys.argv[2:] if ':' in p]
    print(f"{'pareja':34} {'16 px: % cambian / enteros':30} {'20 px: % cambian / enteros'}")
    for a, b in parejas:
        c16, e16 = medir(iconos[a], iconos[b], 16)
        c20, e20 = medir(iconos[a], iconos[b], 20)
        aviso = '  ← se confunden' if (c16 < 6 or e16 < 8) else ''
        print(f'{a + " : " + b:34} {c16:5.1f} % / {e16:3d} px{"":14} {c20:5.1f} % / {e20:3d} px{aviso}')


if __name__ == '__main__':
    main()
