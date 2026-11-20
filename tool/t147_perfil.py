"""T-147 · Lee un perfil de CPU de Chrome (`cpu.cpuprofile`, de tool/t147_web.py
con `--perfil-cpu`) y dice en qué se va el tiempo de una función: su tiempo
total, el propio y el de cada función que llama directamente.

    python -X utf8 tool/t147_perfil.py build/t147/e1/antes/web-perfil-cpu/cpu.cpuprofile
        candidateSlots slots$ get$occupancy [--salida RUTA.json]

Cada nombre es el principio del nombre de la función en el JavaScript sin
minificar (compilación `--profile -O 1`).
"""
import json
import sys
from pathlib import Path


def principal():
    argumentos = sys.argv[1:]
    salida = None
    if '--salida' in argumentos:
        i = argumentos.index('--salida')
        salida = Path(argumentos[i + 1])
        del argumentos[i:i + 2]
    perfil = json.loads(Path(argumentos[0]).read_text(encoding='utf-8'))
    nodos = {n['id']: n for n in perfil['nodes']}
    propio = {i: 0 for i in nodos}
    for nodo, delta in zip(perfil['samples'], perfil['timeDeltas']):
        propio[nodo] += delta
    hijos = {i: n.get('children', []) for i, n in nodos.items()}
    nombre = lambda i: nodos[i]['callFrame']['functionName'] or '(anónima)'
    total = {}
    pila = [(perfil['nodes'][0]['id'], False)]
    while pila:
        actual, visto = pila.pop()
        if visto:
            total[actual] = propio[actual] + sum(total[h] for h in hijos[actual])
        else:
            pila.append((actual, True))
            pila.extend((h, False) for h in hijos[actual])
    ms = lambda micros: round(micros / 1000, 1)
    informe = {}
    for prefijo in argumentos[1:]:
        # Las apariciones más altas: una llamada dentro de otra no se repite.
        altas = []
        pila = [perfil['nodes'][0]['id']]
        while pila:
            actual = pila.pop()
            if nombre(actual).startswith(prefijo):
                altas.append(actual)
            else:
                pila.extend(hijos[actual])
        llamadas = {}
        for nodo in altas:
            for hijo in hijos[nodo]:
                llamadas[nombre(hijo)] = llamadas.get(nombre(hijo), 0) + total[hijo]
        informe[prefijo] = {
            'funciones': sorted({nombre(n) for n in altas}),
            'total_ms': ms(sum(total[n] for n in altas)),
            'propio_ms': ms(sum(propio[n] for n in altas)),
            'lo_que_llama_ms': [[f, ms(t)] for f, t in
                                sorted(llamadas.items(), key=lambda x: -x[1])[:14]],
        }
    texto = json.dumps(informe, ensure_ascii=False, indent=2)
    print(texto)
    if salida:
        salida.write_text(texto + '\n', encoding='utf-8')


if __name__ == '__main__':
    principal()
