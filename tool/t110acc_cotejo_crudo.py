# Aceptacion de T-110 (Timonel): cotejo crudo de las bahias de cada BAPLIE.
#
# Lee el EDI sin pasar por el lector de BayStream y reconstruye, por su cuenta,
# de donde sale cada bahia que la regla de 10.87 pone en el selector:
#   - carga propia: grupos LOC+147 con EQD y numero de contenedor;
#   - reservas: grupos LOC+147 sin numero (sin EQD o con EQD vacio, T-69);
#   - sombra fisica: impares B-1 y B+1 de cada 40/45 que esta en una par B;
#   - proyeccion de dibujo: impares B-1 y B+1 de cada reserva de 40/45 en par.
# El tamano sale del primer caracter del tipo ISO 6346 (2 = 20, 4 = 40,
# L = 45, M = 48 pies); 40 o mas cuenta como largo.
#
# Uso: python -I tool/t110acc_cotejo_crudo.py <carpeta del corpus> <salida.json>
# El corpus no entra al repositorio; la salida va a %TEMP%.
import json
import os
import sys

LONG = {'4': 40, 'L': 45, 'M': 48}


def segments(text):
    """Separa los segmentos EDIFACT respetando el caracter de escape '?'."""
    out, current, escape = [], [], False
    for char in text.replace('\r', '').replace('\n', ''):
        if escape:
            current.append(char)
            escape = False
        elif char == '?':
            current.append(char)
            escape = True
        elif char == "'":
            out.append(''.join(current).strip())
            current = []
        else:
            current.append(char)
    if ''.join(current).strip():
        out.append(''.join(current).strip())
    return out


def elements(segment):
    parts, current, escape = [], [], False
    for char in segment:
        if escape:
            current.append(char)
            escape = False
        elif char == '?':
            escape = True
        elif char == '+':
            parts.append(''.join(current))
            current = []
        else:
            current.append(char)
    parts.append(''.join(current))
    return parts


def groups(text):
    """Un grupo por LOC+147: (posicion cruda, numero o None, tipo ISO o None)."""
    found, group = [], None
    for segment in segments(text):
        tag = segment[:3]
        if segment.startswith('LOC+147+'):
            if group is not None:
                found.append(group)
            position = elements(segment)[2].split(':')[0]
            group = {'position': position, 'number': None, 'iso': None, 'eqd': False}
        elif tag in ('UNT', 'UNZ') and group is not None:
            found.append(group)
            group = None
        elif segment.startswith('EQD+') and group is not None:
            parts = elements(segment)
            group['eqd'] = True
            number = parts[2].split(':')[0] if len(parts) > 2 else ''
            iso = parts[3].split(':')[0] if len(parts) > 3 else ''
            group['number'] = number or None
            group['iso'] = iso or None
    if group is not None:
        found.append(group)
    return found


def bay_of(position):
    if len(position) != 7 or not position.isdigit():
        return None
    return int(position[:3])


def analyse(path):
    with open(path, encoding='latin-1') as handle:
        text = handle.read()
    own, reserved = {}, {}
    shadow_sources, reserved_sources = {}, {}
    for group in groups(text):
        bay = bay_of(group['position'])
        if bay is None:
            continue
        is_long = (group['iso'] or ' ')[0] in LONG
        target = own if group['number'] else reserved
        target[bay] = target.get(bay, 0) + 1
        if bay % 2 == 0 and is_long:
            sources = shadow_sources if group['number'] else reserved_sources
            for neighbour in (bay - 1, bay + 1):
                if neighbour < 1:
                    continue
                sources.setdefault(neighbour, {})
                sources[neighbour][bay] = sources[neighbour].get(bay, 0) + 1
    rule = sorted(set(own) | set(reserved) | set(shadow_sources) | set(reserved_sources))
    before = sorted(set(own) | set(reserved))  # lo que armaba el lector antes de T-110
    added = [b for b in rule if b not in before]
    explained = {
        b: {
            'sombra_de': shadow_sources.get(b, {}),
            'proyeccion_de_reserva_de': reserved_sources.get(b, {}),
        }
        for b in added
    }
    return {
        'contenedores': sum(own.values()),
        'reservas': sum(reserved.values()),
        'bahias_carga_propia': sorted(own),
        'bahias_reservas': sorted(reserved),
        'antes_al_leer': len(before),
        'regla_10_87': len(rule),
        'bahias_regla': rule,
        'agregadas': added,
        'origen_de_agregadas': explained,
        'agregadas_sin_explicar': [b for b in added
                                   if not shadow_sources.get(b) and not reserved_sources.get(b)],
        'solo_por_reserva': [b for b in added if not shadow_sources.get(b)],
        'ocupadas_estadisticas': len(set(own) | set(shadow_sources)),
    }


def main():
    folder, output = sys.argv[1], sys.argv[2]
    result = {}
    for name in sorted(os.listdir(folder)):
        if name.startswith('CORPUS_') and name.endswith('.edi'):
            result[name] = analyse(os.path.join(folder, name))
    with open(output, 'w', encoding='utf-8') as handle:
        json.dump(result, handle, indent=1, ensure_ascii=False)
    for name, row in result.items():
        print(f"{name}: {row['contenedores']} cont., {row['reservas']} reservas, "
              f"antes {row['antes_al_leer']} -> regla {row['regla_10_87']} "
              f"(+{len(row['agregadas'])}: {', '.join(f'{b:03d}' for b in row['agregadas'])}); "
              f"sin explicar {row['agregadas_sin_explicar']}; "
              f"ocupadas {row['ocupadas_estadisticas']}")


if __name__ == '__main__':
    main()
