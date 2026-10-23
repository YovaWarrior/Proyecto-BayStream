"""Construye BayStreamIconos.ttf a partir de los íconos (Icono del DSL) y escribe codigos.json.

Cada glifo ocupa el cuadrado del em, como en Material Icons: unitsPerEm = 1024, ascendente 1024 y
descendente 0, anchura de avance 1024. La rejilla de 24 del ícono se escala al em (1 unidad = 42.667
unidades de fuente; las coordenadas se redondean al entero, un error máximo de 0.5/42.667 = 0.012
unidades de rejilla). Las insignias, dibujadas en la rejilla de 24, se escalan igual: a 12 px ocupan
su cuadrado de 12. Las cúbicas se convierten a cuadráticas (TrueType) con cu2qu, error máximo de 1
unidad de fuente. Los contornos exteriores van en sentido horario (convención TrueType).

En Flutter: IconData(0xE000, fontFamily: 'BayStreamIconos'), con la fuente declarada en pubspec.yaml.
"""
from __future__ import annotations
import json, os, sys
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.recordingPen import RecordingPen
from fontTools.pens.svgPathPen import SVGPathPen

UPEM = 1024
REJILLA = 24
ESCALA = UPEM / REJILLA
FAMILIA = 'BayStreamIconos'
PRIMER_CODIGO = 0xE000
FECHA = 3813350400   # 2024-11-01 00:00:00 UTC en segundos desde 1904 (fija: fuente reproducible)


def _area(cont):
    """Área con signo (shoelace) de un contorno (M, L, C, Z) en coordenadas de fuente (y hacia arriba)."""
    pts = []
    for seg in cont:
        if seg[0] == 'M':
            pts.append(seg[1])
        elif seg[0] == 'L':
            pts.append(seg[1])
        elif seg[0] == 'C':
            pts.append(seg[3])
    a = 0.0
    for i in range(len(pts)):
        x0, y0 = pts[i]; x1, y1 = pts[(i + 1) % len(pts)]
        a += x0 * y1 - x1 * y0
    return a / 2


def _invertir(cont):
    """Recorre el contorno al revés conservando (M, L, C, Z)."""
    segs = [s for s in cont if s[0] != 'Z']
    pts = []   # lista de (punto, controles_que_llevan_a_el)
    actual = segs[0][1]
    pts.append((actual, None))
    for s in segs[1:]:
        if s[0] == 'L':
            pts.append((s[1], None))
        elif s[0] == 'C':
            pts.append((s[3], (s[1], s[2])))
    if pts[-1][0] == pts[0][0] and len(pts) > 1:
        # el último punto repite el primero: su segmento cierra; lo tratamos como cierre
        pass
    out = [('M', pts[-1][0])]
    for i in range(len(pts) - 1, 0, -1):
        p, ctrl = pts[i]
        prev = pts[i - 1][0]
        if ctrl is None:
            out.append(('L', prev))
        else:
            out.append(('C', ctrl[1], ctrl[0], prev))
    out.append(('Z',))
    return out


def _dentro(p, cont):
    """Paridad de cruces (ray casting) del punto p respecto al polígono de los puntos ancla del contorno."""
    pts = [s[1] if s[0] in 'ML' else s[3] for s in cont if s[0] != 'Z']
    x, y = p; dentro = False
    for i in range(len(pts)):
        x0, y0 = pts[i]; x1, y1 = pts[(i + 1) % len(pts)]
        if (y0 > y) != (y1 > y):
            xi = x0 + (y - y0) * (x1 - x0) / (y1 - y0)
            if xi > x:
                dentro = not dentro
    return dentro


def contornos_fuente(contornos):
    """Contornos (M, L, C, Z) de la rejilla de 24 → coordenadas de fuente (y arriba) con la dirección
    TrueType: exteriores horarios (área negativa en y-arriba), agujeros antihorarios."""
    f = []
    for cont in contornos:
        c2 = []
        for seg in cont:
            if seg[0] == 'M' or seg[0] == 'L':
                c2.append((seg[0], (seg[1][0] * ESCALA, (REJILLA - seg[1][1]) * ESCALA)))
            elif seg[0] == 'C':
                c2.append(('C', *[(p[0] * ESCALA, (REJILLA - p[1]) * ESCALA) for p in seg[1:]]))
            else:
                c2.append(('Z',))
        f.append(c2)
    out = []
    for i, cont in enumerate(f):
        p0 = cont[0][1]
        # un contorno es agujero si está dentro de un número impar de los otros
        n = sum(1 for j, otro in enumerate(f) if j != i and _dentro(p0, otro))
        es_agujero = n % 2 == 1
        a = _area(cont)
        horario = a < 0            # en y-arriba, área negativa = horario
        if (not es_agujero and not horario) or (es_agujero and horario):
            cont = _invertir(cont)
        out.append(cont)
    return out


def _dibujar(pen, contornos):
    for cont in contornos:
        for seg in cont:
            if seg[0] == 'M':
                pen.moveTo((round(seg[1][0]), round(seg[1][1])))
            elif seg[0] == 'L':
                pen.lineTo((round(seg[1][0]), round(seg[1][1])))
            elif seg[0] == 'C':
                pen.curveTo(*[(round(p[0]), round(p[1])) for p in seg[1:]])
            elif seg[0] == 'Z':
                pen.closePath()


def construir(iconos: dict, insignias: dict, salida_ttf: str, salida_codigos: str, version: str = '1.0'):
    """iconos: nombre → Icono (31, en el orden de los códigos); insignias: nombre → Icono (4)."""
    nombres = list(iconos) + [f'insignia_{n}' for n in insignias]
    fuentes = list(iconos.values()) + list(insignias.values())
    codigos = {n: PRIMER_CODIGO + i for i, n in enumerate(nombres)}
    orden = ['.notdef'] + nombres
    fb = FontBuilder(UPEM, isTTF=True)
    fb.setupGlyphOrder(orden)
    fb.setupCharacterMap({c: n for n, c in codigos.items()})
    glifos = {}
    pen0 = TTGlyphPen(None)
    glifos['.notdef'] = pen0.glyph()
    contornos_por_nombre = {}
    for n, ic in zip(nombres, fuentes):
        conts = contornos_fuente(ic.contorno_solido())
        contornos_por_nombre[n] = conts
        tt = TTGlyphPen(None)
        pen = Cu2QuPen(tt, max_err=1.0, reverse_direction=False)
        _dibujar(pen, conts)
        glifos[n] = tt.glyph()
    fb.setupGlyf(glifos)
    metricas = {}
    for n in orden:
        g = glifos[n]
        g.recalcBounds(fb.font['glyf']) if hasattr(g, 'recalcBounds') else None
        xmin = getattr(g, 'xMin', 0) if g.numberOfContours else 0
        metricas[n] = (UPEM, xmin)
    fb.setupHorizontalMetrics(metricas)
    fb.setupHorizontalHeader(ascent=UPEM, descent=0)
    fb.setupNameTable({
        'familyName': FAMILIA, 'styleName': 'Regular', 'uniqueFontIdentifier': f'{FAMILIA} {version}',
        'fullName': f'{FAMILIA} Regular', 'version': f'Version {version}', 'psName': f'{FAMILIA}-Regular',
        'copyright': 'BayStream. Iconos del dominio dibujados para el proyecto.',
        'description': 'Iconos del dominio de BayStream en el area de uso privado (U+E000 en adelante). Cada glifo ocupa el cuadrado del em.',
    })
    fb.setupOS2(sTypoAscender=UPEM, sTypoDescender=0, sTypoLineGap=0, usWinAscent=UPEM, usWinDescent=0,
                sxHeight=UPEM // 2, sCapHeight=UPEM, achVendID='BAYS', fsType=0,
                ulUnicodeRange1=0, ulCodePageRange1=0)
    fb.setupPost(keepGlyphNames=True)
    fb.setupMaxp() if hasattr(fb, 'setupMaxp') else None
    head = fb.font['head']
    head.created = FECHA
    head.modified = FECHA
    head.fontRevision = float(version)
    fb.font['OS/2'].usWeightClass = 400
    fb.save(salida_ttf)
    with open(salida_codigos, 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'fontFamily': FAMILIA, 'unitsPerEm': UPEM, 'codigos': {n: f'U+{c:04X}' for n, c in codigos.items()}},
                  f, ensure_ascii=False, indent=2)
        f.write('\n')
    return codigos, contornos_por_nombre


def glifo_a_svg_path(ttf_path: str, nombre: str) -> str:
    """Ruta SVG (en la rejilla de 24, y hacia abajo) del contorno TrueType guardado, para compararlo con el SVG."""
    from fontTools.ttLib import TTFont
    from fontTools.pens.transformPen import TransformPen
    font = TTFont(ttf_path)
    gs = font.getGlyphSet()
    sp = SVGPathPen(gs)
    # fuente (y arriba, 0..1024) → rejilla (y abajo, 0..24): x' = x/E, y' = 24 - y/E
    tp = TransformPen(sp, (1 / ESCALA, 0, 0, -1 / ESCALA, 0, REJILLA))
    gs[nombre].draw(tp)
    return sp.getCommands()
