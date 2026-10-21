"""T-100 · El listado de la agencia de la escala sintética del manual.

Toma las 30 cargas de cargas.json (tool/t100_sintetico.dart) y escribe el Excel
con la forma del listado real, reutilizando el escritor de
tool/t73_listado_sintetico.py sin cambiarlo. Ningún dato real: agencias, OR y
contenedores son ficticios. Sale solo en %TEMP%.

    python -I tool/t100_listado.py <carpeta de cargas.json en %TEMP%>
"""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import t73_listado_sintetico as t73  # noqa: E402

TIPOS = {'45G1': '40HC', '42G1': '40ST', '45R1': '40RF', '22G1': '20ST'}


def main() -> None:
    carpeta = Path(sys.argv[1]).resolve()
    temp = Path(os.environ['TEMP']).resolve()
    if temp not in carpeta.parents and carpeta != temp:
        raise SystemExit('La salida tiene que estar en %TEMP%.')
    datos = json.loads((carpeta / 'cargas.json').read_text(encoding='utf-8'))
    filas = [
        ('title', f'LISTADO DE EXPORTACIÓN - PRUEBA                 {datos["escala"]}'),
        ('blank',),
        ('title', f'M/V: {datos["buque"]}   V-{datos["viaje"]}'),
        ('header',),
    ]
    agencias = {'MNA': 'AGENCIA MANUAL A S.A.    CODIGO 10-100-100',
                'MNB': 'AGENCIA MANUAL B S.A.    CODIGO 20-200-200'}
    orden = 0
    for linea, titulo in agencias.items():
        filas.append(('agency', titulo))
        for c in datos['cargas']:
            if c['linea'] != linea:
                continue
            orden += 1
            contenido = 'VACIO EN PATIO' if not c['lleno'] else (
                f'DANGEROUS CARGO          IMO 9 UN {c["un"]}' if c['un'] else
                'REEFER CARGO' if c['temperatura'] is not None else 'GENERAL CARGO')
            tara = 4530 if c['iso'] == '45R1' else 3900 if c['iso'] == '45G1' else 3700
            filas.append(('box', orden, c['contenedor'], TIPOS[c['iso']], c['pod'], linea,
                          tara, (c['kg'] if c['lleno'] else None),
                          'X' if c['lleno'] else None, None if c['lleno'] else 'X',
                          contenido, None, None))
        filas.append(('blank',))
    filas.append(('title', f'TOTAL {orden} CONTENEDORES'))
    t73.ROWS = filas
    t73.STALE_NET = {}
    t73.write(carpeta / 'T100_LISTADO.xlsx', excel=True)
    print(f'{orden} filas en {len(agencias)} agencias')


if __name__ == '__main__':
    main()
