"""Aceptación de T-98 (10.104): los rechazos de Windows sin persona ni agente.

Carlos pidió que Timonel hiciera la toma solo (21-oct). Por cada archivo:
  1. con BayStream al frente, maximizada y sin aviso, pulsa «Cargar archivo
     BAPLIE», como una persona;
  2. en el selector nativo escribe la ruta en «Nombre» y lo confirma («Abrir»,
     por mensaje de Win32): ese cierre es el inicio de la medición;
  3. a la espera fija (1 s, como el Honor) pulsa otra vez el botón, si el
     aviso rojo está a la vista: la prueba de que la app responde;
  4. cancela el selector reabierto y espera a que el aviso desaparezca.
Se detiene ante cualquier estado inesperado. La medición sale del video.

python tool/t98acc_recuperacion_auto.py --pid N --carpeta DIR --salida <json TEMP> 01_x.edi 02_y.edi ...
python tool/t98acc_recuperacion_auto.py --pid N --prueba-cancelar   (abre y cancela, sin cargar)
"""
import argparse
import ctypes
import json
import os
import time
from ctypes import wintypes
from datetime import datetime, timezone
from pathlib import Path

import t98acc_sonda_windows as s

user32 = s.user32
user32.GetDlgItem.restype = wintypes.HWND
user32.GetDlgItem.argtypes = [wintypes.HWND, ctypes.c_int]
user32.FindWindowExW.restype = wintypes.HWND
user32.FindWindowExW.argtypes = [wintypes.HWND, wintypes.HWND, wintypes.LPCWSTR, wintypes.LPCWSTR]
user32.SendMessageW.argtypes = [wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPCWSTR]
user32.SendMessageW.restype = ctypes.c_ssize_t
user32.PostMessageW.argtypes = [wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM]

WM_SETTEXT, WM_GETTEXT, WM_COMMAND = 0x000C, 0x000D, 0x0111
IDOK, IDCANCEL, ID_NOMBRE = 1, 2, 0x47C


def selector(pid):
    hallados = []

    @ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
    def cada(hwnd, _):
        if user32.IsWindowVisible(hwnd):
            largo = user32.GetWindowTextLengthW(hwnd)
            texto = ctypes.create_unicode_buffer(largo + 1)
            user32.GetWindowTextW(hwnd, texto, largo + 1)
            if texto.value == s.TITULO and s.pid_de(hwnd) == pid:
                hallados.append(hwnd)
        return True

    user32.EnumWindows(cada, 0)
    return hallados[0] if len(hallados) == 1 else None


def campo_nombre(dialogo):
    combo_ex = user32.GetDlgItem(dialogo, ID_NOMBRE)
    combo = user32.FindWindowExW(combo_ex, None, 'ComboBox', None) if combo_ex else None
    return user32.FindWindowExW(combo, None, 'Edit', None) if combo else None


def texto_de(hwnd):
    buffer = ctypes.create_unicode_buffer(1024)
    ctypes.windll.user32.SendMessageW(hwnd, WM_GETTEXT, 1024, buffer)
    return buffer.value


def esperar_selector(pid, limite):
    hwnd = None

    def hay():
        nonlocal hwnd
        hwnd = selector(pid)
        return hwnd is not None

    return hwnd if s.esperar(hay, limite=limite) else None


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--pid', type=int, required=True)
    p.add_argument('--carpeta', type=Path)
    p.add_argument('--espera', type=float, default=1.0)
    p.add_argument('--salida', type=Path)
    p.add_argument('--prueba-cancelar', action='store_true')
    p.add_argument('--sin-sonda', action='store_true',
                   help='03 y 04: solo abre, confirma y anota; no pulsa después')
    p.add_argument('--carpeta-vista', type=Path,
                   help='antes de escribir la ruta, el selector entra en esta carpeta '
                        '(la del corpus en OneDrive, como en los videos de Codex)')
    p.add_argument('archivos', nargs='*')
    a = p.parse_args()
    user32.SetProcessDPIAware()

    def listo():
        return (s.baystream_lista(a.pid) and selector(a.pid) is None
                and not s.aviso_rojo())

    if a.prueba_cancelar:
        if not listo():
            raise SystemExit('BayStream no está lista (al frente, maximizada, sin selector ni aviso).')
        s.clic(*s.BOTON)
        dialogo = esperar_selector(a.pid, 5)
        if dialogo is None:
            raise SystemExit('No se abrió el selector.')
        time.sleep(1.5)
        campo = campo_nombre(dialogo)
        if campo:
            user32.SendMessageW(campo, WM_SETTEXT, 0, 'prueba-sin-cargar.edi')
        leido = texto_de(campo) if campo else None
        time.sleep(0.5)
        user32.PostMessageW(dialogo, WM_COMMAND, IDCANCEL, 0)
        cerrado = s.esperar(lambda: selector(a.pid) is None, limite=5)
        print(json.dumps({'campoNombre': bool(campo), 'textoEscrito': leido,
                          'cancelado': cerrado, 'avisoRojo': s.aviso_rojo()},
                         ensure_ascii=False))
        return

    temp = Path(os.environ['TEMP']).resolve()
    if a.salida is None or temp not in a.salida.resolve().parents or a.salida.exists():
        raise SystemExit('La salida tiene que ser nueva y estar bajo TEMP.')
    registro = {'pid': a.pid, 'boton': s.BOTON, 'esperaFijaS': a.espera,
                'carpeta': str(a.carpeta), 'inicioUtc': datetime.now(timezone.utc).isoformat(),
                'casos': []}

    def guardar():
        a.salida.write_text(json.dumps(registro, ensure_ascii=False, indent=1),
                            encoding='utf-8')

    for nombre in a.archivos:
        ruta = (a.carpeta / nombre).resolve()
        caso = {'archivo': nombre, 'eventos': []}
        registro['casos'].append(caso)

        def anota(evento, **extra):
            caso['eventos'].append({'evento': evento,
                                    'utc': datetime.now(timezone.utc).isoformat(),
                                    'perf': round(time.perf_counter(), 4), **extra})
            guardar()

        if not ruta.is_file():
            anota('alto: no existe el archivo')
            break
        s.esperar(lambda: not s.aviso_rojo(), limite=15)
        time.sleep(1.0)
        if not listo():
            anota('alto: BayStream no está lista')
            break
        s.clic(*s.BOTON)
        anota('clic para abrir el selector')
        dialogo = esperar_selector(a.pid, 5)
        if dialogo is None:
            anota('alto: no se abrió el selector')
            break
        time.sleep(1.5)  # que termine de dibujarse, como lo vería una persona
        campo = campo_nombre(dialogo)
        if not campo:
            anota('alto: no se encontró el campo «Nombre»')
            user32.PostMessageW(dialogo, WM_COMMAND, IDCANCEL, 0)
            break
        if a.carpeta_vista:  # una carpeta en «Nombre» + «Abrir» solo navega
            user32.SendMessageW(campo, WM_SETTEXT, 0, str(a.carpeta_vista))
            user32.PostMessageW(dialogo, WM_COMMAND, IDOK, 0)
            time.sleep(2.5)
            if selector(a.pid) != dialogo:
                anota('alto: el selector no siguió abierto al navegar')
                break
            anota('selector en la carpeta de vista')
            campo = campo_nombre(dialogo)
        user32.SendMessageW(campo, WM_SETTEXT, 0, str(ruta))
        if texto_de(campo) != str(ruta):
            anota('alto: el campo «Nombre» no quedó con la ruta')
            user32.PostMessageW(dialogo, WM_COMMAND, IDCANCEL, 0)
            break
        time.sleep(0.3)
        anota('confirmar («Abrir»)')
        user32.PostMessageW(dialogo, WM_COMMAND, IDOK, 0)
        if not s.esperar(lambda: selector(a.pid) is None, limite=5):
            anota('alto: el selector no se cerró')
            break
        cierre = time.perf_counter()
        rojo_al_cerrar = s.aviso_rojo()
        anota('selector cerrado', avisoRojoYaVisible=rojo_al_cerrar)
        if a.sin_sonda:  # una admisión: la pantalla siguiente la revisa una persona
            time.sleep(3.0)
            anota('tras 3 s', avisoRojo=s.aviso_rojo(),
                  baystreamAlFrente=s.baystream_lista(a.pid))
            break
        time.sleep(max(0.0, a.espera - (time.perf_counter() - cierre)))
        if rojo_al_cerrar or not s.aviso_rojo() or selector(a.pid) or not s.baystream_lista(a.pid):
            anota('sin sonda: estado no previsto tras el cierre',
                  avisoRojo=s.aviso_rojo(), selectorAbierto=selector(a.pid) is not None,
                  baystreamLista=s.baystream_lista(a.pid))
            break
        s.clic(*s.BOTON)
        anota('sonda: clic en «Cargar archivo BAPLIE»',
              retrasoDesdeCierreS=round(time.perf_counter() - cierre, 4))
        reabierto = esperar_selector(a.pid, 5)
        if reabierto is None:
            anota('el selector no se reabrió en 5 s')
            break
        anota('selector reabierto')
        time.sleep(1.0)
        user32.PostMessageW(reabierto, WM_COMMAND, IDCANCEL, 0)
        s.esperar(lambda: selector(a.pid) is None, limite=5)
        anota('selector cancelado')
        s.esperar(lambda: not s.aviso_rojo(), limite=15)
        anota('sin aviso a la vista')
    registro['finUtc'] = datetime.now(timezone.utc).isoformat()
    guardar()
    print(json.dumps([{'archivo': c['archivo'], 'ultimo': c['eventos'][-1]['evento']}
                      for c in registro['casos']], ensure_ascii=False))


if __name__ == '__main__':
    main()
