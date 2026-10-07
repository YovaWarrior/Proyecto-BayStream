"""T-73 · Genera los dos listados sintéticos de test/fixtures/.

Listado de exportación inventado, con la forma del de la agencia: filas de
título, encabezados por nombre (en otro orden que el real, para probar que se
ubican por nombre), separadores de agencia combinados con «CODIGO», un VGM con
decimales, una fila en blanco y dos filas que no se entienden. Ningún dato
real: buque, contenedores y agencias son ficticios.

Sale en dos formas, con los mismos datos:
- t73_listado_sintetico.xlsx: como LISTADO_A08.xlsx, escrito por un script
  (inlineStr sin sharedStrings.xml, PESO NETO sin valor guardado, enteros y
  rutas absolutas en workbook.xml.rels, como las escribe openpyxl).
- t73_listado_sintetico_excel.xlsx: como lo guarda Excel (revisión de Yov,
  7-oct): textos en sharedStrings.xml, números como double («1.0», «3900.0»),
  PESO NETO con su valor en caché, HORA como fracción del día con formato
  h:mm y rutas relativas en workbook.xml.rels. El neto en caché del OR 2 está desactualizado a propósito, como si se
  hubiera corregido el VGM sin recalcular: el lector debe recalcularlo igual.

Uso: python tool/t73_listado_sintetico.py
"""
import zipfile
from pathlib import Path
from xml.sax.saxutils import escape

FIXTURES = Path(__file__).resolve().parent.parent / 'test' / 'fixtures'
OUT = FIXTURES / 't73_listado_sintetico.xlsx'
OUT_EXCEL = FIXTURES / 't73_listado_sintetico_excel.xlsx'


def check_digit(owner_serial: str) -> str:
    """Dígito de control ISO 6346 de 4 letras y 6 cifras."""
    values = {}
    v = 10
    for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
        if v % 11 == 0:
            v += 1
        values[c] = v
        v += 1
    total = sum((values[c] if c.isalpha() else int(c)) * (2 ** i)
                for i, c in enumerate(owner_serial))
    return str(total % 11 % 10)


def box(owner_serial: str) -> str:
    return owner_serial + check_digit(owner_serial)


HEADERS = ['CONTENEDOR', 'OR', 'TIPO', 'POD', 'POT', 'OPR', 'TARA', 'PESO VGM',
           'PESO NETO', 'F', 'E', 'CONTENIDO', 'HORA', 'MARCHAMO', 'REEFER TEMP', 'ORIG']
COLS = 'ABCDEFGHIJKLMNOP'
WEIGHTS = {'TARA', 'PESO VGM', 'PESO NETO'}

# Forma Excel: neto en caché desactualizado. VGM − TARA da 5036.59.
STALE_NET = {2: 5000.0}

# (OR, contenedor, tipo, POD, línea, tara, VGM, F, E, contenido, hora, marchamo)
ROWS = [
    ('title', 'LISTADO DE EXPORTACIÓN - PRUEBA                 GTSTC'),
    ('blank',),
    ('title', 'M/V: BUQUE PRUEBA   V-T73'),
    ('header',),
    ('agency', 'AGENCIA A S.A.          CODIGO 11-111-111'),
    ('box', 1, box('TSTU000001'), '40HC', 'COMNG', 'LNX', 3900, 20800, 'X', None, 'GENERAL CARGO', None, None),
    ('box', 2, box('TSTU000002'), '20ST', 'JMKWL', 'LNX', 2230, 7266.59, 'X', None, 'GENERAL CARGO', '14:35', 'S-0001'),
    ('box', 3, box('TSTU000003'), '40HC', 'JMKCT', 'LNB', 3900, 20100, 'X', None,
     'DANGEROUS CARGO          IMO 9 UN 3082, 3077', None, None),
    ('blank',),
    ('agency', 'AGENCIA B S.A.          CODIGO 22-222-222'),
    ('box', 4, box('TSTU000004'), '20ST', 'PAMIT', 'LNX', 2185, None, None, 'X', 'VACIO EN PATIO', None, None),
    ('box', 5, box('TSTU000005'), '40RF', 'PAMIT', 'LNX', 4530, None, None, 'X', 'VACIO EN PATIO', None, None),
    ('box', 6, box('TSTU000006'), '40ST', 'PAMIT', 'LNX', 3700, None, None, 'X', 'VACIO EN PATIO', None, None),
    ('box', 7, box('TSTU000007'), '40HC', 'PAMIT', 'LNX', 3900, None, None, None, 'VACIO EN PATIO', None, None),
    ('title', 'TOTAL 8 CONTENEDORES'),
    ('box', 8, box('TSTU000008'), '40HC', 'JMKCT', 'LNB', 3900, 25000, 'X', None, 'GENERAL CARGO', None, None),
]


def sheet_xml(excel: bool):
    """La hoja y, en la forma Excel, la tabla de textos compartidos."""
    shared = []

    def text_cell(ref: str, text: str) -> str:
        if not excel:
            return f'<c r="{ref}" t="inlineStr"><is><t xml:space="preserve">{escape(text)}</t></is></c>'
        if text not in shared:
            shared.append(text)
        return f'<c r="{ref}" t="s"><v>{shared.index(text)}</v></c>'

    def number_cell(ref: str, value, style: int = 0) -> str:
        if not excel:
            return f'<c r="{ref}" t="n"><v>{value}</v></c>'
        return f'<c r="{ref}" s="{style}"><v>{float(value)!r}</v></c>'

    rows = []
    merges = []
    for index, row in enumerate(ROWS, start=1):
        kind = row[0]
        cells = []
        if kind in ('title', 'agency'):
            cells.append(text_cell(f'A{index}', row[1]))
            if kind == 'agency':
                merges.append(f'A{index}:P{index}')
        elif kind == 'header':
            cells = [text_cell(f'{COLS[i]}{index}', h) for i, h in enumerate(HEADERS)]
        elif kind == 'box':
            _, order, number, iso, pod, line, tare, vgm, full, empty, contents, hour, seal = row
            values = {
                'CONTENEDOR': number, 'OR': order, 'TIPO': iso, 'POD': pod, 'POT': pod,
                'OPR': line, 'TARA': tare, 'PESO VGM': vgm, 'F': full, 'E': empty,
                'CONTENIDO': contents, 'HORA': hour, 'MARCHAMO': seal, 'ORIG': 'GT',
            }
            for i, header in enumerate(HEADERS):
                ref = f'{COLS[i]}{index}'
                if header == 'PESO NETO':
                    if vgm is not None:
                        vgm_ref = f'{COLS[HEADERS.index("PESO VGM")]}{index}'
                        tare_ref = f'{COLS[HEADERS.index("TARA")]}{index}'
                        if excel:
                            cached = STALE_NET.get(order, round(vgm - tare, 2))
                            cells.append(f'<c r="{ref}" s="1"><f>{vgm_ref}-{tare_ref}</f>'
                                         f'<v>{float(cached)!r}</v></c>')
                        else:
                            # Fórmula sin <v>: sin valor guardado, como en LISTADO_A08.
                            cells.append(f'<c r="{ref}" t="n"><f>{vgm_ref}-{tare_ref}</f></c>')
                    continue
                value = values.get(header)
                if value is None:
                    continue
                if header == 'HORA' and excel:
                    hours, minutes = (int(x) for x in value.split(':'))
                    cells.append(number_cell(ref, (hours * 60 + minutes) / 1440, style=2))
                elif isinstance(value, (int, float)):
                    cells.append(number_cell(ref, value, style=1 if header in WEIGHTS else 0))
                else:
                    cells.append(text_cell(ref, value))
        rows.append(f'<row r="{index}">{"".join(cells)}</row>')
    merge_xml = (f'<mergeCells count="{len(merges)}">'
                 + ''.join(f'<mergeCell ref="{m}"/>' for m in merges) + '</mergeCells>')
    sheet = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
             '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
             f'<sheetData>{"".join(rows)}</sheetData>{merge_xml}</worksheet>')
    if not excel:
        return sheet, None
    strings = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
               '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
               f'count="{len(shared)}" uniqueCount="{len(shared)}">'
               + ''.join(f'<si><t xml:space="preserve">{escape(t)}</t></si>' for t in shared)
               + '</sst>')
    return sheet, strings


def content_types(excel: bool) -> str:
    shared = ('<Override PartName="/xl/sharedStrings.xml" ContentType="application/'
              'vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>') if excel else ''
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        f'{shared}</Types>')


def workbook_rels(excel: bool) -> str:
    # Excel escribe destinos relativos a xl/; openpyxl, absolutos desde la raíz.
    base = '' if excel else '/xl/'
    shared = ('<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/'
              '2006/relationships/sharedStrings" Target="sharedStrings.xml"/>') if excel else ''
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
        f'Target="{base}worksheets/sheet1.xml"/>'
        '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" '
        f'Target="{base}styles.xml"/>'
        f'{shared}</Relationships>')


RELS = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
    '</Relationships>')
WORKBOOK = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
    '<sheets><sheet name="OPS" sheetId="1" r:id="rId1"/></sheets>'
    '<calcPr calcId="191029" fullCalcOnLoad="1"/></workbook>')
# Estilos 1 y 2: formatos integrados «0.00» (pesos) y «h:mm» (HORA).
STYLES = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
    '<fonts count="1"><font><sz val="10"/><name val="Arial"/></font></fonts>'
    '<fills count="2"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill></fills>'
    '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
    '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
    '<cellXfs count="3"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
    '<xf numFmtId="2" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>'
    '<xf numFmtId="20" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/></cellXfs>'
    '</styleSheet>')


def write(out: Path, excel: bool) -> None:
    sheet, strings = sheet_xml(excel)
    parts = [
        ('[Content_Types].xml', content_types(excel)),
        ('_rels/.rels', RELS),
        ('xl/workbook.xml', WORKBOOK),
        ('xl/_rels/workbook.xml.rels', workbook_rels(excel)),
        ('xl/styles.xml', STYLES),
        ('xl/worksheets/sheet1.xml', sheet),
    ]
    if strings is not None:
        parts.append(('xl/sharedStrings.xml', strings))
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
        for name, data in parts:
            # Fecha fija: el archivo sale igual en cada ejecución.
            info = zipfile.ZipInfo(name, date_time=(2026, 10, 7, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(info, data)
    print(out)


def main() -> None:
    FIXTURES.mkdir(parents=True, exist_ok=True)
    write(OUT, excel=False)
    write(OUT_EXCEL, excel=True)
    for row in ROWS:
        if row[0] == 'box':
            print(row[1], row[2])


if __name__ == '__main__':
    main()
