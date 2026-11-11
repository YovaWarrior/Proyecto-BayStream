"""T-142 · El service worker con las cabeceras nuevas, y quien ya tenía la app
en caché. Usa tool/t142_control_web.py (corriendo) y tool/t142_emulador.ps1.

    python tool/t142_sw.py

1. Con las cabeceras de hoy (variante «antes»), un perfil nuevo abre la app,
   el service worker se registra y toma la página; se recarga en línea para que
   guarde también la raíz. Sin CSP en el documento.
2. Se cambia el emulador a «despues», como hará el despliegue. El mismo perfil
   recarga en línea: ¿le llegan las cabeceras nuevas, o le sirve el SW la
   copia vieja?
3. Sin red (Playwright corta la red del navegador): la app recarga desde el
   SW y ¿con qué cabeceras?
4. Un perfil nuevo con «despues»: el SW se registra con la CSP puesta, y
   recarga sin red.
Resultado en build/t142/sw.json.
"""
import json
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from t142_control_web import SALIDA, cliente  # noqa: E402

RAIZ = Path(__file__).resolve().parent.parent
SW_JS = """async () => { const r = await navigator.serviceWorker.getRegistration();
  return { alcance: r && r.scope, activo: r && r.active && r.active.scriptURL.replace(location.origin, ''),
           controla: !!navigator.serviceWorker.controller, cachés: await caches.keys() }; }"""


def c(**orden):
    r = cliente(orden, 5943)
    if not r.get('ok'):
        raise RuntimeError(f'{orden}: {r.get("error")}')
    return r['resultado']


def emulador(variante):
    subprocess.run(['powershell', '-NoProfile', '-File', str(RAIZ / 'tool' / 't142_emulador.ps1'),
                    '-Variante', variante], check=True)


def cab(nav):
    return {k: nav['cabeceras'].get(k) is not None for k in
            ('content-security-policy', 'x-frame-options', 'permissions-policy', 'x-content-type-options')}


def esperar_sw(segundos=15):
    for _ in range(segundos * 2):
        sw = c(accion='js', codigo=SW_JS)
        if sw['controla']:
            return sw
        time.sleep(0.5)
    return sw


def main():
    r = {}
    emulador('antes')
    c(accion='limpiar_registro')
    nav = c(accion='abrir', perfil='sw', fresco=True)
    sw = esperar_sw()
    nav2 = c(accion='recargar')
    r['1_antes_primera_visita'] = {'cabeceras': cab(nav), 'sw': sw, 'recarga_desdeSW': nav2['desdeSW'],
                                   'rigeCSP': c(accion='sonda_csp')['rigeCSP']}

    emulador('despues')
    nav = c(accion='recargar')
    r['2_despliegue_recarga_en_linea'] = {'desdeSW': nav['desdeSW'], 'cabeceras': cab(nav),
                                          'rigeCSP': c(accion='sonda_csp')['rigeCSP'],
                                          'sw': c(accion='js', codigo=SW_JS)}

    c(accion='sin_conexion', sin=True)
    nav = c(accion='recargar')
    r['3_sin_red'] = {'pinta': nav['semanticos'] > 0, 'desdeSW': nav['desdeSW'], 'cabeceras': cab(nav),
                      'rigeCSP': c(accion='sonda_csp')['rigeCSP'],
                      'red': c(accion='js', codigo="() => fetch('/version.json', {cache: 'no-store'}).then(() => 'hay red', () => 'sin red')")}
    c(accion='sin_conexion', sin=False)

    c(accion='limpiar_registro')
    nav = c(accion='abrir', perfil='sw-nuevo', fresco=True)
    sw = esperar_sw()
    c(accion='recargar')
    c(accion='sin_conexion', sin=True)
    nav_off = c(accion='recargar')
    r['4_perfil_nuevo_con_csp'] = {'cabeceras': cab(nav), 'sw': sw, 'sinRed_pinta': nav_off['semanticos'] > 0,
                                   'sinRed_desdeSW': nav_off['desdeSW'], 'sinRed_cabeceras': cab(nav_off),
                                   'rigeCSP': c(accion='sonda_csp')['rigeCSP']}
    c(accion='sin_conexion', sin=False)
    inf = c(accion='informe', guardar='sw-registro')
    r['violaciones_que_bloquean'] = [v for v in inf['violaciones'] if v['disposicion'] == 'enforce'
                                     and not v['recurso'].startswith('https://t142-sonda.invalid')]
    r['erroresPagina'] = inf['erroresPagina']
    (SALIDA / 'sw.json').write_text(json.dumps(r, ensure_ascii=False, indent=1), encoding='utf-8')
    print(json.dumps(r, ensure_ascii=False, indent=1))


if __name__ == '__main__':
    main()
