"""T-113 · Secretos en el árbol y en la historia de sprint-3.

Recorre tres fuentes, solo con lecturas de Git que no tocan el índice:
  - arbol:      los archivos versionados, como están en la copia de trabajo;
  - sin_versionar: los que no están versionados ni ignorados (podrían
                entrar en el próximo commit);
  - historia:   cada blob alcanzable desde la rama (git rev-list --objects),
                es decir, todas las versiones de todos los archivos.

Busca claves de Google, claves privadas, cuentas de servicio, tokens, la
firma de Android, contraseñas literales, correos, UID de Firebase, rutas de
baystream-privado, archivos que el .gitignore protege y contenido del corpus
(huella igual a un archivo del corpus o tres o más contenedores del corpus).
Los .docx, .xlsx y .pptx se abren como ZIP y se revisa su XML.

El informe del repositorio da cuentas y rutas, nunca el valor. Los valores,
para revisarlos a mano, van solo a --privado (por omisión
%TEMP%\\t113\\revision-privada.json, fuera del repositorio).

Uso:

    python -I tool/t113_secretos.py --corpus <carpeta> [--rama sprint-3]
        [--salida build/t113] [--privado %TEMP%\\t113\\revision-privada.json]

Sale con 1 si encuentra una clave, token, clave privada, firma o archivo
protegido versionado; con 0 si solo hay hallazgos que piden revisión.
"""

import argparse
import hashlib
import io
import json
import os
import re
import subprocess
import sys
import zipfile
from collections import defaultdict

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Detectores que, si aparecen, son un secreto real.
DUROS = {
    'clave_google_api': re.compile(rb'AIza[0-9A-Za-z_\-]{35}'),
    'clave_privada': re.compile(rb'-----BEGIN [A-Z ]*PRIVATE KEY-----'),
    'cuenta_servicio': re.compile(rb'"private_key_id"\s*:|"type"\s*:\s*"service_account"'),
    'token_github': re.compile(rb'\b(?:gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{40,})'),
    'token_api': re.compile(rb'\bsk-(?:ant-|proj-)?[A-Za-z0-9_\-]{32,}'),
    'jwt_literal': re.compile(rb'\beyJ[A-Za-z0-9_\-]{10,}\.eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{16,}'),
    'firma_android': re.compile(rb'(?m)^\s*(?:storePassword|keyPassword)\s*=\s*\S+'),
    'contrasena_literal': re.compile(
        rb'(?i)(?:password|passwd|contrase\xc3\xb1a)\s*[:=]\s*[\'"][^\'"\s]{6,}[\'"]'),
    'refresh_token': re.compile(rb'\b1//0[A-Za-z0-9_\-]{40,}'),
}

# Detectores que piden revisión a mano: casi siempre son legítimos.
REVISION = {
    'correo': re.compile(rb'[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(?:\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}'),
    'uid_firebase': re.compile(
        rb'(?<![A-Za-z0-9_\-/+])(?=[A-Za-z0-9]{28}(?![A-Za-z0-9_\-/+=]))'
        rb'(?=[A-Za-z0-9]*[a-z])(?=[A-Za-z0-9]*[A-Z])(?=[A-Za-z0-9]*[0-9])[A-Za-z0-9]{28}'),
    'ruta_privado': re.compile(rb'(?i)baystream-privado'),
    'firebase_prod_json': re.compile(rb'(?i)firebase-prod[A-Za-z0-9_\-]*\.json'),
    'id_app_firebase': re.compile(rb'\b1:[0-9]{8,}:(?:android|web|ios):[0-9a-f]{8,}'),
}

# Archivos que el .gitignore protege: no deben estar versionados nunca.
PROTEGIDOS = re.compile(
    r'(?i)(?:^|/)(?:key\.properties(?!\.example)[^/]*|[^/]*\.jks|[^/]*\.keystore|'
    r'google-services\.json|GoogleService-Info\.plist|firebase_options\.dart|'
    r'firebase-prod[^/]*\.json|\.env(?:\.[^/]*)?)$')
NOMBRES_CORPUS = re.compile(r'(?i)(?:CORPUS_A\d\d|LISTADO_A08|CASO_A08|PRUEBA_NIVEL_\d\d)')

# Correos de ejemplo o de servicio, que no identifican a nadie.
DOMINIOS_NEUTROS = re.compile(
    r'(?i)(?:^|\.)(?:example\.(?:com|org|net)|test|invalid|localhost|local|'
    r'users\.noreply\.github\.com|anthropic\.com|openai\.com|google\.com|'
    r'googlegroups\.com|dartlang\.org|dart\.dev|flutter\.dev|apple\.com|'
    r'gradle\.org|android\.com|baystream\.(?:test|local))$')
DOMINIOS_PERSONALES = re.compile(
    r'(?i)^(?:gmail\.com|googlemail\.com|hotmail\.[a-z.]+|outlook\.[a-z.]+|'
    r'live\.[a-z.]+|yahoo\.[a-z.]+|icloud\.com|me\.com|proton(?:mail)?\.[a-z.]+)$')
# Lo que parece correo y es otra cosa (paquetes, versiones, @2x.png…).
NO_CORREO = re.compile(rb'(?i)\.(?:png|jpg|jpeg|svg|gif|webp|dart|js|ts|css|html?|md)$')

TEXTO_ZIP = re.compile(r'(?i)\.(?:xml|rels|txt|json|csv)$')
BINARIOS = re.compile(
    r'(?i)\.(?:png|jpg|jpeg|gif|webp|ico|bmp|ttf|otf|woff2?|mp4|mkv|webm|zip|7z|'
    r'gz|jar|so|dll|exe|msix|apk|aab|wasm|pdf|doc|ppt)$')


def git(*args, entrada=None):
    return subprocess.run(['git', '-C', RAIZ, *args], input=entrada,
                          capture_output=True, check=True).stdout


def contenido_revisable(ruta, datos):
    """Los bytes que se escanean: el XML de un Office o el archivo tal cual."""
    if datos[:2] == b'PK' and re.search(r'(?i)\.(?:docx|xlsx|pptx|dotx)$', ruta):
        try:
            with zipfile.ZipFile(io.BytesIO(datos)) as z:
                partes = [z.read(n) for n in z.namelist() if TEXTO_ZIP.search(n)]
            return b'\n'.join(partes), 'office'
        except zipfile.BadZipFile:
            return datos, 'zip_invalido'
    if BINARIOS.search(ruta):
        return None, 'binario'
    return datos, 'texto'


def cargar_corpus(carpeta):
    huellas, contenedores = {}, set()
    if not carpeta or not os.path.isdir(carpeta):
        return huellas, contenedores
    for nombre in sorted(os.listdir(carpeta)):
        ruta = os.path.join(carpeta, nombre)
        if not os.path.isfile(ruta):
            continue
        with open(ruta, 'rb') as f:
            datos = f.read()
        huellas[hashlib.sha256(datos).hexdigest()] = nombre
        if nombre.lower().endswith('.edi'):
            for m in re.finditer(rb"EQD\+CN\+([A-Z]{4}[0-9]{6,7})", datos):
                contenedores.add(m.group(1))
    return huellas, contenedores


def clasificar_correo(valor, autores):
    texto = valor.decode('utf8', 'replace')
    dominio = texto.rsplit('@', 1)[1].lower()
    if texto.lower() in autores:
        return 'autor_de_commits', dominio
    if DOMINIOS_NEUTROS.search(dominio):
        return 'neutro', dominio
    if DOMINIOS_PERSONALES.search(dominio):
        return 'personal', dominio
    return 'otro', dominio


def escanear(ruta, datos, ctx):
    """Devuelve {detector: [valores]} de un archivo."""
    hallado = defaultdict(list)
    if PROTEGIDOS.search(ruta):
        hallado['archivo_protegido'].append(ruta.encode())
    if NOMBRES_CORPUS.search(os.path.basename(ruta)):
        hallado['nombre_corpus'].append(os.path.basename(ruta).encode())
    huella = hashlib.sha256(datos).hexdigest()
    if huella in ctx['huellas']:
        hallado['archivo_del_corpus'].append(ctx['huellas'][huella].encode())
    texto, tipo = contenido_revisable(ruta, datos)
    ctx['tipos'][tipo] += 1
    if texto is None:
        return hallado
    for nombre, patron in DUROS.items():
        for m in patron.finditer(texto):
            hallado[nombre].append(m.group(0))
    for nombre, patron in REVISION.items():
        for m in patron.finditer(texto):
            valor = m.group(0)
            if nombre == 'correo' and NO_CORREO.search(valor):
                continue
            hallado[nombre].append(valor)
    if ctx['contenedores']:
        propios = {m.group(1) for m in re.finditer(rb'([A-Z]{4}[0-9]{6,7})', texto)}
        comunes = propios & ctx['contenedores']
        if len(comunes) >= 3:
            hallado['contenedores_del_corpus'].extend(sorted(comunes))
    return hallado


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--corpus')
    p.add_argument('--rama', default='sprint-3')
    p.add_argument('--salida', default=os.path.join(RAIZ, 'build', 't113'))
    p.add_argument('--privado', default=os.path.join(
        os.environ.get('TEMP', '.'), 't113', 'revision-privada.json'))
    a = p.parse_args()

    huellas, contenedores = cargar_corpus(a.corpus)
    autores = {e.strip().lower() for e in
               git('log', a.rama, '--format=%ae%n%ce').decode().splitlines() if e.strip()}
    ctx = {'huellas': huellas, 'contenedores': contenedores, 'tipos': defaultdict(int)}

    resultados = {}   # fuente -> detector -> {ruta: n}
    privado = defaultdict(lambda: defaultdict(set))   # detector -> valor -> rutas
    correos = defaultdict(lambda: defaultdict(set))   # fuente -> clase -> dominios

    def registrar(fuente, ruta, hallado):
        for detector, valores in hallado.items():
            if detector == 'correo':
                for v in valores:
                    clase, dominio = clasificar_correo(v, autores)
                    correos[fuente][clase].add(dominio)
                    det = f'correo_{clase}'
                    resultados[fuente].setdefault(det, {}).setdefault(ruta, 0)
                    resultados[fuente][det][ruta] += 1
                    privado[det][v.decode('utf8', 'replace')].add(f'{fuente}:{ruta}')
                continue
            resultados[fuente].setdefault(detector, {}).setdefault(ruta, 0)
            resultados[fuente][detector][ruta] += len(valores)
            for v in valores:
                privado[detector][v.decode('utf8', 'replace')].add(f'{fuente}:{ruta}')

    # Árbol y sin versionar, desde la copia de trabajo.
    totales = {}
    for fuente, args in (('arbol', ['ls-files', '-z']),
                         ('sin_versionar', ['ls-files', '-z', '--others', '--exclude-standard'])):
        resultados[fuente] = {}
        rutas = [r for r in git(*args).decode('utf8').split('\0') if r]
        totales[fuente] = len(rutas)
        for ruta in rutas:
            completa = os.path.join(RAIZ, ruta)
            if not os.path.isfile(completa):
                continue
            with open(completa, 'rb') as f:
                registrar(fuente, ruta, escanear(ruta, f.read(), ctx))

    # Historia: cada blob alcanzable desde la rama, una vez.
    resultados['historia'] = {}
    rutas_de = defaultdict(set)
    for linea in git('rev-list', '--objects', a.rama).decode('utf8').splitlines():
        partes = linea.split(' ', 1)
        if len(partes) == 2:
            rutas_de[partes[0]].add(partes[1])
    entrada = ''.join(f'{o}\n' for o in rutas_de).encode()
    tipos = git('cat-file', '--batch-check', entrada=entrada).decode().splitlines()
    blobs = [t.split()[0] for t in tipos if t.split()[1] == 'blob']
    totales['historia_blobs'] = len(blobs)
    totales['historia_commits'] = int(git('rev-list', '--count', a.rama).decode().strip())
    salida = git('cat-file', '--batch', entrada=''.join(f'{b}\n' for b in blobs).encode())
    pos = 0
    while pos < len(salida):
        fin = salida.index(b'\n', pos)
        sha, _, tam = salida[pos:fin].decode().split()
        datos = salida[fin + 1: fin + 1 + int(tam)]
        pos = fin + 1 + int(tam) + 1
        for ruta in sorted(rutas_de[sha]):
            registrar('historia', ruta, escanear(ruta, datos, ctx))
            break   # el contenido es el mismo: basta con una ruta por blob
        if len(rutas_de[sha]) > 1:
            for ruta in sorted(rutas_de[sha])[1:]:
                if PROTEGIDOS.search(ruta) or NOMBRES_CORPUS.search(os.path.basename(ruta)):
                    registrar('historia', ruta, escanear(ruta, datos, ctx))

    duros = sorted(set(DUROS) | {'archivo_protegido', 'archivo_del_corpus',
                                 'contenedores_del_corpus'})
    resumen = {
        'rama': a.rama,
        'cabeza': git('rev-parse', a.rama).decode().strip(),
        'corpus': {'archivos': len(huellas), 'contenedores': len(contenedores)},
        'totales': totales,
        'tipos_de_contenido': dict(ctx['tipos']),
        'por_fuente': {
            fuente: {det: {'archivos': len(rutas), 'apariciones': sum(rutas.values()),
                           'rutas': sorted(rutas)}
                     for det, rutas in sorted(dets.items())}
            for fuente, dets in resultados.items()},
        'dominios_de_correo': {f: {c: sorted(d) for c, d in cl.items() if c != 'personal'}
                               for f, cl in correos.items()},
        'secretos_duros': {f: sorted(d for d in dets if d in duros)
                           for f, dets in resultados.items()},
    }
    os.makedirs(a.salida, exist_ok=True)
    with open(os.path.join(a.salida, 'secretos.json'), 'w', encoding='utf8') as f:
        json.dump(resumen, f, ensure_ascii=False, indent=2)
    os.makedirs(os.path.dirname(a.privado), exist_ok=True)
    with open(a.privado, 'w', encoding='utf8') as f:
        json.dump({d: {v: sorted(r) for v, r in vs.items()} for d, vs in privado.items()},
                  f, ensure_ascii=False, indent=2)

    print(json.dumps({k: resumen[k] for k in ('rama', 'cabeza', 'corpus', 'totales',
                                               'tipos_de_contenido', 'secretos_duros')},
                     ensure_ascii=False, indent=2))
    for fuente, dets in resumen['por_fuente'].items():
        for det, info in dets.items():
            print(f'{fuente:14} {det:26} {info["archivos"]:4} archivos {info["apariciones"]:6} apariciones')
    sys.exit(1 if any(resumen['secretos_duros'].values()) else 0)


if __name__ == '__main__':
    main()
