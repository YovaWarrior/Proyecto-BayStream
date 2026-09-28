"""Valida la evidencia de Chrome recibida por prepare_block4_web_probe.ps1.

Requiere los PDF/metrics de T-52 y pdfplumber/pypdf del entorno de QA.
No pertenece a la aplicacion ni agrega dependencias Flutter.
"""
import json
import runpy
from pathlib import Path

import pdfplumber

root = Path('build/block4_web')
results = [json.loads(line) for line in (root / 'results.jsonl').read_text(
    encoding='utf-8').splitlines()]
written, read = results[-2:]
assert written['status'] == 'WRITE_OK', written
assert read['status'] == 'RELOAD_READ_PDF_OK', read
assert written['run'] == read['run']
assert 'Chrome/' in read['userAgent']
assert read['containers'] == 977
assert [m['limit'] for m in read['measurements']] == [75000, None]
assert all(m['sockets'] == 50 and m['socketOrigin'] == 'proposedFromFile'
           and m['bays'] == 34 for m in read['measurements'])
pdf_path = root / 'T52-Chrome-A01.pdf'
assert pdf_path.stat().st_size == read['pdfBytes']
checks = runpy.run_path('tool/verify_t52_pdf.py')
metrics = checks['metrics']
with pdfplumber.open(pdf_path) as pdf:
    assert len(pdf.pages) == 62
    checks['check_bounds'](pdf)
    for i, bay in enumerate(metrics['bays'], 1):
        checks['check_grid'](pdf.pages[i], metrics['rows'],
                             metrics['deckTiers'] + metrics['holdTiers'])
        assert f'{bay:03}' in pdf.pages[i].extract_text()

print('CHROME_OK: recarga real; limites 75000/null; 50 tomas propuestas; '
      'viaje seco conserva tomas; PDF 977 contenedores, 34 bahias, 62 paginas; '
      'rejillas C-2/C-4 y margenes correctos.')
