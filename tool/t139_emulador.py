"""T-139 · El emulador de Firebase (Auth y Firestore) para las capturas del
manual de la 1.0.0, con las dos cuentas de prueba sembradas.

Como el instrumental de la aceptación de T-128 y el banco de T-130: solo un
proyecto `demo-*` que no existe en la nube, Auth en 9399 y Firestore en 8383,
las reglas de T-130 (`docs/T130-firestore.rules.propuesta`) y dos cuentas,
oficina y muelle, en `authorized/{uid}`. Correos y claves son sintéticos y
viven solo en %TEMP%\\t139\\emu\\cuentas.json, fuera del repositorio; nunca se
imprimen. La CLI no inicia sesión ni toca baystream-app.

    python -I tool/t139_emulador.py iniciar     # levanta el emulador y siembra
    python -I tool/t139_emulador.py cuentas     # vuelve a sembrar las cuentas
    python -I tool/t139_emulador.py detener     # cierra el emulador por su PID
"""
import json
import os
import secrets
import shutil
import socket
import subprocess
import sys
import time
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen

PROJECT = 'demo-t139'
AUTH_PORT = 9399
FIRESTORE_PORT = 8383
HUB_PORT = 4498
LOGGING_PORT = 4598
AUTH = f'http://127.0.0.1:{AUTH_PORT}'
FIRESTORE = f'http://127.0.0.1:{FIRESTORE_PORT}'
TEMP = Path(os.environ['TEMP']).resolve()
EMU = TEMP / 't139' / 'emu'
REPO = Path(__file__).resolve().parents[1]
CUENTAS = EMU / 'cuentas.json'
PROCESO = EMU / 'proceso.json'


def request(method, url, body=None, owner=False):
    parsed = urlparse(url)
    if parsed.hostname != '127.0.0.1' or parsed.port not in (AUTH_PORT, FIRESTORE_PORT):
        raise RuntimeError('ALTO: petición fuera del emulador propio')
    if PROJECT not in url and not url.startswith(AUTH + '/identitytoolkit.'):
        raise RuntimeError('ALTO: proyecto distinto del demo autorizado')
    headers = {'Content-Type': 'application/json'}
    if owner:
        headers['Authorization'] = 'Bearer owner'
    data = None if body is None else json.dumps(body).encode()
    with urlopen(Request(url, method=method, headers=headers, data=data), timeout=30) as response:
        text = response.read()
        return json.loads(text) if text else None


def puerto_libre(puerto):
    with socket.socket() as s:
        return s.connect_ex(('127.0.0.1', puerto)) != 0


def escribir_config():
    EMU.mkdir(parents=True, exist_ok=True)
    reglas = EMU / 'firestore.rules'
    if not reglas.exists():
        shutil.copy2(REPO / 'docs' / 'T130-firestore.rules.propuesta', reglas)
    config = {
        'firestore': {'rules': 'firestore.rules'},
        'emulators': {
            'auth': {'host': '127.0.0.1', 'port': AUTH_PORT},
            'firestore': {'host': '127.0.0.1', 'port': FIRESTORE_PORT},
            'hub': {'host': '127.0.0.1', 'port': HUB_PORT},
            'logging': {'host': '127.0.0.1', 'port': LOGGING_PORT},
            'ui': {'enabled': False},
            'singleProjectMode': True,
        },
    }
    (EMU / 'firebase.json').write_text(json.dumps(config, indent=2), encoding='utf-8')


def iniciar():
    for puerto in (AUTH_PORT, FIRESTORE_PORT, HUB_PORT, LOGGING_PORT):
        if not puerto_libre(puerto):
            raise SystemExit(f'Puerto {puerto} ocupado: no se levanta otro emulador.')
    escribir_config()
    env = os.environ.copy()
    env['JAVA_TOOL_OPTIONS'] = '-Duser.language=en -Duser.country=US'
    env['FIREBASE_CLI_DISABLE_UPDATE_CHECK'] = 'true'
    env['CI'] = 'true'
    jbr = r'C:\Program Files\Android\Android Studio\jbr\bin'
    if shutil.which('java') is None and Path(jbr, 'java.exe').exists():
        env['PATH'] = jbr + os.pathsep + env['PATH']
    salida = (EMU / 'emulador-salida.log').open('ab')
    error = (EMU / 'emulador-error.log').open('ab')
    proceso = subprocess.Popen(
        [shutil.which('firebase.cmd') or shutil.which('firebase'), 'emulators:start',
         '--only', 'auth,firestore', '--project', PROJECT, '--config', str(EMU / 'firebase.json')],
        cwd=EMU, env=env, stdout=salida, stderr=error,
        creationflags=subprocess.CREATE_NO_WINDOW)
    PROCESO.write_text(json.dumps({'pid': proceso.pid, 'proyecto': PROJECT,
                                   'puertos': [AUTH_PORT, FIRESTORE_PORT, HUB_PORT, LOGGING_PORT]},
                                  indent=2), encoding='utf-8')
    for _ in range(90):
        time.sleep(2)
        if proceso.poll() is not None:
            raise SystemExit('El emulador terminó antes de escuchar (ver emulador-error.log).')
        if not puerto_libre(AUTH_PORT) and not puerto_libre(FIRESTORE_PORT):
            break
    else:
        raise SystemExit('El emulador no escuchó a tiempo.')
    time.sleep(3)
    print(f'Emulador {PROJECT} escuchando: Auth {AUTH_PORT}, Firestore {FIRESTORE_PORT}; PID {proceso.pid}')
    cuentas()


def cuentas():
    """Dos cuentas sintéticas, oficina y muelle. Los correos y las claves solo
    van a cuentas.json en TEMP; aquí no se imprimen."""
    nombres = {'office': 'Oficina de prueba', 'dock': 'Muelle de prueba'}
    resultado = {}
    for role, nombre in nombres.items():
        email = f't139-{role}-{secrets.token_hex(3)}@example.test'
        password = secrets.token_urlsafe(16)
        r = request('POST', AUTH + '/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key',
                    {'email': email, 'password': password, 'returnSecureToken': True})
        uid = r['localId']
        request('PATCH', f'{FIRESTORE}/v1/projects/{PROJECT}/databases/(default)/documents/authorized/{uid}',
                {'fields': {'active': {'booleanValue': True},
                            'role': {'stringValue': role},
                            'name': {'stringValue': nombre}}}, owner=True)
        resultado[role] = {'email': email, 'password': password, 'name': nombre}
    CUENTAS.write_text(json.dumps(resultado, indent=2), encoding='utf-8')
    print('Cuentas sembradas:', ', '.join(f'{r} ({nombres[r]})' for r in resultado))


def detener():
    if not PROCESO.exists():
        raise SystemExit('No hay proceso anotado.')
    pid = json.loads(PROCESO.read_text(encoding='utf-8'))['pid']
    subprocess.run(['taskkill', '/PID', str(pid), '/T', '/F'], check=False,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(2)
    print('Emulador detenido:', 'puertos libres' if puerto_libre(FIRESTORE_PORT) and puerto_libre(AUTH_PORT)
          else 'ALGÚN PUERTO SIGUE OCUPADO')


if __name__ == '__main__':
    accion = sys.argv[1] if len(sys.argv) > 1 else 'iniciar'
    {'iniciar': iniciar, 'cuentas': cuentas, 'detener': detener}[accion]()
