"""T-142 · El recorrido sin sesión de la Web 1.0.0, siempre el mismo, contra el
emulador de Hosting y a través de tool/t142_control_web.py (que debe estar
corriendo). Se corre con cada variante de cabeceras y deja su informe en
build/t142/flujo-<etiqueta>.json y sus capturas en build/t142/capturas/.

    python tool/t142_flujo.py despues
    python tool/t142_flujo.py inventario

Pasos (los del prompt de T-142): abrir el BAPLIE sintético T100_LLEGADA.edi
(BUQUE MANUAL, generado por tool/t100_sintetico.dart), el plano, cambiar de
bahía, la búsqueda escrita, Lista, Estadísticas, Orden de descarga, confirmar
el perfil, el botón de voz del selector de carga, Exportar PDF, CSV y JSON, y
la política de privacidad. Cada paso comprueba lo que se ve en la semántica.
"""
import json
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from t142_control_web import SALIDA, cliente  # noqa: E402

PUERTO = 5943
ARCHIVO = str((SALIDA / 'datos' / 'T100_LLEGADA.edi').resolve()).replace('\\', '/')


def c(**orden):
    r = cliente(orden, PUERTO)
    if not r.get('ok'):
        raise RuntimeError(f'{orden}: {r.get("error")}')
    return r['resultado']


def hay(patron):
    return c(accion='nodos', patron=patron) != []


def main(etiqueta):
    pasos = []

    def paso(nombre, comprobacion, captura=True):
        ok = bool(comprobacion)
        if captura:
            c(accion='captura', nombre=f'{etiqueta}-{len(pasos) + 1:02d}')
        pasos.append({'paso': nombre, 'ok': ok})
        print(('OK   ' if ok else 'FALLA'), nombre, flush=True)

    c(accion='limpiar_registro')
    abierto = c(accion='abrir', perfil=etiqueta, fresco=True)
    paso('abrir la app (primer cuadro y semántica)', abierto['semanticos'] > 0 and hay('^Seleccionar archivo$'))

    c(accion='archivo', patron='^Seleccionar archivo$', ruta=ARCHIVO, pausa=4)
    paso('abrir el BAPLIE sintético: el plano de BUQUE MANUAL', hay('^BUQUE MANUAL$') and hay('^Bahía 02, '))

    c(accion='pulsar', patron='^Bahía siguiente$', pausa=1.2)
    paso('cambiar de bahía (Bahía siguiente: 02 → 03)', hay('^Bahía 03$'))

    c(accion='pulsar', patron='^Buscar contenedor$')
    c(accion='teclear', texto='MNLU0000010', pausa=1.5)
    paso('búsqueda escrita: MNLU0000010 en 002-01-06', hay('Posición: Bahía 002, Fila 01, Nivel 06'))
    c(accion='pulsar', patron='^Limpiar$')
    c(accion='pulsar', patron='^Volver$')

    c(accion='pulsar', patron='^Lista\n', pausa=1.5)
    paso('Lista', hay('MNLU0000010'))

    c(accion='pulsar', patron='^Estadísticas\n', pausa=1.5)
    paso('Estadísticas', hay('contenedores a bordo') or hay('^60$'))

    c(accion='pulsar', patron='^Más\n')
    c(accion='pulsar', patron='^Orden de descarga$', pausa=2)
    paso('Orden de descarga', hay('^Puerto de descarga\n'))
    c(accion='pulsar', patron='^Atrás$')

    c(accion='pulsar', patron='^Plano\n')
    c(accion='pulsar', patron='^Confirmar$', pausa=2)
    c(accion='rueda', dy=3000)
    c(accion='rueda', dy=3000)
    c(accion='pulsar', patron='^No lo tengo\n')
    c(accion='pulsar', patron='^Confirmar y ver el plano$', pausa=3)
    paso('confirmar el perfil (sin límite de pila declarado)', hay('Escala PAMIT'))

    c(accion='pulsar', patron='^Carga[.] 30', pausa=1.5)
    c(accion='pulsar', patron='^OR / últimos dígitos$', pausa=1.5)
    antes = c(accion='permiso')
    c(accion='pulsar', patron='^Dictar búsqueda en español$', pausa=3)
    voz = c(accion='informe', resumen=True)['voz']
    despues = c(accion='permiso')
    paso('botón de voz: el navegador pide el micrófono y la política no lo bloquea',
         despues['politicaPermite'] is True and any(v['evento'] == 'start() llamado' for v in voz)
         and not any(v['evento'] == 'error' and v.get('error') == 'not-allowed' for v in voz))
    pasos[-1].update({'permisoAntes': antes, 'permisoDespues': despues, 'voz': voz})
    c(accion='tecla', teclas='Escape')

    for formato in ('PDF', 'CSV', 'JSON'):
        if not hay(f'^Exportar {formato}$'):
            c(accion='pulsar', patron='^Más\n')
        n = len(c(accion='informe', resumen=True)['descargas'])
        c(accion='pulsar', patron=f'^Exportar {formato}$', pausa=1)
        for _ in range(30):
            descargas = c(accion='informe', resumen=True)['descargas']
            if len(descargas) > n:
                break
            time.sleep(0.5)
        bajo = descargas[n:] and descargas[-1]['archivo'].lower().endswith(formato.lower())
        paso(f'Exportar {formato}', bajo and isinstance(descargas[-1]['bytes'], int) and descargas[-1]['bytes'] > 0)

    info = c(accion='privacidad', etiqueta=etiqueta)
    paso('política de privacidad (privacidad.html)', info['titulo'].startswith('Política de privacidad'), captura=False)

    datos = c(accion='informe', guardar=f'flujo-{etiqueta}')
    resumen = {'etiqueta': etiqueta, 'pasos': pasos,
               'violaciones': len(datos['violaciones']),
               'violacionesQueBloquean': len([v for v in datos['violaciones'] if v['disposicion'] == 'enforce']),
               'origenesExternos': datos['origenesExternos'], 'erroresPagina': datos['erroresPagina'],
               'consolaErrores': datos['consolaErrores'], 'descargas': datos['descargas']}
    (SALIDA / f'flujo-{etiqueta}-resumen.json').write_text(json.dumps(resumen, ensure_ascii=False, indent=1),
                                                         encoding='utf-8')
    print(json.dumps({k: v for k, v in resumen.items() if k != 'pasos'}, ensure_ascii=False, indent=1))
    return 0 if all(p['ok'] for p in pasos) else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
