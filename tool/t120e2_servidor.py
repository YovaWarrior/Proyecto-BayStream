"""T-120, entrega 2 · El servidor local del banco Web: el de T-147
(tool/t147_servidor.py) con la salida en build/t120/e2. Solo escucha en
127.0.0.1, y las rutas son las de T-147 (`/t147/…`), que son las que usa
tool/t147_plataforma_web.dart.

Sirve la compilación del banco (`--web`), entrega al conductor los archivos del
caso desde una carpeta de FUERA del repositorio (`--caso`, y `--caso2` para la
copia del plan que vive en %TEMP%) y guarda en `--salida` lo que el conductor
manda: una línea por paso en `pasos.jsonl` y las capturas en `capturas/`.

    python -X utf8 tool/t120e2_servidor.py --web <compilación Web>
        --caso %TEMP%\\t120-e2\\caso --salida build/t120/e2/web/<corrida>

Del caso solo se sirven `.edi` y `.xlsx`, por su nombre, sin subcarpetas. Nada
del caso se copia: ni a la salida ni al repositorio.
"""
import argparse
import re
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlparse

RAIZ = Path(__file__).resolve().parent.parent


def fuera_del_repositorio(ruta):
    carpeta = Path(ruta).resolve()
    if carpeta == RAIZ or RAIZ in carpeta.parents:
        sys.exit(f'{carpeta} está dentro del repositorio: el caso se lee de fuera.')
    if not carpeta.is_dir():
        sys.exit(f'No existe la carpeta {carpeta}.')
    return carpeta


def principal():
    p = argparse.ArgumentParser()
    p.add_argument('--web', required=True)
    p.add_argument('--caso', required=True)
    p.add_argument('--caso2')
    p.add_argument('--salida', required=True)
    p.add_argument('--puerto', type=int, default=5948)
    a = p.parse_args()

    web = Path(a.web).resolve()
    if not (web / 'index.html').is_file():
        sys.exit(f'{web} no es una compilación Web (falta index.html).')
    casos = [fuera_del_repositorio(a.caso)]
    if a.caso2:
        casos.append(fuera_del_repositorio(a.caso2))
    salida = Path(a.salida).resolve()
    if RAIZ / 'build' / 't120' / 'e2' not in [salida, *salida.parents]:
        sys.exit('--salida tiene que estar dentro de build/t120/e2.')
    (salida / 'capturas').mkdir(parents=True, exist_ok=True)

    class Manejador(SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=str(web), **kwargs)

        def log_message(self, formato, *args):
            with open(salida / 'servidor.log', 'a', encoding='utf-8') as registro:
                registro.write('%s %s\n' % (self.client_address[0], formato % args))

        def end_headers(self):
            self.send_header('Cache-Control', 'no-store')
            super().end_headers()

        def do_GET(self):
            ruta = urlparse(self.path).path
            if not ruta.startswith('/t147/'):
                return super().do_GET()
            nombre = unquote(ruta[len('/t147/caso/'):]) if ruta.startswith('/t147/caso/') else ''
            if not re.fullmatch(r'[A-Za-z0-9_.-]+\.(edi|xlsx)', nombre):
                return self.send_error(404)
            for carpeta in casos:
                archivo = carpeta / nombre
                if archivo.is_file():
                    datos = archivo.read_bytes()
                    self.send_response(200)
                    self.send_header('Content-Type', 'application/octet-stream')
                    self.send_header('Content-Length', str(len(datos)))
                    self.end_headers()
                    self.wfile.write(datos)
                    return None
            return self.send_error(404)

        def do_POST(self):
            url = urlparse(self.path)
            cuerpo = self.rfile.read(int(self.headers.get('Content-Length', '0')))
            if url.path == '/t147/registro':
                with open(salida / 'pasos.jsonl', 'ab') as pasos:
                    pasos.write(cuerpo.rstrip(b'\n') + b'\n')
            elif url.path == '/t147/captura':
                nombre = parse_qs(url.query).get('nombre', [''])[0]
                if not re.fullmatch(r'[A-Za-z0-9_.-]+\.png', nombre):
                    return self.send_error(400)
                (salida / 'capturas' / nombre).write_bytes(cuerpo)
            else:
                return self.send_error(404)
            self.send_response(204)
            self.end_headers()
            return None

    servidor = ThreadingHTTPServer(('127.0.0.1', a.puerto), Manejador)
    print(f'T-120 e2: banco en http://127.0.0.1:{a.puerto}/ · salida en {salida}', flush=True)
    try:
        servidor.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    principal()
