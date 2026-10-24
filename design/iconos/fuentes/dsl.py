"""Mini-lenguaje de dibujo para los íconos de BayStream (rejilla de 24, margen de 2, trazo de 1.75).

Cada ícono se describe con primitivas sencillas. El SVG resultante usa un solo color
(`currentColor`): la app lo tiñe. Las primitivas guardan su geometría para poder convertir
los trazos en contornos (fuente TTF) y exportar JSON más adelante.

Uso típico:

    from dsl import Icono, R_CELDA
    ic = Icono('contenedor_40')
    ic.rect(2.875, 7, 18.25, 10)            # caja (el radio por defecto repite la proporción de la celda)
    ic.linea(8, 9.5, 8, 14.5)               # corrugado
    ICONOS = {'contenedor_40': ic}

Coordenadas: rejilla de 24 × 24, con margen de 2. La tinta visible tiene que quedar dentro de
[2, 22]. Un trazo de 1.75 ocupa 0.875 a cada lado de su eje, así que el eje de un trazo que
toca el margen va en 2.875 o en 21.125. Para relleno sólido, el borde de la forma va en 2 o 22.

Primitivas (todas devuelven el propio Icono, para encadenar):
    linea(x1, y1, x2, y2)
    poli(puntos, cerrar=False, relleno=False)          puntos = [(x, y), ...]
    rect(x, y, w, h, r=None, relleno=False)            r por defecto = R_CELDA * min(w, h)
    circulo(cx, cy, r, relleno=False)
    arco(cx, cy, r, a0, a1)                             grados; 0 = derecha, 90 = abajo (sentido horario en pantalla)
    ruta(d, relleno=False, evenodd=False)               datos de ruta SVG, absolutos: M L H V C Q A Z
    punto(cx, cy)                                        un punto redondo del grosor del trazo (línea de longitud 0)

`relleno=True` pinta la forma maciza con currentColor y sin trazo. Sin relleno, solo se traza.
`calado=True` (en rect, circulo, poli y ruta) RESTA esa forma de todo lo macizo: así se abren huecos
en un estilo sólido (p. ej. las ventanas de un contenedor relleno). Todo lo macizo sale como un único
contorno (unión de rellenos menos calados), listo para la fuente.
Opcional: cualquier primitiva acepta `grosor=` para un trazo distinto (p. ej. 1.25 en un detalle fino);
úsalo con moderación, la regla general es 1.75.
"""
from __future__ import annotations
import math

R_CELDA = 1.9 / 11          # proporción radio/lado de las celdas del ícono de BayStream (≈ 0.173)
REJILLA = 24
MARGEN = 2
TRAZO = 1.75


def _f(v: float) -> str:
    s = f'{v:.3f}'.rstrip('0').rstrip('.')
    return '0' if s in ('-0', '') else s


class Icono:
    def __init__(self, nombre: str, trazo: float = TRAZO):
        self.nombre = nombre
        self.trazo = trazo
        self.formas: list[dict] = []

    # ---------------------------------------------------------------- primitivas
    def linea(self, x1, y1, x2, y2, grosor=None):
        self.formas.append({'tipo': 'linea', 'p': [(x1, y1), (x2, y2)], 'relleno': False, 'grosor': grosor})
        return self

    def punto(self, cx, cy, grosor=None):
        self.formas.append({'tipo': 'linea', 'p': [(cx, cy), (cx, cy)], 'relleno': False, 'grosor': grosor})
        return self

    def poli(self, puntos, cerrar=False, relleno=False, grosor=None, calado=False):
        self.formas.append({'tipo': 'poli', 'p': [tuple(p) for p in puntos], 'cerrar': cerrar or relleno or calado,
                            'relleno': relleno or calado, 'calado': calado, 'grosor': grosor})
        return self

    def rect(self, x, y, w, h, r=None, relleno=False, grosor=None, calado=False):
        if r is None:
            r = R_CELDA * min(w, h)
        r = max(0.0, min(r, w / 2, h / 2))
        self.formas.append({'tipo': 'rect', 'x': x, 'y': y, 'w': w, 'h': h, 'r': r, 'relleno': relleno or calado,
                            'calado': calado, 'grosor': grosor})
        return self

    def circulo(self, cx, cy, r, relleno=False, grosor=None, calado=False):
        self.formas.append({'tipo': 'circulo', 'cx': cx, 'cy': cy, 'r': r, 'relleno': relleno or calado,
                            'calado': calado, 'grosor': grosor})
        return self

    def arco(self, cx, cy, r, a0, a1, grosor=None):
        """Arco trazado desde el ángulo a0 hasta a1 (grados, sentido horario en pantalla)."""
        self.formas.append({'tipo': 'arco', 'cx': cx, 'cy': cy, 'r': r, 'a0': a0, 'a1': a1, 'relleno': False, 'grosor': grosor})
        return self

    def ruta(self, d: str, relleno=False, evenodd=False, grosor=None, calado=False):
        self.formas.append({'tipo': 'ruta', 'd': d.strip(), 'relleno': relleno or calado, 'calado': calado,
                            'evenodd': evenodd, 'grosor': grosor})
        return self

    # ---------------------------------------------------------------- salida
    def _d(self, f) -> str:
        t = f['tipo']
        if t == 'linea':
            (x1, y1), (x2, y2) = f['p']
            return f'M{_f(x1)} {_f(y1)}L{_f(x2)} {_f(y2)}'
        if t == 'poli':
            pts = f['p']
            d = 'M' + 'L'.join(f'{_f(x)} {_f(y)}' for x, y in pts)
            return d + ('Z' if f['cerrar'] else '')
        if t == 'rect':
            x, y, w, h, r = f['x'], f['y'], f['w'], f['h'], f['r']
            if r <= 0:
                return f'M{_f(x)} {_f(y)}H{_f(x+w)}V{_f(y+h)}H{_f(x)}Z'
            return (f'M{_f(x+r)} {_f(y)}H{_f(x+w-r)}A{_f(r)} {_f(r)} 0 0 1 {_f(x+w)} {_f(y+r)}'
                    f'V{_f(y+h-r)}A{_f(r)} {_f(r)} 0 0 1 {_f(x+w-r)} {_f(y+h)}H{_f(x+r)}'
                    f'A{_f(r)} {_f(r)} 0 0 1 {_f(x)} {_f(y+h-r)}V{_f(y+r)}A{_f(r)} {_f(r)} 0 0 1 {_f(x+r)} {_f(y)}Z')
        if t == 'circulo':
            cx, cy, r = f['cx'], f['cy'], f['r']
            return (f'M{_f(cx+r)} {_f(cy)}A{_f(r)} {_f(r)} 0 1 1 {_f(cx-r)} {_f(cy)}'
                    f'A{_f(r)} {_f(r)} 0 1 1 {_f(cx+r)} {_f(cy)}Z')
        if t == 'arco':
            cx, cy, r, a0, a1 = f['cx'], f['cy'], f['r'], f['a0'], f['a1']
            x0, y0 = cx + r * math.cos(math.radians(a0)), cy + r * math.sin(math.radians(a0))
            x1, y1 = cx + r * math.cos(math.radians(a1)), cy + r * math.sin(math.radians(a1))
            barrido = (a1 - a0) % 360
            grande = 1 if barrido > 180 else 0
            return f'M{_f(x0)} {_f(y0)}A{_f(r)} {_f(r)} 0 {grande} 1 {_f(x1)} {_f(y1)}'
        if t == 'ruta':
            return f['d']
        raise ValueError(t)

    def contorno_solido(self):
        """Contornos (M, L, C, Z) de la parte maciza: unión de los rellenos menos los calados."""
        from geom import analizar_ruta, booleano
        rellenos = [analizar_ruta(self._d(f)) for f in self.formas if f['relleno'] and not f.get('calado')]
        calados = [analizar_ruta(self._d(f)) for f in self.formas if f.get('calado')]
        return booleano(rellenos, calados)

    def elementos(self) -> list[str]:
        from geom import contornos_a_d
        out = []
        solido = self.contorno_solido()
        if solido:
            out.append(f'<path fill="currentColor" stroke="none" d="{contornos_a_d(solido)}"/>')
        for f in self.formas:
            if f['relleno']:
                continue
            d = self._d(f)
            g = f' stroke-width="{_f(f["grosor"])}"' if f.get('grosor') else ''
            out.append(f'<path d="{d}"{g}/>')
        return out

    def svg(self, color: str = 'currentColor', tam: int | None = None, titulo: bool = True) -> str:
        wh = f' width="{tam}" height="{tam}"' if tam else ''
        if color != 'currentColor':
            wh += f' color="{color}"'
        cuerpo = '\n'.join('    ' + e for e in self.elementos())
        t = f'\n  <title>{self.nombre}</title>' if titulo else ''
        if all(f['relleno'] for f in self.formas):          # todo macizo: sin atributos de trazo
            g = f'<g fill="{color}">'
            cuerpo = cuerpo.replace(' fill="currentColor" stroke="none"', '')
        else:
            g = (f'<g fill="none" stroke="{color}" stroke-width="{_f(self.trazo)}" '
                 f'stroke-linecap="round" stroke-linejoin="round">')
        return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {REJILLA} {REJILLA}"{wh}>{t}\n'
                f'  {g}\n{cuerpo}\n  </g>\n</svg>\n')


def cargar(ruta: str) -> dict:
    """Importa un archivo .py y devuelve su diccionario ICONOS (nombre → Icono)."""
    import importlib.util, sys, os
    aqui = os.path.dirname(os.path.abspath(__file__))
    if aqui not in sys.path:
        sys.path.insert(0, aqui)
    spec = importlib.util.spec_from_file_location('iconos_mod_' + str(abs(hash(ruta))), ruta)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.ICONOS
