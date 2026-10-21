"""Empaqueta cuadros CDP de T98 sin inventar una tasa constante.

Los JPEG y metadata.timestamp siguen siendo la fuente. El MP4 añade una
columna/fila negra si hace falta y cuantiza a microsegundos; verifica todos
los PTS y el número de cuadros antes de declararlo utilizable.
"""
import argparse
from decimal import Decimal, ROUND_HALF_UP
import hashlib
import json
from pathlib import Path
import subprocess

from t98_inventario import output_directory


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('captura', type=Path)
    args = parser.parse_args()
    root = output_directory(str(args.captura.resolve().parent))
    data = json.loads(args.captura.read_text(encoding='utf-8'))
    if data['error'] or data['truncado'] or not data['ptsEstrictamenteCrecientes']:
        raise ValueError('Captura no apta; no ocultar errores del instrumento.')
    frames = data['cuadros']
    if len(frames) < 2:
        raise ValueError('Faltan cuadros.')
    times = [Decimal(str(f['metadataOrigen']['timestamp'])) for f in frames]
    relative = [int(((t-times[0])*1000000).quantize(
        Decimal(1), rounding=ROUND_HALF_UP)) for t in times]
    if any(b <= a for a, b in zip(relative, relative[1:])):
        raise ValueError('La cuantización colapsa cuadros.')
    lines = ['ffconcat version 1.0']
    for i, frame in enumerate(frames):
        name = frame['archivo']
        if Path(name).name != name or not name.endswith('.jpg'):
            raise ValueError('Nombre de cuadro inseguro.')
        lines += [f"file '{name}'", 'option framerate 1000000']
        if i+1 < len(frames):
            lines += [f'duration {(relative[i+1]-relative[i])/1000000:.6f}']
    concat = root / 'cuadros.ffconcat'
    video = root / 'video.mp4'
    with concat.open('x', encoding='utf-8', newline='\n') as stream:
        stream.write('\n'.join(lines)+'\n')
    subprocess.run(['ffmpeg', '-v', 'error', '-n', '-f', 'concat', '-safe', '0',
        '-i', str(concat), '-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2:0:0:black',
        '-fps_mode', 'passthrough', '-c:v', 'libx264', '-preset', 'fast',
        '-crf', '16', '-pix_fmt', 'yuv420p', '-enc_time_base', '1/1000000',
        '-video_track_timescale', '1000000', str(video)], check=True,
        capture_output=True)
    probe = json.loads(subprocess.check_output(['ffprobe', '-v', 'error',
        '-select_streams', 'v:0', '-show_frames', '-show_entries',
        'frame=best_effort_timestamp_time:stream=avg_frame_rate,time_base,width,height',
        '-of', 'json', str(video)]))
    actual = [int(Decimal(f['best_effort_timestamp_time'])*1000000)
              for f in probe['frames']]
    verified = actual == relative
    result = {'cuadros': len(frames), 'ptsMicrosegundosEsperados': relative,
              'ptsMicrosegundosVideo': actual, 'ptsVerificadosTodos': verified,
              'cuantizacionMaximaSegundos': 0.0000005,
              'streams': probe['streams'],
              'sha256Video': hashlib.sha256(video.read_bytes()).hexdigest(),
              'sha256Captura': hashlib.sha256(args.captura.read_bytes()).hexdigest(),
              'aviso': 'Fuente: JPEG y timestamp CDP. MP4 con borde negro para '
                       'dimensiones pares, sin interpolación ni cuadros extra.'}
    (root / 'video-verificado.json').write_text(json.dumps(result, indent=2),
                                               encoding='utf-8')
    if not verified:
        raise ValueError('Los PTS del MP4 no coinciden; no usar el derivado.')
    print(json.dumps({'cuadros': len(frames), 'ptsVerificadosTodos': verified,
                      'video': str(video)}))


if __name__ == '__main__':
    main()
