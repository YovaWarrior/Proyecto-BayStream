"""T-139 · Las figuras del manual de la 1.0.0: recorta, nombra y copia.

Toma las capturas crudas de %TEMP%\\t139\\capturas (Chrome de Playwright a
escala 2: la oficina a 1920 × 1080 y el muelle a 360 × 800) y las del asistente
de Windows que tomó Carlos (build/t137/capturas/carlos/claro de la carpeta de
T-137), recorta cada una a lo que el manual explica (las coordenadas van en
píxeles lógicos y se multiplican por la escala) y las deja en
docs/manual-1.0.0/ con el número de figura. Escribe build/t139/figuras.json con
el origen, el recorte, el tamaño y la huella SHA-256 de cada figura.

    python tool/t139_recortes.py
"""
import hashlib
import json
import os
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parents[1]
CRUDAS = Path(os.environ['TEMP']).resolve() / 't139' / 'capturas'
CARLOS = Path(r'C:\Proyectos\baystream-t137\build\t137\capturas\carlos\claro')
DESTINO = REPO / 'docs' / 'manual-1.0.0'
EVIDENCIA = REPO / 'build' / 't139'

# La ventana del asistente dentro de las capturas de Carlos, con su borde de 1 px y
# sin la sombra ni el Explorador de detrás: medida pixel a pixel en cada captura,
# porque la ventana se movió unos píxeles entre una y otra (revisión de Yov, 4-nov).
VENTANA_1 = (295, 50, 798, 615)
VENTANA_2 = (291, 50, 798, 615)
VENTANA_3 = (293, 50, 798, 615)

# (número orientativo, nombre, origen, carpeta, recorte en píxeles lógicos (x, y, ancho, alto) o None, escala)
# El número de figura definitivo es el orden en esta lista.
FIGURAS = [
    (1, 'instalador-bienvenida', 'Captura de pantalla 2026-11-03 215231.png', 'carlos', VENTANA_1, 1),
    (2, 'instalador-que-se-instala', 'Captura de pantalla 2026-11-03 215245.png', 'carlos', VENTANA_2, 1),
    (3, 'instalador-carpeta-y-accesos', 'Captura de pantalla 2026-11-03 215431.png', 'carlos', VENTANA_3, 1),
    (4, 'instalador-listo', 'Captura de pantalla 2026-11-03 215542.png', 'carlos', None, 1),
    # Android (la prueba interna de Play) y la Web: las toma Carlos; aquí solo cuentan el número.
    (5, 'instalar-android-play', None, 'carlos', None, 1),
    (6, 'instalar-web', None, 'carlos', None, 1),
    (7, 'inicio-oficina', 'f03-01-inicio.png', 'web', (0, 0, 1920, 600), 2),
    (8, 'inicio-muelle', 'f03-10-inicio-muelle.png', 'web', None, 2),
    (9, 'plano-previo', 'f03-02-previo.png', 'web', (0, 0, 1920, 790), 2),
    (10, 'parametros-arriba', 'f03-03-parametros-arriba.png', 'web', (0, 0, 1920, 560), 2),
    (11, 'parametros-escala', 'f03-04-escala.png', 'web', (0, 700, 1920, 380), 2),
    (12, 'parametros-limite-y-confirmar', 'f03-05-parametros-abajo.png', 'web', (0, 400, 1920, 680), 2),
    (13, 'plano-publicado', 'f03-06-plano-publicado.png', 'web', (0, 0, 1920, 700), 2),
    (14, 'inicio-recientes', 'f03-07-inicio-recientes.png', 'web', (0, 0, 1920, 560), 2),
    (15, 'volver-al-inicio', 'f03-13-volver-al-inicio.png', 'web', None, 1),
    (16, 'mas-oficina', 'f03-09-mas.png', 'web', (600, 350, 720, 730), 2),
    (18, 'colorear-tipo-de-vacio', 'f04-02-colorear-tipo-vacio.png', 'web', (100, 170, 1520, 510), 2),
    (19, 'detalle-de-la-celda', 'f04-03-detalle-celda.png', 'web', (560, 0, 1360, 720), 2),
    (20, 'zoom', 'f04-04-zoom.png', 'web', (100, 170, 1520, 880), 2),
    (21, 'plano-muelle', 'f07-08-muelle-plano.png', 'web', None, 2),
    (22, 'buscador-resultados', 'f05-02-buscador-resultados.png', 'web', (0, 0, 1920, 840), 2),
    (23, 'buscador-resaltado', 'f05-03-buscador-resaltado.png', 'web', (100, 170, 1520, 510), 2),
    (24, 'lista', 'f05-04-lista.png', 'web', (0, 0, 1920, 1080), 2),
    (25, 'estadisticas', 'f06-01-estadisticas.png', 'web', None, 2),
    (27, 'alertas-de-estiba', 'f06-04-alertas.png', 'web', (0, 0, 1920, 430), 2),
    (28, 'nube-sin-cuenta', 'f07-01-nube-sin-cuenta.png', 'web', (0, 0, 1920, 710), 2),
    (29, 'nube-publicada', 'f07-03-nube-publicada.png', 'web', (0, 0, 1920, 650), 2),
    (30, 'cabecera-oficina-publicada', 'f07-04-oficina-publicada.png', 'web', (0, 0, 1920, 170), 2),
    (31, 'muelle-unirse', 'f07-06-muelle-unirse.png', 'web', (0, 0, 360, 480), 2),
    (32, 'muelle-descarga', 'f07-10-muelle-descarga.png', 'web', None, 2),
    (33, 'muelle-descargado', 'f07-11-muelle-descargado.png', 'web', None, 2),
    (35, 'avance-oficina', 'f07-15-oficina-avance.png', 'web', (0, 0, 1920, 880), 2),
    (36, 'plan-de-carga-previo', 'f07-16-oficina-plan-previo.png', 'web', (0, 0, 1920, 170), 2),
    (37, 'agregar-plan-dialogo', 'f07-17-oficina-agregar-plan.png', 'web', (700, 415, 520, 300), 2),
    (38, 'listado-leido', 'f07-19-listado-leido.png', 'web', None, 2),
    (39, 'numero-de-orden-oficina', 'f07-23-oficina-numero-orden.png', 'web', (100, 60, 1520, 620), 2),
    (40, 'muelle-carga', 'f07-22-muelle-carga.png', 'web', None, 2),
    (41, 'muelle-confirmar-carga', 'f07-26-muelle-confirmar-carga.png', 'web', (40, 30, 280, 740), 2),
    (42, 'muelle-celda-ocupada', 'f07-32-muelle-celda-ocupada.png', 'web', (40, 20, 280, 760), 2),
    (43, 'muelle-sin-conexion', 'f07-31-muelle-sin-conexion.png', 'web', (0, 0, 360, 300), 2),
    (44, 'operacion-cerrada', 'f07-34-operacion-cerrada.png', 'web', (0, 0, 1920, 500), 2),
    (45, 'baplie-de-salida', 'f08-01-baplie-salida.png', 'web', None, 2),
    (47, 'parametros-tema', 'f09-01-parametros.png', 'web', (0, 0, 1920, 480), 2),
    (48, 'plano-oscuro', 'f09-04-plano-oscuro.png', 'web', None, 2),
    (49, 'aviso-no-es-baplie', 'f10-01-error-no-baplie.png', 'web', (100, 1000, 1520, 80), 2),
]


def sha256(ruta):
    return hashlib.sha256(ruta.read_bytes()).hexdigest()


def main():
    DESTINO.mkdir(parents=True, exist_ok=True)
    EVIDENCIA.mkdir(parents=True, exist_ok=True)
    inventario = []
    for numero, (_, nombre, origen, carpeta, recorte, escala) in enumerate(FIGURAS, 1):
        if origen is None:
            inventario.append({'figura': numero, 'archivo': f'{numero:02d}-{nombre}.png',
                               'origen': 'la toma Carlos (marcador en el manual)', 'pendiente': True})
            print(f'{numero:02d}-{nombre}.png: pendiente (la toma Carlos)')
            continue
        fuente = (CARLOS if carpeta == 'carlos' else CRUDAS) / origen
        imagen = Image.open(fuente)
        if recorte:
            x, y, w, h = (v * escala for v in recorte)
            imagen = imagen.crop((x, y, min(x + w, imagen.width), min(y + h, imagen.height)))
        destino = DESTINO / f'{numero:02d}-{nombre}.png'
        imagen.save(destino, optimize=True)
        inventario.append({
            'figura': numero, 'archivo': destino.name,
            'origen': ('build/t137/capturas/carlos/claro/' if carpeta == 'carlos' else '%TEMP%/t139/capturas/') + origen,
            'tomada_por': 'Carlos (T-137, 3-nov)' if carpeta == 'carlos' else 'Timonel (banco Web, Chrome de Playwright)',
            'recorte_logico': recorte, 'escala': escala,
            'ancho': imagen.width, 'alto': imagen.height,
            'bytes': destino.stat().st_size, 'sha256': sha256(destino),
        })
        print(f'{destino.name}: {imagen.width}×{imagen.height}, {destino.stat().st_size} bytes')
    (EVIDENCIA / 'figuras.json').write_text(json.dumps(inventario, ensure_ascii=False, indent=2), encoding='utf-8')
    total = sum(f.get('bytes', 0) for f in inventario)
    print(f'{len(inventario)} figuras, {total / 1e6:.1f} MB')


if __name__ == '__main__':
    main()
