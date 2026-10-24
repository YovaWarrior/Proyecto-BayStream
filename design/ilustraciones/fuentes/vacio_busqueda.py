"""VACIO_BUSQUEDA (320 × 200) — «ningún contenedor coincide» (Nube).

Una fila de celdas de cubierta sobre la barra de la tapa de escotilla, como en el ícono, con un hueco
en el centro: la celda vacía, punteada en `tinta_suave`. Nada se mueve: no hay naranja. Pocas piezas
grandes (celda de 46 px) para que lea a 160 px de ancho.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from ilus import Ilustracion
from plantilla import celda, tapa, LADO_U, GAP_U

W, H = 320, 200
G = 1.75                      # grosor de trazo a 320 de ancho
N = 5                         # celdas en la fila
HUECO = 2                     # la del centro queda vacía
LADO = 46.0                   # lado de la celda en px
E = LADO / LADO_U             # px por unidad del ícono
GAP = GAP_U * E               # luz entre celdas (2.8 unidades)
H_TAPA = 5.4 * E              # canto de la barra de la tapa, como en el ícono
VUELO_TAPA = 3 * E            # cuánto sobresale la tapa a cada lado de la fila

il = Ilustracion('vacio_busqueda', W, H)

ancho_fila = N * LADO + (N - 1) * GAP
x0 = (W - ancho_fila) / 2
alto_total = LADO + GAP + H_TAPA
y_celdas = (H - alto_total) / 2
y_tapa = y_celdas + LADO + GAP

tapa(il, x0 - VUELO_TAPA, y_tapa, ancho_fila + 2 * VUELO_TAPA, H_TAPA, grosor=G)
for i in range(N):
    x = x0 + i * (LADO + GAP)
    if i == HUECO:
        celda(il, x, y_celdas, LADO, 'vacia', grosor=G + 0.5, nombre='celda_vacia')
    else:
        celda(il, x, y_celdas, LADO, 'cubierta', grosor=G, nombre=f'cubierta_0_{i}')

ILUSTRACIONES = {'vacio_busqueda': il}
