"""T-125 · Capturas de Estadísticas con los vacíos asignados, en la Web
(1920 × 1080, la oficina).

Con el Chrome de Playwright (perfil temporal por tema, ventana visible, sin
cuentas) sobre el banco tool/t124_main.dart compilado con la 3.2.0 y servido
en 127.0.0.1, con los ayudantes de tool/t122_capturas_web.py,
tool/t123_capturas_web.py y tool/t124_capturas_web.py. Por cada tema, en un
almacén nuevo:

  0_asignados   el plan de carga de T-122 con su listado importado: Estadísticas
                cuenta lo del archivo y no hay ficha (como antes);
  1_asignado    «Asignar vacío» con el OR 12 en la reserva 021-00-84: la
                protagonista sube y la ficha dice «Incluye: 1 vacío asignado a
                una celda reservada, que el archivo no trae» (DESIGN.md 15.13);
  2_asignados   el OR 13 en la reserva 022-00-84: la ficha en plural.

De cada una, los gráficos y «Ver como tabla» (el resumen con la fila
«Vacíos asignados»).

python -X utf8 tool/t125_capturas_web.py build/t125/capturas/web --url http://127.0.0.1:5905/
"""
import argparse
import sys
import time
from pathlib import Path

from playwright.sync_api import sync_playwright

sys.path.insert(0, str(Path(__file__).resolve().parent))
from t114_primera_web import abrir, desplazar_hasta, esperar, hay, nuevo_contexto, pulsar  # noqa: E402
from t122_capturas_web import Fotos, panel  # noqa: E402
from t123_capturas_web import accion, destino, elegir_modo, volver  # noqa: E402
from t124_capturas_web import bahia, confirmar_buque_nuevo  # noqa: E402
from t73_listado_sintetico import box  # noqa: E402


def estadisticas(page, f, nombre, esperado):
    """Estadísticas y su tabla, con el puntero fuera de la silueta."""
    destino(page, 'Estadísticas')
    esperar(page, esperado, 40)
    time.sleep(1.5)
    page.mouse.move(5, 1075)
    time.sleep(0.6)
    f.foto(f'estadisticas_{nombre}')
    pulsar(page, '^Ver como tabla')
    esperar(page, '^Ver como gráficos')
    page.mouse.move(5, 1075)
    time.sleep(1.2)
    f.foto(f'estadisticas_{nombre}_tabla')
    pulsar(page, '^Ver como gráficos')
    time.sleep(1)


def asignar(page, orden, numero, celda=None):
    """«Acciones» → «Asignar vacío» → el vacío del listado; la celda que el
    formulario propone, o [celda] si se pide; «Confirmar carga»."""
    accion(page, '^Asignar vacío$')
    pulsar(page, rf'^OR {orden} · {numero}')
    esperar(page, '^Asignar vacío$')
    if celda:
        pulsar(page, '^Celda reservada')
        time.sleep(0.8)
        pulsar(page, rf'^{celda}')
        time.sleep(0.8)
    pulsar(page, '^Confirmar carga$')
    time.sleep(4.5)


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
        # El plan de carga de T-122 y su listado.
        panel(page, '^Plan de carga$')
        pulsar(page, '^Seleccionar archivo')
        confirmar_buque_nuevo(page)
        destino(page, 'Lista')
        desplazar_hasta(page, '^Listado de la agencia')
        pulsar(page, '^Listado de la agencia')
        esperar(page, '^Elegir listado')
        panel(page, r'^Listado \(H3\)$')
        pulsar(page, '^Elegir listado')
        esperar(page, '^Confirmar e importar', 30)
        pulsar(page, '^Confirmar e importar')
        esperar(page, 'guardado en la operación|Listado guardado', 30)
        volver(page)
        estadisticas(page, f, '0_asignados', 'contenedores a bordo')
        if hay(page, '^Incluye: '):
            raise AssertionError('Sin vacíos asignados no tiene que haber ficha')
        # Un vacío asignado, y después otro.
        destino(page, 'Plano')
        elegir_modo(page, 'Carga')
        bahia(page, 21)
        asignar(page, 12, box('TSTU001212'), '021-00-84')
        estadisticas(page, f, '1_asignado',
                     '^Incluye: 1 vacío asignado a una celda reservada, que el archivo no trae$')
        destino(page, 'Plano')
        bahia(page, 22)
        asignar(page, 13, box('TSTU001213'), '022-00-84')
        estadisticas(page, f, '2_asignados',
                     '^Incluye: 2 vacíos asignados a celdas reservadas, que el archivo no trae$')
    except Exception:
        page.screenshot(path=str(out / f'_error_{tema}.png'))
        raise
    finally:
        contexto.close()


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5905/')
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
