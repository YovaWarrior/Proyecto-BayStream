"""VACIO_RECIENTES (320 × 200) — «todavía no hay viajes» (Nube).

El muelle sin buque: la banda `marca` del muelle con su muro y una defensa esperando en la cara, y la
grúa pórtico STS en reposo (sin carga, carro recogido sobre el portal, spreader izado) con la pluma
tendida sobre el agua vacía. Nada se mueve: no hay naranja. Mismas piezas que `inicio`, a la mitad
(escala 0.5 de la grúa), trazos 1.75 (2 en casco/pluma) para que lea a 160 px de ancho.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from ilus import Ilustracion
from plantilla import agua, muelle, grua

W, H = 320, 200
G = 1.75                      # grosor de trazo a 320 de ancho
Y_MUELLE = 134                # cota del muelle
Y_AGUA = 158                  # línea de flotación = base de la banda del muelle
X_MUELLE = 176                # cara del muelle: a la derecha, el agua vacía
X_GRUA = 70                   # eje de la pierna de tierra; la de agua queda en 145

il = Ilustracion('vacio_recientes', W, H)

# el agua vacía a la derecha de la cara del muelle; el muelle con muro, cota, base, cara y defensa
agua(il, X_MUELLE, Y_AGUA, W - X_MUELLE, H - Y_AGUA, grosor=G)
muelle(il, 0, Y_MUELLE, X_MUELLE, alto=Y_AGUA - Y_MUELLE, hasta=H, defensa=True, grosor=2, grosor_linea=G)

# la grúa en reposo: la pluma sale sobre el agua y no cuelga nada. El carro, recogido sobre el
# portal, va al 30 % de la luz (no al centro) para que el spreader izado no se cruce con la riostra:
# a 160 px de ancho se fundían en una mancha.
grua(il, X_GRUA, Y_MUELLE, 0.5, luz=150, pluma=(-95, 445), reposo=True, carro_x=X_GRUA + 0.3 * 150 * 0.5,
     grosor=G, grosor_pluma=2)

ILUSTRACIONES = {'vacio_recientes': il}
