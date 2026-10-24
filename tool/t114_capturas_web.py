"""T-114 · Fase 3, entrega 1: capturas del inicio y del previo en la Web.

Con el mismo Chrome de Playwright de tool/t114_primera_web.py (perfil
temporal, ventana visible, sin cuentas), sobre el banco r4 servido en
127.0.0.1. Primero publica T100_CARGA.edi confirmando su perfil como lo haría
la oficina, para que el inicio tenga un reciente y un perfil guardado; luego,
por cada tamaño de vista (360x800, 600x960, 1280x800) y tema (claro, oscuro),
captura el inicio y el previo de T99_SINTETICO_977.edi, que abre en previo
porque su buque no tiene perfil. Navegar de nuevo descarta el previo sin
guardarlo. Los PNG van a la salida en TEMP: web_<ancho>_<tema>_<pantalla>.png.

python tool/t114_capturas_web.py <salida en TEMP> --url http://127.0.0.1:5899/
"""
import argparse
import sys
import time

from playwright.sync_api import sync_playwright

from t114_primera_web import abrir, confirmar_perfil, limpiar, medir, nuevo_contexto
from t98_inventario import output_directory


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5899/')
    p.add_argument('--publicado', default='T100_CARGA.edi')
    p.add_argument('--previo', default='T99_SINTETICO_977.edi')
    p.add_argument('--vistas', default='360x800,600x960,1280x800')
    args = p.parse_args()
    if not args.url.startswith('http://127.0.0.1:'):
        raise ValueError('Solo el banco servido en 127.0.0.1.')
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    vistas = [tuple(int(v) for v in vista.split('x')) for vista in args.vistas.split(',')]
    with sync_playwright() as pw:
        navegador = pw.chromium.launch(channel='chrome', headless=False,
                                       args=['--window-size=1400,1000', '--window-position=40,40'])
        contexto, page = nuevo_contexto(navegador, 'light', viewport={'width': 1280, 'height': 800})
        try:
            abrir(page, args.url)
            limpiar(page)
            abrir(page, args.url)
            medir(page, f'/t114/{args.publicado}')
            confirmar_perfil(page)
            for ancho, alto in vistas:
                page.set_viewport_size({'width': ancho, 'height': alto})
                for tema, esquema in (('claro', 'light'), ('oscuro', 'dark')):
                    page.emulate_media(color_scheme=esquema)
                    abrir(page, args.url)
                    time.sleep(1)
                    page.screenshot(path=str(out / f'web_{ancho}_{tema}_inicio.png'))
                    medir(page, f'/t114/{args.previo}')
                    time.sleep(1)
                    page.screenshot(path=str(out / f'web_{ancho}_{tema}_previo.png'))
        finally:
            navegador.close()
    print('capturas:', sorted(ruta.name for ruta in out.glob('*.png')))
    return 0


if __name__ == '__main__':
    sys.exit(main())
