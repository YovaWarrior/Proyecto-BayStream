"""Aceptación de T-98 (Timonel): instrumento del Honor para el paquete .t98acc.

Subcomandos (la salida va siempre a una carpeta bajo TEMP):
  red ETIQUETA          netstats forzado + /proc/net del UID del paquete
  muestreo iniciar      /proc/net/{tcp,tcp6,udp,udp6} cada 0.1 s en el Honor
  muestreo detener      detiene, cuenta filas del UID y borra el rastro
  grabar iniciar NOMBRE screenrecord en el Honor
  grabar detener NOMBRE lo cierra con SIGINT y lo baja a TEMP
  nodos                 textos y bounds de la pantalla (uiautomator)
  toque X Y [MS]        contacto de MS milisegundos (por defecto 150)
  primera NOMBRE [--raices]  primera visualización sin perfil, grabada
  recuperacion NOMBRE CASO   rechazo del caso 01 o 05 con A01 a la vista
  pts VIDEO             PTS de cada cuadro, leídos con ffprobe

No guarda el UID, las direcciones ni la identidad de la red: solo cuentas.
"""
import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

PAQUETE = 'gt.cmartinez.baystream.t98acc'
ADB = Path(os.environ['LOCALAPPDATA']) / 'Android/Sdk/platform-tools/adb.exe'
SALIDA = Path(os.environ['TEMP']) / 't98acc-33404a5-21oct' / 'honor'
REMOTO = '/data/local/tmp/t98acc'


def adb(*args, check=True):
    r = subprocess.run([str(ADB), *args], capture_output=True, text=True,
                       encoding='utf-8', errors='replace')
    if check and r.returncode:
        raise RuntimeError(f'adb {args[:2]} falló: {r.stderr.strip()}')
    return r.stdout


def uid():
    filas = [l for l in adb('shell', 'pm', 'list', 'packages', '-U').splitlines()
             if l.startswith(f'package:{PAQUETE} ')]
    if len(filas) != 1:
        raise RuntimeError('El paquete no aparece una sola vez.')
    return re.search(r'\buid:(\d+)', filas[0]).group(1)


def utc():
    return datetime.now(timezone.utc).isoformat()


def guardar(nombre, datos):
    SALIDA.mkdir(parents=True, exist_ok=True)
    destino = SALIDA / nombre
    if destino.exists():
        raise FileExistsError(f'No sobrescribe {destino}')
    destino.write_text(json.dumps(datos, ensure_ascii=False, indent=1),
                       encoding='utf-8')
    return destino


def historial(texto, u):
    """Buckets del UID en «UID stats» y «UID tag stats»; nunca el mapa BPF."""
    seccion, propio, filas = None, False, []
    for linea in texto.splitlines():
        if re.match(r'^\S', linea):  # encabezado de primer nivel
            seccion = linea.strip().rstrip(':') if linea.strip() in (
                'UID stats:', 'UID tag stats:') else None
            propio = False
            continue
        if seccion is None:
            continue
        m = re.match(r'^  ident=.*\buid=(-?\d+) set=(\S+) tag=(\S+)', linea)
        if m:
            propio = m.group(1) == u
            conjunto, etiqueta = m.group(2), m.group(3)
            continue
        b = re.match(r'^\s+st=(\d+) rb=(\d+) rp=(\d+) tb=(\d+) tp=(\d+)', linea)
        if b and propio:
            filas.append({'seccion': seccion, 'set': conjunto, 'tag': etiqueta,
                          'st': int(b.group(1)), 'rb': int(b.group(2)),
                          'rp': int(b.group(3)), 'tb': int(b.group(4)),
                          'tp': int(b.group(5))})
    return filas


def sockets(u):
    cuentas, validas = {}, True
    for f in ('tcp', 'tcp6', 'udp', 'udp6'):
        r = subprocess.run([str(ADB), 'shell', 'cat', f'/proc/net/{f}'],
                           capture_output=True, text=True)
        lineas = r.stdout.splitlines()
        if r.returncode or not lineas or 'local_address' not in lineas[0]:
            validas = False
            continue
        cuentas[f] = sum(1 for l in lineas[1:] if len(l.split()) > 7
                         and l.split()[7] == u)
    return cuentas, validas


def red(etiqueta):
    u = uid()
    poll = adb('shell', 'dumpsys', 'netstats', '--poll', check=False)
    texto = adb('shell', 'dumpsys', 'netstats', 'detail')
    filas = historial(texto, u)
    cuentas, validas = sockets(u)
    ping = subprocess.run([str(ADB), 'shell', 'ping', '-c', '1', '-W', '2',
                           '1.1.1.1'], capture_output=True).returncode
    datos = {
        'utc': utc(), 'etiqueta': etiqueta, 'paquete': PAQUETE,
        'pollForzado': 'Forced poll' in poll,
        'buckets': len(filas),
        'bytesRecibidos': sum(f['rb'] for f in filas if f['seccion'] == 'UID stats'),
        'bytesEnviados': sum(f['tb'] for f in filas if f['seccion'] == 'UID stats'),
        'detalle': filas,
        'socketsDelUid': cuentas, 'consultaSocketsValida': validas,
        'modoAvion': adb('shell', 'settings', 'get', 'global',
                         'airplane_mode_on').strip(),
        'wifi': adb('shell', 'settings', 'get', 'global', 'wifi_on').strip(),
        'pingResponde': ping == 0,
    }
    print(guardar(f'red-{etiqueta}.json', datos))
    print(json.dumps({k: datos[k] for k in ('etiqueta', 'pollForzado', 'buckets',
          'bytesRecibidos', 'bytesEnviados', 'socketsDelUid', 'pingResponde')},
          ensure_ascii=False))


MUESTREO = r'''
u=__UID__; d=__DIR__; rm -rf $d; mkdir -p $d; i=0
date +%s.%N > $d/inicio
while [ ! -f $d/parar ]; do
  i=$((i+1))
  for f in tcp tcp6 udp udp6; do
    awk -v u=$u -v f=$f 'NR>1 && $8==u {print f}' /proc/net/$f
  done >> $d/filas
  echo $i > $d/vueltas
  sleep 0.1
done
date +%s.%N > $d/fin
'''


def muestreo(accion):
    if accion == 'iniciar':
        guion = MUESTREO.replace('__UID__', uid()).replace('__DIR__', REMOTO)
        local = SALIDA / 'muestreo.sh'
        SALIDA.mkdir(parents=True, exist_ok=True)
        local.write_text(guion, encoding='utf-8', newline='\n')
        adb('push', str(local), '/data/local/tmp/t98acc_muestreo.sh')
        local.unlink()
        subprocess.Popen([str(ADB), 'shell',
                          'nohup sh /data/local/tmp/t98acc_muestreo.sh '
                          '>/dev/null 2>&1 &'])
        time.sleep(1.5)
        print('muestreo iniciado:', adb('shell', 'cat', f'{REMOTO}/inicio').strip())
        return
    adb('shell', 'touch', f'{REMOTO}/parar')
    time.sleep(1.0)
    inicio = float(adb('shell', 'cat', f'{REMOTO}/inicio').strip())
    fin = float(adb('shell', 'cat', f'{REMOTO}/fin').strip())
    vueltas = int(adb('shell', 'cat', f'{REMOTO}/vueltas').strip())
    filas = adb('shell', f'cat {REMOTO}/filas 2>/dev/null', check=False).split()
    datos = {'utc': utc(), 'inicioDispositivo': inicio, 'finDispositivo': fin,
             'duracionS': round(fin - inicio, 3), 'vueltas': vueltas,
             'intervaloMedioS': round((fin - inicio) / max(vueltas, 1), 4),
             'filasDelUid': {f: filas.count(f) for f in ('tcp', 'tcp6', 'udp', 'udp6')}}
    adb('shell', 'rm', '-rf', REMOTO, '/data/local/tmp/t98acc_muestreo.sh')
    print(guardar(f'muestreo-{datetime.now():%H%M%S}.json', datos))
    print(json.dumps(datos, ensure_ascii=False))


def grabar(accion, nombre):
    remoto = f'/sdcard/Download/t98acc_{nombre}.mp4'
    if accion == 'iniciar':
        subprocess.Popen([str(ADB), 'shell', 'screenrecord', '--bit-rate',
                          '8000000', remoto])
        time.sleep(1.0)
        print('grabando', nombre, utc())
        return
    adb('shell', 'pkill', '-INT', 'screenrecord', check=False)
    time.sleep(2.0)
    destino = SALIDA / 'video' / f'{nombre}.mp4'
    destino.parent.mkdir(parents=True, exist_ok=True)
    if destino.exists():
        raise FileExistsError(destino)
    adb('pull', remoto, str(destino))
    adb('shell', 'rm', remoto)
    print(destino)


def nodos():
    xml = adb('exec-out', 'uiautomator', 'dump', '/dev/tty')
    for m in re.finditer(r'<node [^>]*?(?:text="([^"]*)")[^>]*?'
                         r'(?:content-desc="([^"]*)")[^>]*?'
                         r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', xml):
        texto = (m.group(1) or m.group(2) or '').replace('&#10;', ' | ')
        if texto:
            x1, y1, x2, y2 = map(int, m.group(3, 4, 5, 6))
            print(f'({(x1 + x2) // 2},{(y1 + y2) // 2}) {texto[:90]}')


def toque(x, y, ms=150):
    adb('shell', 'input', 'swipe', str(x), str(y), str(x), str(y), str(ms))


# Coordenadas del ensayo a 720×1600 (360 dp, letra 1.0), sin volcados durante
# la corrida: un volcado de uiautomator tarda segundos y se sumaría al tiempo.
ICONO = (105, 220)
SELECCIONAR = (360, 1266)
RAICES, DESCARGAS, CARPETA, A01 = (56, 112), (200, 568), (194, 543), (201, 523)
NO_LO_TENGO, CONFIRMAR, PLANO = (112, 394), (360, 1408), (198, 240)


def primera(nombre, raices):
    """Primera visualización sin perfil: seis pasos, con los toques visibles."""
    adb('shell', 'settings', 'put', 'system', 'show_touches', '1')
    pasos = []

    def paso(nombre_paso, punto, espera):
        pasos.append({'paso': nombre_paso, 'utcHost': utc()})
        toque(*punto, 150)
        time.sleep(espera)

    try:
        # Inicio deja el launcher en su primera página; el ícono está en la
        # última. Se llega deslizando y se comprueba antes de grabar.
        adb('shell', 'input', 'keyevent', '3')
        time.sleep(1.5)
        for _ in range(10):
            xml = adb('exec-out', 'uiautomator', 'dump', '/dev/tty')
            if re.search(r'BayStream T98acc"[^>]*bounds="\[20,122\]\[190,319\]"',
                         xml):
                break
            adb('shell', 'input', 'swipe', '600', '900', '120', '900', '250')
            time.sleep(1.2)
        else:
            raise RuntimeError('No apareció el ícono en su posición del ensayo.')
        grabar('iniciar', nombre)
        time.sleep(1.5)
        paso('1 icono', ICONO, 2.5)
        paso('2 Seleccionar archivo', SELECCIONAR, 2.0)
        if raices:  # navegación dentro del selector: sigue siendo el paso 3
            for punto, espera in ((RAICES, 1.0), (DESCARGAS, 1.5), (CARPETA, 1.2)):
                toque(*punto, 120)
                time.sleep(espera)
        paso('3 A01 en el selector', A01, 2.5)
        for _ in range(3):  # desplazamiento: no cuenta como paso (T-63 2)
            adb('shell', 'input', 'swipe', '360', '1300', '360', '200', '250')
            time.sleep(0.4)
        time.sleep(0.8)
        paso('4 No lo tengo', NO_LO_TENGO, 0.6)
        paso('5 Confirmar y ver el plano', CONFIRMAR, 2.0)
        paso('6 Plano', PLANO, 2.5)
    finally:
        grabar('detener', nombre)
        adb('shell', 'settings', 'delete', 'system', 'show_touches')
    print(guardar(f'primera-{nombre}.json', {'nombre': nombre, 'raices': raices,
                                              'pasos': pasos}))


# A 360 dp la acción de carga queda al final de la tira desplazable de la barra.
CARGAR = (576, 120)
ARCHIVOS = {'01': (323, 523), '05': (250, 669)}


def foco():
    return adb('shell', 'dumpsys', 'window').split('mCurrentFocus=', 1)[1] \
        .split('\n', 1)[0]


def recuperacion(nombre, caso):
    """Recuperación: con A01 a la vista, rechazo de un inválido y nueva carga."""
    if 'baystream.t98acc' not in foco():
        raise RuntimeError('La app t98acc no está al frente.')
    adb('shell', 'settings', 'put', 'system', 'show_touches', '1')
    eventos = []
    try:
        grabar('iniciar', nombre)
        time.sleep(1.5)
        toque(*CARGAR, 150)
        time.sleep(2.2)
        if 'documentsui' not in foco():
            raise RuntimeError('No abrió el selector.')
        eventos.append({'evento': 'toque archivo (confirmación)', 'utcHost': utc()})
        toque(*ARCHIVOS[caso], 200)
        time.sleep(1.0)  # espera fija: queda incluida en la medición
        eventos.append({'evento': 'toque Cargar archivo BAPLIE', 'utcHost': utc()})
        toque(*CARGAR, 150)
        time.sleep(2.5)
    finally:
        grabar('detener', nombre)
        adb('shell', 'settings', 'delete', 'system', 'show_touches')
    # Fuera del video: cerrar el selector sin elegir (Atrás solo en el selector).
    for _ in range(3):
        if 'documentsui' not in foco():
            break
        adb('shell', 'input', 'keyevent', '4')
        time.sleep(1.2)
    print(guardar(f'recuperacion-{nombre}.json', {'nombre': nombre, 'caso': caso,
          'eventos': eventos, 'focoFinal': 'baystream.t98acc' in foco()}))


def pts(video):
    r = subprocess.run(['ffprobe', '-v', 'error', '-select_streams', 'v:0',
                        '-show_entries', 'frame=pts_time', '-of', 'csv=p=0',
                        video], capture_output=True, text=True, check=True)
    return [float(v) for v in r.stdout.split()]


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    a = sys.argv[1:]
    if a[0] == 'red':
        red(a[1])
    elif a[0] == 'muestreo':
        muestreo(a[1])
    elif a[0] == 'grabar':
        grabar(a[1], a[2])
    elif a[0] == 'nodos':
        nodos()
    elif a[0] == 'toque':
        toque(*map(int, a[1:]))
    elif a[0] == 'primera':
        primera(a[1], '--raices' in a)
    elif a[0] == 'recuperacion':
        recuperacion(a[1], a[2])
    elif a[0] == 'pts':
        valores = pts(a[1])
        print(len(valores), valores[:3], valores[-3:])
    else:
        raise SystemExit(__doc__)
