"""T-122 · Capturas de la 3.1.1 en el emulador (360 × 640 dp, emulator-5554).

Sobre el banco tool/t122_main.dart (gt.cmartinez.baystream, APK de
depuración), con ADB y los volcados de uiautomator, como una persona: el
panel «T122» elige la entrada sintética y el rol; todo lo demás se toca en la
interfaz del producto. Por cada tema (claro y oscuro) recorre:

  h1  el plano de llegada: «Parámetros del buque» ofrece el puerto donde baja
      la carga («GTSTC (7)») y el modo Descarga existe al elegirlo;
  h3  el listado con la fila «AGREGADOS», leído sin filas sin entender;
  h4  en el muelle, un lleno del plan sin fila en el listado abre «Confirmar
      carga» y se registra por su número;
  h5  el avance de una bahía de 40 (la 22) sube bajo la 22 en la silueta y en
      «Avance de la operación»;
  h6  el vacío asignado a una reserva sale en «OR / últimos dígitos» y en la
      búsqueda general;
  h7  el arrastre de un extremo al otro de la bahía 22 desplaza el plano y
      suelta en la celda bajo el dedo (rol oficina, operación publicada en el
      dispositivo).

python -X utf8 tool/t122_capturas_android.py build/t122/capturas/emulador
"""
import argparse
import os
import re
import subprocess
import sys
import threading
import time
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from t73_listado_sintetico import box  # noqa: E402

ADB = os.path.join(os.environ['LOCALAPPDATA'], 'Android', 'Sdk', 'platform-tools', 'adb.exe')
PAQUETE = 'gt.cmartinez.baystream'
SERIAL = 'emulator-5554'


def adb(*args, texto=False):
    r = subprocess.run([ADB, '-s', SERIAL, *args], capture_output=True, check=True)
    return r.stdout.decode('utf-8', 'replace') if texto else r.stdout


def volcado():
    """El volcado de uiautomator; si la interfaz no está ociosa (animación,
    arranque), reintenta y, si no hay manera, devuelve vacío."""
    for _ in range(4):
        raw = subprocess.run([ADB, '-s', SERIAL, 'exec-out', 'uiautomator', 'dump', '/dev/tty'],
                             capture_output=True).stdout
        inicio, fin = raw.find(b'<?xml'), raw.rfind(b'</hierarchy>')
        if inicio >= 0 and fin >= 0:
            return raw[inicio:fin + len(b'</hierarchy>')].decode('utf-8', 'replace')
        time.sleep(0.7)
    return ''


def nodos(patron=None):
    """[(x1, y1, x2, y2, texto)] de los nodos cuyo texto o content-desc casa."""
    try:
        raiz = ET.fromstring(volcado())
    except ET.ParseError:
        return []
    salida = []
    for n in raiz.iter('node'):
        texto = n.get('content-desc') or n.get('text') or ''
        if not texto:
            continue
        if patron is not None and not re.search(patron, texto):
            continue
        x1, y1, x2, y2 = map(int, re.findall(r'-?\d+', n.get('bounds')))
        if x2 - x1 <= 0 or y2 - y1 <= 0:
            continue
        salida.append((x1, y1, x2, y2, texto))
    return salida


def marcado(patron):
    """Si el control que casa con el patrón está marcado (`checked` del volcado)."""
    try:
        raiz = ET.fromstring(volcado())
    except ET.ParseError:
        return False
    for n in raiz.iter('node'):
        texto = n.get('content-desc') or n.get('text') or ''
        if texto and re.search(patron, texto):
            return n.get('checked') == 'true'
    return False


def esperar(patron, segundos=40):
    fin = time.time() + segundos
    while time.time() < fin:
        filas = nodos(patron)
        if filas:
            return filas
        time.sleep(0.8)
    raise RuntimeError(f'No apareció: {patron}')


def tap(x, y):
    adb('shell', 'input', 'tap', str(x), str(y))
    time.sleep(0.9)


def tocar(patron, cual='primero', segundos=40):
    filas = esperar(patron, segundos)
    if cual == 'ultimo':
        filas = sorted(filas, key=lambda f: f[1])
        f = filas[-1]
    else:
        f = filas[0]
    tap((f[0] + f[2]) // 2, (f[1] + f[3]) // 2)
    return f


def deslizar_hasta(patron, intentos=20, de=(540, 1200), a=(540, 800)):
    """Desliza despacio (sin lanzar la lista) hasta que el control esté
    entero a la vista (alto ≥ 40 px)."""
    for _ in range(intentos):
        for f in nodos(patron):
            if f[3] - f[1] >= 40 and f[1] > 150 and f[3] < 1880:
                return f
        adb('shell', 'input', 'swipe', str(de[0]), str(de[1]), str(a[0]), str(a[1]), '900')
        time.sleep(1.0)
    raise RuntimeError(f'No se pudo traer a la vista: {patron}')


def atras():
    adb('shell', 'input', 'keyevent', '4')
    time.sleep(0.9)


def captura(out, nombre):
    destino = out / f'{nombre}.png'
    time.sleep(0.6)
    destino.write_bytes(adb('exec-out', 'screencap', '-p'))
    print(destino.name)


# ---------------------------------------------------------------- el banco
def panel(*acciones):
    """Abre el panel T122, toca cada acción (patrón) y lo cierra. La pestaña
    se toca por su posición (28 × 56 dp en el borde izquierdo, al 42 % del
    alto): su nodo de semántica abarca toda la pantalla."""
    alto = esperar(r'^Banco T122$')[0][3]
    tap(42, int(alto * .42) + 84)
    esperar(r'^Próximo archivo$')
    for a in acciones:
        tocar(a)
    tocar(r'^Cerrar panel$')
    time.sleep(0.6)


def tema(nombre):
    panel(rf'^Tema {nombre}$')
    time.sleep(1.2)


def cerrar_el_plano():
    tocar(r'^Más(?:\n|$)')
    time.sleep(1)
    for _ in range(5):
        f = [n for n in nodos(r'^Cerrar el plano') if n[3] - n[1] >= 60]
        if f:
            break
        adb('shell', 'input', 'swipe', '540', '1400', '540', '900', '300')
        time.sleep(1)
    tocar(r'^Cerrar el plano')
    esperar(r'^Seleccionar archivo')
    time.sleep(1)


def confirmar_plano(out, prefijo, puerto=None, foto_escala=False):
    """El previo: «Confirmar», «Parámetros del buque», la escala, «No lo
    tengo» y «Confirmar y ver»."""
    esperar(r'^Confirmar$', 60)
    time.sleep(1)
    tocar(r'^Confirmar$')
    # Con el perfil del mismo buque guardado, la carga que excede el perfil
    # pregunta antes: «Revisar ampliación» abre los parámetros.
    for _ in range(20):
        if nodos(r'Parámetros del buque'):
            break
        if nodos(r'^Revisar ampliación$'):
            tocar(r'^Revisar ampliación$')
            break
        time.sleep(0.8)
    esperar(r'Parámetros del buque')
    time.sleep(0.8)
    deslizar_hasta(r'^Puerto de esta escala')
    deslizar_hasta(r'^Sin declarar$')  # la última ficha de los puertos, a la vista
    if foto_escala:
        captura(out, f'{prefijo}_parametros_escala')
    if puerto:
        tocar(rf'^{puerto} \(\d+\)$')
        time.sleep(0.8)
        if foto_escala:
            captura(out, f'{prefijo}_parametros_escala_elegida')
    deslizar_hasta(r'^No lo tengo')
    # Con el perfil ya guardado viene marcado: tocarlo lo desmarcaría.
    if not marcado(r'^No lo tengo'):
        tocar(r'^No lo tengo')
    deslizar_hasta(r'^Confirmar y ver')
    tocar(r'^Confirmar y ver')
    esperar(r'^Bahía \d+,', 60)
    time.sleep(3.5)  # el aviso «Archivo cargado» dura 4 s


def modo(nombre):
    """El modo del plano («Contenido», «Carga», «Descarga»): si ya es el
    pedido no toca nada; si no, abre el desplegable y lo elige."""
    if nodos(r'^Número de orden$'):  # el desplegable quedó abierto
        atras()
    # El desplegable del modo va en la tira de abajo; la banda del muelle
    # también dice «Carga» arriba, así que se toma el nodo más bajo.
    actual = sorted(esperar(r'^(Contenido|Carga|Descarga|Número de orden)(?:\n|$)'),
                    key=lambda n: n[1])[-1]
    if actual[4].startswith(nombre):
        return
    tap((actual[0] + actual[2]) // 2, (actual[1] + actual[3]) // 2)
    time.sleep(0.8)
    tocar(rf'^{nombre}$', cual='ultimo')
    time.sleep(1.2)


def bahia(numero):
    # La cabecera anidada (silueta) se va al desplazar la rejilla (13.8):
    # primero vuelve arriba, después busca la bahía en la silueta.
    for _ in range(2):
        adb('shell', 'input', 'swipe', '540', '700', '540', '1500', '400')
        time.sleep(0.8)
    f = deslizar_hasta(rf'^Bahía {numero},', de=(900, 560), a=(300, 560))
    tap((f[0] + f[2]) // 2, (f[1] + f[3]) // 2)
    time.sleep(1.0)


def celda(patron):
    """Toca una celda del plano, trayéndola a la vista en la rejilla."""
    for _ in range(6):
        filas = [n for n in nodos(patron) if 150 < n[1] and n[3] < 1700]
        if filas:
            f = filas[0]
            tap((f[0] + f[2]) // 2, (f[1] + f[3]) // 2)
            return f
        adb('shell', 'input', 'swipe', '900', '900', '400', '900', '400')
        time.sleep(1)
    raise RuntimeError(f'No se encontró la celda {patron}')


def h1(out, prefijo):
    panel(r'^Llegada \(H1\)$')
    tocar(r'^Seleccionar archivo')
    confirmar_plano(out, f'{prefijo}_h1', puerto='GTSTC', foto_escala=True)
    f = esperar(r'^(Contenido|Descarga)(?:\n|$)')
    tap((f[0][0] + f[0][2]) // 2, (f[0][1] + f[0][3]) // 2)
    time.sleep(0.8)
    esperar(r'^Descarga$')
    captura(out, f'{prefijo}_h1_modo_descarga')
    atras()
    cerrar_el_plano()


def h3(out, prefijo):
    panel(r'^Plan de carga$')
    tocar(r'^Seleccionar archivo')
    confirmar_plano(out, f'{prefijo}_carga')
    tocar(r'^Lista(?:\n|$)')
    time.sleep(1)
    deslizar_hasta(r'^Listado de la agencia')
    tocar(r'^Listado de la agencia')
    esperar(r'^Elegir listado')
    panel(r'^Listado \(H3\)$')
    tocar(r'^Elegir listado')
    esperar(r'^Confirmar e importar', 30)
    time.sleep(0.8)
    captura(out, f'{prefijo}_h3_agregados')
    deslizar_hasta(r'^Confirmar e importar')
    tocar(r'^Confirmar e importar')
    esperar(r'guardado en la operación|Listado guardado', 30)
    time.sleep(0.6)
    captura(out, f'{prefijo}_h3_importado')
    atras()
    time.sleep(0.8)


def confirmar_carga(out, nombre):
    esperar(r'^Confirmar carga$')
    time.sleep(0.5)
    captura(out, nombre)
    tocar(r'^Confirmar carga$', cual='ultimo')
    time.sleep(1.5)


def h4(out, prefijo):
    tocar(r'^Plano(?:\n|$)')
    time.sleep(1)
    modo('Carga')
    bahia(22)
    sin_or = box('TSTU022007')
    celda(rf'^{sin_or}, sube$')
    confirmar_carga(out, f'{prefijo}_h4_confirmar_sin_or')
    captura(out, f'{prefijo}_h4_registrado')
    time.sleep(4)


def h5(out, prefijo):
    # El OR 1 por «OR / últimos dígitos»: no depende de dónde quedó la rejilla.
    tocar(r'^OR / últimos dígitos')
    esperar(r'Confirmar carga por OR o contenedor')
    adb('shell', 'input', 'text', 'OR%s1')
    time.sleep(1.2)
    tocar(r'^OR 1 · TSTU0220003')
    confirmar_carga(out, f'{prefijo}_h5_confirmar_or1')
    time.sleep(4)
    bahia(22)
    captura(out, f'{prefijo}_h5_silueta_22')
    tocar(r'^Avance(?:\n|$)')
    esperar(r'^TOTAL')  # la tarjeta entera es un solo nodo
    # La tarjeta de la 22 va debajo de TOTAL: se desliza hasta verla entera.
    deslizar_hasta(r'^Bahía 22(?:\n|$)')
    time.sleep(0.8)
    captura(out, f'{prefijo}_h5_avance_22')
    tocar(r'^Plano(?:\n|$)')
    time.sleep(1)


def h6(out, prefijo):
    vacio = box('TSTU001212')
    if nodos(r'^Asignar vacío$'):
        tocar(r'^Asignar vacío$')
    else:
        tocar(r'Acciones$')
        tocar(r'^Asignar vacío$')
    tocar(rf'^OR 12 · {vacio}')
    esperar(r'^Asignar vacío$')
    tocar(r'^Celda reservada')
    time.sleep(0.8)
    tocar(r'^021-00-84', cual='ultimo')
    time.sleep(0.8)
    tocar(r'^Confirmar carga$', cual='ultimo')
    time.sleep(4.5)
    tocar(r'^OR / últimos dígitos$')
    esperar(r'Confirmar carga por OR o contenedor')
    adb('shell', 'input', 'text', '123')
    time.sleep(1.2)
    esperar(r'Ya cargado')
    captura(out, f'{prefijo}_h6_or_ultimos_digitos')
    atras()
    time.sleep(0.8)
    tocar(r'Buscar contenedor$')
    time.sleep(1)
    adb('shell', 'input', 'text', vacio)
    time.sleep(1.5)
    esperar(r'Posición: Bahía')
    captura(out, f'{prefijo}_h6_busqueda_general')
    f = nodos(r'Posición: Bahía')[0]
    tap((f[0] + f[2]) // 2, (f[1] + f[3]) // 2)
    time.sleep(1.5)
    captura(out, f'{prefijo}_h6_resaltado')


# ------------------------------------------------- el dedo, por sendevent
# `input draganddrop` suelta en cuanto llega al punto final, así que el dedo
# nunca se queda quieto en el borde ni vuelve a la celda. Con sendevent sobre
# la pantalla táctil del emulador (event1, protocolo B, 0..32767) el gesto es
# el de una persona: mantener, llevar al borde, esperar a que el plano se
# desplace solo, posarse sobre la celda que apareció y soltar.
_PANTALLA = '/dev/input/event1'


def _crudo(x, y):
    return int(x * 32767 / 1080), int(y * 32767 / 1920)


def _ev(tipo, codigo, valor):
    return f'sendevent {_PANTALLA} {tipo} {codigo} {valor}'


def dedo_abajo(x, y):
    rx, ry = _crudo(x, y)
    adb('shell', '; '.join([_ev(3, 47, 0), _ev(3, 57, 1), _ev(1, 330, 1),
                            _ev(3, 53, rx), _ev(3, 54, ry), _ev(3, 58, 500), _ev(0, 0, 0)]))


def dedo_mueve(puntos, pausa=0.1):
    ordenes = []
    for x, y in puntos:
        rx, ry = _crudo(x, y)
        ordenes += [_ev(3, 53, rx), _ev(3, 54, ry), _ev(0, 0, 0), f'sleep {pausa}']
    adb('shell', '; '.join(ordenes))


def dedo_arriba():
    adb('shell', '; '.join([_ev(3, 57, 4294967295), _ev(1, 330, 0), _ev(0, 0, 0)]))


def h7(out, prefijo):
    panel(r'^Oficina$', r'^Publicar en este dispositivo$')
    time.sleep(1.5)
    bahia(22)
    pendientes = sorted(
        [n for n in nodos(r'^(OR \d+ · )?TSTU0220\d{3}, sube$') if 150 < n[1] < 1700],
        key=lambda n: n[0])
    origen = pendientes[0]
    x1 = (origen[0] + origen[2]) // 2
    y1 = (origen[1] + origen[3]) // 2
    borde = 1000  # a 27 px del borde: dentro de los 40 dp (120 px) del desplazador
    dedo_abajo(x1, y1)
    time.sleep(0.9)  # la pulsación larga levanta la celda
    pasos = 8
    dedo_mueve([(x1 + (borde - x1) * i // pasos, y1) for i in range(1, pasos + 1)])
    time.sleep(1.0)  # el plano ya se está desplazando solo
    captura(out, f'{prefijo}_h7_arrastre_en_marcha')
    time.sleep(1.5)  # hasta el final del desplazamiento
    # La celda libre del otro extremo, que antes no estaba a la vista.
    destino = esperar(r'^Celda 022-09-84, libre$', 20)[0]
    cx, cy = (destino[0] + destino[2]) // 2, (destino[1] + destino[3]) // 2
    dedo_mueve([(borde, y1), (cx, cy)], pausa=0.3)
    time.sleep(0.6)
    captura(out, f'{prefijo}_h7_sobre_la_celda')
    dedo_arriba()
    time.sleep(1.8)
    captura(out, f'{prefijo}_h7_al_soltar')
    if nodos(r'^Cancelar$'):
        tocar(r'^Cancelar$', cual='ultimo')


def solo_h7(out, nombre_tema):
    """Solo el arrastre, sobre la operación que la vuelta completa dejó en
    el dispositivo (sin borrar datos)."""
    adb('shell', 'monkey', '-p', PAQUETE, '-c', 'android.intent.category.LAUNCHER', '1')
    time.sleep(2)
    tema(nombre_tema)
    tocar(r'^Plano(?:\n|$)')
    time.sleep(1)
    modo('Carga')
    h7(out, f'emulador_{nombre_tema}')


def recorrido(out, nombre_tema):
    adb('shell', 'am', 'force-stop', PAQUETE)
    adb('shell', 'pm', 'clear', PAQUETE)
    adb('shell', 'monkey', '-p', PAQUETE, '-c', 'android.intent.category.LAUNCHER', '1')
    esperar(r'^Seleccionar archivo', 60)
    time.sleep(2)
    tema(nombre_tema)
    prefijo = f'emulador_{nombre_tema}'
    h1(out, prefijo)
    h3(out, prefijo)
    h4(out, prefijo)
    h5(out, prefijo)
    h6(out, prefijo)
    h7(out, prefijo)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--tema', choices=['claro', 'oscuro', 'ambos'], default='ambos')
    p.add_argument('--solo-h7', action='store_true',
                   help='solo el arrastre, sobre la operación que ya está en el dispositivo')
    args = p.parse_args()
    out = Path(args.salida)
    out.mkdir(parents=True, exist_ok=True)
    for t in (['claro', 'oscuro'] if args.tema == 'ambos' else [args.tema]):
        try:
            (solo_h7 if args.solo_h7 else recorrido)(out, t)
        except Exception:
            captura(out, f'_error_{t}')
            raise
    print('capturas:', sorted(r.name for r in out.glob('*.png')))


if __name__ == '__main__':
    raise SystemExit(main())
