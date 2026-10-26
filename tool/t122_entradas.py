"""T-122 · Las entradas sintéticas del banco de capturas de la 3.1.1.

Genera, en build/t122/entradas/, el plano de llegada de H1 (sale de PAMIT
rumbo a CRPMN con carga que baja en GTSTC), el plan de carga de H4 a H7
(sale de GTSTC: la bahía 22 ancha, con reservas y celdas libres; la 21 y la
23 de 20 pies; la 25 y la 26) y el listado de la agencia de H3 (dos agencias,
una sección «AGREGADOS», llenos que faltan a propósito y tres vacíos), y
escribe los tres como constantes en tool/t122_entradas.dart, que el banco
tool/t122_main.dart devuelve desde su selector de archivos.

Buque, viaje, contenedores, agencias y líneas son inventados (BUQUE PRUEBA
T122, TSTU…, AGENCIA A/B, LNX): nada del piloto. El listado se escribe con el
mismo escritor de tool/t73_listado_sintetico.py (sin openpyxl).

Uso: python -X utf8 tool/t122_entradas.py
"""
import base64
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import t73_listado_sintetico as t73  # noqa: E402

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / 'build' / 't122' / 'entradas'
DART = RAIZ / 'tool' / 't122_entradas.dart'

box = t73.box


def segmento(position, pol, pod, number, iso, kind, weight, line='LNX'):
    """Un contenedor (kind 5 lleno, 4 vacío) o, sin número, una reserva."""
    eqd = f'EQD+CN+{number}+{iso}+++{kind}' if number else f'EQD+CN++{iso}+++{kind}'
    mea = f'MEA+AAE+VGM+KGM:{weight}' if number else f'MEA+AAE+WT+KGM:{weight}'
    return f"LOC+147+{position}::5'{mea}'LOC+9+{pol}:139:6'LOC+11+{pod}:139:6'{eqd}'NAD+CA+{line}:172:20'"


def llegada():
    cabecera = ("UNH+1+BAPLIE:D:95B:UN:SMDG20'"
                "TDT+20+V1221+++NV2:172:20+++9001221:146:11:BUQUE PRUEBA T122'"
                "LOC+5+PAMIT:139:6'LOC+61+CRPMN:139:6'")
    carga = []
    n = 0
    for pos, pod in [('0020082', 'GTSTC'), ('0020182', 'GTSTC'), ('0020282', 'GTSTC'),
                     ('0020382', 'GTSTC'), ('0020482', 'GTSTC'), ('0020582', 'GTSTC'),
                     ('0020682', 'CRPMN'), ('0020084', 'CRPMN'), ('0020184', 'CRPMN'),
                     ('0020284', 'USHOU'), ('0020384', 'USHOU'),
                     ('0060082', 'GTSTC'), ('0060182', 'CRPMN')]:
        n += 1
        carga.append(segmento(pos, 'PAMIT', pod, box(f'TSTU0011{n:02d}'), '42G1', 5, 18000 + 500 * n))
    return cabecera + ''.join(carga)


# El plan de carga: (posición, número o None, ISO, lleno/reserva, peso)
CARGA = []
for row in range(0, 11):
    CARGA.append((f'022{row:02d}82', box(f'TSTU0220{row:02d}'), '45G1', 5, 20000 + 100 * row))
for row in range(0, 5):
    CARGA.append((f'022{row:02d}84', None, '45G1', 4, 3900))
for row in range(0, 5):
    CARGA.append((f'021{row:02d}82', box(f'TSTU0210{row:02d}'), '22G1', 5, 9000 + 100 * row))
CARGA.append(('0210084', None, '22G1', 4, 2185))
for row in range(0, 3):
    CARGA.append((f'023{row:02d}82', box(f'TSTU0230{row:02d}'), '22G1', 5, 8500 + 100 * row))
for row in range(0, 3):
    CARGA.append((f'026{row:02d}82', box(f'TSTU0260{row:02d}'), '45G1', 5, 21000 + 100 * row))
CARGA.append(('0250082', box('TSTU000250'), '22G1', 5, 7700))


def carga():
    cabecera = ("UNH+1+BAPLIE:D:95B:UN:SMDG20'"
                "TDT+20+V1222+++NV2:172:20+++9001221:146:11:BUQUE PRUEBA T122'"
                "LOC+5+GTSTC:139:6'LOC+61+PAMIT:139:6'")
    return cabecera + ''.join(segmento(p, 'GTSTC', 'PAMIT', n, iso, kind, w) for p, n, iso, kind, w in CARGA)


def numero(position):
    for p, n, _, _, _ in CARGA:
        if p == position:
            return n
    raise KeyError(position)


# (OR, contenedor, tipo, POD, línea, tara, VGM, F, E, contenido, hora, marchamo)
LISTADO = [
    ('title', 'LISTADO DE EXPORTACION - PRUEBA T-122            GTSTC'),
    ('blank',),
    ('title', 'M/V: BUQUE PRUEBA T122   V-1222'),
    ('header',),
    ('agency', 'AGENCIA A S.A.          CODIGO 11-111-111'),
    ('box', 1, numero('0220082'), '45G1', 'PAMIT', 'LNX', 3900, 20000, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 2, numero('0220182'), '45G1', 'PAMIT', 'LNX', 3900, 20100, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 3, numero('0220282'), '45G1', 'PAMIT', 'LNX', 3900, 20200, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 4, numero('0220382'), '45G1', 'PAMIT', 'LNX', 3900, 20300, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 5, numero('0220482'), '45G1', 'PAMIT', 'LNX', 3900, 20400, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 6, numero('0220582'), '45G1', 'PAMIT', 'LNX', 3900, 20500, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 7, numero('0210182'), '22G1', 'PAMIT', 'LNX', 2230, 9100, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 8, numero('0210282'), '22G1', 'PAMIT', 'LNX', 2230, 9200, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 9, numero('0210382'), '22G1', 'PAMIT', 'LNX', 2230, 9300, 'X', None, 'GENERAL CARGO', None, None),
    ('blank',),
    ('agency', 'AGENCIA B S.A.          CODIGO 22-222-222'),
    ('box', 12, box('TSTU001212'), '22G1', 'PAMIT', 'LNX', 2185, None, None, 'X', 'VACIO EN PATIO', None, None),
    ('box', 13, box('TSTU001213'), '45G1', 'PAMIT', 'LNX', 3900, None, None, 'X', 'VACIO EN PATIO', None, None),
    ('box', 14, box('TSTU001214'), '45G1', 'PAMIT', 'LNX', 3900, None, None, 'X', 'VACIO EN PATIO', None, None),
    ('title', 'AGREGADOS'),
    ('box', 21, numero('0220682'), '45G1', 'PAMIT', 'LNX', 3900, 20600, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 22, numero('0230082'), '22G1', 'PAMIT', 'LNX', 2230, 8500, 'X', None, 'GENERAL CARGO', None, None),
]


def dart(llegada_edi, carga_edi, listado_b64):
    def literal(texto):
        partes = [texto[i:i + 70] for i in range(0, len(texto), 70)]
        return '\n'.join(f'    "{p}"' for p in partes)
    return ('// GENERADO por tool/t122_entradas.py: las entradas sintéticas del banco\n'
            '// de capturas de T-122 (tool/t122_main.dart). No editar a mano.\n'
            '// Buque, viaje, contenedores, agencias y líneas inventados.\n\n'
            '/// H1 · Plano de llegada: sale de PAMIT rumbo a CRPMN con carga que baja en GTSTC.\n'
            f'const t122Llegada =\n{literal(llegada_edi)};\n\n'
            '/// H4 a H7 · Plan de carga que sale de GTSTC: la 22 ancha, la 21 y la 23 de 20.\n'
            f'const t122Carga =\n{literal(carga_edi)};\n\n'
            '/// H3 · El listado de la agencia (.xlsx en base64), con la sección «AGREGADOS».\n'
            f'const t122ListadoBase64 =\n{literal(listado_b64)};\n')


def main():
    SALIDA.mkdir(parents=True, exist_ok=True)
    llegada_edi = llegada()
    carga_edi = carga()
    (SALIDA / 'T122_LLEGADA.edi').write_text(llegada_edi, encoding='ascii', newline='')
    (SALIDA / 'T122_CARGA.edi').write_text(carga_edi, encoding='ascii', newline='')
    t73.ROWS = LISTADO
    listado = SALIDA / 'T122_LISTADO.xlsx'
    t73.write(listado, excel=False)
    b64 = base64.b64encode(listado.read_bytes()).decode('ascii')
    DART.write_text(dart(llegada_edi, carga_edi, b64), encoding='utf-8', newline='\n')
    print(SALIDA / 'T122_LLEGADA.edi', len(llegada_edi))
    print(SALIDA / 'T122_CARGA.edi', len(carga_edi))
    print(DART)
    for fila in LISTADO:
        if fila[0] == 'box':
            print(fila[1], fila[2])


if __name__ == '__main__':
    main()
