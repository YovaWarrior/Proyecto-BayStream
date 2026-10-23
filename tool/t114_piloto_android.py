"""T-114 · Candidata del piloto (10.28): el recorrido del piloto en Android.

Para el emulador (API 26, serial emulator-5554, a 360 dp con `wm density 480`)
con el banco r4, con ADB y uiautomator como tool/t114_capturas_android_plano.py.
Es el recorrido del muelle, como una persona y por el árbol de accesibilidad:
el inicio; el plan de carga (T100_CARGA.edi), que abre en previo y se confirma
por la interfaz (la banda, «Parámetros del buque», «No lo tengo», «Confirmar y
ver el plano»); el listado de la agencia (T100_LISTADO.xlsx) por su página; la
llegada (T100_LLEGADA.edi) por «Más → Cargar archivo BAPLIE», que abre
publicada por DESIGN.md 7.2; la descarga (Baja, otra Baja y Deshacer, Paso con
su pregunta); la carga (asignar un vacío por OR, otro y Deshacer); el avance;
Atrás (un toque avisa, dos vuelven al inicio; el reciente se reabre); y «Más».
Lo que necesita cuenta (pedir cambio) no se recorre aquí. Los archivos van a
/sdcard/Download/t114 (el selector de AOSP los elige ahí). Cada paso es una
captura numerada (screencap) en la salida (TEMP) y una línea de registro.tsv.

python tool/t114_piloto_android.py <salida en TEMP> --entradas <carpeta con los .edi y el .xlsx>
"""
import argparse
import os
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import t98_honor_ui
from t114_capturas_android import adb, captura, elegir_archivo, esperar, observe, tap, tocar_texto
from t114_capturas_android_plano import atras, tocar_entero
from t98_inventario import output_directory
from t98_recuperacion_honor import position


def tocar_patron(patron, intentos=30):
    """Toca el primer control cuyo rótulo cumple el patrón (regex)."""
    rows = esperar(patron, intentos)
    tap(position([rows[0]], rows[0][1]))


def deslizar_hasta(patron, intentos=8, hoja=False):
    """Desliza la lista (o la hoja) hasta que el rótulo esté entero."""
    for _ in range(intentos):
        rows = observe(False, patron)
        if rows:
            try:
                return position([rows[0]], rows[0][1])
            except RuntimeError:
                pass
        if hoja:
            adb('shell', 'input', 'swipe', '540', '1400', '540', '900', '300')
        else:
            adb('shell', 'input', 'swipe', '400', '1300', '400', '700', '400')
        time.sleep(0.9)
    raise RuntimeError(f'No apareció al deslizar: {patron}')


def tocar_celda(patron, intentos=6):
    """Toca la primera celda cuyo rótulo cumple el patrón; si no está a la vista,
    desplaza la rejilla hacia arriba (el teléfono bajo muestra pocas filas) y,
    al final, vuelve arriba."""
    for _ in range(intentos):
        rows = observe(False, patron)
        if rows:
            try:
                tap(position([rows[0]], rows[0][1]))
                return
            except RuntimeError:
                pass
        adb('shell', 'input', 'swipe', '540', '1000', '540', '450', '400')
        time.sleep(1.0)
    raise RuntimeError(f'No apareció ninguna celda: {patron}')


def tocar_ultimo(patron, intentos=8):
    """Toca el último control que cumple el patrón (el botón de un diálogo
    cuyo título dice lo mismo), deslizando si queda bajo el borde."""
    for _ in range(intentos):
        rows = observe(False, patron)
        if rows:
            try:
                tap(position([rows[-1]], rows[-1][1]))
                return
            except RuntimeError:
                pass
        adb('shell', 'input', 'swipe', '400', '1300', '400', '700', '400')
        time.sleep(0.9)
    raise RuntimeError(f'No apareció al deslizar: {patron}')


def sin_aviso(segundos=10):
    """Espera a que se apague el aviso flotante (su «Deshacer» tapa la tira del
    pie, donde están «Acciones» y «OR / últimos dígitos»)."""
    for _ in range(segundos * 2):
        if not observe(False, r'^Deshacer$'):
            return
        time.sleep(0.5)


class Recorrido:
    def __init__(self, out):
        self.out = out
        self.paso = 0
        self.registro = ['paso\tarchivo\tnota\thora (UTC)']

    def foto(self, nombre, nota=''):
        self.paso += 1
        time.sleep(0.6)
        archivo = f'p{self.paso:02d}-{nombre}'
        captura(self.out, archivo)
        self.registro.append(f'{self.paso}\t{archivo}.png\t{nota}\t{datetime.now(timezone.utc).isoformat()}')
        print(archivo, nota)

    def guardar(self):
        (self.out / 'registro.tsv').write_text('\n'.join(self.registro) + '\n', encoding='utf-8')


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--entradas', required=True, help='carpeta con los sintéticos; se copian a /sdcard/Download/t114')
    p.add_argument('--serial', default='emulator-5554')
    p.add_argument('--paquete', default='gt.cmartinez.baystream.r4')
    p.add_argument('--plan-de-carga', default='T100_CARGA.edi')
    p.add_argument('--listado', default='T100_LISTADO.xlsx')
    p.add_argument('--llegada', default='T100_LLEGADA.edi')
    args = p.parse_args()
    if args.serial != 'emulator-5554' and not os.environ.get('T114_HONOR_AUTORIZADO'):
        raise ValueError('El Honor solo con el permiso de Carlos (T114_HONOR_AUTORIZADO=1).')
    os.environ['ANDROID_SERIAL'] = args.serial
    t98_honor_ui.PACKAGE = args.paquete
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    entradas = Path(args.entradas)
    adb('shell', 'mkdir', '-p', '/sdcard/Download/t114')
    for nombre in (args.plan_de_carga, args.listado, args.llegada):
        adb('push', str(entradas / nombre), f'/sdcard/Download/t114/{nombre}')
    adb('shell', 'am', 'force-stop', args.paquete)
    adb('shell', 'pm', 'clear', args.paquete)
    r = Recorrido(out)
    try:
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
        adb('shell', 'monkey', '-p', args.paquete, '-c', 'android.intent.category.LAUNCHER', '1')
        esperar(r'Seleccionar archivo')
        time.sleep(1.5)
        r.foto('inicio', 'el inicio sin viajes')
        # 1. El plan de carga: previo y confirmación por la interfaz.
        tocar_texto('Seleccionar archivo')
        time.sleep(1)
        elegir_archivo(args.plan_de_carga)
        esperar(r'Plano sin confirmar|confirma la escala|Bah[ií]a', 60)
        time.sleep(1.5)
        r.foto('plan-de-carga-en-previo', 'abre en previo con la banda; tres pasos')
        tocar_texto('Confirmar')
        esperar(r'Parámetros del buque')
        time.sleep(0.8)
        r.foto('parametros-del-buque', 'la banda abrió «Parámetros del buque»')
        tocar_entero(r'No lo tengo', 12)
        time.sleep(0.8)
        r.foto('parametros-no-lo-tengo', '«No lo tengo» marcado a mano')
        tocar_entero(r'Confirmar y ver', 8)
        esperar(r'Bah[ií]a', 60)
        time.sleep(1.5)
        r.foto('plan-de-carga-publicado', 'publicado en GTSTC; la banda del muelle con Carga')
        # 2. El listado de la agencia.
        tocar_texto('Lista')
        time.sleep(1.2)
        tap(deslizar_hasta(r'^Listado de la agencia'))
        esperar(r'Elegir listado')
        time.sleep(0.8)
        tocar_patron(r'^Elegir listado')
        time.sleep(1)
        elegir_archivo(args.listado)
        # El botón de confirmar queda bajo el pliegue: primero se espera el listado leído.
        esperar(r'filas en|Equivalencias con el plan', 60)
        time.sleep(1)
        r.foto('listado-leido', 'el listado leído, antes de confirmar')
        tap(deslizar_hasta(r'^Confirmar e importar'))
        # El aviso «Listado importado.» dura 4 s; si se pierde, el listado guardado
        # se lee en la cabecera de la página, arriba.
        try:
            esperar(r'Listado importado', 8)
        except RuntimeError:
            for _ in range(6):
                if observe(False, r'guardado en la operaci'):
                    break
                adb('shell', 'input', 'swipe', '400', '600', '400', '1300', '300')
                time.sleep(0.8)
            esperar(r'guardado en la operaci', 10)
        r.foto('listado-importado', '«Listado guardado en la operación de GTSTC: 30 filas.»')
        atras()
        esperar(r'^Lista(?:\n|$)')
        # 3. La llegada por «Más → Cargar archivo BAPLIE»: abre publicada (7.2).
        tocar_texto('Más')
        time.sleep(1.2)
        tap(deslizar_hasta(r'^Cargar archivo BAPLIE', hoja=True))
        time.sleep(1)
        elegir_archivo(args.llegada)
        esperar(r'Bah[ií]a', 60)
        time.sleep(2.5)
        if observe(False, r'Plano sin confirmar|confirma la escala'):
            raise RuntimeError('La llegada abrió en previo: la escala confirmada no coincide.')
        # El destino sigue en la Lista (de donde salió «Más»): al Plano.
        tocar_texto('Plano')
        time.sleep(1.2)
        r.foto('llegada-publicada', 'la llegada abre publicada sin previo; la banda ofrece Descarga')
        # 4. La descarga.
        tocar_patron(r'^Descarga$')
        time.sleep(1.2)
        r.foto('descarga', 'modo Descarga: «Baja» en las celdas por bajar')
        tocar_patron(r'por descargar$')
        time.sleep(0.6)
        r.foto('baja-registrada', 'un toque: naranja y el aviso con «Deshacer»')
        tocar_patron(r'por descargar$')
        time.sleep(0.6)
        r.foto('segunda-baja', 'otra Baja')
        tocar_patron(r'^Deshacer$')
        time.sleep(1)
        r.foto('baja-deshecha', '«Deshacer»: la celda vuelve a «Baja»')
        tocar_celda(r'de paso, sigue a bordo$')
        esperar(r'Registrar re')
        time.sleep(0.8)
        r.foto('paso-pregunta', 'Paso: la pregunta de la re‑estiba')
        tocar_patron(r'^Registrar re')
        time.sleep(1)
        r.foto('reestiba-registrada', '«Re‑estiba registrada» con «Deshacer»')
        # 5. La carga.
        tocar_patron(r'^Carga$')
        time.sleep(1.2)
        r.foto('carga', 'modo Carga: el OR en las celdas')
        sin_aviso()
        tocar_patron(r'^Acciones$')
        time.sleep(0.8)
        tocar_texto('Asignar vacío')
        esperar(r'Vacíos del listado')
        time.sleep(0.8)
        r.foto('vacios-del-listado', '«Vacíos del listado»')
        tocar_patron(r'^OR \d+ · ')
        esperar(r'Confirmar carga')
        time.sleep(0.8)
        r.foto('asignar-vacio', 'el formulario propone la celda')
        tocar_ultimo(r'^(?:Confirmar carga|Marcar su descarga y cargar)$')
        esperar(r'Carga registrada|carga registradas', 30)
        time.sleep(0.6)
        r.foto('vacio-asignado', '«Carga registrada · OR N» con «Deshacer»')
        sin_aviso()
        tocar_patron(r'^Acciones$')
        time.sleep(0.8)
        tocar_texto('Asignar vacío')
        esperar(r'Vacíos del listado')
        time.sleep(0.8)
        tocar_patron(r'^OR 17 · ')  # el 16 ya se cargó; el subtítulo «Ya cargado» es otro nodo
        esperar(r'Confirmar carga')
        time.sleep(0.8)
        tocar_ultimo(r'^(?:Confirmar carga|Marcar su descarga y cargar)$')
        esperar(r'Carga registrada|carga registradas', 30)
        time.sleep(0.6)
        r.foto('segundo-vacio-asignado', 'otro vacío asignado')
        tocar_patron(r'^Deshacer$')
        time.sleep(1.2)
        r.foto('vacio-deshecho', '«Deshacer»: el OR vuelve a estar pendiente')
        # 6. El avance.
        tocar_texto('Avance')
        time.sleep(1.5)
        r.foto('avance', '«Avance» en el teléfono')
        tocar_texto('Plano')
        time.sleep(1)
        # 7. Atrás: un toque avisa, dos seguidos vuelven al inicio; el reciente se reabre.
        atras()
        esperar(r'Toca Atrás otra vez', 10)
        r.foto('atras-aviso', 'un toque por error: el aviso, y el plano sigue')
        time.sleep(3.5)
        adb('shell', 'input', 'keyevent', '4')
        time.sleep(0.4)
        adb('shell', 'input', 'keyevent', '4')
        esperar(r'Seleccionar archivo', 30)
        time.sleep(1.2)
        r.foto('inicio-con-recientes', 'dos toques seguidos: el inicio con el viaje en los recientes')
        tocar_patron(r'BUQUE MANUAL')
        esperar(r'Bah[ií]a', 60)
        time.sleep(2)
        r.foto('reciente-reabierto', 'el reciente reabre publicado, con la operación')
        # 8. «Más».
        tocar_texto('Más')
        time.sleep(1.2)
        r.foto('mas', 'la hoja «Más»')
        atras()
    finally:
        r.guardar()
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
    print('capturas:', sorted(ruta.name for ruta in out.glob('*.png')))
    return 0


if __name__ == '__main__':
    sys.exit(main())
