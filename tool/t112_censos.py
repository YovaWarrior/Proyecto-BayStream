"""T-112 · Los tres censos de T-98, corridos de nuevo sobre el árbol de T-112.

Los scripts de T-98 (tool/t98c_*) llevan sus decisiones atadas a las líneas de
sprint3-cierre. Este script no los cambia: los importa y, antes de correrlos,
- traslada a las líneas nuevas cada decisión por línea (idioma y Material 3),
  con difflib, archivo por archivo, contra la copia de antes (--antes);
- agrega las decisiones y el vocabulario que piden las cadenas nuevas de T-112
  (abajo, cada una con su motivo);
- cambia la tabla de mensajes por tool/t112_mensajes.py (los mismos 218);
- deja los 20 textos de Flutter en su versión en español (flutter_localizations,
  material_es.arb del SDK);
- marca resuelta la excepción de Material 3 del buscador.
Lo que no tiene decisión queda «PENDIENTE» y el censo se detiene.

Uso (la salida va a TEMP, como en T-98):
    python -I tool/t112_censos.py . %TEMP%\\t112\\censos --antes %TEMP%\\t112\\head
"""
import argparse
import collections
import difflib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import t98c_censos as C  # noqa: E402
import t98c_idioma as I  # noqa: E402
import t98c_lexico as L  # noqa: E402
import t98c_material3 as M3  # noqa: E402
import t98c_mensajes as MSG  # noqa: E402
import t112_mensajes as N  # noqa: E402

_P = 'lib/features/vessel/presentation/'
_D = 'lib/features/vessel/domain/'
_DA = 'lib/features/vessel/data/'


# ---------------------------------------------------------------------------
# 1. Las líneas de antes y las de ahora
# ---------------------------------------------------------------------------
def mapa_lineas(antes, ahora):
    """Línea de antes → línea de ahora, para las líneas iguales y para las que
    cambiaron dentro de un mismo bloque (por posición dentro del bloque)."""
    viejo = [l.rstrip('\r') for l in L.leer(antes).split('\n')]
    nuevo = [l.rstrip('\r') for l in L.leer(ahora).split('\n')]
    mapa = {}
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, viejo, nuevo, autojunk=False).get_opcodes():
        if tag == 'equal' or tag == 'replace':
            for k in range(i2 - i1):
                mapa[i1 + k + 1] = j1 + min(k, j2 - j1 - 1) + 1
    return mapa


def mapas(root, antes):
    return {rel: mapa_lineas(antes / rel, root / rel)
            for rel in L.archivos_lib(root) if (antes / rel).exists()}


def _rango(a, b, mapa):
    dentro = sorted(v for k, v in mapa.items() if a <= k <= b)
    return (dentro[0], dentro[-1]) if dentro else None


def trasladar_tabla(tabla, mapa):
    nueva = {}
    for clave, valor in tabla.items():
        if clave == '*':
            nueva[clave] = valor
        elif isinstance(clave, int):
            if clave in mapa:
                nueva[mapa[clave]] = valor
        elif isinstance(clave, tuple) and isinstance(clave[1], str):
            if clave[0] in mapa:
                nueva[(mapa[clave[0]], clave[1])] = valor
        elif isinstance(clave, tuple):
            rango = _rango(clave[0], clave[1], mapa)
            if rango:
                nueva[rango] = valor
    return nueva


def trasladar_claves(tabla, maps):
    """Tablas con clave (archivo, línea)."""
    nueva = {}
    for (rel, linea), valor in tabla.items():
        destino = maps.get(rel, {}).get(linea)
        if destino is not None:
            nueva[(rel, destino)] = valor
    return nueva


# ---------------------------------------------------------------------------
# 2. Lo que T-112 agrega a las decisiones de idioma
# ---------------------------------------------------------------------------
V, NV = I.V, I.NV
PANTALLA = I.PANTALLA
MENSAJE = V('pantalla', 'mensaje de error (censo 3), leído en su pantalla')
INALCANZABLE = NV('NV-INALCANZABLE', 'rama que no se ejecuta: el lector etiqueta siempre un segmento '
                  'antes de leer (T-112), así que este genérico no se alcanza')

# Por archivo y línea del árbol de T-112. Se completó leyendo las cadenas que
# quedaron «PENDIENTE» al trasladar las tablas de T-98.
OPERACION = V('pantalla', 'operación que nombra el mensaje de error (M001, M006, T-112)')
LOCALE = NV('NV-CODIGO', 'código de idioma del locale de la app (T-112)')
FUENTE = V('pantalla', 'nombre de la fuente dentro del mensaje M050 (T-112)')
VALOR_CSV = V('archivo', 'valor del CSV exportado, en español (T-112)')
SEGMENTOS = V('pantalla', 'segmentos que nombra M004 cuando el lector falla en esa fase (T-112)')
T112_DECISIONES = {
    # En estos archivos, el «resto del archivo» de T-98 es interno: los mensajes
    # nuevos de T-112 que caen ahí se deciden aquí, uno por uno.
    ('lib/core/app.dart', 21): LOCALE,
    ('lib/core/app.dart', 22): LOCALE,
    ('lib/core/errors/exceptions.dart', 16): NV('NV-CODIGO', 'código del fallo inesperado del lector (T-112)'),
    (_DA + 'repositories/firebase_session_repository.dart', 164): MENSAJE,
    (_DA + 'repositories/firebase_session_repository.dart', 186): MENSAJE,
    (_DA + 'repositories/firebase_session_repository.dart', 190): MENSAJE,
    (_DA + 'repositories/firebase_session_repository.dart', 197): MENSAJE,
    (_DA + 'repositories/firebase_session_repository.dart', 212): MENSAJE,
    (_DA + 'repositories/firestore_operation_sync.dart', 56): MENSAJE,
    (_DA + 'repositories/firestore_operation_sync.dart', 148): MENSAJE,
    (_DA + 'repositories/firestore_operation_sync.dart', 155): FUENTE,
    (_DA + 'repositories/firestore_operation_sync.dart', 156): FUENTE,
    (_DA + 'repositories/firestore_operation_sync.dart', 157): FUENTE,
    (_DA + 'repositories/firestore_operation_sync.dart', 199): MENSAJE,
    (_DA + 'repositories/firestore_operation_sync.dart', 254): MENSAJE,
    (_DA + 'repositories/firestore_operation_sync.dart', 282): MENSAJE,
    (_DA + 'repositories/firestore_operation_sync.dart', 292): MENSAJE,
    (_DA + 'services/export_list_parser_service.dart', 79): MENSAJE,
    (_DA + 'services/export_service.dart', 97): VALOR_CSV,
    (_DA + 'services/export_service.dart', 98): VALOR_CSV,
    (_DA + 'services/export_service.dart', 99): VALOR_CSV,
    (_DA + 'services/export_service.dart', 102): VALOR_CSV,
    (_DA + 'services/baplie_parser_service.dart', 57): NV(
        'NV-REEMPLAZADO', 'mensaje técnico de la excepción: la pantalla muestra M004 con el segmento y esto va '
                          'al registro'),
    (_DA + 'services/baplie_parser_service.dart', 77): SEGMENTOS,
    (_DA + 'services/baplie_parser_service.dart', 90): SEGMENTOS,
    (_DA + 'services/baplie_parser_service.dart', 163): MENSAJE,
    (_P + 'formatters/vessel_error_message.dart', 70): INALCANZABLE,
    ('lib/core/utils/voyage_number.dart', 5): NV(
        'NV-PERSISTENCIA', 'valor guardado cuando el TDT no trae número; forma parte de la identidad del viaje '
                           'y no se muestra: en pantalla y en el PDF dice «sin número»'),
    ('lib/core/utils/voyage_number.dart', 10): V('pantalla', 'número de viaje ausente, en pantalla y en el PDF'),
    (_P + 'pages/parameters_page.dart', 38): OPERACION,
    (_P + 'pages/vessel_profiles_page.dart', 20): OPERACION,
}

# T-114 (rediseño, 10.9): los archivos nuevos del sistema de diseño y del
# inicio y el previo. Van por archivo entero («*»): cada archivo tiene un solo
# canal, y el idioma lo juzga el censo texto por texto.
T114_DECISIONES = {
    ('lib/core/design/bs_formato.dart', '*'): V(
        'pantalla', 'formatos de número con su unidad («28.7 t», «28 650 kg»), leídos en pantalla (T-114)'),
    ('lib/core/design/bs_tipografia.dart', '*'): NV(
        'NV-CODIGO', 'nombres de familias tipográficas (fontFamily): no se leen (T-114)'),
    ('lib/core/design/componentes/bs_celda.dart', '*'): V(
        'pantalla', 'rótulos de la marca de operación en la celda del plano (T-114, Fase 2)'),
    ('lib/core/design/componentes/bs_tira_de_bahias.dart', '*'): V(
        'accesibilidad', 'etiqueta de accesibilidad de la casilla de bahía (T-114, Fase 2)'),
    (_P + 'providers/voyage_ui_state.dart', '*'): V(
        'pantalla', 'textos del previo: la banda, «sin evaluar», exportar y la operación del error (T-114, Fase 3)'),
    (_P + 'widgets/inicio_view.dart', '*'): V(
        'pantalla', 'textos del inicio: recientes, perfiles, nube y la operación del error (T-114, Fase 3)'),
}
T112_DECISIONES.update(T114_DECISIONES)

# Palabras nuevas sin tilde de las cadenas visibles que no son españolas.
T112_VOCABULARIO = {
    **{w: (I.SIGLA, 'segmento EDIFACT') for w in ('MEA', 'LOC', 'EQD', 'UNA', 'DTM', 'BGM', 'UNT', 'UNZ')},
    'SMDG15': (I.SIGLA, 'identificador de versión del estándar'),
    'cm': (I.FORMATO, 'unidad'),
}

# Los textos que pone Flutter, con flutter_localizations y locale es: el texto
# es el de material_es.arb (SDK 3.38.9); el resto de cada fila, el de T-98.
ES_FLUTTER = {
    'F01': 'Atrás', 'F02': 'Alerta', 'F03': 'Cerrar', 'F04': 'Sombreado',
    'F05': 'Cerrar Hoja inferior', 'F06': 'Menú emergente', 'F07': 'Eliminar',
    'F08': 'Pestaña 1 de 3', 'F09': 'Quedan N caracteres', 'F10': 'Contraído / Desplegado',
    'F11': 'Desplegar para ver más detalles / Contraer', 'F12': 'Cortar / Copiar / Pegar / Seleccionar todo',
    'F13': 'Buscador visual / Buscar en la Web / Compartir', 'F14': 'Seleccionar fecha', 'F15': 'Cancelar / ACEPTAR',
    'F16': 'Cambiar a cuadro de texto / Cambiar a calendario', 'F17': 'Introduce una fecha / dd/mm/aaaa',
    'F18': 'Formato no válido. / Fuera del periodo válido.',
    'F19': 'Mes anterior / Mes siguiente / Seleccionar año',
    'F20': 'meses y días en español, como «octubre de 2026» (test/t112_localization_test.dart)',
}


# ---------------------------------------------------------------------------
def preparar(root, antes):
    maps = mapas(root, antes)
    I.POR_ARCHIVO = {rel: trasladar_tabla(tabla, maps.get(rel, {})) for rel, tabla in I.POR_ARCHIVO.items()}
    for (rel, clave), decision in T112_DECISIONES.items():
        I.POR_ARCHIVO.setdefault(rel, {})[clave] = decision
    I.CORRECCIONES = trasladar_claves(I.CORRECCIONES, maps)
    # T-112 quitó de la pantalla los cuatro valores interpolados en inglés.
    I.INTERPOLA_INGLES = {}
    I.VOCABULARIO.update(T112_VOCABULARIO)
    I.FRAMEWORK = [(ES_FLUTTER[f'F{k:02d}'],) + fila[1:] for k, fila in enumerate(I.FRAMEWORK, 1)]

    M3.PANTALLA_DE = {rel: trasladar_tabla(tabla, maps.get(rel, {})) for rel, tabla in M3.PANTALLA_DE.items()}
    # T-114 (10.9): el inicio nuevo es parte de S01; el sistema de diseño
    # (componentes, tema y vistas previas) todavía no está en una pantalla.
    M3.PANTALLAS['T114'] = 'Sistema de diseño de T-114: componentes, tema y vistas previas (sin pantalla aún)'
    M3.PANTALLA_DE[_P + 'widgets/inicio_view.dart'] = {'*': 'S01'}
    M3.PANTALLA_DE[_P + 'providers/voyage_ui_state.dart'] = {'*': 'S01'}
    for rel in ('lib/core/design/bs_tema.dart', 'lib/core/design/vistas_previas.dart',
                'lib/core/design/componentes/bs_banda.dart',
                'lib/core/design/componentes/bs_barra_de_operacion.dart',
                'lib/core/design/componentes/bs_cartela.dart',
                'lib/core/design/componentes/bs_celda.dart',
                'lib/core/design/componentes/bs_cifra.dart',
                'lib/core/design/componentes/bs_hoja_de_detalle.dart',
                'lib/core/design/componentes/bs_numero_de_contenedor.dart',
                'lib/core/design/componentes/bs_tira_de_bahias.dart'):
        M3.PANTALLA_DE[rel] = {'*': 'T114'}
    for nombre in ('REJILLA', 'NO_INTERACTIVOS', 'OBSERVACIONES', 'RESUELTOS'):
        setattr(M3, nombre, trasladar_claves(getattr(M3, nombre), maps))
    buscador = (_P + 'widgets/container_search_delegate.dart', maps[_P + 'widgets/container_search_delegate.dart'][347])
    M3.RESUELTOS[buscador] = (
        'sí', 'leading: _buildLeadingIcon usa errorContainer, primaryContainer, secondaryContainer y '
              'surfaceContainerHighest del esquema, con sus colores on*: los mismos de las celdas y la leyenda '
              'del plano (T-112); el resaltado usa tertiaryContainer y onTertiaryContainer')
    # T-114: los componentes toman el color de BsColoresSemanticos, una
    # ThemeExtension del tema (DESIGN.md 5): son colores del tema.
    M3.RESUELTOS[('lib/core/design/componentes/bs_banda.dart', 108)] = (
        'sí', 'icono de cerrar en rol.contorno: el rol semántico de la banda viene de BsColoresSemanticos, '
              'una ThemeExtension del tema (T-114)')
    M3.RESUELTOS[('lib/core/design/componentes/bs_tira_de_bahias.dart', 136)] = (
        'sí', 'relleno y contorno de la casilla del rol semántico (ThemeExtension) y esquema.primary para la '
              'seleccionada: colores del tema (T-114)')
    implicitos = []
    for pantalla, control, sitio in M3.IMPLICITOS:
        partes = []
        for trozo in sitio.split(' y '):
            nombre, _, linea = trozo.partition(':')
            rel = next((r for r in maps if r.endswith('/' + nombre)), None) if nombre else None
            if rel and linea.isdigit():
                partes.append(f'{nombre}:{maps[rel].get(int(linea), linea)}')
            else:
                partes.append(trozo)
        implicitos.append((pantalla, control, ' y '.join(partes)))
    M3.IMPLICITOS = implicitos

    MSG.M = N.M
    MSG.ENVOLTURAS = N.ENVOLTURAS
    return maps


def tabla(cabeceras, filas, alinear=None):
    alinear = alinear or ['---'] * len(cabeceras)
    out = ['| ' + ' | '.join(cabeceras) + ' |', '|' + '|'.join(alinear) + '|']
    out += ['| ' + ' | '.join(C.md(c) for c in fila) + ' |' for fila in filas]
    return out


def tablas_md(ri, idioma, m3, msgs, metr, maps):
    vis = [f for f in idioma if f['visible'] == 'sí']
    o = ['<!-- Generado por tool/t112_censos.py; no editar a mano. -->', '']
    o += ['## Tabla T1 · Idioma: visibles por canal e idioma', '']
    canales = ['pantalla', 'accesibilidad', 'sistema', 'pdf', 'archivo']
    cats = ['español', 'sin idioma (siglas, nombres o unidades)', 'mixta', 'otro idioma']
    filas = []
    for canal in canales:
        c = collections.Counter(f['idioma'] for f in vis if f['canal'] == canal)
        filas.append([canal] + [str(c.get(k, 0)) for k in cats] + [str(sum(c.values()))])
    total = collections.Counter(f['idioma'] for f in vis)
    filas.append(['**Total**'] + [f'**{total.get(k, 0)}**' for k in cats] + [f'**{len(vis)}**'])
    o += tabla(['Canal'] + cats + ['Total'], filas, ['---'] + ['---:'] * 5) + ['']

    o += ['## Tabla T2 · Idioma: la métrica de T-98, repetida', '',
          'Las dos lecturas de T-98: (a) español / (español + inglés o mixto); (b) (español + sin idioma) / '
          'visibles. Los 20 textos de Flutter ya salen en español y suman como español.', '']
    interfaz = [f for f in vis if f['canal'] in ('pantalla', 'accesibilidad', 'sistema')]
    filas = []
    for nombre, grupo, flutter in (('Interfaz (pantalla, accesibilidad y diálogos del sistema)', interfaz, 0),
                                   ('Interfaz, con los textos de Flutter', interfaz, len(I.FRAMEWORK)),
                                   ('Todo lo visible, también el PDF y el CSV', vis, 0),
                                   ('Todo lo visible, con los textos de Flutter', vis, len(I.FRAMEWORK))):
        c = collections.Counter(f['idioma'] for f in grupo)
        es, sin = c.get('español', 0) + flutter, c.get('sin idioma (siglas, nombres o unidades)', 0)
        en = c.get('mixta', 0) + c.get('otro idioma', 0)
        a = 100 * es / (es + en) if es + en else 0
        b = 100 * (es + sin) / (es + sin + en) if es + sin + en else 0
        filas.append([nombre, str(es), str(sin), str(en), f'{a:.1f} %', f'{b:.1f} %'])
    o += tabla(['Alcance', 'Español (con Flutter)', 'Sin idioma', 'Inglés o mixto', '(a)', '(b)'], filas,
               ['---', '---:', '---:', '---:', '---:', '---:']) + ['']

    o += ['## Tabla T3 · Idioma: lo visible que no es español', '']
    otras = [f for f in vis if f['idioma'] in ('mixta', 'otro idioma')]
    if otras:
        o += tabla(['Archivo:línea', 'Canal', 'Texto', 'Palabras'],
                   [[f"`{C.corto(f['archivo'])}:{f['linea']}`", f['canal'], f['texto'], f['palabras_no_espanolas']]
                    for f in otras])
    else:
        o += ['Ninguna: las cadenas visibles están en español o no tienen idioma (siglas, nombres, unidades).']
    o += ['']

    o += ['## Tabla T4 · Textos de Flutter, ahora en español', '']
    o += tabla(['#', 'Texto en español', 'Origen en el SDK 3.38.9 (en material_es.arb)', 'Dónde aparece'],
               [[f'F{k:02d}', f[0], f[1], f[3]] for k, f in enumerate(I.FRAMEWORK, 1)]) + ['']

    o += ['## Tabla T5 · Material 3 por pantalla', '']
    incluidos = [f for f in m3 if f['incluido'] == 'sí']
    filas = []
    for clave, nombre in M3.PANTALLAS.items():
        grupo = [f for f in incluidos if clave in f['pantalla'].split('+')]
        filas.append([f'{clave} · {nombre}', str(len(grupo)), str(sum(1 for f in grupo if f['material'] == 'sí')),
                      str(sum(1 for f in grupo if f['color'].startswith('sí'))),
                      str(sum(1 for f in grupo if f['excepcion'] == 'sí'))])
    o += tabla(['Pantalla', 'Controles', 'Material', 'Color del esquema o del tema', 'Excepciones'], filas,
               ['---', '---:', '---:', '---:', '---:'])
    o += ['', f"Denominador: **{len(incluidos)}** controles; excepciones: "
              f"**{sum(1 for f in incluidos if f['excepcion'] == 'sí')}**.", '']

    o += ['## Tabla T6 · Mensajes: métricas', '']
    n = metr['mensajes']
    pct = lambda x: f'{100 * x / n:.1f}' if n else '0'  # noqa: E731
    filas = [['Mensajes distintos', str(n), '', ''],
             ['Dicen la causa (sí)', str(metr['causa'].get('sí', 0)), str(n), pct(metr['causa'].get('sí', 0))],
             ['Dicen la acción (sí)', str(metr['accion'].get('sí', 0)), str(n), pct(metr['accion'].get('sí', 0))],
             ['**Causa y acción explícitas**', f"**{metr['causa_y_accion_estricto']}**", str(n),
              f"**{pct(metr['causa_y_accion_estricto'])}**"],
             ['Errores de lectura de un BAPLIE que nombran el segmento', str(metr['parseo_con_segmento']),
              str(metr['parseo_edifact']),
              f"{100 * metr['parseo_con_segmento'] / metr['parseo_edifact']:.1f}" if metr['parseo_edifact'] else '—']]
    o += tabla(['Medida', 'Cantidad', 'De', '%'], filas, ['---', '---:', '---:', '---:']) + ['']

    o += ['## Tabla T7 · Mensajes: inventario', '']
    filas, grupo = [], None
    for f in msgs:
        if f['grupo'] != grupo:
            grupo = f['grupo']
            filas.append(['', f'**{grupo}**', '', '', '', '', '', ''])
        filas.append([f['id'], f"`{f['ubicacion']}`", f['texto'], f['tipo'], f['causa'], f['accion'],
                      f['parseo'], f['segmento']])
    o += tabla(['#', 'Archivo:línea', 'Texto como se ve', 'Tipo', 'Causa', 'Acción', 'Parseo', 'Segmento'], filas)
    o += ['']
    return '\n'.join(o)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('fuente', type=Path)
    ap.add_argument('salida')
    ap.add_argument('--antes', type=Path, required=True, help='raíz con el lib/ de sprint3-cierre')
    a = ap.parse_args()
    root = a.fuente.resolve()
    out = C.salida(a.salida)
    maps = preparar(root, a.antes.resolve())
    alc = L.alcanzables(root)

    idioma, cand, lits, anid = C.censo_idioma(root, alc)
    pendientes = [f for f in idioma if f['regla'] == 'PENDIENTE']
    if pendientes:
        for f in pendientes:
            print(f"PENDIENTE {f['archivo']}:{f['linea']}: {f['texto'][:100]}")
        raise SystemExit(f'{len(pendientes)} cadenas sin decisión')
    ri = C.resumen_idioma(idioma)
    m3, codex_total, codex_producto = C.censo_material3(root, alc)
    msgs, env, _ = C.censo_mensajes(root, None)
    metr = C.metricas_mensajes(msgs)

    C.escribir_csv(out / 'idioma.csv', idioma, ['archivo', 'linea', 'regla', 'visible', 'canal', 'idioma',
                                                'palabras_no_espanolas', 'texto', 'motivo'])
    C.escribir_csv(out / 'framework.csv',
                   [dict(zip(['texto', 'origen_sdk', 'widget', 'donde', 'canal', 'plataformas'], f))
                    for f in I.FRAMEWORK], ['texto', 'origen_sdk', 'widget', 'donde', 'canal', 'plataformas'])
    C.escribir_csv(out / 'material3.csv', m3, ['pantalla', 'archivo', 'linea', 'control', 'origen', 'incluido',
                                               'material', 'color', 'excepcion', 'motivo'])
    C.escribir_csv(out / 'mensajes.csv', msgs, ['id', 'grupo', 'ubicacion', 'texto', 'tipo', 'causa', 'accion',
                                                'parseo', 'segmento', 'arreglo'])
    C.escribir_csv(out / 'envolturas.csv', env, ['archivo', 'lineas', 'motivo'])
    resumen = {
        'idioma': {**ri, 'literales': lits, 'anidados': anid, 'framework_en_espanol': len(I.FRAMEWORK)},
        'material3': {'incluidos': sum(1 for f in m3 if f['incluido'] == 'sí'),
                      'excluidos': sum(1 for f in m3 if f['incluido'] == 'no'),
                      'excepciones': sum(1 for f in m3 if f['excepcion'] == 'sí')},
        'mensajes': {**metr, 'envolturas': len(env)},
        'archivos_trasladados': sum(1 for m in maps.values() if m),
    }
    (out / 'resumen.json').write_text(json.dumps(resumen, ensure_ascii=False, indent=2), encoding='utf-8')
    (out / 'tablas.md').write_text(tablas_md(ri, idioma, m3, msgs, metr, maps), encoding='utf-8')
    huellas = {n: L.sha256(out / n) for n in ('idioma.csv', 'framework.csv', 'material3.csv', 'mensajes.csv',
                                               'envolturas.csv', 'resumen.json', 'tablas.md')}
    (out / 'huellas.json').write_text(json.dumps(huellas, indent=2), encoding='utf-8')
    print(json.dumps({'idioma': {k: ri[k] for k in ('cadenas', 'visibles', 'visibles_por_idioma')},
                      'material3': resumen['material3'],
                      'mensajes': {k: metr[k] for k in ('mensajes', 'causa_y_accion_estricto', 'parseo_edifact',
                                                         'parseo_con_segmento')},
                      'salida': str(out)}, ensure_ascii=True, indent=1))


if __name__ == '__main__':
    main()
