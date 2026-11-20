"""T-147 · Una corrida del banco Web: levanta tool/t147_servidor.py, abre el
banco en un Chrome de Playwright con su propio perfil en %TEMP% y espera a que
el conductor (tool/t147_conductor.dart) escriba «fin» o «error».

    python -X utf8 tool/t147_web.py --web build/t147/e1/antes/web
        --caso "<carpeta del corpus>" --caso2 %TEMP%\\t147\\caso
        --salida build/t147/e1/antes/web-medir-1 --perfil antes
        --ancho 360 --alto 800 [--perfil-nuevo] [--cpu 4] [--perfil-cpu]
        --consulta "escenario=medir&plan=…&celda=0180084"

- Todo lo que no sea http://127.0.0.1:<puerto>/ se corta, y queda anotado en
  `red.json`: el banco no habla con nadie más.
- `--cpu N` frena la CPU N veces (Emulation.setCPUThrottlingRate de Chrome).
- `--perfil-cpu` guarda el perfil de CPU de la corrida (`cpu.cpuprofile`) y
  su resumen (`cpu-resumen.json`): sirve con una compilación `--profile`,
  que conserva los nombres de las funciones.
- No toca el Chrome de Carlos, la nube ni ningún almacén real.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path
from urllib.parse import urlparse

from playwright.sync_api import sync_playwright

TEMP = Path(os.environ['TEMP']).resolve()
AQUI = Path(__file__).resolve().parent


def resumen_del_perfil(perfil, patrones):
    """Tiempo propio por función y tiempo total (con lo que llama) de las
    funciones cuyo nombre contiene alguno de los patrones."""
    nodos = {n['id']: n for n in perfil['nodes']}
    propio = {i: 0 for i in nodos}
    for nodo, delta in zip(perfil['samples'], perfil['timeDeltas']):
        propio[nodo] += delta
    hijos = {i: n.get('children', []) for i, n in nodos.items()}
    total = {}

    def sumar(i):
        pila = [(i, False)]
        while pila:
            actual, visto = pila.pop()
            if visto:
                total[actual] = propio[actual] + sum(total[h] for h in hijos[actual])
            else:
                pila.append((actual, True))
                pila.extend((h, False) for h in hijos[actual])

    raiz = perfil['nodes'][0]['id']
    sumar(raiz)
    nombre = lambda i: nodos[i]['callFrame']['functionName'] or '(anónima)'
    por_funcion = {}
    for i, micros in propio.items():
        por_funcion[nombre(i)] = por_funcion.get(nombre(i), 0) + micros
    duracion = sum(perfil['timeDeltas'])

    # El total de una función: la suma de sus apariciones más altas en el
    # árbol (una llamada dentro de otra de la misma función no se cuenta dos veces).
    def total_de(patron):
        suma = 0
        pila = [raiz]
        while pila:
            actual = pila.pop()
            if patron in nombre(actual):
                suma += total[actual]
            else:
                pila.extend(hijos[actual])
        return suma

    ms = lambda micros: round(micros / 1000, 1)
    return {
        'duracion_ms': ms(duracion),
        'muestras': len(perfil['samples']),
        'tiempo_propio_las_30_mayores_ms': [
            [f, ms(t)] for f, t in sorted(por_funcion.items(), key=lambda x: -x[1])[:30]],
        'tiempo_total_por_patron_ms': {p: ms(total_de(p)) for p in patrones},
    }


def principal():
    p = argparse.ArgumentParser()
    p.add_argument('--web', required=True)
    p.add_argument('--caso', required=True)
    p.add_argument('--caso2')
    p.add_argument('--salida', required=True)
    p.add_argument('--perfil', required=True, help='nombre del perfil de Chrome en %%TEMP%%\\t147\\perfiles')
    p.add_argument('--perfil-nuevo', action='store_true')
    p.add_argument('--puerto', type=int, default=5947)
    p.add_argument('--ancho', type=int, default=360)
    p.add_argument('--alto', type=int, default=800)
    p.add_argument('--cpu', type=float, default=1)
    p.add_argument('--perfil-cpu', action='store_true')
    p.add_argument('--patrones', default='occupancy,candidateSlots,slots,available,_before,search,_LoadingPickerState,contains')
    p.add_argument('--consulta', required=True)
    p.add_argument('--tope', type=int, default=600, help='segundos')
    a = p.parse_args()

    salida = Path(a.salida).resolve()
    salida.mkdir(parents=True, exist_ok=True)
    pasos = salida / 'pasos.jsonl'
    if pasos.exists():
        sys.exit(f'{pasos} ya existe: cada corrida va en su carpeta.')
    perfil = TEMP / 't147' / 'perfiles' / a.perfil
    if a.perfil_nuevo and perfil.exists():
        shutil.rmtree(perfil)
    perfil.mkdir(parents=True, exist_ok=True)

    orden = [sys.executable, '-X', 'utf8', str(AQUI / 't147_servidor.py'),
             '--web', a.web, '--caso', a.caso, '--salida', str(salida),
             '--puerto', str(a.puerto)]
    if a.caso2:
        orden += ['--caso2', a.caso2]
    servidor = subprocess.Popen(orden)
    origen = f'http://127.0.0.1:{a.puerto}'
    red = {'cortadas': [], 'servidas': 0}
    final = None
    try:
        time.sleep(1.5)
        if servidor.poll() is not None:
            sys.exit('El servidor del banco no arrancó.')
        with sync_playwright() as pw:
            escala = 2 if a.ancho < 600 else 1
            ctx = pw.chromium.launch_persistent_context(
                str(perfil), channel='chrome', headless=False,
                viewport={'width': a.ancho, 'height': a.alto},
                device_scale_factor=escala, locale='es-GT',
                args=[f'--window-size={a.ancho + 16},{min(a.alto, 1000) + 90}',
                      '--window-position=0,0'])

            def filtrar(ruta):
                url = ruta.request.url
                if url.startswith(origen + '/'):
                    red['servidas'] += 1
                    ruta.continue_()
                else:
                    red['cortadas'].append(urlparse(url).netloc or url[:60])
                    ruta.abort()

            ctx.route('**/*', filtrar)
            page = ctx.pages[0] if ctx.pages else ctx.new_page()
            consola = []
            page.on('console', lambda m: consola.append(m.text[:300]))
            page.on('pageerror', lambda e: consola.append(f'ERROR {str(e)[:300]}'))
            cdp = ctx.new_cdp_session(page)
            if a.cpu != 1:
                cdp.send('Emulation.setCPUThrottlingRate', {'rate': a.cpu})
            if a.perfil_cpu:
                cdp.send('Profiler.enable')
                cdp.send('Profiler.setSamplingInterval', {'interval': 500})
                cdp.send('Profiler.start')
            page.goto(f'{origen}/?{a.consulta}', wait_until='commit')
            limite = time.time() + a.tope
            while time.time() < limite and final is None:
                # No `time.sleep`: Playwright solo atiende sus eventos (el
                # filtro de la red entre ellos) dentro de una llamada suya.
                page.wait_for_timeout(500)
                if pasos.exists():
                    for linea in pasos.read_text(encoding='utf-8').splitlines():
                        paso = json.loads(linea)
                        if paso['paso'] in ('fin', 'error'):
                            final = paso
            if a.perfil_cpu:
                crudo = cdp.send('Profiler.stop')['profile']
                (salida / 'cpu.cpuprofile').write_text(json.dumps(crudo), encoding='utf-8')
                (salida / 'cpu-resumen.json').write_text(json.dumps(
                    resumen_del_perfil(crudo, a.patrones.split(',')),
                    ensure_ascii=False, indent=2), encoding='utf-8')
            (salida / 'consola.log').write_text('\n'.join(consola), encoding='utf-8')
            (salida / 'navegador.json').write_text(json.dumps({
                'version': ctx.browser.version if ctx.browser else page.evaluate('navigator.userAgent'),
                'viewport': page.viewport_size, 'escala': escala, 'cpu': a.cpu,
                'consulta': a.consulta, 'perfil': str(perfil),
            }, ensure_ascii=False, indent=2), encoding='utf-8')
            ctx.close()
    finally:
        servidor.terminate()
        (salida / 'red.json').write_text(json.dumps(red, ensure_ascii=False, indent=2), encoding='utf-8')
    if final is None:
        sys.exit('El conductor no terminó: mira consola.log y pasos.jsonl.')
    print(f"T-147: {final['paso']} · {salida}")
    if final['paso'] == 'error':
        print(final.get('detalle'))
        sys.exit(1)


if __name__ == '__main__':
    principal()
