"""T-123 · Capturas de la 3.1.1 dentro del rediseño en el emulador (360 × 640
dp, emulator-5554).

Sobre el banco tool/t122_main.dart compilado en sprint-4 (gt.cmartinez.baystream,
APK de depuración), con ADB y los volcados de uiautomator, como
tool/t122_capturas_android.py, del que toma el panel «T122», el previo, la
silueta, las celdas y el dedo por sendevent. Lo que cambia es el teléfono del
rediseño (DESIGN.md 13.8 y 14.6): el modo se elige en la banda del muelle
(Descarga / Carga) o en el menú «Modo del plano», «Asignar vacío» va en
«Acciones» (solo con su icono) y el resumen va en fichas en la línea de
T-107. Por cada tema recorre H1, H3, H4, H5, H6 y H7, y toma además el plano
en Contenido y «El buque en corte» (15), como quedaron aceptados.

python -X utf8 tool/t123_capturas_android.py build/t123/capturas/emulador
"""
import argparse
import io
import sys
import time
from contextlib import contextmanager
from pathlib import Path

from PIL import Image, ImageChops, ImageStat

sys.path.insert(0, str(Path(__file__).resolve().parent))
import t122_capturas_android as t122  # noqa: E402
from t122_capturas_android import (  # noqa: E402
    PAQUETE, adb, atras, bahia, captura, celda, cerrar_el_plano, confirmar_carga,
    confirmar_plano, deslizar_hasta, esperar, nodos, panel, tap, tema, tocar)
from t73_listado_sintetico import box  # noqa: E402

BOTON_DEL_MENU = r'^Modo del plano: '


def modo(nombre):
    """El modo del plano en el rediseño: la banda del muelle si lo ofrece
    (Descarga / Carga, 14.6); si no, el menú «Modo del plano: …» y su
    entrada. Si ya es el pedido, no toca nada."""
    if nodos(r'^Número de orden'):  # el menú quedó abierto
        atras()
    boton = nodos(BOTON_DEL_MENU)
    if boton and boton[0][4].startswith(f'Modo del plano: {nombre}'):
        return
    banda = [n for n in nodos(rf'^{nombre}(?![:\wáéíóúñ])')
             if not n[4].startswith('Modo del plano')]
    if banda:
        n = sorted(banda, key=lambda n: n[1])[0]
        tap((n[0] + n[2]) // 2, (n[1] + n[3]) // 2)
        time.sleep(1.2)
        return
    tocar(BOTON_DEL_MENU)
    time.sleep(0.8)
    tocar(rf'^{nombre}(?![:\wáéíóúñ])', cual='ultimo')
    time.sleep(1.2)


def celda(patron):
    """Toca una celda del plano. En el teléfono bajo del rediseño (13.8) la
    rejilla va anidada bajo la banda y la silueta, y la barra de la operación
    tapa el pie: si la celda queda bajo el pliegue o bajo la barra (y > 1120
    px), primero se desplaza la columna hacia arriba; si no está, la rejilla
    hacia la izquierda."""
    for _ in range(10):
        filas = [n for n in nodos(patron) if 150 < n[1]]
        # Entera (una celda mide unos 170 px) y por encima de la barra: el
        # volcado recorta a lo visible una celda que asoma bajo el pliegue.
        a_la_vista = [n for n in filas if n[3] < 1120 and n[3] - n[1] >= 120]
        if a_la_vista:
            f = a_la_vista[0]
            tap((f[0] + f[2]) // 2, (f[1] + f[3]) // 2)
            return f
        if filas:
            adb('shell', 'input', 'swipe', '540', '1000', '540', '650', '500')
        else:
            adb('shell', 'input', 'swipe', '900', '900', '400', '900', '400')
        time.sleep(1)
    raise RuntimeError(f'No se encontró la celda {patron}')


def accion(rotulo):
    """Una entrada de «Acciones» (solo con su icono en el teléfono: el rótulo
    llega con un salto de línea delante, por eso `Acciones$`)."""
    if nodos(rotulo):
        tocar(rotulo)
        return
    tocar(r'Acciones$')
    time.sleep(0.6)
    tocar(rotulo)


def h1(out, prefijo):
    panel(r'^Llegada \(H1\)$')
    tocar(r'^Seleccionar archivo')
    confirmar_plano(out, f'{prefijo}_h1', puerto='GTSTC', foto_escala=True)
    captura(out, f'{prefijo}_h1_plano_con_descarga')
    modo('Descarga')
    captura(out, f'{prefijo}_h1_modo_descarga')
    cerrar_el_plano()


def h3(out, prefijo):
    panel(r'^Plan de carga$')
    tocar(r'^Seleccionar archivo')
    confirmar_plano(out, f'{prefijo}_carga')
    captura(out, f'{prefijo}_plano_contenido')
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


def h4(out, prefijo):
    tocar(r'^Plano(?:\n|$)')
    time.sleep(1)
    modo('Carga')
    bahia(22)
    captura(out, f'{prefijo}_h4_carga_bahia_22')
    sin_or = box('TSTU022007')
    celda(rf'^{sin_or}, sube$')
    confirmar_carga(out, f'{prefijo}_h4_confirmar_sin_or')
    captura(out, f'{prefijo}_h4_registrado')
    time.sleep(4)


def h5(out, prefijo):
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
    esperar(r'^TOTAL')
    deslizar_hasta(r'^Bahía 22(?:\n|$)')
    time.sleep(0.8)
    captura(out, f'{prefijo}_h5_avance_22')
    tocar(r'^Plano(?:\n|$)')
    time.sleep(1)


def h6(out, prefijo):
    vacio = box('TSTU001212')
    accion(r'^Asignar vacío$')
    tocar(rf'^OR 12 · {vacio}')
    esperar(r'^Asignar vacío$')
    tocar(r'^Celda reservada')
    time.sleep(0.8)
    tocar(r'^021-00-84', cual='ultimo')
    time.sleep(0.8)
    tocar(r'^Confirmar carga$', cual='ultimo')
    time.sleep(4.5)
    tocar(r'^OR / últimos dígitos')
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
# T-124 (O1 de la aceptación de T-123, 10.65). El conductor de T-123 apoyaba
# el dedo con el identificador 1 y, si algo fallaba antes de levantarlo, el
# contacto quedaba activo; el siguiente arrastre reutilizaba el 1 y la celda
# ya no se levantaba. Ahora cada gesto lleva un identificador nuevo, el dedo
# se levanta siempre (finally) y el borde no se evalúa si la celda no se
# levantó.
_ULTIMO_CONTACTO = [int(time.time()) % 40000 + 1000]
_SOLTAR = 4294967295  # ABS_MT_TRACKING_ID = -1


def _contacto_nuevo():
    _ULTIMO_CONTACTO[0] += 1
    return _ULTIMO_CONTACTO[0]


def _ev(tipo, codigo, valor):
    return f'sendevent {t122._PANTALLA} {tipo} {codigo} {valor}'


@contextmanager
def dedo(x, y):
    """El dedo apoyado en (x, y) mientras dura el bloque; al salir, aunque
    sea por un error, se levanta."""
    rx, ry = t122._crudo(x, y)
    adb('shell', '; '.join([_ev(3, 47, 0), _ev(3, 57, _contacto_nuevo()), _ev(1, 330, 1),
                            _ev(3, 53, rx), _ev(3, 54, ry), _ev(3, 58, 500), _ev(0, 0, 0)]))
    try:
        yield
    finally:
        adb('shell', '; '.join([_ev(3, 47, 0), _ev(3, 57, _SOLTAR), _ev(1, 330, 0),
                                _ev(0, 0, 0)]))


def dedo_mueve(puntos, pausa=0.1):
    ordenes = []
    for x, y in puntos:
        rx, ry = t122._crudo(x, y)
        ordenes += [_ev(3, 53, rx), _ev(3, 54, ry), _ev(0, 0, 0), f'sleep {pausa}']
    adb('shell', '; '.join(ordenes))


def _pantalla():
    return Image.open(io.BytesIO(adb('exec-out', 'screencap', '-p'))).convert('L')


def se_levanto(antes, despues, caja, umbral=8.0):
    """Si la celda de [caja] cambió tras la pulsación larga: la que se levanta
    queda atenuada (`childWhenDragging`, opacidad 0.35) y la copia flota
    encima. La diferencia media en gris sobre la celda pasa de [umbral]."""
    recorte = (caja[0], caja[1], caja[2], caja[3])
    diferencia = ImageChops.difference(antes.crop(recorte), despues.crop(recorte))
    return ImageStat.Stat(diferencia).mean[0] > umbral


def h7(out, prefijo):
    panel(r'^Oficina$', r'^Publicar en este dispositivo$')
    time.sleep(1.5)
    modo('Carga')
    bahia(22)
    # El origen, entero y por encima de la barra; en el teléfono bajo la fila
    # de abajo (nivel 82) asoma bajo el pliegue: se desplaza la columna antes.
    pendientes = []
    for _ in range(8):
        pendientes = sorted(
            [n for n in nodos(r'^(OR \d+ · )?TSTU0220\d{3}, sube$')
             if 150 < n[1] and n[3] < 1120 and n[3] - n[1] >= 120],
            key=lambda n: n[0])
        if pendientes:
            break
        adb('shell', 'input', 'swipe', '540', '1000', '540', '650', '500')
        time.sleep(1)
    origen = pendientes[0]
    x1 = (origen[0] + origen[2]) // 2
    y1 = (origen[1] + origen[3]) // 2
    borde = 1000  # a 27 px del borde: dentro de los 40 dp (120 px) del desplazador
    antes = _pantalla()
    with dedo(x1, y1):
        time.sleep(0.9)  # la pulsación larga levanta la celda
        if not se_levanto(antes, _pantalla(), origen):
            raise RuntimeError(f'La celda {origen[4]} no se levantó: no se evalúa el borde.')
        pasos = 8
        dedo_mueve([(x1 + (borde - x1) * i // pasos, y1) for i in range(1, pasos + 1)])
        time.sleep(1.0)
        captura(out, f'{prefijo}_h7_arrastre_en_marcha')
        time.sleep(1.5)
        destino = esperar(r'^Celda 022-09-84, libre$', 20)[0]
        cx, cy = (destino[0] + destino[2]) // 2, (destino[1] + destino[3]) // 2
        dedo_mueve([(borde, y1), (cx, cy)], pausa=0.3)
        time.sleep(0.6)
        captura(out, f'{prefijo}_h7_sobre_la_celda')
    time.sleep(1.8)
    captura(out, f'{prefijo}_h7_al_soltar')
    if nodos(r'^Cancelar$'):
        tocar(r'^Cancelar$', cual='ultimo')


def estadisticas(out, prefijo):
    """«El buque en corte» (15): el destino corto de la barra («Estad.»)."""
    tocar(r'^Estad\.')
    esperar(r'contenedores a bordo', 40)
    time.sleep(1.2)
    captura(out, f'{prefijo}_estadisticas')
    tocar(r'^Plano(?:\n|$)')
    time.sleep(1)


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
    estadisticas(out, prefijo)
    h7(out, prefijo)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--tema', choices=['claro', 'oscuro', 'ambos'], default='ambos')
    p.add_argument('--desde', choices=['h1', 'h3', 'h4', 'h5', 'h6', 'estadisticas', 'h7'],
                   default='h1', help='retomar desde un paso, sobre lo que ya hay en el dispositivo')
    args = p.parse_args()
    if t122.SERIAL != 'emulator-5554':
        raise ValueError('Solo el emulador: nunca el Honor.')
    out = Path(args.salida)
    out.mkdir(parents=True, exist_ok=True)
    for t in (['claro', 'oscuro'] if args.tema == 'ambos' else [args.tema]):
        try:
            if args.desde == 'h1':
                recorrido(out, t)
            else:
                adb('shell', 'monkey', '-p', PAQUETE, '-c', 'android.intent.category.LAUNCHER', '1')
                time.sleep(2)
                tema(t)
                prefijo = f'emulador_{t}'
                pasos = ['h3', 'h4', 'h5', 'h6', 'estadisticas', 'h7']
                for paso in pasos[pasos.index(args.desde):]:
                    globals()[paso](out, prefijo)
        except Exception:
            captura(out, f'_error_{t}')
            raise
    print('capturas:', sorted(r.name for r in out.glob('*.png')))


if __name__ == '__main__':
    raise SystemExit(main())
