# Ronda del Honor del 19-oct (Timonel): capturas y volcados sanitizados.
#
# Todo pasa en memoria antes de guardar (2.4 de SPRINT-3.md):
#   - la captura sale de `adb exec-out screencap -p`, se le recorta la barra
#     de estado (avisos del sistema) y solo entonces se guarda;
#   - el volcado sale de `adb exec-out uiautomator dump /dev/tty`, se queda
#     solo con los nodos de la app de prueba y oculta cualquier correo.
#
# Uso:
#   python tool/honor19_capturas.py cap <carpeta TEMP> <nombre>
#   python tool/honor19_capturas.py dump [<filtro>]
# Con HONOR19_PKG se vuelca otro paquete (el selector del sistema), siempre
# con un filtro, para no listar nombres de archivos ajenos.
# La carpeta de salida tiene que estar en %TEMP%.
import io
import os
import re
import subprocess
import sys

ADB = os.path.join(os.environ['LOCALAPPDATA'], 'Android', 'Sdk',
                   'platform-tools', 'adb.exe')
PACKAGE = os.environ.get('HONOR19_PKG', 'gt.cmartinez.baystream.honor19')
STATUS_BAR_PX = 80
EMAIL = re.compile(r'[\w.+-]+@[\w-]+\.[\w.-]+')


def adb(*args):
    return subprocess.run([ADB, *args], capture_output=True, check=True).stdout


def capture(folder, name):
    from PIL import Image
    if 'temp' not in os.path.abspath(folder).lower():
        sys.exit('La carpeta de capturas tiene que estar en %TEMP%.')
    image = Image.open(io.BytesIO(adb('exec-out', 'screencap', '-p')))
    width, height = image.size
    cropped = image.crop((0, STATUS_BAR_PX, width, height))
    os.makedirs(folder, exist_ok=True)
    path = os.path.join(folder, name if name.endswith('.png') else name + '.png')
    cropped.save(path)
    print(f'{path} {cropped.size[0]}x{cropped.size[1]}')


def dump(pattern=None):
    xml = adb('exec-out', 'uiautomator', 'dump', '/dev/tty').decode('utf-8', 'replace')
    xml = EMAIL.sub('[correo oculto]', xml)
    rows = []
    for node in re.finditer(r'<node [^>]*>', xml):
        attrs = dict(re.findall(r'([\w-]+)="([^"]*)"', node.group(0)))
        if attrs.get('package') != PACKAGE:
            continue
        label = (attrs.get('content-desc') or attrs.get('text') or '').strip()
        if not label:
            continue
        label = label.replace('&#10;', ' | ').replace('&amp;', '&')
        if pattern and not re.search(pattern, label, re.IGNORECASE):
            continue
        rows.append(f"{attrs.get('bounds', '')} {label}")
    print('\n'.join(rows) if rows else '(sin nodos de la app)')


if __name__ == '__main__':
    if sys.argv[1] == 'cap':
        capture(sys.argv[2], sys.argv[3])
    else:
        dump(sys.argv[2] if len(sys.argv) > 2 else None)
