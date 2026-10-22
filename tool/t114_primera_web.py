"""T-114 · Fase 3, entrega 1: la primera visualización en la Web, en tres pasos.

Instrumento de RNF-002 (≤ 3 pasos y ≤ 30 s hasta la rejilla) para el banco r4
de la Web (build/web de la copia, servido en 127.0.0.1). Abre el Chrome
instalado con Playwright, en un perfil temporal vacío y en una ventana visible
en el escritorio: una página oculta no pinta ni corre requestAnimationFrame,
así que el navegador integrado de la consola, que queda oculto cuando nadie
mira la sesión, no sirve para medir. No toca el Chrome de Carlos ni cuentas.

Antes de cada documento inyecta tool/t114_primera_web.js (add_init_script), de
modo que el instrumento observa desde la navegación: el primer cuadro del
motor (first-contentful-paint del navegador o, si falta, el lienzo observado),
la activación de la semántica (acción del instrumento, no del producto) y,
desde el clic en «Seleccionar archivo» hasta la primera bahía en la semántica,
el tiempo del producto. El selector del sistema lo intercepta el navegador
(el archivo ya descargado se asigna al <input type=file>), como T-98.

«sin perfil» (la condición que rige): la app arranca sin perfiles ni viajes y
el plano abre en previo. Con --cache caliente (lo normal desde la segunda
visita) una navegación de calentamiento, que no cuenta, deja la caché del
navegador caliente, y el almacén se borra (IndexedDB y localStorage) después
de cada repetición; con --cache fria cada repetición es un contexto nuevo del
navegador, la primera visita, sin caché ni almacén. «con perfil» (informativa):
confirma antes el perfil propuesto como lo haría la oficina (Confirmar →
Parámetros del buque → No lo tengo → Confirmar y ver el plano) y mide con el
perfil y la escala confirmados en el almacén; por 7.2 de DESIGN.md el plano
abre publicado, sin previo.

Cada corrida escribe en una subcarpeta de <salida> que nombra su condición:
sin-caliente, sin-fria o con-perfil. Ninguna parte de la ruta puede ser un
dispositivo reservado de Windows (con, prn, aux, nul, com1 a com9, lpt1 a
lpt9): una carpeta llamada «con» existe pero Git y el Explorador no la ven
(10.15, O1), y el instrumento se niega a escribir ahí.

python tool/t114_primera_web.py <salida en TEMP> --url http://127.0.0.1:5899/ ^
    --archivo T99_SINTETICO_977.edi --perfil sin --repeticiones 5
python tool/t114_primera_web.py <salida en TEMP> --perfil sin --cache fria --repeticiones 5
python tool/t114_primera_web.py <salida en TEMP> --perfil con --repeticiones 1
"""
import argparse
import json
import statistics
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

from playwright.sync_api import sync_playwright

from t98_inventario import output_directory

# Los nombres de dispositivo que Windows reserva: una carpeta así existe en el
# disco, pero Git, el Explorador y las herramientas de Windows no la ven.
RESERVADOS_DE_WINDOWS = frozenset(
    ['con', 'prn', 'aux', 'nul']
    + [f'com{n}' for n in range(1, 10)]
    + [f'lpt{n}' for n in range(1, 10)])


def sin_nombres_reservados(ruta: Path) -> Path:
    """La misma ruta, o un error si alguna de sus partes es un nombre reservado
    de Windows (con o sin extensión)."""
    for parte in ruta.parts:
        if parte.split('.')[0].lower() in RESERVADOS_DE_WINDOWS:
            raise ValueError(f'«{parte}» es un dispositivo reservado de Windows: '
                             'Git no lo ve. Usa otro nombre (por ejemplo, con-perfil).')
    return ruta


def carpeta_de_corrida(perfil: str, cache: str) -> str:
    """El nombre de la subcarpeta de una corrida: su condición, nunca «con»."""
    return 'con-perfil' if perfil == 'con' else f'sin-{cache}'

INSTRUMENTO_JS = Path(__file__).with_name('t114_primera_web.js')
UMBRAL_PASOS = 3
UMBRAL_S = 30.0

# Pulsa el nodo de semántica más profundo cuyo rótulo cumple el patrón.
PULSAR_JS = """(patron) => {
  const re = new RegExp(patron);
  const texto = (n) => n.getAttribute('aria-label') || n.textContent || '';
  const nodos = Array.from(document.querySelectorAll('flt-semantics')).filter((n) => re.test(texto(n)));
  const hoja = nodos.filter((n) => !nodos.some((otro) => otro !== n && n.contains(otro)));
  if (!hoja.length) return false;
  hoja[hoja.length - 1].click();
  return true;
}"""
HAY_JS = """(patron) => {
  const re = new RegExp(patron);
  return Array.from(document.querySelectorAll('flt-semantics'))
    .some((n) => re.test(n.getAttribute('aria-label') || n.textContent || ''));
}"""
# Publicado: hay bahías y ya no está la banda del previo.
PUBLICADO_JS = ("() => { const hay = " + HAY_JS + "; return hay('BAH[IÍ]A|Bah[ií]a') && "
                "!hay('Plano sin confirmar|confirma la escala|confirma el buque'); }")


def hay(page, patron):
    return page.evaluate(HAY_JS, patron)


def esperar(page, patron, segundos=60):
    page.wait_for_function(HAY_JS, arg=patron, timeout=segundos * 1000)


def pulsar(page, patron, segundos=30):
    esperar(page, patron, segundos)
    if not page.evaluate(PULSAR_JS, patron):
        raise RuntimeError(f'No se pudo pulsar {patron}')


def nuevo_contexto(navegador, esquema, viewport=None):
    contexto = navegador.new_context(viewport=viewport, color_scheme=esquema, locale='es-GT')
    contexto.add_init_script(path=str(INSTRUMENTO_JS))
    return contexto, contexto.new_page()


def abrir(page, url):
    """Navega y espera el primer cuadro y la semántica (instrumento)."""
    page.goto(url, wait_until='commit')
    return page.evaluate('() => window.t114Esperar()')


def medir(page, ruta_archivo):
    page.evaluate('(ruta) => window.t114Preparar(ruta)', ruta_archivo)
    return page.evaluate('() => window.t114Medir()')


def limpiar(page):
    return page.evaluate('() => window.t114Limpiar()')


def desplazar_hasta(page, patron, intentos=15):
    """La semántica de Flutter solo trae lo visible: rueda del ratón hasta verlo."""
    vista = page.viewport_size or {'width': 1280, 'height': 720}
    for _ in range(intentos):
        if hay(page, patron):
            return
        page.mouse.move(vista['width'] / 2, vista['height'] / 2)
        page.mouse.wheel(0, 500)
        time.sleep(0.6)
    raise RuntimeError(f'No apareció al desplazar: {patron}')


def confirmar_perfil(page):
    """Como la oficina: Confirmar, sin límite de apilamiento, confirmar y ver."""
    pulsar(page, '^Confirmar$')
    esperar(page, 'Parámetros del buque|^Cancelar$')
    time.sleep(0.8)
    desplazar_hasta(page, '^No lo tengo')
    pulsar(page, '^No lo tengo')
    time.sleep(0.8)
    desplazar_hasta(page, '^Confirmar y ver')
    pulsar(page, '^Confirmar y ver')
    page.wait_for_function(PUBLICADO_JS, timeout=60000)
    time.sleep(1)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5899/')
    p.add_argument('--archivo', default='T99_SINTETICO_977.edi', help='bajo /t114/ del servidor')
    p.add_argument('--perfil', choices=('sin', 'con'), default='sin')
    p.add_argument('--cache', choices=('caliente', 'fria'), default='caliente')
    p.add_argument('--repeticiones', type=int, default=5)
    p.add_argument('--ancho', type=int, default=1280)
    p.add_argument('--alto', type=int, default=800)
    p.add_argument('--tema', choices=('claro', 'oscuro'), default='oscuro')
    args = p.parse_args()
    if not args.url.startswith('http://127.0.0.1:'):
        raise ValueError('Solo el banco servido en 127.0.0.1.')
    if args.perfil == 'con' and args.cache == 'fria':
        raise ValueError('Con perfil, la caché es caliente: el perfil vive en el almacén del contexto.')
    out = sin_nombres_reservados(
        output_directory(args.salida) / carpeta_de_corrida(args.perfil, args.cache))
    out.mkdir(exist_ok=True)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    ruta = f'/t114/{args.archivo}'
    esquema = 'dark' if args.tema == 'oscuro' else 'light'
    cache = ('caliente (calentamiento previo; almacén borrado por repetición)' if args.cache == 'caliente'
             else 'fría (contexto nuevo por repetición: primera visita, sin caché ni almacén)')
    registros = []
    with sync_playwright() as pw:
        navegador = pw.chromium.launch(channel='chrome', headless=False,
                                       args=[f'--window-size={args.ancho},{args.alto}', '--window-position=40,40'])
        contexto, page = nuevo_contexto(navegador, esquema)
        try:
            if args.cache == 'caliente':
                # Calentamiento: caché del navegador caliente y almacén vacío.
                abrir(page, args.url)
                limpiar(page)
            if args.perfil == 'con':
                abrir(page, args.url)
                previo = medir(page, ruta)
                if not previo['marcas'][-1].get('previo'):
                    raise RuntimeError('La preparación con perfil esperaba un previo.')
                confirmar_perfil(page)
                page.screenshot(path=str(out / 'con00-publicado.png'))
            for i in range(1, args.repeticiones + 1):
                nombre = f'{args.perfil}{i:02d}'
                if args.cache == 'fria' and i > 1:
                    contexto.close()
                    contexto, page = nuevo_contexto(navegador, esquema)
                inicio_utc = datetime.now(timezone.utc).isoformat()
                espera = abrir(page, args.url)
                if i == 1:
                    page.screenshot(path=str(out / f'{nombre}-inicio.png'))
                r = medir(page, ruta)
                if i == 1:
                    page.screenshot(path=str(out / f'{nombre}-rejilla.png'))
                fin = r['marcas'][-1]
                registro = {
                    'instrumento': 'tool/t114_primera_web.py + tool/t114_primera_web.js',
                    'perfil': args.perfil, 'repeticion': i, 'url': args.url, 'archivo': ruta,
                    'navegador': f'Chrome {navegador.version} (Playwright, perfil temporal)',
                    'ventana': {'ancho': args.ancho, 'alto': args.alto, 'vista': page.viewport_size},
                    'tema': args.tema, 'cache': cache,
                    'inicioUtc': inicio_utc, 'finUtc': datetime.now(timezone.utc).isoformat(),
                    'pasosDelProducto': r['pasosDelProducto'],
                    'primerCuadroDesdeNavegacionS': r['primerCuadroDesdeNavegacionS'],
                    'origenDelPrimerCuadro': r['origenDelPrimerCuadro'],
                    'semanticaS': espera, 'tiempoDesdeElClicS': r['tiempoDesdeElClicS'],
                    'tiempoHastaRejillaS': r['tiempoHastaRejillaS'],
                    'incertidumbreS': r['incertidumbreS'],
                    'previo': fin.get('previo'), 'parametrosAbiertos': fin.get('parametrosAbiertos'),
                    'cumplePasos': r['pasosDelProducto'] <= UMBRAL_PASOS,
                    'cumpleTiempo': r['tiempoHastaRejillaS'] is not None and r['tiempoHastaRejillaS'] <= UMBRAL_S,
                    'marcas': r['marcas'],
                }
                (out / f'{nombre}-registro.json').write_text(json.dumps(registro, ensure_ascii=False, indent=2), encoding='utf-8')
                registros.append(registro)
                print(nombre, 'pasos', registro['pasosDelProducto'], 'primer cuadro', registro['primerCuadroDesdeNavegacionS'],
                      'clic→rejilla', registro['tiempoDesdeElClicS'], 'total', registro['tiempoHastaRejillaS'],
                      'previo', registro['previo'], flush=True)
                if args.perfil == 'sin' and args.cache == 'caliente':
                    limpiar(page)
        finally:
            navegador.close()
    tiempos = [r['tiempoHastaRejillaS'] for r in registros if r['tiempoHastaRejillaS'] is not None]
    resumen = {
        'instrumento': 'tool/t114_primera_web.py', 'perfil': args.perfil, 'cache': cache, 'archivo': ruta,
        'tema': args.tema, 'navegador': registros[0]['navegador'] if registros else None,
        'repeticiones': len(registros), 'pasosDelProducto': UMBRAL_PASOS if registros else None,
        'tiemposHastaRejillaS': tiempos,
        'minS': min(tiempos) if tiempos else None, 'maxS': max(tiempos) if tiempos else None,
        'mediaS': round(statistics.fmean(tiempos), 3) if tiempos else None,
        'primerCuadroS': [r['primerCuadroDesdeNavegacionS'] for r in registros],
        'clicARejillaS': [r['tiempoDesdeElClicS'] for r in registros],
        'previos': [r['previo'] for r in registros],
        'umbral': {'pasos': UMBRAL_PASOS, 'segundos': UMBRAL_S},
        'cumplePasos': all(r['cumplePasos'] for r in registros) if registros else None,
        'cumpleTiempo': all(r['cumpleTiempo'] for r in registros) if registros else None,
    }
    (out / 'resumen.json').write_text(json.dumps(resumen, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps({k: v for k, v in resumen.items() if k != 'instrumento'}, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    sys.exit(main())
