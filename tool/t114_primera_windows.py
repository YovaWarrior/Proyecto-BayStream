"""T-114 · Fase 3, entrega 1: la primera visualización en Windows, en tres pasos.

Instrumento de RNF-002 (≤ 3 pasos y ≤ 30 s hasta la rejilla) para el banco r4
de Windows (tool/t99_main.dart con T99_ALMACEN en %TEMP%), sin persona ni
agente: T-98 no pudo medir Windows por las pausas del agente (10.97), así que
aquí todo lo hace un proceso de Python con sus propios relojes.

Por repetición:
  (1) abre el binario como una persona (explorer.exe, fuera del paquete de la
      consola; windows-almacen-real-explorer); es el «icono» y el inicio del
      reloj;
  (2) cuando el inicio está a la vista, pulsa «Seleccionar archivo» (el botón
      de la marca, localizado por su color en la captura de la ventana);
  (3) en el selector nativo escribe la ruta en «Nombre» y lo confirma por
      mensaje de Win32 (como tool/t98acc_recuperacion_auto.py).
El fin es el primer cuadro en que la ventana queda quieta con el plano (la
rejilla no se anima; el indicador de lectura sí). Se captura solo la ventana
del banco (ImageGrab sobre su rectángulo), a unos 20 cuadros por segundo, con
el reloj monotónico del host; el JSON guarda todos los instantes y las
diferencias entre cuadros, y los PNG de los hitos quedan para revisarlos.
La incertidumbre es el intervalo entre cuadros (≈ 50 ms), que se informa.

La condición «sin perfil» aparta el almacén de la copia antes de cada
repetición; «con perfil» lo conserva.

python tool/t114_primera_windows.py --exe <copia>\\build\\windows\\x64\\runner\\Release\\baystream.exe ^
    --archivo <TEMP>\\t114\\sinteticos\\T99_SINTETICO_977.edi --almacen <TEMP>\\t99-r4-fase3\\store-windows ^
    --salida <TEMP>\\t114\\primera\\windows --perfil sin --repeticiones 5
"""
import argparse
import ctypes
import json
import os
import shutil
import subprocess
import sys
import time
from ctypes import wintypes
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
from PIL import ImageGrab

sys.path.insert(0, str(Path(__file__).resolve().parent))
import t98acc_sonda_windows as s  # noqa: E402
import t98acc_recuperacion_auto as r  # noqa: E402

user32 = s.user32
kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)
user32.ShowWindow.argtypes = [wintypes.HWND, ctypes.c_int]
user32.SetForegroundWindow.argtypes = [wintypes.HWND]
user32.EnumWindows.argtypes = [ctypes.c_void_p, wintypes.LPARAM]
kernel32.OpenProcess.restype = wintypes.HANDLE
kernel32.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
kernel32.QueryFullProcessImageNameW.argtypes = [wintypes.HANDLE, wintypes.DWORD, wintypes.LPWSTR,
                                                ctypes.POINTER(wintypes.DWORD)]
kernel32.CloseHandle.argtypes = [wintypes.HANDLE]

TITULO_APP = 'BayStream'
SW_MAXIMIZE = 3
WM_CLOSE = 0x0010
# El botón «Seleccionar archivo» lleva la marca: #0D47A1 en claro y #8FB4F2 en
# oscuro (la app sigue al tema del sistema, DESIGN.md 4.1).
MARCAS = {'claro': np.array([13, 71, 161]), 'oscuro': np.array([143, 180, 242])}
CUADROS_POR_SEGUNDO = 20
QUIETO_S = 0.6           # cuadros iguales durante este tiempo = pantalla quieta
UMBRAL_IGUALES = 0.35    # diferencia media por canal (0-255) para «igual»


def utc():
    return datetime.now(timezone.utc).isoformat()


def ruta_del_proceso(pid):
    handle = kernel32.OpenProcess(0x1000, False, pid)  # PROCESS_QUERY_LIMITED_INFORMATION
    if not handle:
        return ''
    try:
        buffer = ctypes.create_unicode_buffer(1024)
        largo = wintypes.DWORD(1024)
        if kernel32.QueryFullProcessImageNameW(handle, 0, buffer, ctypes.byref(largo)):
            return buffer.value
        return ''
    finally:
        kernel32.CloseHandle(handle)


def ventana_del_banco(exe):
    hallados = []

    @ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    def cada(hwnd, _):
        if user32.IsWindowVisible(hwnd):
            largo = user32.GetWindowTextLengthW(hwnd)
            texto = ctypes.create_unicode_buffer(largo + 1)
            user32.GetWindowTextW(hwnd, texto, largo + 1)
            if texto.value == TITULO_APP:
                pid = s.pid_de(hwnd)
                if ruta_del_proceso(pid).lower() == exe.lower():
                    hallados.append((hwnd, pid))
        return True

    user32.EnumWindows(cada, 0)
    return hallados[0] if len(hallados) == 1 else None


def rectangulo(hwnd):
    rect = wintypes.RECT()
    user32.GetWindowRect(hwnd, ctypes.byref(rect))
    return rect.left, rect.top, rect.right, rect.bottom


def capturar(rect):
    imagen = ImageGrab.grab(bbox=rect, all_screens=True)
    return np.asarray(imagen.convert('RGB'))


def boton_de_marca(cuadro):
    """El centro del rectángulo mayor con el color de la marca y el tema, o None."""
    for tema, marca in MARCAS.items():
        punto = _boton_de(cuadro, marca)
        if punto is not None:
            return punto + (tema,)
    return None


def _boton_de(cuadro, marca):
    mascara = (np.abs(cuadro.astype(np.int16) - marca).max(axis=2) <= 12)
    filas = np.where(mascara.sum(axis=1) > 60)[0]
    if len(filas) < 20:
        return None
    # La franja de filas más larga con marca: el botón, no un icono.
    cortes = np.where(np.diff(filas) > 1)[0]
    bloques = np.split(filas, cortes + 1)
    bloque = max(bloques, key=len)
    if len(bloque) < 20:
        return None
    columnas = np.where(mascara[bloque].sum(axis=0) > len(bloque) * 0.6)[0]
    if len(columnas) < 60:
        return None
    return int(columnas.mean()), int(bloque.mean())


def diferencia(a, b):
    return float(np.abs(a.astype(np.int16) - b.astype(np.int16)).mean())


def repeticion(args, numero, out):
    carpeta = out / f'{args.perfil}{numero:02d}'
    carpeta.mkdir()
    registro = {'instrumento': 'tool/t114_primera_windows.py', 'perfil': args.perfil,
                'repeticion': numero, 'exe': args.exe, 'archivo': args.archivo,
                'inicioUtc': utc(), 'acciones': [], 'cuadros': [], 'hitos': {}}
    if args.perfil == 'sin' and Path(args.almacen).exists():
        destino = out / f'almacen-apartado-{args.perfil}{numero:02d}'
        shutil.move(args.almacen, destino)
        registro['almacenApartado'] = str(destino)
    reloj = time.perf_counter
    t0 = reloj()
    registro['acciones'].append({'paso': 1, 'accion': 'abrir el binario (icono)', 't': 0.0})
    # Fuera del paquete de la consola: explorer.exe lo abre como una persona.
    subprocess.Popen(['explorer.exe', args.exe])
    ventana = None
    while ventana is None:
        if reloj() - t0 > 60:
            raise RuntimeError('La ventana del banco no apareció en 60 s.')
        ventana = ventana_del_banco(args.exe)
        time.sleep(0.02)
    hwnd, pid = ventana
    registro['hitos']['ventana'] = reloj() - t0
    user32.ShowWindow(hwnd, SW_MAXIMIZE)
    user32.SetForegroundWindow(hwnd)
    # Maximizar es asíncrono: se espera a que la ventana esté maximizada y
    # el rectángulo se relee en cada cuadro.
    for _ in range(100):
        if user32.IsZoomed(hwnd):
            break
        time.sleep(0.02)
    rect = rectangulo(hwnd)
    registro['ventana'] = {'pid': pid, 'rect': rect, 'maximizada': bool(user32.IsZoomed(hwnd))}
    cuadros = []          # (t, cuadro)
    pulsado = False
    confirmado = False
    dialogo = None
    quieto_desde = None
    fin = None
    ultimo = None
    guardados = {}
    intervalo = 1.0 / CUADROS_POR_SEGUNDO

    def guardar(nombre, cuadro):
        from PIL import Image
        Image.fromarray(cuadro).save(carpeta / f'{nombre}.png')
        guardados[nombre] = f'{nombre}.png'

    def fallar(motivo):
        registro['errorInstrumento'] = motivo
        registro['pngs'] = guardados
        (carpeta / 'registro.json').write_text(json.dumps(registro, ensure_ascii=False, indent=1),
                                               encoding='utf-8')
        user32.PostMessageW(hwnd, WM_CLOSE, 0, 0)
        raise RuntimeError(motivo)

    while True:
        t = reloj() - t0
        if t > 120:
            guardar('ultimo', cuadro)
            fallar('Más de 120 s sin rejilla.')
        rect = rectangulo(hwnd)
        cuadro = capturar(rect)
        if ultimo is not None and ultimo.shape != cuadro.shape:
            ultimo = None
        dif = None if ultimo is None else diferencia(cuadro, ultimo)
        registro['cuadros'].append({'t': round(t, 4), 'dif': None if dif is None else round(dif, 3)})
        if not pulsado:
            boton = boton_de_marca(cuadro)
            if boton is not None:
                guardar('inicio', cuadro)
                x, y = rect[0] + boton[0], rect[1] + boton[1]
                registro['tema'] = boton[2]
                registro['acciones'].append({'paso': 2, 'accion': 'pulsar «Seleccionar archivo»',
                                             't': round(reloj() - t0, 4), 'punto': [x, y]})
                s.clic(x, y)
                pulsado = True
        elif not confirmado:
            dialogo = r.selector(pid)
            if dialogo is not None:
                time.sleep(0.4)  # el selector se dibuja primero en blanco
                campo = r.campo_nombre(dialogo)
                if campo is None:
                    raise RuntimeError('El selector no tiene el campo «Nombre».')
                user32.SendMessageW(campo, r.WM_SETTEXT, 0, args.archivo)
                time.sleep(0.1)
                user32.PostMessageW(dialogo, r.WM_COMMAND, r.IDOK, 0)
                registro['acciones'].append({'paso': 3, 'accion': 'elegir el archivo en el selector y confirmar',
                                             't': round(reloj() - t0, 4)})
                confirmado = True
                quieto_desde = None
        else:
            if r.selector(pid) is None:
                if dif is not None and dif <= UMBRAL_IGUALES:
                    quieto_desde = quieto_desde if quieto_desde is not None else (t, cuadro)
                    if t - quieto_desde[0] >= QUIETO_S:
                        fin = quieto_desde[0]
                        guardar('rejilla', quieto_desde[1])
                        guardar('final', cuadro)
                        break
                else:
                    quieto_desde = None
        ultimo = cuadro
        resto = intervalo - ((reloj() - t0) - t)
        if resto > 0:
            time.sleep(resto)
    # Sin la pestaña del plano no hay marca de la rejilla en el cuadro final:
    # se deja al revisor el PNG «rejilla» y el «inicio».
    registro['hitos']['confirmado'] = next(a['t'] for a in registro['acciones'] if a['paso'] == 3)
    registro['hitos']['rejillaQuieta'] = round(fin, 4)
    registro['hitos']['incertidumbreS'] = round(intervalo, 3)
    registro['pasosDelProducto'] = 3
    registro['tiempoHastaRejillaS'] = round(fin, 3)
    registro['cumpleTiempo'] = fin <= 30
    registro['pngs'] = guardados
    registro['finUtc'] = utc()
    user32.PostMessageW(hwnd, WM_CLOSE, 0, 0)
    for _ in range(100):
        if ventana_del_banco(args.exe) is None:
            break
        time.sleep(0.1)
    (carpeta / 'registro.json').write_text(json.dumps(registro, ensure_ascii=False, indent=1),
                                           encoding='utf-8')
    return registro


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--exe', required=True)
    p.add_argument('--archivo', required=True)
    p.add_argument('--almacen', required=True, help='El T99_ALMACEN de la compilación, en %%TEMP%%.')
    p.add_argument('--salida', required=True)
    p.add_argument('--perfil', choices=['sin', 'con'], required=True)
    p.add_argument('--repeticiones', type=int, default=5)
    args = p.parse_args()
    temp = Path(os.environ['TEMP']).resolve()
    for ruta in (args.exe, args.archivo, args.almacen, args.salida):
        if not Path(ruta).resolve().is_relative_to(temp):
            raise SystemExit(f'Solo rutas dentro de %TEMP%: {ruta}')
    if not Path(args.exe).exists() or not Path(args.archivo).exists():
        raise SystemExit('Falta el binario o el archivo.')
    if ventana_del_banco(args.exe) is not None:
        raise SystemExit('El banco ya está abierto: ciérralo antes de medir.')
    user32.SetProcessDPIAware()
    out = Path(args.salida)
    out.mkdir(parents=True, exist_ok=True)
    if any(out.iterdir()):
        raise SystemExit('No sobrescribir una corrida: usa otra carpeta.')
    resultados = []
    for numero in range(1, args.repeticiones + 1):
        registro = repeticion(args, numero, out)
        resultados.append({'repeticion': numero, 'tiempoHastaRejillaS': registro['tiempoHastaRejillaS'],
                           'pasos': registro['pasosDelProducto'], 'cumpleTiempo': registro['cumpleTiempo']})
        print(json.dumps(resultados[-1]))
        time.sleep(2)
    (out / 'resumen.json').write_text(json.dumps({
        'instrumento': 'tool/t114_primera_windows.py', 'perfil': args.perfil,
        'archivo': args.archivo, 'exe': args.exe, 'repeticiones': resultados,
        'incertidumbreS': round(1.0 / CUADROS_POR_SEGUNDO, 3)}, ensure_ascii=False, indent=1),
        encoding='utf-8')


if __name__ == '__main__':
    main()
