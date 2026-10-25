"""T-117 y T-118 · Corrección 1 de la entrega 1 (10.42, H2): Atrás con el
menú del modo abierto, en el emulador.

La reproducción de Codex (docs/t117/entrega1/aceptacion-codex.md, H2), en el
emulador (API 26, emulator-5554) con el banco r4 y los datos sintéticos de
T-100: el plano de llegada (T100_LLEGADA.edi) abre publicado en GTSTC
(DESIGN.md 7.2); se elige Descarga (en la banda del muelle o en el menú), se
abre el menú del modo y se pulsa Atrás del sistema. Lo esperado (14.6): el
primer Atrás cierra el menú y el plano se queda, sin la advertencia del doble
Atrás; el segundo es el primer toque del doble Atrás: advierte y no sale. En
claro y en oscuro (Parámetros → Tema).

Con --reiniciar-datos borra los datos del banco y publica antes el plan de
carga (T100_CARGA.edi) confirmando su perfil, como la oficina: deja la escala
GTSTC confirmada. Nunca el Honor; nunca «Nube y cuenta». Los PNG van a la
salida en TEMP, con `registro.jsonl` (lo que se vio en cada paso).

python tool/t117_correccion1_android.py <salida en TEMP> --reiniciar-datos
"""
import argparse
import json
import os
import time

import t98_honor_ui
from t114_capturas_android import adb, captura, esperar, observe, tap, tema
from t114_capturas_android_plano import cerrar_el_plano, entrar_al_plano, publicar_y_cerrar
from t98_inventario import output_directory
from t98_recuperacion_honor import position

AVISO_DE_SALIDA = r'Toca Atrás otra vez para volver al inicio'
# Las entradas del menú se anuncian con su rótulo y su línea («Número de
# orden, …»); «Número de orden» solo está en el menú.
MENU_ABIERTO = r'^Número de orden'
BOTON_DEL_MENU = r'^Modo del plano: '


def tocar(patron):
    rows = esperar(patron)
    tap(position(rows, rows[0][1]))


def elegir_descarga():
    """En la banda del muelle, «Descarga»; si no está, en el menú del modo."""
    banda = [fila for fila in observe(False, r'^Descarga') if not fila[1].startswith('Descarga:')]
    if banda:
        tap(position(banda, banda[0][1]))
    else:
        tocar(BOTON_DEL_MENU)
        time.sleep(1)
        tocar(r'^Descarga')
    time.sleep(1.5)


def atras(espera=1.2):
    adb('shell', 'input', 'keyevent', '4')
    time.sleep(espera)


def recorrido(out, tema_, registro):
    def paso(nombre, **mirar):
        # Primero la captura y después lo que dice uiautomator: el volcado
        # tarda, y la advertencia del doble Atrás dura 2 s (en la primera
        # corrida se capturó cuando ya se había ido).
        captura(out, f'{tema_}_{nombre}')
        fila = {'tema': tema_, 'paso': nombre,
                **{clave: bool(observe(False, patron)) for clave, patron in mirar.items()}}
        registro.write(json.dumps(fila, ensure_ascii=False) + '\n')
        registro.flush()
        print(json.dumps(fila, ensure_ascii=False))
        return fila

    elegir_descarga()
    paso('01-plano-descarga', menuAbierto=MENU_ABIERTO)
    tocar(BOTON_DEL_MENU)
    time.sleep(1.2)
    abierto = paso('02-menu-abierto', menuAbierto=MENU_ABIERTO)
    atras()
    primero = paso('03-primer-atras', advertencia=AVISO_DE_SALIDA,
                   menuAbierto=MENU_ABIERTO, enElPlano=BOTON_DEL_MENU)
    # Dentro de la ventana de 2 s: captura y volcado enseguida.
    atras(espera=0.3)
    segundo = paso('04-segundo-atras', advertencia=AVISO_DE_SALIDA,
                   enElPlano=BOTON_DEL_MENU)
    # Pasada la ventana de 2 s la advertencia se va y el plano sigue.
    time.sleep(3)
    return {
        'tema': tema_,
        'menuSeAbrio': abierto['menuAbierto'],
        'primerAtrasCierraElMenu': not primero['menuAbierto'],
        'primerAtrasNoAdvierte': not primero['advertencia'],
        'primerAtrasSigueEnElPlano': primero['enElPlano'],
        'segundoAtrasAdvierte': segundo['advertencia'],
        'segundoAtrasSigueEnElPlano': segundo['enElPlano'],
    }


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('salida')
    p.add_argument('--serial', default='emulator-5554')
    p.add_argument('--paquete', default='gt.cmartinez.baystream.r4')
    p.add_argument('--reiniciar-datos', action='store_true')
    p.add_argument('--publicado', default='T100_CARGA.edi')
    p.add_argument('--archivo', default='T100_LLEGADA.edi')
    args = p.parse_args()
    if args.serial != 'emulator-5554':
        raise ValueError('Solo el emulador (10.42): nunca el Honor.')
    os.environ['ANDROID_SERIAL'] = args.serial
    t98_honor_ui.PACKAGE = args.paquete
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    adb('shell', 'am', 'force-stop', args.paquete)
    if args.reiniciar_datos:
        adb('shell', 'pm', 'clear', args.paquete)
    resultados = []
    with (out / 'registro.jsonl').open('w', encoding='utf-8') as registro:
        adb('shell', 'settings', 'put', 'system', 'font_scale', '1.0')
        adb('shell', 'monkey', '-p', args.paquete, '-c', 'android.intent.category.LAUNCHER', '1')
        esperar(r'Seleccionar archivo')
        time.sleep(1.5)
        tema('Seguir al sistema')
        if args.reiniciar_datos:
            publicar_y_cerrar(args.publicado)
        for nombre, rotulo in (('claro', 'Claro'), ('oscuro', 'Oscuro')):
            tema(rotulo)
            entrar_al_plano(args.archivo)
            resultados.append(recorrido(out, nombre, registro))
            cerrar_el_plano()
        tema('Seguir al sistema')
    (out / 'resultado.json').write_text(
        json.dumps(resultados, ensure_ascii=False, indent=1), encoding='utf-8')
    print(json.dumps(resultados, ensure_ascii=False))
    ok = all(all(v for k, v in r.items() if k != 'tema') for r in resultados)
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
