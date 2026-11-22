"""T-147, entrega 2 · Una revisión sintética de un listado de la agencia: la
misma hoja, con una nota en la columna MARCHAMO de una fila.

Sirve para mirar en el banco qué pasa cuando llega la revisión del listado que
cancela una fila ya cargada. Toma un `.xlsx` de FUERA del repositorio y
escribe la copia donde se le diga, también fuera: el caso no se copia al
repositorio.

    python -X utf8 tool/t147e2_listado_revisado.py --origen LISTADO.xlsx
        --salida %TEMP%\\t147-e2a\\caso\\LISTADO_REVISADO.xlsx --orden 1
        [--nota CANCELADO]

- La fila se busca por su número de orden (OR), en la columna A.
- La nota tiene que ser un texto que el libro ya use en alguna celda: se
  reutiliza su cadena compartida, y no se toca nada más del libro.
- Cambia una sola celda de la primera hoja. Lo dice al terminar.
"""
import argparse
import re
import sys
import zipfile
from pathlib import Path

AQUI = Path(__file__).resolve().parent.parent


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--origen', required=True)
    p.add_argument('--salida', required=True)
    p.add_argument('--orden', type=int, required=True)
    p.add_argument('--nota', default='CANCELADO')
    a = p.parse_args()
    for ruta in (a.origen, a.salida):
        if AQUI in Path(ruta).resolve().parents:
            sys.exit(f'{ruta} está dentro del repositorio: el caso va fuera.')

    with zipfile.ZipFile(a.origen) as libro:
        entradas = [(i, libro.read(i.filename)) for i in libro.infolist()]
    por_nombre = {i.filename: datos for i, datos in entradas}
    cadenas = re.findall(r'<si>(.*?)</si>',
                         por_nombre['xl/sharedStrings.xml'].decode('utf-8'),
                         flags=re.S)
    textos = [re.sub(r'<[^>]+>', '', c) for c in cadenas]
    if a.nota not in textos:
        sys.exit(f'El libro no usa «{a.nota}» en ninguna celda.')
    indice = textos.index(a.nota)

    hoja = por_nombre['xl/worksheets/sheet1.xml'].decode('utf-8')
    encabezado = re.search(
        r'<c r="([A-Z]+)(\d+)"[^>]*t="s"[^>]*><v>%d</v></c>' %
        textos.index('MARCHAMO'), hoja)
    if encabezado is None:
        sys.exit('No encontré la columna MARCHAMO.')
    columna = encabezado.group(1)
    fila = re.search(r'<c r="A(\d+)"[^>]*><v>%d</v></c>' % a.orden, hoja)
    if fila is None:
        sys.exit(f'No encontré el OR {a.orden} en la columna A.')
    numero = fila.group(1)
    celda = re.search(r'<c r="%s%s"( s="\d+")?[^>]*?(/>|>.*?</c>)' %
                      (columna, numero), hoja, flags=re.S)
    if celda is None:
        sys.exit(f'La fila {numero} no tiene la celda {columna}{numero}.')
    estilo = celda.group(1) or ''
    nueva = f'<c r="{columna}{numero}"{estilo} t="s"><v>{indice}</v></c>'
    hoja = hoja[:celda.start()] + nueva + hoja[celda.end():]

    Path(a.salida).parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(a.salida, 'w', zipfile.ZIP_DEFLATED) as copia:
        for info, datos in entradas:
            if info.filename == 'xl/worksheets/sheet1.xml':
                datos = hoja.encode('utf-8')
            copia.writestr(info, datos)
    print(f'OR {a.orden}: «{a.nota}» en {columna}{numero}. Una celda cambiada.')


if __name__ == '__main__':
    main()
