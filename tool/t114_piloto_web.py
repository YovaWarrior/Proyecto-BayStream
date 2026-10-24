"""T-114 · Candidata del piloto (10.28): el recorrido del piloto en la Web.

Con el Chrome de Playwright de tool/t114_primera_web.py (perfil temporal,
ventana visible, sin cuentas), sobre el banco r4 servido en 127.0.0.1, en una
vista de 1920 × 1080 con el tema oscuro (la oficina). Recorre, como una
persona y por la semántica de Flutter: el inicio; el plan de carga
(T100_CARGA.edi), que abre en previo y se confirma por la interfaz (la banda,
«Parámetros del buque», «No lo tengo», «Confirmar y ver el plano»); el
listado de la agencia (T100_LISTADO.xlsx) por su página; la llegada
(T100_LLEGADA.edi), que abre publicada por DESIGN.md 7.2; la descarga (Baja,
otra Baja y Deshacer, Paso con su pregunta); la carga (asignar un vacío por
OR, otro y Deshacer); el avance con «En vivo»; las alertas; el BAPLIE de
salida, la comparación con la llegada y su descarga; y «Más». Lo que necesita
cuenta (pedir cambio, la bandeja) no se recorre aquí. Cada paso es una captura
numerada en la salida (TEMP) y una línea de registro.tsv. Los archivos se
asignan al <input type=file> por el navegador, como en tool/t114_primera_web.py.

python tool/t114_piloto_web.py <salida en TEMP> --url http://127.0.0.1:5901/
"""
import argparse
import sys
import time
from datetime import datetime, timezone

from playwright.sync_api import sync_playwright

from t114_primera_web import abrir, desplazar_hasta, esperar, hay, limpiar, nuevo_contexto, pulsar
from t98_inventario import output_directory


class Recorrido:
    def __init__(self, page, out):
        self.page = page
        self.out = out
        self.paso = 0
        self.registro = ['paso\tarchivo\tnota\thora (UTC)']

    def foto(self, nombre, nota=''):
        self.paso += 1
        archivo = f'p{self.paso:02d}-{nombre}.png'
        time.sleep(0.6)
        self.page.screenshot(path=str(self.out / archivo))
        self.registro.append(f'{self.paso}\t{archivo}\t{nota}\t{datetime.now(timezone.utc).isoformat()}')
        print(archivo, nota)

    def guardar_registro(self):
        (self.out / 'registro.tsv').write_text('\n'.join(self.registro) + '\n', encoding='utf-8')


def preparar(page, ruta):
    """Deja el archivo listo para el siguiente <input type=file> (interceptado)."""
    return page.evaluate('(ruta) => window.t114Preparar(ruta)', ruta)


def destino(page, rotulo):
    """Un destino del riel o de la barra, o un segmento: su rótulo va seguido de
    «Pestaña n de m» en la semántica, así que el patrón ancla el principio y el
    final de la primera línea."""
    pulsar(page, f'^{rotulo}(?:\n|$)')
    time.sleep(1)


def volver(page):
    """El botón Atrás de la barra (en español, «Atrás»); si no está, el del navegador."""
    if hay(page, '^Atrás$'):
        pulsar(page, '^Atrás$')
    else:
        page.go_back()
    time.sleep(1)


def confirmar_como_la_oficina(r):
    page = r.page
    pulsar(page, '^Confirmar$')
    esperar(page, 'Parámetros del buque|^Cancelar$')
    time.sleep(0.8)
    r.foto('parametros-del-buque', 'la banda del previo abrió «Parámetros del buque»')
    desplazar_hasta(page, '^No lo tengo')
    pulsar(page, '^No lo tengo')
    time.sleep(0.8)
    r.foto('parametros-no-lo-tengo', '«No lo tengo» marcado a mano; no viene marcado')
    desplazar_hasta(page, '^Confirmar y ver')
    pulsar(page, '^Confirmar y ver')
    page.wait_for_function(
        "() => Array.from(document.querySelectorAll('flt-semantics')).some((n) => /Bah[ií]a/.test(n.getAttribute('aria-label') || n.textContent || '')) && "
        "!Array.from(document.querySelectorAll('flt-semantics')).some((n) => /Plano sin confirmar|confirma la escala|confirma el buque/.test(n.getAttribute('aria-label') || n.textContent || ''))",
        timeout=60000)
    time.sleep(1.5)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('salida')
    p.add_argument('--url', default='http://127.0.0.1:5901/')
    p.add_argument('--plan-de-carga', default='T100_CARGA.edi')
    p.add_argument('--listado', default='T100_LISTADO.xlsx')
    p.add_argument('--llegada', default='T100_LLEGADA.edi')
    p.add_argument('--ancho', type=int, default=1920)
    p.add_argument('--alto', type=int, default=1080)
    p.add_argument('--tema', choices=['dark', 'light'], default='dark')
    args = p.parse_args()
    if not args.url.startswith('http://127.0.0.1:'):
        raise ValueError('Solo el banco servido en 127.0.0.1.')
    out = output_directory(args.salida)
    if any(out.iterdir()):
        raise ValueError('No sobrescribir una corrida.')
    with sync_playwright() as pw:
        navegador = pw.chromium.launch(channel='chrome', headless=False,
                                       args=[f'--window-size={args.ancho + 40},{args.alto + 120}', '--window-position=0,0'])
        contexto, page = nuevo_contexto(navegador, args.tema, viewport={'width': args.ancho, 'height': args.alto})
        r = Recorrido(page, out)
        try:
            # Almacén limpio: sin perfiles ni viajes.
            abrir(page, args.url)
            limpiar(page)
            abrir(page, args.url)
            time.sleep(1)
            r.foto('inicio', 'el inicio sin viajes')
            # 1. El plan de carga: previo y confirmación por la interfaz.
            preparar(page, f'/t114/{args.plan_de_carga}')
            pulsar(page, '^Seleccionar archivo$')
            esperar(page, 'Plano sin confirmar|confirma la escala', 60)
            time.sleep(1.5)
            r.foto('plan-de-carga-en-previo', 'abre en previo con la banda; tres pasos')
            confirmar_como_la_oficina(r)
            r.foto('plan-de-carga-publicado', 'publicado en GTSTC; se queda en el Plano')
            # 2. El listado de la agencia, por su página.
            destino(page, 'Lista')
            time.sleep(1)
            desplazar_hasta(page, '^Listado de la agencia')
            pulsar(page, '^Listado de la agencia')
            esperar(page, 'Elegir listado')
            time.sleep(0.8)
            preparar(page, f'/t114/{args.listado}')
            pulsar(page, '^Elegir listado')
            esperar(page, '^Confirmar e importar')
            time.sleep(1)
            r.foto('listado-leido', 'el listado leído, con sus cuentas, antes de confirmar')
            pulsar(page, '^Confirmar e importar')
            esperar(page, 'Listado guardado|guardado en la operación', 30)
            r.foto('listado-importado', '«Listado guardado en la operación de GTSTC»')
            volver(page)
            esperar(page, '^Lista(?:\\n|$)')
            # 3. La llegada: por «Más → Cargar archivo BAPLIE»; abre publicada (7.2).
            preparar(page, f'/t114/{args.llegada}')
            destino(page, 'Más')
            time.sleep(1)
            pulsar(page, '^Cargar archivo BAPLIE')
            esperar(page, 'Escala GTSTC', 60)
            time.sleep(2)
            if hay(page, 'Plano sin confirmar|confirma la escala'):
                raise RuntimeError('La llegada abrió en previo: la escala confirmada no coincide.')
            destino(page, 'Plano')
            time.sleep(1)
            r.foto('llegada-publicada', 'la llegada abre publicada sin previo: la escala de siempre')
            # 4. La descarga.
            destino(page, 'Descarga')
            time.sleep(1.2)
            r.foto('descarga', 'modo Descarga: las celdas por bajar dicen «Baja»')
            pulsar(page, ', por descargar$')
            time.sleep(0.8)
            r.foto('baja-registrada', 'un toque: la celda sale en naranja y el aviso trae «Deshacer»')
            pulsar(page, ', por descargar$')
            time.sleep(0.8)
            r.foto('segunda-baja', 'otra Baja')
            destino(page, 'Deshacer')
            time.sleep(1)
            r.foto('baja-deshecha', '«Deshacer» del aviso: la celda vuelve a «Baja»')
            pulsar(page, 'de paso, sigue a bordo$')
            esperar(page, '^Registrar re')
            time.sleep(0.8)
            r.foto('paso-pregunta', 'Paso: la pregunta de la re‑estiba')
            pulsar(page, '^Registrar re')
            time.sleep(1)
            r.foto('reestiba-registrada', '«Re‑estiba registrada» con «Deshacer»')
            # 5. La carga.
            destino(page, 'Carga')
            time.sleep(1.2)
            r.foto('carga', 'modo Carga con el listado: OR en las celdas')
            desplazar_hasta(page, '^Asignar vacío')
            pulsar(page, '^Asignar vacío')
            esperar(page, 'Vacíos del listado')
            time.sleep(0.8)
            r.foto('vacios-del-listado', '«Vacíos del listado»: los OR de los vacíos con su tara')
            pulsar(page, r'^OR \d+ · ')
            esperar(page, '^Confirmar carga')
            time.sleep(0.8)
            r.foto('asignar-vacio', 'el formulario propone la celda; tara, hora y marchamo opcionales')
            pulsar(page, '^(?:Confirmar carga|Marcar su descarga y cargar)$')  # el botón, no el título
            esperar(page, 'Carga registrada|carga registradas', 30)
            time.sleep(0.8)
            r.foto('vacio-asignado', '«Carga registrada · OR N» con «Deshacer»; la celda en naranja')
            desplazar_hasta(page, '^Asignar vacío')
            pulsar(page, '^Asignar vacío')
            esperar(page, 'Vacíos del listado')
            time.sleep(0.8)
            pulsar(page, r'^OR \d+ · (?![\s\S]*Ya cargado)')
            esperar(page, '^Confirmar carga')
            time.sleep(0.8)
            pulsar(page, '^(?:Confirmar carga|Marcar su descarga y cargar)$')  # el botón, no el título
            esperar(page, 'Carga registrada|carga registradas', 30)
            time.sleep(0.8)
            r.foto('segundo-vacio-asignado', 'otro vacío asignado')
            destino(page, 'Deshacer')
            time.sleep(1.2)
            r.foto('vacio-deshecho', '«Deshacer»: el OR vuelve a estar pendiente')
            # 6. El avance y «En vivo».
            destino(page, 'Avance')
            time.sleep(1.5)
            r.foto('avance', '«Avance»: descarga, carga, re‑estibas y último movimiento')
            destino(page, 'Plano')
            time.sleep(1.2)
            r.foto('plano-con-en-vivo', 'el panel «En vivo» con los movimientos (el rol, nunca un nombre)')
            # 7. Las alertas de estiba.
            destino(page, 'Alertas')
            esperar(page, 'Alertas de estiba')
            time.sleep(1)
            r.foto('alertas-de-estiba', 'las alertas de estiba')
            volver(page)
            esperar(page, '^Plano(?:\\n|$)')
            # 8. El BAPLIE de salida, la comparación y la descarga del archivo.
            destino(page, 'Lista')
            time.sleep(1)
            desplazar_hasta(page, '^Generar BAPLIE de salida')
            pulsar(page, '^Generar BAPLIE de salida')
            esperar(page, 'contenedores a bordo en la salida')
            time.sleep(1)
            r.foto('baplie-de-salida', 'los a bordo en la salida, los pendientes y los cancelados')
            pulsar(page, '^Comparar con la llegada')
            esperar(page, 'Comparar BAPLIE')
            time.sleep(1.2)
            r.foto('comparar-con-la-llegada', 'la salida generada contra la llegada')
            volver(page)
            esperar(page, '^Guardar BAPLIE de salida')
            with page.expect_download(timeout=30000) as descarga:
                pulsar(page, '^Guardar BAPLIE de salida')
            archivo = descarga.value
            ruta_descarga = out / archivo.suggested_filename
            archivo.save_as(str(ruta_descarga))
            time.sleep(1)
            r.foto('baplie-guardado', f'«Exportación BAPLIE completada»; el navegador descargó {archivo.suggested_filename}')
            volver(page)
            esperar(page, '^Lista(?:\\n|$)')
            # 9. «Más».
            destino(page, 'Más')
            time.sleep(1)
            r.foto('mas', 'la hoja «Más»')
            page.keyboard.press('Escape')
            time.sleep(0.6)
        except Exception:
            # La pantalla en la que se detuvo, para diagnosticar.
            page.screenshot(path=str(out / 'p99-detenido.png'))
            raise
        finally:
            r.guardar_registro()
            navegador.close()
    print('capturas:', sorted(ruta.name for ruta in out.glob('*.png')))
    return 0


if __name__ == '__main__':
    sys.exit(main())
