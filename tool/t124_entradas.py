"""T-124 · Las entradas sintéticas del banco de capturas (tool/t124_main.dart)
que no trae el de T-122: el plano de llegada de T-100 (T100_LLEGADA.edi,
BUQUE MANUAL, contenedores MNLU) y el sintético de 977 de T-99
(T99_SINTETICO_977.edi, contenedores SNTU). Son carga de prueba, no viajes.

Las escribe en build/t124/entradas/t124_entradas.dart (fuera de Git), en
base64, para que el banco las entregue por el selector de archivos. Antes
comprueba que sean las sintéticas: el prefijo de los contenedores y la cuenta.

python -X utf8 tool/t124_entradas.py <T100_LLEGADA.edi> <T99_SINTETICO_977.edi>
"""
import base64
import re
import sys
from pathlib import Path

SALIDA = Path(__file__).resolve().parent.parent / 'build' / 't124' / 'entradas' / 't124_entradas.dart'


def leer(ruta, prefijo, cuenta):
    texto = Path(ruta).read_text(encoding='utf-8')
    numeros = re.findall(r"EQD\+CN\+([A-Z]{4})", texto)
    if len(numeros) != cuenta or set(numeros) != {prefijo}:
        raise SystemExit(f'{ruta}: no es la entrada sintética ({len(numeros)} {set(numeros)})')
    return base64.b64encode(texto.encode('ascii')).decode('ascii')


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    llegada = leer(sys.argv[1], 'MNLU', 60)
    sintetico = leer(sys.argv[2], 'SNTU', 977)
    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    SALIDA.write_text(
        '// Generado por tool/t124_entradas.py. Carga de prueba sintética, no viajes.\n'
        f"const t124T100LlegadaBase64 = '{llegada}';\n"
        f"const t124Sintetico977Base64 = '{sintetico}';\n",
        encoding='utf-8')
    print(SALIDA)


if __name__ == '__main__':
    main()
