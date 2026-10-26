"""T-121 · Entrega 2: capturas de Estadísticas en la Web.

Con el mismo Chrome de Playwright de tool/t114_primera_web.py (perfil
temporal, ventana visible, sin cuentas), sobre el banco r4 servido en
127.0.0.1, y con el sintético de 977 contenedores en 72 bahías
(T99_SINTETICO_977.edi; nunca el corpus real ni «Nube y cuenta»). La primera
vez lo abre y confirma su perfil como lo haría la oficina, sin límite de
apilamiento: queda publicado, sin escala, y después abre publicado por
DESIGN.md 7.2.

Por cada tamaño de vista (1920x1080, 1366x768 y 360x800 por omisión) y tema
(claro y oscuro, siguiendo al sistema), vuelve a abrir la app, abre el archivo
y captura Estadísticas (DESIGN.md 15): la página, la pila por peso, la popa de
la silueta desplazada con la rueda y «Ver como tabla». Los PNG van a la
salida en TEMP: web_<ancho>_<tema>_<pantalla>.png.

python tool/t121_capturas_web.py <salida en TEMP> --url http://127.0.0.1:5899/
"""
import argparse
import sys
import time

from playwright.sync_api import sync_playwright

from t114_primera_web import abrir, confirmar_perfil, esperar, hay, limpiar, medir, nuevo_contexto, pulsar
from t98_inventario import output_directory

PROTAGONISTA = 'contenedores a bordo'


def publicar(page, archivo):
    """Abre el archivo; si abre en previo (sin perfil), confirma el perfil."""
    medir(page, f'/t114/{archivo}')
    esperar(page, 'Bahía|Silueta del buque|Plano sin confirmar', 90)
    time.sleep(1)
    if hay(page, '^Confirmar$'):
        confirmar_perfil(page)
    # El aviso «Archivo cargado correctamente» dura 4 s: se deja pasar.
    time.sleep(5)


def aparta(page, ancho):
    """El puntero sobre la protagonista, que no tiene descripción emergente:
    si queda sobre una bahía o una barra, su descripción sale en la captura."""
    page.mouse.move(min(ancho * 0.3, 160), 120)
    time.sleep(0.5)


def arriba(page, ancho, alto):
    page.mouse.move(ancho // 2, alto // 2)
    page.mouse.wheel(0, -20000)
    time.sleep(0.8)
    aparta(page, ancho)


def pulsar_a_la_vista(page, patron, ancho, alto, pasos=12):
    """La semántica de Flutter solo trae lo visible: baja por la página hasta
    ver el control y lo pulsa; si no aparece, vuelve arriba y lo intenta."""
    for _ in range(pasos):
        if hay(page, patron):
            pulsar(page, patron)
            return
        page.mouse.move(ancho // 2, alto - 40)
        page.mouse.wheel(0, 400)
        time.sleep(0.6)
    arriba(page, ancho, alto)
    pulsar(page, patron)


def recorrido(page, foto, ancho, alto, registro):
    pulsar(page, '^Estad')
    esperar(page, PROTAGONISTA, 40)
    time.sleep(1.5)
    arriba(page, ancho, alto)
    foto('estadisticas')
    # La pila por peso.
    pulsar_a_la_vista(page, '^Peso$', ancho, alto)
    time.sleep(1.5)
    arriba(page, ancho, alto)
    foto('estadisticas_peso')
    # La popa: la rueda en horizontal sobre la silueta.
    buque = page.locator('[aria-label^="El buque en corte"]').first
    caja = buque.bounding_box() if buque.count() else None
    if caja:
        page.mouse.move(caja['x'] + caja['width'] / 2, caja['y'] + caja['height'] / 2)
        page.mouse.wheel(20000, 0)
        time.sleep(1.5)
        aparta(page, ancho)
        foto('estadisticas_popa')
        # La silueta se queda en la popa: la rueda de vuelta (hacia la izquierda,
        # ya en el borde) la toma Chrome como el gesto de «atrás» y deja la
        # página en blanco; lo que sigue no la necesita al principio.
    else:
        registro.append(f'{ancho}: la silueta no está en el árbol accesible')
    pulsar_a_la_vista(page, '^Contenedores$', ancho, alto)
    time.sleep(1)
    arriba(page, ancho, alto)
    # Las mismas cifras en tablas, y de vuelta a los gráficos.
    pulsar_a_la_vista(page, '^Ver como tabla', ancho, alto)
    time.sleep(1.5)
    arriba(page, ancho, alto)
    foto('estadisticas_tabla')
    pulsar_a_la_vista(page, '^Ver como gráficos', ancho, alto)
    time.sleep(1)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5899/')
    p.add_argument('--archivo', default='T99_SINTETICO_977.edi',
                   help='bajo /t114/ del servidor; el sintético de 977 en 72 bahías')
    p.add_argument('--vistas', default='1920x1080,1366x768,360x800')
    args = p.parse_args()
    if not args.url.startswith('http://127.0.0.1:'):
        raise ValueError('Solo el banco servido en 127.0.0.1.')
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    vistas = [tuple(int(v) for v in vista.split('x')) for vista in args.vistas.split(',')]
    registro = []
    with sync_playwright() as pw:
        navegador = pw.chromium.launch(channel='chrome', headless=False,
                                       args=['--window-size=1960,1120', '--window-position=0,0'])
        contexto, page = nuevo_contexto(navegador, 'light', viewport={'width': 1280, 'height': 800})
        try:
            abrir(page, args.url)
            limpiar(page)
            abrir(page, args.url)
            publicar(page, args.archivo)
            for ancho, alto in vistas:
                page.set_viewport_size({'width': ancho, 'height': alto})
                for tema, esquema in (('claro', 'light'), ('oscuro', 'dark')):
                    page.emulate_media(color_scheme=esquema)
                    abrir(page, args.url)
                    time.sleep(1)
                    publicar(page, args.archivo)

                    def foto(pantalla):
                        page.screenshot(path=str(out / f'web_{ancho}_{tema}_{pantalla}.png'))

                    try:
                        recorrido(page, foto, ancho, alto, registro)
                    except Exception as error:  # noqa: BLE001 - se anota y sigue con la siguiente vista
                        registro.append(f'{ancho} {tema}: {type(error).__name__}: {str(error).splitlines()[0]}')
                        page.screenshot(path=str(out / f'web_{ancho}_{tema}_fallo.png'))
        finally:
            navegador.close()
            with open(out / 'registro.txt', 'w', encoding='utf-8') as f:
                f.write('\n'.join(registro) + '\n')
    print('capturas:', sorted(ruta.name for ruta in out.glob('*.png')))
    return 0


if __name__ == '__main__':
    sys.exit(main())
