"""T-121 · Entrega 2: capturas reales de Estadísticas en Android.

Para el emulador (API 26, serial emulator-5554, a 360 dp) con el banco r4,
con ADB y uiautomator como tool/t114_capturas_android_plano.py. Con
--reiniciar-datos borra los datos del banco. Abre el sintético de 977
contenedores en 72 bahías (T99_SINTETICO_977.edi, en /sdcard/Download/t114/)
y, si abre en previo (sin perfil), confirma su perfil como lo haría la
oficina, sin límite de apilamiento: queda publicado, sin escala, y la vez
siguiente abre publicado por DESIGN.md 7.2. En Estadísticas (DESIGN.md 15)
captura, con la letra del sistema a 1.0, 1.45 y 2.0 en claro y a 1.0 en
oscuro (Parámetros → Tema; --letras y --letras-oscuro las cambian): la página
(«977 contenedores a bordo»), la pila por peso, la popa de la silueta
desplazada hasta el final y «Ver como tabla». Con --archivo, otro sintético de
la misma carpeta (T100_LLEGADA.edi, nueve bahías).
Deja la letra en 1.0 y el tema en «Seguir al sistema». Nunca el Honor; nunca
«Nube y cuenta». Los PNG se guardan con `screencap`:
emulador_360_<tema>_letra<escala>_<pantalla>.png.

python tool/t121_capturas_android.py <salida en TEMP> --reiniciar-datos
"""
import argparse
import os
import re
import time

import t98_honor_ui
from t114_capturas_android import adb, captura, elegir_archivo, esperar, observe, tap, tema, tocar_texto
from t114_capturas_android_plano import cerrar_el_plano, tocar_entero
from t98_inventario import output_directory
from t98_recuperacion_honor import position

PROTAGONISTA = r'contenedores a bordo'


def tocar(patron):
    rows = esperar(patron)
    tap(position(rows, rows[0][1]))


def arriba(veces=3):
    """La página de vuelta al principio: deslizar hacia abajo, despacio."""
    for _ in range(veces):
        adb('shell', 'input', 'swipe', '540', '700', '540', '1500', '300')
        time.sleep(0.6)
    time.sleep(0.8)


def publicar(nombre):
    """Abrir el archivo desde el inicio; si abre en previo, confirmar como la
    oficina. Después, el aviso «Archivo cargado correctamente» dura 4 s."""
    tocar_texto('Seleccionar archivo')
    time.sleep(1)
    elegir_archivo(nombre)
    esperar(r'Bah[ií]a|Plano sin confirmar|confirma el buque|confirma la escala', 90)
    time.sleep(1.5)
    if observe(False, r'^Confirmar$'):
        tocar_texto('Confirmar')
        esperar(r'Parámetros del buque')
        tocar_entero(r'No lo tengo', 12)
        tocar_entero(r'Confirmar y ver', 8)
        esperar(r'Bah[ií]a', 60)
    time.sleep(4)


def a_estadisticas():
    """El destino de la barra inferior: uiautomator trae el rótulo corto
    («Estad. | Pestaña 4 de 5»), no el nombre entero de la descripción
    emergente."""
    tocar(r'^Estad\.')
    esperar(PROTAGONISTA, 40)
    time.sleep(1.2)


def caja_de(patron):
    rows = observe(False, patron)
    if not rows:
        return None
    return tuple(map(int, re.findall(r'\d+', rows[0][0])))


def a_la_vista(patron, tope=740, paso=250, intentos=14):
    """Baja por la página, despacio, hasta que el control con `patron` quede
    arriba de la pantalla, debajo de la banda (a 360 × 640 la silueta y los
    paneles quedan bajo el pliegue; el árbol de Android solo trae lo visible,
    y lo visible empieza a unos 480 px, bajo la banda del muelle). El paso es
    menor que la ventana de parada (480 a `tope`) para no pasar de largo."""
    for _ in range(intentos):
        caja = caja_de(patron)
        if caja and caja[1] <= tope:
            return True
        adb('shell', 'input', 'swipe', '540', '1300', '540', str(1300 - paso), '300')
        time.sleep(0.7)
    return caja_de(patron) is not None


def recorrido(out, prefijo, registro):
    arriba()
    registro.append((prefijo, 'estadisticas', [t for _, t in observe()]))
    captura(out, f'{prefijo}_estadisticas')
    # La silueta a la vista (bajo el pliegue a 360 × 640).
    if a_la_vista(r'^El buque en corte'):
        captura(out, f'{prefijo}_estadisticas_silueta')
    # La pila por peso: el segmento puede quedar bajo el pliegue.
    tocar_entero(r'^Peso$', 8)
    time.sleep(1.5)
    a_la_vista(r'^El buque en corte')
    captura(out, f'{prefijo}_estadisticas_peso')
    # La popa: la silueta desplazada hasta el final, con el dedo sobre ella.
    caja = caja_de(r'^El buque en corte')
    if caja:
        izquierda, alto, derecha, bajo = caja
        y = (alto + bajo) // 2
        for _ in range(6):
            adb('shell', 'input', 'swipe', str(derecha - 60), str(y), str(izquierda + 60), str(y), '250')
            time.sleep(0.4)
        time.sleep(1)
        captura(out, f'{prefijo}_estadisticas_popa')
        for _ in range(6):
            adb('shell', 'input', 'swipe', str(izquierda + 60), str(y), str(derecha - 60), str(y), '250')
            time.sleep(0.4)
    else:
        registro.append((prefijo, 'sin-silueta-en-el-arbol', []))
    tocar_entero(r'^Contenedores$', 8)
    time.sleep(1)
    # Los paneles de abajo.
    if a_la_vista(r'^Por puerto de descarga'):
        captura(out, f'{prefijo}_estadisticas_paneles')
    arriba(5)
    # Las mismas cifras en tablas, y de vuelta a los gráficos.
    tocar_texto('Ver como tabla')
    time.sleep(1.5)
    arriba()
    captura(out, f'{prefijo}_estadisticas_tabla')
    tocar_texto('Ver como gráficos')
    time.sleep(1)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--serial', default='emulator-5554')
    p.add_argument('--paquete', default='gt.cmartinez.baystream.r4')
    p.add_argument('--reiniciar-datos', action='store_true')
    p.add_argument('--archivo', default='T99_SINTETICO_977.edi',
                   help='el sintético de 977 en 72 bahías, en /sdcard/Download/t114/')
    p.add_argument('--letras', default='1.0,1.45,2.0', help='las letras en claro')
    p.add_argument('--letras-oscuro', default='1.0', help='las letras en oscuro')
    args = p.parse_args()
    if args.serial != 'emulator-5554' and not os.environ.get('T114_HONOR_AUTORIZADO'):
        raise ValueError('El Honor solo con el permiso de Carlos (T114_HONOR_AUTORIZADO=1).')
    os.environ['ANDROID_SERIAL'] = args.serial
    t98_honor_ui.PACKAGE = args.paquete
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    registro = []
    adb('shell', 'am', 'force-stop', args.paquete)
    if args.reiniciar_datos:
        adb('shell', 'pm', 'clear', args.paquete)
    try:
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
        adb('shell', 'monkey', '-p', args.paquete, '-c', 'android.intent.category.LAUNCHER', '1')
        esperar(r'Seleccionar archivo')
        time.sleep(1.5)
        tema('Seguir al sistema')
        publicar(args.archivo)
        a_estadisticas()
        for letra in args.letras.split(','):
            adb('shell', 'settings', 'put', 'system', 'font_scale', letra)
            time.sleep(2.5)
            esperar(PROTAGONISTA, 40)
            recorrido(out, f'emulador_360_claro_letra{letra}', registro)
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
        time.sleep(2)
        cerrar_el_plano()
        tema('Oscuro')
        publicar(args.archivo)
        a_estadisticas()
        for letra in args.letras_oscuro.split(','):
            adb('shell', 'settings', 'put', 'system', 'font_scale', letra)
            time.sleep(2.5)
            esperar(PROTAGONISTA, 40)
            recorrido(out, f'emulador_360_oscuro_letra{letra}', registro)
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
        time.sleep(2)
        cerrar_el_plano()
        tema('Seguir al sistema')
    finally:
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
        with open(out / 'registro.txt', 'w', encoding='utf-8') as f:
            for prefijo, paso, textos in registro:
                f.write(f'{prefijo} {paso}: {" | ".join(textos)}\n')
    print('capturas:', sorted(ruta.name for ruta in out.glob('*.png')))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
