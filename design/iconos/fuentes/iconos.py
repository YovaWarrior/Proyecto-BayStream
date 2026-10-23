"""Los 31 íconos del dominio de BayStream · estilo B · Sólido · Nube.

Cada ícono es una función que devuelve un Icono del DSL (rejilla de 24, margen de 2, un solo color).
Todo macizo o calado, luz ≥ 2, esquinas de celda; los ayudantes viven en ayudantes.py. El orden de
ICONOS es el de los códigos de la fuente (U+E000 en adelante): carga, buque y plano, operación, archivos.

Decisiones que vienen del jurado y de Carlos (10.18, 22-oct; correcciones del 23-oct):
  - contenedor_20 es una caja corta (12) con una ranura: la única que no llega a 16 de eje. Un 20′ ocupa
    media celda de 40 y esa es su señal; las dos medias cajas leían «dos piezas / pausa» a 16 px.
  - refrigerado es el copo, sin caja: dice «frío» tan rápido como el ac_unit que la app usa hoy.
  - peligrosa es el rombo macizo con el «!» calado (pesa como los demás; el doble borde de la etiqueta lo
    volvía gris a 16 px).
  - grua lleva la composición del estilo C en macizo: mástil-pata de tierra, pluma con el tirante fundidos
    en cuña sobre el agua, pata de mar, muelle y el contenedor colgando.
  - descarga y carga dicen lo mismo que la app («Baja», «Sube»): en descarga la flecha baja del buque (la
    tapa de escotilla, arriba) al muelle (la barra, abajo); en carga sube. El contenedor cambia de sitio con
    ella (bajo la tapa / sobre el muelle), así los dos se distinguen a 16 px (16 % de píxeles distintos).
  - reestiba es una flecha recta de la celda vacía a la celda ocupada: sin arco, sin candado.
  - la báscula (viga sobre fulcro) es la forma de peso de peso_pila y vgm; el tope ⊓ es el límite.
"""
import math
from dsl import Icono, R_CELDA
from ayudantes import (banda, punta, barra, rombo_d, arco_banda, poli_redondeado_d, CAJA, S2, RANURA, R_HOJA,
                       ranuras, rect_d, marco, copo, balanza, pila, hoja, hoja_d, columna_casco)


# ================================================================ carga
def contenedor_20():
    """Caja de 20′: una caja corta de 12 en la banda (x 6–18, y 6–18) con una ranura centrada. A 16 px es un
    cuadrado de 8×8 px con una raya clara; se distingue del 40 (18 de ancho) por el largo."""
    ic = Icono('contenedor_20')
    ic.rect(6, 6, 12, 12, relleno=True)
    ranuras(ic, (12 - RANURA / 2,))
    return ic


def contenedor_40():
    """Caja apaisada maciza 18×12 en la banda; tres ranuras caladas = corrugado; extremos anchos = esquineros."""
    ic = Icono('contenedor_40')
    ic.rect(*CAJA, relleno=True)
    ranuras(ic, (6.125, 10.875, 15.625))
    return ic


def contenedor_45():
    """Caja de 45′ high-cube: 20 de ancho (x 2–22) y más alta (y 5–19): el largo extra son 1.3 px a 16 px y
    casi no se ve; la altura extra sí. Tres ranuras más altas, repartidas al ancho."""
    ic = Icono('contenedor_45')
    ic.rect(2, 5, 20, 14, relleno=True)
    ranuras(ic, (5.625, 10.875, 16.125), y=8, h=8)
    return ic


def vacio():
    """Vacío: la caja del 40 vista por dentro: marco de 3 con el hueco de 12×6 y nada en él."""
    ic = Icono('vacio')
    ic.rect(*CAJA, relleno=True)
    ic.rect(6, 9, 12, 6, calado=True)
    return ic


def refrigerado():
    """Reefer: el copo propio (tres barras cruzadas de 2 con ramas a ±60°), a todo el alto. Dice «frío» como
    el ac_unit de la app pero construido con bandas macizas y luz ≥ 2 entre ramas."""
    ic = Icono('refrigerado')
    copo(ic, 12, 12, 9, 2.0, 6, 2.0)
    return ic


def peligrosa():
    """Rombo IMDG macizo (celda girada 45°, puntas con proporción de celda, tinta en 2/22) con el «!» calado:
    barra de 3×6 (2×4 px a 16), luz de 3 y punto de 3×3."""
    ic = Icono('peligrosa')
    D, r = 11.13, 2.72
    ic.ruta(rombo_d(12, 12, D, r), relleno=True)
    ic.rect(10.5, 6, 3, 6, calado=True)
    ic.rect(10.5, 15, 3, 3, calado=True)
    return ic


def fuera_de_medida():
    """OOG: la caja vista por dentro (marco de 3 en la banda) y la carga, pieza maciza de 6 de ancho que está
    dentro y se sale por arriba atravesando el techo (y 2–12): lo que no cabe."""
    ic = Icono('fuera_de_medida')
    marco(ic, 3, 6, 18, 12, 3)
    ic.rect(9, 2, 6, 10, relleno=True)
    return ic


def tanque():
    """Tanque ISO: el cilindro macizo (píldora 11×8, en la banda) entre los dos marcos de extremo (postes de
    2.5, y 4.5–19.5: filas enteras a 16 px), con luz 2. A 16 px: una cápsula entre dos barras."""
    ic = Icono('tanque')
    ic.rect(2, 4.5, 2.5, 15, relleno=True)
    ic.rect(19.5, 4.5, 2.5, 15, relleno=True)
    ic.rect(6.5, 8, 11, 8, r=4, relleno=True)
    return ic


def plataforma():
    """Flat rack: el piso macizo (y 12–18) y los dos testeros delgados en los extremos (3 = 2 px a 16),
    nada encima."""
    ic = Icono('plataforma')
    ic.rect(3, 12, 18, 6, relleno=True)
    ic.rect(3, 6, 3, 12, relleno=True)
    ic.rect(18, 6, 3, 12, relleno=True)
    return ic


def techo_abierto():
    """Open top: la caja de la banda con el techo quitado: muesca calada de 3 entre los dos postes de esquina
    (de 3), y abajo sigue siendo contenedor, con sus ranuras cortas (filas 8–9 enteras a 16 px)."""
    ic = Icono('techo_abierto')
    ic.rect(*CAJA, relleno=True)
    ic.rect(6, 6, 12, 3, calado=True)
    ranuras(ic, (6.125, 10.875, 15.625), y=12, h=3)
    return ic


# ================================================================ buque y plano
def buque():
    """Perfil del buque, proa a la izquierda: casco macizo con la roda recta que rasga hacia delante, dos
    columnas de contenedores en dos filas y, a popa, la superestructura más alta con el puente calado
    (ventana de 2×3: una ranura vertical de 2 px enteros a 16)."""
    ic = Icono('buque')
    ic.ruta(poli_redondeado_d([(2, 15.5), (22, 15.5), (22, 22), (7.5, 22)], 1.0), relleno=True)
    for x0 in (2.5, 9.5):
        for y0 in (4.5, 10.5):
            ic.rect(x0, y0, 4.5, 3, relleno=True)
    ic.rect(16, 2.5, 6, 11, relleno=True)
    ic.rect(18, 4.5, 2, 3, calado=True)
    return ic


def bahia():
    """Corte de la bahía como el ícono de la app: tres celdas de cubierta, la barra de la tapa (píldora) y la
    bodega en tres columnas; las exteriores son el casco, con la curva entera como en el ícono de 24 px."""
    ic = Icono('bahia')
    for x0 in (2, 9.5, 17):
        ic.rect(x0, 2, 5, 4.5, relleno=True)
    barra(ic, 2, 9, 20)
    ic.ruta('M2 14H7V22H6.5C4 22 2 18.4 2 14Z', relleno=True)
    ic.rect(9.5, 14, 5, 8, relleno=True)
    ic.ruta('M17 14H22C22 18.4 20 22 17.5 22H17Z', relleno=True)
    return ic


def tapa_escotilla():
    """Hatch cover: la barra-píldora de la familia levantada (luz 3) sobre la bodega de bahia: las mismas tres
    columnas con la curva del casco, sin celdas de cubierta."""
    ic = Icono('tapa_escotilla')
    barra(ic, 2, 5.5, 20)
    ic.ruta('M2 11H7V22H6.5C4 22 2 18.4 2 14Z', relleno=True)
    ic.rect(9.5, 11, 5, 11, relleno=True)
    ic.ruta('M17 11H22V14C22 18.4 20 22 17.5 22H17Z', relleno=True)
    return ic


def peso_pila():
    """Peso de una pila: dos celdas apiladas (luz 2) sobre la báscula (viga sobre fulcro)."""
    ic = Icono('peso_pila')
    pila(ic, (2.5, 9.5), 5)
    balanza(ic)
    return ic


def limite_apilamiento():
    """Límite de apilamiento: la misma pila de dos celdas y, encima, el tope: barra con los extremos vueltos
    hacia abajo (⊓), lo que no se puede subir más."""
    ic = Icono('limite_apilamiento')
    ic.rect(2, 2, 20, 2.5, relleno=True)
    ic.rect(2, 2, 2.5, 5.5, relleno=True)
    ic.rect(19.5, 2, 2.5, 5.5, relleno=True)
    pila(ic, (9.5, 16.75), 5.25)
    return ic


def vgm():
    """VGM: el contenedor que se pesa (con su ranura) sobre la misma báscula que peso_pila, y a su lado, a
    la altura de la caja, el visto bueno macizo: el peso verificado."""
    ic = Icono('vgm')
    ic.rect(2, 5, 10, 9.5, relleno=True)
    ic.rect(5.875, 7.5, RANURA, 4.5, calado=True)
    banda(ic, 15.75, 8.25, 17.75, 10.25, 2.75, relleno=True)
    banda(ic, 17.75, 10.25, 20.5, 5, 2.75, relleno=True)
    balanza(ic)
    return ic


def segregacion():
    """Matriz de segregación: la fila y la columna de cabecera (clases IMDG) como celdas macizas y, en el
    cuerpo de la tabla, el rombo IMDG que dice «peligrosas»."""
    ic = Icono('segregacion')
    w = (20 - 2 * 2) / 3
    xs = (2, 2 + w + 2, 2 + 2 * (w + 2))
    for x0 in xs:
        ic.rect(x0, 2, w, w, relleno=True)
    for y0 in xs[1:]:
        ic.rect(2, y0, w, w, relleno=True)
    c = xs[1] + (w + 2 + w) / 2
    D = 6
    ic.ruta(rombo_d(c, c, D, R_CELDA * D * S2), relleno=True)
    return ic


# ================================================================ operación
def descarga():
    """Descarga = «Baja»: el contenedor sale del buque hacia el muelle. La tapa de escotilla arriba (el buque),
    el contenedor ya suelto bajo ella, la flecha hacia abajo y el muelle (barra) al pie. Con el buque y el
    muelle en el dibujo no es «descargar un archivo»."""
    ic = Icono('descarga')
    barra(ic, 2, 2, 20)
    ic.rect(6, 6.5, 12, 4, relleno=True)
    ic.rect(10.5, 12.5, 3, 2.5, relleno=True)
    punta(ic, [(7, 14.5), (17, 14.5), (12, 17.5)])
    barra(ic, 2, 19.5, 20)
    return ic


def carga():
    """Carga = «Sube»: el contenedor va del muelle al buque. La misma escena: la tapa arriba, la flecha hacia
    arriba y el contenedor todavía sobre el muelle. Lo que cambia frente a descarga es el sentido de la
    flecha y dónde está el contenedor (16 % de píxeles distintos a 16 px)."""
    ic = Icono('carga')
    barra(ic, 2, 2, 20)
    punta(ic, [(12, 6.5), (17, 9.5), (7, 9.5)])
    ic.rect(10.5, 9.5, 3, 2, relleno=True)
    ic.rect(6, 13.5, 12, 4, relleno=True)
    barra(ic, 2, 19.5, 20)
    return ic


def reestiba():
    """Reestiba = el paso de una celda a otra: la celda de origen vacía (marco con el hueco calado), la de
    destino con el contenedor (maciza) y, encima, la flecha recta de una a otra con la punta grande."""
    ic = Icono('reestiba')
    ic.rect(2, 14, 8, 8, relleno=True)
    ic.rect(4.25, 16.25, 3.5, 3.5, calado=True)
    ic.rect(14, 14, 8, 8, relleno=True)
    ic.rect(3, 5.5, 11, 3, relleno=True)
    punta(ic, [(13, 3), (21, 7), (13, 11)])
    return ic


def pedir_cambio():
    """Pedir cambio = la pregunta sobre el contenedor: el gancho macizo del signo de interrogación, el palo
    y, como punto, el contenedor."""
    ic = Icono('pedir_cambio')
    arco_banda(ic, 12, 7, 3.5, 3.5, 2.75, 200, 90)
    banda(ic, 12, 10.5, 12, 12.25, 2.75, relleno=True)
    ic.rect(3, 16, 18, 6, relleno=True)
    return ic


def orden():
    """Orden = la posición en el listado: tres filas (dos barras-píldora de listado y, en medio, el
    contenedor con su ranura) y la marca de orden: la punta que señala la fila del contenedor."""
    ic = Icono('orden')
    barra(ic, 8.5, 3, 13.5)
    ic.rect(8.5, 8.75, 13.5, 6.5, relleno=True)
    ic.rect(14.125, 10.75, RANURA, 2.5, calado=True)
    barra(ic, 8.5, 18.5, 13.5)
    punta(ic, [(2, 8.5), (6.5, 12), (2, 15.5)])
    return ic


def grua():
    """Grúa pórtico (la composición del estilo C en macizo): mástil-pata de tierra a la derecha, pluma con
    el tirante fundidos en una cuña que sale sobre el mar, pata de mar, el muelle bajo las patas y el
    contenedor colgado del cable, en el aire, a la izquierda."""
    ic = Icono('grua')
    ic.rect(19.5, 2, 2.5, 18.75, relleno=True)
    ic.poli([(3.25, 6.5), (22, 3.5), (22, 9), (3.25, 9)], relleno=True)
    ic.circulo(3.25, 7.75, 1.25, relleno=True)
    ic.rect(13.5, 9, 3, 11.75, relleno=True)
    barra(ic, 12, 19.5, 10)
    ic.rect(4.75, 9, 2.5, 4.5, relleno=True)
    ic.rect(2.5, 13.5, 7, 5.5, relleno=True)
    return ic


def muelle():
    """Muelle = la barra-píldora del muelle (gruesa) con dos bolardos encima: la seta del bolardo es la
    silueta que dice «muelle» a quien amarra."""
    ic = Icono('muelle')
    barra(ic, 2, 17.5, 20, 4.5)
    for cx in (7, 17):
        barra(ic, cx - 3.75, 7.5, 7.5, 3)
        ic.rect(cx - 1.5, 10, 3, 8, relleno=True)
    return ic


def escala():
    """Escala = puerto de escala: el ancla, construida con el vocabulario (arganeo como anillo calado, caña
    y cepo macizos, brazos como banda sobre arco y uñas como puntas)."""
    ic = Icono('escala')
    ic.circulo(12, 5.25, 3.25, relleno=True)
    ic.circulo(12, 5.25, 1.25, calado=True)
    ic.rect(10.5, 8, 3, 11, relleno=True)
    barra(ic, 5, 8.75, 14, 3)
    arco_banda(ic, 12, 13.5, 7.125, 7.125, 2.75, 25, 155)
    punta(ic, [(19.6, 13.5), (21.75, 17.75), (16.75, 18)])
    punta(ic, [(4.4, 13.5), (7.25, 18), (2.25, 17.75)])
    return ic


# ================================================================ archivos y nube
def baplie():
    """El archivo EDI del plano: la hoja (doblez de 4.5) con el corte de la bahía calado: dos celdas de
    cubierta (3×3), la tapa como pared maciza de 3 y dos columnas de bodega con la curva del casco."""
    ic = Icono('baplie')
    hoja(ic, 4.5, 3, 15, 18, 4.5)
    for x0 in (7.5, 13.5):
        ic.rect(x0, 6, 3, 3, calado=True)
    columna_casco(ic, 7.5, 12, 3, 6, 3, 'izq')
    columna_casco(ic, 13.5, 12, 3, 6, 3, 'der')
    return ic


def comparar_baplie():
    """Dos hojas enfrentadas (dobleces hacia fuera), cada una con su columna de celdas caladas; en la derecha
    la celda está en otro sitio: lo que cambió entre los dos planos."""
    ic = Icono('comparar_baplie')
    hoja(ic, 3, 3, 7.5, 18, 3, lado='izq')
    hoja(ic, 13.5, 3, 7.5, 18, 3, lado='der')
    for y0 in (7.5, 13.5):
        ic.rect(4.5, y0, 3, 3, calado=True)
    ic.rect(16.5, 10.5, 3, 3, calado=True)
    return ic


def baplie_salida():
    """BAPLIE de salida: la hoja estrecha (x 3–12, doblez 4) con sus dos celdas y, fuera de ella, la flecha
    maciza hacia la derecha: el plano que se va con el buque. Horizontal y con hoja: no es descarga."""
    ic = Icono('baplie_salida')
    hoja(ic, 3, 3, 9, 18, 4)
    for y0 in (7.5, 13.5):
        ic.rect(6, y0, 3, 3, calado=True)
    ic.rect(14, 10.5, 5, 3, relleno=True)
    punta(ic, [(16.5, 6), (22, 12), (16.5, 18)])
    return ic


def listado_agencia():
    """El listado de la agencia: la hoja apaisada (hoja de cálculo, doblez 4.5) con la tabla calada: la
    columna estrecha del número de orden y la ancha del contenedor, tres filas con reglas de 1.5."""
    ic = Icono('listado_agencia')
    hoja(ic, 3, 4.5, 18, 15, 4.5)
    for y0 in (6, 10.5, 15):
        ic.rect(6, y0, 3, 3, calado=True)
        ic.rect(10.5, y0, 4.5, 3, calado=True)
    return ic


def al_dia():
    """Al día: la nube maciza propia (base de celda + dos lomos) con el visto bueno calado."""
    ic = Icono('al_dia')
    ic.rect(2, 12, 20, 8, relleno=True)
    ic.circulo(9.5, 11, 7.5, relleno=True)
    ic.circulo(16.5, 12.5, 5.5, relleno=True)
    banda(ic, 7, 13.5, 10.5, 16.5, 2.75, calado=True)
    banda(ic, 10.5, 16.5, 17, 10.5, 2.75, calado=True)
    return ic


def solo_aqui():
    """Solo aquí (sin red): la misma nube con la pausa calada donde iba el visto bueno."""
    ic = Icono('solo_aqui')
    ic.rect(2, 12, 20, 8, relleno=True)
    ic.circulo(9.5, 11, 7.5, relleno=True)
    ic.circulo(16.5, 12.5, 5.5, relleno=True)
    ic.rect(7.5, 9, 3, 7.5, calado=True)
    ic.rect(13.5, 9, 3, 7.5, calado=True)
    return ic


ICONOS = {n: globals()[n]() for n in [
    'contenedor_20', 'contenedor_40', 'contenedor_45', 'vacio', 'refrigerado', 'peligrosa', 'fuera_de_medida', 'tanque', 'plataforma', 'techo_abierto',
    'buque', 'bahia', 'tapa_escotilla', 'peso_pila', 'limite_apilamiento', 'vgm', 'segregacion',
    'descarga', 'carga', 'reestiba', 'pedir_cambio', 'orden', 'grua', 'muelle', 'escala',
    'baplie', 'comparar_baplie', 'baplie_salida', 'listado_agencia', 'al_dia', 'solo_aqui']}
