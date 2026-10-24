"""T-114 · Fase 3, entrega 1: la primera visualización en Android, en tres pasos.

Instrumento de RNF-002 (≤ 3 pasos y ≤ 30 s hasta la rejilla) para el emulador
(API 26, serial emulator-5554) con el banco r4 (gt.cmartinez.baystream.r4,
«BayStream R4»). El Honor solo con --serial y con el permiso de Carlos.

Hereda de tool/t98_primera_honor.py (ADB, uiautomator y screenrecord) y cambia
el recorrido, que desde 10.9 («ver primero, confirmar después») termina en la
rejilla al elegir el archivo:
  (1) el icono del lanzador (o `am start` si el icono no está a la vista, y se
      anota), (2) «Seleccionar archivo» en el inicio, (3) el archivo en el
      selector del sistema. No hay «No lo tengo», «Confirmar y ver el plano»
      ni pestaña «Plano»: el plano abre en previo, en la pestaña del plano.
La condición «sin perfil» (la que rige) reinicia antes los datos del banco;
«con perfil» (informativa) conserva el perfil guardado por una corrida previa.

El tiempo sale del video (PTS del primer cuadro con rejilla, revisado con
tool/t114_primera_cuadros.py), como en T-98; los tiempos del host son
trazabilidad. Los nombres de otras apps no se conservan.

python tool/t114_primera_android.py <salida en TEMP> --archivo T99_SINTETICO_977.edi --perfil sin --reiniciar-datos
"""
import argparse
import hashlib
import json
import os
import re
import subprocess
import time
from pathlib import Path

import t98_honor_ui
from t98_inventario import output_directory
from t98_recuperacion_honor import crop_video, position, restore_pointer, utc

ADB = t98_honor_ui.ADB
CARPETA_REMOTA = '/sdcard/Download/t114'


def adb(*args):
    return subprocess.run([ADB, *args], capture_output=True, check=True).stdout


def tap(point):
    adb('shell', 'input', 'tap', str(point[0]), str(point[1]))


SELECTOR_PAQUETES = ('com.google.android.documentsui', 'com.android.documentsui')
SELECTOR_RAICES = ('Show roots', 'Mostrar raíces')
SELECTOR_DESCARGAS = ('Descargas', 'Downloads', 'Download')


def observe(selector=False, pattern=None):
    if not selector:
        return t98_honor_ui.observe(False, pattern)
    return observar_selector(pattern)


def observar_selector(pattern=None):
    """Como t98_honor_ui.observe(True), pero el selector del emulador es el de AOSP."""
    import xml.etree.ElementTree as ET
    for _ in range(3):
        raw = subprocess.check_output([ADB, 'exec-out', 'uiautomator', 'dump', '/dev/tty'])
        start, end = raw.find(b'<?xml'), raw.rfind(b'</hierarchy>')
        if start < 0 or end < 0:
            continue
        root = ET.fromstring(raw[start:end + len(b'</hierarchy>')])
        rows = []
        for node in root.iter('node'):
            if node.get('package', '') not in SELECTOR_PAQUETES:
                continue
            label = (node.get('content-desc') or node.get('text') or '').strip()
            if not label or (pattern and not re.search(pattern, label, re.I)):
                continue
            rows.append((node.get('bounds', ''), t98_honor_ui.sanitize(label.replace('\n', ' | '))))
        if rows:
            return rows
    return []


def elegir_en_selector(archivo, intentos=8):
    """Devuelve la posición del archivo en el selector del sistema, navegando si hace falta.

    El selector de AOSP abre en «Recent» (vacío): se abre el cajón de raíces,
    Descargas, la carpeta t114 y ahí está el archivo. Es un solo paso del
    producto (el selector cuenta una vez), como en T-98.
    """
    patron = (r'^t114$|' + re.escape(archivo) + r'$|^(?:' + '|'.join(SELECTOR_DESCARGAS) + r')$|^(?:'
              + '|'.join(SELECTOR_RAICES) + r')$')
    for _ in range(intentos):
        rows = observar_selector(patron)
        if any(t == archivo for _, t in rows):
            try:
                return position(rows, archivo)
            except RuntimeError:
                # Recortado al borde (letra grande): subir un poco y volver a mirar.
                adb('shell', 'input', 'swipe', '400', '1300', '400', '800', '400')
                time.sleep(1)
                continue
        bajo = lambda b: int(re.findall(r'\d+', b)[1]) > 250  # noqa: E731
        carpeta = [(b, t) for b, t in rows if t == 't114' and bajo(b)]
        descargas = [(b, t) for b, t in rows if t in SELECTOR_DESCARGAS and bajo(b)]
        raices = [(b, t) for b, t in rows if t in SELECTOR_RAICES]
        if len(carpeta) == 1:
            tap(position(carpeta, 't114'))
        elif len(descargas) == 1:
            tap(position(descargas, descargas[0][1]))
        elif len(raices) == 1:
            tap(position(raices, raices[0][1]))
        else:
            adb('shell', 'input', 'swipe', '400', '1350', '400', '430', '180')
        time.sleep(1)
    raise RuntimeError(f'Control no visible o ambiguo: {archivo}')


def icono(rotulo):
    rows = [(b, t) for b, t in observe(False) if t == rotulo]
    return position(rows, rotulo) if rows else None


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('salida')
    p.add_argument('--archivo', required=True, help='Nombre del .edi ya copiado a /sdcard/Download/t114.')
    p.add_argument('--perfil', choices=['con', 'sin'], required=True)
    p.add_argument('--serial', default='emulator-5554')
    p.add_argument('--paquete', default='gt.cmartinez.baystream.r4')
    p.add_argument('--rotulo', default='BayStream R4')
    p.add_argument('--reiniciar-datos', action='store_true',
                   help='Borra SOLO los datos del banco r4 antes del video (condición sin perfil).')
    args = p.parse_args()
    if args.reiniciar_datos and args.perfil != 'sin':
        raise ValueError('No reiniciar una condición con perfil.')
    if args.serial != 'emulator-5554' and not os.environ.get('T114_HONOR_AUTORIZADO'):
        raise ValueError('El Honor solo con el permiso de Carlos (T114_HONOR_AUTORIZADO=1).')
    os.environ['ANDROID_SERIAL'] = args.serial
    t98_honor_ui.PACKAGE = args.paquete
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    paquete = args.paquete
    adb('shell', 'am', 'force-stop', paquete)
    if args.reiniciar_datos:
        if adb('shell', 'pm', 'clear', paquete).decode().strip() != 'Success':
            raise RuntimeError(f'No se confirmó el reinicio exclusivo de {paquete}.')
    adb('shell', 'input', 'keyevent', '3')
    time.sleep(1)
    before = adb('shell', 'settings', 'get', 'system', 'pointer_location').decode().strip()
    remote = f'{CARPETA_REMOTA}/video-{out.name}.mp4'
    adb('shell', 'mkdir', '-p', CARPETA_REMOTA)
    if adb('shell', 'ls', f'{CARPETA_REMOTA}/{args.archivo}').decode().strip() != f'{CARPETA_REMOTA}/{args.archivo}':
        raise RuntimeError(f'Falta {args.archivo} en {CARPETA_REMOTA}: copiarlo con adb push y el media scanner.')
    adb('shell', 'settings', 'put', 'system', 'pointer_location', '1')
    pid = None
    actions = []
    observations = []
    error = None

    def act(label, xy=None, contact=False):
        actions.append({'accion': label, 'utcHostSoloTrazabilidad': utc()})
        if xy is None:
            return
        if contact:
            x, y = map(str, xy)
            adb('shell', 'input', 'swipe', x, y, x, y, '300')
        else:
            tap(xy)

    try:
        time.sleep(.5)
        pid = adb('shell', f'screenrecord --time-limit 120 --bit-rate 4000000 {remote} '
                  '>/dev/null 2>&1 & echo $!').decode().strip()
        if not re.fullmatch(r'\d+', pid):
            raise RuntimeError('Sin PID propio de captura.')
        time.sleep(.5)
        punto = icono(args.rotulo)
        if punto is not None:
            act(f'1 abrir icono {args.rotulo}', punto, True)
        else:
            # El lanzador no muestra el icono (cajón de apps): se abre por su
            # nombre y se deja constancia. Sigue siendo un solo paso.
            act(f'1 abrir {paquete} con am start (icono no visible en el lanzador)')
            adb('shell', 'monkey', '-p', paquete, '-c', 'android.intent.category.LAUNCHER', '1')
        rows = observe()
        for _ in range(20):
            if any(t == 'Seleccionar archivo' or t.startswith('Seleccionar archivo |') for _, t in rows):
                break
            time.sleep(.5)
            rows = observe()
        act('2 Seleccionar archivo (inicio)', position(rows, 'Seleccionar archivo'))
        act(f'3 seleccionar {args.archivo} (el selector cuenta una vez)',
            elegir_en_selector(args.archivo))
        # Fin: la rejilla a la vista. Se corrobora por el árbol; el tiempo sale del video.
        rejilla = False
        for _ in range(60):
            time.sleep(.5)
            rows = observe()
            if any(re.search(r'bah[ií]a', t, re.I) for _, t in rows):
                rejilla = True
                break
        observations.append({'etapa': 'tras_seleccionar', 'rejillaEnElArbol': rejilla,
                             'nodos': [t for _, t in rows][:40]})
        if not rejilla:
            raise RuntimeError('No se corroboró el plano; revisar el video.')
        previo = any('Plano sin confirmar' in t or 'confirma la escala' in t
                     or 'confirma el buque' in t for _, t in rows)
        observations.append({'etapa': 'estado', 'previo': previo,
                             'parametrosAbiertos': any('Parámetros del buque' in t for _, t in rows)})
        time.sleep(1)
    except Exception as exc:  # noqa: BLE001 - se registra y se relanza al final
        error = str(exc)
    finally:
        restore_pointer(before)
        if pid and re.fullmatch(r'\d+', pid):
            command = adb('shell', 'cat', f'/proc/{pid}/cmdline')
            if b'screenrecord' not in command or remote.encode() not in command:
                raise RuntimeError('PID no es el grabador reservado.')
            adb('shell', 'kill', '-2', pid)
            time.sleep(1.5)
            raw, target = out / 'transitorio.mp4', out / 'video.mp4'
            adb('pull', remote, str(raw))
            original, cropped = crop_video(raw, target)
            source_pts = [f['best_effort_timestamp_time'] for f in original['frames']]
            pts = [f['best_effort_timestamp_time'] for f in cropped['frames']]
            valid = pts == source_pts and all(float(b) > float(a) for a, b in zip(pts, pts[1:]))
            meta = {'instrumento': 'tool/t114_primera_android.py', 'serial': args.serial,
                    'paquete': paquete, 'archivo': args.archivo, 'perfil': args.perfil,
                    'reinicioExclusivo': args.reiniciar_datos, 'errorInstrumento': error,
                    'accionesHostNoSonMedicion': actions, 'observaciones': observations,
                    'pasosDelProducto': 3, 'pts': pts,
                    'ptsOrigenIgualesYMonotonicos': valid, 'streams': cropped['streams'],
                    'punteroAntes': before,
                    'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
                    'dictamen': 'Pendiente: primer cuadro con rejilla (t114_primera_cuadros.py).'}
            (out / 'captura.json').write_text(json.dumps(meta, ensure_ascii=False, indent=2),
                                              encoding='utf-8')
            if valid:
                raw.unlink()
                adb('shell', 'rm', remote)
            else:
                raise RuntimeError('No medir: PTS distintos.')
    print(json.dumps({'error': error, 'video': str(out / 'video.mp4'),
                      'acciones': len(actions)}))
    if error:
        raise RuntimeError(error)


if __name__ == '__main__':
    main()
