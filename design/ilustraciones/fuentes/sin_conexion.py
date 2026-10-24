"""SIN_CONEXION (320 × 200) — el buque de perfil, proa a la izquierda, con la nube en pausa (Nube).

Para la pantalla «trabajando solo en este equipo»: el buque sigue ahí, cargado y a flote, y la nube
(la sincronización) está en pausa: dos barras `tinta` dentro. Nada se mueve, así que no hay naranja.
Piezas de la plantilla común: `agua`, `buque_perfil` (la roda a la izquierda, la caseta a popa) y
`nube` en estado 'pausa'. Compuesta con tres piezas grandes para que siga leyéndose a 160 px.

Rondas: (1) nube de 116 a la izquierda y calado 44: la nube quedaba chica y descentrada de la carga;
(2) nube de 130 centrada sobre la fila de contenedores, calado 48 (celdas de 23); se probó una
variante con dos filas de carga y se descartó: achica la nube y le quita el aire sobre el borde;
(3) la nube se corre a x = 150 para equilibrar con la caseta de popa. Un solo trazo de 1.75.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from ilus import Ilustracion
from plantilla import agua, buque_perfil, nube

W, H = 320, 200
G = 1.75                      # grosor de trazo a 320 de ancho
Y_AGUA = 152                  # línea de flotación
X_RODA, Y_CUBIERTA = 36, 132  # la roda en la línea de cubierta
ESLORA, CALADO = 248, 48      # eslora dibujada y de cubierta a quilla

il = Ilustracion('sin_conexion', W, H)

agua(il, 0, Y_AGUA, W, H - Y_AGUA, grosor=G)
buque_perfil(il, X_RODA, Y_CUBIERTA, ESLORA, CALADO, filas=1, grosor=G)
nube(il, 150, 58, 130, 'pausa', grosor=G)   # sobre la fila de carga, equilibrando la caseta de popa

ILUSTRACIONES = {'sin_conexion': il}
