"""Observación ADB de la app .t98; XML y barra de estado solo en memoria."""
import argparse
import io
import os
import re
import subprocess
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path

from t98_inventario import output_directory, sanitize


ADB = str(Path(os.environ['LOCALAPPDATA']) / 'Android/Sdk/platform-tools/adb.exe')
PACKAGE = 'gt.cmartinez.baystream.t98'


def observe(selector=False, pattern=None):
    # Una transición Flutter puede ofrecer temporalmente un árbol vacío.
    # Se reobserva, sin conservar ni mostrar el XML crudo.
    for _ in range(3):
        raw = subprocess.check_output(
            [ADB, 'exec-out', 'uiautomator', 'dump', '/dev/tty'])
        start, end = raw.find(b'<?xml'), raw.rfind(b'</hierarchy>')
        if start < 0 or end < 0:
            continue
        root = ET.fromstring(raw[start:end + len(b'</hierarchy>')])
        rows = []
        for node in root.iter('node'):
            package = node.get('package', '')
            if package != ('com.google.android.documentsui' if selector else PACKAGE):
                continue
            label = (node.get('content-desc') or node.get('text') or '').strip()
            if not label:
                continue
            if not selector and re.search(r'^(?:Iniciar sesión|Cerrar sesión)$', label):
                raise RuntimeError('Pantalla de cuenta: no volcar ni capturar.')
            if pattern and not re.search(pattern, label, re.I):
                continue
            rows.append((node.get('bounds', ''), sanitize(label.replace('\n', ' | '))))
        if rows:
            return rows
    return []


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--selector', action='store_true')
    parser.add_argument('--filtro')
    parser.add_argument('--captura', type=Path)
    parser.add_argument('--tocar', help='Etiqueta exacta observada en el árbol actual.')
    parser.add_argument('--guardar-observacion', type=Path)
    args = parser.parse_args()
    if args.selector and (not args.filtro or args.captura):
        raise ValueError('El selector exige filtro y no se captura.')
    rows = observe(args.selector, args.filtro)
    for bounds, label in rows:
        print(bounds, label)
    if not rows:
        print('(sin nodos que cumplan el filtro; no inferir estado)')
    if args.guardar_observacion:
        output_directory(str(args.guardar_observacion.resolve().parent))
        if args.guardar_observacion.exists():
            raise ValueError('No sobrescribir observación.')
        import json
        args.guardar_observacion.write_text(json.dumps({
            'utc': datetime.now(timezone.utc).isoformat(),
            'selector': args.selector, 'nodos': rows,
        }, ensure_ascii=False, indent=2), encoding='utf-8')
    if args.tocar:
        if re.search(r'cuenta|sesión|contraseña|correo', args.tocar, re.I):
            raise ValueError('Este ayudante no opera cuentas.')
        matches = [(bounds, label) for bounds, label in rows
                   if label == args.tocar or label.startswith(args.tocar + ' | ')]
        if len(matches) != 1:
            raise ValueError('La etiqueta debe resolver a un nodo visible único.')
        values = [int(v) for v in re.findall(r'\d+', matches[0][0])]
        if len(values) != 4:
            raise ValueError('Nodo sin límites utilizables.')
        left, top, right, bottom = values
        if right - left < 40 or bottom - top < 30:
            raise ValueError('Control recortado: desplazar antes de tocar.')
        subprocess.run([ADB, 'shell', 'input', 'tap',
                        str((left + right) // 2), str((top + bottom) // 2)], check=True)
        print('TOQUE', args.tocar, datetime.now(timezone.utc).isoformat())
    if args.captura:
        # Solo una captura con la app propia en primer plano, sin cuenta.
        if not observe():
            raise RuntimeError('No se confirmó la app de prueba.')
        output_directory(str(args.captura.resolve().parent))
        if args.captura.exists():
            raise ValueError('No sobrescribir evidencia.')
        from PIL import Image
        raw = subprocess.check_output([ADB, 'exec-out', 'screencap', '-p'])
        image = Image.open(io.BytesIO(raw))
        image.crop((0, 80, image.width, image.height)).save(args.captura)


if __name__ == '__main__':
    main()
