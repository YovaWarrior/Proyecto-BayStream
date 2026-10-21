"""T-100 · Copia limpia de sprint3-cierre-2 en %TEMP% para el manual de usuario.

Prepara, compila y nunca publica ni escribe en Git. Los comandos de Flutter
van en serie (AGENTS.md, punto 3). La configuración privada de Firebase solo
se pasa por ruta; no se abre ni se imprime. Misma receta que tool/t98_cierre2.py,
con el namespace t100 y la identidad Android .t100.

    python -I tool/t100_preparar.py preparar
    python -I tool/t100_preparar.py windows | web | android
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import tarfile
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
BASE = '33404a5804be4fad85aab80dd923a7ae9e878ee9'
ROOT = Path(os.environ['TEMP']) / 't100-33404a5-20oct'
APP = ROOT / 'app'
FLUTTER = r'C:\flutter\bin\flutter.bat'
CONFIG = Path(r'C:\Proyectos\baystream-privado\firebase-prod.json')
# El SDK C++ de Firebase (915 MB) se reutiliza por enlace duro desde una
# copia previa, para no descargarlo otra vez; CMake lo extrae de nuevo.
SDK_PREVIO = (Path(os.environ['TEMP']) / 't98-b-33404a5-20oct/app/build/windows/x64'
              / 'firebase_cpp_sdk_windows_13.9.0.zip')


def write(name, data):
    (ROOT / name).write_text(json.dumps(data, ensure_ascii=False, indent=2),
                             encoding='utf-8')


def manifest():
    return {p.relative_to(APP).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(APP.rglob('*')) if p.is_file()
            and not p.relative_to(APP).as_posix().startswith(('build/', '.dart_tool/'))}


def check_product():
    original = json.loads((ROOT / 'manifiesto-original.json').read_text(encoding='utf-8'))
    paths = [s for s in original if s.startswith('lib/') or s in ['pubspec.yaml', 'pubspec.lock']]
    changed = [s for s in paths
               if hashlib.sha256((APP / s).read_bytes()).hexdigest() != original[s]]
    if changed:
        raise RuntimeError('Producto de la copia distinto del cierre: ' + ', '.join(changed))
    return {'archivosProducto': len(paths), 'diferencias': changed}


def prepare():
    sha = subprocess.check_output(['git', 'rev-parse', 'sprint3-cierre-2^{commit}'],
                                  cwd=REPO, text=True).strip()
    if sha != BASE:
        raise RuntimeError('La etiqueta no apunta al cierre autorizado.')
    ROOT.mkdir(exist_ok=True)
    APP.mkdir()  # Nunca reutilizar una copia anterior.
    archive = ROOT / 'cierre.tar'
    subprocess.run(['git', 'archive', '--format=tar', f'--output={archive}', BASE],
                   cwd=REPO, check=True)
    with tarfile.open(archive) as source:
        source.extractall(APP, filter='data')
    original = manifest()
    write('manifiesto-original.json', original)
    # Fecha actual: la limpieza de temporales borra antes lo que trae fechas viejas.
    now = datetime.now().timestamp()
    for p in APP.rglob('*'):
        if p.is_file():
            os.utime(p, (now, now))
    overlay = REPO / 'tool/t100_main.dart'
    shutil.copyfile(overlay, APP / 'tool/t100_main.dart')
    # Identidad Android propia, solo en la copia.
    gradle = APP / 'android/app/build.gradle.kts'
    old = gradle.read_bytes()
    needle = b'applicationId = "gt.cmartinez.baystream"'
    if old.count(needle) != 1:
        raise RuntimeError('Identidad Android inesperada.')
    gradle.write_bytes(old.replace(needle, b'applicationId = "gt.cmartinez.baystream.t100"'))
    xml = APP / 'android/app/src/main/AndroidManifest.xml'
    x = xml.read_bytes()
    if x.count(b'android:label="BayStream"') != 1:
        raise RuntimeError('Etiqueta Android inesperada.')
    xml.write_bytes(x.replace(b'android:label="BayStream"', b'android:label="BayStream T100"'))
    if SDK_PREVIO.is_file():
        dest = APP / 'build/windows/x64'
        dest.mkdir(parents=True)
        os.link(SDK_PREVIO, dest / SDK_PREVIO.name)
    write('preparacion.json', {
        'base': BASE, 'archivos': len(original),
        'tarSHA256': hashlib.sha256(archive.read_bytes()).hexdigest(),
        'overlay': {'archivo': 'tool/t100_main.dart',
                    'sha256': hashlib.sha256(overlay.read_bytes()).hexdigest()},
        'android': 'gt.cmartinez.baystream.t100, rótulo BayStream T100 (solo en la copia)',
        'sdkFirebaseReutilizado': SDK_PREVIO.is_file(),
        'producto': check_product(),
        'fecha': datetime.now(timezone.utc).isoformat()})
    print('Copia nueva preparada en', APP, flush=True)


def run(name, *args):
    log = ROOT / (name + '.log')
    if log.exists():
        raise ValueError('No sobrescribir registro: ' + name)
    print('Inicia ' + name, flush=True)
    started = datetime.now(timezone.utc).isoformat()
    with log.open('x', encoding='utf-8') as stream:
        code = subprocess.run([FLUTTER, *args], cwd=APP,
                              stdout=stream, stderr=subprocess.STDOUT).returncode
    write(name + '.ejecucion.json', {'base': BASE, 'inicioUTC': started,
          'finUTC': datetime.now(timezone.utc).isoformat(), 'exit': code})
    print(f'Termina {name}: exit {code}', flush=True)
    if code:
        raise RuntimeError('Comando falló; ver ' + str(log))


def common():
    if not CONFIG.is_file() or (APP / 'android/key.properties').exists():
        raise RuntimeError('Falta la configuración autorizada o hay una firma ajena.')
    return ['--release', '--target=tool/t100_main.dart',
            '--dart-define=T100_FIREBASE=true', f'--dart-define-from-file={CONFIG}']


def record(kind, path):
    data = json.loads((ROOT / 'binarios.json').read_text(encoding='utf-8')) \
        if (ROOT / 'binarios.json').exists() else {'base': BASE, 'artefactos': {}}
    data['artefactos'][kind] = {'ruta': str(path), 'bytes': path.stat().st_size,
                                'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                                'producto': check_product()}
    write('binarios.json', data)


def pub_get():
    if not (ROOT / 'pub-get.log').exists():
        run('pub-get', 'pub', 'get', '--offline')


def windows():
    pub_get()
    run('build-windows', 'build', 'windows', '--no-pub', *common(),
        f'--dart-define=T100_WINDOWS_STORE={ROOT / "store-windows"}')
    record('windows', APP / 'build/windows/x64/runner/Release/baystream.exe')


def web():
    pub_get()
    run('build-web', 'build', 'web', '--no-pub', '--no-web-resources-cdn',
        '--pwa-strategy=none', *common())
    record('web', APP / 'build/web/main.dart.js')


def android():
    # Sin --no-pub: con integration_test entre las dependencias de desarrollo,
    # solo así Flutter regenera el registrante para release (flutter#162649).
    run('build-android', 'build', 'apk', *common())
    record('apk', APP / 'build/app/outputs/flutter-apk/app-release.apk')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('accion', choices=['preparar', 'windows', 'web', 'android'])
    {'preparar': prepare, 'windows': windows, 'web': web,
     'android': android}[parser.parse_args().accion]()
