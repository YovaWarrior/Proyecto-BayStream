"""T-129 (O-128-2) · Extrae de la evidencia de Codex (la aceptacion de la 0.4.1,
C:\\Proyectos\\baystream-qa-r4\\build\\t128-aceptacion) lo que el diagnostico del cierre
usa, sin copiar identificadores de cuentas, y coteja el SDK de Firestore empaquetado
en web/vendor. Solo lee la evidencia de Codex; escribe en build/t129/.

    python -I -X utf8 tool/t129_evidencia.py
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
CODEX = Path(r'C:\Proyectos\baystream-qa-r4\build\t128-aceptacion')
SALIDA = RAIZ / 'build' / 't129'
SDK = RAIZ / 'web' / 'vendor' / 'firebase' / '12.17.0' / 'firebase-firestore-pipelines.js'

# Claves que nunca se copian: identifican cuentas del emulador.
PRIVADAS = {'createdBy', 'closedBy', 'uid', 'email', 'password', 'token', 'idToken', 'author'}

# El primer cierre (138-147) y el segundo (173-177) en web-comandos-e2e-final.json.
INDICES = list(range(138, 148)) + list(range(173, 178))


def limpiar(valor):
    if isinstance(valor, dict):
        return {k: limpiar(v) for k, v in valor.items() if k not in PRIVADAS}
    if isinstance(valor, list):
        return [limpiar(v) for v in valor]
    return valor


def campo(fields, nombre):
    """Un campo del documento en el formato REST de Firestore ({'stringValue': ...})."""
    valor = fields.get(nombre)
    if not isinstance(valor, dict):
        return None
    return next(iter(valor.values()), None)


def revision_listado(fields):
    try:
        return (fields['sources']['mapValue']['fields']['export_list']['mapValue']
                ['fields']['revision']['integerValue'])
    except (KeyError, TypeError):
        return None


def registro():
    return json.loads((CODEX / 'web-comandos-e2e-final.json').read_text(encoding='utf-8'))


def comandos(entradas):
    salida = []
    for i in INDICES:
        entrada = entradas[i]
        comando, resultado = entrada['command'], entrada['result']
        fila = {
            'indice': i,
            'accion': comando.get('action'),
            'cliente': comando.get('client'),
            'patron': comando.get('pattern'),
            'segundos': round(entrada['seconds'], 2),
            'ok': resultado.get('ok'),
        }
        if not resultado.get('ok'):
            fila['error'] = str(resultado.get('error'))[:160]
        elif comando.get('action') == 'nodes':
            fila['rotulos'] = [n['label'][:240] for n in resultado['result']
                               if n.get('role') != 'group'][:3]
        elif comando.get('action') == 'remote':
            fila['documento'] = [
                {
                    'status': campo(d['fields'], 'status'),
                    'closedAt': campo(d['fields'], 'closedAt'),
                    'revisionListado': revision_listado(d['fields']),
                    'updateTime': d.get('updateTime'),
                }
                for d in resultado['result']['documents']
            ]
        salida.append(fila)
    return salida


def chip_antes_del_cierre(entradas):
    """El chip «Nube y cuenta · …» de la oficina antes del primer cierre: si dice
    «Al día», el motor de T-127 estaba escuchando el documento de la operacion."""
    vistos = []
    for i, entrada in enumerate(entradas[:139]):
        comando, resultado = entrada['command'], entrada['result']
        if (comando.get('client') != 'oficina-f' or comando.get('action') != 'nodes'
                or not resultado.get('ok')):
            continue
        for nodo in resultado['result']:
            m = re.search(r'Nube y cuenta · [^\n]{0,40}', nodo['label'])
            if m:
                vistos.append({'indice': i, 'chip': m.group(0)[:60]})
                break
    return vistos


def sonda_local():
    """La sonda de solo lectura del banco de Codex: la bitacora local de la oficina,
    cada vez que cambio. Sin cuentas: solo estado."""
    instantaneas = json.loads(
        (CODEX / 'e2e' / 'oficina-f' / 'snapshots.json').read_text(encoding='utf-8'))
    filas = []
    for i, instantanea in enumerate(instantaneas):
        for operacion in instantanea.get('operations', []):
            filas.append({
                'instantanea': i,
                'published': operacion.get('published'),
                'closed': operacion.get('closed'),
                'fuentes': [[f.get('kind'), f.get('revision'), f.get('rows')]
                            for f in operacion.get('sources', [])],
                'movimientos': len(operacion.get('records', [])),
            })
    return filas


def cotejo_sdk():
    texto = SDK.read_text(encoding='utf-8', errors='replace')
    buscados = {
        'view.ts shouldWaitForSyncedDocument (la instantanea del acuse se calla)':
            r'hasLocalMutations&&[A-Za-z_$][\w$]*\.hasCommittedMutations&&![A-Za-z_$][\w$]*\.hasLocalMutations',
        'firestore_client.ts lectura del servidor (opciones de la escucha de una vez)':
            r'includeMetadataChanges:!0,waitForSyncWhenOnline:!0',
        'firestore_client.ts lectura del servidor (rechazo cuando la vista es de cache)':
            r'Failed to get document from server',
    }
    return {
        'archivo': SDK.relative_to(RAIZ).as_posix(),
        'bytes': SDK.stat().st_size,
        'hallazgos': {nombre: re.findall(patron, texto)[:2] for nombre, patron in buscados.items()},
    }


def main() -> int:
    if not CODEX.exists():
        print(f'No esta la evidencia de Codex en {CODEX}', file=sys.stderr)
        return 1
    SALIDA.mkdir(parents=True, exist_ok=True)
    entradas = registro()
    piezas = {
        'codex-paso13-comandos.json': comandos(entradas),
        'codex-chip-antes-del-cierre.json': chip_antes_del_cierre(entradas),
        'codex-sonda-local.json': sonda_local(),
        'sdk-12.17.0-cotejo.json': cotejo_sdk(),
    }
    for nombre, contenido in piezas.items():
        (SALIDA / nombre).write_text(
            json.dumps(limpiar(contenido), ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
        cuenta = f'{len(contenido)} entradas' if isinstance(contenido, list) else 'escrito'
        print(f'{nombre}: {cuenta}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
