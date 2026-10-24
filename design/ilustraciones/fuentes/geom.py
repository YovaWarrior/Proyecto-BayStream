"""Geometría compartida: arcos → cúbicas, análisis de rutas SVG absolutas, y booleanos con skia-pathops.

- `arco_a_cubicas(cx, cy, r, a0, a1)` → lista de (p1, p2, p3) cúbicas (el punto inicial es el final anterior).
- `analizar_ruta(d)` → lista de contornos; cada contorno es una lista de segmentos ('L', (x, y)) o
  ('C', (x1, y1), (x2, y2), (x, y)), más un primer ('M', (x, y)) y opcionalmente ('Z',). Acepta M L H V C Q A Z
  en mayúsculas (absolutas) y también sus minúsculas relativas, por si acaso. Las Q se elevan a C y las A se
  convierten en C.
- `a_pathops(contornos)` → pathops.Path;  `desde_pathops(path)` → contornos (solo M, L, C, Z).
- `contornos_a_d(contornos)` → cadena d con M, L, C y Z absolutos.
"""
from __future__ import annotations
import math, re

K = 4 / 3 * math.tan(math.pi / 8)   # 0.5523, cúbica para un cuarto de círculo


def _f(v):
    s = f'{v:.3f}'.rstrip('0').rstrip('.')
    return '0' if s in ('-0', '') else s


def arco_a_cubicas(cx, cy, r, a0, a1, horario=True):
    """Arco de a0 a a1 (grados, sentido horario en pantalla si horario) partido en cúbicas de ≤ 90°."""
    a0r, a1r = math.radians(a0), math.radians(a1)
    barrido = (a1r - a0r) % (2 * math.pi) if horario else -((a0r - a1r) % (2 * math.pi))
    if abs(barrido) < 1e-9:
        barrido = 2 * math.pi if horario else -2 * math.pi
    n = max(1, int(math.ceil(abs(barrido) / (math.pi / 2) - 1e-9)))
    paso = barrido / n
    out = []
    t = a0r
    for _ in range(n):
        k = 4 / 3 * math.tan(paso / 4)
        c, s = math.cos(t), math.sin(t)
        c2, s2 = math.cos(t + paso), math.sin(t + paso)
        p1 = (cx + r * (c - k * s), cy + r * (s + k * c))
        p2 = (cx + r * (c2 + k * s2), cy + r * (s2 - k * c2))
        p3 = (cx + r * c2, cy + r * s2)
        out.append((p1, p2, p3))
        t += paso
    return out


def _arco_endpoint_a_cubicas(p0, rx, ry, phi, grande, barrido, p1):
    """Arco SVG (parametrización por extremos) → cúbicas. Implementación de la nota F.6.5 de SVG 1.1."""
    x1, y1 = p0; x2, y2 = p1
    if (x1, y1) == (x2, y2):
        return []
    rx, ry = abs(rx), abs(ry)
    if rx == 0 or ry == 0:
        return [((x1, y1), (x2, y2), (x2, y2))]
    phi = math.radians(phi); cp, sp = math.cos(phi), math.sin(phi)
    dx, dy = (x1 - x2) / 2, (y1 - y2) / 2
    x1p, y1p = cp * dx + sp * dy, -sp * dx + cp * dy
    lam = (x1p / rx) ** 2 + (y1p / ry) ** 2
    if lam > 1:
        rx, ry = rx * math.sqrt(lam), ry * math.sqrt(lam)
    num = rx**2 * ry**2 - rx**2 * y1p**2 - ry**2 * x1p**2
    den = rx**2 * y1p**2 + ry**2 * x1p**2
    coef = math.sqrt(max(0, num / den)) if den else 0
    if grande == barrido:
        coef = -coef
    cxp, cyp = coef * rx * y1p / ry, -coef * ry * x1p / rx
    cx = cp * cxp - sp * cyp + (x1 + x2) / 2
    cy = sp * cxp + cp * cyp + (y1 + y2) / 2
    def ang(ux, uy, vx, vy):
        d = math.atan2(ux * vy - uy * vx, ux * vx + uy * vy)
        return d
    t1 = ang(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
    dt = ang((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
    if not barrido and dt > 0:
        dt -= 2 * math.pi
    elif barrido and dt < 0:
        dt += 2 * math.pi
    n = max(1, int(math.ceil(abs(dt) / (math.pi / 2) - 1e-9)))
    paso = dt / n
    out = []
    t = t1
    for _ in range(n):
        k = 4 / 3 * math.tan(paso / 4)
        def pt(a, kx=0, ky=0):
            ex, ey = math.cos(a), math.sin(a)
            # punto sobre la elipse (con derivada escalada para los controles)
            return (cx + rx * cp * ex - ry * sp * ey, cy + rx * sp * ex + ry * cp * ey)
        c1x, c1y = math.cos(t), math.sin(t)
        c2x, c2y = math.cos(t + paso), math.sin(t + paso)
        # derivadas en el espacio unitario, rotadas y escaladas
        d1 = (-c1y, c1x); d2 = (-c2y, c2x)
        def tr(ux, uy):
            return (rx * cp * ux - ry * sp * uy, rx * sp * ux + ry * cp * uy)
        p_ini = pt(t); p_fin = pt(t + paso)
        v1 = tr(*d1); v2 = tr(*d2)
        q1 = (p_ini[0] + k * v1[0], p_ini[1] + k * v1[1])
        q2 = (p_fin[0] - k * v2[0], p_fin[1] - k * v2[1])
        out.append((q1, q2, p_fin))
        t += paso
    return out


_TOKEN = re.compile(r'[MmLlHhVvCcQqAaZz]|-?\d*\.?\d+(?:[eE][-+]?\d+)?')


def analizar_ruta(d: str):
    toks = _TOKEN.findall(d)
    i = 0
    contornos = []
    actual = None
    cmd = None
    pos = (0.0, 0.0); inicio = (0.0, 0.0)
    ult_ctrl = None; ult_cmd = None

    def num():
        nonlocal i
        v = float(toks[i]); i += 1; return v

    while i < len(toks):
        t = toks[i]
        if re.match(r'[A-Za-z]', t):
            cmd = t; i += 1
            if cmd in 'Zz':
                if actual is not None:
                    actual.append(('Z',))
                    pos = inicio
                    actual = None
                continue
        rel = cmd.islower()
        c = cmd.upper()
        if c == 'M':
            x, y = num(), num()
            if rel: x, y = pos[0] + x, pos[1] + y
            actual = [('M', (x, y))]; contornos.append(actual); pos = inicio = (x, y)
            cmd = 'l' if rel else 'L'
        elif c == 'L':
            x, y = num(), num()
            if rel: x, y = pos[0] + x, pos[1] + y
            actual.append(('L', (x, y))); pos = (x, y)
        elif c == 'H':
            x = num(); x = pos[0] + x if rel else x
            actual.append(('L', (x, pos[1]))); pos = (x, pos[1])
        elif c == 'V':
            y = num(); y = pos[1] + y if rel else y
            actual.append(('L', (pos[0], y))); pos = (pos[0], y)
        elif c == 'C':
            x1, y1, x2, y2, x, y = (num() for _ in range(6))
            if rel:
                x1, y1, x2, y2, x, y = pos[0]+x1, pos[1]+y1, pos[0]+x2, pos[1]+y2, pos[0]+x, pos[1]+y
            actual.append(('C', (x1, y1), (x2, y2), (x, y))); pos = (x, y)
        elif c == 'Q':
            qx, qy, x, y = (num() for _ in range(4))
            if rel:
                qx, qy, x, y = pos[0]+qx, pos[1]+qy, pos[0]+x, pos[1]+y
            c1 = (pos[0] + 2/3 * (qx - pos[0]), pos[1] + 2/3 * (qy - pos[1]))
            c2 = (x + 2/3 * (qx - x), y + 2/3 * (qy - y))
            actual.append(('C', c1, c2, (x, y))); pos = (x, y)
        elif c == 'A':
            rx, ry, phi, grande, barrido, x, y = (num() for _ in range(7))
            if rel: x, y = pos[0] + x, pos[1] + y
            for p1, p2, p3 in _arco_endpoint_a_cubicas(pos, rx, ry, phi, int(grande), int(barrido), (x, y)):
                actual.append(('C', p1, p2, p3))
            pos = (x, y)
        else:
            raise ValueError(f'comando no admitido: {cmd}')
    return contornos


def contornos_a_d(contornos) -> str:
    partes = []
    for cont in contornos:
        for seg in cont:
            if seg[0] == 'M':
                partes.append(f'M{_f(seg[1][0])} {_f(seg[1][1])}')
            elif seg[0] == 'L':
                partes.append(f'L{_f(seg[1][0])} {_f(seg[1][1])}')
            elif seg[0] == 'C':
                (a, b), (c, d), (e, g) = seg[1], seg[2], seg[3]
                partes.append(f'C{_f(a)} {_f(b)} {_f(c)} {_f(d)} {_f(e)} {_f(g)}')
            elif seg[0] == 'Z':
                partes.append('Z')
    return ''.join(partes)


def a_pathops(contornos):
    import pathops
    p = pathops.Path()
    for cont in contornos:
        for seg in cont:
            if seg[0] == 'M': p.moveTo(*seg[1])
            elif seg[0] == 'L': p.lineTo(*seg[1])
            elif seg[0] == 'C': p.cubicTo(*seg[1], *seg[2], *seg[3])
            elif seg[0] == 'Z': p.close()
    return p


def desde_pathops(path):
    out = []
    actual = None
    for verbo, pts in path.segments:
        if verbo == 'moveTo':
            actual = [('M', tuple(pts[0]))]; out.append(actual)
        elif verbo == 'lineTo':
            actual.append(('L', tuple(pts[0])))
        elif verbo == 'curveTo':
            actual.append(('C', tuple(pts[0]), tuple(pts[1]), tuple(pts[2])))
        elif verbo == 'qCurveTo':
            # TrueType: controles implícitos; elevamos cada cuadrática a cúbica
            p0 = actual[-1][-1] if actual[-1][0] != 'M' else actual[-1][1]
            ctrls = list(pts[:-1]); fin = pts[-1]
            if fin is None:
                fin = ctrls[0]
            puntos = []
            for j, c in enumerate(ctrls):
                if j < len(ctrls) - 1:
                    nxt = ctrls[j + 1]
                    on = ((c[0] + nxt[0]) / 2, (c[1] + nxt[1]) / 2)
                else:
                    on = fin
                puntos.append((c, on))
            for c, on in puntos:
                c1 = (p0[0] + 2/3 * (c[0] - p0[0]), p0[1] + 2/3 * (c[1] - p0[1]))
                c2 = (on[0] + 2/3 * (c[0] - on[0]), on[1] + 2/3 * (c[1] - on[1]))
                actual.append(('C', c1, c2, tuple(on))); p0 = on
        elif verbo == 'closePath':
            actual.append(('Z',))
    return out


def booleano(rellenos, calados):
    """Unión de los rellenos menos la unión de los calados. Devuelve contornos (M, L, C, Z)."""
    import pathops
    if not rellenos:
        return []
    u = pathops.Path()
    pathops.union([a_pathops(c) for c in rellenos], u.getPen())
    if calados:
        r = pathops.Path()
        pathops.difference([u], [a_pathops(c) for c in calados], r.getPen())
        u = r
    return desde_pathops(u)
