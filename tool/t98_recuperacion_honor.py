"""Graba un caso real de UI; no calcula recuperación a partir de tiempos ADB.

El toque de comprobación usa la posición de carga observada antes del selector.
Solo el evaluador, viendo el video, confirma error, viaje anterior y respuesta.
"""
import argparse
import json
import re
import subprocess
import time
from datetime import datetime, timezone

from t98_honor_ui import ADB, observe
from t98_inventario import output_directory


CASES = ['01_bytes_aleatorios.edi', '02_texto_sin_edifact.edi',
         '03_segmento_cortado.edi', '04_sin_unt_unz.edi', '05_sin_tdt.edi',
         '06_coprar.edi', '07_version_no_admitida.edi', '08_vacio.edi']


def adb(*args):
    return subprocess.run([ADB, *args], capture_output=True, check=True).stdout


def position(rows, label):
    found = [bounds for bounds, text in rows
             if text == label or text.startswith(label + ' | ')]
    if len(found) != 1:
        raise RuntimeError(f'Control no visible o ambiguo: {label}')
    left, top, right, bottom = map(int, re.findall(r'\d+', found[0]))
    if right - left < 40 or bottom - top < 30:
        raise RuntimeError('Control recortado: desplazar antes de grabar.')
    return (left + right) // 2, (top + bottom) // 2


def tap(point):
    adb('shell', 'input', 'tap', *map(str, point))


def utc():
    return datetime.now(timezone.utc).isoformat()


def probe_video(path):
    return json.loads(subprocess.check_output(['ffprobe', '-v', 'error',
        '-select_streams', 'v:0', '-count_frames', '-show_frames', '-show_entries',
        'frame=best_effort_timestamp_time:stream=width,height,r_frame_rate,avg_frame_rate,time_base,nb_read_frames:format=duration',
        '-of', 'json', str(path)]))


def crop_video(raw, target):
    original_probe = probe_video(raw)
    subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-n',
        '-i', str(raw), '-vf', 'crop=iw:ih-80:0:80', '-an', '-c:v', 'libx264',
        '-preset', 'fast', '-crf', '18', '-fps_mode', 'passthrough',
        '-enc_time_base', original_probe['streams'][0]['time_base'],
        '-video_track_timescale', '1000000', str(target)], check=True)
    return original_probe, probe_video(target)


def restore_pointer(value):
    if value == 'null':
        adb('shell', 'settings', 'delete', 'system', 'pointer_location')
    else:
        adb('shell', 'settings', 'put', 'system', 'pointer_location', value)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('caso', type=int, choices=range(1, 9))
    parser.add_argument('salida')
    parser.add_argument('--base', required=True,
                        help='SHA completo del cierre que produjo el APK.')
    parser.add_argument('--marca-toque', action='store_true',
                        help='Indicador temporal de puntero; restaura el ajuste previo.')
    parser.add_argument('--pulsacion-ms', type=int, choices=[120, 300], default=120,
                        help='Pulsacion menor que el umbral de pulsacion larga del Honor.')
    args = parser.parse_args()
    if not re.fullmatch(r'[a-fA-F0-9]{40}', args.base):
        raise ValueError('Se requiere el SHA completo del cierre.')
    output = output_directory(args.salida)
    name = f'rec{args.caso:02}'
    target = output / f'{name}.mp4'
    raw = output / f'{name}-transitorio.mp4'
    metadata = output / f'{name}.json'
    if any(p.exists() for p in [target, raw, metadata]):
        raise ValueError('No sobrescribir corrida.')
    rows = observe()
    if not any('BUQUE ALFA' in text and '977' in text for _, text in rows):
        raise RuntimeError('Requiere el viaje anterior A01 visible (977).')
    load = position(rows, 'Cargar archivo BAPLIE')
    remote = f'/sdcard/Movies/t98b/{args.base[:7]}-{name}.mp4'
    adb('shell', 'mkdir', '-p', '/sdcard/Movies/t98b')
    existing = subprocess.run([ADB, 'shell', 'test', '-e', remote], capture_output=True)
    if existing.returncode == 0:
        raise ValueError('Video remoto existente: no sobrescribir.')
    pointer_before = None
    long_press_timeout = None
    if args.marca_toque:
        long_press_timeout = adb('shell', 'settings', 'get', 'secure',
                                 'long_press_timeout').decode().strip()
        if args.pulsacion_ms > 120 and (
                not long_press_timeout.isdigit() or
                args.pulsacion_ms >= int(long_press_timeout)):
            raise RuntimeError('No se acredita una pulsacion inferior al umbral largo.')
        pointer_before = adb('shell', 'settings', 'get', 'system',
                             'pointer_location').decode().strip()
        if pointer_before not in {'0', '1', 'null'}:
            raise RuntimeError('Ajuste de puntero desconocido; no modificar.')
        adb('shell', 'settings', 'put', 'system', 'pointer_location', '1')
    # Se conserva el PID propio; nunca se detienen grabadores por nombre.
    recording_pid = adb('shell',
        f'screenrecord --time-limit 60 --bit-rate 4000000 {remote} '
        '>/dev/null 2>&1 & echo $!').decode().strip()
    if not re.fullmatch(r'[0-9]+', recording_pid):
        if pointer_before is not None:
            restore_pointer(pointer_before)
        raise RuntimeError('No se obtuvo el PID del grabador propio.')
    actions = []
    observations = []
    success = False
    try:
        time.sleep(0.5)
        tap(load)
        selector = observe(True, r't98b|\.edi$|Descargas')
        # DocumentsUI puede volver a Descargas al cancelar la selección previa.
        folders = [(bounds, label) for bounds, label in selector if label == 't98b']
        if len(folders) == 1 and not any(text.endswith('.edi') for _, text in selector):
            tap(position(folders, 't98b'))
            selector = observe(True, r't98b|\.edi$|Descargas')
        if not any(text == 't98b' for _, text in selector):
            raise RuntimeError('El selector debe estar en Descargas/t98b.')
        filename = CASES[args.caso - 1]
        # El catálogo ya fue observado en esta carpeta. Volver arriba si
        # el selector conserva el desplazamiento de la operación previa.
        for _ in range(3):
            if any(text == filename for _, text in selector):
                break
            adb('shell', 'input', 'swipe', '400', '500', '400', '1400', '500')
            selector = observe(True, r't98b|\.edi$')
        selected = position(selector, filename)
        actions.append({'evento': 'confirma_archivo', 'utcHost': utc()})
        if args.marca_toque:
            # Una pulsación estacionaria corta hace observable el contacto
            # inyectado en varios cuadros; no llega al umbral de pulsación larga.
            x, y = map(str, selected)
            adb('shell', 'input', 'swipe', x, y, x, y, str(args.pulsacion_ms))
        else:
            tap(selected)
        # Retardo fijo declarado. No se resta del resultado ni se usa como
        # tiempo de recuperación. El video puede mostrar que no respondió.
        time.sleep(1.0)
        if args.caso == 3:
            observations = observe()
            if not any('Parámetros del buque' in t for _, t in observations):
                raise RuntimeError('El 03 no mostró la admisión esperada; revisar video.')
            actions.append({'evento': '03_abre_parametros_no_es_rechazo', 'utcHost': utc()})
        else:
            actions.append({'evento': 'sonda_boton_carga', 'utcHost': utc(),
                            'retardoFijoSolicitadoS': 1.0})
            tap(load)
            picker_after = observe(True, r't98b|\.edi$')
            actions.append({'evento': 'selector_observado_tras_sonda',
                            'utcHost': utc(), 'visible': bool(picker_after)})
        success = True
    finally:
        if pointer_before is not None:
            restore_pointer(pointer_before)
        # Verifica la línea de órdenes antes de señalar el PID reservado.
        command = adb('shell', 'cat', f'/proc/{recording_pid}/cmdline')
        if remote.encode() not in command or b'screenrecord' not in command:
            raise RuntimeError('El PID ya no corresponde al grabador propio.')
        adb('shell', 'kill', '-2', recording_pid)
        time.sleep(1.0)
        adb('pull', remote, str(raw))
        original_probe, probe = crop_video(raw, target)
        if not probe.get('streams'):
            raise RuntimeError('Video sin cuadros: conservar el transitorio.')
        original_pts = [f['best_effort_timestamp_time'] for f in original_probe['frames']]
        cropped_pts = [f['best_effort_timestamp_time'] for f in probe['frames']]
        temporal_valid = original_pts == cropped_pts and all(
            float(b) > float(a) for a, b in zip(cropped_pts, cropped_pts[1:]))
        del probe['frames']
        # Cancelar fuera del video: Back puede subir primero a Descargas.
        # Solo repetir Back si se sigue observando el selector, nunca a ciegas.
        picker_after = observe(True, r't98b|\.edi$|Descargas')
        for _ in range(3):
            if not picker_after:
                break
            adb('shell', 'input', 'keyevent', '4')
            observations = observe()
            if observations:
                break
            picker_after = observe(True, r't98b|\.edi$|Descargas')
        if not observations:
            observations = observe()
        admission = observations if args.caso == 3 else []
        if args.caso == 3 and any('Parámetros del buque' in t for _, t in observations):
            tap(position(observations, 'Cancelar'))
            observations = observe()
        metadata.write_text(json.dumps({'fase': 'B',
            'base': args.base,
            'caso': CASES[args.caso - 1], 'instrumentoTermino': success,
            'accionesHostNoSonMedicion': actions,
            'observacionFinalSanitizada': observations, 'video': probe,
            'admision03SinConfirmar': admission,
            'videoOrigen': {k: v for k, v in original_probe.items() if k != 'frames'},
            'ptsOrigen': original_pts, 'ptsSalida': cropped_pts,
            'ptsIgualesYMonotonicos': temporal_valid,
            'punteroAntes': pointer_before,
            'marcaToque': args.marca_toque,
            'pulsacionSolicitadaMs': args.pulsacion_ms if args.marca_toque else None,
            'umbralPulsacionLargaMs': long_press_timeout,
            'anotacionPTS': 'PENDIENTE: seleccionar cuadros observados, no tiempos ADB',
            'sanitizacion': 'Recorte de 80 px de barra de estado; sin login ni cuenta'},
            ensure_ascii=False, indent=2), encoding='utf-8')
        if not temporal_valid:
            raise RuntimeError('PTS no conservados: no medir ni retirar el transitorio.')
        # Solo artefactos propios, tras comparar todos los PTS originales.
        raw.unlink()
        adb('shell', 'rm', remote)
    print(json.dumps({'caso': args.caso, 'video': str(target),
                      'instrumentoTermino': success, 'dictamen': 'pendiente PTS'}))


if __name__ == '__main__':
    main()
