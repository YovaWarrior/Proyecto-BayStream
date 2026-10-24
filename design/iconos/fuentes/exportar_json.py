"""Exporta una ilustración (Ilustracion del DSL) al JSON de trazos que la app pinta con su propio código,
y comprueba que ese JSON reproduce el SVG.

Formato (`<nombre>.json`):
{
  "nombre": "inicio", "ancho": 640, "alto": 400,
  "paleta": { "claro": {nombre: "#RRGGBB", …}, "oscuro": {…} },   # todos los nombres usados, ya resueltos por tema
  "fondo": "fondo",                                              # nombre de color del fondo
  "formas": [
    { "grupo": "muelle", "ruta": "M0 256L345 256L345 306L0 306Z",   # absoluta, solo M L C Z
      "relleno": "marca",            # nombre, o {"claro": "hoja", "oscuro": "cubierta"}, o null
      "trazo": null,                 # nombre, o {"claro": …, "oscuro": …}, o null
      "grosor": 2,                   # ancho del trazo (0 si no hay trazo)
      "punteado": [6, 4] }           # opcional: patrón de guiones del trazo
  ]
}
Los trazos llevan puntas y uniones redondas. Las formas se pintan en orden, después del fondo.
"""
from __future__ import annotations
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from ilus import color, TEMAS, COMUN, Ilustracion
from geom import analizar_ruta, contornos_a_d


def _nombre_color(c):
    if c is None:
        return None
    if isinstance(c, (tuple, list)):
        return {'claro': c[0], 'oscuro': c[1]}
    return c


def _nombres_usados(il):
    usados = {'fondo'}
    for f in il.formas:
        for c in (f['relleno'], f['trazo']):
            if isinstance(c, (tuple, list)):
                usados.update(x for x in c if x)
            elif c:
                usados.add(c)
    return usados


def exportar(il: Ilustracion) -> dict:
    usados = _nombres_usados(il)
    paleta = {tema: {n: color(n, tema) for n in sorted(usados) if n in TEMAS[tema] or n in COMUN} for tema in ('claro', 'oscuro')}
    formas = []
    for f in il.formas:
        d = contornos_a_d(analizar_ruta(il._d(f)))
        forma = {'grupo': f.get('grupo'), 'ruta': d, 'relleno': _nombre_color(f['relleno']),
                 'trazo': _nombre_color(f['trazo']), 'grosor': f['grosor'] if f['trazo'] else 0}
        if f.get('punteado'):
            forma['punteado'] = list(f['punteado'])
        formas.append(forma)
    return {'nombre': il.nombre, 'ancho': il.ancho, 'alto': il.alto, 'paleta': paleta, 'fondo': 'fondo', 'formas': formas}


def json_a_svg(datos: dict, tema: str) -> str:
    """Pinta el JSON como lo haría la app (una forma tras otra) para comprobar que no falta nada."""
    pal = datos['paleta'][tema]

    def col(c):
        if c is None:
            return 'none'
        if isinstance(c, dict):
            c = c[tema]
        return pal[c] if c else 'none'
    partes = [f'<rect width="{datos["ancho"]}" height="{datos["alto"]}" fill="{pal[datos["fondo"]]}"/>']
    for f in datos['formas']:
        at = [f'd="{f["ruta"]}"', f'fill="{col(f["relleno"])}"']
        ct = col(f['trazo'])
        if ct != 'none':
            at.append(f'stroke="{ct}" stroke-width="{f["grosor"]}" stroke-linecap="round" stroke-linejoin="round"')
            if f.get('punteado'):
                at.append('stroke-dasharray="' + ' '.join(str(v) for v in f['punteado']) + '"')
        partes.append('<path ' + ' '.join(at) + '/>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {datos["ancho"]} {datos["alto"]}" '
            f'width="{datos["ancho"]}" height="{datos["alto"]}">' + ''.join(partes) + '</svg>')


def comprobar(il: Ilustracion, datos: dict):
    """Rasteriza el SVG del DSL y el SVG reconstruido desde el JSON y mide la diferencia por tema."""
    import io
    from PIL import Image, ImageChops
    import resvg_py
    out = {}
    for tema in ('claro', 'oscuro'):
        a = Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_string=il.svg(tema), width=il.ancho, height=il.alto)))).convert('RGB')
        b = Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_string=json_a_svg(datos, tema), width=il.ancho, height=il.alto)))).convert('RGB')
        diff = ImageChops.difference(a, b).convert('L')
        px = diff.tobytes()
        out[tema] = {'max': max(px), 'distintos': sum(1 for v in px if v >= 32), 'total': len(px)}
    return out


def escribir(il: Ilustracion, ruta: str) -> dict:
    datos = exportar(il)
    with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(datos, f, ensure_ascii=False, indent=1)
        f.write('\n')
    return datos
