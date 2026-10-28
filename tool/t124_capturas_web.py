"""T-124 · Capturas de la regla de la par en la Web (1920 × 1080, la oficina).

Con el Chrome de Playwright (perfil temporal por tema, ventana visible, sin
cuentas) sobre el banco tool/t124_main.dart servido en 127.0.0.1, con los
ayudantes de tool/t122_capturas_web.py y tool/t123_capturas_web.py. Por cada
tema:

  ficha      el plan de carga de T-122 en Carga y en Contenido, con la 21, la
             22 y la 26 elegidas: la ficha de la bahía dice la bahía que se ve
             con su número y el grupo con el rótulo de su par (14.7);
  salida     sin listado, un lleno cargado por sus últimos dígitos (H4) y la
             página del BAPLIE de salida: «1 contenedor a bordo» (P3);
  t100       Estadísticas con el plano de llegada de T-100: tres bahías (02, 06
             y 10), y «Ver como tabla»;
  977        Estadísticas con el sintético de 977: 24 bahías, y la tabla.

python -X utf8 tool/t124_capturas_web.py build/t124/capturas/web --url http://127.0.0.1:5904/
"""
import argparse
import sys
import time
from pathlib import Path

from playwright.sync_api import sync_playwright

sys.path.insert(0, str(Path(__file__).resolve().parent))
from t114_primera_web import PUBLICADO_JS, abrir, desplazar_hasta, esperar, hay, nuevo_contexto, pulsar  # noqa: E402
from t122_capturas_web import Fotos, confirmar_carga, confirmar_plano, panel  # noqa: E402
from t123_capturas_web import cerrar_el_plano, destino, elegir_modo, volver  # noqa: E402


def confirmar_buque_nuevo(page):
    """El previo de un buque que el equipo no conoce: «Confirmar», «Perfil del
    buque nuevo» → «Proponer desde el archivo», sin límite de apilamiento y
    «Confirmar y ver», como la oficina."""
    esperar(page, '^Confirmar$', 60)
    time.sleep(1)
    pulsar(page, '^Confirmar$')
    esperar(page, 'Parámetros del buque|^Proponer desde el archivo|^Revisar ampliación$')
    if hay(page, '^Proponer desde el archivo'):
        pulsar(page, '^Proponer desde el archivo')
    if hay(page, '^Revisar ampliación$'):
        pulsar(page, '^Revisar ampliación$')
    esperar(page, 'Parámetros del buque')
    esperar(page, '^Sin declarar$', 30)
    time.sleep(1.5)
    desplazar_hasta(page, '^No lo tengo')
    if not page.evaluate("""() => Array.from(document.querySelectorAll('flt-semantics'))
        .some((n) => /^No lo tengo/.test(n.getAttribute('aria-label') || n.textContent || '')
                     && n.getAttribute('aria-checked') === 'true')"""):
        pulsar(page, '^No lo tengo')
    desplazar_hasta(page, '^Confirmar y ver')
    pulsar(page, '^Confirmar y ver')
    page.wait_for_function(PUBLICADO_JS, timeout=90000)
    time.sleep(4.5)


def bahia(page, numero):
    pulsar(page, rf'^Bahía {numero},')
    time.sleep(1.2)


def ficha(page, f):
    panel(page, '^Plan de carga$')
    pulsar(page, '^Seleccionar archivo')
    confirmar_plano(page, f)
    elegir_modo(page, 'Carga')
    for numero in (21, 22, 26):
        bahia(page, numero)
        esperar(page, rf'Bahía {numero}: ')
        f.foto(f'ficha_{numero}_carga')
    elegir_modo(page, 'Contenido')
    bahia(page, 23)
    f.foto('ficha_23_contenido')


def salida(page, f):
    elegir_modo(page, 'Carga')
    pulsar(page, '^OR / últimos dígitos')
    esperar(page, 'Confirmar carga por OR o contenedor')
    page.keyboard.type('0071')
    time.sleep(1.2)
    pulsar(page, '^TSTU0220071 · sin OR en el listado')
    confirmar_carga(page, f, 'salida_carga_sin_or')
    time.sleep(4)
    destino(page, 'Lista')
    desplazar_hasta(page, '^Generar BAPLIE de salida')
    pulsar(page, '^Generar BAPLIE de salida')
    esperar(page, 'a bordo en la salida', 30)
    f.foto('salida_1_contenedor')
    volver(page)
    destino(page, 'Plano')


def estadisticas(page, f, url, entrada, nombre):
    cerrar_el_plano(page, url)
    panel(page, rf'^{entrada}$')
    pulsar(page, '^Seleccionar archivo')
    confirmar_buque_nuevo(page)
    destino(page, 'Estadísticas')
    esperar(page, 'contenedores a bordo', 40)
    time.sleep(1.5)
    # El puntero fuera de la silueta: su descripción emergente no tapa nada.
    page.mouse.move(5, 1075)
    time.sleep(0.6)
    f.foto(f'estadisticas_{nombre}')
    pulsar(page, '^Ver como tabla')
    esperar(page, '^Ver como gráficos')
    page.mouse.move(5, 1075)
    time.sleep(1.2)
    f.foto(f'estadisticas_{nombre}_tabla')
    page.mouse.move(900, 700)
    page.mouse.wheel(0, 500)
    page.mouse.move(5, 1075)
    time.sleep(1)
    f.foto(f'estadisticas_{nombre}_tabla_bahias')
    page.mouse.move(900, 700)
    page.mouse.wheel(0, -4000)
    time.sleep(0.6)
    if hay(page, '^Ver como gráficos'):
        pulsar(page, '^Ver como gráficos')
        time.sleep(1)


def recorrido(navegador, url, out, tema, solo_estadisticas=False):
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
        if not solo_estadisticas:
            ficha(page, f)
            salida(page, f)
        estadisticas(page, f, url, 'Llegada T100', 't100')
        estadisticas(page, f, url, 'Sintético 977', '977')
    except Exception:
        page.screenshot(path=str(out / f'_error_{tema}.png'))
        raise
    finally:
        contexto.close()


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5904/')
    p.add_argument('--tema', choices=['claro', 'oscuro', 'ambos'], default='ambos')
    p.add_argument('--solo-estadisticas', action='store_true',
                   help='solo Estadísticas (T100 y 977), en un perfil nuevo')
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
                recorrido(navegador, args.url, out, t, args.solo_estadisticas)
        finally:
            navegador.close()
    print('capturas:', sorted(r.name for r in out.glob('*.png')))


if __name__ == '__main__':
    raise SystemExit(main())
