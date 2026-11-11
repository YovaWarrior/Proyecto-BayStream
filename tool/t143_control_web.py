"""T-143 · El control de la Web del banco para las capturas del antes y el
después y el cierre visto por el muelle. Es `tool/t139_control_web.py` con
las rutas de T-143 (como el `control_web.py` de la aceptación de T-128): un servidor HTTP
local que sostiene el Chrome de Playwright entre llamadas, con un perfil
persistente por cliente (la oficina a 1920 × 1080 y el muelle a 360 × 800, los
dos con escala 2), y recibe órdenes en JSON. Las capturas van a
%TEMP%\\t143\\capturas. Solo abre el banco servido en 127.0.0.1 y nunca toca el
Chrome de Carlos, la nube real ni el almacén real.

    python tool/t143_control_web.py servidor [--puerto 5944]
    python tool/t143_control_web.py '{"accion": "abrir", "cliente": "oficina"}'
    python tool/t143_control_web.py '{"accion": "nodos", "cliente": "oficina", "patron": "Bahía"}'
    python tool/t143_control_web.py '{"accion": "pulsar", "cliente": "oficina", "patron": "^Confirmar$"}'
    python tool/t143_control_web.py '{"accion": "captura", "cliente": "oficina", "nombre": "01-inicio"}'
    python tool/t143_control_web.py '{"accion": "salir"}'

La semántica de Flutter (flt-semantics) es lo que se lee y se pulsa, con los
mismos ayudantes de tool/t114_primera_web.py y .js (el selector del sistema lo
intercepta el navegador: el archivo preparado entra al <input type=file>).
"""
import json
import os
import re
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.request import Request, urlopen

TEMP = Path(os.environ['TEMP']).resolve()
RAIZ = TEMP / 't143'
CAPTURAS = RAIZ / 'capturas'
INSTRUMENTO = Path(__file__).with_name('t114_primera_web.js')
URL_BANCO = 'http://127.0.0.1:5943/'

CLIENTES = {
    # nombre: (ancho, alto, escala, esquema, carpeta del perfil)
    'oficina': (1920, 1080, 2, 'light', 'perfil-oficina'),
    'muelle': (360, 800, 2, 'light', 'perfil-muelle'),
    'oscuro': (1920, 1080, 2, 'dark', 'perfil-oscuro'),
    'muelle2': (360, 800, 2, 'light', 'perfil-muelle2'),
}

NODOS_JS = """(patron) => {
  const re = new RegExp(patron);
  const texto = (n) => n.getAttribute('aria-label') || n.textContent || '';
  const nodos = Array.from(document.querySelectorAll('flt-semantics')).filter((n) => re.test(texto(n)));
  const hoja = nodos.filter((n) => !nodos.some((otro) => otro !== n && n.contains(otro)));
  return hoja.map((n) => {
    const r = n.getBoundingClientRect();
    return { etiqueta: texto(n).slice(0, 160), rol: n.getAttribute('role') || '',
             x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) };
  });
}"""
PULSAR_JS = """([patron, indice]) => {
  const re = new RegExp(patron);
  const texto = (n) => n.getAttribute('aria-label') || n.textContent || '';
  const nodos = Array.from(document.querySelectorAll('flt-semantics')).filter((n) => re.test(texto(n)));
  const hoja = nodos.filter((n) => !nodos.some((otro) => otro !== n && n.contains(otro)));
  if (!hoja.length) return null;
  const n = hoja[indice < 0 ? hoja.length + indice : indice];
  if (!n) return null;
  const r = n.getBoundingClientRect();
  return { x: r.x + r.width / 2, y: r.y + r.height / 2, etiqueta: texto(n).slice(0, 120) };
}"""
HAY_JS = """(patron) => {
  const re = new RegExp(patron);
  return Array.from(document.querySelectorAll('flt-semantics'))
    .some((n) => re.test(n.getAttribute('aria-label') || n.textContent || ''));
}"""
TODO_JS = """() => Array.from(document.querySelectorAll('flt-semantics'))
  .map((n) => (n.getAttribute('aria-label') || '').trim()).filter((t) => t.length > 0)"""


class Control:
    def __init__(self, pw):
        self.pw = pw
        self.navegadores = {}
        self.paginas = {}

    def pagina(self, nombre):
        if nombre not in self.paginas:
            raise RuntimeError(f'Cliente «{nombre}» no abierto.')
        return self.paginas[nombre]

    def abrir(self, c):
        nombre = c['cliente']
        ancho, alto, escala, esquema, perfil = CLIENTES[nombre]
        esquema = c.get('esquema', esquema)
        url = c.get('url', URL_BANCO)
        if not url.startswith('http://127.0.0.1:'):
            raise RuntimeError('Solo el banco servido en 127.0.0.1.')
        if nombre not in self.navegadores:
            carpeta = RAIZ / perfil
            carpeta.mkdir(parents=True, exist_ok=True)
            ctx = self.pw.chromium.launch_persistent_context(
                str(carpeta), channel='chrome', headless=False,
                viewport={'width': ancho, 'height': alto}, device_scale_factor=escala,
                color_scheme=esquema, locale='es-GT',
                args=[f'--window-size={min(ancho, 1920) + 16},{min(alto, 1080) + 90}',
                      '--window-position=0,0'])
            ctx.add_init_script(path=str(INSTRUMENTO))
            self.navegadores[nombre] = ctx
            page = ctx.pages[0] if ctx.pages else ctx.new_page()
            self.paginas[nombre] = page
        page = self.paginas[nombre]
        page.emulate_media(color_scheme=esquema)
        page.goto(url, wait_until='commit')
        r = page.evaluate('() => window.t114Esperar()')
        self.sin_aviso_del_emulador(page)
        return {'abierto': nombre, 'espera': r, 'viewport': page.viewport_size}

    @staticmethod
    def sin_aviso_del_emulador(page):
        """El SDK de Auth pinta abajo «Running in emulator mode…», fuera de la
        app: se oculta para que no entre en las capturas."""
        page.evaluate("""() => {
          if (document.getElementById('t143-sin-aviso')) return;
          const s = document.createElement('style');
          s.id = 't143-sin-aviso';
          s.textContent = '.firebase-emulator-warning{display:none !important}';
          document.head.appendChild(s);
        }""")

    def recargar(self, c):
        page = self.pagina(c['cliente'])
        page.reload(wait_until='commit')
        r = page.evaluate('() => window.t114Esperar()')
        self.sin_aviso_del_emulador(page)
        return r

    def tema(self, c):
        page = self.pagina(c['cliente'])
        page.emulate_media(color_scheme=c['esquema'])
        return {'esquema': c['esquema']}

    def nodos(self, c):
        page = self.pagina(c['cliente'])
        return page.evaluate(NODOS_JS, c.get('patron', '.'))

    def etiquetas(self, c):
        return self.pagina(c['cliente']).evaluate(TODO_JS)

    def hay(self, c):
        return self.pagina(c['cliente']).evaluate(HAY_JS, c['patron'])

    def esperar(self, c):
        page = self.pagina(c['cliente'])
        page.wait_for_function(HAY_JS, arg=c['patron'], timeout=c.get('segundos', 30) * 1000)
        return True

    def pulsar(self, c):
        page = self.pagina(c['cliente'])
        if c.get('esperar', True):
            page.wait_for_function(HAY_JS, arg=c['patron'], timeout=c.get('segundos', 20) * 1000)
        punto = page.evaluate(PULSAR_JS, [c['patron'], c.get('indice', -1)])
        if punto is None:
            raise RuntimeError(f'No hay nodo para {c["patron"]}')
        # Un clic real del ratón en el centro del nodo: así reaccionan también
        # los controles que ignoran el click sintético de la semántica.
        page.mouse.click(punto['x'] + c.get('dx', 0), punto['y'] + c.get('dy', 0))
        time.sleep(c.get('pausa', 0.8))
        return punto

    def clic(self, c):
        page = self.pagina(c['cliente'])
        page.mouse.click(c['x'], c['y'], click_count=c.get('veces', 1))
        time.sleep(c.get('pausa', 0.8))
        return True

    def mover(self, c):
        page = self.pagina(c['cliente'])
        page.mouse.move(c['x'], c['y'])
        time.sleep(c.get('pausa', 0.6))
        return True

    def rueda(self, c):
        page = self.pagina(c['cliente'])
        page.mouse.move(c.get('x', page.viewport_size['width'] / 2), c.get('y', page.viewport_size['height'] / 2))
        modificador = c.get('modificador')
        if modificador:
            page.keyboard.down(modificador)
        page.mouse.wheel(c.get('dx', 0), c.get('dy', 300))
        if modificador:
            time.sleep(0.2)
            page.keyboard.up(modificador)
        time.sleep(c.get('pausa', 0.8))
        return True

    def arrastrar(self, c):
        page = self.pagina(c['cliente'])
        page.mouse.move(c['x0'], c['y0'])
        page.mouse.down()
        pasos = c.get('pasos', 12)
        for i in range(1, pasos + 1):
            page.mouse.move(c['x0'] + (c['x1'] - c['x0']) * i / pasos, c['y0'] + (c['y1'] - c['y0']) * i / pasos)
            time.sleep(0.03)
        page.mouse.up()
        time.sleep(c.get('pausa', 0.8))
        return True

    def tecla(self, c):
        page = self.pagina(c['cliente'])
        for tecla in c['teclas'].split():
            page.keyboard.press(tecla)
            time.sleep(0.2)
        time.sleep(c.get('pausa', 0.5))
        return True

    def teclear(self, c):
        page = self.pagina(c['cliente'])
        page.keyboard.type(c['texto'], delay=40)
        time.sleep(c.get('pausa', 0.5))
        return True

    def escribir(self, c):
        """Rellena un campo por su rótulo accesible (textbox)."""
        page = self.pagina(c['cliente'])
        campo = page.get_by_role('textbox', name=re.compile(c['rotulo']))
        campo.first.click()
        campo.first.fill(c['valor'])
        time.sleep(c.get('pausa', 0.5))
        return True

    def sesion(self, c):
        """Inicia sesión con la cuenta sembrada del rol pedido; las credenciales
        solo viajan del archivo de TEMP al formulario."""
        page = self.pagina(c['cliente'])
        cuentas = json.loads((RAIZ / 'emu' / 'cuentas.json').read_text(encoding='utf-8'))
        cuenta = cuentas[c['rol']]
        page.get_by_role('textbox', name=re.compile('^Correo')).first.fill(cuenta['email'])
        page.get_by_role('textbox', name=re.compile('^Contraseña')).first.fill(cuenta['password'])
        if c.get('enviar', True):
            punto = page.evaluate(PULSAR_JS, ['^Iniciar sesión$', -1])
            page.mouse.click(punto['x'], punto['y'])
            time.sleep(c.get('pausa', 3))
        return {'rol': c['rol'], 'nombre': cuenta['name']}

    def archivo(self, c):
        """Prepara el archivo que entrará al próximo selector del sistema."""
        page = self.pagina(c['cliente'])
        return page.evaluate('(ruta) => window.t114Preparar(ruta)', '/t143/' + c['archivo'])

    def captura(self, c):
        page = self.pagina(c['cliente'])
        CAPTURAS.mkdir(parents=True, exist_ok=True)
        ruta = CAPTURAS / f'{c["nombre"]}.png'
        if c.get('quieto', True):
            # El puntero fuera de los controles, para que ninguna descripción
            # emergente entre en la captura.
            v = page.viewport_size
            if v['width'] > 600:
                page.mouse.move(300, v['height'] - 1)  # el pie de la columna
            else:
                page.mouse.move(v['width'] - 1, 1)  # la esquina, fuera de todo botón
        time.sleep(c.get('pausa', 0.6))
        clip = c.get('recorte')
        if clip:
            page.screenshot(path=str(ruta), clip={'x': clip[0], 'y': clip[1], 'width': clip[2], 'height': clip[3]})
        else:
            page.screenshot(path=str(ruta))
        return {'captura': str(ruta), 'bytes': ruta.stat().st_size}

    def js(self, c):
        return self.pagina(c['cliente']).evaluate(c['codigo'])

    def limpiar(self, c):
        """Borra el almacén del navegador de ese cliente (IndexedDB y localStorage)."""
        page = self.pagina(c['cliente'])
        return page.evaluate('() => window.t114Limpiar()')

    def sin_conexion(self, c):
        """Corta o devuelve la red del navegador de ese cliente."""
        self.navegadores[c['cliente']].set_offline(bool(c.get('sin', True)))
        return {'sinConexion': bool(c.get('sin', True))}

    def cerrar(self, c):
        nombre = c['cliente']
        if nombre in self.navegadores:
            self.navegadores.pop(nombre).close()
            self.paginas.pop(nombre, None)
        return {'cerrado': nombre}

    def ejecutar(self, c):
        accion = c['accion']
        if accion == 'salir':
            for ctx in list(self.navegadores.values()):
                ctx.close()
            self.navegadores.clear()
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
        print(f'Control T-143 en 127.0.0.1:{puerto}', flush=True)
        while not detener.is_set():
            httpd.handle_request()
        httpd.server_close()


def cliente(comando, puerto):
    datos = json.dumps(comando).encode('utf-8')
    with urlopen(Request(f'http://127.0.0.1:{puerto}/', data=datos, method='POST',
                         headers={'Content-Type': 'application/json'}), timeout=180) as r:
        return json.loads(r.read().decode('utf-8'))


if __name__ == '__main__':
    puerto = 5944
    args = [a for a in sys.argv[1:]]
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
