"""T-114 · Fase 3, entrega 1: la primera visualización en Windows, en tres pasos.

Instrumento de RNF-002 (≤ 3 pasos y ≤ 30 s hasta la rejilla) para el banco r4
de Windows (tool/t99_main.dart con T99_ALMACEN en %TEMP%), sin persona ni
agente: T-98 no pudo medir Windows por las pausas del agente (10.97), así que
aquí todo lo hace un proceso de Python con sus propios relojes.

Por repetición:
  (1) abre el binario como una persona (explorer.exe, fuera del paquete de la
      consola; windows-almacen-real-explorer); es el «icono» y el inicio del
      reloj;
  (2) cuando el inicio está a la vista, pulsa «Seleccionar archivo» (el botón
      de la marca, localizado en la captura de la ventana por su color, su
      forma y su rótulo);
  (3) en el selector nativo escribe la ruta en «Nombre» y lo confirma por
      mensaje de Win32 (como tool/t98acc_recuperacion_auto.py).
El fin es el primer cuadro en que la ventana queda quieta con el plano (la
rejilla no se anima; el indicador de lectura sí). Se captura solo la ventana
del banco (ImageGrab sobre su rectángulo), a unos 20 cuadros por segundo, con
el reloj monotónico del host; el JSON guarda todos los instantes y las
diferencias entre cuadros, y los PNG de los hitos quedan para revisarlos.
La incertidumbre es el intervalo entre cuadros (≈ 50 ms), que se informa.

La condición «sin perfil» aparta el almacén de la copia antes de cada
repetición; «con perfil» lo conserva.

Desde la corrección de la travesía (10.26, H2):
  - El detector no prueba azules por turno: lee el tema del papel de la
    ventana y busca el botón del color de ese tema, y solo acepta un
    rectángulo con la forma del botón (ancho y bajo, de 40 a 120 px de alto,
    relleno casi entero) con un rótulo centrado dentro. El azul de la marca
    (#0D47A1) está también en el muelle de la ilustración del inicio desde el
    paquete de íconos (10.19), de día y de noche, y antes se pulsaba ahí.
  - El botón tiene que verse en el mismo sitio en dos cuadros seguidos antes
    de pulsarlo (el inicio a la vista y quieto).
  - Antes de buscar, el cursor se aparca en la barra de título: al repetir
    quedaba sobre el botón y el botón nacía con la capa de hover, más
    apagado, fuera de la tolerancia del detector; el detector acepta también
    esa variante del color.
  - El clic se comprueba: si en ESPERA_SELECTOR_S no asoma el selector, se
    anota qué ventana estaba en primer plano y cuál había bajo el cursor, se
    vuelve a traer el banco al frente y se repite el clic, hasta
    INTENTOS_DE_CLIC veces; después se falla con ese diagnóstico, en vez de
    esperar 120 s en silencio. El registro guarda cada intento.
  - `--detector <png> [<png>…]` solo corre el detector sobre capturas
    guardadas y dice qué encontró: sirve para revisar una corrida.

python tool/t114_primera_windows.py --exe <copia>\\build\\windows\\x64\\runner\\Release\\baystream.exe ^
    --archivo <TEMP>\\t114\\sinteticos\\T99_SINTETICO_977.edi --almacen <TEMP>\\t99-r4-fase3\\store-windows ^
    --salida <TEMP>\\t114\\primera\\windows --perfil sin --repeticiones 5
python tool/t114_primera_windows.py --detector <corrida>\\sin01\\inicio.png
"""
import argparse
import ctypes
import json
import os
import shutil
import subprocess
import sys
import time
from ctypes import wintypes
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
from PIL import Image, ImageGrab

sys.path.insert(0, str(Path(__file__).resolve().parent))
import t98acc_sonda_windows as s  # noqa: E402
import t98acc_recuperacion_auto as r  # noqa: E402

user32 = s.user32
kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)
user32.ShowWindow.argtypes = [wintypes.HWND, ctypes.c_int]
user32.SetForegroundWindow.argtypes = [wintypes.HWND]
user32.EnumWindows.argtypes = [ctypes.c_void_p, wintypes.LPARAM]
user32.GetForegroundWindow.restype = wintypes.HWND
user32.WindowFromPoint.argtypes = [wintypes.POINT]
user32.WindowFromPoint.restype = wintypes.HWND
user32.GetAncestor.argtypes = [wintypes.HWND, wintypes.UINT]
user32.GetAncestor.restype = wintypes.HWND
user32.GetCursorPos.argtypes = [ctypes.POINTER(wintypes.POINT)]
kernel32.OpenProcess.restype = wintypes.HANDLE
kernel32.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
kernel32.QueryFullProcessImageNameW.argtypes = [wintypes.HANDLE, wintypes.DWORD, wintypes.LPWSTR,
                                                ctypes.POINTER(wintypes.DWORD)]
kernel32.CloseHandle.argtypes = [wintypes.HANDLE]

TITULO_APP = 'BayStream'
SW_MAXIMIZE = 3
WM_CLOSE = 0x0010
GA_ROOT = 2
# El botón «Seleccionar archivo» lleva la marca (la app sigue al tema del sistema,
# DESIGN.md 4.1): #0D47A1 de día y, desde la Fase 2 bis (13.1), #4F8EF7 de noche, la
# selección, que es el `primary` de noche; antes era #8FB4F2. Con el cursor encima,
# Material 3 le pone la capa de hover (onPrimary al 8 %): de día queda en (32, 86, 169)
# y de noche en (74, 132, 230). Al repetir, el cursor queda donde pulsó la repetición
# anterior, justo sobre el botón, y el botón nace con esa capa (10.26, H2: así se
# perdieron dos de cuatro repeticiones): el detector acepta las dos variantes y,
# además, aparca el cursor en la barra de título antes de buscar.
MARCAS = {
    'claro': {'normal': np.array([13, 71, 161]), 'hover': np.array([32, 86, 169])},
    'oscuro': {'normal': np.array([79, 142, 247]), 'hover': np.array([74, 132, 230])},
}
# El papel de cada tema (DESIGN.md 13.1): el fondo de la ventana dice el tema.
PAPEL = {'claro': np.array([245, 248, 252]), 'oscuro': np.array([7, 17, 31])}
TOLERANCIA = 12
# La forma del botón, en píxeles de la captura, a cualquier escala de Windows
# entre 1.0 y 2.0: 56 dp de alto y al menos tres veces más ancho que alto.
ALTO_DEL_BOTON = (40, 120)
ANCHO_MINIMO_DEL_BOTON = 120
CUADROS_POR_SEGUNDO = 20
QUIETO_S = 0.6           # cuadros iguales durante este tiempo = pantalla quieta
UMBRAL_IGUALES = 0.35    # diferencia media por canal (0-255) para «igual»
ESPERA_SELECTOR_S = 4.0  # tras pulsar, cuánto se espera el selector antes de diagnosticar
INTENTOS_DE_CLIC = 3


def utc():
    return datetime.now(timezone.utc).isoformat()


def ruta_del_proceso(pid):
    handle = kernel32.OpenProcess(0x1000, False, pid)  # PROCESS_QUERY_LIMITED_INFORMATION
    if not handle:
        return ''
    try:
        buffer = ctypes.create_unicode_buffer(1024)
        largo = wintypes.DWORD(1024)
        if kernel32.QueryFullProcessImageNameW(handle, 0, buffer, ctypes.byref(largo)):
            return buffer.value
        return ''
    finally:
        kernel32.CloseHandle(handle)


def titulo_de(hwnd):
    if not hwnd:
        return ''
    largo = user32.GetWindowTextLengthW(hwnd)
    texto = ctypes.create_unicode_buffer(largo + 1)
    user32.GetWindowTextW(hwnd, texto, largo + 1)
    return texto.value


def ventana_del_banco(exe):
    hallados = []

    @ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    def cada(hwnd, _):
        if user32.IsWindowVisible(hwnd):
            if titulo_de(hwnd) == TITULO_APP:
                pid = s.pid_de(hwnd)
                if ruta_del_proceso(pid).lower() == exe.lower():
                    hallados.append((hwnd, pid))
        return True

    user32.EnumWindows(cada, 0)
    return hallados[0] if len(hallados) == 1 else None


def rectangulo(hwnd):
    rect = wintypes.RECT()
    user32.GetWindowRect(hwnd, ctypes.byref(rect))
    return rect.left, rect.top, rect.right, rect.bottom


def capturar(rect):
    imagen = ImageGrab.grab(bbox=rect, all_screens=True)
    return np.asarray(imagen.convert('RGB'))


def tema_del_cuadro(cuadro):
    """El tema por el papel: el color que más píxeles ocupa en la captura."""
    reducido = cuadro[::4, ::4].reshape(-1, 3)
    colores, cuentas = np.unique(reducido, axis=0, return_counts=True)
    dominante = colores[cuentas.argmax()].astype(np.int16)
    for tema, papel in PAPEL.items():
        if np.abs(dominante - papel).max() <= TOLERANCIA:
            return tema
    return None


def _bloques(indices):
    if len(indices) == 0:
        return []
    cortes = np.where(np.diff(indices) > 1)[0]
    return np.split(indices, cortes + 1)


def boton_de_marca(cuadro):
    """El centro del botón «Seleccionar archivo», el tema y sus medidas, o None.

    Lee el tema del papel y busca rectángulos del color del botón de ese tema;
    acepta el que tiene su forma (ancho y bajo, relleno casi entero) y lleva un
    rótulo centrado dentro: lo que no es un dibujo con el mismo azul.
    """
    tema = tema_del_cuadro(cuadro)
    if tema is None:
        return None
    for variante, marca in MARCAS[tema].items():
        mascara = np.abs(cuadro.astype(np.int16) - marca).max(axis=2) <= TOLERANCIA
        filas = np.where(mascara.sum(axis=1) > 60)[0]
        for bloque in sorted(_bloques(filas), key=len, reverse=True):
            alto = len(bloque)
            if not ALTO_DEL_BOTON[0] <= alto <= ALTO_DEL_BOTON[1]:
                continue
            columnas = np.where(mascara[bloque].sum(axis=0) > alto * 0.6)[0]
            for franja in sorted(_bloques(columnas), key=len, reverse=True):
                medidas = _medidas_del_boton(cuadro, mascara, bloque, franja)
                if medidas is not None:
                    x0, x1, y0, y1 = medidas['caja']
                    medidas['color'] = variante
                    return int((x0 + x1) / 2), int((y0 + y1) / 2), tema, medidas
    return None


def _medidas_del_boton(cuadro, mascara, bloque, franja):
    """Las medidas de un candidato si tiene la forma y el rótulo del botón."""
    alto = len(bloque)
    ancho = len(franja)
    if ancho < ANCHO_MINIMO_DEL_BOTON or ancho < alto * 3 or ancho > cuadro.shape[1] * 0.95:
        return None
    y0, y1 = int(bloque[0]), int(bloque[-1])
    x0, x1 = int(franja[0]), int(franja[-1])
    caja = mascara[y0:y1 + 1, x0:x1 + 1]
    relleno = float(caja.mean())
    # Relleno casi entero: lo que no es marca es el rótulo (y las esquinas).
    if relleno < 0.75:
        return None
    otros = ~caja
    # El rótulo: píxeles que no son marca, concentrados en la franja central de
    # filas y centrados a lo ancho, con una extensión de entre el 8 y el 60 %
    # del ancho. Un dibujo con el mismo azul no tiene esa firma.
    centro = otros[int(alto * 0.3):int(alto * 0.7) + 1]
    columnas = np.where(centro.sum(axis=0) > 0)[0]
    if len(columnas) == 0:
        return None
    extension = (int(columnas[-1]) - int(columnas[0]) + 1) / ancho
    if not 0.08 <= extension <= 0.6:
        return None
    desvio = abs((int(columnas[0]) + int(columnas[-1])) / 2 - ancho / 2) / ancho
    if desvio > 0.15:
        return None
    proporcion = float(otros.mean())
    if not 0.01 <= proporcion <= 0.2:
        return None
    return {'caja': [x0, x1, y0, y1], 'ancho': ancho, 'alto': alto,
            'relleno': round(relleno, 3), 'rotulo': round(extension, 3),
            'rotuloDesvio': round(desvio, 3), 'otros': round(proporcion, 3)}


def diferencia(a, b):
    return float(np.abs(a.astype(np.int16) - b.astype(np.int16)).mean())


def diagnostico_del_clic(hwnd, x, y):
    """Qué había al pulsar: la ventana en primer plano, la que había bajo el
    cursor y dónde quedó el cursor. Si el clic no abre el selector, esto dice
    si llegó al banco o a otra ventana."""
    bajo = user32.WindowFromPoint(wintypes.POINT(x, y))
    raiz = user32.GetAncestor(bajo, GA_ROOT) if bajo else None
    cursor = wintypes.POINT()
    user32.GetCursorPos(ctypes.byref(cursor))
    primero = user32.GetForegroundWindow()
    return {
        'pedido': [x, y],
        'cursor': [cursor.x, cursor.y],
        'primerPlano': {'esElBanco': bool(primero) and primero == hwnd,
                        'titulo': titulo_de(primero), 'pid': s.pid_de(primero) if primero else None},
        'bajoElCursor': {'esElBanco': bool(raiz) and raiz == hwnd,
                         'titulo': titulo_de(raiz), 'pid': s.pid_de(raiz) if raiz else None},
    }


def repeticion(args, numero, out):
    carpeta = out / f'{args.perfil}{numero:02d}'
    carpeta.mkdir()
    registro = {'instrumento': 'tool/t114_primera_windows.py', 'perfil': args.perfil,
                'repeticion': numero, 'exe': args.exe, 'archivo': args.archivo,
                'inicioUtc': utc(), 'acciones': [], 'clics': [], 'cuadros': [], 'hitos': {}}
    if args.perfil == 'sin' and Path(args.almacen).exists():
        destino = out / f'almacen-apartado-{args.perfil}{numero:02d}'
        shutil.move(args.almacen, destino)
        registro['almacenApartado'] = str(destino)
    reloj = time.perf_counter
    t0 = reloj()
    registro['acciones'].append({'paso': 1, 'accion': 'abrir el binario (icono)', 't': 0.0})
    # Fuera del paquete de la consola: explorer.exe lo abre como una persona.
    subprocess.Popen(['explorer.exe', args.exe])
    ventana = None
    while ventana is None:
        if reloj() - t0 > 60:
            raise RuntimeError('La ventana del banco no apareció en 60 s.')
        ventana = ventana_del_banco(args.exe)
        time.sleep(0.02)
    hwnd, pid = ventana
    registro['hitos']['ventana'] = reloj() - t0
    # El cursor, a la barra de título: fuera del contenido, para que ningún
    # botón nazca con la capa de hover de la repetición anterior.
    rect = rectangulo(hwnd)
    user32.SetCursorPos((rect[0] + rect[2]) // 2, rect[1] + 12)
    registro['cursorAparcado'] = [(rect[0] + rect[2]) // 2, rect[1] + 12]
    user32.ShowWindow(hwnd, SW_MAXIMIZE)
    user32.SetForegroundWindow(hwnd)
    # Maximizar es asíncrono: se espera a que la ventana esté maximizada y
    # el rectángulo se relee en cada cuadro.
    for _ in range(100):
        if user32.IsZoomed(hwnd):
            break
        time.sleep(0.02)
    rect = rectangulo(hwnd)
    registro['ventana'] = {'pid': pid, 'rect': rect, 'maximizada': bool(user32.IsZoomed(hwnd))}
    pulsado = False
    confirmado = False
    dialogo = None
    quieto_desde = None
    fin = None
    ultimo = None
    guardados = {}
    intervalo = 1.0 / CUADROS_POR_SEGUNDO
    boton_anterior = None   # el botón visto en el cuadro anterior: dos seguidos antes de pulsar
    pulsado_en = None
    intentos = 0

    def guardar(nombre, cuadro):
        Image.fromarray(cuadro).save(carpeta / f'{nombre}.png')
        guardados[nombre] = f'{nombre}.png'

    def fallar(motivo):
        registro['errorInstrumento'] = motivo
        registro['pngs'] = guardados
        (carpeta / 'registro.json').write_text(json.dumps(registro, ensure_ascii=False, indent=1),
                                               encoding='utf-8')
        user32.PostMessageW(hwnd, WM_CLOSE, 0, 0)
        raise RuntimeError(motivo)

    def pulsar(boton, cuadro, t):
        nonlocal pulsado, pulsado_en, intentos
        intentos += 1
        x, y = rect[0] + boton[0], rect[1] + boton[1]
        if intentos == 1:
            guardar('inicio', cuadro)
            registro['tema'] = boton[2]
            registro['boton'] = boton[3]
        else:
            guardar(f'reintento{intentos}', cuadro)
            # Al frente otra vez, por si el primer clic fue a otra ventana.
            user32.SetForegroundWindow(hwnd)
            time.sleep(0.25)
        registro['acciones'].append({'paso': 2, 'accion': 'pulsar «Seleccionar archivo»',
                                     't': round(reloj() - t0, 4), 'punto': [x, y],
                                     'intento': intentos})
        s.clic(x, y)
        registro['clics'].append({'intento': intentos, 't': round(reloj() - t0, 4), 'punto': [x, y],
                                  'botonEnLaCaptura': boton[:2], 'selectorEnS': None,
                                  'diagnostico': None})
        pulsado = True
        pulsado_en = t

    while True:
        t = reloj() - t0
        if t > 120:
            guardar('ultimo', cuadro)
            fallar('Más de 120 s sin rejilla.')
        rect = rectangulo(hwnd)
        cuadro = capturar(rect)
        if ultimo is not None and ultimo.shape != cuadro.shape:
            ultimo = None
        dif = None if ultimo is None else diferencia(cuadro, ultimo)
        registro['cuadros'].append({'t': round(t, 4), 'dif': None if dif is None else round(dif, 3)})
        if not pulsado:
            boton = boton_de_marca(cuadro)
            # El inicio a la vista y quieto: el botón en el mismo sitio en dos
            # cuadros seguidos (el ventanazo de maximizar ya pasó).
            if boton is not None and boton_anterior is not None and \
                    abs(boton[0] - boton_anterior[0]) <= 2 and abs(boton[1] - boton_anterior[1]) <= 2:
                pulsar(boton, cuadro, t)
            boton_anterior = None if boton is None else boton[:2]
        elif not confirmado:
            dialogo = r.selector(pid)
            if dialogo is not None:
                registro['clics'][-1]['selectorEnS'] = round(t - pulsado_en, 3)
                time.sleep(0.4)  # el selector se dibuja primero en blanco
                campo = r.campo_nombre(dialogo)
                if campo is None:
                    fallar('El selector no tiene el campo «Nombre».')
                user32.SendMessageW(campo, r.WM_SETTEXT, 0, args.archivo)
                time.sleep(0.1)
                user32.PostMessageW(dialogo, r.WM_COMMAND, r.IDOK, 0)
                registro['acciones'].append({'paso': 3, 'accion': 'elegir el archivo en el selector y confirmar',
                                             't': round(reloj() - t0, 4)})
                confirmado = True
                quieto_desde = None
            elif t - pulsado_en > ESPERA_SELECTOR_S:
                # El clic no abrió el selector: se anota qué pasó y se repite.
                ultimo_clic = registro['clics'][-1]
                diagnostico = diagnostico_del_clic(hwnd, *ultimo_clic['punto'])
                ultimo_clic['diagnostico'] = diagnostico
                guardar(f'sin-selector{intentos}', cuadro)
                if intentos >= INTENTOS_DE_CLIC:
                    fallar(f'El clic no abrió el selector en {intentos} intentos de '
                           f'{ESPERA_SELECTOR_S:.0f} s. Último diagnóstico: '
                           f'{json.dumps(diagnostico, ensure_ascii=False)}')
                boton = boton_de_marca(cuadro)
                if boton is None:
                    fallar(f'Tras el clic {intentos} no asomó el selector y el inicio ya no '
                           f'está a la vista. Diagnóstico: {json.dumps(diagnostico, ensure_ascii=False)}')
                pulsar(boton, cuadro, t)
        else:
            if r.selector(pid) is None:
                if dif is not None and dif <= UMBRAL_IGUALES:
                    quieto_desde = quieto_desde if quieto_desde is not None else (t, cuadro)
                    if t - quieto_desde[0] >= QUIETO_S:
                        fin = quieto_desde[0]
                        guardar('rejilla', quieto_desde[1])
                        guardar('final', cuadro)
                        break
                else:
                    quieto_desde = None
        ultimo = cuadro
        resto = intervalo - ((reloj() - t0) - t)
        if resto > 0:
            time.sleep(resto)
    # Sin la pestaña del plano no hay marca de la rejilla en el cuadro final:
    # se deja al revisor el PNG «rejilla» y el «inicio».
    registro['hitos']['pulsado'] = next(a['t'] for a in registro['acciones'] if a['paso'] == 2)
    registro['hitos']['confirmado'] = next(a['t'] for a in registro['acciones'] if a['paso'] == 3)
    registro['hitos']['rejillaQuieta'] = round(fin, 4)
    registro['hitos']['incertidumbreS'] = round(intervalo, 3)
    registro['pasosDelProducto'] = 3
    registro['reintentosDeClic'] = intentos - 1
    registro['tiempoHastaRejillaS'] = round(fin, 3)
    registro['cumpleTiempo'] = fin <= 30
    registro['pngs'] = guardados
    registro['finUtc'] = utc()
    user32.PostMessageW(hwnd, WM_CLOSE, 0, 0)
    for _ in range(100):
        if ventana_del_banco(args.exe) is None:
            break
        time.sleep(0.1)
    (carpeta / 'registro.json').write_text(json.dumps(registro, ensure_ascii=False, indent=1),
                                           encoding='utf-8')
    return registro


def solo_detector(rutas):
    """Corre el detector sobre capturas guardadas y dice qué encontró."""
    for ruta in rutas:
        cuadro = np.asarray(Image.open(ruta).convert('RGB'))
        boton = boton_de_marca(cuadro)
        resultado = {'imagen': str(ruta), 'tamano': [cuadro.shape[1], cuadro.shape[0]],
                     'tema': tema_del_cuadro(cuadro)}
        if boton is None:
            resultado['boton'] = None
        else:
            resultado['boton'] = {'punto': list(boton[:2]), 'tema': boton[2], **boton[3]}
        print(json.dumps(resultado, ensure_ascii=False))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--detector', nargs='+', metavar='PNG',
                   help='solo corre el detector sobre estas capturas y termina')
    p.add_argument('--exe')
    p.add_argument('--archivo')
    p.add_argument('--almacen', help='El T99_ALMACEN de la compilación, en %%TEMP%%.')
    p.add_argument('--salida')
    p.add_argument('--perfil', choices=['sin', 'con'])
    p.add_argument('--repeticiones', type=int, default=5)
    args = p.parse_args()
    if args.detector:
        solo_detector([Path(ruta) for ruta in args.detector])
        return
    for nombre in ('exe', 'archivo', 'almacen', 'salida', 'perfil'):
        if getattr(args, nombre) is None:
            raise SystemExit(f'Falta --{nombre} (o usa --detector).')
    temp = Path(os.environ['TEMP']).resolve()
    for ruta in (args.exe, args.archivo, args.almacen, args.salida):
        if not Path(ruta).resolve().is_relative_to(temp):
            raise SystemExit(f'Solo rutas dentro de %TEMP%: {ruta}')
    if not Path(args.exe).exists() or not Path(args.archivo).exists():
        raise SystemExit('Falta el binario o el archivo.')
    if ventana_del_banco(args.exe) is not None:
        raise SystemExit('El banco ya está abierto: ciérralo antes de medir.')
    user32.SetProcessDPIAware()
    out = Path(args.salida)
    out.mkdir(parents=True, exist_ok=True)
    if any(out.iterdir()):
        raise SystemExit('No sobrescribir una corrida: usa otra carpeta.')
    resultados = []
    for numero in range(1, args.repeticiones + 1):
        registro = repeticion(args, numero, out)
        resultados.append({'repeticion': numero, 'tiempoHastaRejillaS': registro['tiempoHastaRejillaS'],
                           'pasos': registro['pasosDelProducto'], 'cumpleTiempo': registro['cumpleTiempo'],
                           'reintentosDeClic': registro['reintentosDeClic']})
        print(json.dumps(resultados[-1]))
        time.sleep(2)
    (out / 'resumen.json').write_text(json.dumps({
        'instrumento': 'tool/t114_primera_windows.py', 'perfil': args.perfil,
        'archivo': args.archivo, 'exe': args.exe, 'repeticiones': resultados,
        'incertidumbreS': round(1.0 / CUADROS_POR_SEGUNDO, 3)}, ensure_ascii=False, indent=1),
        encoding='utf-8')


if __name__ == '__main__':
    main()
