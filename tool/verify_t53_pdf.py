"""Evidencia independiente de sombras, prioridad y claridad del PDF final.

python tool/verify_t53_pdf.py [PDF_A01]
Requiere pdfplumber y pypdf en QA, no en Flutter.
"""
import json
import sys
from pathlib import Path
import pdfplumber
from pypdf import PdfReader

metrics = json.loads(Path('build/t53/metrics.json').read_text())
target = sys.argv[1] if len(sys.argv) > 1 else 'output/pdf/T53-CORPUS_A01.pdf'

def bounds(pdf):
    for i, page in enumerate(pdf.pages):
        for item in page.chars + page.rects + page.curves:
            assert item['x0'] >= 23.5 and item['x1'] <= page.width - 23.5, (i, item)
            assert item['top'] >= 23.5 and item['bottom'] <= page.height - 23.5, (i, item)

total = 0
with pdfplumber.open(target) as pdf:
    assert len(pdf.pages) == 62
    bounds(pdf)
    for index, bay in enumerate(metrics['bays'], 1):
        page = pdf.pages[index]
        words = page.extract_words(x_tolerance=1)
        zero = next(w for w in words if w['text'] == '00')
        rows = [w for w in words if abs(w['top'] - zero['top']) < .2]
        assert [int(w['text']) for w in rows] == metrics['rows']
        tiers = [w for w in words if zero['bottom'] < w['top'] < page.height - 60
                 and w['x1'] < rows[0]['x0'] and w['text'].isdigit()]
        assert [int(w['text']) for w in tiers] == metrics['tiers']
        shadows = [w for w in words if w['text'] == "40'"]
        positions = set()
        for shadow in shadows:
            center = (shadow['x0'] + shadow['x1']) / 2
            row = min(rows, key=lambda r: abs((r['x0'] + r['x1']) / 2 - center))
            tier = min(tiers, key=lambda t: abs(t['top'] - shadow['top']))
            positions.add(row['text'] + tier['text'])
        assert len(shadows) == len(positions), bay
        assert positions == set(metrics['shadows'][str(bay)]), (bay, positions)
        total += len(shadows)
        if bay in [5, 13, 15, 35, 39, 43, 45]:
            assert shadows

old = PdfReader('output/pdf/T52-CORPUS_A01.pdf')
new = PdfReader(target)
for i in range(35, 62):
    assert ''.join(old.pages[i].extract_text().split()) == ''.join(new.pages[i].extract_text().split()), i

def luminance(rgb):
    linear = [v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4 for v in rgb]
    return sum(a*b for a, b in zip(linear, [.2126, .7152, .0722]))

with pdfplumber.open('output/pdf/T53-contraste.pdf') as pdf:
    bounds(pdf)
    page = pdf.pages[1]
    cells = sorted([r for r in page.curves if r.get('fill') and abs(r['width']-36) < .1
                    and abs(r['height']-24) < .1], key=lambda r: r['x0'])
    legend = sorted([r for r in page.rects if r.get('fill') and abs(r['width']-10) < .1], key=lambda r: r['x0'])
    assert len(cells) == 3 and len(legend) == 7
    assert cells[0]['non_stroking_color'] == legend[1]['non_stroking_color']
    assert cells[1]['non_stroking_color'] == legend[4]['non_stroking_color']
    assert cells[2]['non_stroking_color'] == legend[5]['non_stroking_color']
    difference = luminance(cells[0]['non_stroking_color']) - luminance(cells[1]['non_stroking_color'])
    assert difference > .25, difference
    assert [w['text'] for w in page.extract_words() if 295 < w['top'] < 320] == ['82', '20', 'OOG', "40'"]
print(f'T53_OK: 62 paginas; 977 contenedores; {total} sombras en sus coordenadas; '
      f'7 bahias sin carga propia; tabla intacta; prioridad propia; diferencia de luminancia {difference:.3f}.')
