"""T-122 · Capturas de la 3.1.1 en la Web (1920 × 1080, la oficina).

Con el Chrome de Playwright (perfil temporal, ventana visible, sin cuentas)
sobre el banco tool/t122_main.dart servido en 127.0.0.1, por la semántica de
Flutter como tool/t114_piloto_web.py. El panel «T122» elige la entrada
sintética; el resto se toca en la interfaz del producto. Por cada tema recorre
H1 (la escala del plano de llegada), H3 (la fila «AGREGADOS»), H4 (cargar un
lleno sin listado), H5 (el avance de la bahía 22) y H6 (el vacío asignado en
las dos búsquedas). H7 es del teléfono (tool/t122_capturas_android.py).

python -X utf8 tool/t122_capturas_web.py build/t122/capturas/web --url http://127.0.0.1:5902/
"""
import argparse
import sys
import time
from pathlib import Path

from playwright.sync_api import sync_playwright

sys.path.insert(0, str(Path(__file__).resolve().parent))
from t114_primera_web import PUBLICADO_JS, abrir, desplazar_hasta, esperar, hay, nuevo_contexto, pulsar  # noqa: E402
from t73_listado_sintetico import box  # noqa: E402


MARCADO_JS = """(patron) => {
  const re = new RegExp(patron);
  return Array.from(document.querySelectorAll('flt-semantics'))
    .some((n) => re.test(n.getAttribute('aria-label') || n.textContent || '') && n.getAttribute('aria-checked') === 'true');
}"""


def marcado(page, patron):
    return page.evaluate(MARCADO_JS, patron)


class Fotos:
    def __init__(self, page, out, prefijo):
        self.page, self.out, self.prefijo = page, out, prefijo

    def foto(self, nombre):
        time.sleep(0.8)
        destino = self.out / f'{self.prefijo}_{nombre}.png'
        self.page.screenshot(path=str(destino))
        print(destino.name)


def panel(page, *acciones):
    pulsar(page, '^Banco T122$')
    esperar(page, '^Próximo archivo$')
    for a in acciones:
        pulsar(page, a)
        time.sleep(0.4)
    pulsar(page, '^Cerrar panel$')
    time.sleep(0.6)


def confirmar_plano(page, f, puerto=None, fotos=False):
    esperar(page, '^Confirmar$', 60)
    time.sleep(1)
    pulsar(page, '^Confirmar$')
    # Con el perfil del mismo buque guardado, la carga que excede el perfil
    # pregunta antes: «Revisar ampliación» abre los parámetros.
    esperar(page, 'Parámetros del buque|^Revisar ampliación$')
    if hay(page, '^Revisar ampliación$'):
        pulsar(page, '^Revisar ampliación$')
    esperar(page, 'Parámetros del buque')
    # La semántica de la página tarda un momento en completarse.
    esperar(page, '^Sin declarar$', 30)
    time.sleep(1.5)
    desplazar_hasta(page, '^Puerto de esta escala')
    # La semántica trae también lo que queda bajo el pliegue: una vuelta más
    # de rueda deja las fichas de los puertos a la vista.
    page.mouse.wheel(0, 700)
    time.sleep(0.8)
    if fotos:
        f.foto('h1_parametros_escala')
    if puerto:
        pulsar(page, rf'^{puerto} \(\d+\)$')
        time.sleep(0.6)
        if fotos:
            f.foto('h1_parametros_escala_elegida')
    desplazar_hasta(page, '^No lo tengo')
    # Con el perfil ya guardado viene marcado: pulsarlo lo desmarcaría.
    if not marcado(page, '^No lo tengo'):
        pulsar(page, '^No lo tengo')
    desplazar_hasta(page, '^Confirmar y ver')
    pulsar(page, '^Confirmar y ver')
    page.wait_for_function(PUBLICADO_JS, timeout=90000)
    time.sleep(4.5)  # el aviso «Archivo cargado» dura 4 s


def cerrar_el_plano(page):
    pulsar(page, r'^Más(?:\n|$)')
    time.sleep(1)
    pulsar(page, '^Cerrar el plano')
    esperar(page, '^Seleccionar archivo')
    time.sleep(1)


def destino(page, rotulo):
    pulsar(page, rf'^{rotulo}(?:\n|$)')
    time.sleep(1)


def h1(page, f):
    panel(page, r'^Llegada \(H1\)$')
    pulsar(page, '^Seleccionar archivo')
    confirmar_plano(page, f, puerto='GTSTC', fotos=True)
    esperar(page, r'^Descarga(?:\n|$)')
    f.foto('h1_plano_con_descarga')
    cerrar_el_plano(page)


def h3(page, f):
    panel(page, '^Plan de carga$')
    pulsar(page, '^Seleccionar archivo')
    confirmar_plano(page, f)
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
    if hay(page, '^Atrás$'):
        pulsar(page, '^Atrás$')
    else:
        page.go_back()
    time.sleep(1)


def confirmar_carga(page, f, nombre):
    esperar(page, '^Confirmar carga$')
    f.foto(nombre)
    pulsar(page, '^Confirmar carga$')
    time.sleep(1.5)


def h4(page, f):
    destino(page, 'Plano')
    pulsar(page, r'^Carga(?:\n|$)')
    time.sleep(1)
    pulsar(page, '^Bahía 22,')
    time.sleep(1)
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
    pulsar(page, '^Avance de la operación$')
    esperar(page, 'Bahía 22|^22$')
    f.foto('h5_avance_22')
    if hay(page, '^Atrás$'):
        pulsar(page, '^Atrás$')
    else:
        page.go_back()
    time.sleep(1)


def h6(page, f):
    vacio = box('TSTU001212')
    if hay(page, '^Asignar vacío$'):
        pulsar(page, '^Asignar vacío$')
    else:
        pulsar(page, '^Acciones$')
        pulsar(page, '^Asignar vacío$')
    pulsar(page, rf'^OR 12 · {vacio}')
    esperar(page, '^Asignar vacío$')
    pulsar(page, '^Celda reservada')
    time.sleep(0.8)
    pulsar(page, '^021-00-84')
    time.sleep(0.8)
    pulsar(page, '^Confirmar carga$')
    time.sleep(4.5)
    pulsar(page, '^OR / últimos dígitos$')
    esperar(page, 'Confirmar carga por OR o contenedor')
    page.keyboard.type('123')
    time.sleep(1.2)
    esperar(page, 'Ya cargado')
    f.foto('h6_or_ultimos_digitos')
    pulsar(page, '^Cerrar$')
    time.sleep(0.8)
    pulsar(page, '^Buscar contenedor$')
    time.sleep(1)
    page.keyboard.type(vacio)
    time.sleep(1.5)
    esperar(page, 'Posición: Bahía')
    f.foto('h6_busqueda_general')
    pulsar(page, 'Posición: Bahía')
    time.sleep(1.5)
    f.foto('h6_resaltado')


def recorrido(navegador, url, out, tema):
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
        h1(page, f)
        h3(page, f)
        h4(page, f)
        h5(page, f)
        h6(page, f)
    except Exception:
        page.screenshot(path=str(out / f'_error_{tema}.png'))
        raise
    finally:
        contexto.close()


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5902/')
    p.add_argument('--tema', choices=['claro', 'oscuro', 'ambos'], default='ambos')
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
                recorrido(navegador, args.url, out, t)
        finally:
            navegador.close()
    print('capturas:', sorted(r.name for r in out.glob('*.png')))


if __name__ == '__main__':
    raise SystemExit(main())
