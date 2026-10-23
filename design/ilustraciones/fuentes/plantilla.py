"""plantilla.py — piezas comunes de las ilustraciones de BayStream (Nube).

Cada función recibe la `Ilustracion` del DSL de `ilus.py` y una posición/escala en píxeles de la hoja,
y dibuja en línea de plano técnico con rellenos planos de la paleta (claro y oscuro salen del mismo
dibujo). Los grosores de trazo NO escalan con la pieza: a 640 de ancho se usan 2 (2.5 en casco y
pluma); a 320 de ancho, 1.5–2, y se comprueba el 3:1 con `verificar_ilus.py`.

Vocabulario heredado del ícono de la app: la celda cuadrada (lado 11, esquina 1.9 → R_CELDA = 1.9/11),
el paso de rejilla 13.8 (celda + 2.8 de luz), la barra de la tapa de escotilla, la bodega que se cierra
hacia la quilla con la curva del casco, el hueco punteado que deja un contenedor y la pieza naranja que
se mueve fuera de la rejilla. El naranja (`grua`) solo marca lo que se acaba de mover.

    agua(il, x, y, w, h, grosor=2)
        Banda de agua (frase / panel_alto) y la línea de flotación sobre su borde superior.
    muelle(il, x, y, w, alto=50, hasta=None, defensa=False, grosor=2.5, grosor_linea=2)
        Banda `marca` del muelle con su cota, su base (= flotación), el muro debajo (panel en
        oscuro) y la cara del muelle a la derecha, con defensa opcional.
    grua(il, x, y, escala=1, luz=150, pluma=(-95, 445), reposo=False, carro_x=None, carga=None,
         grosor=2, grosor_pluma=2.5)
        Grúa pórtico STS en línea. (x, y) = eje de la pierna de tierra sobre la cota del muelle.
        carga=(x, y, lado): contenedor naranja izado bajo el spreader; reposo: sin carga, carro
        recogido sobre el portal y spreader izado.
    buque_corte(il, x, y, escala, columnas=4, filas_cubierta=2, filas_bodega=3, cubierta=None,
                bodega=None, vacias=(), naranja=None, con_tapa=True, grosor=2, grosor_casco=2.5)
        El corte de la bahía como en el ícono. (x, y) = esquina superior izquierda de la celda
        (0, 0) de cubierta; escala = px por unidad del ícono. Devuelve la geometría (ver docstring).
    geometria_corte(x, y, escala, columnas, filas_cubierta, filas_bodega)
        La misma geometría sin dibujar.
    celda(il, x, y, lado, estado='cubierta' | 'bodega' | 'naranja' | 'vacia', grosor=2)
    tapa(il, x, y, w, h, grosor=2)
    buque_perfil(il, x, y, w, h, filas=1, celdas=None, caseta=True, grosor=2)
        Perfil del buque con la proa SIEMPRE a la izquierda. (x, y) = roda en la línea de cubierta.
    nube(il, cx, cy, w, estado='normal' | 'pausa', grosor=2)
    check(il, cx, cy, tam, grosor=None, fondo=True)   en `hecho`
"""
from __future__ import annotations
import math

LADO_U = 11.0            # lado de la celda, en unidades del ícono
PASO_U = 13.8            # paso de la rejilla (celda + luz)
GAP_U = PASO_U - LADO_U  # 2.8: luz entre celdas = espesor del casco
R_CELDA = 1.9 / 11       # radio de esquina / lado, como en el ícono
AREA_MINIMA = 0.45       # fracción de celda que debe sobrevivir al recorte del casco para dibujarse

_CLARO_OSCURO = ('hoja', 'panel_alto')   # relleno de los miembros «de chapa» (grúa, caseta, nube)


def _f(v):
    return f'{v:.2f}'


# ====================================================================== agua y muelle
def agua(il, x, y, w, h, grosor=2):
    """Banda de agua desde (x, y), w × h, y la línea de flotación sobre su borde superior."""
    il.grupo('agua').rect(x, y, w, h, relleno=('frase', 'panel_alto'))
    il.grupo('flotacion').linea(x, y, x + w, y, trazo=('tinta_suave', 'bodega'), grosor=grosor)
    return il


def muelle(il, x, y, w, alto=50, hasta=None, defensa=False, grosor=2.5, grosor_linea=2):
    """La banda azul de la marca es el gesto de la app: muelle de (x, y) a (x + w, y + alto), con su
    cota arriba, su base (que es el mismo datum que la flotación) y el muro debajo hasta `hasta`
    (el papel ya es tierra; en oscuro, un `panel` sin trazo le da masa). La cara del muelle queda a
    la derecha, en x + w; con `defensa`, una defensa apoyada en la cara, justo bajo la cota."""
    hasta = il.alto if hasta is None else hasta
    k = alto / 50.0
    if hasta > y + alto:
        il.grupo('muelle_muro').rect(x, y + alto, w, hasta - (y + alto), relleno=(None, 'panel'))
    il.grupo('muelle').rect(x, y, w, alto, relleno='marca')
    il.grupo('muelle_cota').linea(x, y, x + w, y, trazo='tinta', grosor=grosor)
    il.grupo('muelle_base').linea(x, y + alto, x + w, y + alto, trazo=('tinta_suave', 'bodega'),
                                   grosor=grosor_linea)
    il.grupo('muelle_cara').linea(x + w, y, x + w, hasta, trazo='tinta', grosor=grosor)
    if defensa:
        il.grupo('defensa').rect(x + w, y + 6 * k, 15 * k, 26 * k, r=3 * k, relleno='tinta_suave')
    return il


# ====================================================================== celda y tapa
_ESTADOS = {
    'cubierta': dict(relleno=('hoja', 'cubierta'), trazo=('tinta', None)),
    'bodega': dict(relleno='bodega', trazo=None),
    'naranja': dict(relleno='grua', trazo=('tinta', None)),
    'vacia': dict(relleno=None, trazo='tinta_suave'),
}


def celda(il, x, y, lado, estado='cubierta', grosor=2, nombre=None):
    """Una celda/contenedor de lado `lado` con la esquina del ícono. Estados: 'cubierta' (hoja con
    trazo tinta en claro; cubierta sin trazo en oscuro), 'bodega' (azul medio, sin trazo), 'naranja'
    (lo que se acaba de mover) y 'vacia' (el hueco: punteado en tinta_suave)."""
    kw = dict(_ESTADOS[estado])
    if estado == 'vacia':
        kw['punteado'] = (6 * lado / 30.8, 4 * lado / 30.8)
    il.grupo(nombre or 'celda_' + estado).rect(x, y, lado, lado, r=R_CELDA * lado, grosor=grosor, **kw)
    return il


def tapa(il, x, y, w, h, grosor=2):
    """La barra de la tapa de escotilla: cápsula clara (hoja con trazo en claro, cubierta en oscuro)."""
    il.grupo('tapa').rect(x, y, w, h, r=h / 2, relleno=('hoja', 'cubierta'), trazo=('tinta', None),
                          grosor=grosor)
    return il


# ====================================================================== buque en corte
class _Casco:
    """Curva interior del casco (lado izquierdo) en unidades del ícono, con origen en la esquina
    superior izquierda de la bodega (x = borde izquierdo de la columna 0, y = tope de la fila 0).

    Reconstruida del ícono (4 columnas, 3 filas): parábola x = 0.01·y² hasta y = prof − 1.95 y un
    giro cuadrático al plan de la quilla, que queda plano en xc ± 8.5. Para otras columnas y filas
    se conservan las proporciones del ícono (x del final de la parábola, control y plano de la quilla
    como fracción del ancho interior; la parábola termina 1.95 por encima de la quilla)."""

    def __init__(self, columnas, filas_bodega):
        self.wi = columnas * PASO_U - GAP_U          # ancho interior (52.4 en el ícono)
        self.xc = self.wi / 2
        self.prof = filas_bodega * PASO_U - GAP_U    # profundidad hasta la quilla (38.6 en el ícono)
        self.yfin = self.prof - 1.95
        xfin = 13.43 / 52.4 * self.wi
        self.k = xfin / self.yfin ** 2               # 0.01 en el ícono
        ctrl = (14.83 / 52.4 * self.wi, self.prof)
        plano = self.xc - 8.5 / 52.4 * self.wi
        pts = []
        y = 0.0
        while y < self.yfin:
            pts.append((self.k * y * y, y))
            y += 0.25
        p0 = (self.k * self.yfin ** 2, self.yfin)
        p1 = (plano, self.prof)
        for i in range(0, 41):
            t = i / 40
            pts.append(((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * ctrl[0] + t * t * p1[0],
                        (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * ctrl[1] + t * t * p1[1]))
        self.curva = pts

    def fx(self, y):
        """x de la curva interior izquierda a la altura y (no decreciente en y)."""
        c = self.curva
        if y <= c[0][1]:
            return c[0][0]
        for (xa, ya), (xb, yb) in zip(c, c[1:]):
            if ya <= y <= yb:
                return xa if yb == ya else xa + (xb - xa) * (y - ya) / (yb - ya)
        return c[-1][0]

    def y_en_x(self, x):
        """y donde la curva interior izquierda alcanza x."""
        c = self.curva
        if x <= c[0][0]:
            return c[0][1]
        for (xa, ya), (xb, yb) in zip(c, c[1:]):
            if xa <= x <= xb:
                return ya if xb == xa else ya + (yb - ya) * (x - xa) / (xb - xa)
        return c[-1][1]

    def exterior(self, top):
        """Contorno exterior del casco: la curva interior desplazada GAP_U hacia fuera, cerrado por
        arriba a la altura `top` (base de la tapa), en unidades locales."""
        izq = []
        c = self.curva
        for i, (x, y) in enumerate(c):
            xa, ya = c[max(i - 1, 0)]
            xb, yb = c[min(i + 1, len(c) - 1)]
            tx, ty = _unit(xb - xa, yb - ya)
            izq.append((x - ty * GAP_U, y + tx * GAP_U))     # normal hacia fuera
        pts = [(-GAP_U, top), (-GAP_U, c[0][1])] + izq
        pts += [(self.wi - x, y) for x, y in reversed(izq)]
        pts += [(self.wi + GAP_U, c[0][1]), (self.wi + GAP_U, top)]
        return pts


def _unit(dx, dy):
    n = math.hypot(dx, dy) or 1
    return dx / n, dy / n


def _area(verts):
    n = len(verts)
    return abs(sum(verts[i][0] * verts[(i + 1) % n][1] - verts[(i + 1) % n][0] * verts[i][1]
                   for i in range(n))) / 2


def _ruta_redondeada(verts, r):
    """Polígono cerrado con vértices (x, y, redondear) en píxeles → ruta SVG con esquinas de radio r
    donde `redondear` es True."""
    pts = []
    for v in verts:
        if not pts or math.hypot(v[0] - pts[-1][0], v[1] - pts[-1][1]) > 1e-6:
            pts.append(v)
    if len(pts) > 1 and math.hypot(pts[0][0] - pts[-1][0], pts[0][1] - pts[-1][1]) <= 1e-6:
        pts.pop()
    n = len(pts)
    cmds = []
    for i, (x, y, rd) in enumerate(pts):
        px, py, _ = pts[i - 1]
        nx, ny, _ = pts[(i + 1) % n]
        if rd:
            din = _unit(x - px, y - py)
            dout = _unit(nx - x, ny - y)
            rr = min(r, math.hypot(x - px, y - py) / 2, math.hypot(nx - x, ny - y) / 2)
            ax, ay = x - din[0] * rr, y - din[1] * rr
            bx, by = x + dout[0] * rr, y + dout[1] * rr
            sweep = 1 if (din[0] * dout[1] - din[1] * dout[0]) > 0 else 0
            cmds.append(f'L{ax:.2f} {ay:.2f}')
            cmds.append(f'A{rr:.2f} {rr:.2f} 0 0 {sweep} {bx:.2f} {by:.2f}')
        else:
            cmds.append(f'L{x:.2f} {y:.2f}')
    cmds[0] = 'M' + cmds[0][1:]
    return ' '.join(cmds) + ' Z'


def _recorte(casco, x0, y0, x1, y1, n=28):
    """Celda [x0, x1] × [y0, y1] (unidades locales de la bodega) recortada por el casco, que a la
    altura y deja libre [fx(y), wi − fx(y)]. Devuelve None si cabe entera, [] si no queda nada o la
    lista de vértices (x, y, redondear) en sentido horario."""
    wi = casco.wi
    fl = casco.fx
    fr = lambda y: wi - casco.fx(y)
    eps = 1e-9
    if fl(y1) <= x0 + eps and fr(y1) >= x1 - eps:
        return None
    if max(x0, fl(y0)) >= min(x1, fr(y0)) - eps:
        return []
    izq = fl(y1) > x0 + eps
    der = fr(y1) < x1 - eps
    if max(x0, fl(y1)) < min(x1, fr(y1)) - eps:
        yb = y1
    else:                                   # la celda se cierra antes del fondo: bisección
        lo, hi = y0, y1
        for _ in range(60):
            m = (lo + hi) / 2
            if min(x1, fr(m)) - max(x0, fl(m)) > 0:
                lo = m
            else:
                hi = m
        yb = lo
    yl = casco.y_en_x(x0) if izq else None           # donde la curva cruza el borde izquierdo
    yr = casco.y_en_x(wi - x1) if der else None      # idem, derecho (simétrico)
    verts = []
    # arriba, de izquierda a derecha
    if izq and fl(y0) > x0 + eps:
        verts.append((fl(y0), y0, False))
    else:
        verts.append((x0, y0, (yl - y0 >= 1.9) if izq else True))
    if der and fr(y0) < x1 - eps:
        verts.append((fr(y0), y0, False))
    else:
        verts.append((x1, y0, (yr - y0 >= 1.9) if der else True))
    # lado derecho, de arriba abajo
    if der and yr < yb:
        verts.append((x1, yr, False))
        for i in range(1, n + 1):
            y = yr + (yb - yr) * i / n
            verts.append((fr(y), y, False))
    else:
        verts.append((x1, yb, yb == y1 and max(x0, fl(y1)) <= x1 - 1.9))
    # lado izquierdo, de abajo arriba
    if izq and yl < yb:
        for i in range(0, n + 1):
            y = yb - (yb - yl) * i / n
            verts.append((fl(y), y, False))
        if yl > y0 + eps:
            verts.append((x0, yl, False))
    else:
        verts.append((x0, yb, yb == y1 and min(x1, fr(y1)) >= x0 + 1.9))
    return verts


def geometria_corte(x, y, escala, columnas=4, filas_cubierta=2, filas_bodega=3):
    """Geometría del corte sin dibujar. (x, y) = esquina superior izquierda de la celda (0, 0) de
    cubierta; escala = px por unidad del ícono. Devuelve dict con:
      lado (px), paso (px), xc (px), casco (_Casco), y_bodega (px, tope de la fila 0 de la bodega),
      quilla_y (px), tapa = (x, y, w, h) px, caja = (x0, y0, x1, y1) px del casco exterior,
      celda(fila, col) → (x, y) px de la esquina superior izquierda (filas de cubierta desde 0;
      pueden ser negativas o fraccionarias), celda_bodega(fila, col) → idem para la bodega."""
    e = escala
    casco = _Casco(columnas, filas_bodega)
    y_tapa = filas_cubierta * PASO_U
    y_bod = y_tapa + 5.4 + GAP_U
    g = dict(lado=LADO_U * e, paso=PASO_U * e, xc=x + casco.xc * e, casco=casco, escala=e,
             columnas=columnas, filas_cubierta=filas_cubierta, filas_bodega=filas_bodega,
             y_bodega=y + y_bod * e, quilla_y=y + (y_bod + casco.prof) * e,
             tapa=(x - 6 * e, y + y_tapa * e, (casco.wi + 12) * e, 5.4 * e),
             caja=(x - GAP_U * e, y + (y_tapa + 5.4) * e, x + (casco.wi + GAP_U) * e,
                   y + (y_bod + casco.prof + GAP_U) * e),
             celda=lambda fila, col: (x + col * PASO_U * e, y + fila * PASO_U * e),
             celda_bodega=lambda fila, col: (x + col * PASO_U * e, y + (y_bod + fila * PASO_U) * e))
    g['_T'] = lambda ux, uy: (x + ux * e, y + (y_bod + uy) * e)   # unidades locales de bodega → px
    g['_top'] = y_tapa + 5.4 - y_bod                                 # base de la tapa en unidades de bodega
    return g


def buque_corte(il, x, y, escala, columnas=4, filas_cubierta=2, filas_bodega=3, cubierta=None,
                bodega=None, vacias=(), naranja=None, con_tapa=True, grosor=2, grosor_casco=2.5):
    """El corte de la bahía del ícono, ampliado: casco `marca` cuyo interior se cierra hacia la
    quilla con la curva del casco, la bodega de celdas `bodega` (recortadas por el casco; una celda
    se dibuja solo si conserva AREA_MINIMA de su área), la barra de la tapa y las filas de cubierta.
    cubierta / bodega: conjuntos de (fila, col) con contenedor (None = todas); vacias: celdas de
    cubierta dibujadas punteadas (el hueco); naranja: (fila, col) de cubierta que se acaba de mover
    (la fila puede ser fraccionaria o negativa). Devuelve la geometría de `geometria_corte`."""
    g = geometria_corte(x, y, escala, columnas, filas_cubierta, filas_bodega)
    e, casco, T = escala, g['casco'], g['_T']
    lado, R = g['lado'], R_CELDA * LADO_U * e
    vacias = set(vacias)

    il.grupo('casco').poli([T(ux, uy) for ux, uy in casco.exterior(g['_top'])], cerrar=True,
                           relleno='marca', trazo=('tinta', 'tinta_suave'), grosor=grosor_casco)
    for fila in range(filas_bodega):
        for col in range(columnas):
            if bodega is not None and (fila, col) not in bodega:
                continue
            x0, y0 = col * PASO_U, fila * PASO_U
            verts = _recorte(casco, x0, y0, x0 + LADO_U, y0 + LADO_U)
            if verts is None:
                cx, cy = T(x0, y0)
                celda(il, cx, cy, lado, 'bodega', nombre=f'bodega_{fila}_{col}')
            elif verts and _area(verts) >= AREA_MINIMA * LADO_U * LADO_U:
                d = _ruta_redondeada([(T(ux, uy)[0], T(ux, uy)[1], rd) for ux, uy, rd in verts], R)
                il.grupo(f'bodega_{fila}_{col}').ruta(d, relleno='bodega')
    if con_tapa:
        tapa(il, *g['tapa'], grosor=grosor)
    for fila in range(filas_cubierta):
        for col in range(columnas):
            cx, cy = g['celda'](fila, col)
            if (fila, col) in vacias:
                celda(il, cx, cy, lado, 'vacia', grosor=grosor + 0.5, nombre='celda_vacia')
            elif cubierta is None or (fila, col) in cubierta:
                celda(il, cx, cy, lado, 'cubierta', grosor=grosor, nombre=f'cubierta_{fila}_{col}')
    if naranja is not None:
        cx, cy = g['celda'](*naranja)
        celda(il, cx, cy, lado, 'naranja', grosor=grosor, nombre='naranja')
    return g


# ====================================================================== grúa pórtico
def grua(il, x, y, escala=1.0, luz=150, pluma=(-95, 445), reposo=False, carro_x=None, carga=None,
         grosor=2, grosor_pluma=2.5):
    """Grúa pórtico STS en línea, de plano. (x, y) = eje de la pierna de tierra sobre la cota del
    muelle. Las cotas van en píxeles «de inicio» (640 de ancho) multiplicados por `escala`; `luz` es la
    distancia entre piernas y `pluma` = (vuelo hacia tierra, alcance sobre el agua) desde la pierna de
    tierra. Piezas: viga sill con ruedas, piernas, portal, riostra, pluma, casa de máquinas en el
    tramo de tierra, pilón en A con tres tirantes (punta, medio y casa) y el carro con la cabina
    colgando de su cara inferior.
      carga=(x, y, lado): contenedor naranja izado; el carro se centra sobre él y bajan dos cables
        al spreader, que lo sujeta por arriba.
      reposo=True: sin carga, carro recogido sobre el portal con el spreader izado.
      carro_x: posición del carro si no hay carga (por defecto, a mitad del alcance; en reposo, sobre
        el portal).
    Devuelve dict con pluma=(x0, y0, x1, y1), apice=(x, y), carro=(x, y, w, h) en px."""
    e = escala
    P = lambda dx, dy: (x + dx * e, y + dy * e)
    miembro = dict(relleno=_CLARO_OSCURO, trazo='tinta', grosor=grosor)
    x1 = x + luz * e                               # pierna de agua
    y_pluma, h_pluma = -190, 12                    # cara superior de la pluma y su canto
    y_carro = y_pluma + h_pluma                    # cara inferior de la pluma = tope del carro
    px0, px1 = pluma
    # viga sill y ruedas, piernas
    for xp in (x, x1):
        il.grupo('sill').rect(xp - 24 * e, y - 16 * e, 48 * e, 9 * e, **miembro)
        for dx in (-14, 14):
            il.grupo('rueda').circulo(xp + dx * e, y - 5 * e, 5 * e, **miembro)
        il.grupo('pierna').rect(xp - 6 * e, y + y_carro * e, 12 * e, (-16 - y_carro) * e, **miembro)
    # portal y riostra
    il.grupo('portal').rect(x + 6 * e, y - 110 * e, (luz - 12) * e, 10 * e, **miembro)
    il.grupo('riostra').linea(x + 6 * e, y - 110 * e, x1 - 6 * e, y + (y_carro + 4) * e,
                              trazo='tinta', grosor=grosor)
    # pluma
    il.grupo('pluma').rect(x + px0 * e, y + y_pluma * e, (px1 - px0) * e, h_pluma * e,
                           relleno=_CLARO_OSCURO, trazo='tinta', grosor=grosor_pluma)
    # casa de máquinas sobre el tramo de tierra (baja: 18 de alto, para que el tirante le pase encima)
    casa = (x + (px0 + 11) * e, y + (y_pluma - 18) * e, 70 * e, 18 * e)
    il.grupo('maquinas').rect(*casa, **miembro)
    # pilón en A sobre la pierna de agua y tres tirantes: punta, medio y casa de máquinas. El de
    # tierra se ancla 4 dentro de la esquina alta de la casa y le pasa por encima (5.2 px de luz en
    # su borde derecho a escala 1, 2.6 a la mitad); el ápice queda a 36 sobre la pluma.
    apice = P(luz, y_pluma - 36)
    x_punta = x + (px1 - 6) * e
    x_medio = x1 + 0.475 * (x + px1 * e - x1)
    il.grupo('tirante').linea(apice[0], apice[1], x_punta, y + y_pluma * e, trazo='tinta', grosor=grosor)
    il.grupo('tirante').linea(apice[0], apice[1], x_medio, y + y_pluma * e, trazo='tinta', grosor=grosor)
    il.grupo('tirante').linea(apice[0], apice[1], casa[0] + 4 * e, casa[1], trazo='tinta', grosor=grosor)
    il.grupo('pilon').poli([P(luz - 14, y_pluma), P(luz + 14, y_pluma), apice], cerrar=True, **miembro)
    # carro (42 de ancho: 26 a tierra, 16 al agua) con la cabina colgando de su cara inferior, a
    # tierra de los cables (que bajan a ±12 del eje de la carga)
    if carga is not None:
        cx = carga[0] + carga[2] / 2
    elif carro_x is not None:
        cx = carro_x
    elif reposo:
        cx = x + luz * 0.5 * e
    else:
        cx = x1 + 0.5 * (x + px1 * e - x1)
    carro = (cx - 26 * e, y + y_carro * e, 42 * e, 12 * e)
    il.grupo('carro').rect(*carro, **miembro)
    il.grupo('cabina').rect(cx - 26 * e, y + (y_carro + 12) * e, 10 * e, 10 * e, **miembro)
    y_cables = y + (y_carro + 12) * e
    if carga is not None:
        lx, ly, lado = carga
        y_spreader = ly - 7 * e
        for dx in (-12, 12):
            il.grupo('cable').linea(cx + dx * e, y_cables, cx + dx * e, y_spreader, trazo='tinta', grosor=grosor)
        il.grupo('spreader').rect(lx - 2 * e, y_spreader, lado + 4 * e, 7 * e, r=1.5 * e, **miembro)
        celda(il, lx, ly, lado, 'naranja', grosor=grosor, nombre='izado')
    elif reposo:
        lado = LADO_U * 2.8 * e
        y_spreader = y_cables + 14 * e
        for dx in (-12, 12):
            il.grupo('cable').linea(cx + dx * e, y_cables, cx + dx * e, y_spreader, trazo='tinta', grosor=grosor)
        il.grupo('spreader').rect(cx - lado / 2 - 2 * e, y_spreader, lado + 4 * e, 7 * e, r=1.5 * e, **miembro)
    return dict(pluma=(x + px0 * e, y + y_pluma * e, x + px1 * e, y + y_carro * e), apice=apice, carro=carro)


# ====================================================================== perfil del buque
def buque_perfil(il, x, y, w, h, filas=1, celdas=None, caseta=True, grosor=2):
    """Perfil del buque con la proa SIEMPRE a la izquierda. (x, y) = la roda en la línea de cubierta;
    w = eslora dibujada; h = de la cubierta a la quilla. Casco `marca` con la roda lanzada y el espejo
    de popa a la derecha; sobre cubierta, `filas` filas de contenedores (celdas de cubierta) y, si
    `caseta`, la superestructura a popa. Devuelve dict con lado, cubierta=(x0, x1) de la zona de carga."""
    xa, xb = x + w * 0.27, x + w * 0.95
    d = (f'M{_f(x)} {_f(y)} H{_f(x + w * 0.975)} L{_f(x + w)} {_f(y + h * 0.5)} L{_f(xb)} {_f(y + h)} '
         f'H{_f(xa)} C{_f(x + w * 0.12)} {_f(y + h)} {_f(x + w * 0.025)} {_f(y + h * 0.6)} {_f(x)} {_f(y)} Z')
    il.grupo('casco_perfil').ruta(d, relleno='marca', trazo=('tinta', 'tinta_suave'), grosor=grosor)
    lado = h * 0.48
    gap = lado * GAP_U / LADO_U
    zx0, zx1 = x + w * 0.11, x + w * 0.76
    n = celdas or int((zx1 - zx0 + gap) // (lado + gap))
    ancho = n * lado + (n - 1) * gap
    cx0 = zx0 + (zx1 - zx0 - ancho) / 2
    for fila in range(filas):
        cy = y - (fila + 1) * (lado + gap) + gap
        for i in range(n):
            celda(il, cx0 + i * (lado + gap), cy, lado, 'cubierta', grosor=grosor, nombre=f'perfil_{fila}_{i}')
    if caseta:
        hb = filas * (lado + gap) + lado * 0.3
        bx, bw = x + w * 0.80, w * 0.14
        il.grupo('caseta').rect(bx, y - hb, bw, hb, relleno=_CLARO_OSCURO, trazo='tinta', grosor=grosor)
        il.grupo('puente').rect(bx + bw * 0.08, y - hb - lado * 0.5, bw * 0.84, lado * 0.5,
                                relleno=_CLARO_OSCURO, trazo='tinta', grosor=grosor)
    return dict(lado=lado, cubierta=(cx0, cx0 + ancho))


# ====================================================================== nube y check
def _interseccion_alta(c1, r1, c2, r2):
    (x1, y1), (x2, y2) = c1, c2
    d = math.hypot(x2 - x1, y2 - y1)
    a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
    hh = math.sqrt(max(r1 * r1 - a * a, 0))
    mx, my = x1 + a * (x2 - x1) / d, y1 + a * (y2 - y1) / d
    px, py = -(y2 - y1) / d, (x2 - x1) / d
    p = (mx + hh * px, my + hh * py)
    q = (mx - hh * px, my - hh * py)
    return p if p[1] < q[1] else q                    # la de arriba (y menor)


def _arco_hasta(c, r, desde, hasta):
    """Tramo 'A' en sentido horario (de pantalla) sobre el círculo (c, r) desde el punto `desde` al
    punto `hasta`."""
    a0 = math.degrees(math.atan2(desde[1] - c[1], desde[0] - c[0]))
    a1 = math.degrees(math.atan2(hasta[1] - c[1], hasta[0] - c[0]))
    grande = 1 if (a1 - a0) % 360 > 180 else 0
    return f'A{_f(r)} {_f(r)} 0 {grande} 1 {_f(hasta[0])} {_f(hasta[1])}'


def nube(il, cx, cy, w, estado='normal', grosor=2):
    """La nube, construida propia: tres arcos (pequeño a la izquierda, grande en el centro, medio a
    la derecha) sobre una base plana; de ancho w y alto 0.62·w, centrada en (cx, cy). Estado 'pausa':
    dos barras `tinta` dentro (sin red: se trabaja solo en este equipo)."""
    yb = cy + 0.31 * w
    A = ((cx - 0.26 * w, yb - 0.19 * w), 0.19 * w)
    B = ((cx - 0.02 * w, yb - 0.31 * w), 0.31 * w)
    C = ((cx + 0.25 * w, yb - 0.21 * w), 0.21 * w)
    pab = _interseccion_alta(A[0], A[1], B[0], B[1])
    pbc = _interseccion_alta(B[0], B[1], C[0], C[1])
    ini = (A[0][0], yb)
    fin = (C[0][0], yb)
    d = (f'M{_f(ini[0])} {_f(ini[1])} ' + _arco_hasta(A[0], A[1], ini, pab) + ' '
         + _arco_hasta(B[0], B[1], pab, pbc) + ' ' + _arco_hasta(C[0], C[1], pbc, fin) + ' Z')
    il.grupo('nube').ruta(d, relleno=_CLARO_OSCURO, trazo='tinta', grosor=grosor)
    if estado == 'pausa':
        bw, bh = 0.08 * w, 0.26 * w
        for dx in (-0.09 * w, 0.09 * w):
            il.grupo('pausa').rect(cx + dx - bw / 2, cy + 0.02 * w - bh / 2, bw, bh, r=R_CELDA * bw,
                                   relleno='tinta')
    elif estado != 'normal':
        raise ValueError(f'estado de nube desconocido: {estado!r}')
    return il


def check(il, cx, cy, tam, grosor=None, fondo=True):
    """La marca de hecho, en `hecho`: un círculo de diámetro `tam` (relleno de chapa) con el check
    dentro. El trazo del check crece con el tamaño si no se da `grosor`."""
    g = grosor if grosor is not None else max(2.0, tam * 0.11)
    if fondo:
        il.grupo('check_fondo').circulo(cx, cy, tam / 2, relleno=_CLARO_OSCURO, trazo='hecho', grosor=g)
    il.grupo('check').poli([(cx - 0.25 * tam, cy + 0.01 * tam), (cx - 0.07 * tam, cy + 0.19 * tam),
                            (cx + 0.27 * tam, cy - 0.17 * tam)], trazo='hecho', grosor=g)
    return il
