"""T-122 · Corrección 1: la página del BAPLIE de salida con un lleno sin fila.

Sobre el banco tool/t122_main.dart servido en 127.0.0.1 (Playwright, 1920 ×
1080, la oficina): abre el plan de carga, lo confirma, **sin importar el
listado** carga un lleno por sus últimos dígitos (H4) y abre «Generar BAPLIE
de salida» desde la Lista. La página dice que ese lleno va con los datos del
plan de carga porque no tiene fila en el listado. Una captura por tema.

python -X utf8 tool/t122_c1_captura_web.py build/t122/c1/capturas --url http://127.0.0.1:5902/
"""
import argparse
import sys
import time
from pathlib import Path

from playwright.sync_api import sync_playwright

sys.path.insert(0, str(Path(__file__).resolve().parent))
from t114_primera_web import abrir, desplazar_hasta, esperar, nuevo_contexto, pulsar  # noqa: E402
from t122_capturas_web import Fotos, confirmar_carga, confirmar_plano, destino, panel  # noqa: E402


def recorrido(navegador, url, out, tema):
    contexto, page = nuevo_contexto(navegador, 'dark' if tema == 'oscuro' else 'light',
                                    viewport={'width': 1920, 'height': 1080})
    f = Fotos(page, out, f'web_{tema}_c1')
    try:
        abrir(page, url)
        page.set_default_timeout(60000)
        esperar(page, '^Seleccionar archivo', 60)
        time.sleep(1.5)
        panel(page, f'^Tema {tema}$', '^Plan de carga$')
        pulsar(page, '^Seleccionar archivo')
        confirmar_plano(page, f)
        pulsar(page, r'^Carga(?:\n|$)')
        time.sleep(1)
        pulsar(page, '^OR / últimos dígitos$')
        esperar(page, 'Confirmar carga por OR o contenedor')
        page.keyboard.type('0071')
        time.sleep(1.2)
        pulsar(page, '^TSTU0220071 · sin OR en el listado')
        confirmar_carga(page, f, 'h4_sin_listado_registrado')
        time.sleep(4)
        destino(page, 'Lista')
        desplazar_hasta(page, '^Generar BAPLIE de salida')
        pulsar(page, '^Generar BAPLIE de salida')
        esperar(page, 'contenedores a bordo en la salida', 30)
        esperar(page, 'porque no tiene fila en el listado', 30)
        f.foto('salida_lleno_sin_fila')
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
