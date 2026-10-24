"""T-117 y T-118 · Entrega 1: capturas de la oficina en la Web.

Con el mismo Chrome de Playwright de tool/t114_primera_web.py (perfil
temporal, ventana visible, sin cuentas), sobre el banco r4 servido en
127.0.0.1, y con los datos sintéticos de T-100 (nunca el corpus real ni
«Nube y cuenta»). Publica primero el plan de carga (T100_CARGA.edi)
confirmando su perfil como lo haría la oficina, lo que deja la escala GTSTC
confirmada; con eso el plano de llegada (T100_LLEGADA.edi) abre publicado en
GTSTC (DESIGN.md 7.2) y ofrece Descarga y Carga.

Por cada tamaño de vista (1920x1080 y 1366x768 por omisión) y tema (claro y
oscuro, siguiendo al sistema), vuelve a abrir la app, abre el plano de
llegada y captura la oficina de DESIGN.md 14: el plano en Contenido, en
Descarga y en Carga (elegidos en el selector de modo de la cabecera, en
segmentos o en menú), el panel del buque plegado (su botón en la franja de
la bahía), el panel lateral oculto (su botón en la cabecera) y flotante (el
mouse en el borde derecho). Deja la oficina como la encontró. Los PNG van a
la salida en TEMP: web_<ancho>_<tema>_<pantalla>.png.

python tool/t117_capturas_web.py <salida en TEMP> --url http://127.0.0.1:5899/
"""
import argparse
import sys
import time

from playwright.sync_api import sync_playwright

from t114_capturas_web_plano import entrar_al_plano
from t114_primera_web import abrir, confirmar_perfil, hay, limpiar, medir, nuevo_contexto, pulsar
from t98_inventario import output_directory


def elegir_modo(page, rotulo):
    """El modo en el selector de la cabecera: el segmento si está a la vista
    («Descarga 9»: el rótulo y la cuenta) o, si el selector va en menú, el
    botón «Modo del plano: …» y su entrada. El final aparta las fichas de la
    franja de cifras («Descarga: 28 pendientes») y lo que sigue con letras
    («Descargado» en «En vivo»)."""
    patron = f'^{rotulo}(?![:\\wáéíóúñ])'
    if not hay(page, patron):
        pulsar(page, '^Modo del plano: ')
        time.sleep(0.8)
    pulsar(page, patron)
    time.sleep(1.2)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5899/')
    p.add_argument('--publicado', default='T100_CARGA.edi',
                   help='se publica primero, confirmando el perfil: deja la escala GTSTC confirmada')
    p.add_argument('--archivo', default='T100_LLEGADA.edi',
                   help='bajo /t114/ del servidor; el plano de llegada, que abre publicado en GTSTC')
    p.add_argument('--vistas', default='1920x1080,1366x768')
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

                    def foto(pantalla):
                        page.screenshot(path=str(out / f'web_{ancho}_{tema}_{pantalla}.png'))

                    foto('plano')
                    elegir_modo(page, 'Descarga')
                    foto('plano_descarga')
                    elegir_modo(page, 'Carga')
                    foto('plano_carga')
                    elegir_modo(page, 'Contenido')
                    # El panel del buque plegado y otra vez desplegado.
                    pulsar(page, '^Plegar el panel del buque')
                    time.sleep(1)
                    foto('plano_puente_plegado')
                    pulsar(page, '^Desplegar el panel del buque')
                    time.sleep(1)
                    # El panel lateral oculto y, con el mouse en el borde, flotante
                    # (sale a los 250 ms y se va a los 400 ms de salir).
                    if hay(page, '^Ocultar el panel lateral'):
                        pulsar(page, '^Ocultar el panel lateral')
                        time.sleep(1)
                        foto('plano_panel_oculto')
                        page.mouse.move(ancho - 6, alto // 2)
                        time.sleep(1.2)
                        foto('plano_panel_flotante')
                        page.mouse.move(ancho // 3, alto // 2)
                        time.sleep(1.2)
                        pulsar(page, '^Mostrar el panel lateral')
                        time.sleep(1)
        finally:
            navegador.close()
    print('capturas:', sorted(ruta.name for ruta in out.glob('*.png')))
    return 0


if __name__ == '__main__':
    sys.exit(main())
