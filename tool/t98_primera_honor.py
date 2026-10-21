"""Recorrido de primera visualización en la app Android T98 exclusivamente.

ADB está autorizado por Carlos para esta sesión. Tiempos del host solo sirven
para trazabilidad; el dictamen requiere anotar el icono y la rejilla en video.
"""
import argparse
import hashlib
import json
import re
import subprocess
import time
import xml.etree.ElementTree as ET

from t98_honor_ui import PACKAGE, observe
from t98_inventario import output_directory
from t98_recuperacion_honor import (adb, crop_video, position, restore_pointer,
                                    tap, utc)


def icon():
    raw = adb('exec-out', 'uiautomator', 'dump', '/dev/tty')
    a, b = raw.find(b'<?xml'), raw.rfind(b'</hierarchy>')
    root = ET.fromstring(raw[a:b+len(b'</hierarchy>')])
    # No conservar ni mostrar otras aplicaciones o nombres del launcher.
    rows = [(n.get('bounds', ''), 'BayStream T98') for n in root.iter('node')
            if n.get('text') == 'BayStream T98'
            and n.get('content-desc') == 'BayStream T98']
    return position(rows, 'BayStream T98')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('salida')
    p.add_argument('--base', required=True, help='SHA completo del APK medido.')
    p.add_argument('--perfil', choices=['con', 'sin'], required=True)
    p.add_argument('--reiniciar-datos-t98', action='store_true',
                   help='Borra SOLO los datos desechables de la app .t98, antes del video.')
    args = p.parse_args()
    if not re.fullmatch(r'[a-fA-F0-9]{40}', args.base):
        raise ValueError('Se requiere el SHA completo del cierre.')
    if args.reiniciar_datos_t98 and args.perfil != 'sin':
        raise ValueError('No reiniciar una condición con perfil.')
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    if args.reiniciar_datos_t98:
        adb('shell', 'am', 'force-stop', PACKAGE)
        if adb('shell', 'pm', 'clear', PACKAGE).decode().strip() != 'Success':
            raise RuntimeError('No se confirmó el reinicio exclusivo de .t98.')
    else:
        adb('shell', 'am', 'force-stop', PACKAGE)
    adb('shell', 'input', 'keyevent', '3')
    for page in range(7):
        try:
            point = icon()
            break
        except RuntimeError:
            if page == 6:
                raise
            # Home puede volver a la página principal. Se busca solo el
            # icono propio; no se abren otras apps ni se conserva su censo.
            adb('shell', 'input', 'swipe', '640', '900', '100', '900', '300')
    before = adb('shell', 'settings', 'get', 'system', 'pointer_location').decode().strip()
    threshold = adb('shell', 'settings', 'get', 'secure', 'long_press_timeout').decode().strip()
    if before not in {'0', '1', 'null'} or not threshold.isdigit() or int(threshold) <= 300:
        raise RuntimeError('No se acredita ajuste restaurable y toque corto.')
    remote = '/sdcard/Movies/t98b/pv-'+out.name+'.mp4'
    if subprocess.run([__import__('t98_honor_ui').ADB, 'shell', 'test', '-e', remote],
                      capture_output=True).returncode == 0:
        raise ValueError('Video remoto existente.')
    adb('shell', 'mkdir', '-p', '/sdcard/Movies/t98b')
    adb('shell', 'settings', 'put', 'system', 'pointer_location', '1')
    pid = None
    actions = []
    observations = []
    error = None

    def act(label, xy, contact=False):
        actions.append({'accion': label, 'utcHostSoloTrazabilidad': utc()})
        if contact:
            x, y = map(str, xy)
            adb('shell', 'input', 'swipe', x, y, x, y, '300')
        else:
            tap(xy)

    try:
        time.sleep(.5)  # Calentar indicador antes de abrir el video.
        pid = adb('shell', f'screenrecord --time-limit 120 --bit-rate 4000000 {remote} '
                  '>/dev/null 2>&1 & echo $!').decode().strip()
        if not re.fullmatch(r'\d+', pid):
            raise RuntimeError('Sin PID propio de captura.')
        time.sleep(.5)
        act('1 abrir icono BayStream T98', point, True)
        rows = observe()
        act('2 Seleccionar archivo (inicio)', position(rows, 'Seleccionar archivo'))
        rows = observe(True, r't98b|A01\.edi$|Descargas')
        if any(t == 't98b' for _, t in rows) and not any(t == 'A01.edi' for _, t in rows):
            # Si t98b es el título, su rectángulo no es una carpeta. Solo abrir
            # una fila situada debajo de la barra de navegación.
            folders = [(b, t) for b, t in rows if t == 't98b'
                       and int(re.findall(r'\d+', b)[1]) > 250]
            if len(folders) == 1:
                tap(position(folders, 't98b'))
                rows = observe(True, r't98b|A01\.edi$')
        for _ in range(3):
            if any(t == 'A01.edi' for _, t in rows):
                break
            adb('shell', 'input', 'swipe', '400', '1350', '400', '430', '180')
            rows = observe(True, r't98b|A01\.edi$')
        act('3 seleccionar A01.edi (selector cuenta una vez)', position(rows, 'A01.edi'))
        rows = observe()
        if args.perfil == 'sin':
            if not any('Parámetros del buque' in t for _, t in rows):
                raise RuntimeError('Sin perfil no abrió Parámetros.')
            for _ in range(8):
                if any(t == 'No lo tengo' or t.startswith('No lo tengo |') for _, t in rows):
                    break
                adb('shell', 'input', 'swipe', '400', '1350', '400', '400', '160')
                rows = observe()
            act('4 No lo tengo', position(rows, 'No lo tengo'))
            rows = observe()
            for _ in range(3):
                if any(t.startswith('Confirmar y ver') for _, t in rows):
                    break
                adb('shell', 'input', 'swipe', '400', '1350', '400', '400', '160')
                rows = observe()
            labels = [t for _, t in rows if t.startswith('Confirmar y ver')]
            if len(labels) != 1:
                raise RuntimeError('Confirmación no única.')
            act('5 '+labels[0], position(rows, labels[0]))
            rows = observe()
        elif any('Parámetros del buque' in t for _, t in rows):
            raise RuntimeError('La condición con perfil abrió Parámetros.')
        observations.append({'etapa': 'tras_carga', 'resumen': [t for _, t in rows
                             if 'BUQUE ALFA' in t]})
        act(('6' if args.perfil == 'sin' else '4')+' Plano', position(rows, 'Plano'))
        rows = observe()
        observations.append({'etapa': 'tras_Bay_Plan', 'nodos': rows})
        if not any('Bahía' in t or 'Bahia' in t for _, t in rows):
            raise RuntimeError('No se corroboró el plano; revisar video.')
        time.sleep(.5)
    except Exception as exc:
        error = str(exc)
    finally:
        restore_pointer(before)
        if pid and re.fullmatch(r'\d+', pid):
            command = adb('shell', 'cat', f'/proc/{pid}/cmdline')
            if b'screenrecord' not in command or remote.encode() not in command:
                raise RuntimeError('PID no es el grabador reservado.')
            adb('shell', 'kill', '-2', pid)
            time.sleep(1)
            raw, target = out/'transitorio.mp4', out/'video.mp4'
            adb('pull', remote, str(raw))
            original, cropped = crop_video(raw, target)
            source_pts = [f['best_effort_timestamp_time'] for f in original['frames']]
            pts = [f['best_effort_timestamp_time'] for f in cropped['frames']]
            valid = pts == source_pts and all(float(b)>float(a) for a,b in zip(pts,pts[1:]))
            meta = {'fase': 'B', 'base': args.base,
                    'perfil': args.perfil, 'reinicioExclusivoT98': args.reiniciar_datos_t98,
                    'errorInstrumento': error, 'accionesHostNoSonMedicion': actions,
                    'observaciones': observations, 'pts': pts,
                    'ptsOrigenIgualesYMonotonicos': valid,
                    'streams': cropped['streams'], 'punteroAntes': before,
                    'umbralLargoMs': threshold,
                    'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
                    'dictamen': 'Pendiente de anotar icono y rejilla en cuadros originales.'}
            (out/'captura.json').write_text(json.dumps(meta, ensure_ascii=False, indent=2),
                                             encoding='utf-8')
            if valid:
                raw.unlink()
                adb('shell', 'rm', remote)
            else:
                raise RuntimeError('No medir: PTS distintos.')
    print(json.dumps({'error': error, 'video': str(out/'video.mp4'),
                      'acciones': len(actions), 'dictamen': 'Pendiente PTS'}))
    if error:
        raise RuntimeError(error)


if __name__ == '__main__':
    main()
