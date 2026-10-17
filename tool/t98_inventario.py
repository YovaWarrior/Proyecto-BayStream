"""Censo conservador de literales y controles Dart, sin paquetes externos.

No confunde un censo de candidatos con una auditoría de idioma/M3 final.
Exporta cada literal (incluidos los indirectos), ubicación, huella y contexto;
las columnas de revisión quedan explícitas. Las marcas son indicios léxicos.
"""
import argparse
import csv
import hashlib
import json
import os
import re
from pathlib import Path


def output_directory(value):
    path = Path(value).resolve()
    root = Path(os.environ.get('TEMP', '/tmp')).resolve()
    if not path.is_relative_to(root) or path == root:
        raise ValueError('La salida debe estar bajo TEMP.')
    path.mkdir(parents=True, exist_ok=True)
    return path


def literals(source):
    """Saltos de línea, raw/triples y comentarios. Conserva interpolaciones."""
    pattern = re.compile(
        r'//[^\n]*|/\*[\s\S]*?\*/|'
        r'(?P<string>r?"""[\s\S]*?"""|r?\x27\x27\x27[\s\S]*?\x27\x27\x27|'
        r'r?"(?:\\.|[^"\\])*"|r?\x27(?:\\.|[^\x27\\])*\x27)', re.MULTILINE)
    for match in pattern.finditer(source):
        if match.group('string') is not None:
            yield match.start(), match.end(), match.group()


def sanitize(text):
    text = re.sub(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}', '[CORREO OMITIDO]', text)
    text = re.sub(r'(?i)(?:Bearer\s+)[\w.\-]+', '[TOKEN OMITIDO]', text)
    return text


CONTROLS = re.compile(
    r'\b(?:TextButton|FilledButton|ElevatedButton|OutlinedButton|IconButton|'
    r'FloatingActionButton|DropdownButton|DropdownMenu|PopupMenuButton|'
    r'Checkbox|Switch|Radio|Slider|RangeSlider|TextField|TextFormField|'
    r'FilterChip|ChoiceChip|ActionChip|InputChip|SegmentedButton|'
    r'NavigationBar|NavigationRail|NavigationDrawer|BottomNavigationBar|'
    r'TabBar|ListTile|CheckboxListTile|SwitchListTile|RadioListTile|'
    r'InkWell|GestureDetector|Draggable|DragTarget|InteractiveViewer|'
    r'MenuItemButton|SubmenuButton|SearchBar|SearchAnchor)\b(?:\.[\w]+)?\s*\(')


def write_csv(path, rows, columns):
    with path.open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=columns)
        writer.writeheader()
        writer.writerows(rows)


def inventory(root, output):
    strings, errors, controls, files = [], [], [], []
    for path in sorted((root / 'lib').rglob('*.dart')):
        source = path.read_text(encoding='utf-8-sig')
        relative = path.relative_to(root).as_posix()
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        files.append({'archivo': relative, 'sha256': digest})
        # Se conservan todos los literales: no se descartan constantes usadas
        # indirectamente, errores de dominio ni pantallas H5 congeladas.
        for start, end, value in literals(source):
            before = source[max(0, start - 240):start]
            row = {
                'archivo': relative, 'linea': source.count('\n', 0, start) + 1,
                'sha256': digest, 'literal': sanitize(value),
                'visible': 'PENDIENTE', 'espanol': 'PENDIENTE',
                'ruta_comprobada': '',
            }
            strings.append(row)
            if re.search(r'error|exception|failure|message|throw|snackbar|fallo|'
                         r'no se pudo|sin conex|inval|incorrect|rechaz',
                         before + value, re.IGNORECASE):
                errors.append({**row,
                    'causa_indicio': 'si' if re.search(
                        r'no |sin |error|falla|inval|vac[ií]o|incorrect|falta|'
                        r'no admit|deshabilit|demasiad', value, re.I) else 'no',
                    'accion_indicio': 'si' if re.search(
                        r'int[eé]nta|revisa|selecciona|pide|solicita|reinicia|'
                        r'espera|confirma|comprueba|habla|vuelve|corrige|elige', value, re.I) else 'no',
                    'segmento_indicio': ','.join(sorted(set(re.findall(
                        r'\b(?:UNB|UNH|BGM|DTM|TDT|LOC|EQD|MEA|UNT|UNZ|DGS)\b', value)))),
                    'parseo': 'PENDIENTE', 'causa': 'PENDIENTE',
                    'accion': 'PENDIENTE', 'segmento': 'PENDIENTE',
                })
        # Se eliminan comentarios y literales para no contar ejemplos como widgets.
        code = list(source)
        pattern = re.compile(r'//[^\n]*|/\*[\s\S]*?\*/', re.M)
        spans = [(m.start(), m.end()) for m in pattern.finditer(source)]
        spans.extend((a, b) for a, b, _ in literals(source))
        for a, b in spans:
            code[a:b] = ['\n' if c == '\n' else ' ' for c in code[a:b]]
        code = ''.join(code)
        for match in CONTROLS.finditer(code):
            line = code.count('\n', 0, match.start()) + 1
            controls.append({'pantalla_archivo': relative, 'linea': line,
                'sha256': digest, 'control': match.group().rstrip(' ('),
                'material': 'PENDIENTE', 'color_scheme': 'PENDIENTE',
                'incluido': 'PENDIENTE', 'motivo_exclusion': '',
                'ruta_comprobada': ''})
    write_csv(output / 'cadenas.csv', strings,
              ['archivo', 'linea', 'sha256', 'literal', 'visible', 'espanol', 'ruta_comprobada'])
    write_csv(output / 'errores.csv', errors, list(errors[0]))
    write_csv(output / 'material3.csv', controls,
              ['pantalla_archivo', 'linea', 'sha256', 'control', 'material',
               'color_scheme', 'incluido', 'motivo_exclusion', 'ruta_comprobada'])
    result = {'fase': 'A: censo de candidatos; no es medición',
              'literales': len(strings), 'errores_candidatos': len(errors),
              'controles_candidatos': len(controls), 'fuentes': files,
              'limitacion': 'Extractor léxico conservador; interpolaciones, '
              'concatenaciones y controles propios requieren revisión de código '
              'y recorrido UI. No calcula porcentajes de conformidad.'}
    (output / 'inventario.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('fuente', type=Path)
    parser.add_argument('salida')
    args = parser.parse_args()
    result = inventory(args.fuente.resolve(), output_directory(args.salida))
    print(json.dumps({k: v for k, v in result.items() if k != 'fuentes'}, ensure_ascii=True))


if __name__ == '__main__':
    main()
