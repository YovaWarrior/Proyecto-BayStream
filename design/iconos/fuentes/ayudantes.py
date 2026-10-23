"""Ayudantes compartidos de los íconos de BayStream (estilo B · Sólido). Nube.

Rejilla de 24, margen de 2, un solo color. Todo macizo (relleno=True) o hueco (calado=True), luz ≥ 2.
Esquinas con la proporción de la celda del ícono (R_CELDA = 1.9/11) salvo dos excepciones declaradas:
la «barra» (tapa de escotilla, muelle, viga de la báscula) es la píldora del ícono maestro (r = h/2), y la
«hoja» de los archivos lleva R_HOJA = R_CELDA × 8 (la esquina de la base de la nube): con la proporción
del lado menor (≈ 2.6 a 15 de lado) la hoja se volvía tarjeta y el doblez se perdía.

Familia de cajas de contenedor, en la banda CAJA = (3, 6, 18, 12): x 3–21, y 6–18, bordes en píxel entero
a 16, 20 y 24 px. contenedor_20 es una caja de 12 centrada (la única que no llega a 16 de eje: un 20′ es
corto, y esa es la señal); contenedor_45 ocupa 2–22 y es más alta (y 5–19). Las ranuras del corrugado
miden RANURA = 2.25 (1.5 px a 16).
"""
import math
from dsl import Icono, R_CELDA

S2 = math.sqrt(2)


# ---------------------------------------------------------------- ayudantes macizos
def banda(ic, x1, y1, x2, y2, w, calado=False, relleno=False, tapas=True):
    """Barra maciza (o calada) de anchura w entre dos puntos, con puntas redondas."""
    dx, dy = x2 - x1, y2 - y1
    L = math.hypot(dx, dy)
    nx, ny = -dy / L * w / 2, dx / L * w / 2
    # orden horario en pantalla, como rect() y circulo() del DSL: así los solapes entre bandas y tapas suman
    ic.poli([(x1 - nx, y1 - ny), (x2 - nx, y2 - ny), (x2 + nx, y2 + ny), (x1 + nx, y1 + ny)],
            relleno=relleno, calado=calado)
    if tapas:
        ic.circulo(x1, y1, w / 2, relleno=relleno, calado=calado)
        ic.circulo(x2, y2, w / 2, relleno=relleno, calado=calado)
    return ic


def poli_redondeado_d(pts, r):
    """Ruta cerrada (M L A … Z) de un polígono convexo con las esquinas redondeadas a radio r.
    Los puntos van en sentido horario en pantalla. Sin dependencias: solo trigonometría."""
    n = len(pts)
    partes = []
    for i in range(n):
        p0, p1, p2 = pts[i - 1], pts[i], pts[(i + 1) % n]
        v0 = (p0[0] - p1[0], p0[1] - p1[1]); l0 = math.hypot(*v0); v0 = (v0[0] / l0, v0[1] / l0)
        v2 = (p2[0] - p1[0], p2[1] - p1[1]); l2 = math.hypot(*v2); v2 = (v2[0] / l2, v2[1] / l2)
        ang = math.acos(max(-1.0, min(1.0, v0[0] * v2[0] + v0[1] * v2[1])))
        t = min(r / math.tan(ang / 2), l0 / 2, l2 / 2)      # distancia del vértice a los puntos de tangencia
        rr = t * math.tan(ang / 2)
        a = (p1[0] + v0[0] * t, p1[1] + v0[1] * t)
        b = (p1[0] + v2[0] * t, p1[1] + v2[1] * t)
        cruz = v0[0] * v2[1] - v0[1] * v2[0]
        barrido = 1 if cruz < 0 else 0
        partes.append(('M' if i == 0 else 'L') + f'{a[0]:.3f} {a[1]:.3f}')
        partes.append(f'A{rr:.3f} {rr:.3f} 0 0 {barrido} {b[0]:.3f} {b[1]:.3f}')
    return ''.join(partes) + 'Z'


def punta(ic, pts, r=0.7):
    """Punta de flecha maciza: triángulo (horario) con los tres vértices redondeados a r."""
    return ic.ruta(poli_redondeado_d(pts, r), relleno=True)


def rombo_d(cx, cy, D, r, horario=True):
    """Ruta de una celda girada 45°: rombo de semidiagonal D con puntas redondeadas a radio r.
    horario=False recorre al revés (para abrir un anillo dentro de otro rombo)."""
    k = r / S2
    Tr, Tl = (cx + k, cy - D + k), (cx - k, cy - D + k)
    Rt, Rb = (cx + D - k, cy - k), (cx + D - k, cy + k)
    Br, Bl = (cx + k, cy + D - k), (cx - k, cy + D - k)
    Lb, Lt = (cx - D + k, cy + k), (cx - D + k, cy - k)
    if horario:
        s, sw = [Tr, Rt, Rb, Br, Bl, Lb, Lt, Tl], 1
    else:
        s, sw = [Tl, Lt, Lb, Bl, Br, Rb, Rt, Tr], 0
    P = lambda p: f'{p[0]:.3f} {p[1]:.3f}'
    A = lambda p: f'A{r:.3f} {r:.3f} 0 0 {sw} {P(p)}'
    return (f'M{P(s[0])}L{P(s[1])}{A(s[2])}L{P(s[3])}{A(s[4])}'
            f'L{P(s[5])}{A(s[6])}L{P(s[7])}{A(s[0])}Z')


def arco_banda(ic, cx, cy, rx, ry, w, a0, a1):
    """Banda maciza de anchura w a lo largo de un arco elíptico de a0 a a1 (grados, horario), tapas redondas."""
    def p(r_x, r_y, a):
        return cx + r_x * math.cos(math.radians(a)), cy + r_y * math.sin(math.radians(a))
    ox, oy = rx + w / 2, ry + w / 2
    ix, iy = rx - w / 2, ry - w / 2
    grande = 1 if (a1 - a0) % 360 > 180 else 0
    p0o, p1o = p(ox, oy, a0), p(ox, oy, a1)
    p0i, p1i = p(ix, iy, a0), p(ix, iy, a1)
    d = (f'M{p0o[0]:.3f} {p0o[1]:.3f}A{ox} {oy} 0 {grande} 1 {p1o[0]:.3f} {p1o[1]:.3f}'
         f'L{p1i[0]:.3f} {p1i[1]:.3f}A{ix} {iy} 0 {grande} 0 {p0i[0]:.3f} {p0i[1]:.3f}Z')
    ic.ruta(d, relleno=True)
    for a in (a0, a1):
        x, y = p(rx, ry, a)
        ic.circulo(x, y, w / 2, relleno=True)
    return ic


def barra(ic, x, y, w, h=2.5):
    """La «barra» de la familia: tapa de escotilla / muelle, píldora como la del ícono maestro."""
    return ic.rect(x, y, w, h, r=h / 2, relleno=True)

CAJA = (3, 6, 18, 12)        # banda común de las cajas: x 3–21, y 6–18 (bordes enteros a 16/20/24 px)


# ---------------------------------------------------------------- ayudantes de los grupos
RANURA = 2.25          # ancho de las ranuras del corrugado (1.5 px a 16 px)
R_HOJA = R_CELDA * 8   # esquina de la hoja de los archivos (≈ 1.38): la de la base de la nube 20×8


def ranuras(ic, xs, y=9, h=6):
    """Ranuras caladas verticales del corrugado (mismo ancho que en contenedor_40)."""
    for x0 in xs:
        ic.rect(x0, y, RANURA, h, calado=True)
    return ic


def rect_d(x, y, w, h, r, horario=True):
    """Ruta de un rectángulo redondeado; horario=False lo recorre al revés (para abrir un hueco dentro de
    otra forma sin usar calado, que restaría también lo macizo que haya dentro)."""
    r = max(0.0, min(r, w / 2, h / 2))
    if horario:
        return (f'M{x+r:.3f} {y:.3f}H{x+w-r:.3f}A{r:.3f} {r:.3f} 0 0 1 {x+w:.3f} {y+r:.3f}'
                f'V{y+h-r:.3f}A{r:.3f} {r:.3f} 0 0 1 {x+w-r:.3f} {y+h:.3f}H{x+r:.3f}'
                f'A{r:.3f} {r:.3f} 0 0 1 {x:.3f} {y+h-r:.3f}V{y+r:.3f}A{r:.3f} {r:.3f} 0 0 1 {x+r:.3f} {y:.3f}Z')
    return (f'M{x+r:.3f} {y:.3f}A{r:.3f} {r:.3f} 0 0 0 {x:.3f} {y+r:.3f}V{y+h-r:.3f}'
            f'A{r:.3f} {r:.3f} 0 0 0 {x+r:.3f} {y+h:.3f}H{x+w-r:.3f}A{r:.3f} {r:.3f} 0 0 0 {x+w:.3f} {y+h-r:.3f}'
            f'V{y+r:.3f}A{r:.3f} {r:.3f} 0 0 0 {x+w-r:.3f} {y:.3f}Z')


def marco(ic, x, y, w, h, t):
    """Marco macizo de grosor t: la caja vista «por dentro». Una sola ruta con anillo, así lo que se dibuje
    dentro del hueco (el cilindro del tanque, la carga que se sale) sigue siendo macizo."""
    d = rect_d(x, y, w, h, R_CELDA * min(w, h)) + rect_d(x + t, y + t, w - 2 * t, h - 2 * t,
                                                           R_CELDA * min(w - 2 * t, h - 2 * t), horario=False)
    return ic.ruta(d, relleno=True)


def copo(ic, cx, cy, A, w, d, L, wr=None):
    """Copo propio: tres barras macizas cruzadas (seis brazos de eje A y anchura w, puntas redondas) y en
    cada brazo, a distancia d del centro, dos ramas de eje L y anchura wr a ±60° (paralelas a los brazos
    vecinos). Con d − L ≥ 4 las ramas que convergen entre dos brazos guardan luz ≥ 2."""
    wr = w if wr is None else wr
    for k in range(6):
        a = math.radians(90 + 60 * k)
        ux, uy = math.cos(a), math.sin(a)
        banda(ic, cx, cy, cx + A * ux, cy + A * uy, w, relleno=True)
        px, py = cx + d * ux, cy + d * uy
        for s in (-60, 60):
            b = math.radians(90 + 60 * k + s)
            banda(ic, px, py, px + L * math.cos(b), py + L * math.sin(b), wr, relleno=True)
    return ic


def balanza(ic, y=16.5, base=12):
    """La báscula del grupo buque: la barra-píldora como viga (y..y+2.5) sobre un fulcro macizo (triángulo
    de base 12 que llega al margen inferior). La «forma de peso», sin pesa, sin cifra, sin platillos."""
    barra(ic, 2, y, 20)
    punta(ic, [(12, y + 1.5), (12 + base / 2, 22), (12 - base / 2, 22)], 0.6)
    return ic


def pila(ic, ys, h, x=7, w=10):
    """Celdas apiladas, una por y inicial, todas de la misma anchura: la pila de una celda."""
    for y0 in ys:
        ic.rect(x, y0, w, h, relleno=True)
    return ic


def hoja_d(x, y, w, h, c, lado='der', r=None):
    """Ruta de la hoja de los archivos: rectángulo con la esquina superior cortada en diagonal (c, el doblez)
    del lado `lado`, esquinas R_HOJA, puntos en sentido horario."""
    if r is None:
        r = R_HOJA
    if lado == 'der':
        pts = [(x, y), (x + w - c, y), (x + w, y + c), (x + w, y + h), (x, y + h)]
    else:
        pts = [(x + c, y), (x + w, y), (x + w, y + h), (x, y + h), (x, y + c)]
    return poli_redondeado_d(pts, r)


def hoja(ic, x, y, w, h, c, lado='der'):
    return ic.ruta(hoja_d(x, y, w, h, c, lado), relleno=True)


def columna_casco(ic, x, y, w, h, R, lado='izq'):
    """Celda de bodega calada: tres esquinas de celda y la esquina inferior de fuera con la curva del casco."""
    r = R_CELDA * min(w, h)
    f = lambda v: f'{v:.3f}'
    if lado == 'izq':
        d = (f'M{f(x+r)} {f(y)}H{f(x+w-r)}A{f(r)} {f(r)} 0 0 1 {f(x+w)} {f(y+r)}V{f(y+h-r)}'
             f'A{f(r)} {f(r)} 0 0 1 {f(x+w-r)} {f(y+h)}H{f(x+R)}A{f(R)} {f(R)} 0 0 1 {f(x)} {f(y+h-R)}'
             f'V{f(y+r)}A{f(r)} {f(r)} 0 0 1 {f(x+r)} {f(y)}Z')
    else:
        d = (f'M{f(x+r)} {f(y)}H{f(x+w-r)}A{f(r)} {f(r)} 0 0 1 {f(x+w)} {f(y+r)}V{f(y+h-R)}'
             f'A{f(R)} {f(R)} 0 0 1 {f(x+w-R)} {f(y+h)}H{f(x+r)}A{f(r)} {f(r)} 0 0 1 {f(x)} {f(y+h-r)}'
             f'V{f(y+r)}A{f(r)} {f(r)} 0 0 1 {f(x+r)} {f(y)}Z')
    return ic.ruta(d, calado=True)
