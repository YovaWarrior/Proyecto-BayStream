"""INICIO (640 × 400) — el ícono de la app en grande, sobre la plantilla común (Nube).

La composición aprobada: el corte de la bahía es el ícono ampliado literalmente (maestro de 100
unidades, escala S = 2.8): cuatro columnas, celda 11 con esquina 1.9, dos filas de cubierta, la barra
de la tapa de escotilla y la bodega de tres filas que se cierra hacia la quilla con la curva del casco.
A su izquierda, el muelle (banda `marca` con su muro y una defensa apoyada en el casco) y la grúa
pórtico STS en línea, que iza el contenedor naranja media celda por encima de su celda, ahora vacía y
punteada.

Afinado tras la aprobación (se ve en `plantilla.grua`):
  - la cabina cuelga de la cara inferior del carro, compartiendo arista con él (antes tocaba una esquina);
  - la pluma baja de 54 a 66 y el ápice del pilón queda en y = 30 (antes 14): respira sobre el borde;
    la casa de máquinas pasa de 28 a 18 de alto para que el tirante de tierra le pase por encima con luz;
  - a escala 0.5: ruedas de r = 5 (antes 4) y dos por pierna, carro de 42 de ancho con cabina de 10,
    cables a ±12 del eje para que la cabina no se funda con el cable.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from ilus import Ilustracion
from plantilla import agua, muelle, buque_corte, grua

W, H = 640, 400
S = 2.8                       # px por unidad del ícono (maestro de 100)
X0, Y0 = 300.0, 104.74        # origen del ícono en la hoja (la quilla 95.45 cae en y = 372)
Y_MUELLE = 256                # cota del muelle ≈ base de la barra de la tapa (deck del buque)
Y_AGUA = 306                  # línea de flotación = base de la banda del muelle
X_MUELLE = 345                # cara del muelle (el casco exterior arranca en x ≈ 359)
X_GRUA = 150                  # eje de la pierna de tierra; la de agua queda en 300

il = Ilustracion('inicio', W, H)

# agua a la derecha de la cara del muelle; muelle con su muro, cota, base, cara y defensa
agua(il, X_MUELLE, Y_AGUA, W - X_MUELLE, H - Y_AGUA)
muelle(il, 0, Y_MUELLE, X_MUELLE, alto=Y_AGUA - Y_MUELLE, hasta=H, defensa=True)

# el buque en corte: celda (0, 0) de cubierta en la posición del ícono (23.8, 21.05); la columna 2
# de la fila alta queda vacía y punteada
g = buque_corte(il, X0 + 23.8 * S, Y0 + 21.05 * S, S, columnas=4, filas_cubierta=2, filas_bodega=3,
                vacias={(0, 2)}, grosor=2, grosor_casco=2.5)

# la grúa iza el contenedor naranja de esa columna, media celda de aire sobre la fila alta
ox, oy = g['celda'](0, 2)
oy -= 1.5 * g['lado']
grua(il, X_GRUA, Y_MUELLE, 1.0, luz=150, pluma=(-95, 445), carga=(ox, oy, g['lado']),
     grosor=2, grosor_pluma=2.5)

ILUSTRACIONES = {'inicio': il}
