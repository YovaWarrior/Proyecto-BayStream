"""Extrae cuadros originales por índice y conserva sus PTS para revisión humana."""
import argparse
import bisect
import hashlib
import json
import subprocess
from pathlib import Path

from t98_inventario import output_directory


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('video', type=Path)
    parser.add_argument('salida')
    parser.add_argument('--cuadros', nargs='+', type=int)
    parser.add_argument('--franja-contacto', nargs=2, type=int,
                        metavar=('Y', 'ALTO'), help='Solo la miniatura; JPEG original completo.')
    parser.add_argument('--tiempos', nargs='+', type=float,
                        default=[0, 1, 2, 3, 3.5, 4, 4.5, 5, 5.5, 6, 7, 8])
    args = parser.parse_args()
    output_directory(str(args.video.resolve().parent))
    output = output_directory(args.salida)
    if any(output.iterdir()):
        raise ValueError('La carpeta de revisión debe estar vacía.')
    probe = json.loads(subprocess.check_output(['ffprobe', '-v', 'error',
        '-select_streams', 'v:0', '-show_frames', '-show_entries',
        'frame=best_effort_timestamp_time:stream=r_frame_rate,avg_frame_rate,time_base',
        '-of', 'json', str(args.video)]))
    pts = [float(frame['best_effort_timestamp_time']) for frame in probe['frames']]
    if len(pts) < 2 or any(b <= a for a, b in zip(pts, pts[1:])):
        raise ValueError('PTS no estrictamente crecientes; no anotar automáticamente.')
    chosen = args.cuadros
    if chosen is None:
        chosen = [min(bisect.bisect_left(pts, t), len(pts)-1) for t in args.tiempos]
    indices = sorted(set(chosen))
    if any(n < 0 or n >= len(pts) for n in indices):
        raise ValueError('Índice fuera de rango (base cero).')
    # El video no se transforma. Cada JPEG corresponde al cuadro n del
    # original; la única reducción es la miniatura del índice de contactos.
    for n in indices:
        subprocess.run(['ffmpeg', '-v', 'error', '-n', '-i', str(args.video),
            '-vf', f'select=eq(n\\,{n})', '-frames:v', '1', '-update', '1',
            str(output / f'cuadro-{n:06}.jpg')], check=True, capture_output=True)
    from PIL import Image, ImageDraw
    sheets = []
    sample = Image.open(output / f'cuadro-{indices[0]:06}.jpg')
    band_height = args.franja_contacto[1] if args.franja_contacto else sample.height
    cell_height = min(507, round(band_height*240/sample.width)) + 28
    for page, offset in enumerate(range(0, len(indices), 12), 1):
        group = indices[offset:offset+12]
        sheet = Image.new('RGB', (720, ((len(group)+2)//3)*cell_height), 'white')
        draw = ImageDraw.Draw(sheet)
        for k, n in enumerate(group):
            image = Image.open(output / f'cuadro-{n:06}.jpg')
            if args.franja_contacto:
                top, height = args.franja_contacto
                if top < 0 or height <= 0 or top+height > image.height:
                    raise ValueError('Franja fuera del cuadro original.')
                image = image.crop((0, top, image.width, top+height))
            image.thumbnail((240, 507))
            x, y = (k % 3)*240, (k // 3)*cell_height
            sheet.paste(image, (x, y+25))
            draw.text((x+4, y+5), f'n={n}; PTS={pts[n]:.6f}', fill='black')
        name = f'contacto-{page:02}.jpg'
        sheet.save(output / name)
        sheets.append(name)
    (output / 'cuadros.json').write_text(json.dumps({
        'videoSha256': hashlib.sha256(args.video.read_bytes()).hexdigest(),
        'streams': probe['streams'], 'pts': pts, 'indicesSeleccionados': indices,
        'franjaSoloEnContactos': args.franja_contacto,
        'contactos': sheets,
        'dictamen': 'Sin dictamen; seleccionar hitos en los cuadros originales.'
    }, indent=2), encoding='utf-8')
    print(json.dumps({'cuadrosExtraidos': len(indices), 'contactos': sheets}))


if __name__ == '__main__':
    main()
