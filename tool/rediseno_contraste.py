"""Contraste WCAG de las paletas de DESIGN.md (rediseño, Fase 1).

Calcula la relación de contraste (WCAG 2.x) de cada par texto/fondo y de cada
borde/fondo de las dos direcciones, en claro y en oscuro, y genera la paleta
categórica de 12 tonos para «Colorear por» con sus valores en los dos modos.

Uso (desde la raíz del repositorio):

    python tool/rediseno_contraste.py            # tablas en Markdown
    python tool/rediseno_contraste.py --json     # lo mismo, en JSON

Termina con código 1 si algún par de texto baja de 4.5:1 o alguno de borde
baja de 3:1. No usa ninguna dependencia fuera de la biblioteca estándar.
"""
from __future__ import annotations

import colorsys
import json
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
# Las dos direcciones. Los nombres son los de DESIGN.md.
# ---------------------------------------------------------------------------
DIRECCIONES = {
    'A · Plano de a bordo': {
        'claro': {
            'papel': '#F5F8FC', 'hoja': '#FFFFFF', 'tinta': '#10243F',
            'tinta suave': '#4A5B73', 'linea': '#C9D3E0', 'linea fuerte': '#6D809F',
            'marca': '#0D47A1', 'sobre marca': '#FFFFFF',
            'marca tenue': '#DCE7F8', 'acero': '#6E9DE6', 'acero tenue': '#E3EDFB',
            'grua': '#C2410C', 'grua relleno': '#FF7A1A', 'sobre grua': '#10243F',
        },
        'oscuro': {
            'papel': '#0B1626', 'hoja': '#13223A', 'tinta': '#E6EEF8',
            'tinta suave': '#A9B8CC', 'linea': '#2E4260', 'linea fuerte': '#6983A3',
            'marca': '#8FB4F2', 'sobre marca': '#0B1626',
            'marca tenue': '#1E3A66', 'acero': '#6E9DE6', 'acero tenue': '#1C2F4D',
            'grua': '#FF9A4D', 'grua relleno': '#FF7A1A', 'sobre grua': '#0B1626',
        },
    },
    'B · Consola de muelle': {
        'claro': {
            'papel': '#FFFFFF', 'hoja': '#EDF2FA', 'tinta': '#0A1A33',
            'tinta suave': '#3F5473', 'linea': '#B8C6DA', 'linea fuerte': '#5F7694',
            'marca': '#0D47A1', 'sobre marca': '#FFFFFF',
            'marca tenue': '#D6E3F7', 'acero': '#6E9DE6', 'acero tenue': '#DCE6F5',
            'grua': '#B83D00', 'grua relleno': '#FF7A1A', 'sobre grua': '#0A1A33',
        },
        'oscuro': {
            'papel': '#061120', 'hoja': '#0E1B30', 'tinta': '#F2F6FB',
            'tinta suave': '#B5C3D6', 'linea': '#33476A', 'linea fuerte': '#6B84A8',
            'marca': '#7FAAF0', 'sobre marca': '#061120',
            'marca tenue': '#1B3561', 'acero': '#6E9DE6', 'acero tenue': '#162844',
            'grua': '#FFA366', 'grua relleno': '#FF7A1A', 'sobre grua': '#061120',
        },
    },
}

# Pares que tienen que cumplir. (texto, fondo, umbral, qué es)
# Regla: «grua relleno» y «acero» son rellenos (llevan texto oscuro encima);
# como borde fino sobre el papel se usa «grua» o «linea fuerte».
PARES = [
    ('tinta', 'papel', AA_TEXT, 'texto sobre el fondo'),
    ('tinta', 'hoja', AA_TEXT, 'texto sobre una hoja'),
    ('tinta suave', 'papel', AA_TEXT, 'texto secundario sobre el fondo'),
    ('tinta suave', 'hoja', AA_TEXT, 'texto secundario sobre una hoja'),
    ('marca', 'papel', AA_TEXT, 'texto o icono de marca sobre el fondo'),
    ('sobre marca', 'marca', AA_TEXT, 'texto sobre un botón de marca'),
    ('tinta', 'marca tenue', AA_TEXT, 'texto sobre marca tenue (chip, banda)'),
    ('tinta', 'acero tenue', AA_TEXT, 'texto sobre bodega tenue'),
    ('sobre grua', 'acero', AA_TEXT, 'texto oscuro sobre relleno de acero (zona de bodega)'),
    ('grua', 'papel', AA_TEXT, 'texto o icono naranja sobre el fondo'),
    ('sobre grua', 'grua relleno', AA_TEXT, 'texto sobre relleno naranja (marca de celda)'),
    ('linea fuerte', 'papel', AA_NON_TEXT, 'borde esencial (celda) sobre el fondo'),
    ('linea fuerte', 'hoja', AA_NON_TEXT, 'borde esencial sobre la hoja (cubierta)'),
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
        'oscuro': ('#1E3A66', '#E6EEF8', '#8FB4F2')},
    'hecho': {
        'claro': ('#D3EFDB', '#10243F', '#1E6B43'),
        'oscuro': ('#1D4A33', '#E6EEF8', '#6FCF97')},
    'cancelado': {
        'claro': ('#E4E8EE', '#4A5B73', '#6D809F'),
        'oscuro': ('#2A3850', '#A9B8CC', '#8A9DB8')},
    'revisar (conflicto, aviso)': {
        'claro': ('#FBE7B5', '#10243F', '#8A5A00'),
        'oscuro': ('#5C4300', '#F2F6FB', '#E0B23F')},
    'error': {
        'claro': ('#F9D9D6', '#10243F', '#B3261E'),
        'oscuro': ('#601410', '#F2F6FB', '#F2B8B5')},
    'peligrosa (IMO)': {
        'claro': ('#F9D9D6', '#10243F', '#B3261E'),
        'oscuro': ('#601410', '#F2F6FB', '#F2B8B5')},
    'refrigerado': {
        'claro': ('#C4E3EE', '#10243F', '#1F6F8B'),
        'oscuro': ('#1E4A5C', '#F2F6FB', '#7FC6DD')},
    'OOG': {
        'claro': ('#E3C4EE', '#10243F', '#6B2E8A'),
        'oscuro': ('#4A2A5E', '#F2F6FB', '#C9A0DE')},
    'de paso': {
        'claro': ('#F5F8FC', '#4A5B73', '#6D809F'),
        'oscuro': ('#0B1626', '#A9B8CC', '#6983A3')},
    'reservado (contorno)': {
        'claro': ('#FFFFFF', '#4A5B73', '#6D809F'),
        'oscuro': ('#13223A', '#A9B8CC', '#8A9DB8')},
}
# Los fondos sobre los que se apoya una celda o un chip: el papel, la hoja de la
# cubierta, la hoja alta y el acero tenue de la bodega (10.7: la prueba compuesta
# encontró que la línea fuerte de antes quedaba en 2.9:1 sobre el acero tenue).
PAPEL = {'claro': ['#F5F8FC', '#FFFFFF', '#E9EFF7', '#E3EDFB'],
         'oscuro': ['#0B1626', '#061120', '#13223A', '#1B2D4A', '#1C2F4D']}

# ---------------------------------------------------------------------------
# Paleta categórica para «Colorear por» (destino y tipo de vacío).
# Doce tonos a 30°, el mismo tono en claro y en oscuro; lo que cambia es la
# luminosidad para que el código escrito en la celda lea con contraste AA.
# ---------------------------------------------------------------------------
TONOS = [15 + 30 * i for i in range(12)]
NOMBRES = ['arcilla', 'ámbar', 'oliva', 'hierba', 'verde mar', 'turquesa',
           'cielo', 'cobalto', 'índigo', 'uva', 'magenta', 'rosa']

# Dos luminosidades por tono (10.4): la «suave» y la «intensa». En claro la
# intensa es un tinte más oscuro; en oscuro es una sombra más oscura, porque
# una sombra más clara deja el texto claro por debajo de 4.5:1 en los verdes.
LUMINOSIDADES = {
    'suave': {'claro': (0.55, 0.85, 0.60, 0.32), 'oscuro': (0.45, 0.30, 0.55, 0.68)},
    'intensa': {'claro': (0.50, 0.74, 0.60, 0.26), 'oscuro': (0.45, 0.21, 0.55, 0.76)},
}

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
TINTA_SUAVE = {'claro': '#4A5B73', 'oscuro': '#A9B8CC'}
LINEA_FUERTE = {'claro': '#6D809F', 'oscuro': '#6983A3'}
PAPEL_CELDA = {'claro': '#F5F8FC', 'oscuro': '#0B1626'}


def compuesto(frente: str, fondo: str, alfa: float) -> str:
    """`frente` al `alfa` sobre `fondo`, canal a canal en sRGB."""
    f, b = _hex_to_rgb(frente), _hex_to_rgb(fondo)
    return _rgb_to_hex(tuple(alfa * fc + (1 - alfa) * bc for fc, bc in zip(f, b)))


def atenuadas(informe: dict) -> list[dict]:
    """El peor contraste de la celda atenuada por modo: la tinta suave sobre el
    relleno compuesto (4.5) y la línea fuerte sobre el papel (3), para las 24
    ranuras y los roles semánticos."""
    filas = []
    for modo in ('claro', 'oscuro'):
        rellenos = [f[modo]['relleno'] for f in informe['categorica']]
        rellenos += [s['relleno'] for s in informe['semanticos'] if s['modo'] == modo]
        peor = min(((contrast(TINTA_SUAVE[modo], compuesto(r, PAPEL_CELDA[modo], ALFA_ATENUADA)), r)
                    for r in rellenos), key=lambda par: par[0])
        filas.append({'modo': modo, 'rellenos': len(rellenos),
                      'peor texto': round(peor[0], 2), 'peor relleno': peor[1],
                      'borde': round(contrast(LINEA_FUERTE[modo], PAPEL_CELDA[modo]), 2)})
    return filas
TABLA_TIPOS = ['45G1', '22G1', '45G0', 'L5G1', '45R1', '42G1', '42U1', '42P3',
               'L5G0', '22K2', '22U1', '22T1', '45R8']


def ranura(k: int) -> dict:
    """Relleno, borde y texto de la ranura k (0..23) en claro y oscuro."""
    nombre, h = NOMBRES[k % 12], TONOS[k % 12]
    lumi = 'suave' if k < 12 else 'intensa'
    fila = {'ranura': k, 'nombre': f'{nombre} {lumi}', 'tono': h}
    for modo, (s_rel, l_rel, s_bor, l_bor) in LUMINOSIDADES[lumi].items():
        relleno, borde = hsl(h, s_rel, l_rel), hsl(h, s_bor, l_bor)
        texto = '#10243F' if modo == 'claro' else '#F2F6FB'
        papel = '#F5F8FC' if modo == 'claro' else '#0B1626'
        fila[modo] = {'relleno': relleno, 'borde': borde, 'texto': texto,
                      'contraste texto': round(contrast(texto, relleno), 2),
                      'contraste borde': round(contrast(borde, papel), 2)}
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


def main() -> int:
    salida_json = '--json' in sys.argv
    fallos = 0
    informe: dict = {'direcciones': {}, 'categorica': categorica(),
                     'secuencial': escala_secuencial()}
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
    print('\n### Paleta categórica «Colorear por»: 24 ranuras (12 tonos × 2 luminosidades)\n')
    print('| Ranura | Tono | Claro: relleno / borde | Texto sobre relleno | Borde sobre papel | '
          'Oscuro: relleno / borde | Texto sobre relleno | Borde sobre papel |')
    print('|---:|---|---|---:|---:|---|---:|---:|')
    for f in informe['categorica']:
        c, o = f['claro'], f['oscuro']
        print(f"| {f['ranura']} | {f['nombre']} ({f['tono']}°) | {c['relleno']} / {c['borde']} | "
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
    print('\n### Celda atenuada (10.7): relleno al 35 % sobre el papel, código en tinta suave, contorno en línea fuerte\n')
    print('| Modo | Rellenos probados | Peor texto sobre el relleno compuesto | Con el relleno | Línea fuerte sobre papel | Cumple |')
    print('|---|---:|---:|---|---:|---|')
    informe['atenuadas'] = atenuadas(informe)
    for a in informe['atenuadas']:
        cumple = a['peor texto'] >= AA_TEXT and a['borde'] >= AA_NON_TEXT
        if not cumple:
            fallos += 1
        print(f"| {a['modo']} | {a['rellenos']} | {a['peor texto']:.2f} | {a['peor relleno']} | "
              f"{a['borde']:.2f} | {'sí' if cumple else '**no**'} |")
    print('\n### Escala secuencial para Estadísticas (del papel a la marca)\n')
    print(' → '.join(informe['secuencial']))
    print(f'\nPares que no cumplen: {fallos}')
    return 1 if fallos else 0


if __name__ == '__main__':
    sys.exit(main())
