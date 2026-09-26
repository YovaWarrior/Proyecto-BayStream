"""Comprueba el PDF renderizado, sin depender del árbol de widgets del generador.

Ejecutar después de tool/t52_corpus_pdf_test.dart. Requiere pdfplumber/pypdf
en el entorno de QA, nunca en la aplicación Flutter.
"""
import json
from pathlib import Path

import pdfplumber
from pypdf import PdfReader


def check_grid(page, rows, tiers):
    words = page.extract_words(x_tolerance=1)
    center = next(w for w in words if w['text'] == '00')
    header = [w for w in words if abs(w['top'] - center['top']) < 0.2]
    assert [w['text'] for w in header] == [f'{n:02}' for n in rows]
    labels = [w['text'] for w in words
              if w['top'] > center['bottom'] and w['top'] < page.height - 60
              and w['x1'] < header[0]['x0'] and w['text'].isdigit()]
    assert labels == [f'{n:02}' for n in tiers], labels


def check_bounds(pdf):
    for i, page in enumerate(pdf.pages):
        for char in page.chars:
            assert char['x0'] >= 23.5 and char['x1'] <= page.width - 23.5, (i, char)
            assert char['top'] >= 23.5 and char['bottom'] <= page.height - 23.5, (i, char)
        if i > 0:
            assert abs(page.width - 841.89) < 0.1
            assert abs(page.height - 595.28) < 0.1
        for shape in page.rects + page.curves:
            assert shape['x0'] >= 23.5 and shape['x1'] <= page.width - 23.5, (i, shape)
            assert shape['top'] >= 23.5 and shape['bottom'] <= page.height - 23.5, (i, shape)


metrics = json.loads(Path('build/t52/metrics.json').read_text())
with pdfplumber.open('output/pdf/T52-CORPUS_A01.pdf') as pdf:
    assert len(pdf.pages) == 62
    check_bounds(pdf)
    for i, bay in enumerate(metrics['bays'], 1):
        check_grid(pdf.pages[i], metrics['rows'],
                   metrics['deckTiers'] + metrics['holdTiers'])
        assert f'{bay:03}' in pdf.pages[i].extract_text()

with pdfplumber.open('output/pdf/T52-regresion.pdf') as pdf:
    check_bounds(pdf)
    for page in pdf.pages[1:3]:
        check_grid(page, [4, 2, 0, 1, 3], [92, 88, 84, 8, 4])
    text = PdfReader('output/pdf/T52-regresion.pdf').pages[1].extract_text()
    assert 'Tiers 84 y superiores' in text
    assert 'Tiers inferiores a 84' in text

with pdfplumber.open('output/pdf/T52-rejilla-amplia.pdf') as pdf:
    check_bounds(pdf)
    for page in pdf.pages[1:3]:
        check_grid(page, list(range(50, 0, -2)) + [0] + list(range(1, 50, 2)),
                   list(range(98, 83, -2)) + list(range(78, 1, -2)))

print('T52_PDF_OK: 62 paginas = portada + 34 bahias + 27 tabla; '
      '34 rejillas declaradas; C-2/C-4; frontera 84; '
      'rejilla 51x47; texto y trazos dentro de margenes en los tres PDF.')
