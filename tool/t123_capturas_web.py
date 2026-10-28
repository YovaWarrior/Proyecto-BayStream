"""T-123 · Capturas de la 3.1.1 dentro del rediseño, en la Web (1920 × 1080,
la oficina de DESIGN.md 14).

Con el Chrome de Playwright (perfil temporal, ventana visible, sin cuentas)
sobre el banco tool/t122_main.dart compilado en sprint-4 y servido en
127.0.0.1, por la semántica de Flutter como tool/t122_capturas_web.py, del
que toma el panel «T122», el previo y los nombres sintéticos. Lo que cambia
es la oficina: el modo se elige en el selector de la cabecera (segmentos a
1920, 14.6), «Avance de la operación» y «Asignar vacío» viven en «Acciones»
(14.7), «OR / últimos dígitos» en la franja de la bahía (14.8) y el resumen
va en fichas en la franja de cifras. Por cada tema recorre H1, H3, H4, H5 y
H6 (H7 es del teléfono) y toma además el plano en Contenido y «El buque en
corte» (15), como quedaron aceptados.

python -X utf8 tool/t123_capturas_web.py build/t123/capturas/web --url http://127.0.0.1:5903/
"""
import argparse
import sys
import time
from pathlib import Path

from playwright.sync_api import sync_playwright

sys.path.insert(0, str(Path(__file__).resolve().parent))
from t114_primera_web import abrir, desplazar_hasta, esperar, hay, nuevo_contexto, pulsar  # noqa: E402
from t122_capturas_web import Fotos, confirmar_plano, panel  # noqa: E402
from t73_listado_sintetico import box  # noqa: E402


def elegir_modo(page, rotulo):
    """El modo en el selector de la cabecera (14.6): el segmento si está a la
    vista («Carga 29»: el rótulo y la cuenta) o, en menú, el botón «Modo del
    plano: …» y su entrada. El final aparta las fichas («Carga: 29 …»)."""
    patron = f'^{rotulo}(?![:\\wáéíóúñ])'
    if not hay(page, patron):
        pulsar(page, '^Modo del plano: ')
        time.sleep(0.8)
    pulsar(page, patron)
    time.sleep(1.2)


def accion(page, rotulo):
    """Una entrada de «Acciones» (14.7); el botón dice su cuenta de
    solicitudes cuando la hay («Acciones, 2 solicitudes pendientes»)."""
    pulsar(page, '^Acciones')
    time.sleep(0.8)
    pulsar(page, rotulo)
    time.sleep(1)


def destino(page, rotulo):
    """Un destino del riel de la oficina, por su rótulo entero."""
    pulsar(page, f'^{rotulo}(?:\n|$)')
    time.sleep(1.2)


def volver(page):
    if hay(page, '^Atrás$'):
        pulsar(page, '^Atrás$')
    else:
        page.go_back()
    time.sleep(1)


def cerrar_el_plano(page, url):
    """«Más» → «Cerrar el plano»; si el riel no lo ofrece, se vuelve a abrir
    la app, que arranca en «Seleccionar archivo»."""
    if hay(page, r'^Más(?:\n|$)'):
        pulsar(page, r'^Más(?:\n|$)')
        time.sleep(1)
        if hay(page, '^Cerrar el plano'):
            pulsar(page, '^Cerrar el plano')
            esperar(page, '^Seleccionar archivo')
            time.sleep(1)
            return
        page.keyboard.press('Escape')
    abrir(page, url)
    esperar(page, '^Seleccionar archivo', 60)
    time.sleep(1.5)


def h1(page, f, url):
    panel(page, r'^Llegada \(H1\)$')
    pulsar(page, '^Seleccionar archivo')
    confirmar_plano(page, f, puerto='GTSTC', fotos=True)
    esperar(page, r'^Descarga(?![:\wáéíóúñ])')
    f.foto('h1_plano_con_descarga')
    elegir_modo(page, 'Descarga')
    f.foto('h1_modo_descarga')
    cerrar_el_plano(page, url)


def h3(page, f):
    panel(page, '^Plan de carga$')
    pulsar(page, '^Seleccionar archivo')
    confirmar_plano(page, f)
    # El plano de la oficina en Contenido, como quedó aceptado (14).
    f.foto('plano_contenido')
    destino(page, 'Lista')
    desplazar_hasta(page, '^Listado de la agencia')
    pulsar(page, '^Listado de la agencia')
    esperar(page, '^Elegir listado')
    panel(page, r'^Listado \(H3\)$')
    pulsar(page, '^Elegir listado')
    esperar(page, '^Confirmar e importar', 30)
    f.foto('h3_agregados')
    pulsar(page, '^Confirmar e importar')
    esperar(page, 'guardado en la operación|Listado guardado', 30)
    f.foto('h3_importado')
    volver(page)


def confirmar_carga(page, f, nombre):
    esperar(page, '^Confirmar carga$')
    f.foto(nombre)
    pulsar(page, '^Confirmar carga$')
    time.sleep(1.5)


def h4(page, f):
    destino(page, 'Plano')
    elegir_modo(page, 'Carga')
    pulsar(page, '^Bahía 22,')
    time.sleep(1)
    f.foto('h4_carga_bahia_22')
    sin_or = box('TSTU022007')
    pulsar(page, rf'^{sin_or}, sube$')
    confirmar_carga(page, f, 'h4_confirmar_sin_or')
    f.foto('h4_registrado')
    time.sleep(4)


def h5(page, f):
    pulsar(page, '^OR 1 · TSTU0220003, sube$')
    confirmar_carga(page, f, 'h5_confirmar_or1')
    time.sleep(4)
    f.foto('h5_silueta_22')
    accion(page, '^Avance de la operación$')
    esperar(page, 'Bahía 22|^22$')
    f.foto('h5_avance_22')
    volver(page)


def h6(page, f):
    vacio = box('TSTU001212')
    accion(page, '^Asignar vacío$')
    pulsar(page, rf'^OR 12 · {vacio}')
    esperar(page, '^Asignar vacío$')
    pulsar(page, '^Celda reservada')
    time.sleep(0.8)
    pulsar(page, '^021-00-84')
    time.sleep(0.8)
    pulsar(page, '^Confirmar carga$')
    time.sleep(4.5)
    pulsar(page, '^OR / últimos dígitos')
    esperar(page, 'Confirmar carga por OR o contenedor')
    page.keyboard.type('123')
    time.sleep(1.2)
    esperar(page, 'Ya cargado')
    f.foto('h6_or_ultimos_digitos')
    pulsar(page, '^Cerrar$')
    time.sleep(0.8)
    pulsar(page, '^Buscar contenedor')
    time.sleep(1)
    page.keyboard.type(vacio)
    time.sleep(1.5)
    esperar(page, 'Posición: Bahía')
    f.foto('h6_busqueda_general')
    pulsar(page, 'Posición: Bahía')
    time.sleep(1.5)
    f.foto('h6_resaltado')
    # La Lista cuenta también el vacío asignado («Todas (n)»).
    destino(page, 'Lista')
    esperar(page, r'^Todas \(\d+\)')
    f.foto('h6_lista')
    destino(page, 'Plano')


def estadisticas(page, f):
    """«El buque en corte» (15), como quedó aceptado en 10.55."""
    destino(page, 'Estadísticas')
    esperar(page, 'contenedores a bordo', 40)
    time.sleep(1.5)
    f.foto('estadisticas')
    destino(page, 'Plano')


def sin_listado(page, f):
    """H4 sin listado, en un almacén limpio: la ficha de revisar dice que los
    llenos se cargan por su número y los vacíos esperan el listado, y «OR /
    últimos dígitos» abre la búsqueda con los llenos sin OR."""
    panel(page, '^Plan de carga$')
    pulsar(page, '^Seleccionar archivo')
    confirmar_plano(page, f)
    elegir_modo(page, 'Carga')
    esperar(page, 'Sin listado de agencia')
    f.foto('h4_sin_listado_ficha')
    pulsar(page, '^OR / últimos dígitos')
    esperar(page, 'sin OR en el listado')
    f.foto('h4_sin_listado_busqueda')
    pulsar(page, '^Cerrar$')
    time.sleep(0.8)


def recorrido(navegador, url, out, tema, solo_sin_listado=False):
    contexto, page = nuevo_contexto(navegador, 'dark' if tema == 'oscuro' else 'light',
                                    viewport={'width': 1920, 'height': 1080})
    f = Fotos(page, out, f'web_{tema}')
    try:
        abrir(page, url)
        page.set_default_timeout(60000)
        esperar(page, '^Seleccionar archivo', 60)
        time.sleep(1.5)
        panel(page, f'^Tema {tema}$')
        time.sleep(1)
        if solo_sin_listado:
            sin_listado(page, f)
            return
        h1(page, f, url)
        h3(page, f)
        h4(page, f)
        h5(page, f)
        h6(page, f)
        estadisticas(page, f)
    except Exception:
        page.screenshot(path=str(out / f'_error_{tema}.png'))
        raise
    finally:
        contexto.close()


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5903/')
    p.add_argument('--tema', choices=['claro', 'oscuro', 'ambos'], default='ambos')
    p.add_argument('--solo-sin-listado', action='store_true',
                   help='solo H4 sin listado, en un perfil limpio: la ficha y la búsqueda')
    args = p.parse_args()
    if not args.url.startswith('http://127.0.0.1:'):
        raise ValueError('Solo el banco servido en 127.0.0.1.')
    out = Path(args.salida)
    out.mkdir(parents=True, exist_ok=True)
    with sync_playwright() as pw:
        navegador = pw.chromium.launch(channel='chrome', headless=False,
                                       args=['--window-size=1960,1200', '--window-position=0,0'])
        try:
            for t in (['claro', 'oscuro'] if args.tema == 'ambos' else [args.tema]):
                recorrido(navegador, args.url, out, t, solo_sin_listado=args.solo_sin_listado)
        finally:
            navegador.close()
    print('capturas:', sorted(r.name for r in out.glob('*.png')))


if __name__ == '__main__':
    raise SystemExit(main())
