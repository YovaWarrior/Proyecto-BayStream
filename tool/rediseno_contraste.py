"""Contraste WCAG de las paletas de DESIGN.md (rediseño, Fases 1, 2 y 2 bis).

Calcula la relación de contraste (WCAG 2.x) de cada par texto/fondo y de cada
borde/fondo de la dirección activa, C «Puente de mando» (el día de la Fase 2 y
la noche de 10.14), y de la A como historia; genera las 24 ranuras de «Colorear
por» con la tabla reordenada de 10.14 (ranura → tono a saltos): en claro, los
rellenos suaves e intensos de la Fase 2 (HSL); en la noche, las fichas en OKLCH
(relleno profundo del tono, código y contorno en el tono vivo).

Uso (desde la raíz del repositorio):

    python tool/rediseno_contraste.py            # tablas en Markdown
    python tool/rediseno_contraste.py --json     # lo mismo, en JSON

    python tool/rediseno_contraste.py --dart     # las 24 ranuras como listas de Dart

Termina con código 1 si algún par de texto baja de 4.5:1 o alguno de borde
baja de 3:1. No usa ninguna dependencia fuera de la biblioteca estándar.
"""
from __future__ import annotations

import colorsys
import json
import math
import sys

AA_TEXT = 4.5
AA_LARGE = 3.0
AA_NON_TEXT = 3.0


def _hex_to_rgb(value: str) -> tuple[float, float, float]:
    value = value.lstrip('#')
    return tuple(int(value[i:i + 2], 16) / 255 for i in (0, 2, 4))


def _rgb_to_hex(rgb: tuple[float, float, float]) -> str:
    return '#' + ''.join(f'{round(c * 255):02X}' for c in rgb)


def _linear(c: float) -> float:
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def luminance(value: str) -> float:
    r, g, b = (_linear(c) for c in _hex_to_rgb(value))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a: str, b: str) -> float:
    la, lb = luminance(a), luminance(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


def hsl(h: float, s: float, l: float) -> str:
    return _rgb_to_hex(colorsys.hls_to_rgb(h / 360, l, s))


# ---------------------------------------------------------------------------
# Las direcciones. Los nombres son los de DESIGN.md. La C es la activa (10.14):
# su día es el de la Fase 2 y su noche sale del concepto «Puente de mando».
# La A queda como historia (su oscuro ya no se usa). La B salió en 10.4.
# ---------------------------------------------------------------------------
DIA = {
    'papel': '#F5F8FC', 'hoja': '#FFFFFF', 'hoja alta': '#E9EFF7', 'tinta': '#10243F',
    'tinta suave': '#4A5B73', 'tinta tenue': '#566986', 'linea': '#C9D3E0',
    'linea fuerte': '#6D809F',
    'marca': '#0D47A1', 'sobre marca': '#FFFFFF',
    'marca tenue': '#DCE7F8', 'marca superficie': '#0D47A1',
    'sobre marca superficie': '#FFFFFF', 'sobre marca suave': '#BCD2F7',
    'marca profunda': '#0A3A85',
    'acero': '#6E9DE6', 'acero tenue': '#E3EDFB', 'sobre acero': '#10243F',
    'grua': '#C2410C', 'grua relleno': '#FF7A1A', 'sobre grua': '#10243F',
}
NOCHE = {
    'papel': '#07111F', 'hoja': '#0C1A31', 'hoja alta': '#11223F', 'tinta': '#EAF0F9',
    'tinta suave': '#A9B9D2', 'tinta tenue': '#8DA0BE', 'linea': '#1E3457',
    'linea fuerte': '#5272A6',
    'marca': '#4F8EF7', 'sobre marca': '#07111F',
    'marca tenue': '#0D47A1', 'marca superficie': '#0D47A1',
    'sobre marca superficie': '#FFFFFF', 'sobre marca suave': '#BCD2F7',
    'marca profunda': '#0A3A85',
    'acero': '#6E9DE6', 'acero tenue': '#11213A', 'sobre acero': '#07111F',
    'grua': '#FF9A4D', 'grua relleno': '#FF7A1A', 'sobre grua': '#07111F',
}
DIRECCIONES = {
    'C · Puente de mando': {'claro': DIA, 'oscuro': NOCHE},
    'A · Plano de a bordo (historia)': {
        'oscuro': {
            'papel': '#0B1626', 'hoja': '#13223A', 'hoja alta': '#1B2D4A',
            'tinta': '#E6EEF8', 'tinta suave': '#A9B8CC', 'tinta tenue': '#A9B8CC',
            'linea': '#2E4260', 'linea fuerte': '#6983A3',
            'marca': '#8FB4F2', 'sobre marca': '#0B1626',
            'marca tenue': '#1E3A66', 'marca superficie': '#0D47A1',
            'sobre marca superficie': '#FFFFFF', 'sobre marca suave': '#BCD2F7',
            'marca profunda': '#0A3A85',
            'acero': '#6E9DE6', 'acero tenue': '#1C2F4D', 'sobre acero': '#0B1626',
            'grua': '#FF9A4D', 'grua relleno': '#FF7A1A', 'sobre grua': '#0B1626',
        },
    },
}

# Pares que tienen que cumplir. (texto, fondo, umbral, qué es)
# Regla: «grua relleno» y «acero» son rellenos (llevan texto oscuro encima);
# como borde fino sobre el papel se usa «grua» o «linea fuerte».
PARES = [
    ('tinta', 'papel', AA_TEXT, 'texto sobre el fondo'),
    ('tinta', 'hoja', AA_TEXT, 'texto sobre una hoja'),
    ('tinta', 'hoja alta', AA_TEXT, 'texto sobre la hoja alta (panel alto)'),
    ('tinta suave', 'papel', AA_TEXT, 'texto secundario sobre el fondo'),
    ('tinta suave', 'hoja', AA_TEXT, 'texto secundario sobre una hoja'),
    ('tinta suave', 'hoja alta', AA_TEXT, 'texto secundario sobre la hoja alta'),
    ('tinta tenue', 'papel', AA_TEXT, 'texto terciario sobre el fondo'),
    ('tinta tenue', 'hoja', AA_TEXT, 'texto terciario sobre una hoja'),
    ('tinta tenue', 'hoja alta', AA_TEXT, 'texto terciario sobre la hoja alta'),
    ('marca', 'papel', AA_TEXT, 'texto o icono de marca sobre el fondo'),
    ('marca', 'hoja', AA_TEXT, 'texto o icono de marca sobre una hoja'),
    ('marca', 'hoja alta', AA_TEXT, 'texto o icono de marca sobre la hoja alta'),
    ('sobre marca', 'marca', AA_TEXT, 'texto sobre un botón de marca'),
    ('tinta', 'marca tenue', AA_TEXT, 'texto sobre marca tenue (chip, banda)'),
    ('sobre marca superficie', 'marca superficie', AA_TEXT,
     'texto blanco sobre la marca como superficie (riel activo, banda del muelle)'),
    ('sobre marca suave', 'marca superficie', AA_TEXT,
     'texto secundario sobre la marca como superficie (la frase de la banda)'),
    ('sobre marca superficie', 'marca profunda', AA_TEXT,
     'texto sobre el chip de la nube dentro de la banda'),
    ('tinta', 'acero tenue', AA_TEXT, 'texto sobre bodega tenue'),
    ('sobre grua', 'acero', AA_TEXT, 'texto oscuro sobre relleno de acero (zona de bodega)'),
    ('grua', 'papel', AA_TEXT, 'texto o icono naranja sobre el fondo'),
    ('sobre grua', 'grua relleno', AA_TEXT, 'texto sobre relleno naranja (marca de celda)'),
    ('linea fuerte', 'papel', AA_NON_TEXT, 'borde esencial (celda) sobre el fondo'),
    ('linea fuerte', 'hoja', AA_NON_TEXT, 'borde esencial sobre la hoja (cubierta)'),
    ('linea fuerte', 'hoja alta', AA_NON_TEXT, 'borde esencial sobre la hoja alta'),
    ('linea fuerte', 'acero tenue', AA_NON_TEXT, 'borde esencial sobre el acero tenue (bodega)'),
    ('grua', 'papel', AA_NON_TEXT, 'borde naranja (contorno de celda en movimiento)'),
    ('marca', 'papel', AA_NON_TEXT, 'borde o icono de marca sobre el fondo'),
]

# Roles semánticos compartidos por las dos direcciones: relleno, texto sobre
# el relleno y contorno, en claro y en oscuro. El color nunca va solo: cada
# rol lleva icono o rótulo.
SEMANTICOS = {
    'pendiente (por hacer)': {
        'claro': ('#DCE7F8', '#10243F', '#0D47A1'),
        'oscuro': ('#1E3A66', '#EAF0F9', '#4F8EF7')},
    'hecho': {
        'claro': ('#D3EFDB', '#10243F', '#1E6B43'),
        'oscuro': ('#1D4A33', '#EAF0F9', '#3DD68C')},
    'cancelado': {
        'claro': ('#E4E8EE', '#4A5B73', '#6D809F'),
        'oscuro': ('#2A3850', '#A9B9D2', '#8A9DB8')},
    'revisar (conflicto, aviso)': {
        'claro': ('#FBE7B5', '#10243F', '#8A5A00'),
        'oscuro': ('#5C4300', '#F2F6FB', '#F5B83D')},
    'error': {
        'claro': ('#F9D9D6', '#10243F', '#B3261E'),
        'oscuro': ('#601410', '#F2F6FB', '#F2777A')},
    'peligrosa (IMO)': {
        'claro': ('#F9D9D6', '#10243F', '#B3261E'),
        'oscuro': ('#601410', '#F2F6FB', '#F2777A')},
    'refrigerado': {
        'claro': ('#C4E3EE', '#10243F', '#1F6F8B'),
        'oscuro': ('#1E4A5C', '#F2F6FB', '#7FC6DD')},
    'OOG': {
        'claro': ('#E3C4EE', '#10243F', '#6B2E8A'),
        'oscuro': ('#4A2A5E', '#F2F6FB', '#C9A0DE')},
    'de paso': {
        'claro': ('#F5F8FC', '#4A5B73', '#6D809F'),
        'oscuro': ('#11223F', '#A9B9D2', '#5272A6')},
    'reservado (contorno)': {
        'claro': ('#FFFFFF', '#4A5B73', '#6D809F'),
        'oscuro': ('#0C1A31', '#A9B9D2', '#8A9DB8')},
    'en movimiento': {
        'claro': ('#FF7A1A', '#10243F', '#C2410C'),
        'oscuro': ('#FF7A1A', '#07111F', '#FF9A4D')},
    'cubierta (zona)': {
        'claro': ('#FFFFFF', '#10243F', '#6D809F'),
        'oscuro': ('#0C1A31', '#EAF0F9', '#5272A6')},
    'bodega (zona)': {
        'claro': ('#E3EDFB', '#10243F', '#6D809F'),
        'oscuro': ('#11213A', '#EAF0F9', '#5272A6')},
    'información (banda)': {
        'claro': ('#DCE7F8', '#10243F', '#0D47A1'),
        'oscuro': ('#11223F', '#EAF0F9', '#4F8EF7')},
    # La vista Estado de 10.14: el plano se dibuja como el ícono.
    'por bajar en cubierta': {
        'claro': ('#0D47A1', '#FFFFFF', '#0D47A1'),
        'oscuro': ('#F5F8FC', '#07111F', '#F5F8FC')},
    'por bajar en bodega': {
        'claro': ('#1F5FD6', '#FFFFFF', '#1F5FD6'),
        'oscuro': ('#6E9DE6', '#07111F', '#6E9DE6')},
    'bajado': {
        'claro': ('#D3EFDB', '#10243F', '#1E6B43'),
        'oscuro': ('#07111F', '#3DD68C', '#5272A6')},
    'recién movido': {
        'claro': ('#FF7A1A', '#10243F', '#C2410C'),
        'oscuro': ('#FF7A1A', '#07111F', '#FFB27A')},
}
# Los fondos sobre los que se apoya una celda o un chip: el papel, la hoja de la
# cubierta, la hoja alta y el acero tenue de la bodega (10.7: la prueba compuesta
# encontró que la línea fuerte de antes quedaba en 2.9:1 sobre el acero tenue).
PAPEL = {'claro': ['#F5F8FC', '#FFFFFF', '#E9EFF7', '#E3EDFB'],
         'oscuro': ['#07111F', '#0C1A31', '#11223F', '#11213A']}

# ---------------------------------------------------------------------------
# Paleta categórica para «Colorear por» (destino y tipo de vacío).
# Doce tonos, el mismo tono en claro y en oscuro. En claro (el día de la Fase
# 2), el tono va en HSL a 30° desde 15°; en la noche (10.14), las fichas se
# calculan en OKLCH con los tonos del concepto: relleno profundo del tono y
# código y contorno en el tono vivo.
# ---------------------------------------------------------------------------
TONOS = [15 + 30 * i for i in range(12)]
NOMBRES = ['arcilla', 'ámbar', 'oliva', 'hierba', 'verde mar', 'turquesa',
           'cielo', 'cobalto', 'índigo', 'uva', 'magenta', 'rosa']
# Los tonos OKLCH de las fichas de la noche (grados de matiz, por nombre).
TONOS_OKLCH = [35, 75, 110, 145, 170, 195, 230, 262, 285, 315, 345, 10]

# La tabla reparte los tonos dando saltos (10.14): ranura k → tono
# TONO_DE_RANURA[k mod 12], suave hasta la 11 e intensa desde la 12. Así los
# cinco primeros puertos quedan a 60° o más: JMKIN rosa, USHOU cielo, GTSTC
# hierba, JMKCT uva y PAMIT ámbar. Las tablas de códigos y la ranura de
# reserva (FNV-1a) no cambian.
TONO_DE_RANURA = [11, 6, 3, 9, 1, 8, 4, 0, 10, 5, 2, 7]

# Dos luminosidades por tono (10.4): la «suave» y la «intensa». En claro la
# intensa es un tinte más oscuro (HSL: saturación y luminosidad del relleno y
# del borde). En la noche, OKLCH: (L, C) del relleno y (L, C) del código y el
# contorno; la intensa es un relleno más claro y cromático con el código más
# claro, para separarse de la suave por luminosidad.
LUMINOSIDADES_CLARO = {
    'suave': (0.55, 0.85, 0.60, 0.32),
    'intensa': (0.50, 0.74, 0.60, 0.26),
}
FICHAS_NOCHE = {
    'suave': ((0.34, 0.075), (0.84, 0.12)),
    'intensa': ((0.44, 0.12), (0.93, 0.06)),
}


def _lineal_a_srgb(c: float) -> float:
    c = max(0.0, min(1.0, c))
    return 12.92 * c if c <= 0.0031308 else 1.055 * (c ** (1 / 2.4)) - 0.055


def oklch_a_lineal(l: float, c: float, h: float) -> tuple[float, float, float]:
    """OKLCH → RGB lineal (Björn Ottosson, 2020), sin recortar."""
    a = c * math.cos(math.radians(h))
    b = c * math.sin(math.radians(h))
    l_ = l + 0.3963377774 * a + 0.2158037573 * b
    m_ = l - 0.1055613458 * a - 0.0638541728 * b
    s_ = l - 0.0894841775 * a - 1.2914855480 * b
    l3, m3, s3 = l_ ** 3, m_ ** 3, s_ ** 3
    return (
        4.0767416621 * l3 - 3.3077115913 * m3 + 0.2309699292 * s3,
        -1.2684380046 * l3 + 2.6097574011 * m3 - 0.3413193965 * s3,
        -0.0041960863 * l3 - 0.7034186147 * m3 + 1.7076147010 * s3,
    )


def oklch(l: float, c: float, h: float) -> str:
    """El hexadecimal sRGB de un color OKLCH. Si el color se sale de la gama
    de sRGB, baja el croma de 0.002 en 0.002 hasta que quepa (así el tono y
    la luminosidad se conservan), y recorta lo que quede por redondeo."""
    croma = c
    while croma > 0:
        lineal = oklch_a_lineal(l, croma, h)
        if all(-0.002 <= v <= 1.002 for v in lineal):
            break
        croma -= 0.002
    else:
        lineal = oklch_a_lineal(l, 0, h)
    return '#' + ''.join(f'{round(_lineal_a_srgb(v) * 255):02X}' for v in lineal)

# Tablas fijas confirmadas por Carlos (10.6): solo códigos, en el orden de
# asignación. Ranura k → tono k mod 12, luminosidad «suave» para k < 12 e
# «intensa» después. Los puertos de destino (LOC+11) y los tipos ISO de vacío
# que salen en el corpus; XXVSL salió porque no es un UN/LOCODE. Las ranuras
# 15 a 23 de puertos las asigna la oficina (T-115).
TABLA_PUERTOS = ['JMKIN', 'USHOU', 'GTSTC', 'JMKCT', 'PAMIT', 'COSPC', 'JMKWL',
                 'PACCT', 'GTPBR', 'USPEF', 'PAONX', 'VEPBL', 'VELAG', 'COCTG',
                 'USMSY']
PRIMERA_RANURA_LIBRE_DE_PUERTOS = 15

# La celda atenuada (10.7, H1): el relleno del rol al 35 % sobre el papel, el
# código en tinta suave y el contorno en línea fuerte. Se verifica compuesto,
# como lo dibuja Flutter (Color.alphaBlend, canal a canal en sRGB), igual que
# test/t114_celda_contraste_test.dart.
ALFA_ATENUADA = 0.35
TINTA_SUAVE = {'claro': '#4A5B73', 'oscuro': '#A9B9D2'}
LINEA_FUERTE = {'claro': '#6D809F', 'oscuro': '#5272A6'}
PAPEL_CELDA = {'claro': '#F5F8FC', 'oscuro': '#07111F'}


def compuesto(frente: str, fondo: str, alfa: float) -> str:
    """`frente` al `alfa` sobre `fondo`, canal a canal en sRGB."""
    f, b = _hex_to_rgb(frente), _hex_to_rgb(fondo)
    return _rgb_to_hex(tuple(alfa * fc + (1 - alfa) * bc for fc, bc in zip(f, b)))


TINTA = {'claro': '#10243F', 'oscuro': '#EAF0F9'}


def texto_atenuado(modo: str, relleno: str) -> tuple[str, str]:
    """La tinta del código de una celda atenuada y el relleno compuesto: tinta
    suave, o la tinta si la suave no llega a 4.5:1 sobre lo compuesto (13.2)."""
    fondo = compuesto(relleno, PAPEL_CELDA[modo], ALFA_ATENUADA)
    tinta = TINTA_SUAVE[modo]
    if contrast(tinta, fondo) < AA_TEXT:
        tinta = TINTA[modo]
    return tinta, fondo


def atenuadas(informe: dict) -> list[dict]:
    """El peor contraste de la celda atenuada por modo: el código (tinta suave,
    o tinta si hace falta) sobre el relleno compuesto (4.5) y la línea fuerte
    sobre el papel (3), para las 24 ranuras y los roles semánticos."""
    filas = []
    for modo in ('claro', 'oscuro'):
        rellenos = [f[modo]['relleno'] for f in informe['categorica']]
        rellenos += [s['relleno'] for s in informe['semanticos'] if s['modo'] == modo]
        medidas = []
        con_tinta = 0
        for r in rellenos:
            tinta, fondo = texto_atenuado(modo, r)
            con_tinta += tinta == TINTA[modo]
            medidas.append((contrast(tinta, fondo), r))
        peor = min(medidas, key=lambda par: par[0])
        filas.append({'modo': modo, 'rellenos': len(rellenos), 'con tinta': con_tinta,
                      'peor texto': round(peor[0], 2), 'peor relleno': peor[1],
                      'borde': round(contrast(LINEA_FUERTE[modo], PAPEL_CELDA[modo]), 2)})
    return filas
TABLA_TIPOS = ['45G1', '22G1', '45G0', 'L5G1', '45R1', '42G1', '42U1', '42P3',
               'L5G0', '22K2', '22U1', '22T1', '45R8']


def ranura(k: int) -> dict:
    """Relleno, borde y texto de la ranura k (0..23) en claro y oscuro."""
    tono = TONO_DE_RANURA[k % 12]
    nombre, h = NOMBRES[tono], TONOS[tono]
    lumi = 'suave' if k < 12 else 'intensa'
    fila = {'ranura': k, 'nombre': f'{nombre} {lumi}', 'tono': h,
            'tono oklch': TONOS_OKLCH[tono]}
    s_rel, l_rel, s_bor, l_bor = LUMINOSIDADES_CLARO[lumi]
    relleno, borde = hsl(h, s_rel, l_rel), hsl(h, s_bor, l_bor)
    fila['claro'] = {'relleno': relleno, 'borde': borde, 'texto': '#10243F',
                     'contraste texto': round(contrast('#10243F', relleno), 2),
                     'contraste borde': round(contrast(borde, '#F5F8FC'), 2)}
    (l_f, c_f), (l_t, c_t) = FICHAS_NOCHE[lumi]
    relleno = oklch(l_f, c_f, TONOS_OKLCH[tono])
    vivo = oklch(l_t, c_t, TONOS_OKLCH[tono])
    # En la noche, el código y el contorno son el mismo tono vivo (10.14).
    fila['oscuro'] = {'relleno': relleno, 'borde': vivo, 'texto': vivo,
                      'contraste texto': round(contrast(vivo, relleno), 2),
                      'contraste borde': round(
                          min(contrast(vivo, p) for p in PAPEL['oscuro']), 2)}
    return fila


def categorica() -> list[dict]:
    return [ranura(k) for k in range(24)]


def fnv1a(codigo: str) -> int:
    """FNV-1a de 32 bits sobre el código en mayúsculas, como en Dart."""
    h = 0x811C9DC5
    for byte in codigo.upper().encode('utf-8'):
        h = ((h ^ byte) * 0x01000193) & 0xFFFFFFFF
    return h


def tabla(codigos: list[str]) -> list[tuple[str, int]]:
    return [(codigo, k) for k, codigo in enumerate(codigos)]


def escala_secuencial(base: str = '#0D47A1', pasos: int = 5) -> list[str]:
    """Escala monocromática para Estadísticas: del papel a la marca."""
    r, g, b = _hex_to_rgb(base)
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    return [hsl(h * 360, s, 0.92 - i * (0.92 - l) / (pasos - 1)) for i in range(pasos)]


def dart(informe: dict) -> None:
    """Las 24 ranuras como las dos listas de bs_colores_semanticos.dart."""
    for modo, nombre in (('claro', '_categoricosClaro'), ('oscuro', '_categoricosOscuro')):
        print(f'const List<BsRol> {nombre} = <BsRol>[')
        for f in informe['categorica']:
            c = f[modo]
            texto = '_tintaClara' if modo == 'claro' else f"Color(0xFF{c['texto'][1:]})"
            print(f"  // {f['ranura']}: {f['nombre']}")
            print(f"  BsRol(relleno: Color(0xFF{c['relleno'][1:]}), texto: {texto}, "
                  f"contorno: Color(0xFF{c['borde'][1:]})),")
        print('];')


def main() -> int:
    salida_json = '--json' in sys.argv
    fallos = 0
    informe: dict = {'direcciones': {}, 'categorica': categorica(),
                     'secuencial': escala_secuencial()}
    if '--dart' in sys.argv:
        dart(informe)
        return 0
    for direccion, modos in DIRECCIONES.items():
        informe['direcciones'][direccion] = {}
        for modo, tokens in modos.items():
            filas = []
            for texto, fondo, umbral, que in PARES:
                ratio = contrast(tokens[texto], tokens[fondo])
                ok = ratio >= umbral
                fallos += 0 if ok else 1
                filas.append({'par': f'{texto} / {fondo}', 'que': que,
                              'hex': f'{tokens[texto]} / {tokens[fondo]}',
                              'contraste': round(ratio, 2), 'umbral': umbral,
                              'cumple': ok})
            informe['direcciones'][direccion][modo] = {'tokens': tokens, 'pares': filas}
    for fila in informe['categorica']:
        for modo in ('claro', 'oscuro'):
            if fila[modo]['contraste texto'] < AA_TEXT:
                fallos += 1
            if fila[modo]['contraste borde'] < AA_NON_TEXT:
                fallos += 1
    semanticos = []
    for rol, modos in SEMANTICOS.items():
        for modo, (relleno, texto, borde) in modos.items():
            texto_ratio = contrast(texto, relleno)
            borde_ratio = min(contrast(borde, papel) for papel in PAPEL[modo])
            ok = texto_ratio >= AA_TEXT and borde_ratio >= AA_NON_TEXT
            fallos += 0 if ok else 1
            semanticos.append({'rol': rol, 'modo': modo, 'relleno': relleno,
                               'texto': texto, 'borde': borde,
                               'contraste texto': round(texto_ratio, 2),
                               'contraste borde': round(borde_ratio, 2),
                               'cumple': ok})
    informe['semanticos'] = semanticos

    if salida_json:
        print(json.dumps(informe, ensure_ascii=False, indent=2))
        return 1 if fallos else 0

    for direccion, modos in informe['direcciones'].items():
        for modo, datos in modos.items():
            print(f'\n### {direccion} · modo {modo}\n')
            print('| Par | Qué | Hex | Contraste | Umbral | Cumple |')
            print('|---|---|---|---:|---:|---|')
            for f in datos['pares']:
                print(f"| {f['par']} | {f['que']} | {f['hex']} | {f['contraste']:.2f} | "
                      f"{f['umbral']} | {'sí' if f['cumple'] else '**no**'} |")
    print('\n### Paleta categórica «Colorear por»: 24 ranuras (12 tonos × 2 luminosidades), '
          'tabla reordenada (10.14)\n')
    print('Ranura k → tono [11, 6, 3, 9, 1, 8, 4, 0, 10, 5, 2, 7][k mod 12]. En claro, HSL '
          '(el día de la Fase 2); en la noche, fichas OKLCH: relleno L 0.34 C 0.075 y código y '
          'contorno L 0.84 C 0.12 (suaves); relleno L 0.44 C 0.12 y código y contorno L 0.93 '
          'C 0.06 (intensas). El contorno se mide contra el peor de los fondos del modo.\n')
    print('| Ranura | Tono (HSL / OKLCH) | Claro: relleno / borde | Texto sobre relleno | '
          'Borde sobre papel | Noche: relleno / código y contorno | Código sobre relleno | '
          'Contorno sobre fondos |')
    print('|---:|---|---|---:|---:|---|---:|---:|')
    for f in informe['categorica']:
        c, o = f['claro'], f['oscuro']
        print(f"| {f['ranura']} | {f['nombre']} ({f['tono']}° / {f['tono oklch']}°) | "
              f"{c['relleno']} / {c['borde']} | "
              f"{c['contraste texto']:.2f} | {c['contraste borde']:.2f} | "
              f"{o['relleno']} / {o['borde']} | {o['contraste texto']:.2f} | "
              f"{o['contraste borde']:.2f} |")
    print('\n### Tabla fija confirmada (10.6): puertos de destino, ranuras 0 a 14\n')
    print('| Código | Ranura | Tono |')
    print('|---|---:|---|')
    for codigo, k in tabla(TABLA_PUERTOS):
        print(f'| {codigo} | {k} | {informe["categorica"][k]["nombre"]} |')
    print(f'\nRanuras {PRIMERA_RANURA_LIBRE_DE_PUERTOS} a 23: libres, las asigna la oficina (T-115).')
    print('\n### Tabla fija confirmada (10.6): tipos ISO de vacío, ranuras 0 a 12\n')
    print('| Código | Ranura | Tono |')
    print('|---|---:|---|')
    for codigo, k in tabla(TABLA_TIPOS):
        print(f'| {codigo} | {k} | {informe["categorica"][k]["nombre"]} |')
    print('\n### Códigos fuera de la tabla: ranura = FNV-1a(código) mod 24\n')
    for codigo in ['MXVER', 'PABLB', '22P1']:
        print(f'- {codigo} → ranura {fnv1a(codigo) % 24} ({informe["categorica"][fnv1a(codigo) % 24]["nombre"]})')
    print('\n### Roles semánticos (relleno / texto sobre el relleno / contorno)\n')
    print('| Rol | Modo | Relleno | Texto | Contorno | Texto sobre relleno | '
          'Contorno sobre papel (peor caso) | Cumple |')
    print('|---|---|---|---|---|---:|---:|---|')
    for s in informe['semanticos']:
        print(f"| {s['rol']} | {s['modo']} | {s['relleno']} | {s['texto']} | {s['borde']} | "
              f"{s['contraste texto']:.2f} | {s['contraste borde']:.2f} | "
              f"{'sí' if s['cumple'] else '**no**'} |")
    print('\n### Celda atenuada (10.7 y 13.2): relleno al 35 % sobre el papel, código en tinta suave '
          '(o en tinta si la suave no llega a 4.5:1), contorno en línea fuerte\n')
    print('| Modo | Rellenos probados | Con el código en tinta | Peor código sobre el relleno compuesto | '
          'Con el relleno | Línea fuerte sobre papel | Cumple |')
    print('|---|---:|---:|---:|---|---:|---|')
    informe['atenuadas'] = atenuadas(informe)
    for a in informe['atenuadas']:
        cumple = a['peor texto'] >= AA_TEXT and a['borde'] >= AA_NON_TEXT
        if not cumple:
            fallos += 1
        print(f"| {a['modo']} | {a['rellenos']} | {a['con tinta']} | {a['peor texto']:.2f} | "
              f"{a['peor relleno']} | {a['borde']:.2f} | {'sí' if cumple else '**no**'} |")
    print('\n### Escala secuencial para Estadísticas (del papel a la marca)\n')
    print(' → '.join(informe['secuencial']))
    print(f'\nPares que no cumplen: {fallos}')
    return 1 if fallos else 0


if __name__ == '__main__':
    sys.exit(main())
