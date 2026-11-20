"""T-147 · Una corrida del banco de Windows: abre el `baystream.exe` del banco
(una copia en %TEMP%, compilada con `-t tool/t147_main.dart`) con sus
parámetros como variables `T147_…`, espera a que el conductor escriba «fin» o
«error» en `pasos.jsonl` y cierra ese proceso, y solo ese.

    python -X utf8 tool/t147_windows.py --exe %TEMP%\\t147\\antes\\windows\\baystream.exe
        --almacen %TEMP%\\t147\\antes\\store-windows --caso %TEMP%\\t147\\caso
        --salida build/t147/e1/antes/windows-medir-1
        escenario=medir plan=CORPUS_A09_EN_BLANCO.edi celda=0180084 tamano=360x800

El almacén del banco vive en %TEMP% (namespace r4): no abre la BayStream
instalada, ni %LOCALAPPDATA%\\BayStream, ni la carpeta de ningún paquete.
"""
import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TEMP = Path(os.environ['TEMP']).resolve()


def en_temp(ruta, que):
    carpeta = Path(ruta).resolve()
    if TEMP not in [carpeta, *carpeta.parents]:
        sys.exit(f'{que} tiene que estar en %TEMP%: {carpeta}')
    return carpeta


def principal():
    p = argparse.ArgumentParser()
    p.add_argument('--exe', required=True)
    p.add_argument('--almacen', required=True)
    p.add_argument('--caso', required=True)
    p.add_argument('--salida', required=True)
    p.add_argument('--tope', type=int, default=300)
    p.add_argument('parametros', nargs='*', help='nombre=valor')
    a = p.parse_args()

    exe = en_temp(a.exe, 'El banco')
    almacen = en_temp(a.almacen, 'El almacén')
    caso = Path(a.caso).resolve()
    if caso == RAIZ or RAIZ in caso.parents:
        sys.exit('El caso se lee de fuera del repositorio.')
    salida = Path(a.salida).resolve()
    if RAIZ / 'build' / 't147' not in [salida, *salida.parents]:
        sys.exit('--salida tiene que estar dentro de build/t147.')
    pasos = salida / 'pasos.jsonl'
    if pasos.exists():
        sys.exit(f'{pasos} ya existe: cada corrida va en su carpeta.')
    salida.mkdir(parents=True, exist_ok=True)
    almacen.mkdir(parents=True, exist_ok=True)

    entorno = dict(os.environ)
    entorno.update({'T147_ALMACEN': str(almacen), 'T147_CASO': str(caso),
                    'T147_SALIDA': str(salida)})
    for par in a.parametros:
        nombre, valor = par.split('=', 1)
        entorno[f'T147_{nombre.upper()}'] = valor
    proceso = subprocess.Popen([str(exe)], env=entorno, cwd=str(exe.parent))
    final = None
    limite = time.time() + a.tope
    try:
        while time.time() < limite and final is None and proceso.poll() is None:
            time.sleep(0.5)
            if pasos.exists():
                for linea in pasos.read_text(encoding='utf-8').splitlines():
                    paso = json.loads(linea)
                    if paso['paso'] in ('fin', 'error'):
                        final = paso
    finally:
        if proceso.poll() is None:
            proceso.terminate()
    (salida / 'corrida.json').write_text(json.dumps({
        'exe': str(exe), 'almacen': str(almacen), 'parametros': a.parametros,
    }, ensure_ascii=False, indent=2), encoding='utf-8')
    if final is None:
        sys.exit('El conductor no terminó: mira pasos.jsonl.')
    print(f"T-147: {final['paso']} · {salida}")
    if final['paso'] == 'error':
        print(final.get('detalle'))
        sys.exit(1)


if __name__ == '__main__':
    principal()
