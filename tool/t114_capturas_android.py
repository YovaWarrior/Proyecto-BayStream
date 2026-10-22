"""T-114 · Fase 3, entrega 1: capturas reales del inicio y del previo en Android.

Para el emulador (API 26, serial emulator-5554, a 360 dp con `wm density 480`)
con el banco r4. Recorre, con ADB y uiautomator como tool/t114_primera_android.py:
  - el inicio y el previo con la letra del sistema a 1.0, 1.45 y 2.0
    (`settings put system font_scale`), en claro;
  - los dos en oscuro a 1.0, eligiendo «Oscuro» en Parámetros → Tema.
Deja la letra en 1.0 y el tema en «Seguir al sistema» al terminar. Con
--reiniciar-datos borra los datos del banco r4 y publica antes el plan de carga
(T100_CARGA.edi, confirmando su perfil como la oficina) y lo cierra, para que
el inicio tenga un reciente y un perfil guardado. El previo se abre con
T99_SINTETICO_977.edi, otro buque sin perfil (buque nuevo): con el perfil de
BUQUE MANUAL confirmado en GTSTC, T100_LLEGADA.edi abre publicado por 7.2 de
DESIGN.md (propone esa misma escala), así que no sirve para el previo aquí; el
previo del hallazgo 5 está en las capturas del arnés de Windows, donde el
conductor deja el historial de escala en USHOU. Los PNG se guardan con
`screencap`.

python tool/t114_capturas_android.py <salida en TEMP> --reiniciar-datos
"""
import argparse
import os
import re
import subprocess
import time
from pathlib import Path

import t98_honor_ui
from t114_primera_android import elegir_en_selector
from t98_inventario import output_directory
from t98_recuperacion_honor import position

ADB = t98_honor_ui.ADB
CARPETA_REMOTA = '/sdcard/Download/t114'


def adb(*args):
    return subprocess.run([ADB, *args], capture_output=True, check=True).stdout


def tap(point):
    adb('shell', 'input', 'tap', str(point[0]), str(point[1]))


def observe(selector=False, pattern=None):
    return t98_honor_ui.observe(selector, pattern)


def esperar(patron, intentos=30, selector=False):
    for _ in range(intentos):
        rows = observe(selector, patron)
        if rows:
            return rows
        time.sleep(0.5)
    raise RuntimeError(f'No apareció: {patron}')


def tocar_texto(texto, selector=False, intentos=30):
    rows = esperar(re.escape(texto), intentos, selector)
    tap(position(rows, texto))


def captura(out, nombre):
    destino = out / f'{nombre}.png'
    destino.write_bytes(adb('exec-out', 'screencap', '-p'))
    return destino


def elegir_archivo(nombre):
    """En el selector del sistema: cajón de raíces, Descargas, t114 y el archivo."""
    tap(elegir_en_selector(nombre))


def abrir_en_previo(nombre):
    tocar_texto('Seleccionar archivo')
    time.sleep(1)
    elegir_archivo(nombre)
    # Con la letra grande la tira de bahías queda bajo el borde y el árbol de
    # Android solo trae lo visible: la banda del previo también vale como fin.
    esperar(r'bah[ií]a|Plano sin confirmar|confirma la escala|confirma el buque', 60)
    time.sleep(1.5)


def descartar_previo():
    # «Limpiar datos» está en la barra; desde la Lista no se pliega.
    tocar_texto('Lista')
    time.sleep(1)
    rows = observe(False, r'Limpiar datos')
    if not rows:
        # La tira de acciones a 360 dp: deslizar hasta el final.
        adb('shell', 'input', 'swipe', '650', '120', '250', '120', '300')
        time.sleep(1)
    tocar_texto('Limpiar datos')
    # En previo pregunta «¿Descartar el plano sin confirmar?»; publicado, limpia sin más.
    for _ in range(20):
        rows = observe(False, r'^Descartar$|^Seleccionar archivo$')
        if any(t == 'Descartar' for _, t in rows):
            tap(position(rows, 'Descartar'))
            break
        if any(t == 'Seleccionar archivo' for _, t in rows):
            break
        time.sleep(0.5)
    esperar(r'Seleccionar archivo')
    time.sleep(1)


def publicar_y_cerrar(nombre):
    """Como lo haría la oficina: abrir, Confirmar, sin límite, confirmar."""
    tocar_texto('Seleccionar archivo')
    time.sleep(1)
    elegir_archivo(nombre)
    esperar(r'Bah[ií]a', 60)
    tocar_texto('Confirmar')
    esperar(r'Parámetros del buque')
    for _ in range(12):
        rows = observe(False, r'No lo tengo')
        if rows:
            break
        # Despacio y corto: un deslizamiento rápido lanza la lista y se salta
        # la sección del límite de apilamiento («No lo tengo»).
        adb('shell', 'input', 'swipe', '400', '1300', '400', '700', '400')
        time.sleep(0.8)
    tocar_texto('No lo tengo')
    for _ in range(6):
        rows = observe(False, r'Confirmar y ver')
        if rows:
            break
        # Despacio y corto: un deslizamiento rápido lanza la lista y se salta
        # la sección del límite de apilamiento («No lo tengo»).
        adb('shell', 'input', 'swipe', '400', '1300', '400', '700', '400')
        time.sleep(0.8)
    rows = observe(False, r'Confirmar y ver')
    tap(position(rows, [t for _, t in rows][0]))
    esperar(r'Bah[ií]a', 60)
    time.sleep(1.5)
    descartar_o_limpiar_publicado()


def descartar_o_limpiar_publicado():
    tocar_texto('Lista')
    time.sleep(1)
    rows = observe(False, r'Limpiar datos')
    if not rows:
        adb('shell', 'input', 'swipe', '650', '120', '250', '120', '300')
        time.sleep(1)
    tocar_texto('Limpiar datos')
    esperar(r'Seleccionar archivo')
    time.sleep(1)


def tema(nombre):
    tocar_texto('Parámetros')
    time.sleep(1)
    tocar_texto('Tema')
    time.sleep(0.8)
    tocar_texto(nombre)
    time.sleep(0.8)
    adb('shell', 'input', 'keyevent', '4')  # vuelve al inicio (no es la raíz)
    esperar(r'Seleccionar archivo')
    time.sleep(1)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('salida')
    p.add_argument('--serial', default='emulator-5554')
    p.add_argument('--paquete', default='gt.cmartinez.baystream.r4')
    p.add_argument('--reiniciar-datos', action='store_true')
    p.add_argument('--publicado', default='T100_CARGA.edi', help='se publica con --reiniciar-datos')
    p.add_argument('--previo', default='T99_SINTETICO_977.edi', help='otro buque, sin perfil')
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
            captura(out, f'emulador_360_claro_letra{letra}_inicio')
            abrir_en_previo(args.previo)
            captura(out, f'emulador_360_claro_letra{letra}_previo')
            descartar_previo()
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
        time.sleep(2)
        esperar(r'Seleccionar archivo')
        tema('Oscuro')
        captura(out, 'emulador_360_oscuro_letra1.0_inicio')
        abrir_en_previo(args.previo)
        captura(out, 'emulador_360_oscuro_letra1.0_previo')
        descartar_previo()
        tema('Seguir al sistema')
    finally:
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
    print('capturas:', sorted(p.name for p in out.glob('*.png')))


if __name__ == '__main__':
    main()
