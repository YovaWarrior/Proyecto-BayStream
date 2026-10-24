"""Mini-lenguaje para las ilustraciones de BayStream: línea de plano técnico con rellenos planos de la paleta.

Cada forma lleva su relleno y su trazo por NOMBRE de color de la paleta, y la ilustración se emite en
versión clara y oscura. Un color puede ser un nombre (vale para ambos temas) o un par (claro, oscuro).

    from ilus import Ilustracion
    il = Ilustracion('inicio', 640, 400)
    il.rect(40, 300, 560, 60, relleno='marca')                       # la banda del muelle
    il.rect(100, 120, 44, 44, r=7.6, relleno=('hoja', 'panel_alto'), trazo='tinta', grosor=2)
    il.linea(0, 300, 640, 300, trazo='tinta', grosor=3)
    il.poli([(x, y), ...], cerrar=True, relleno='bodega')
    il.rect(..., trazo='tinta_suave', grosor=2, punteado=(4, 4))    # celda vacía, punteada
    ILUSTRACIONES = {'inicio': il}

Nombres de color:
  del ícono (iguales en los dos temas): marca #0D47A1, cubierta #F5F8FC, bodega #6E9DE6, grua #FF7A1A,
      frase #BCD2F7, aviso #F5B83D
  por tema:  fondo, tinta, tinta_suave, linea, hecho, y además
      claro: papel #F5F8FC (= fondo), hoja #FFFFFF
      oscuro: noche #07111F (= fondo), panel #0C1A31, panel_alto #11223F
  Ojo: 'cubierta' (#F5F8FC) es el mismo color que el papel del tema claro: en claro, una celda de
  cubierta se dibuja con relleno 'hoja' y trazo 'tinta' (o par ('hoja', 'cubierta')).

Reglas: sin degradados, sin texto, sin personas, sin buques ni marcas reales; la proa a la izquierda;
el naranja ('grua') solo para lo que se acaba de mover; trazos a 3:1 o más contra el fondo.

Primitivas (devuelven la ilustración, para encadenar):
    rect(x, y, w, h, r=0, relleno=None, trazo=None, grosor=2, punteado=None)
    poli(puntos, cerrar=False, relleno=None, trazo=None, grosor=2, punteado=None)
    linea(x1, y1, x2, y2, trazo='tinta', grosor=2, punteado=None)
    circulo(cx, cy, r, relleno=None, trazo=None, grosor=2)
    arco(cx, cy, r, a0, a1, trazo='tinta', grosor=2)             grados, sentido horario en pantalla
    ruta(d, relleno=None, trazo=None, grosor=2, punteado=None)     ruta SVG absoluta: M L H V C Q A Z
    grupo(nombre)                                                  solo etiqueta la forma siguiente (para el JSON)
"""
from __future__ import annotations
import math

COMUN = {'marca': '#0D47A1', 'cubierta': '#F5F8FC', 'bodega': '#6E9DE6', 'grua': '#FF7A1A',
         'frase': '#BCD2F7', 'aviso': '#F5B83D'}
TEMAS = {
    'claro': {'fondo': '#F5F8FC', 'papel': '#F5F8FC', 'hoja': '#FFFFFF', 'tinta': '#10243F',
              'tinta_suave': '#4A5B73', 'linea': '#C9D3E0', 'hecho': '#1E6B43'},
    'oscuro': {'fondo': '#07111F', 'noche': '#07111F', 'panel': '#0C1A31', 'panel_alto': '#11223F',
               'linea': '#1E3457', 'tinta': '#EAF0F9', 'tinta_suave': '#A9B9D2', 'hecho': '#3DD68C'},
}


def _f(v):
    s = f'{v:.2f}'.rstrip('0').rstrip('.')
    return '0' if s in ('-0', '') else s


def color(nombre, tema: str) -> str:
    if nombre is None:
        return 'none'
    if isinstance(nombre, (tuple, list)):
        nombre = nombre[0] if tema == 'claro' else nombre[1]
        if nombre is None:
            return 'none'
    if nombre in TEMAS[tema]:
        return TEMAS[tema][nombre]
    if nombre in COMUN:
        return COMUN[nombre]
    raise KeyError(f'color desconocido: {nombre!r} (tema {tema})')


class Ilustracion:
    def __init__(self, nombre: str, ancho: int, alto: int):
        self.nombre, self.ancho, self.alto = nombre, ancho, alto
        self.formas: list[dict] = []
        self._grupo = None

    def grupo(self, nombre):
        self._grupo = nombre
        return self

    def _add(self, f):
        f['grupo'] = self._grupo
        self._grupo = None
        self.formas.append(f)
        return self

    def rect(self, x, y, w, h, r=0, relleno=None, trazo=None, grosor=2, punteado=None):
        return self._add({'tipo': 'rect', 'x': x, 'y': y, 'w': w, 'h': h, 'r': max(0, min(r, w / 2, h / 2)),
                          'relleno': relleno, 'trazo': trazo, 'grosor': grosor, 'punteado': punteado})

    def poli(self, puntos, cerrar=False, relleno=None, trazo=None, grosor=2, punteado=None):
        return self._add({'tipo': 'poli', 'p': [tuple(p) for p in puntos], 'cerrar': cerrar or relleno is not None,
                          'relleno': relleno, 'trazo': trazo, 'grosor': grosor, 'punteado': punteado})

    def linea(self, x1, y1, x2, y2, trazo='tinta', grosor=2, punteado=None):
        return self._add({'tipo': 'linea', 'p': [(x1, y1), (x2, y2)], 'relleno': None, 'trazo': trazo,
                          'grosor': grosor, 'punteado': punteado})

    def circulo(self, cx, cy, r, relleno=None, trazo=None, grosor=2):
        return self._add({'tipo': 'circulo', 'cx': cx, 'cy': cy, 'r': r, 'relleno': relleno, 'trazo': trazo,
                          'grosor': grosor, 'punteado': None})

    def arco(self, cx, cy, r, a0, a1, trazo='tinta', grosor=2):
        return self._add({'tipo': 'arco', 'cx': cx, 'cy': cy, 'r': r, 'a0': a0, 'a1': a1, 'relleno': None,
                          'trazo': trazo, 'grosor': grosor, 'punteado': None})

    def ruta(self, d, relleno=None, trazo=None, grosor=2, punteado=None):
        return self._add({'tipo': 'ruta', 'd': d.strip(), 'relleno': relleno, 'trazo': trazo, 'grosor': grosor,
                          'punteado': punteado})

    # ---------------------------------------------------------------- salida
    def _d(self, f):
        t = f['tipo']
        if t == 'linea':
            (x1, y1), (x2, y2) = f['p']
            return f'M{_f(x1)} {_f(y1)}L{_f(x2)} {_f(y2)}'
        if t == 'poli':
            return 'M' + 'L'.join(f'{_f(x)} {_f(y)}' for x, y in f['p']) + ('Z' if f['cerrar'] else '')
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
            grande = 1 if (a1 - a0) % 360 > 180 else 0
            return f'M{_f(x0)} {_f(y0)}A{_f(r)} {_f(r)} 0 {grande} 1 {_f(x1)} {_f(y1)}'
        if t == 'ruta':
            return f['d']
        raise ValueError(t)

    def svg(self, tema: str = 'claro', fondo: bool = True) -> str:
        partes = []
        if fondo:
            partes.append(f'  <rect width="{self.ancho}" height="{self.alto}" fill="{color("fondo", tema)}"/>')
        for f in self.formas:
            at = [f'd="{self._d(f)}"', f'fill="{color(f["relleno"], tema)}"']
            ct = color(f['trazo'], tema)
            if ct != 'none':
                at.append(f'stroke="{ct}" stroke-width="{_f(f["grosor"])}" '
                          'stroke-linecap="round" stroke-linejoin="round"')
                if f.get('punteado'):
                    at.append('stroke-dasharray="' + ' '.join(_f(v) for v in f['punteado']) + '"')
            if f.get('grupo'):
                at.append(f'data-grupo="{f["grupo"]}"')
            partes.append('  <path ' + ' '.join(at) + '/>')
        return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {self.ancho} {self.alto}" '
                f'width="{self.ancho}" height="{self.alto}">\n  <title>{self.nombre} · {tema}</title>\n'
                + '\n'.join(partes) + '\n</svg>\n')


def cargar(ruta: str) -> dict:
    import importlib.util, sys, os
    aqui = os.path.dirname(os.path.abspath(__file__))
    if aqui not in sys.path:
        sys.path.insert(0, aqui)
    spec = importlib.util.spec_from_file_location('ilus_mod_' + str(abs(hash(ruta))), ruta)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.ILUSTRACIONES
