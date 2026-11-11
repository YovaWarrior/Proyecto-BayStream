"""T-142 · Las configuraciones del emulador de Hosting para probar las cabeceras.

Cada variante es una carpeta build/t142/emu-<nombre>/ con un firebase.json que
sirve la copia de la Web 1.0.0 publicada (build/t142/web, copiada byte a byte
de C:\\Proyectos\\proyecto-baystream\\build\\web) en 127.0.0.1:5942, con el
proyecto de demostración `demo-t142`: el emulador no habla con Firebase real.

    python tool/t142_configs.py            # escribe todas las variantes
    firebase emulators:start --only hosting --project demo-t142 \
        --config build/t142/emu-despues/firebase.json

Variantes:
  antes        el firebase.json de HEAD, copiado antes de editarlo (solo Cache-Control);
  inventario   antes + una CSP de solo informe `default-src 'none'`: el
               navegador avisa de todo lo que la app carga, sin bloquear nada;
  despues      el firebase.json de la carpeta, con las cabeceras de T-142;
  sin-<x>      despues sin una concesión de la CSP, para ver qué se rompe;
  mic-apagado  despues con `microphone=()`: el control negativo de la voz.
"""
import copy
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / 'build' / 't142'
PUERTO = 5942


def firebase_head():
    """La copia de firebase.json tomada antes de editarlo (igual a HEAD y a
    master `eddc388`): build/t142/firebase.antes.json."""
    return json.loads((SALIDA / 'firebase.antes.json').read_text(encoding='utf-8'))


def firebase_actual():
    return json.loads((RAIZ / 'firebase.json').read_text(encoding='utf-8'))


def para_emulador(cfg):
    cfg = copy.deepcopy(cfg)
    cfg['hosting']['public'] = '../web'
    # En Windows, el emulador no aplica ninguna cabecera con `"source": "**"`:
    # superstatic pasa el patrón por glob-slasher, que usa el separador del
    # sistema y lo vuelve `\**`, y minimatch ya no casa ninguna ruta (ni el
    # Cache-Control de hoy). `"regex": ".*"` es la misma regla y esquiva el
    # fallo. Solo en las copias del emulador: firebase.json sigue con `source`,
    # que en Hosting de verdad funciona (el Cache-Control llega en vivo, T-141).
    for bloque in cfg['hosting'].get('headers', []):
        if bloque.get('source') == '**':
            del bloque['source']
            bloque['regex'] = '.*'
    cfg['emulators'] = {'hosting': {'host': '127.0.0.1', 'port': PUERTO},
                        'ui': {'enabled': False}}
    return cfg


def cabeceras(cfg):
    return cfg['hosting']['headers'][0]['headers']


def poner(cfg, clave, valor):
    lista = cabeceras(cfg)
    for h in lista:
        if h['key'] == clave:
            h['value'] = valor
            return
    lista.append({'key': clave, 'value': valor})


def csp(cfg):
    for h in cabeceras(cfg):
        if h['key'] == 'Content-Security-Policy':
            return h['value']
    return None


def quitar_de_csp(valor, directiva, fuente):
    partes = []
    for d in valor.split(';'):
        d = d.strip()
        if d.split(' ')[0] == directiva:
            fuentes = [f for f in d.split(' ')[1:] if f != fuente]
            d = ' '.join([directiva] + (fuentes or ["'none'"]))
        partes.append(d)
    return '; '.join(partes)


def variantes():
    antes = para_emulador(firebase_head())
    v = {'antes': antes}
    inv = copy.deepcopy(antes)
    poner(inv, 'Content-Security-Policy-Report-Only', "default-src 'none'")
    v['inventario'] = inv
    despues = para_emulador(firebase_actual())
    v['despues'] = despues
    politica = csp(despues)
    if politica:
        for directiva in politica.split(';'):
            partes = directiva.strip().split(' ')
            for fuente in partes[1:]:
                # Los orígenes de Google solo se usan con sesión: sin ella no
                # hay nada que probar aquí (los prueba Carlos en el canal).
                if fuente in ("'self'", "'none'") or fuente.startswith('https://'):
                    continue
                nombre = 'sin-' + partes[0] + '-' + re.sub(r'[^a-z0-9]+', '', fuente.lower())[:24]
                cfg = copy.deepcopy(despues)
                poner(cfg, 'Content-Security-Policy', quitar_de_csp(politica, partes[0], fuente))
                v[nombre] = cfg
        mic = copy.deepcopy(despues)
        pp = [h['value'] for h in cabeceras(mic) if h['key'] == 'Permissions-Policy'][0]
        poner(mic, 'Permissions-Policy', pp.replace('microphone=(self)', 'microphone=()'))
        v['mic-apagado'] = mic
    return v


def main():
    for nombre, cfg in variantes().items():
        carpeta = SALIDA / f'emu-{nombre}'
        carpeta.mkdir(parents=True, exist_ok=True)
        (carpeta / 'firebase.json').write_text(json.dumps(cfg, indent=2, ensure_ascii=False) + '\n',
                                               encoding='utf-8')
        print(nombre)


if __name__ == '__main__':
    sys.exit(main())
