"""T-143 · Ayudantes para conducir el banco Web por `tool/t143_control_web.py`.

    python -I -X utf8 tool/t143_banco.py nodos oficina [patrón]
    python -I -X utf8 tool/t143_banco.py '<orden JSON>' ['<orden JSON>' ...]

Cada orden va al control (127.0.0.1:5944) en el orden dado y se detiene en la
primera que falle. `nodos` imprime las hojas de la semántica, una por línea.
"""
import json
import sys
from urllib.request import Request, urlopen

PUERTO = 5944


def c(**orden):
    datos = json.dumps(orden).encode('utf-8')
    with urlopen(Request(f'http://127.0.0.1:{PUERTO}/', data=datos, method='POST',
                         headers={'Content-Type': 'application/json'}), timeout=180) as r:
        salida = json.loads(r.read().decode('utf-8'))
    if not salida.get('ok'):
        raise RuntimeError(f'{orden.get("accion")}: {salida.get("error")}')
    return salida['resultado']


def nodos(cliente, patron='.'):
    for n in c(accion='nodos', cliente=cliente, patron=patron):
        print(f"{n['rol']:9} {n['x']:5} {n['y']:5} {n['w']:5} {n['h']:4} | {n['etiqueta'][:110]}")


if __name__ == '__main__':
    args = sys.argv[1:]
    if args and args[0] == 'nodos':
        nodos(args[1], args[2] if len(args) > 2 else '.')
    else:
        for a in args:
            r = c(**json.loads(a))
            print(json.dumps(r, ensure_ascii=False)[:400])
