"""T-125 · Capturas de Estadísticas con los vacíos asignados en el emulador
(360 × 640 dp, emulator-5554).

Sobre el banco tool/t124_main.dart compilado con la 3.2.0
(gt.cmartinez.baystream, APK de depuración), con ADB y los volcados de
uiautomator, con los ayudantes de tool/t122_capturas_android.py a
tool/t124_capturas_android.py. Por cada tema, en un almacén limpio: el plan de
carga de T-122 con su listado; Estadísticas sin vacíos asignados (sin ficha),
con el OR 12 asignado a la 021-00-84 (la ficha en singular) y con el OR 13 en
una reserva de la 22 (en plural); de cada una, arriba con la ficha y «Ver como
tabla» (DESIGN.md 15.13).

python -X utf8 tool/t125_capturas_android.py build/t125/capturas/emulador
"""
import argparse
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import t122_capturas_android as t122  # noqa: E402
from t122_capturas_android import (  # noqa: E402
    PAQUETE, adb, bahia, captura, esperar, nodos, tema, tocar)
from t123_capturas_android import accion, h3, modo  # noqa: E402
from t124_capturas_android import arriba  # noqa: E402
from t73_listado_sintetico import box  # noqa: E402


def estadisticas(out, prefijo, nombre, esperado):
    tocar(r'^Estad\.')
    esperar(esperado, 40)
    time.sleep(1.5)
    captura(out, f'{prefijo}_estadisticas_{nombre}')
    tocar(r'^Ver como tabla')
    time.sleep(1.5)
    captura(out, f'{prefijo}_estadisticas_{nombre}_tabla')
    arriba(6)
    if nodos(r'^Ver como gráficos'):
        tocar(r'^Ver como gráficos')
        time.sleep(1)
    tocar(r'^Plano(?:\n|$)')
    time.sleep(1)


def asignar(orden, numero, celda=None):
    """«Acciones» → «Asignar vacío» → el vacío; la celda propuesta o [celda];
    «Confirmar carga»."""
    accion(r'^Asignar vacío$')
    tocar(rf'^OR {orden} · {numero}')
    esperar(r'^Asignar vacío$')
    if celda:
        tocar(r'^Celda reservada')
        time.sleep(0.8)
        tocar(rf'^{celda}', cual='ultimo')
        time.sleep(0.8)
    tocar(r'^Confirmar carga$', cual='ultimo')
    time.sleep(4.5)


def recorrido(out, nombre_tema):
    adb('shell', 'am', 'force-stop', PAQUETE)
    adb('shell', 'pm', 'clear', PAQUETE)
    adb('shell', 'monkey', '-p', PAQUETE, '-c', 'android.intent.category.LAUNCHER', '1')
    esperar(r'^Seleccionar archivo', 60)
    time.sleep(2)
    tema(nombre_tema)
    prefijo = f'emulador_{nombre_tema}'
    # El plan de carga de T-122 y su listado (como H3 de T-123).
    h3(out, prefijo)
    estadisticas(out, prefijo, '0_asignados', r'contenedores a bordo')
    if nodos(r'^Incluye: '):
        raise AssertionError('Sin vacíos asignados no tiene que haber ficha')
    modo('Carga')
    bahia(21)
    asignar(12, box('TSTU001212'), '021-00-84')
    estadisticas(out, prefijo, '1_asignado',
                 r'^Incluye: 1 vacío asignado a una celda reservada, que el archivo no trae$')
    bahia(22)
    asignar(13, box('TSTU001213'), '022-00-84')
    estadisticas(out, prefijo, '2_asignados',
                 r'^Incluye: 2 vacíos asignados a celdas reservadas, que el archivo no trae$')


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--tema', choices=['claro', 'oscuro', 'ambos'], default='ambos')
    args = p.parse_args()
    if t122.SERIAL != 'emulator-5554':
        raise ValueError('Solo el emulador: nunca el Honor.')
    out = Path(args.salida)
    out.mkdir(parents=True, exist_ok=True)
    for t in (['claro', 'oscuro'] if args.tema == 'ambos' else [args.tema]):
        try:
            recorrido(out, t)
        except Exception:
            captura(out, f'_error_{t}')
            raise
    print('capturas:', sorted(r.name for r in out.glob('*.png')))


if __name__ == '__main__':
    raise SystemExit(main())
