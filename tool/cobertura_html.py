#!/usr/bin/env python3
"""Convierte LCOV de Flutter en HTML local, sin dependencias ni conexión.

Uso: python tool/cobertura_html.py
Las cifras cuentan líneas ejecutables presentes en DA, no líneas físicas.
Los archivos sin registros LCOV se muestran como «Sin datos», sin inventar
líneas ejecutables ni incluirlos en el denominador del total.
"""

import argparse
import html
import os
from pathlib import Path
from urllib.parse import quote


ESTILOS = """
body {font: 16px system-ui, sans-serif; margin: 2rem; color: #17212b;
      background: #fff; line-height: 1.5}
h1 {font-size: 1.7rem} a {color: #154a75}
table {border-collapse: collapse; width: 100%; margin: 1rem 0}
th, td {padding: .4rem .7rem; border-bottom: 1px solid #cbd5dc; text-align: left}
th {background: #eef2f5} .numero {text-align: right; font-variant-numeric: tabular-nums}
tfoot {font-weight: bold} .cubierta {background: #d9f0df}
.no-cubierta {background: #f8dada} .sin-datos {color: #53616d}
.codigo {overflow-x: auto} .codigo table {width: auto; min-width: 100%}
.codigo td {border: 0; padding: 0 .6rem; vertical-align: top}
.codigo pre {margin: 0; tab-size: 2}
.codigo .numero, .codigo .estado {white-space: nowrap}
code {font-family: Consolas, monospace} caption {text-align: left; font-weight: bold}
"""


def ruta_fuente(nombre, raiz):
    """Acepta rutas relativas y absolutas de Flutter en Windows o Unix."""
    nombre = nombre.replace("\\", "/")
    if len(nombre) > 3 and nombre[0] == "/" and nombre[2] == ":":
        nombre = nombre[1:]  # LCOV puede escribir /C:/ruta/archivo.dart.
    candidata = Path(nombre)
    if not candidata.is_absolute():
        candidata = raiz / candidata
    candidata = candidata.resolve()
    if not candidata.is_relative_to((raiz / "lib").resolve()):
        return None  # No publica pruebas, paquetes ni fuentes fuera de lib/.
    return candidata.relative_to(raiz)


def leer_lcov(archivo, raiz):
    """Agrupa por archivo y línea; une registros repetidos sin duplicar LF."""
    cobertura = {}
    actual = None
    for numero, linea in enumerate(archivo.read_text(encoding="utf-8-sig").splitlines(), 1):
        if linea.startswith("SF:"):
            actual = ruta_fuente(linea[3:], raiz)
            if actual is not None:
                cobertura.setdefault(actual, {})
        elif linea == "end_of_record":
            actual = None
        elif linea.startswith("DA:") and actual is not None:
            try:
                campos = linea[3:].split(",")
                posicion, veces = int(campos[0]), int(campos[1])
                if posicion < 1 or veces < 0:
                    raise ValueError("posición o contador negativo")
            except (ValueError, IndexError) as error:
                raise ValueError(f"Registro DA inválido en LCOV, línea {numero}") from error
            datos = cobertura[actual]
            datos[posicion] = datos.get(posicion, 0) + veces
    return cobertura


def porcentaje(cubiertas, lineas):
    return f"{100 * cubiertas / lineas:.2f}%" if lineas else "Sin datos"


def pagina(titulo, contenido):
    return (
        '<!doctype html>\n<html lang="es"><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width, initial-scale=1">'
        f"<title>{html.escape(titulo)}</title><style>{ESTILOS}</style></head>"
        f"<body>{contenido}</body></html>\n"
    )


def generar(raiz, cobertura, salida):
    """Crea un índice y una página de código por archivo Dart de lib/."""
    archivos = sorted(
        {ruta.relative_to(raiz) for ruta in (raiz / "lib").rglob("*.dart")}
        | set(cobertura),
        key=lambda ruta: ruta.as_posix(),
    )
    if not cobertura:
        raise ValueError("El LCOV no contiene archivos de lib/ de este proyecto")

    filas = []
    total_lineas = total_cubiertas = sin_datos = 0
    for archivo in archivos:
        datos = cobertura.get(archivo, {})
        fuente = (raiz / archivo).read_text(encoding="utf-8-sig").splitlines()
        if datos and max(datos) > len(fuente):
            raise ValueError(f"LCOV no coincide con el código actual: {archivo.as_posix()}")
        lineas = len(datos)
        cubiertas = sum(veces > 0 for veces in datos.values())
        total_lineas += lineas
        total_cubiertas += cubiertas
        sin_datos += lineas == 0
        destino = salida / "archivos" / (archivo.as_posix() + ".html")
        destino.parent.mkdir(parents=True, exist_ok=True)
        enlace = quote(destino.relative_to(salida).as_posix())
        etiqueta = html.escape(archivo.as_posix())
        filas.append(
            f'<tr><td><a href="{enlace}">{etiqueta}</a></td>'
            f'<td class="numero">{lineas if datos else "—"}</td>'
            f'<td class="numero">{cubiertas if datos else "—"}</td>'
            f'<td class="numero">{porcentaje(cubiertas, lineas)}</td></tr>'
        )

        codigo = []
        for posicion, texto in enumerate(fuente, 1):
            veces = datos.get(posicion)
            if veces is None:
                clase, estado, contador = "sin-datos", "Sin instrumentar", "—"
            elif veces > 0:
                clase, estado, contador = "cubierta", "Cubierta", str(veces)
            else:
                clase, estado, contador = "no-cubierta", "No cubierta", "0"
            codigo.append(
                f'<tr id="L{posicion}" class="{clase}">'
                f'<td class="numero"><a href="#L{posicion}">{posicion}</a></td>'
                f'<td class="numero">{contador}</td><td class="estado">{estado}</td>'
                f"<td><pre><code>{html.escape(texto)}</code></pre></td></tr>"
            )
        volver = quote(os.path.relpath(salida / "index.html", destino.parent).replace("\\", "/"))
        detalle = (
            f'<a href="{volver}">Volver al resumen</a><h1>{etiqueta}</h1>'
            f"<p>{cubiertas} de {lineas} líneas instrumentadas cubiertas: "
            f"<strong>{porcentaje(cubiertas, lineas)}</strong>.</p>"
            '<p>Verde: cubierta. Rojo: no cubierta. Gris: sin instrumentar.</p>'
            '<div class="codigo"><table><caption>Código y ejecuciones por línea</caption>'
            '<thead><tr><th>Línea</th><th>Ejecuciones</th><th>Estado</th>'
            f'<th>Código</th></tr></thead><tbody>{"".join(codigo)}</tbody></table></div>'
        )
        destino.write_text(pagina(archivo.as_posix(), detalle), encoding="utf-8")

    resumen = (
        '<h1>Cobertura de pruebas de BayStream</h1>'
        f'<p><strong>Total: {porcentaje(total_cubiertas, total_lineas)}</strong> · '
        f'{total_cubiertas} de {total_lineas} líneas instrumentadas cubiertas.</p>'
        '<p>Una línea está cubierta si LCOV registra al menos una ejecución. '
        'La cobertura de líneas no demuestra cobertura de ramas ni ausencia de errores.</p>'
        f'<p>{sin_datos} archivos sin datos ejecutables en este LCOV: se muestran '
        'sin porcentaje y no aportan líneas al denominador. El total describe los '
        'archivos instrumentados, no garantiza cobertura de todo lib/.</p>'
        '<table><caption>Archivos de lib/</caption><thead><tr><th>Archivo</th>'
        '<th class="numero">Líneas instrumentadas</th><th class="numero">Cubiertas</th>'
        '<th class="numero">Porcentaje</th></tr></thead>'
        f'<tbody>{"".join(filas)}</tbody><tfoot><tr><td>Total instrumentado</td>'
        f'<td class="numero">{total_lineas}</td><td class="numero">{total_cubiertas}</td>'
        f'<td class="numero">{porcentaje(total_cubiertas, total_lineas)}</td>'
        '</tr></tfoot></table><p>Reporte local: funciona sin conexión.</p>'
    )
    salida.mkdir(parents=True, exist_ok=True)
    (salida / "index.html").write_text(pagina("Cobertura de BayStream", resumen), encoding="utf-8")
    return total_cubiertas, total_lineas


def main():
    raiz = Path(__file__).resolve().parent.parent
    argumentos = argparse.ArgumentParser(description=__doc__)
    argumentos.add_argument("--lcov", type=Path, default=raiz / "coverage/lcov.info")
    argumentos.add_argument("--salida", type=Path, default=raiz / "coverage/html")
    opciones = argumentos.parse_args()
    try:
        cobertura = leer_lcov(opciones.lcov, raiz)
        cubiertas, lineas = generar(raiz, cobertura, opciones.salida)
    except (OSError, ValueError) as error:
        argumentos.exit(1, f"No se pudo generar el reporte: {error}\n")
    print(f"Total: {cubiertas}/{lineas} líneas cubiertas ({porcentaje(cubiertas, lineas)})")
    print(f"Reporte: {(opciones.salida / 'index.html').resolve()}")


if __name__ == "__main__":
    main()
