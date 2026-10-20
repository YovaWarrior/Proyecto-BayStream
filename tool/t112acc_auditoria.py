"""Evidencia estática independiente y muestra reproducible de 20 mensajes."""
import csv
import hashlib
import json
import os
from pathlib import Path
import random
import re
import shutil
import subprocess

repo = Path(__file__).resolve().parents[1]
base = Path(os.environ['TEMP']) / 't112acc-33404a5'
out = repo / 'build/t112acc'
cierre = base / 'cierre'
padre = base / 'padre'
shutil.copytree(base / 'censos', out / 'censos', dirs_exist_ok=True)
rows = list(csv.DictReader((base / 'censos/mensajes.csv').open(encoding='utf-8-sig')))
sample = random.Random(11220261020).sample(rows, 20)

# Juicios del Capitán después de leer los literales, condiciones y envolturas.
# No se copian los campos causa/accion del censo de Timonel.
juicios = {
    'M151': ('No hay un único BAPLIE con UNB y UNH', 'Volver a importar el plan de carga'),
    'M026': ('Error interno al guardar el tema, o lectura/escritura local fallida', 'Reintentar y reiniciar si se repite'),
    'M195': ('La aprobación no coincide con la solicitud', 'Revisar en la bandeja de la oficina'),
    'M217': ('Error interno en la operación nombrada, o fallo del almacén', 'Reintentar y reiniciar si se repite'),
    'M108': ('La carga requiere un motivo escrito', 'Escribirlo para registrar'),
    'M100': ('La escala no tiene operación guardada', 'Abrir el plan y confirmar la escala'),
    'M214': ('El contenedor quedó en una reserva de otro grupo', 'Deshacer desde el detalle de la celda'),
    'M019': ('Editar parámetros no permite cambiar la identidad', 'Abrir el perfil correcto antes de editar'),
    'M014': ('El nombre no distingue estos buques', 'Pedir exportación con IMO o indicativo'),
    'M211': ('Se asignó una reserva cancelada', 'Deshacer el registro desde el detalle de la celda'),
    'M116': ('El peso previsto excede el límite del perfil', 'Escribir motivo o elegir otra pila'),
    'M017': ('No hay viaje para confirmar', 'Cargar primero un BAPLIE'),
    'M131': ('No hay plan de carga confirmado', 'Abrir el plan BAPLIE y confirmar escala'),
    'M193': ('El rechazo no cita una solicitud', 'Revisar en la bandeja de la oficina'),
    'M083': ('Deshacer exige motivo de hasta 300 caracteres', 'Escribirlo'),
    'M129': ('Archivo vacío o lectura sin bytes', 'Volver a elegir el Excel de la agencia'),
    'M096': ('La celda destino choca con otro objeto', 'Elegir otra celda'),
    'M070': ('Anular exige motivo', 'Escribirlo'),
    'M165': ('No hay códigos pegados', 'Pegar al menos uno'),
    'M102': ('La corrección exige movimiento vigente y motivo', 'Elegir la carga vigente y escribir motivo'),
}
assert {r['id'] for r in sample} == set(juicios)
evidence = []
for row in sample:
    causa, accion = juicios[row['id']]
    snippets = []
    for loc in row['ubicacion'].split(';'):
        m = re.search(r'(.+\.dart):([0-9,]+)', loc)
        if not m:
            continue
        rel = 'lib/features/vessel/' + m[1].strip()
        lines = (cierre / rel).read_text(encoding='utf-8').splitlines()
        for n in map(int, m[2].split(',')):
            snippets.append({'archivo': rel, 'linea': n,
                             'codigo': '\n'.join(f'{i+1}: {lines[i]}' for i in
                                                 range(max(0, n-3), min(len(lines), n+5)))})
    evidence.append({'id': row['id'], 'ubicacion': row['ubicacion'], 'texto': row['texto'],
                     'causa_independiente': causa, 'accion_independiente': accion,
                     'dictamen': 'PASA', 'codigo': snippets})
(out / 'muestra-independiente.json').write_text(json.dumps(
    {'semilla': 11220261020, 'metodo': 'random.Random(seed).sample(CSV en orden M001..M218, 20)',
     'mensajes': evidence}, ensure_ascii=False, indent=2), encoding='utf-8')

def git(*args):
    return subprocess.check_output(['git', *args], cwd=repo).decode('utf-8')

tests = git('diff', '--name-only', '--diff-filter=M', 'b1a0b5f^', 'b1a0b5f', '--', 'test/').splitlines()
counts = []
for rel in tests:
    before, after = (padre / rel).read_text(encoding='utf-8'), (cierre / rel).read_text(encoding='utf-8')
    counts.append({'archivo': rel, **{name: [len(re.findall(pattern, t)) for t in [before, after]]
                  for name, pattern in [('test', r'\btest(?:Widgets)?\s*\('),
                                        ('expect', r'\bexpect(?:Later)?\s*\('),
                                        ('skip', r'\bskip\s*:')]}})
assert len(counts) == 20
assert all(all(r[k][0] == r[k][1] for k in ['test', 'expect', 'skip']) for r in counts)
(out / 'pruebas-actualizadas.json').write_text(json.dumps(counts, indent=2), encoding='utf-8')

def sha(path):
    return hashlib.sha256(path.read_bytes().replace(b'\r\n', b'\n')).hexdigest()

product = {p.relative_to(cierre).as_posix(): sha(p) for p in (cierre / 'lib').rglob('*.dart')}
assert all(sha(repo / rel) == h for rel, h in product.items())
(out / 'producto-huellas.json').write_text(json.dumps(product, indent=2), encoding='utf-8')
assert git('diff', '--name-only', 'b1a0b5f', 'sprint3-cierre-2', '--',
           'lib/', 'test/', 'pubspec.yaml', 'pubspec.lock').strip() == ''
protected = ['lib/main.dart', 'lib/latency_test_screen.dart', 'lib/c3_reconciliation_screen.dart']
assert all(sha(padre / p) == sha(cierre / p) for p in protected)
for p in ['pubspec.yaml', 'pubspec.lock']:
    assert sha(repo / p) == sha(cierre / p)
print('20 mensajes contrastados; 20 archivos sin pérdida de test/expect ni skip; '
      f'{len(product)} archivos lib idénticos al cierre; protegidos intactos.')
