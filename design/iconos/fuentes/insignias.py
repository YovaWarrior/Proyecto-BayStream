"""Las cuatro insignias de 12 px para la esquina de la celda · estilo B · Nube.

Se dibujan en la rejilla de 24 con margen de 2 y se usan a 12 px (1 unidad = 0.5 px): una sola masa por
insignia, con a lo sumo un calado de 4 unidades (2 px). Cada una hereda la marca de su ícono: el copo del
refrigerado (sin ramas: a 12 px no caben), el rombo IMDG con el «!» calado, la carga que se sale del marco
en fuera_de_medida y el marco hueco del vacío. En la fuente van como insignia_<nombre>; en Flutter,
Icon(BsIconos.insigniaRefrigerado, size: 12).
"""
import math
from dsl import Icono, R_CELDA
from ayudantes import banda, rombo_d, marco


def refrigerado():
    """Copo sin ramas: tres barras cruzadas de 3.5 (1.75 px a 12), seis brazos de 8.25 con puntas redondas (tinta en 2/22)."""
    ic = Icono('refrigerado')
    for k in range(3):
        a = math.radians(90 + 60 * k)
        banda(ic, 12 - 8.25 * math.cos(a), 12 - 8.25 * math.sin(a), 12 + 8.25 * math.cos(a), 12 + 8.25 * math.sin(a), 3.5, relleno=True)
    return ic


def peligrosa():
    """Rombo IMDG macizo con la barra del «!» calada (4×7 = 2×3.5 px a 12) y el punto (4×3)."""
    ic = Icono('peligrosa')
    ic.ruta(rombo_d(12, 12, 11.13, 2.72), relleno=True)
    ic.rect(10, 5.5, 4, 7, calado=True)
    ic.rect(10, 15.5, 4, 3, calado=True)
    return ic


def fuera_de_medida():
    """La carga que se sale: marco de 4 (2 px a 12) y la pieza maciza de 8 que atraviesa el techo."""
    ic = Icono('fuera_de_medida')
    marco(ic, 2, 9, 20, 13, 4)
    ic.rect(8, 2, 8, 13, relleno=True)
    return ic


def vacio():
    """Vacío: el marco hueco (4 = 2 px a 12) con nada dentro."""
    ic = Icono('vacio')
    marco(ic, 2, 5, 20, 14, 4)
    return ic


ICONOS = {'refrigerado': refrigerado(), 'peligrosa': peligrosa(), 'fuera_de_medida': fuera_de_medida(), 'vacio': vacio()}
