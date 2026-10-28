"""T-124 · Capturas de la regla de la par en el emulador (360 × 640 dp,
emulator-5554).

Sobre el banco tool/t124_main.dart (gt.cmartinez.baystream, APK de
depuración), con ADB y los volcados de uiautomator, con los ayudantes de
tool/t122_capturas_android.py y tool/t123_capturas_android.py. Por cada tema:
la ficha de la bahía con la 21 elegida en Carga y en Contenido (14.7); sin
listado, un lleno cargado por sus últimos dígitos y la página del BAPLIE de
salida, «1 contenedor a bordo» (P3); y Estadísticas con el plano de llegada de
T-100 y con el sintético de 977, arriba, la silueta y «Ver como tabla» (15).

python -X utf8 tool/t124_capturas_android.py build/t124/capturas/emulador
"""
import argparse
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import t122_capturas_android as t122  # noqa: E402
from t122_capturas_android import (  # noqa: E402
    PAQUETE, adb, atras, bahia, captura, cerrar_el_plano, confirmar_carga, confirmar_plano,
    deslizar_hasta, esperar, nodos, panel, tema, tocar)
from t123_capturas_android import modo  # noqa: E402


def abrir(entrada, out, prefijo, nuevo=False):
    panel(rf'^{entrada}$')
    tocar(r'^Seleccionar archivo')
    if nuevo:
        confirmar_buque_nuevo()
    else:
        confirmar_plano(out, prefijo)


def confirmar_buque_nuevo():
    """El previo de un buque que el equipo no conoce: «Confirmar», «Perfil del
    buque nuevo» → «Proponer desde el archivo», «No lo tengo» y «Confirmar y
    ver»."""
    esperar(r'^Confirmar$', 60)
    time.sleep(1)
    tocar(r'^Confirmar$')
    for _ in range(25):
        if nodos(r'Parámetros del buque'):
            break
        if nodos(r'^Proponer desde el archivo'):
            tocar(r'^Proponer desde el archivo')
        elif nodos(r'^Revisar ampliación$'):
            tocar(r'^Revisar ampliación$')
        time.sleep(0.8)
    esperar(r'Parámetros del buque')
    time.sleep(0.8)
    deslizar_hasta(r'^No lo tengo')
    if not t122.marcado(r'^No lo tengo'):
        tocar(r'^No lo tengo')
    deslizar_hasta(r'^Confirmar y ver')
    tocar(r'^Confirmar y ver')
    esperar(r'^Bahía \d+,', 90)
    time.sleep(4)


def ficha(out, prefijo):
    abrir('Plan de carga', out, f'{prefijo}_carga')
    modo('Carga')
    bahia(21)
    esperar(r'Bahía 21: ')
    captura(out, f'{prefijo}_ficha_21_carga')
    modo('Contenido')
    bahia(21)
    captura(out, f'{prefijo}_ficha_21_contenido')


def salida(out, prefijo):
    modo('Carga')
    tocar(r'^OR / últimos dígitos')
    esperar(r'Confirmar carga por OR o contenedor')
    # El campo, arriba de la hoja: un toque le da el foco antes de escribir.
    t122.tap(470, 550)
    time.sleep(0.8)
    adb('shell', 'input', 'text', '0071')
    time.sleep(1.2)
    tocar(r'^TSTU0220071 · sin OR en el listado')
    confirmar_carga(out, f'{prefijo}_salida_carga_sin_or')
    time.sleep(4)
    tocar(r'^Lista(?:\n|$)')
    time.sleep(1)
    deslizar_hasta(r'^Generar BAPLIE de salida')
    tocar(r'^Generar BAPLIE de salida')
    esperar(r'a bordo en la salida', 30)
    time.sleep(0.8)
    captura(out, f'{prefijo}_salida_1_contenedor')
    atras()
    time.sleep(1)
    tocar(r'^Plano(?:\n|$)')
    time.sleep(1)


def cerrar_el_plano_t124():
    """«Más» → «Cerrar el plano». En el teléfono «Más» lleva delante la cuenta
    de las alertas («2\nMás\nPestaña 5 de 5»), así que el patrón de T-122
    (empieza por «Más») no la encuentra: aquí basta con una línea «Más»."""
    tocar(r'(?:^|\n)Más(?:\n|$)')
    time.sleep(1)
    for _ in range(5):
        if [n for n in nodos(r'^Cerrar el plano') if n[3] - n[1] >= 60]:
            break
        adb('shell', 'input', 'swipe', '540', '1400', '540', '900', '300')
        time.sleep(1)
    tocar(r'^Cerrar el plano')
    esperar(r'^Seleccionar archivo')
    time.sleep(1)


def subir(veces=1):
    for _ in range(veces):
        adb('shell', 'input', 'swipe', '540', '1300', '540', '700', '600')
        time.sleep(0.8)


def arriba(veces=4):
    for _ in range(veces):
        adb('shell', 'input', 'swipe', '540', '700', '540', '1500', '300')
        time.sleep(0.6)


def estadisticas(out, prefijo, entrada, nombre):
    cerrar_el_plano_t124()
    abrir(entrada, out, f'{prefijo}_{nombre}', nuevo=True)
    tocar(r'^Estad\.')
    esperar(r'contenedores a bordo', 40)
    time.sleep(1.5)
    captura(out, f'{prefijo}_estadisticas_{nombre}')
    # La silueta va bajo la cabecera de cifras: un deslizamiento la sube.
    subir(1)
    time.sleep(0.8)
    captura(out, f'{prefijo}_estadisticas_{nombre}_silueta')
    arriba()
    tocar(r'^Ver como tabla')
    time.sleep(1.5)
    # «Por bahía» va justo debajo del resumen: dos tomas fijas.
    captura(out, f'{prefijo}_estadisticas_{nombre}_tabla')
    subir(1)
    captura(out, f'{prefijo}_estadisticas_{nombre}_tabla_bahias')
    arriba(6)
    if nodos(r'^Ver como gráficos'):
        tocar(r'^Ver como gráficos')
        time.sleep(1)
    tocar(r'^Plano(?:\n|$)')
    time.sleep(1)


def recorrido(out, nombre_tema):
    adb('shell', 'am', 'force-stop', PAQUETE)
    adb('shell', 'pm', 'clear', PAQUETE)
    adb('shell', 'monkey', '-p', PAQUETE, '-c', 'android.intent.category.LAUNCHER', '1')
    esperar(r'^Seleccionar archivo', 60)
    time.sleep(2)
    tema(nombre_tema)
    prefijo = f'emulador_{nombre_tema}'
    ficha(out, prefijo)
    salida(out, prefijo)
    estadisticas(out, prefijo, 'Llegada T100', 't100')
    estadisticas(out, prefijo, 'Sintético 977', '977')


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--tema', choices=['claro', 'oscuro', 'ambos'], default='ambos')
    p.add_argument('--solo-estadisticas', action='store_true',
                   help='solo Estadísticas, sobre lo que ya está en el dispositivo')
    p.add_argument('--desde-salida', action='store_true',
                   help='la salida y Estadísticas, sobre el plan que ya está abierto')
    args = p.parse_args()
    if t122.SERIAL != 'emulator-5554':
        raise ValueError('Solo el emulador: nunca el Honor.')
    out = Path(args.salida)
    out.mkdir(parents=True, exist_ok=True)
    for t in (['claro', 'oscuro'] if args.tema == 'ambos' else [args.tema]):
        try:
            if args.desde_salida:
                adb('shell', 'monkey', '-p', PAQUETE, '-c', 'android.intent.category.LAUNCHER', '1')
                time.sleep(2)
                tema(t)
                tocar(r'^Plano(?:\n|$)')
                time.sleep(1)
                salida(out, f'emulador_{t}')
                estadisticas(out, f'emulador_{t}', 'Llegada T100', 't100')
                estadisticas(out, f'emulador_{t}', 'Sintético 977', '977')
            elif args.solo_estadisticas:
                adb('shell', 'monkey', '-p', PAQUETE, '-c', 'android.intent.category.LAUNCHER', '1')
                time.sleep(2)
                tema(t)
                estadisticas(out, f'emulador_{t}', 'Llegada T100', 't100')
                estadisticas(out, f'emulador_{t}', 'Sintético 977', '977')
            else:
                recorrido(out, t)
        except Exception:
            captura(out, f'_error_{t}')
            raise
    print('capturas:', sorted(r.name for r in out.glob('*.png')))


if __name__ == '__main__':
    raise SystemExit(main())
