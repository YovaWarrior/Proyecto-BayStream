"""Aceptación T-112: archivos Git de solo lectura y verificaciones aisladas.

Uso: python -I tool/t112acc_verificar.py preparar|pruebas|cotejos
No modifica el producto ni los instrumentos de T-98/T-99 del árbol compartido.
"""
import hashlib
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import time

REPO = Path(__file__).resolve().parents[1]
BASE = Path(os.environ['TEMP']) / 't112acc-33404a5'
EVIDENCIA = REPO / 'build/t112acc'
FLUTTER = shutil.which('flutter')
CORPUS = Path(r'C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files')


def git(*args):
    return subprocess.check_output(['git', *args], cwd=REPO)


def ejecutar(nombre, carpeta, *args):
    registros = EVIDENCIA / 'registros'
    registros.mkdir(parents=True, exist_ok=True)
    inicio = time.monotonic()
    with (registros / f'{nombre}.log').open('wb') as salida:
        result = subprocess.run(list(args), cwd=carpeta, stdout=salida,
                                stderr=subprocess.STDOUT)
    print(f'{nombre}: exit={result.returncode}, {time.monotonic()-inicio:.1f}s', flush=True)
    return result.returncode


def preparar():
    if BASE.exists():
        raise SystemExit(f'La carpeta ya existe: {BASE}; no se reemplaza.')
    BASE.mkdir(parents=True)
    EVIDENCIA.mkdir(parents=True, exist_ok=True)
    for nombre, ref in [('cierre', 'sprint3-cierre-2'), ('padre', 'cdab56b')]:
        destino = BASE / nombre
        destino.mkdir()
        archivo = git('archive', '--format=tar', ref)
        with tarfile.open(fileobj=io.BytesIO(archivo)) as tar:
            tar.extractall(destino, filter='data')
        (EVIDENCIA / f'{nombre}-archivo.sha256').write_text(
            hashlib.sha256(archivo).hexdigest() + '\n', encoding='utf-8')
    # La foto del árbol compartido permite comprobar que no tocamos trabajo ajeno.
    foto = {}
    for carpeta in ['lib', 'test', 'tool', 'docs', 'integration_test']:
        for p in (REPO / carpeta).rglob('*'):
            if p.is_file() and '__pycache__' not in p.parts:
                foto[p.relative_to(REPO).as_posix()] = hashlib.sha256(p.read_bytes()).hexdigest()
    for nombre in ['pubspec.yaml', 'pubspec.lock']:
        foto[nombre] = hashlib.sha256((REPO / nombre).read_bytes()).hexdigest()
    (EVIDENCIA / 'arbol-antes.json').write_text(json.dumps(foto, indent=2), encoding='utf-8')
    print(BASE)


def pruebas():
    cierre = BASE / 'cierre'
    for nombre, args in [
        ('pub-get', ['pub', 'get', '--offline']),
        ('suite', ['test', '--reporter=json']),
        ('analyze', ['analyze']),
    ]:
        if ejecutar(nombre, cierre, FLUTTER, *args):
            raise SystemExit(1)
    excluir = {'t108_corpus_test.dart', 't110_corpus_test.dart',
               't110acc_corpus_test.dart', 't111acc_card_test.dart', 't98_estandares_test.dart'}
    instrumentos = sorted(p for p in (cierre / 'tool').glob('*_test.dart') if p.name not in excluir)
    (EVIDENCIA / 'corpus-instrumentos.json').write_text(
        json.dumps([p.name for p in instrumentos], indent=2), encoding='utf-8')
    raise SystemExit(ejecutar('corpus', cierre, FLUTTER, 'test', '--reporter=json',
                             f'--dart-define=BAYSTREAM_CORPUS_DIRECTORY={CORPUS}',
                             *[str(p) for p in instrumentos]))


def cotejos():
    padre, cierre = BASE / 'padre', BASE / 'cierre'
    if ejecutar('padre-pub-get', padre, FLUTTER, 'pub', 'get', '--offline'):
        raise SystemExit(1)
    casos = [
        ('t108', 't108_corpus_test.dart', 'T108_OUTPUT', 'T108_CAPTURE_BASELINE'),
        ('t110', 't110_corpus_test.dart', 'T110_OUTPUT', 'T110_CAPTURE'),
        ('t110acc', 't110acc_corpus_test.dart', 'T110ACC_OUTPUT', 'T110ACC_CAPTURE_BASELINE'),
        ('t111acc', 't111acc_card_test.dart', 'T111ACC_OUTPUT', 'T111ACC_CAPTURE_BASELINE'),
    ]
    for nombre, instrumento, variable, captura in casos:
        salida = BASE / nombre
        salida.mkdir(exist_ok=True)
        comunes = ['test', f'tool/{instrumento}', '--reporter=json',
                   f'--dart-define=BAYSTREAM_CORPUS_DIRECTORY={CORPUS}',
                   f'--dart-define={variable}={salida}']
        if ejecutar(f'{nombre}-padre', padre, FLUTTER, *comunes,
                    f'--dart-define={captura}=true'):
            raise SystemExit(1)
        codigo = ejecutar(f'{nombre}-cierre', cierre, FLUTTER, *comunes)
        shutil.copytree(salida, EVIDENCIA / nombre, dirs_exist_ok=True)
        if codigo:
            if nombre != 't111acc':
                raise SystemExit(codigo)
            # Este instrumento exige una referencia anterior a T-111. cdab56b
            # ya tiene el singular: preservamos el exit 1 y cotejamos sus datos.
            antes = json.loads((salida / 'baseline.json').read_text(encoding='utf-8'))
            despues = json.loads((salida / 'head.json').read_text(encoding='utf-8'))
            if antes != despues or len(antes) != 192:
                raise SystemExit(codigo)
            print('T111acc: exit 1 conservado; 192 objetos idénticos. '
                  'Revisar los 48 requisitos históricos ACC2 del registro.', flush=True)


def clientes():
    cierre = BASE / 'cierre'
    if ejecutar('banco-analyze', cierre, FLUTTER, 'analyze', 'tool/t112acc_main.dart'):
        raise SystemExit(1)
    for nombre, args in [
        ('windows-build', ['build', 'windows', '--release', '-t', 'tool/t112acc_main.dart',
                           f'--dart-define=T112_STORE={BASE / "windows-store"}',
                           f'--dart-define=T112ACC_OUTPUT={BASE / "windows"}']),
        ('web-build', ['build', 'web', '--release', '--pwa-strategy=none', '-t', 'tool/t112acc_main.dart',
                       '--dart-define=T112ACC_OUTPUT=web']),
        ('honor-build', ['build', 'apk', '--profile', '-t', 'tool/t112acc_main.dart',
                         '--dart-define=T112ACC_OUTPUT=/data/user/0/gt.cmartinez.baystream.t112acc/files/evidencia']),
    ]:
        if ejecutar(nombre, cierre, FLUTTER, *args):
            raise SystemExit(1)


if __name__ == '__main__':
    {'preparar': preparar, 'pruebas': pruebas, 'cotejos': cotejos,
     'clientes': clientes}[sys.argv[1]]()
