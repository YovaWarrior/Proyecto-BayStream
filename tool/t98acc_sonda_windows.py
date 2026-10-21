"""Aceptación de T-98 (10.104): sonda del botón de carga en Windows, sin agente.

Una persona abre el selector «Seleccionar archivo BAPLIE», elige un archivo
inválido y lo confirma. Este script vigila ese selector en el proceso de
BayStream y, cuando se cierra, espera un tiempo fijo (1 s, como el Honor) y
pulsa una vez «Cargar archivo BAPLIE»: la prueba de que la app responde.
No pulsa si el selector sigue abierto, si no hay aviso rojo de error (una
cancelación o una admisión), ni si BayStream no está al frente y maximizada.
La medición sale del video; los tiempos de este registro son trazabilidad.

python tool/t98acc_sonda_windows.py --pid N --casos 4 --salida <json en TEMP>
python tool/t98acc_sonda_windows.py --pid N --prueba   (solo las comprobaciones)
"""
import argparse
import ctypes
import json
import os
import time
from ctypes import wintypes
from datetime import datetime, timezone
from pathlib import Path

user32 = ctypes.WinDLL('user32', use_last_error=True)
gdi32 = ctypes.WinDLL('gdi32')
user32.GetDC.restype = wintypes.HDC
user32.GetDC.argtypes = [wintypes.HWND]
user32.ReleaseDC.argtypes = [wintypes.HWND, wintypes.HDC]
user32.GetForegroundWindow.restype = wintypes.HWND
for _f in ('IsWindowVisible', 'GetWindowTextLengthW', 'IsZoomed'):
    getattr(user32, _f).argtypes = [wintypes.HWND]
user32.GetWindowTextW.argtypes = [wintypes.HWND, wintypes.LPWSTR, ctypes.c_int]
user32.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
user32.GetWindowRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]
gdi32.GetPixel.argtypes = [wintypes.HDC, ctypes.c_int, ctypes.c_int]
gdi32.GetPixel.restype = wintypes.DWORD

TITULO = 'Seleccionar archivo BAPLIE'
# Ventana maximizada a 1920×1080 y 125 %; píxeles físicos medidos en la toma 4.
BOTON = (1764, 65)            # «Cargar archivo BAPLIE»; la X está en x=1815
RECT_MAX = (-9, -9, 1929, 1029)
PUNTOS_AVISO = [(x, 970) for x in (100, 500, 900, 1300, 1700)]  # aviso en Lista
LIMITE_SIN_ACTIVIDAD_S = 900


def utc():
    return datetime.now(timezone.utc).isoformat()


def pid_de(hwnd):
    pid = wintypes.DWORD()
    user32.GetWindowThreadProcessId(hwnd, ctypes.byref(pid))
    return pid.value


def selector_abierto(pid):
    hallados = []

    @ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    def cada(hwnd, _):
        if user32.IsWindowVisible(hwnd):
            largo = user32.GetWindowTextLengthW(hwnd)
            texto = ctypes.create_unicode_buffer(largo + 1)
            user32.GetWindowTextW(hwnd, texto, largo + 1)
            if texto.value == TITULO and pid_de(hwnd) == pid:
                hallados.append(hwnd)
        return True

    user32.EnumWindows(cada, 0)
    return bool(hallados)


def baystream_lista(pid):
    hwnd = user32.GetForegroundWindow()
    rect = wintypes.RECT()
    user32.GetWindowRect(hwnd, ctypes.byref(rect))
    return (pid_de(hwnd) == pid and bool(user32.IsZoomed(hwnd)) and
            (rect.left, rect.top, rect.right, rect.bottom) == RECT_MAX)


def aviso_rojo():
    dc = user32.GetDC(None)
    try:
        rosados = 0
        for x, y in PUNTOS_AVISO:
            color = gdi32.GetPixel(dc, x, y)
            rojo, azul = color & 0xFF, (color >> 16) & 0xFF
            rosados += (rojo - azul) > 40
        return rosados >= 4
    finally:
        user32.ReleaseDC(None, dc)


def clic(x, y):
    user32.SetCursorPos(x, y)
    user32.mouse_event(0x0002, 0, 0, 0, 0)  # botón izquierdo abajo
    user32.mouse_event(0x0004, 0, 0, 0, 0)  # botón izquierdo arriba


def esperar(condicion, limite=LIMITE_SIN_ACTIVIDAD_S):
    inicio = time.perf_counter()
    while not condicion():
        if time.perf_counter() - inicio > limite:
            return False
        time.sleep(0.005)
    return True


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--pid', type=int, required=True)
    p.add_argument('--casos', type=int, default=4)
    p.add_argument('--espera', type=float, default=1.0)
    p.add_argument('--salida', type=Path)
    p.add_argument('--prueba', action='store_true')
    a = p.parse_args()
    user32.SetProcessDPIAware()
    if a.prueba:
        print(json.dumps({'selectorAbierto': selector_abierto(a.pid),
                          'baystreamAlFrenteYMaximizada': baystream_lista(a.pid),
                          'avisoRojo': aviso_rojo()}))
        return
    temp = Path(os.environ['TEMP']).resolve()
    if a.salida is None or temp not in a.salida.resolve().parents or a.salida.exists():
        raise SystemExit('La salida tiene que ser nueva y estar bajo TEMP.')
    registro = {'pid': a.pid, 'boton': BOTON, 'esperaFijaS': a.espera,
                'inicioUtc': utc(), 'eventos': []}

    def anota(evento, **extra):
        registro['eventos'].append({'evento': evento, 'utc': utc(),
                                    'perf': round(time.perf_counter(), 4), **extra})
        a.salida.write_text(json.dumps(registro, ensure_ascii=False, indent=1),
                            encoding='utf-8')

    anota('sonda armada')
    clics = 0
    while clics < a.casos:
        if not esperar(lambda: selector_abierto(a.pid)):
            anota('fin: sin actividad')
            break
        anota('selector abierto por la persona')
        esperar(lambda: not selector_abierto(a.pid))
        cierre = time.perf_counter()
        rojo_al_cerrar = aviso_rojo()
        anota('selector cerrado', avisoRojoYaVisible=rojo_al_cerrar)
        time.sleep(max(0.0, a.espera - (time.perf_counter() - cierre)))
        if rojo_al_cerrar:
            anota('sin clic: el aviso rojo ya estaba antes del cierre')
        elif selector_abierto(a.pid):
            anota('sin clic: el selector se abrió otra vez')
        elif not aviso_rojo():
            anota('sin clic: no hay aviso rojo (cancelación o admisión)')
        elif not baystream_lista(a.pid):
            anota('sin clic: BayStream no está al frente o no está maximizada')
        else:
            clic(*BOTON)
            clics += 1
            anota('clic en «Cargar archivo BAPLIE»',
                  retrasoDesdeCierreS=round(time.perf_counter() - cierre, 4))
            if esperar(lambda: selector_abierto(a.pid), limite=5):
                anota('selector reabierto')
                esperar(lambda: not selector_abierto(a.pid))
                anota('selector cancelado o cerrado')
            else:
                anota('el selector no se reabrió en 5 s')
        esperar(lambda: not aviso_rojo())  # el caso siguiente, sin aviso en cola
        anota('sin aviso a la vista')
    anota('fin', clics=clics)


if __name__ == '__main__':
    main()
