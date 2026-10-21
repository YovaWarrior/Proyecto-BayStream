"""Captura acotada y controlada por archivo, sin automatizar entrada de Windows.

El evaluador prepara una superficie sin cuentas y revisa cada video. Los
tiempos del host son trazabilidad; las mediciones usan PTS de cuadros reales.
"""
import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

from t98_inventario import output_directory


def utc():
    return datetime.now(timezone.utc).isoformat()


def save(path, data):
    temporary = path.with_suffix('.nuevo')
    temporary.write_text(json.dumps(data, indent=2), encoding='utf-8')
    os.replace(temporary, path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('accion', choices=['iniciar', 'detener', 'trabajador'])
    parser.add_argument('video', type=Path)
    parser.add_argument('--rectangulo', nargs=4, type=int,
                        metavar=('X', 'Y', 'ANCHO', 'ALTO'), required=True)
    args = parser.parse_args()
    target = args.video.resolve()
    output_directory(str(target.parent))
    if target.suffix != '.mp4':
        raise ValueError('Se requiere MP4 en TEMP.')
    x, y, width, height = args.rectangulo
    if min(x, y) < 0 or min(width, height) < 64 or width % 2 or height % 2:
        raise ValueError('Rectangulo invalido; dimensiones pares.')
    metadata = target.with_suffix('.captura.json')
    stop = target.with_suffix('.detener')
    progress = target.with_suffix('.progreso.txt')
    log = target.with_suffix('.ffmpeg.txt')
    if args.accion == 'iniciar':
        if any(p.exists() for p in [target, metadata, stop, progress, log]):
            raise ValueError('No sobrescribir corrida.')
        with target.with_suffix('.trabajador.txt').open('x') as output:
            subprocess.Popen([sys.executable, str(Path(__file__).resolve()),
                'trabajador', str(target), '--rectangulo',
                *map(str, args.rectangulo)], stdin=subprocess.DEVNULL,
                stdout=output, stderr=output,
                creationflags=subprocess.CREATE_NO_WINDOW)
        for _ in range(100):
            if metadata.exists():
                data = json.loads(metadata.read_text())
                if data['estado'] == 'grabando':
                    print('T98: captura iniciada; detener por su ruta exacta.')
                    return
                if data['estado'] == 'fallo':
                    raise RuntimeError('FFmpeg fallo; consultar registro propio.')
            time.sleep(0.1)
        raise RuntimeError('Captura no confirmada; no iniciar la medicion.')
    if args.accion == 'detener':
        data = json.loads(metadata.read_text())
        if data['video'] != str(target) or data['rectangulo'] != args.rectangulo:
            raise ValueError('Captura distinta de la solicitada.')
        if data['estado'] != 'grabando':
            raise ValueError('La captura ya no esta grabando.')
        stop.write_text('detener captura propia\n', encoding='utf-8')
        for _ in range(100):
            data = json.loads(metadata.read_text())
            if data['estado'] == 'terminada':
                print('T98: captura cerrada correctamente; revisar y anotar PTS.')
                return
            if data['estado'] == 'fallo':
                raise RuntimeError('FFmpeg fallo; no usar sin revisar.')
            time.sleep(0.1)
        raise RuntimeError('Cierre pendiente; no borrar ni forzar procesos.')
    data = {'video': str(target), 'rectangulo': args.rectangulo,
            'inicioHostNoEsMedicion': utc(), 'estado': 'arrancando',
            'fpsSolicitadosNoSonTasaMedida': 30,
            'limiteAutomaticoS': 600, 'pidTrabajador': os.getpid()}
    with log.open('x') as error:
        process = subprocess.Popen(['ffmpeg', '-hide_banner', '-loglevel',
            'error', '-n', '-stats_period', '0.1', '-progress', str(progress),
            '-f', 'gdigrab', '-framerate', '30', '-video_size',
            f'{width}x{height}', '-offset_x', str(x), '-offset_y', str(y),
            '-i', 'desktop', '-t', '600', '-an', '-c:v', 'libx264',
            '-preset', 'ultrafast', '-crf', '16', '-fps_mode', 'passthrough',
            '-enc_time_base', '1/1000000', '-video_track_timescale', '1000000',
            str(target)], stdin=subprocess.PIPE, stdout=subprocess.DEVNULL,
            stderr=error, creationflags=subprocess.CREATE_NO_WINDOW)
        data['pidFfmpegPropio'] = process.pid
        started = False
        while process.poll() is None:
            if not started and progress.exists() and progress.stat().st_size:
                started = True
                data['estado'] = 'grabando'
                save(metadata, data)
            if stop.exists():
                process.stdin.write(b'q\n')
                process.stdin.flush()
                break
            time.sleep(0.05)
        code = process.wait()
    data.update({'finHostNoEsMedicion': utc(), 'codigo': code,
                 'estado': 'terminada' if code == 0 and started else 'fallo'})
    save(metadata, data)


if __name__ == '__main__':
    main()
