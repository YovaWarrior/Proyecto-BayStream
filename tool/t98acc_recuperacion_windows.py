"""Aceptación de T-98 (10.104): candidatos de hitos en una toma de Windows.

Lee cada cuadro de la toma (ventana maximizada, 1920×1020) y anota:
  - dialogo: el selector «Seleccionar archivo BAPLIE» está a la vista; se mide
    por la diferencia, en la zona del selector (arriba a la izquierda), contra
    un cuadro de referencia con selector y otro sin él;
  - aviso: el aviso rojo de error está a la vista (franja inferior rosada).
No decide nada: propone cuadros para revisarlos a ojo con t98_video_cuadros.py
y medirlos con t98_video.py.

python tool/t98acc_recuperacion_windows.py VIDEO SALIDA.json --con-dialogo N --sin-dialogo M
"""
import argparse
import json
import subprocess
from pathlib import Path

import numpy as np

ANCHO, ALTO = 960, 510  # mitad de 1920×1020
ZONA_DIALOGO = (slice(0, 320), slice(0, 500))  # filas, columnas (media resolución)
# El aviso flota sobre el botón «Cargar BAPLIE» en Inicio y más abajo en Lista.
FRANJA_AVISO = (slice(410, 508), slice(50, 900))


def cuadros(video, solo=None):
    filtro = f'scale={ANCHO}:{ALTO}'
    if solo is not None:  # un solo cuadro, por índice desde cero
        filtro = f'select=eq(n\\,{solo}),' + filtro
    proceso = subprocess.Popen(
        ['ffmpeg', '-v', 'error', '-i', str(video), '-vf', filtro,
         '-fps_mode', 'passthrough', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'],
        stdout=subprocess.PIPE)
    tam = ANCHO * ALTO * 3
    while True:
        datos = proceso.stdout.read(tam)
        if len(datos) < tam:
            break
        yield np.frombuffer(datos, np.uint8).reshape(ALTO, ANCHO, 3).astype(np.int16)
    proceso.wait()


def pts(video):
    salida = subprocess.check_output(
        ['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries',
         'frame=pts_time', '-of', 'csv=p=0', str(video)], text=True)
    return [float(v.strip(',')) for v in salida.split() if v.strip(',')]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('video', type=Path)
    p.add_argument('salida', type=Path)
    p.add_argument('--con-dialogo', type=int, required=True)
    p.add_argument('--sin-dialogo', type=int, required=True)
    a = p.parse_args()
    if a.salida.exists():
        raise SystemExit('No sobrescribe la salida.')
    marcas = pts(a.video)
    if any(b <= x for x, b in zip(marcas, marcas[1:])):
        raise SystemExit('PTS no estrictamente crecientes.')
    con = next(cuadros(a.video, a.con_dialogo))[ZONA_DIALOGO]
    sin = next(cuadros(a.video, a.sin_dialogo))[ZONA_DIALOGO]
    filas = []
    for n, c in enumerate(cuadros(a.video)):
        zona = c[ZONA_DIALOGO]
        d_con = float(np.abs(zona - con).mean())
        d_sin = float(np.abs(zona - sin).mean())
        franja = c[FRANJA_AVISO]
        # La fila más rosada de la franja: rojo menos azul, promediado por fila.
        rosado = float((franja[..., 0] - franja[..., 2]).mean(axis=1).max())
        filas.append({'n': n, 'pts': marcas[n], 'difConDialogo': round(d_con, 2),
                      'difSinDialogo': round(d_sin, 2), 'dialogo': d_con < d_sin,
                      'rosado': round(rosado, 1), 'aviso': rosado > 40})
    if len(filas) != len(marcas):
        raise SystemExit(f'Cuadros {len(filas)} y PTS {len(marcas)} no coinciden.')
    transiciones = []
    for antes, ahora in zip(filas, filas[1:]):
        for clave in ('dialogo', 'aviso'):
            if antes[clave] != ahora[clave]:
                transiciones.append({'evento': f"{clave} {'aparece' if ahora[clave] else 'desaparece'}",
                                     'ultimoAntes': [antes['n'], antes['pts']],
                                     'primeroDespues': [ahora['n'], ahora['pts']]})
    a.salida.write_text(json.dumps({'video': str(a.video), 'cuadros': len(filas),
                                    'referencias': {'conDialogo': a.con_dialogo,
                                                    'sinDialogo': a.sin_dialogo},
                                    'transiciones': transiciones, 'filas': filas},
                                   indent=1), encoding='utf-8')
    for t in transiciones:
        print(t['evento'], t['ultimoAntes'], t['primeroDespues'])


if __name__ == '__main__':
    main()
