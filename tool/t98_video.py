"""Tiempos a partir de PTS reales de cuadros elegidos por el evaluador.

No infiere que la UI responde. El evaluador debe observar y anotar cada hito.
No divide un número de cuadro por los fps nominales (admite video variable).
"""
import argparse
import json
import subprocess
from pathlib import Path

from t98_inventario import output_directory


def analyze(probe, start, end):
    frames = probe['frames']
    if not 0 <= start < end < len(frames):
        raise ValueError('Cuadros fuera de rango; índices desde cero y fin posterior al inicio.')
    points = [float(frame['best_effort_timestamp_time']) for frame in frames]
    if any(b <= a for a, b in zip(points, points[1:])):
        raise ValueError('PTS ausentes, repetidos o no crecientes.')
    elapsed = points[end] - points[start]
    # Incertidumbre conservadora por los cuadros que rodean ambos eventos.
    before = points[start] - points[start - 1] if start else points[1] - points[0]
    after = points[end] - points[end - 1]
    return {'inicioCuadro': start, 'finCuadro': end,
            'inicioPts': points[start], 'finPts': points[end],
            'segundos': elapsed, 'incertidumbreMaxSegundos': before + after,
            'cuadros': len(frames), 'intervaloMin': min(b-a for a,b in zip(points, points[1:])),
            'intervaloMax': max(b-a for a,b in zip(points, points[1:]))}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('video', type=Path)
    parser.add_argument('salida')
    parser.add_argument('--ffprobe', default='ffprobe')
    parser.add_argument('--tipo', choices=['recuperacion', 'primera_visualizacion'], required=True)
    parser.add_argument('--inicio', type=int, required=True)
    parser.add_argument('--fin', type=int, required=True)
    parser.add_argument('--viaje-anterior', type=int)
    parser.add_argument('--boton-responde', type=int)
    parser.add_argument('--pasos', type=int)
    args = parser.parse_args()
    output_directory(str(args.video.resolve().parent))
    result = subprocess.run([args.ffprobe, '-v', 'error', '-select_streams', 'v:0',
        '-show_entries', 'frame=best_effort_timestamp_time:stream=r_frame_rate,avg_frame_rate,time_base',
        '-show_frames', '-of', 'json', str(args.video)], check=True, capture_output=True)
    probe = json.loads(result.stdout)
    end = args.fin
    if args.tipo == 'recuperacion':
        if args.viaje_anterior is None or args.boton_responde is None:
            raise ValueError('Recuperación requiere error visible, viaje anterior y botón que responde.')
        end = max(end, args.viaje_anterior, args.boton_responde)
    elif args.pasos is None or args.pasos < 1:
        raise ValueError('Primera visualización requiere conteo de pasos observado.')
    data = analyze(probe, args.inicio, end)
    data.update({'tipo': args.tipo, 'streams': probe['streams'],
                 'errorORejillaCuadro': args.fin, 'viajeAnteriorCuadro': args.viaje_anterior,
                 'botonRespondeCuadro': args.boton_responde, 'pasos': args.pasos,
                 'dictamen': 'PENDIENTE: Fase B y validación de hitos por el evaluador'})
    target = output_directory(args.salida) / 'video-anotado.json'
    if target.exists():
        raise ValueError('No sobrescribir evidencia.')
    target.write_text(json.dumps(data, indent=2), encoding='utf-8')
    print('T98: PTS y tasa real analizados; no se emite dictamen RNF.')


if __name__ == '__main__':
    main()
