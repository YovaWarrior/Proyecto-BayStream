"""T-114 · Paquete de íconos e ilustraciones (10.19): escribe
lib/core/design/bs_ilustraciones.dart a partir de design/ilustraciones/*.json,
los trazos que entregó Nube. La app no declara los JSON como assets (pubspec
solo suma la fuente, 10.19): las seis ilustraciones viajan como datos const de
Dart y BsIlustracion las pinta con CustomPainter.

Solo copia: las rutas (M, L, C y Z absolutos), los nombres de color de la
paleta (un nombre, o uno por tema), el grosor y el punteado. Los hex del bloque
`paleta` del JSON no se copian: la app resuelve los nombres con sus tokens
(colorDeIlustracion), y test/t114_ilustraciones_test.dart comprueba que dan el
mismo hex que el paquete declara.

python tool/bs_ilustraciones_generar.py            # escribe el .dart
python tool/bs_ilustraciones_generar.py --verificar  # compara con el .dart actual
"""
import argparse
import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ORIGEN = RAIZ / 'design' / 'ilustraciones'
DESTINO = RAIZ / 'lib' / 'core' / 'design' / 'bs_ilustraciones.dart'

# El orden y la constante de cada ilustración, y qué muestra (LEEME.md):
# es la etiqueta accesible por omisión.
ILUSTRACIONES = [
    ('inicio', 'inicio',
     'El corte de una bahía junto al muelle: la grúa pórtico iza el contenedor '
     'naranja y su celda queda vacía, punteada.'),
    ('vacio_recientes', 'vacioRecientes',
     'El muelle sin buque, con la grúa en reposo.'),
    ('vacio_busqueda', 'vacioBusqueda',
     'Una fila de celdas de cubierta sobre la tapa, con un hueco punteado.'),
    ('sin_conexion', 'sinConexion',
     'El buque de perfil, con la proa a la izquierda, y la nube en pausa.'),
    ('descarga_completa', 'descargaCompleta',
     'La bahía vacía, con las celdas punteadas, la tapa cerrada y la palomita de hecho.'),
    ('sin_alertas', 'sinAlertas',
     'La tapa de escotilla con la palomita de hecho.'),
]
COMANDOS = set('MLCZ')


def dart_cadena(texto):
    if "'" in texto or '\\' in texto or '$' in texto:
        raise ValueError(f'texto con comillas, barras o $: {texto!r}')
    return "'" + texto + "'"


def dart_numero(valor):
    if isinstance(valor, bool) or not isinstance(valor, (int, float)):
        raise ValueError(f'número esperado: {valor!r}')
    if isinstance(valor, int) or float(valor).is_integer():
        return str(int(valor))
    return repr(float(valor))


def dart_color(valor):
    if valor is None:
        return None
    if isinstance(valor, str):
        return f'BsColorDeIlustracion.fijo({dart_cadena(valor)})'
    if isinstance(valor, dict):
        claves = set(valor)
        if claves - {'claro', 'oscuro'}:
            raise ValueError(f'color por tema con claves raras: {valor!r}')
        claro = valor.get('claro')
        oscuro = valor.get('oscuro')
        if claro is None and oscuro is None:
            return None
        partes = []
        if claro is not None:
            partes.append(f'claro: {dart_cadena(claro)}')
        if oscuro is not None:
            partes.append(f'oscuro: {dart_cadena(oscuro)}')
        return 'BsColorDeIlustracion.porTema(' + ', '.join(partes) + ')'
    raise ValueError(f'color raro: {valor!r}')


def comprobar_ruta(ruta):
    letras = {c for c in ruta if c.isalpha()}
    if letras - COMANDOS:
        raise ValueError(f'comando no admitido en la ruta: {sorted(letras - COMANDOS)}')


def forma_dart(forma):
    comprobar_ruta(forma['ruta'])
    lineas = ['      BsFormaDeIlustracion(',
              f'        grupo: {dart_cadena(forma["grupo"])},',
              f'        ruta: {dart_cadena(forma["ruta"])},']
    relleno = dart_color(forma.get('relleno'))
    trazo = dart_color(forma.get('trazo'))
    if relleno:
        lineas.append(f'        relleno: {relleno},')
    if trazo:
        lineas.append(f'        trazo: {trazo},')
    grosor = forma.get('grosor', 0) or 0
    if grosor:
        lineas.append(f'        grosor: {dart_numero(grosor)},')
    punteado = forma.get('punteado')
    if punteado:
        lineas.append('        punteado: <double>['
                      + ', '.join(dart_numero(v) for v in punteado) + '],')
    lineas.append('      ),')
    return lineas


def generar():
    salida = [
        '// Generado por tool/bs_ilustraciones_generar.py desde',
        '// design/ilustraciones/*.json (el paquete de Nube, 10.19). No editar a mano:',
        '// se regenera con `python tool/bs_ilustraciones_generar.py`.',
        "import 'componentes/bs_ilustracion.dart';",
        '',
        '/// Las seis ilustraciones del paquete (`DESIGN.md` 13.7 y 13.9), como',
        '/// datos: cada una con su lienzo, su descripción (la etiqueta accesible por',
        '/// omisión) y sus formas, con los colores por nombre de la paleta. Las',
        '/// pinta `BsIlustracion`.',
        'abstract final class BsIlustraciones {',
    ]
    constantes = []
    for archivo, constante, descripcion in ILUSTRACIONES:
        datos = json.loads((ORIGEN / f'{archivo}.json').read_text(encoding='utf-8'))
        if datos['nombre'] != archivo:
            raise ValueError(f'{archivo}: el JSON se llama {datos["nombre"]}')
        if datos.get('fondo') != 'fondo':
            raise ValueError(f'{archivo}: fondo {datos.get("fondo")!r}')
        salida += [
            f'  /// `{archivo}`: {descripcion}',
            f'  static const BsDatosDeIlustracion {constante} = BsDatosDeIlustracion(',
            f'    nombre: {dart_cadena(archivo)},',
            f'    descripcion: {dart_cadena(descripcion)},',
            f'    ancho: {dart_numero(datos["ancho"])},',
            f'    alto: {dart_numero(datos["alto"])},',
            '    formas: <BsFormaDeIlustracion>[',
        ]
        for forma in datos['formas']:
            salida += forma_dart(forma)
        salida += ['    ],', '  );', '']
        constantes.append(constante)
    salida += [
        '  /// Las seis, en el orden del LEEME del paquete.',
        '  static const List<BsDatosDeIlustracion> todas = <BsDatosDeIlustracion>[',
    ]
    salida += [f'    {c},' for c in constantes]
    salida += ['  ];', '}', '']
    return '\n'.join(salida)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--verificar', action='store_true',
                    help='no escribe: compara con el archivo generado actual')
    args = ap.parse_args()
    texto = generar()
    if args.verificar:
        actual = DESTINO.read_text(encoding='utf-8') if DESTINO.exists() else ''
        if actual.replace('\r\n', '\n') != texto:
            print(f'{DESTINO} difiere de lo generado', file=sys.stderr)
            sys.exit(1)
        print('bs_ilustraciones.dart coincide con los JSON')
        return
    DESTINO.write_text(texto, encoding='utf-8', newline='\n')
    print(f'escrito {DESTINO} ({len(texto.splitlines())} líneas)')


if __name__ == '__main__':
    main()
