"""T-114 · Fase 3, entrega 2: capturas reales del plano por bahía en Android.

Para el emulador (API 26, serial emulator-5554, a 360 dp con `wm density 480`)
con el banco r4, con ADB y uiautomator como tool/t114_capturas_android.py.
Con --reiniciar-datos borra los datos del banco, publica el plan de carga
(T100_CARGA.edi) confirmando su perfil como la oficina (deja la escala GTSTC
confirmada) y lo cierra. Después, con la letra del sistema a 1.0, 1.45 y 2.0
en claro, y a 1.0 en oscuro (Parámetros → Tema → Oscuro), abre el plano de
llegada (T100_LLEGADA.edi, que abre publicado en GTSTC por DESIGN.md 7.2: la
banda del muelle ofrece Descarga) y captura el plano, el plano con la rejilla a
la vista (la cabecera se va al desplazar, 13.8), el modo Descarga (y su
rejilla), la lista, el avance y la hoja «Más». Deja
la letra en 1.0 y el tema en «Seguir al sistema». Los PNG se guardan con
`screencap`: emulador_360_<tema>_letra<escala>_<pantalla>.png.

python tool/t114_capturas_android_plano.py <salida en TEMP> --reiniciar-datos
"""
import argparse
import re
import os
import time

import t98_honor_ui
from t114_capturas_android import (abrir_en_previo, adb, captura, descartar_o_limpiar_publicado,
                                   elegir_archivo, esperar, observe, tap, tema, tocar_texto)
from t98_inventario import output_directory
from t98_recuperacion_honor import position


def tocar_entero(texto, intentos=8):
    """Toca un control que puede quedar recortado al pie de la pantalla:
    desliza despacio hasta que uiautomator lo traiga entero."""
    for _ in range(intentos):
        rows = observe(False, texto)
        if rows:
            try:
                tap(position(rows, [t for _, t in rows][0]))
                return
            except RuntimeError:
                pass
        # Despacio y corto: un deslizamiento rápido lanza la lista y se salta
        # la sección del límite de apilamiento («No lo tengo»).
        adb('shell', 'input', 'swipe', '400', '1300', '400', '700', '400')
        time.sleep(0.8)
    raise RuntimeError(f'No se pudo tocar entero: {texto}')


def publicar_y_cerrar(nombre):
    """Como lo haría la oficina: abrir, Confirmar, sin límite, confirmar y
    ver; después «Más» → «Cerrar el plano» (la entrega 2 ya no tiene la barra
    de la Lista con «Limpiar datos»)."""
    tocar_texto('Seleccionar archivo')
    time.sleep(1)
    elegir_archivo(nombre)
    esperar(r'Bah[ií]a', 60)
    tocar_texto('Confirmar')
    esperar(r'Parámetros del buque')
    tocar_entero(r'No lo tengo', 12)
    tocar_entero(r'Confirmar y ver', 8)
    esperar(r'Bah[ií]a', 60)
    time.sleep(1.5)
    cerrar_el_plano()


def entrar_al_plano(archivo):
    """Abrir el archivo: con el perfil y la escala ya confirmados (7.2), el
    plano de llegada abre publicado y el Plano es lo primero."""
    abrir_en_previo(archivo)
    # El aviso «Archivo cargado correctamente» dura 4 s: se deja pasar.
    time.sleep(4)


def atras():
    adb('shell', 'input', 'keyevent', '4')
    time.sleep(0.8)


def _a_la_vista(rows, alto_minimo=100):
    """Si alguna fila trae un control de al menos `alto_minimo` px: la hoja
    puede dejar la última entrada recortada en el borde (position la rechaza)."""
    for bounds, _ in rows:
        _, arriba, _, abajo = map(int, re.findall(r'\d+', bounds))
        if abajo - arriba >= alto_minimo:
            return True
    return False


def cerrar_el_plano():
    """«Más» → «Cerrar el plano» deja el inicio. Sin «Más» (el «antes», con
    pestañas), la barra de la Lista → «Limpiar datos»."""
    if not observe(False, r'^Más(?:\n|$)'):
        descartar_o_limpiar_publicado()
        return
    tocar_texto('Más')
    time.sleep(1)
    # El primer deslizamiento expande la hoja; «Cerrar el plano» es la última
    # entrada y puede hacer falta otro para verla.
    for _ in range(5):
        if _a_la_vista(observe(False, r'Cerrar el plano')):
            break
        adb('shell', 'input', 'swipe', '540', '1400', '540', '900', '300')
        time.sleep(1)
    tocar_texto('Cerrar el plano')
    esperar(r'Seleccionar archivo')
    time.sleep(1)


def elegir_descarga():
    """El modo Descarga: el segmento de la cabecera o de la banda del muelle si
    está a la vista; en el teléfono, el desplegable del modo («Contenido» →
    «Descarga»). Devuelve False si el plano no ofrece Descarga."""
    if observe(False, r'^Descarga$'):
        tocar_texto('Descarga')
        return True
    if observe(False, r'^Contenido$'):
        tocar_texto('Contenido')
        time.sleep(1)
        if observe(False, r'^Descarga$'):
            tocar_texto('Descarga')
            return True
        atras()  # cierra el desplegable sin elegir
    return False


def rejilla_a_la_vista(out, nombre, veces=1):
    """El teléfono bajo (360 × 640): la cabecera del plano se va al desplazar
    la rejilla (DESIGN.md 13.8). El gesto empieza sobre la silueta (y = 1000
    px, dentro del área anidada en los dos modos y con cualquier letra); con
    la letra grande hacen falta dos para pasar el título. Se captura y se
    vuelve arriba, para que los controles sigan a la vista."""
    for _ in range(veces):
        adb('shell', 'input', 'swipe', '540', '1000', '540', '250', '400')
        time.sleep(1.0)
    time.sleep(0.5)
    captura(out, nombre)
    for _ in range(veces + 1):
        adb('shell', 'input', 'swipe', '540', '400', '540', '1500', '400')
        time.sleep(1.0)


def recorrido(out, prefijo):
    veces = 2 if ('letra1.45' in prefijo or 'letra2.0' in prefijo) else 1
    captura(out, f'{prefijo}_plano')
    rejilla_a_la_vista(out, f'{prefijo}_plano_rejilla', veces)
    if elegir_descarga():
        time.sleep(1.5)
        captura(out, f'{prefijo}_plano_descarga')
        rejilla_a_la_vista(out, f'{prefijo}_plano_descarga_rejilla', veces)
    tocar_texto('Lista')
    time.sleep(1.2)
    captura(out, f'{prefijo}_lista')
    if observe(False, r'^Avance(?:\n|$)'):
        tocar_texto('Avance')
        time.sleep(1.5)
        captura(out, f'{prefijo}_avance')
    if observe(False, r'^Más(?:\n|$)'):
        tocar_texto('Más')
        time.sleep(1.2)
        captura(out, f'{prefijo}_mas')
        atras()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('salida')
    p.add_argument('--serial', default='emulator-5554')
    p.add_argument('--paquete', default='gt.cmartinez.baystream.r4')
    p.add_argument('--reiniciar-datos', action='store_true')
    p.add_argument('--publicado', default='T100_CARGA.edi',
                   help='se publica con --reiniciar-datos, confirmando el perfil: deja la escala GTSTC')
    p.add_argument('--archivo', default='T100_LLEGADA.edi',
                   help='el plano de llegada, que abre publicado en GTSTC en cada vuelta')
    args = p.parse_args()
    if args.serial != 'emulator-5554' and not os.environ.get('T114_HONOR_AUTORIZADO'):
        raise ValueError('El Honor solo con el permiso de Carlos (T114_HONOR_AUTORIZADO=1).')
    os.environ['ANDROID_SERIAL'] = args.serial
    t98_honor_ui.PACKAGE = args.paquete
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    adb('shell', 'am', 'force-stop', args.paquete)
    if args.reiniciar_datos:
        adb('shell', 'pm', 'clear', args.paquete)
    try:
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
        adb('shell', 'monkey', '-p', args.paquete, '-c', 'android.intent.category.LAUNCHER', '1')
        esperar(r'Seleccionar archivo')
        time.sleep(1.5)
        tema('Seguir al sistema')
        if args.reiniciar_datos:
            publicar_y_cerrar(args.publicado)
        for letra in ('1.0', '1.45', '2.0'):
            adb('shell', 'settings', 'put', 'system', 'font_scale', letra)
            time.sleep(2)
            esperar(r'Seleccionar archivo')
            time.sleep(1)
            entrar_al_plano(args.archivo)
            recorrido(out, f'emulador_360_claro_letra{letra}')
            cerrar_el_plano()
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
        time.sleep(2)
        esperar(r'Seleccionar archivo')
        tema('Oscuro')
        entrar_al_plano(args.archivo)
        recorrido(out, 'emulador_360_oscuro_letra1.0')
        cerrar_el_plano()
        tema('Seguir al sistema')
    finally:
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
    print('capturas:', sorted(ruta.name for ruta in out.glob('*.png')))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
