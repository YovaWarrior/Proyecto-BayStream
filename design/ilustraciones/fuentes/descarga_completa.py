"""DESCARGA_COMPLETA (320 × 200) — la bahía vacía, con la tapa cerrada y un check (Nube).

El corte de la bahía del ícono (4 columnas, 2 filas de cubierta, 3 de bodega) sin ningún contenedor:
las ocho celdas de cubierta quedan como huecos punteados (lo que dejó cada contenedor), la bodega
vacía es el casco `marca` sin celdas —la misma «bahía vacía» que `prueba.p_buque_corte_vacio`—, la
barra de la tapa de escotilla cerrada y el check en `hecho` como insignia sobre el costado del casco.
Nada se mueve: sin naranja.

Rondas: (1) composición; (2) la flotación quedaba tangente al borde alto del check: el check baja
hasta que la línea le entra por el centro y queda tapada por su cuerpo; (3) vista a 0.5 ampliada ×3,
lo que más sufre son las celdas punteadas: el corte sube de 2.15 a 2.25 px por unidad y ocupa la
altura con 13 px de aire arriba y abajo.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from ilus import Ilustracion
from plantilla import agua, buque_corte, geometria_corte, check

W, H = 320, 200
G = 1.75                      # grosor de trazo a 320 de ancho
E = 2.25                      # px por unidad del ícono
COLS, FC, FB = 4, 2, 3
CHECK = 64                    # diámetro de la insignia (32 px a la mitad)

il = Ilustracion('descarga_completa', W, H)

# el corte a la izquierda del centro, para que el grupo corte + insignia quede centrado en 160 (la
# insignia asoma CHECK/2 + 4 por fuera del casco); 13 px de aire sobre las celdas y bajo la quilla
g0 = geometria_corte(0, 0, E, COLS, FC, FB)
ancho_grupo = (g0['caja'][2] + 4 + CHECK / 2) - g0['tapa'][0]
X0 = (W - ancho_grupo) / 2 - g0['tapa'][0]
Y0 = (H - g0['caja'][3]) / 2
g = geometria_corte(X0, Y0, E, COLS, FC, FB)
x0c, y0c, x1c, y1c = g['caja']

# agua: la flotación al 40 % de la altura del casco, como en inicio (buque descargado, flota alto)
y_agua = y0c + 0.4 * (y1c - y0c)
agua(il, 0, y_agua, W, H - y_agua, grosor=G)

# la bahía vacía: cubierta toda punteada, bodega sin celdas, tapa cerrada
todas = {(f, c) for f in range(FC) for c in range(COLS)}
buque_corte(il, X0, Y0, E, columnas=COLS, filas_cubierta=FC, filas_bodega=FB,
            cubierta=set(), bodega=set(), vacias=todas, con_tapa=True, grosor=G, grosor_casco=2)

# el check, insignia sobre el costado de estribor: centrado en la flotación, que le pasa por detrás
check(il, x1c + 4, y_agua + 6, CHECK)

ILUSTRACIONES = {'descarga_completa': il}
