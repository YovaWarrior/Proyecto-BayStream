"""T-114 · Fase 3: el primer cuadro con rejilla de un video de primera visualización.

Lee el video de tool/t114_primera_android.py (o cualquier MP4 con PTS reales)
y propone el fin de la medición: el primer cuadro a partir del cual la imagen
se parece al cuadro final (el plano quieto) y ya no cambia. El indicador de
lectura se mueve y el selector del sistema es otra imagen, así que quedan
antes. También propone el inicio: el primer cuadro que difiere del inicial
(el toque sobre el icono o la aparición de la app). No decide por su cuenta:
guarda los cuadros candidatos y sus vecinos como JPEG para revisarlos a ojo,
como en T-98 (tool/t98_video_cuadros.py), y el JSON con cada PTS.

python tool/t114_primera_cuadros.py <video.mp4> <salida en TEMP> [--umbral 6]
"""
import argparse
import json
import subprocess
from pathlib import Path

import numpy as np

ANCHO, ALTO = 360, 640


def pts_de(video):
    salida = subprocess.check_output(
        ['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries',
         'frame=best_effort_timestamp_time', '-of', 'csv=p=0', str(video)], text=True)
    return [float(v.strip(',')) for v in salida.split() if v.strip(',')]


def cuadros(video):
    proceso = subprocess.Popen(
        ['ffmpeg', '-v', 'error', '-i', str(video), '-vf', f'scale={ANCHO}:{ALTO}',
         '-fps_mode', 'passthrough', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'],
        stdout=subprocess.PIPE)
    tam = ANCHO * ALTO * 3
    while True:
        datos = proceso.stdout.read(tam)
        if len(datos) < tam:
            break
        yield np.frombuffer(datos, np.uint8).reshape(ALTO, ANCHO, 3).astype(np.int16)
    proceso.wait()


def extraer(video, indices, salida):
    for n in indices:
        destino = salida / f'cuadro-{n:05d}.jpg'
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', str(video), '-vf',
                        f'select=eq(n\\,{n})', '-frames:v', '1', '-q:v', '3', str(destino)],
                       check=True)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('video', type=Path)
    p.add_argument('salida', type=Path)
    p.add_argument('--umbral', type=float, default=6.0,
                   help='diferencia media por canal (0-255) para «se parece al final»')
    a = p.parse_args()
    if not str(a.salida.resolve()).lower().startswith(str(Path.home() / 'AppData' / 'Local' / 'Temp').lower()):
        raise SystemExit('La salida va en %TEMP%.')
    a.salida.mkdir(parents=True, exist_ok=True)
    if any(a.salida.iterdir()):
        raise SystemExit('No sobrescribir una revisión.')
    marcas = pts_de(a.video)
    todos = list(cuadros(a.video))
    if len(todos) != len(marcas):
        raise SystemExit(f'Cuadros {len(todos)} y PTS {len(marcas)} no coinciden.')
    final = todos[-1]
    inicial = todos[0]
    dif_final = [float(np.abs(c - final).mean()) for c in todos]
    dif_inicial = [float(np.abs(c - inicial).mean()) for c in todos]
    # Fin: desde dónde todos los cuadros restantes se parecen al final.
    fin = len(todos) - 1
    while fin > 0 and dif_final[fin - 1] <= a.umbral:
        fin -= 1
    # Inicio: el primer cuadro que se aparta del inicial (el toque o la app).
    inicio = next((n for n, d in enumerate(dif_inicial) if d > a.umbral), 0)
    candidatos = sorted({max(inicio - 1, 0), inicio, min(inicio + 1, fin),
                         max(fin - 2, 0), max(fin - 1, 0), fin, min(fin + 1, len(todos) - 1)})
    extraer(a.video, candidatos, a.salida)
    informe = {
        'video': str(a.video), 'cuadros': len(todos), 'umbral': a.umbral,
        'inicio': {'cuadro': inicio, 'pts': marcas[inicio],
                   'ultimoAntes': {'cuadro': max(inicio - 1, 0), 'pts': marcas[max(inicio - 1, 0)]}},
        'fin': {'cuadro': fin, 'pts': marcas[fin],
                'ultimoAntes': {'cuadro': max(fin - 1, 0), 'pts': marcas[max(fin - 1, 0)]}},
        'duracionAcotadaS': [round(marcas[fin] - marcas[inicio], 3),
                             round(marcas[min(fin + 1, len(todos) - 1)] - marcas[max(inicio - 1, 0)], 3)],
        'candidatosExtraidos': candidatos,
        'difConElFinal': [round(d, 2) for d in dif_final],
        'difConElInicial': [round(d, 2) for d in dif_inicial],
        'pts': marcas,
        'dictamen': 'Propuesta del instrumento; revisar los JPEG antes de anotar.',
    }
    (a.salida / 'cuadros.json').write_text(json.dumps(informe, indent=1), encoding='utf-8')
    print(json.dumps({'inicio': informe['inicio'], 'fin': informe['fin'],
                      'duracionAcotadaS': informe['duracionAcotadaS']}))


if __name__ == '__main__':
    main()
