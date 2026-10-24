"""T-114 · Fase 3, entrega 2: capturas del plano por bahía en la Web.

Con el mismo Chrome de Playwright de tool/t114_primera_web.py (perfil
temporal, ventana visible, sin cuentas), sobre el banco r4 servido en
127.0.0.1. Publica primero el plan de carga (T100_CARGA.edi) confirmando su
perfil como lo haría la oficina, lo que deja la escala GTSTC confirmada; con
eso el plano de llegada (T100_LLEGADA.edi) abre publicado en GTSTC (DESIGN.md
7.2) y ofrece Descarga y «Avance». Por cada tamaño de vista (360x800,
600x960, 1280x800, 1920x1080) y tema (claro, oscuro, siguiendo al sistema),
vuelve a abrir la app, abre el plano de llegada y captura el plano, el modo
Descarga, la lista, el avance y la hoja «Más». Los PNG van a la salida en
TEMP: web_<ancho>_<tema>_<pantalla>.png.

python tool/t114_capturas_web_plano.py <salida en TEMP> --url http://127.0.0.1:5899/
"""
import argparse
import sys
import time

from playwright.sync_api import sync_playwright

from t114_primera_web import abrir, confirmar_perfil, esperar, hay, limpiar, medir, nuevo_contexto, pulsar
from t98_inventario import output_directory


def entrar_al_plano(page, archivo):
    """Abrir el archivo: con el perfil y la escala ya confirmados (7.2), el
    plano de llegada abre publicado y el Plano es lo primero."""
    medir(page, f'/t114/{archivo}')
    esperar(page, 'Bahía|Silueta del buque', 60)
    # El aviso «Archivo cargado correctamente» dura 4 s: se deja pasar.
    time.sleep(5)


def elegir_descarga(page):
    """El modo Descarga: el segmento de la cabecera (oficina) o de la banda del
    muelle si está a la vista; a 360, el desplegable del modo («Contenido» →
    «Descarga»). Devuelve False si el plano no ofrece Descarga."""
    if hay(page, '^Descarga$'):
        pulsar(page, '^Descarga$')
        return True
    if hay(page, '^Contenido$'):
        pulsar(page, '^Contenido$')
        time.sleep(1)
        if hay(page, '^Descarga$'):
            pulsar(page, '^Descarga$')
            return True
        page.keyboard.press('Escape')  # cierra el desplegable sin elegir
    return False


def destino(page, rotulo):
    """Un destino de la barra inferior o del riel, por su rótulo."""
    pulsar(page, f'^{rotulo}')
    time.sleep(1)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5899/')
    p.add_argument('--publicado', default='T100_CARGA.edi',
                   help='se publica primero, confirmando el perfil: deja la escala GTSTC confirmada')
    p.add_argument('--archivo', default='T100_LLEGADA.edi',
                   help='bajo /t114/ del servidor; el plano de llegada, que abre publicado en GTSTC')
    p.add_argument('--vistas', default='360x800,600x960,1280x800,1920x1080')
    args = p.parse_args()
    if not args.url.startswith('http://127.0.0.1:'):
        raise ValueError('Solo el banco servido en 127.0.0.1.')
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    vistas = [tuple(int(v) for v in vista.split('x')) for vista in args.vistas.split(',')]
    with sync_playwright() as pw:
        navegador = pw.chromium.launch(channel='chrome', headless=False,
                                       args=['--window-size=1960,1120', '--window-position=0,0'])
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
                    entrar_al_plano(page, args.archivo)
                    page.screenshot(path=str(out / f'web_{ancho}_{tema}_plano.png'))
                    # El modo Descarga: el segmento de la cabecera (oficina), el de
                    # la banda del muelle o el desplegable del modo (360), si el
                    # plano lo ofrece.
                    if elegir_descarga(page):
                        time.sleep(1.2)
                        page.screenshot(path=str(out / f'web_{ancho}_{tema}_plano_descarga.png'))
                    destino(page, 'Lista')
                    page.screenshot(path=str(out / f'web_{ancho}_{tema}_lista.png'))
                    if hay(page, '^Avance'):
                        destino(page, 'Avance')
                        page.screenshot(path=str(out / f'web_{ancho}_{tema}_avance.png'))
                    # «Más» solo existe desde la entrega 2: el mismo recorrido sirve
                    # para el «antes» (las pestañas de la entrega 1).
                    if hay(page, '^Más'):
                        destino(page, 'Más')
                        page.screenshot(path=str(out / f'web_{ancho}_{tema}_mas.png'))
                        page.keyboard.press('Escape')
                        time.sleep(0.6)
        finally:
            navegador.close()
    print('capturas:', sorted(ruta.name for ruta in out.glob('*.png')))
    return 0


if __name__ == '__main__':
    sys.exit(main())
