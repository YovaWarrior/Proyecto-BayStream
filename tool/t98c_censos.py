"""T-98 · Los tres censos de Timonel sobre lib/ de sprint3-cierre (10.92):
idioma (RNF-002), Material 3 (RNF-002, 2.4 a) y mensajes de error (RNF-006).

Solo lee archivos. No ejecuta Flutter ni Dart, no abre la app y no usa la red.

Uso, desde la raíz del repositorio o de una copia de sprint3-cierre:

    python -I tool/t98c_censos.py . %TEMP%\\t98c-censos
    python -I tool/t98c_censos.py . %TEMP%\\t98c-censos --codex <raíz de la Fase B de Codex>

Con --codex, concilia con el inventario de Codex (inventario/cadenas.csv,
errores.csv y material3.csv) y compara las huellas de lib/ con su copia
(app/lib), normalizando los finales de línea.

Escribe en la carpeta de salida (debe estar bajo TEMP): idioma.csv,
framework.csv, material3.csv, mensajes.csv, envolturas.csv, resumen.json y
tablas.md, el texto de las tablas del informe docs/T98-CENSOS-RESULTADOS.md.
"""
import argparse
import collections
import csv
import hashlib
import json
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import t98c_idioma as I  # noqa: E402
import t98c_lexico as L  # noqa: E402
import t98c_material3 as M3  # noqa: E402
import t98c_mensajes as MSG  # noqa: E402

CORREO = re.compile(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}')
H5 = ('lib/latency_test_screen.dart', 'lib/c3_reconciliation_screen.dart')


def salida(valor):
    ruta = Path(valor).resolve()
    temp = Path(os.environ.get('TEMP', '/tmp')).resolve()
    if not ruta.is_relative_to(temp) or ruta == temp:
        raise SystemExit('La salida debe estar bajo TEMP.')
    ruta.mkdir(parents=True, exist_ok=True)
    return ruta


def limpio(texto):
    return CORREO.sub('[CORREO OMITIDO]', texto)


def escribir_csv(ruta, filas, columnas):
    with ruta.open('w', encoding='utf-8-sig', newline='') as f:
        w = csv.DictWriter(f, fieldnames=columnas, extrasaction='ignore')
        w.writeheader()
        w.writerows(filas)


def md(texto):
    return str(texto).replace('|', '\\|').replace('\n', ' ')


def corto(rel):
    return rel.replace('lib/features/vessel/', '')


# ---------------------------------------------------------------------------
def procedencia(root, codex):
    archivos = L.archivos_lib(root)
    huellas = {rel: L.sha256_lf(root / rel) for rel in archivos}
    total = hashlib.sha256(''.join(f'{r}:{h}\n' for r, h in sorted(huellas.items())).encode()).hexdigest()
    out = {'archivos_lib': len(archivos), 'huella_lib_lf': total}
    if codex:
        copia = codex / 'app'
        iguales = sum(1 for rel in archivos
                      if (copia / rel).exists() and L.sha256_lf(copia / rel) == huellas[rel])
        inv = json.loads((codex / 'inventario' / 'inventario.json').read_text(encoding='utf-8'))
        fuentes = {f['archivo']: f['sha256'] for f in inv['fuentes']}
        inv_copia = sum(1 for rel, h in fuentes.items()
                        if (copia / rel).exists() and L.sha256(copia / rel) == h)
        out.update({'iguales_a_copia_codex_lf': iguales, 'inventario_codex_sobre_copia': inv_copia,
                    'inventario_codex_archivos': len(fuentes)})
    return out


# ---------------------------------------------------------------------------
def censo_idioma(root, alcanzables):
    filas = []
    candidatos = {'total': 0, 'exactos': 0, 'trozos': 0, 'fuera_del_producto': 0}
    literales = anidados = 0
    for rel in L.archivos_lib(root):
        src, lx, m, cadenas = L.cadenas_de(root, rel)
        literales += len(lx.lits)
        anidados += sum(1 for lit in lx.lits if lit.parent is not None)
        spans = {(lit.start, lit.end) for lit in lx.lits}
        for a, b, _ in L.candidatos_codex(src):
            candidatos['total'] += 1
            candidatos['exactos' if (a, b) in spans else 'trozos'] += 1
            if not alcanzables[rel]:
                candidatos['fuera_del_producto'] += 1
        padres = {}
        for c in cadenas:
            d = I.decidir(c, alcanzables[rel], padres)
            padres[id(c)] = d
            regla, visible, canal, motivo = d
            fila = {'archivo': rel, 'linea': c.linea, 'regla': regla,
                    'visible': {True: 'sí', False: 'no', None: '—'}[visible],
                    'canal': canal or '', 'texto': limpio(c.texto), 'motivo': motivo,
                    'idioma': '', 'palabras_no_espanolas': ''}
            if visible:
                cat, otras = I.idioma(c)
                fila['idioma'] = cat
                fila['palabras_no_espanolas'] = '; '.join(f'{w} ({e})' for w, e, _ in otras)
            filas.append(fila)
    return filas, candidatos, literales, anidados


def resumen_idioma(filas):
    reglas = collections.Counter(f['regla'] for f in filas)
    vis = [f for f in filas if f['visible'] == 'sí']
    por_canal = collections.defaultdict(collections.Counter)
    for f in vis:
        por_canal[f['canal']][f['idioma']] += 1
    return {
        'cadenas': len(filas),
        'por_regla': dict(sorted(reglas.items(), key=lambda kv: -kv[1])),
        'directivas': sum(v for k, v in reglas.items() if k == 'NV-DIRECTIVA'),
        'fuera_del_producto': reglas.get('NV-FUERA-DEL-PRODUCTO', 0),
        'sin_letras': reglas.get('SIN-LETRAS', 0),
        'no_visibles_con_letras': sum(1 for f in filas if f['visible'] == 'no'
                                      and f['regla'] not in ('NV-DIRECTIVA', 'NV-FUERA-DEL-PRODUCTO')),
        'visibles': len(vis),
        'visibles_por_idioma': dict(collections.Counter(f['idioma'] for f in vis)),
        'visibles_por_canal': {k: dict(v) for k, v in por_canal.items()},
    }


# ---------------------------------------------------------------------------
def censo_material3(root, alcanzables):
    filas = []
    codex_total = codex_producto = 0
    for rel in L.archivos_lib(root):
        src = L.leer(root / rel)
        m = L.masked(src, L.Lexer(src).run())
        n = len(list(L.CODEX_CONTROLS.finditer(m)))
        codex_total += n
        producto = alcanzables[rel] and rel not in H5
        if producto:
            codex_producto += n
            for fila in M3.controles(root, rel):
                f = M3.clasificar(fila)
                f['pantalla'] = M3._pantalla(rel, f['linea'])
                filas.append(f)
    for pantalla, control, sitio in M3.IMPLICITOS:
        filas.append({'archivo': '(framework)', 'linea': sitio, 'control': control, 'origen': 'implícito',
                      'pantalla': pantalla, 'incluido': 'sí', 'motivo': 'lo construye el framework',
                      'material': 'sí', 'color': 'sí: tema (sin color propio)', 'excepcion': ''})
    return filas, codex_total, codex_producto


# ---------------------------------------------------------------------------
def censo_mensajes(root, codex):
    filas, envolturas = MSG.censo(root)
    for f in filas:
        f['ubicacion'] = '; '.join(f'{corto(a)}:{",".join(map(str, ls))}' for a, ls in f['sitios'])
    conciliacion = None
    if codex:
        with (codex / 'inventario' / 'errores.csv').open(encoding='utf-8-sig') as fh:
            cands = list(csv.DictReader(fh))
        sitios = {(a, l) for f in filas for a, ls in f['sitios'] for l in ls}
        en_sitio = sum(1 for c in cands if (c['archivo'], int(c['linea'])) in sitios)
        con_candidato = sum(1 for f in filas
                            if any((a, l) in {(c['archivo'], int(c['linea'])) for c in cands}
                                   for a, ls in f['sitios'] for l in ls))
        conciliacion = {'candidatos_codex': len(cands), 'candidatos_en_un_mensaje': en_sitio,
                        'mensajes_con_candidato': con_candidato}
    return filas, envolturas, conciliacion


def metricas_mensajes(filas):
    n = len(filas)
    causa = collections.Counter(f['causa'] for f in filas)
    accion = collections.Counter(f['accion'] for f in filas)
    estricto = sum(1 for f in filas if f['causa'] == 'sí' and f['accion'] == 'sí')
    amplio = sum(1 for f in filas if f['causa'] != 'no' and f['accion'] != 'no')
    parseo = [f for f in filas if f['parseo'] == 'sí']
    return {
        'mensajes': n, 'causa': dict(causa), 'accion': dict(accion),
        'causa_y_accion_estricto': estricto, 'causa_y_accion_con_implicitas': amplio,
        'parseo_edifact': len(parseo), 'parseo_con_segmento': sum(1 for f in parseo if f['segmento'] == 'sí'),
        'por_tipo': {t: {'mensajes': len(g), 'estricto': sum(1 for f in g if f['causa'] == 'sí' and f['accion'] == 'sí'),
                         'con_implicitas': sum(1 for f in g if f['causa'] != 'no' and f['accion'] != 'no')}
                     for t, g in _agrupar(filas, 'tipo').items()},
    }


def _agrupar(filas, clave):
    g = collections.defaultdict(list)
    for f in filas:
        g[f[clave]].append(f)
    return g


# ---------------------------------------------------------------------------
def tablas_md(prov, ri, cand, lits, anid, idioma, m3, codex_total, codex_producto, msgs, metr, env, conc):
    o = []
    o.append('<!-- Generado por tool/t98c_censos.py; no editar a mano. -->\n')
    # --- idioma: conciliación
    o.append('## Tabla I-1 · De los candidatos léxicos a las cadenas censadas\n')
    o.append('| Paso | Cantidad |\n|---|---:|')
    o.append(f'| Candidatos léxicos de `tool/t98_inventario.py` (Fase A de Codex) | {cand["total"]} |')
    o.append(f'| · coinciden exactamente con un literal de Dart | {cand["exactos"]} |')
    o.append(f'| · son trozos: comillas dentro de `${{…}}` parten el literal | {cand["trozos"]} |')
    o.append(f'| Literales simples que encuentra el tokenizador de `tool/t98c_lexico.py` | {lits} |')
    o.append(f'| · anidados dentro de una interpolación | {anid} |')
    o.append(f'| Cadenas de Dart (literales adyacentes unidos, como el compilador) | {ri["cadenas"]} |')
    o.append('')
    o.append('## Tabla I-2 · Clasificación de las cadenas\n')
    o.append('| Grupo | Cadenas |\n|---|---:|')
    o.append(f'| Directivas import/export/part | {ri["directivas"]} |')
    o.append(f'| En archivos que no llegan al producto | {ri["fuera_del_producto"]} |')
    o.append(f'| Sin letras (cifras, signos, separadores o solo interpolaciones) | {ri["sin_letras"]} |')
    o.append(f'| Con letras y no visibles para el usuario | {ri["no_visibles_con_letras"]} |')
    o.append(f'| **Visibles** | **{ri["visibles"]}** |')
    o.append(f'| **Total** | **{ri["cadenas"]}** |')
    o.append('')
    o.append('## Tabla I-3 · Reglas de clasificación\n')
    o.append('| Regla | Cadenas |\n|---|---:|')
    for k, v in ri['por_regla'].items():
        o.append(f'| `{k}` | {v} |')
    o.append('')
    o.append('## Tabla I-4 · Visibles por canal e idioma\n')
    cats = ['español', 'sin idioma (siglas, nombres o unidades)', 'mixta', 'otro idioma']
    o.append('| Canal | ' + ' | '.join(cats) + ' | Total |\n|---|' + '---:|' * (len(cats) + 1))
    tot = collections.Counter()
    for canal in ('pantalla', 'accesibilidad', 'sistema', 'pdf', 'archivo'):
        c = ri['visibles_por_canal'].get(canal, {})
        tot.update(c)
        o.append(f'| {canal} | ' + ' | '.join(str(c.get(k, 0)) for k in cats) + f' | {sum(c.values())} |')
    o.append('| **Total** | ' + ' | '.join(f'**{tot.get(k, 0)}**' for k in cats) + f' | **{sum(tot.values())}** |')
    o.append('')
    o.append('## Tabla I-8 · Métrica del idioma: visibles en español / visibles\n')
    o.append('Dos lecturas, porque T-63 no dice qué hacer con lo que no tiene idioma (siglas, nombres, '
             'unidades): (a) español / (español + inglés o mixto); (b) (español + sin idioma) / visibles. '
             'Los textos de Flutter cuentan por entrada de la tabla I-7, todas en inglés.\n')
    o.append('| Alcance | Español | Sin idioma | Inglés o mixto | Flutter (I-7) | (a) | (b) |\n'
             '|---|---:|---:|---:|---:|---:|---:|')
    nfw = len(I.FRAMEWORK)

    def fila_metrica(nombre, canales, con_fw):
        es = sum(ri['visibles_por_canal'].get(c, {}).get('español', 0) for c in canales)
        neu = sum(ri['visibles_por_canal'].get(c, {}).get('sin idioma (siglas, nombres o unidades)', 0) for c in canales)
        noes = sum(ri['visibles_por_canal'].get(c, {}).get(k, 0) for c in canales for k in ('mixta', 'otro idioma'))
        fw = nfw if con_fw else 0
        a = es / (es + noes + fw)
        b = (es + neu) / (es + neu + noes + fw)
        o.append(f'| {nombre} | {es} | {neu} | {noes} | {fw if con_fw else "—"} | {100 * a:.1f} % | {100 * b:.1f} % |')
    interfaz = ('pantalla', 'accesibilidad', 'sistema')
    todo = interfaz + ('pdf', 'archivo')
    fila_metrica('Interfaz (pantalla, accesibilidad y diálogos del sistema)', interfaz, False)
    fila_metrica('Interfaz, con los textos de Flutter', interfaz, True)
    fila_metrica('Todo lo visible, también el PDF y el CSV', todo, False)
    fila_metrica('Todo lo visible, con los textos de Flutter', todo, True)
    o.append('')
    o.append('## Tabla I-5 · Cadenas visibles en inglés o mixtas\n')
    o.append('| # | Archivo:línea | Canal | Idioma | Texto | Palabras en inglés y por qué |\n|---|---|---|---|---|---|')
    k = 0
    for f in idioma:
        if f['visible'] == 'sí' and f['idioma'] in ('mixta', 'otro idioma'):
            k += 1
            ingles = '; '.join(p for p in f['palabras_no_espanolas'].split('; ') if 'inglés' in p)
            o.append(f'| I{k:02d} | `{corto(f["archivo"])}:{f["linea"]}` | {f["canal"]} | {f["idioma"]} | '
                     f'{md(f["texto"])} | {md(ingles)} |')
    o.append('')
    o.append('## Tabla I-6 · Préstamos y abreviaturas que se cuentan como no inglés\n')
    o.append('| Archivo:línea | Canal | Texto | Palabra |\n|---|---|---|---|')
    for f in idioma:
        if f['visible'] == 'sí' and ('préstamo' in f['palabras_no_espanolas'] or 'N_A' in f['palabras_no_espanolas']):
            pal = '; '.join(p for p in f['palabras_no_espanolas'].split('; ') if 'préstamo' in p or 'N_A' in p)
            o.append(f'| `{corto(f["archivo"])}:{f["linea"]}` | {f["canal"]} | {md(f["texto"])} | '
                     f'{md(pal.replace("N_A", "N/A"))} |')
    o.append('')
    o.append('## Tabla I-7 · Textos que pone Flutter en inglés\n')
    o.append('| # | Texto | Origen en el SDK 3.38.9 | Widget | Dónde aparece | Canal | Plataformas |\n'
             '|---|---|---|---|---|---|---|')
    for i, (texto, origen, widget, donde, canal, plat) in enumerate(I.FRAMEWORK, 1):
        o.append(f'| F{i:02d} | {md(texto)} | `{md(origen)}` | {md(widget)} | {md(donde)} | {canal} | {md(plat)} |')
    o.append('')
    # --- Material 3
    incl = [f for f in m3 if f['incluido'] == 'sí']
    excl = [f for f in m3 if f['incluido'] == 'no']
    exc = [f for f in incl if f['excepcion'] == 'sí']
    o.append('## Tabla M-1 · Del candidato al denominador\n')
    o.append('| Paso | Cantidad |\n|---|---:|')
    o.append(f'| Candidatos de `tool/t98_inventario.py` en todo lib/ | {codex_total} |')
    o.append(f'| · en archivos que no llegan al producto (H5 y matriz de segregación) | {codex_total - codex_producto} |')
    o.append(f'| · en las rutas del producto | {codex_producto} |')
    agregados = [f for f in m3 if f['origen'] == 'agregado']
    o.append(f'| Constructores que su patrón no encuentra (argumento de tipo o nombre no buscado) | {len(agregados)} |')
    o.append(f'| Controles implícitos del framework | {sum(1 for f in m3 if f["origen"] == "implícito")} |')
    o.append(f'| Excluidos: rejilla | {sum(1 for f in excl if f["motivo"].startswith("rejilla"))} |')
    o.append(f'| Excluidos: no interactivos | {sum(1 for f in excl if not f["motivo"].startswith("rejilla"))} |')
    o.append(f'| **Denominador (controles interactivos)** | **{len(incl)}** |')
    o.append(f'| **Excepciones** | **{len(exc)}** |')
    o.append('')
    o.append('## Tabla M-2 · Controles por pantalla\n')
    o.append('| Pantalla | Controles | Material | Color del esquema o del tema | Excepciones |\n|---|---:|---:|---:|---:|')
    por = collections.defaultdict(list)
    for f in incl:
        for p in f['pantalla'].split('+'):
            por[p].append(f)
    for p in sorted(M3.PANTALLAS):
        g = por.get(p, [])
        o.append(f'| {p} · {M3.PANTALLAS[p]} | {len(g)} | {sum(1 for f in g if f["material"] == "sí")} | '
                 f'{sum(1 for f in g if f["color"].startswith("sí"))} | {sum(1 for f in g if f["excepcion"] == "sí")} |')
    o.append('\nUn constructor que se ve en dos pantallas cuenta en las dos filas; el total del denominador lo '
             'cuenta una vez.\n')
    o.append('## Tabla M-3 · Lista completa de controles\n')
    o.append('| # | Pantalla | Archivo:línea | Control | Origen | Material | Color | Excepción | Nota |\n'
             '|---|---|---|---|---|---|---|---|---|')
    k = 0
    for f in sorted(incl, key=lambda f: (f['pantalla'], str(f['archivo']), str(f['linea']))):
        k += 1
        sitio = f'{corto(f["archivo"])}:{f["linea"]}' if f['archivo'] != '(framework)' else f'(framework) {f["linea"]}'
        color = f['color'] if len(f['color']) < 140 else f['color'][:137] + '…'
        o.append(f'| C{k:03d} | {f["pantalla"]} | `{sitio}` | {f["control"]} | {f["origen"]} | {f["material"]} | '
                 f'{md(color)} | {f["excepcion"] or "no"} | {md(f["motivo"])} |')
    o.append('')
    o.append('## Tabla M-4 · Constructores excluidos\n')
    o.append('| Archivo:línea | Control | Motivo |\n|---|---|---|')
    for f in excl:
        o.append(f'| `{corto(f["archivo"])}:{f["linea"]}` | {f["control"]} | {md(f["motivo"])} |')
    o.append('')
    # --- mensajes
    o.append('## Tabla E-1 · Métricas de los mensajes\n')
    o.append('| Medida | Cantidad | De | % |\n|---|---:|---:|---:|')
    n = metr['mensajes']

    def pct(a, b):
        return f'{100 * a / b:.1f}' if b else '—'
    o.append(f'| Mensajes distintos | {n} | | |')
    o.append(f'| Dicen la causa (sí) | {metr["causa"].get("sí", 0)} | {n} | {pct(metr["causa"].get("sí", 0), n)} |')
    o.append(f'| Causa solo implícita | {metr["causa"].get("impl.", 0)} | {n} | {pct(metr["causa"].get("impl.", 0), n)} |')
    o.append(f'| Sin causa (genérica o ninguna) | {metr["causa"].get("no", 0)} | {n} | {pct(metr["causa"].get("no", 0), n)} |')
    o.append(f'| Dicen la acción (sí) | {metr["accion"].get("sí", 0)} | {n} | {pct(metr["accion"].get("sí", 0), n)} |')
    o.append(f'| Acción solo implícita | {metr["accion"].get("impl.", 0)} | {n} | {pct(metr["accion"].get("impl.", 0), n)} |')
    o.append(f'| Sin acción | {metr["accion"].get("no", 0)} | {n} | {pct(metr["accion"].get("no", 0), n)} |')
    o.append(f'| **Causa y acción explícitas (lectura estricta)** | **{metr["causa_y_accion_estricto"]}** | {n} | '
             f'**{pct(metr["causa_y_accion_estricto"], n)}** |')
    o.append(f'| Causa y acción, contando las implícitas | {metr["causa_y_accion_con_implicitas"]} | {n} | '
             f'{pct(metr["causa_y_accion_con_implicitas"], n)} |')
    o.append(f'| Errores de lectura de un BAPLIE que nombran el segmento | {metr["parseo_con_segmento"]} | '
             f'{metr["parseo_edifact"]} | {pct(metr["parseo_con_segmento"], metr["parseo_edifact"])} |')
    o.append('')
    o.append('## Tabla E-2 · Por tipo de mensaje\n')
    o.append('| Tipo | Mensajes | Causa y acción explícitas | Contando implícitas |\n|---|---:|---:|---:|')
    for t, v in sorted(metr['por_tipo'].items(), key=lambda kv: -kv[1]['mensajes']):
        o.append(f'| {t} | {v["mensajes"]} | {v["estricto"]} | {v["con_implicitas"]} |')
    o.append('')
    o.append('## Tabla E-3 · Inventario de los mensajes de error\n')
    o.append('| # | Archivo:línea | Texto como se ve | Tipo | Causa | Acción | Parseo | Segmento | Arreglo sugerido |\n'
             '|---|---|---|---|---|---|---|---|---|')
    grupo = None
    for f in msgs:
        if f['grupo'] != grupo:
            grupo = f['grupo']
            o.append(f'| | **{md(grupo)}** | | | | | | | |')
        o.append(f'| {f["id"]} | `{md(f["ubicacion"])}` | {md(f["texto"])} | {f["tipo"]} | {f["causa"]} | '
                 f'{f["accion"]} | {f["parseo"]} | {f["segmento"]} | {md(f["arreglo"]) or "—"} |')
    o.append('')
    o.append('## Tabla E-4 · Envolturas (muestran un mensaje de E-3; no suman)\n')
    o.append('| Archivo:línea | Qué muestran |\n|---|---|')
    for e in env:
        o.append(f'| `{corto(e["archivo"])}:{",".join(map(str, e["lineas"]))}` | {md(e["motivo"])} |')
    o.append('')
    if conc:
        o.append('## Tabla E-5 · Conciliación con los 804 candidatos de Codex\n')
        o.append('| Medida | Cantidad |\n|---|---:|')
        o.append(f'| Candidatos de `errores.csv` | {conc["candidatos_codex"]} |')
        o.append(f'| · en la línea de un mensaje de E-3 | {conc["candidatos_en_un_mensaje"]} |')
        o.append(f'| Mensajes de E-3 con algún candidato en su línea | {conc["mensajes_con_candidato"]} de {n} |')
        o.append('')
    return '\n'.join(o)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('fuente', type=Path)
    ap.add_argument('salida')
    ap.add_argument('--codex', type=Path, help='raíz de la evidencia de la Fase B de Codex')
    a = ap.parse_args()
    root = a.fuente.resolve()
    out = salida(a.salida)
    alc = L.alcanzables(root)

    prov = procedencia(root, a.codex)
    idioma, cand, lits, anid = censo_idioma(root, alc)
    ri = resumen_idioma(idioma)
    m3, codex_total, codex_producto = censo_material3(root, alc)
    msgs, env, conc = censo_mensajes(root, a.codex)
    metr = metricas_mensajes(msgs)

    escribir_csv(out / 'idioma.csv', idioma, ['archivo', 'linea', 'regla', 'visible', 'canal', 'idioma',
                                              'palabras_no_espanolas', 'texto', 'motivo'])
    escribir_csv(out / 'framework.csv',
                 [dict(zip(['texto', 'origen_sdk', 'widget', 'donde', 'canal', 'plataformas'], f)) for f in I.FRAMEWORK],
                 ['texto', 'origen_sdk', 'widget', 'donde', 'canal', 'plataformas'])
    escribir_csv(out / 'material3.csv', m3, ['pantalla', 'archivo', 'linea', 'control', 'origen', 'incluido',
                                             'material', 'color', 'excepcion', 'motivo'])
    escribir_csv(out / 'mensajes.csv', msgs, ['id', 'grupo', 'ubicacion', 'texto', 'tipo', 'causa', 'accion',
                                              'parseo', 'segmento', 'arreglo'])
    escribir_csv(out / 'envolturas.csv', env, ['archivo', 'lineas', 'motivo'])
    resumen = {
        'procedencia': prov,
        'idioma': {**ri, 'candidatos_codex': cand, 'literales': lits, 'anidados': anid,
                   'framework': len(I.FRAMEWORK)},
        'material3': {'filas': len(m3), 'incluidos': sum(1 for f in m3 if f['incluido'] == 'sí'),
                      'excluidos': sum(1 for f in m3 if f['incluido'] == 'no'),
                      'excepciones': sum(1 for f in m3 if f['excepcion'] == 'sí'),
                      'codex_total': codex_total, 'codex_producto': codex_producto,
                      'agregados': sum(1 for f in m3 if f['origen'] == 'agregado'),
                      'implicitos': sum(1 for f in m3 if f['origen'] == 'implícito')},
        'mensajes': {**metr, 'envolturas': len(env), 'conciliacion_codex': conc},
    }
    (out / 'resumen.json').write_text(json.dumps(resumen, ensure_ascii=False, indent=2), encoding='utf-8')
    (out / 'tablas.md').write_text(
        tablas_md(prov, ri, cand, lits, anid, idioma, m3, codex_total, codex_producto, msgs, metr, env, conc),
        encoding='utf-8')
    for nombre in ('idioma.csv', 'framework.csv', 'material3.csv', 'mensajes.csv', 'envolturas.csv',
                   'resumen.json', 'tablas.md'):
        resumen.setdefault('huellas_salida', {})[nombre] = L.sha256(out / nombre)
    (out / 'huellas.json').write_text(json.dumps(resumen['huellas_salida'], indent=2), encoding='utf-8')
    print(json.dumps({'procedencia': prov,
                      'idioma': {k: ri[k] for k in ('cadenas', 'visibles', 'visibles_por_idioma')},
                      'material3': resumen['material3'],
                      'mensajes': {k: metr[k] for k in ('mensajes', 'causa_y_accion_estricto',
                                                         'causa_y_accion_con_implicitas', 'parseo_edifact',
                                                         'parseo_con_segmento')},
                      'salida': str(out)}, ensure_ascii=True, indent=1))


if __name__ == '__main__':
    main()
