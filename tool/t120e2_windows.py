"""T-120, entrega 2 · Una corrida del banco de Windows: la de T-147
(tool/t147_windows.py) con la salida en build/t120/e2. Abre el `baystream.exe`
del banco (una copia en %TEMP%, compilada con `-t tool/t120e2_main.dart`) con
sus parámetros como variables `T147_…`, espera a que el conductor escriba
«fin» o «error» y cierra ese proceso, y solo ese.

    python -X utf8 tool/t120e2_windows.py --exe %TEMP%\\t120-e2\\banco\\...\\baystream.exe
        --almacen %TEMP%\\t120-e2\\almacenes\\<corrida> --caso %TEMP%\\t120-e2\\caso
        --salida build/t120/e2/windows/<corrida> [--foco] [--grabar]
        escenario=capturas archivo=T120_BUQUE_LISTA_977.edi

- `--foco` (O-128-4): cuando el conductor anota «esperando-foco», minimiza la
  ventana del banco, espera, la restaura y la trae al frente. Es la ventana de
  ese proceso, por su PID; nada más.
- `--grabar` (O-120-4): graba la ventana del banco con ffmpeg (gdigrab, solo
  esa ventana, por su título, a 60 cuadros por segundo) en `ventana.mkv`, y
  anota en `grabacion.json` cuándo empezó, para cruzarlo con la hora de los
  pasos.

El almacén del banco vive en %TEMP% (namespace r4): no abre la BayStream
instalada, ni %LOCALAPPDATA%\\BayStream, ni la carpeta de ningún paquete.
"""
import argparse
import ctypes
import ctypes.wintypes as wt
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TEMP = Path(os.environ['TEMP']).resolve()
user32 = ctypes.windll.user32


def en_temp(ruta, que):
    carpeta = Path(ruta).resolve()
    if TEMP not in [carpeta, *carpeta.parents]:
        sys.exit(f'{que} tiene que estar en %TEMP%: {carpeta}')
    return carpeta


def ventana_de(pid):
    """La ventana visible de nivel superior del proceso `pid`, o None."""
    halladas = []
    PROC = ctypes.WINFUNCTYPE(wt.BOOL, wt.HWND, wt.LPARAM)

    def cada(hwnd, _):
        propio = wt.DWORD()
        user32.GetWindowThreadProcessId(hwnd, ctypes.byref(propio))
        if propio.value == pid and user32.IsWindowVisible(hwnd) and not user32.GetWindow(hwnd, 4):
            halladas.append(hwnd)
        return True

    user32.EnumWindows(PROC(cada), 0)
    return halladas[0] if halladas else None


def titulo_de(hwnd):
    largo = user32.GetWindowTextLengthW(hwnd)
    texto = ctypes.create_unicode_buffer(largo + 1)
    user32.GetWindowTextW(hwnd, texto, largo + 1)
    return texto.value


def principal():
    p = argparse.ArgumentParser()
    p.add_argument('--exe', required=True)
    p.add_argument('--almacen', required=True)
    p.add_argument('--caso', required=True)
    p.add_argument('--salida', required=True)
    p.add_argument('--tope', type=int, default=600)
    p.add_argument('--foco', action='store_true')
    p.add_argument('--grabar', action='store_true')
    p.add_argument('parametros', nargs='*', help='nombre=valor')
    a = p.parse_args()

    exe = en_temp(a.exe, 'El banco')
    almacen = en_temp(a.almacen, 'El almacén')
    caso = Path(a.caso).resolve()
    if caso == RAIZ or RAIZ in caso.parents:
        sys.exit('El caso se lee de fuera del repositorio.')
    salida = Path(a.salida).resolve()
    # La entrega 2 y sus correcciones 1 y 2 (build/t120/e2c1 y e2c2).
    if not any(RAIZ / 'build' / 't120' / c in [salida, *salida.parents] for c in ('e2', 'e2c1', 'e2c2')):
        sys.exit('--salida tiene que estar dentro de build/t120/e2, e2c1 o e2c2.')
    pasos = salida / 'pasos.jsonl'
    if pasos.exists():
        sys.exit(f'{pasos} ya existe: cada corrida va en su carpeta.')
    if almacen.exists() and any(almacen.iterdir()):
        sys.exit(f'El almacén {almacen} ya tiene algo: cada corrida, el suyo.')
    salida.mkdir(parents=True, exist_ok=True)
    almacen.mkdir(parents=True, exist_ok=True)

    entorno = dict(os.environ)
    entorno.update({'T147_ALMACEN': str(almacen), 'T147_CASO': str(caso),
                    'T147_SALIDA': str(salida)})
    for par in a.parametros:
        nombre, valor = par.split('=', 1)
        entorno[f'T147_{nombre.upper()}'] = valor
    consola = open(salida / 'consola.log', 'w', encoding='utf-8')
    proceso = subprocess.Popen([str(exe)], env=entorno, cwd=str(exe.parent),
                               stdout=consola, stderr=subprocess.STDOUT)
    grabadora = None
    final = None
    foco_hecho = False
    limite = time.time() + a.tope
    try:
        hwnd = None
        while hwnd is None and time.time() < limite and proceso.poll() is None:
            time.sleep(0.2)
            hwnd = ventana_de(proceso.pid)
        if hwnd is None:
            sys.exit('El banco no abrió su ventana.')
        if a.grabar:
            titulo = titulo_de(hwnd)
            inicio = datetime.now(timezone.utc).isoformat()
            grabadora = subprocess.Popen(
                ['ffmpeg', '-hide_banner', '-loglevel', 'error', '-f', 'gdigrab',
                 '-framerate', '60', '-draw_mouse', '0', '-i', f'title={titulo}',
                 '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '12',
                 str(salida / 'ventana.mkv')], stdin=subprocess.PIPE)
            (salida / 'grabacion.json').write_text(json.dumps(
                {'inicio_utc': inicio, 'titulo': titulo, 'cuadros_por_segundo': 60},
                ensure_ascii=False, indent=2), encoding='utf-8')
        while time.time() < limite and final is None and proceso.poll() is None:
            time.sleep(0.25)
            if pasos.exists():
                for linea in pasos.read_text(encoding='utf-8').splitlines():
                    # Una línea a medio escribir se lee en la vuelta siguiente.
                    try:
                        paso = json.loads(linea)
                    except ValueError:
                        continue
                    if paso['paso'] in ('fin', 'error'):
                        final = paso
                    if a.foco and paso['paso'] == 'esperando-foco' and not foco_hecho:
                        foco_hecho = True
                        user32.ShowWindow(hwnd, 6)  # SW_MINIMIZE
                        time.sleep(2)
                        user32.ShowWindow(hwnd, 9)  # SW_RESTORE
                        user32.SetForegroundWindow(hwnd)
    finally:
        if grabadora is not None:
            try:
                grabadora.communicate(b'q', timeout=20)
            except Exception:
                grabadora.kill()
        if proceso.poll() is None:
            proceso.terminate()
        consola.close()
    (salida / 'corrida.json').write_text(json.dumps({
        'exe': str(exe), 'almacen': str(almacen), 'parametros': a.parametros,
        'foco': a.foco, 'grabar': a.grabar,
    }, ensure_ascii=False, indent=2), encoding='utf-8')
    if final is None:
        sys.exit('El conductor no terminó: mira pasos.jsonl.')
    print(f"T-120 e2: {final['paso']} · {salida}")
    if final['paso'] == 'error':
        print(final.get('detalle'))
        sys.exit(1)


if __name__ == '__main__':
    principal()
