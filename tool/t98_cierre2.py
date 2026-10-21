"""Banco aislado T98 sobre el cierre 2; nunca publica ni escribe en Git.

Preparar, validar y compilar son fases separadas. Los comandos Flutter se
ejecutan en serie y requieren la ventana de máquina asignada por Carlos.
La configuración privada solo se pasa por ruta; no se abre ni se imprime.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
from datetime import datetime, timezone

REPO = Path(__file__).resolve().parents[1]
BASE = '33404a5804be4fad85aab80dd923a7ae9e878ee9'
ROOT = Path(os.environ['TEMP']) / 't98-b-33404a5-20oct'
APP = ROOT / 'app'
FLUTTER = r'C:\flutter\bin\flutter.bat'
CONFIG = Path(r'C:\Proyectos\baystream-privado\firebase-prod.json')


def write(name, data):
    (ROOT / name).write_text(json.dumps(data, ensure_ascii=False, indent=2),
                             encoding='utf-8')


def manifest():
    return {p.relative_to(APP).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(APP.rglob('*')) if p.is_file()}


def check_product():
    original = json.loads((ROOT/'manifiesto-original.json').read_text(encoding='utf-8'))
    paths = [s for s in original if s.startswith('lib/') or s in
             ['pubspec.yaml', 'pubspec.lock', 'lib/main.dart']]
    changed = [s for s in paths if hashlib.sha256((APP/s).read_bytes()).hexdigest() != original[s]]
    if changed:
        raise RuntimeError('Producto de la copia distinto del cierre: '+', '.join(changed))
    return {'archivosProducto': len(paths), 'diferencias': changed,
            'libDart': sum(s.startswith('lib/') and s.endswith('.dart') for s in paths)}


def prepare():
    sha = subprocess.check_output(['git', 'rev-parse', 'sprint3-cierre-2^{commit}'],
                                  cwd=REPO, text=True).strip()
    if sha != BASE:
        raise RuntimeError('La etiqueta no apunta al cierre autorizado.')
    ROOT.mkdir()  # Nunca reutilizar la copia anterior.
    archive = ROOT/'cierre.tar'
    subprocess.run(['git', 'archive', '--format=tar', f'--output={archive}', BASE],
                    cwd=REPO, check=True)
    APP.mkdir()
    with tarfile.open(archive) as source:
        source.extractall(APP, filter='data')
    original = manifest()
    write('manifiesto-original.json', original)
    overlays = []
    for p in sorted((REPO/'tool').glob('t98_*')):
        if p.is_file():
            dest = APP/'tool'/p.name
            overlays.append({'archivo': dest.relative_to(APP).as_posix(),
                             'sha256': hashlib.sha256(p.read_bytes()).hexdigest()})
            shutil.copyfile(p, dest)
    write('preparacion.json', {'base': BASE, 'archivosArchivo': len(original),
          'archivoTarSHA256': hashlib.sha256(archive.read_bytes()).hexdigest(),
          'overlaysSoloInstrumentos': overlays, 'producto': check_product()})
    print('Copia nueva preparada; producto idéntico y sin configuración privada copiada.', flush=True)


def run(name, *args):
    log = ROOT/(name+'.log')
    if log.exists():
        raise ValueError('No sobrescribir registro: '+name)
    print('Inicia '+name, flush=True)
    started = datetime.now(timezone.utc).isoformat()
    with log.open('x', encoding='utf-8') as stream:
        code = subprocess.run([FLUTTER, *args], cwd=APP,
                              stdout=stream, stderr=subprocess.STDOUT).returncode
    write(name+'.ejecucion.json', {'base': BASE, 'inicioUTC': started,
          'finUTC': datetime.now(timezone.utc).isoformat(), 'exit': code})
    print(f'Termina {name}: exit {code}', flush=True)
    if code:
        raise RuntimeError('Comando falló; conservar registro propio: '+name)


def validate():
    check_product()
    run('pub-get', 'pub', 'get', '--offline')
    # Antes de cambiar la etiqueta Android: T88 exige la etiqueta del producto.
    run('suite', 'test', '--no-pub', '--reporter=json')
    run('analyze', 'analyze', '--no-pub')
    run('conformidad', 'test', '--no-pub', 'tool/t98_estandares_test.dart',
        '--reporter=expanded', '--dart-define=T98_FASE=B',
        f'--dart-define=T98_BASE={BASE}',
        f'--dart-define=T98_SALIDA={ROOT / "conformidad"}')
    write('producto-despues-pruebas.json', check_product())


def build():
    check_product()
    if not CONFIG.is_file() or (APP/'android/key.properties').exists():
        raise RuntimeError('Falta configuración autorizada o hay una firma ajena en la copia.')
    gradle = APP/'android/app/build.gradle.kts'
    old = gradle.read_bytes()
    needle = b'applicationId = "gt.cmartinez.baystream"'
    if old.count(needle) != 1:
        raise RuntimeError('Identidad Android inesperada.')
    gradle.write_bytes(old.replace(needle, b'applicationId = "gt.cmartinez.baystream.t98"'))
    xml = APP/'android/app/src/main/AndroidManifest.xml'
    original_xml = xml.read_bytes()
    if original_xml.count(b'android:label="BayStream"') != 1:
        raise RuntimeError('Etiqueta Android inesperada.')
    xml.write_bytes(original_xml.replace(b'android:label="BayStream"',
                                         b'android:label="BayStream T98"'))
    common = ['--release', '--target=tool/t98_main.dart',
              '--dart-define=T98_FIREBASE=true', f'--dart-define-from-file={CONFIG}']
    run('build-windows', 'build', 'windows', *common,
        f'--dart-define=T98_WINDOWS_STORE={ROOT / "store-windows"}')
    run('build-web', 'build', 'web', '--no-web-resources-cdn', *common)
    # Sin --no-pub: requisito explícito del paquete Android aislado.
    run('build-android', 'build', 'apk', *common)
    products = {'windows': APP/'build/windows/x64/runner/Release/baystream.exe',
                'webMain': APP/'build/web/main.dart.js',
                'apk': APP/'build/app/outputs/flutter-apk/app-release.apk'}
    write('binarios.json', {'base': BASE, 'identidadAndroid': 'gt.cmartinez.baystream.t98',
          'firebase': True, 'objetivo': 'tool/t98_main.dart',
          'producto': check_product(), 'artefactos': {k: {'ruta': str(p),
          'bytes': p.stat().st_size, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
          for k,p in products.items()}})
    print('Tres binarios preparados y huellas guardadas.', flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('accion', choices=['preparar', 'validar', 'compilar'])
    {'preparar': prepare, 'validar': validate, 'compilar': build}[parser.parse_args().accion]()
