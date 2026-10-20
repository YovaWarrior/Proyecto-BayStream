"""Observación/taps del paquete de aceptación; XML sanitizado antes de guardar.

Uso: python -I tool/t112acc_honor.py ver nombre
     python -I tool/t112acc_honor.py tap X Y nombre
     python -I tool/t112acc_honor.py swipe X1 Y1 X2 Y2 nombre
     python -I tool/t112acc_honor.py key CODIGO nombre
"""
import os
from pathlib import Path
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

adb = str(Path(os.environ['LOCALAPPDATA']) / 'Android/Sdk/platform-tools/adb.exe')
salida = Path(__file__).resolve().parents[1] / 'build/t112acc/honor'
accion, *argumentos = sys.argv[1:]
nombre = argumentos.pop()
if not re.fullmatch(r'[a-z0-9-]+', nombre):
    raise SystemExit('Nombre de evidencia no permitido')
if accion != 'ver':
    orden = {'tap': 'tap', 'swipe': 'swipe', 'key': 'keyevent'}[accion]
    if not all(re.fullmatch(r'\d+', v) for v in argumentos):
        raise SystemExit('Solo argumentos numéricos de input')
    subprocess.run([adb, 'shell', 'input', orden, *argumentos], check=True)
texto = subprocess.check_output([adb, 'exec-out', 'uiautomator', 'dump', '/dev/tty']).decode(
    'utf-8', errors='replace')
texto = re.sub(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '[CUENTA OMITIDA]', texto)
root = ET.fromstring(texto[texto.index('<?xml'):texto.index('</hierarchy>')+12])
packages = {n.get('package') for n in root.iter('node') if n.get('package')}
if packages != {'gt.cmartinez.baystream.t112acc'}:
    raise SystemExit('Fuera del banco de aceptación: captura descartada, sin guardar XML ni imagen')
salida.mkdir(parents=True, exist_ok=True)
(salida / f'{nombre}.xml').write_text(texto, encoding='utf-8')
(salida / f'{nombre}.png').write_bytes(subprocess.check_output([adb, 'exec-out', 'screencap', '-p']))
for node in root.iter('node'):
    label = node.get('text') or node.get('content-desc')
    if label:
        print(label, node.get('bounds'))
print(salida / f'{nombre}.png')
