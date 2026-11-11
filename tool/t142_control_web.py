"""T-142 · El control de la Web 1.0.0 servida por el emulador de Hosting, para
probar las cabeceras de seguridad. Como tool/t139_control_web.py: un servidor
HTTP local que sostiene el Chrome de Playwright entre llamadas y recibe
órdenes en JSON. Lo nuevo es lo que registra:

  - cada `securitypolicyviolation` del documento (directiva, recurso, muestra,
    disposición «enforce» o «report»), por una función expuesta, así que no se
    pierde al recargar;
  - la consola, los errores de la página, cada petición (tipo, URL, si la
    sirvió el service worker) y las que fallan;
  - los eventos del dictado (SpeechRecognition y getUserMedia), envolviendo
    sus constructores antes de que cargue la app;
  - las descargas.

Nada sale de 127.0.0.1: Chrome arranca con `--host-resolver-rules` que
resuelven cualquier otro nombre a «no existe». Así se ve a qué orígenes
intenta llegar la app, sin tocar Firebase real. Nunca inicia sesión.

    python tool/t142_control_web.py servidor [--puerto 5943]
    python tool/t142_control_web.py '{"accion": "abrir", "perfil": "a"}'
    python tool/t142_control_web.py '{"accion": "informe"}'
    python tool/t142_control_web.py '{"accion": "tiempos", "n": 5, "etiqueta": "antes"}'
"""
import json
import os
import re
import statistics
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.request import Request, urlopen

RAIZ_REPO = Path(__file__).resolve().parent.parent
SALIDA = RAIZ_REPO / 'build' / 't142'
PERFILES = Path(os.environ['TEMP']).resolve() / 't142'
URL = 'http://127.0.0.1:5942/'
ARGS_RED = ['--host-resolver-rules=MAP * ~NOTFOUND , EXCLUDE 127.0.0.1 , EXCLUDE localhost']

INSTRUMENTO = r"""
(() => {
  if (window.__t142) return;
  window.__t142 = true;
  document.addEventListener('securitypolicyviolation', (e) => {
    try {
      window.t142Violacion({
        directiva: e.effectiveDirective, violada: e.violatedDirective, recurso: e.blockedURI,
        muestra: e.sample, disposicion: e.disposition, fuente: e.sourceFile, linea: e.lineNumber,
        pagina: location.href,
      });
    } catch (_) {}
  }, true);
  const voz = (evento, extra) => { try { window.t142Voz({ evento, ...(extra || {}) }); } catch (_) {} };
  for (const nombre of ['SpeechRecognition', 'webkitSpeechRecognition']) {
    const Original = window[nombre];
    if (!Original) continue;
    const Envuelto = function (...a) {
      const r = new Original(...a);
      voz('creado', { nombre });
      for (const ev of ['start', 'audiostart', 'error', 'end', 'result']) {
        r.addEventListener(ev, (x) => voz(ev, { error: x && x.error, mensaje: x && x.message }));
      }
      const iniciar = r.start.bind(r);
      r.start = () => { voz('start() llamado'); return iniciar(); };
      return r;
    };
    Envuelto.prototype = Original.prototype;
    window[nombre] = Envuelto;
  }
  if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
    const gum = navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);
    navigator.mediaDevices.getUserMedia = (c) => {
      voz('getUserMedia', { pide: JSON.stringify(c) });
      return gum(c).then((s) => { voz('getUserMedia concedido'); return s; },
                         (e) => { voz('getUserMedia rechazado', { error: e.name, mensaje: e.message }); throw e; });
    };
  }
})();
"""

HAY_PRIMER_CUADRO = """() => {
  const v = document.querySelector('flt-glass-pane');
  const s = v && v.shadowRoot;
  return !!(s && s.querySelector('flt-scene canvas, flt-scene-host canvas'));
}"""

SEMANTICA = """async () => {
  for (let i = 0; i < 8 && document.querySelectorAll('flt-semantics').length === 0; i++) {
    const m = document.querySelector('flt-semantics-placeholder');
    if (m) m.click(); else window.dispatchEvent(new Event('resize'));
    await new Promise((r) => setTimeout(r, 400));
  }
  return document.querySelectorAll('flt-semantics').length;
}"""

NODOS_JS = """(patron) => {
  const re = new RegExp(patron);
  const texto = (n) => n.getAttribute('aria-label') || n.textContent || '';
  const nodos = Array.from(document.querySelectorAll('flt-semantics')).filter((n) => re.test(texto(n)));
  const hoja = nodos.filter((n) => !nodos.some((o) => o !== n && n.contains(o)));
  return hoja.map((n) => { const r = n.getBoundingClientRect();
    return { etiqueta: texto(n).slice(0, 160), rol: n.getAttribute('role') || '',
             x: Math.round(r.x + r.width / 2), y: Math.round(r.y + r.height / 2), w: Math.round(r.width), h: Math.round(r.height) }; });
}"""
HAY_JS = """(patron) => { const re = new RegExp(patron);
  return Array.from(document.querySelectorAll('flt-semantics'))
    .some((n) => re.test(n.getAttribute('aria-label') || n.textContent || '')); }"""


class Control:
    def __init__(self, pw):
        self.pw = pw
        self.ctx = None
        self.page = None
        self.limpiar_registro()

    def limpiar_registro(self, c=None):
        self.violaciones, self.consola, self.peticiones, self.fallidas = [], [], [], []
        self.voz, self.descargas, self.errores, self.respuestas = [], [], [], []
        return True

    # ---- navegador ----
    def abrir(self, c):
        perfil = c.get('perfil', 'a')
        if c.get('fresco') and self.ctx is not None:
            self.cerrar()
        if self.ctx is None:
            carpeta = PERFILES / f'perfil-{perfil}'
            if c.get('fresco') and carpeta.exists():
                import shutil
                shutil.rmtree(carpeta)
            carpeta.mkdir(parents=True, exist_ok=True)
            self.ctx = self.pw.chromium.launch_persistent_context(
                str(carpeta), channel='chrome', headless=False, accept_downloads=True,
                viewport={'width': c.get('ancho', 1600), 'height': c.get('alto', 900)},
                locale='es-GT', args=ARGS_RED + ['--window-position=0,0'])
            self.ctx.expose_function('t142Violacion', lambda v: self.violaciones.append(v))
            self.ctx.expose_function('t142Voz', lambda v: self.voz.append({**v, 't': time.time()}))
            self.ctx.add_init_script(INSTRUMENTO)
            self.page = self.ctx.pages[0] if self.ctx.pages else self.ctx.new_page()
            p = self.page
            p.on('console', lambda m: self.consola.append({'tipo': m.type, 'texto': m.text[:600]}))
            p.on('pageerror', lambda e: self.errores.append(str(e)[:600]))
            p.on('request', lambda r: self.peticiones.append(
                {'url': r.url[:300], 'tipo': r.resource_type, 'metodo': r.method,
                 'sw': r.service_worker is not None}))
            p.on('requestfailed', lambda r: self.fallidas.append({'url': r.url[:300], 'fallo': r.failure}))
            p.on('response', lambda r: self.respuestas.append(
                {'url': r.url[:300], 'estado': r.status, 'desdeSW': r.from_service_worker}))
            p.on('download', self._descarga)
        return self.ir(c)

    def _descarga(self, d):
        destino = SALIDA / 'descargas' / d.suggested_filename
        destino.parent.mkdir(parents=True, exist_ok=True)
        try:
            d.save_as(str(destino))
            tam = destino.stat().st_size
        except Exception as e:  # noqa: BLE001
            tam = f'error: {e}'
        self.descargas.append({'archivo': d.suggested_filename, 'url': d.url[:80], 'bytes': tam})

    def ir(self, c):
        t0 = time.time()
        r = self.page.goto(c.get('url', URL), wait_until='commit')
        cab = r.all_headers() if r else {}
        self.page.wait_for_function(HAY_PRIMER_CUADRO, polling='raf', timeout=60000)
        n = self.page.evaluate(SEMANTICA)
        return {'s': round(time.time() - t0, 2), 'semanticos': n, 'desdeSW': r.from_service_worker if r else None,
                'cabeceras': {k: v for k, v in cab.items() if k not in ('date', 'etag', 'last-modified')}}

    def privacidad(self, c):
        """Abre /privacidad.html en otra pestaña del mismo navegador: la
        página estática también recibe la CSP (lleva un <style> en línea)."""
        p = self.ctx.new_page()
        p.on('console', lambda m: self.consola.append({'tipo': m.type, 'texto': m.text[:600]}))
        r = p.goto(URL + 'privacidad.html', wait_until='load')
        time.sleep(1)
        info = {'titulo': p.title(), 'estado': r.status,
                'fondo': p.evaluate("() => getComputedStyle(document.body).backgroundColor"),
                'anchoMain': p.evaluate("() => getComputedStyle(document.querySelector('main')).maxWidth")}
        ruta = SALIDA / 'capturas' / f'privacidad-{c.get("etiqueta", "x")}.png'
        ruta.parent.mkdir(parents=True, exist_ok=True)
        p.screenshot(path=str(ruta))
        p.close()
        return info

    def recargar(self, c):
        return self.ir({'url': self.page.url})

    def cerrar(self, c=None):
        if self.ctx:
            self.ctx.close()
        self.ctx = self.page = None
        return True

    def sin_conexion(self, c):
        self.ctx.set_offline(bool(c.get('sin', True)))
        return {'sinConexion': bool(c.get('sin', True))}

    def permiso(self, c):
        if c.get('conceder'):
            self.ctx.grant_permissions(['microphone'], origin=URL.rstrip('/'))
        else:
            self.ctx.clear_permissions()
        return self.page.evaluate("""async () => ({
          permiso: (await navigator.permissions.query({name: 'microphone'})).state,
          politicaPermite: document.featurePolicy ? document.featurePolicy.allowsFeature('microphone') : null })""")

    # ---- la app ----
    def nodos(self, c):
        return self.page.evaluate(NODOS_JS, c.get('patron', '.'))

    def esperar(self, c):
        self.page.wait_for_function(HAY_JS, arg=c['patron'], timeout=c.get('segundos', 30) * 1000)
        return True

    def pulsar(self, c):
        if c.get('esperar', True):
            self.page.wait_for_function(HAY_JS, arg=c['patron'], timeout=c.get('segundos', 20) * 1000)
        nodos = self.page.evaluate(NODOS_JS, c['patron'])
        if not nodos:
            raise RuntimeError(f'No hay nodo para {c["patron"]}')
        n = nodos[c.get('indice', -1)]
        self.page.mouse.click(n['x'] + c.get('dx', 0), n['y'] + c.get('dy', 0))
        time.sleep(c.get('pausa', 0.8))
        return n

    def clic(self, c):
        self.page.mouse.click(c['x'], c['y'])
        time.sleep(c.get('pausa', 0.8))
        return True

    def rueda(self, c):
        v = self.page.viewport_size
        self.page.mouse.move(c.get('x', v['width'] / 2), c.get('y', v['height'] / 2))
        self.page.mouse.wheel(0, c.get('dy', 600))
        time.sleep(c.get('pausa', 0.8))
        return True

    def teclear(self, c):
        self.page.keyboard.type(c['texto'], delay=40)
        time.sleep(c.get('pausa', 0.5))
        return True

    def tecla(self, c):
        for t in c['teclas'].split():
            self.page.keyboard.press(t)
            time.sleep(0.2)
        time.sleep(c.get('pausa', 0.5))
        return True

    def archivo(self, c):
        """Pulsa el nodo que abre el selector y le entrega el archivo."""
        with self.page.expect_file_chooser(timeout=20000) as fc:
            self.pulsar({'patron': c['patron'], 'pausa': 0.2})
        fc.value.set_files(c['ruta'])
        time.sleep(c.get('pausa', 2))
        return {'archivo': Path(c['ruta']).name}

    def captura(self, c):
        ruta = SALIDA / 'capturas' / f'{c["nombre"]}.png'
        ruta.parent.mkdir(parents=True, exist_ok=True)
        self.page.screenshot(path=str(ruta))
        return str(ruta)

    def js(self, c):
        return self.page.evaluate(c['codigo'])

    def sonda_csp(self, c):
        """¿Rige una CSP en el documento? Un fetch a un nombre .invalid: con
        connect-src lo bloquea la política (violación), sin ella falla el DNS."""
        antes = len(self.violaciones)
        self.page.evaluate("() => fetch('https://t142-sonda.invalid/').catch(() => null)")
        self.page.wait_for_timeout(1500)  # entrega el evento de la violación
        return {'rigeCSP': any(v['recurso'].startswith('https://t142-sonda.invalid')
                               for v in self.violaciones[antes:])}

    def informe(self, c):
        if self.page is not None:
            # La API síncrona de Playwright solo entrega eventos (descargas,
            # consola, violaciones) durante una llamada: esta los recoge.
            self.page.wait_for_timeout(c.get('esperaMs', 300))
        externas = sorted({re.sub(r'(https?://[^/]+).*', r'\1', p['url']) for p in self.peticiones
                           if not p['url'].startswith(('http://127.0.0.1', 'blob:', 'data:'))})
        tipos = {}
        for p in self.peticiones:
            clave = (p['tipo'], re.sub(r'^(https?://[^/]+/)([^/?]*/?)?.*', r'\1\2', p['url'])[:90])
            tipos[clave] = tipos.get(clave, 0) + 1
        datos = {
            'violaciones': self.violaciones, 'origenesExternos': externas,
            'peticionesPorTipo': [{'tipo': k[0], 'ruta': k[1], 'n': v} for k, v in sorted(tipos.items())],
            'fallidas': self.fallidas, 'consolaErrores': [m for m in self.consola if m['tipo'] in ('error', 'warning')],
            'erroresPagina': self.errores, 'voz': self.voz, 'descargas': self.descargas,
        }
        if c.get('guardar'):
            destino = SALIDA / f'{c["guardar"]}.json'
            destino.write_text(json.dumps({**datos, 'consola': self.consola, 'peticiones': self.peticiones},
                                          ensure_ascii=False, indent=1), encoding='utf-8')
            datos['guardado'] = str(destino)
        if c.get('resumen'):
            datos.pop('peticionesPorTipo')
        return datos

    # ---- tiempos ----
    def tiempos(self, c):
        """Carga en frío n veces, cada una con un perfil nuevo y sin caché:
        de la navegación al primer cuadro del motor (performance.now())."""
        resultados = []
        for i in range(c.get('n', 5)):
            nav = self.pw.chromium.launch(channel='chrome', headless=False, args=ARGS_RED + ['--window-position=0,0'])
            ctx = nav.new_context(viewport={'width': 1600, 'height': 900}, locale='es-GT')
            page = ctx.new_page()
            page.goto(URL, wait_until='commit')
            page.wait_for_function(HAY_PRIMER_CUADRO, polling='raf', timeout=60000)
            ms = page.evaluate('() => performance.now()')
            nav_ms = page.evaluate("""() => { const n = performance.getEntriesByType('navigation')[0];
                return n ? {dcl: n.domContentLoadedEventEnd, carga: n.loadEventEnd} : null; }""")
            resultados.append({'primerCuadroMs': round(ms), **({k: round(v) for k, v in nav_ms.items()} if nav_ms else {})})
            nav.close()
        meds = [r['primerCuadroMs'] for r in resultados]
        datos = {'etiqueta': c.get('etiqueta'), 'corridas': resultados, 'medianaMs': statistics.median(meds)}
        destino = SALIDA / f'tiempos-{c.get("etiqueta", "x")}.json'
        destino.write_text(json.dumps(datos, ensure_ascii=False, indent=1), encoding='utf-8')
        return datos

    def ejecutar(self, c):
        accion = c['accion']
        if accion == 'salir':
            self.cerrar()
            return {'saliendo': True}
        return getattr(self, accion)(c)


def servidor(puerto):
    from playwright.sync_api import sync_playwright
    with sync_playwright() as pw:
        control = Control(pw)
        detener = threading.Event()

        class Manejador(BaseHTTPRequestHandler):
            def log_message(self, *a):
                pass

            def do_POST(self):
                largo = int(self.headers.get('Content-Length', 0))
                comando = json.loads(self.rfile.read(largo).decode('utf-8'))
                try:
                    resultado = {'ok': True, 'resultado': control.ejecutar(comando)}
                except Exception as e:  # noqa: BLE001 — se devuelve al cliente
                    resultado = {'ok': False, 'error': f'{type(e).__name__}: {e}'}
                cuerpo = json.dumps(resultado, ensure_ascii=False, default=str).encode('utf-8')
                self.send_response(200)
                self.send_header('Content-Type', 'application/json; charset=utf-8')
                self.send_header('Content-Length', str(len(cuerpo)))
                self.end_headers()
                self.wfile.write(cuerpo)
                if comando.get('accion') == 'salir':
                    detener.set()

        httpd = HTTPServer(('127.0.0.1', puerto), Manejador)
        httpd.timeout = 1
        print(f'Control T-142 en 127.0.0.1:{puerto}', flush=True)
        while not detener.is_set():
            httpd.handle_request()
        httpd.server_close()


def cliente(comando, puerto):
    datos = json.dumps(comando).encode('utf-8')
    with urlopen(Request(f'http://127.0.0.1:{puerto}/', data=datos, method='POST',
                         headers={'Content-Type': 'application/json'}), timeout=600) as r:
        return json.loads(r.read().decode('utf-8'))


if __name__ == '__main__':
    puerto = 5943
    args = list(sys.argv[1:])
    if '--puerto' in args:
        i = args.index('--puerto')
        puerto = int(args[i + 1])
        del args[i:i + 2]
    if args and args[0] == 'servidor':
        servidor(puerto)
    else:
        salida = cliente(json.loads(args[0]), puerto)
        print(json.dumps(salida, ensure_ascii=False, indent=1))
        sys.exit(0 if salida.get('ok') else 1)
