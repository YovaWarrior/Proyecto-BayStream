#!/usr/bin/env python3
"""Rehace todo el paquete de íconos e ilustraciones de BayStream desde sus fuentes, y lo verifica.

Uso, desde la raíz del repositorio:

    python -m pip install resvg-py==0.5.0 Pillow fonttools skia-pathops freetype-py
    python design/iconos/generar.py               # escribe todo y lo verifica
    python design/iconos/generar.py --verificar   # solo comprueba que lo escrito coincide con las fuentes
    python design/iconos/generar.py --salida X    # escribe en otra carpeta, con la misma estructura

Fuentes: design/iconos/fuentes/ (el DSL, los ayudantes, iconos.py con los 31 e insignias.py con las 4) y
design/ilustraciones/fuentes/ (el DSL de ilustraciones, plantilla.py y un archivo por ilustración).
Salidas: design/iconos/svg/, design/iconos/svg_insignias/, assets/fonts/bs_iconos/BayStreamIconos.ttf,
design/iconos/codigos.json, design/iconos/vista-previa.png, design/iconos/comprobacion-fuente.png,
design/ilustraciones/<nombre>_{claro,oscuro}.svg, <nombre>.json, design/ilustraciones/vista-previa.png y
design/iconos/LEEME.md (desde fuentes/LEEME.plantilla.md, con las tablas de comprobación y los SHA-256).
design/iconos/conceptos.png es la captura de la página de conceptos: no se regenera, solo se suma al LEEME.

Corriéndolo dos veces sobre una carpeta vacía salen archivos idénticos byte a byte (Python 3.13,
Pillow 12.3, resvg-py 0.5.0, fontTools 4.67, skia-pathops 0.8, freetype-py 2.13). Con otras versiones los
PNG pueden comprimirse distinto y cambiar su SHA-256 sin cambiar un píxel.
"""
import argparse, hashlib, importlib.util, os, shutil, sys, tempfile
from pathlib import Path

AQUI = Path(__file__).resolve().parent                 # design/iconos
RAIZ = AQUI.parent.parent                              # raíz del repositorio
FUENTES = AQUI / 'fuentes'
FUENTES_ILUS = RAIZ / 'design' / 'ilustraciones' / 'fuentes'
for p in (str(FUENTES), str(FUENTES_ILUS)):
    if p not in sys.path:
        sys.path.insert(0, p)

try:
    import resvg_py, PIL, fontTools, pathops, freetype  # noqa: F401
except ImportError as e:  # pragma: no cover
    sys.exit(f'Falta una dependencia ({e.name}). Instala con: python -m pip install resvg-py==0.5.0 Pillow fonttools skia-pathops freetype-py')

import fuente as modulo_fuente
import verificar_fuente, exportar_json, vista_previa
from dsl import cargar as cargar_iconos, REJILLA
from ilus import cargar as cargar_ilus

ILUSTRACIONES = ['inicio', 'vacio_recientes', 'vacio_busqueda', 'sin_conexion', 'descarga_completa', 'sin_alertas']
PAREJAS = ['contenedor_20:contenedor_40', 'contenedor_40:contenedor_45', 'contenedor_20:contenedor_45', 'vacio:contenedor_40',
           'refrigerado:contenedor_40', 'tanque:contenedor_40', 'plataforma:techo_abierto', 'fuera_de_medida:contenedor_40',
           'bahia:tapa_escotilla', 'peso_pila:limite_apilamiento', 'peso_pila:vgm', 'limite_apilamiento:vgm', 'bahia:buque',
           'descarga:carga', 'descarga:reestiba', 'carga:reestiba', 'descarga:baplie_salida', 'carga:baplie', 'pedir_cambio:reestiba',
           'grua:muelle', 'baplie:comparar_baplie', 'baplie:baplie_salida', 'comparar_baplie:baplie_salida', 'baplie:listado_agencia',
           'al_dia:solo_aqui']
TTF = 'assets/fonts/bs_iconos/BayStreamIconos.ttf'
VERSION = '1.1'


def _modulo(ruta):
    spec = importlib.util.spec_from_file_location(ruta.stem + '_mod', ruta)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def cargar_todo():
    iconos = cargar_iconos(str(FUENTES / 'iconos.py'))
    insignias = cargar_iconos(str(FUENTES / 'insignias.py'))
    ils = {}
    for n in ILUSTRACIONES:
        ils[n] = cargar_ilus(str(FUENTES_ILUS / f'{n}.py'))[n]
    return iconos, insignias, ils


def svg_insignia(ic) -> str:
    """La insignia se dibuja en la rejilla de 24; su SVG se entrega en una rejilla de 12 (coordenadas a la mitad)."""
    s = ic.svg(titulo=False)
    cuerpo = s[s.index('<g '):s.rindex('</g>') + 4]
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12">\n  <title>insignia {ic.nombre}</title>\n'
            f'  <g transform="scale(0.5)">\n  {cuerpo}\n  </g>\n</svg>\n')


def escribir_texto(ruta: Path, texto: str):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
        f.write(texto)


def generar(raiz: Path):
    iconos, insignias, ils = cargar_todo()
    di = raiz / 'design' / 'iconos'
    dil = raiz / 'design' / 'ilustraciones'
    escritos = []
    for n, ic in iconos.items():
        escribir_texto(di / 'svg' / f'{n}.svg', ic.svg()); escritos.append(f'design/iconos/svg/{n}.svg')
    for n, ic in insignias.items():
        escribir_texto(di / 'svg_insignias' / f'{n}.svg', svg_insignia(ic)); escritos.append(f'design/iconos/svg_insignias/{n}.svg')
    (raiz / TTF).parent.mkdir(parents=True, exist_ok=True)
    codigos, _ = modulo_fuente.construir(iconos, insignias, str(raiz / TTF), str(di / 'codigos.json'), VERSION)
    escritos += [TTF, 'design/iconos/codigos.json']
    todos = dict(iconos); todos.update({f'insignia_{k}': v for k, v in insignias.items()})
    filas_fuente = verificar_fuente.verificar(todos, codigos, str(raiz / TTF), str(di / 'comprobacion-fuente.png'))
    escritos.append('design/iconos/comprobacion-fuente.png')
    redondeos = {}
    for n, il in ils.items():
        escribir_texto(dil / f'{n}_claro.svg', il.svg('claro')); escribir_texto(dil / f'{n}_oscuro.svg', il.svg('oscuro'))
        datos = exportar_json.escribir(il, str(dil / f'{n}.json'))
        redondeos[n] = exportar_json.comprobar(il, datos)
        escritos += [f'design/ilustraciones/{n}_claro.svg', f'design/ilustraciones/{n}_oscuro.svg', f'design/ilustraciones/{n}.json']
    vista_previa.iconos(iconos, insignias, str(di / 'vista-previa.png')); escritos.append('design/iconos/vista-previa.png')
    vista_previa.ilustraciones(ils, str(dil / 'vista-previa.png')); escritos.append('design/ilustraciones/vista-previa.png')
    # archivos que viajan tal cual: fuentes, generador y la captura de conceptos
    if raiz != RAIZ:
        (di / 'fuentes').mkdir(parents=True, exist_ok=True)
        (dil / 'fuentes').mkdir(parents=True, exist_ok=True)
        for p in sorted(FUENTES.glob('*')):
            if p.is_file() and p.suffix in ('.py', '.md', '.js'):
                shutil.copy(p, di / 'fuentes' / p.name)
        for p in sorted(FUENTES_ILUS.glob('*.py')):
            shutil.copy(p, dil / 'fuentes' / p.name)
        shutil.copy(AQUI / 'generar.py', di / 'generar.py')
    escritos += [f'design/iconos/fuentes/{p.name}' for p in sorted(FUENTES.glob('*')) if p.is_file() and p.suffix in ('.py', '.md', '.js')]
    escritos += [f'design/ilustraciones/fuentes/{p.name}' for p in sorted(FUENTES_ILUS.glob('*.py'))]
    escritos += ['design/iconos/generar.py']
    for extra in ('conceptos.png', 'comprobacion-skia.md', 'comprobacion-skia.png'):
        if raiz != RAIZ and (AQUI / extra).exists() and not (di / extra).exists():
            shutil.copy(AQUI / extra, di / extra)
        if (di / extra).exists():
            escritos.append(f'design/iconos/{extra}')
    leeme = leeme_texto(raiz, sorted(set(escritos)), filas_fuente, redondeos, codigos)
    escribir_texto(di / 'LEEME.md', leeme)
    return escritos, filas_fuente, redondeos


def sha256(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def tabla_fuente(filas):
    out = ['| Glifo | Código | Contorno 16 px (Δ medio · cambian) | FreeType 16 px (cambian · %) | Contorno 24 px | FreeType 24 px | Coincide |', '|---|---|---|---|---|---|---|']
    for f in filas:
        c16, f16, c24, f24 = f['contorno_16'], f['freetype_16'], f['contorno_24'], f['freetype_24']
        out.append(f"| `{f['nombre']}` | {f['codigo']} | {c16[0]} · {c16[1]} | {f16[1]} · {f16[3]} % | {c24[0]} · {c24[1]} | {f24[1]} · {f24[3]} % | {'sí' if f['ok'] else 'no'} |")
    return '\n'.join(out)


def tabla_sha(raiz, escritos):
    out = ['| Archivo | Bytes | SHA-256 |', '|---|---:|---|']
    for rel in escritos:
        p = raiz / rel
        if p.exists():
            out.append(f'| `{rel}` | {p.stat().st_size:,} | `{sha256(p)}` |'.replace(',', ' '))
    return '\n'.join(out)


def tabla_codigos(codigos):
    out = ['| Glifo | Código |', '|---|---|']
    for n, c in codigos.items():
        out.append(f'| `{n}` | U+{c:04X} |')
    return '\n'.join(out)


def tabla_json(redondeos):
    out = ['| Ilustración | Claro: píxeles distintos (de los totales) · Δ máx | Oscuro |', '|---|---|---|']
    for n, r in redondeos.items():
        c, o = r['claro'], r['oscuro']
        out.append(f"| `{n}` | {c['distintos']} de {c['total']:,} · {c['max']} | {o['distintos']} de {o['total']:,} · {o['max']} |".replace(',', ' '))
    return '\n'.join(out)


def tabla_parejas(iconos):
    import io
    from PIL import Image
    def alfa(ic, px):
        png = resvg_py.svg_to_bytes(svg_string=ic.svg(color='#000000'), width=px, height=px)
        return Image.open(io.BytesIO(bytes(png))).convert('RGBA').getchannel('A').tobytes()
    out = ['| Pareja | 16 px: píxeles que cambian de estado · % | 20 px | Se distinguen a 16 px |', '|---|---|---|---|']
    for par in PAREJAS:
        a, b = par.split(':')
        if a not in iconos or b not in iconos:
            continue
        celdas = []
        for px in (16, 20):
            A, B = alfa(iconos[a], px), alfa(iconos[b], px)
            e = sum(1 for x, y in zip(A, B) if (x >= 128) != (y >= 128))
            celdas.append((e, round(100 * e / (px * px), 1)))
        ok = celdas[0][0] >= 8 and celdas[0][1] >= 6
        out.append(f'| `{a}` · `{b}` | {celdas[0][0]} · {celdas[0][1]} % | {celdas[1][0]} · {celdas[1][1]} % | {"sí" if ok else "no (ver nota)"} |')
    return '\n'.join(out)


def bloque_dart(codigos):
    lineas = ['/// Iconos del dominio de BayStream (fuente BayStreamIconos, area de uso privado).',
              '/// Generado por design/iconos/generar.py a partir de design/iconos/codigos.json; no editar a mano.',
              "import 'package:flutter/widgets.dart';", '',
              'abstract final class BsIconos {', "  static const String familia = 'BayStreamIconos';", '']
    for n, c in codigos.items():
        partes = n.split('_')
        camel = partes[0] + ''.join(p.capitalize() for p in partes[1:])
        lineas.append(f'  static const IconData {camel} = IconData(0x{c:04X}, fontFamily: familia);')
    lineas.append('}')
    return '\n'.join('   ' + l if l else l for l in lineas)


def leeme_texto(raiz, escritos, filas_fuente, redondeos, codigos):
    plantilla = (FUENTES / 'LEEME.plantilla.md').read_text(encoding='utf-8')
    iconos, _, _ = cargar_todo()
    rutas = [e for e in escritos if e != 'design/iconos/LEEME.md'] + ['design/iconos/LEEME.md']
    git = '```\n' + '\n'.join(f'git add -- {r}' for r in rutas) + '\ngit commit -m "Agrega los iconos del dominio y las ilustraciones de BayStream, paquete 1"\ngit push\n```'
    skia_md = raiz / 'design' / 'iconos' / 'comprobacion-skia.md'
    skia = skia_md.read_text(encoding='utf-8').strip() if skia_md.exists() else '(no se corrió: necesita Node con Playwright y Chromium)'
    return (plantilla.replace('{{TABLA_CODIGOS}}', tabla_codigos(codigos))
            .replace('{{SKIA_TABLA}}', skia)
            .replace('{{GIT}}', git)
            .replace('{{TABLA_PAREJAS}}', tabla_parejas(iconos))
            .replace('{{DART}}', bloque_dart(codigos))
            .replace('{{TABLA_FUENTE}}', tabla_fuente(filas_fuente))
            .replace('{{TABLA_JSON}}', tabla_json(redondeos))
            .replace('{{TABLA_SHA}}', tabla_sha(raiz, [e for e in escritos if e != 'design/iconos/LEEME.md'])))


def verificar(raiz: Path):
    """Regenera en una carpeta temporal y compara byte a byte con lo que hay en raiz."""
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        escritos, filas, _ = generar(tmp)
        fallas = []
        for rel in sorted(set(escritos)) + ['design/iconos/LEEME.md']:
            a, b = raiz / rel, tmp / rel
            if not a.exists():
                fallas.append(f'{rel}: no existe'); continue
            if (rel.startswith('design/iconos/fuentes/') or rel.startswith('design/ilustraciones/fuentes/') or rel.endswith('generar.py')
                    or rel.endswith('conceptos.png') or 'comprobacion-skia' in rel):
                continue
            if a.read_bytes() != b.read_bytes():
                fallas.append(f'{rel}: distinto de lo que producen las fuentes')
        for f in filas:
            if not f['ok']:
                fallas.append(f"glifo {f['nombre']}: no coincide con su SVG")
        return fallas, len(set(escritos))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    ap.add_argument('--salida', type=Path, default=RAIZ)
    ap.add_argument('--verificar', action='store_true')
    a = ap.parse_args()
    if a.verificar:
        fallas, n = verificar(a.salida)
        for f in fallas:
            print(' ✗', f)
        print(f'\n{n - len(fallas)} de {n} comprobaciones correctas.')
        sys.exit(1 if fallas else 0)
    escritos, filas, redondeos = generar(a.salida)
    malos = [f['nombre'] for f in filas if not f['ok']]
    print(f'{len(set(escritos))} archivos escritos en {a.salida}')
    print(f"fuente: {len(filas) - len(malos)} de {len(filas)} glifos coinciden con su SVG" + (f' (revisar: {", ".join(malos)})' if malos else ''))
    for n, r in redondeos.items():
        print(f"json {n}: claro {r['claro']['distintos']} px distintos, oscuro {r['oscuro']['distintos']} px distintos")
    sys.exit(1 if malos else 0)


if __name__ == '__main__':
    main()
