"""T-122 · Corrección 2 (A1): el muelle sin listado no carga un vacío con número.

Sobre el banco tool/t122_main.dart servido en 127.0.0.1 (Playwright, 1920 ×
1080): abre el plan de carga, lo confirma, **sin importar el listado** y como
muelle local, toca en la bahía 21 el vacío con número (TSTU0210284, que el
plan declara vacío) y el contenedor sin estado (TSTU0210480): el aviso dice
que esperan el listado y no se abre «Confirmar carga». En «OR / últimos
dígitos», «0284» no ofrece nada y «0071» ofrece el lleno sin OR, que sí se
carga. Una captura por paso y por tema.

python -X utf8 tool/t122_c2_captura_web.py build/t122/c2/capturas --url http://127.0.0.1:5902/
"""
import argparse
import sys
import time
from pathlib import Path

from playwright.sync_api import sync_playwright

sys.path.insert(0, str(Path(__file__).resolve().parent))
from t114_primera_web import abrir, esperar, hay, nuevo_contexto, pulsar  # noqa: E402
from t122_capturas_web import Fotos, confirmar_carga, confirmar_plano, panel  # noqa: E402


def recorrido(navegador, url, out, tema):
    contexto, page = nuevo_contexto(navegador, 'dark' if tema == 'oscuro' else 'light',
                                    viewport={'width': 1920, 'height': 1080})
    f = Fotos(page, out, f'web_{tema}_c2')
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
        pulsar(page, '^Bahía 21,')
        time.sleep(1)
        # El vacío con número: el aviso, sin diálogo.
        pulsar(page, '^TSTU0210284, sube$')
        esperar(page, 'espera el listado de la agencia', 20)
        f.foto('vacio_con_numero_espera_el_listado')
        assert not hay(page, '^Confirmar carga$'), 'no debe abrir Confirmar carga'
        time.sleep(5)
        # El contenedor sin estado: igual.
        pulsar(page, '^TSTU0210480, sube$')
        esperar(page, 'no declara lleno ni vacío', 20)
        f.foto('sin_estado_espera_el_listado')
        assert not hay(page, '^Confirmar carga$'), 'no debe abrir Confirmar carga'
        time.sleep(5)
        # «OR / últimos dígitos»: el vacío no se ofrece; el lleno sí.
        pulsar(page, '^OR / últimos dígitos$')
        esperar(page, 'Confirmar carga por OR o contenedor')
        time.sleep(0.8)
        f.foto('or_solo_ofrece_llenos')  # la lista sin filtrar: solo llenos sin OR
        page.mouse.click(935, 281)  # el campo de la hoja, antes de escribir
        time.sleep(0.5)
        page.keyboard.type('0284')
        time.sleep(1.2)
        esperar(page, 'No hay coincidencias disponibles', 20)
        f.foto('or_no_ofrece_el_vacio')
        page.keyboard.press('Control+A')
        page.keyboard.type('0071')
        time.sleep(1.2)
        esperar(page, '^TSTU0220071 · sin OR en el listado', 20)
        f.foto('or_ofrece_el_lleno')
        pulsar(page, '^TSTU0220071 · sin OR en el listado')
        confirmar_carga(page, f, 'lleno_sin_fila_registrado')
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
