"""Verifica pesos, posiciones y texto dentro de celdas; salidas a TEMP.

Uso: python tool/t102_verify_pdf.py RUTA_PDF [RUTA_MANIFEST]
Requiere PyMuPDF en el entorno de verificación, no en BayStream.
"""
import json
import sys
from pathlib import Path

import fitz


pdf_path = Path(sys.argv[1])
document = fitz.open(pdf_path)
if len(sys.argv) > 2:
    manifest = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
else:
    manifest = {"totalKg": 79700, "bays": [{"bay": 1, "cells": [
        {"position": "0010282", "tons": "28.7"},
        {"position": "0010284", "tons": None},
        {"position": "0010182", "tons": "21.0"},
        {"position": "0010102", "tons": "30.0"},
        {"position": "0010002", "tons": None},
        {"position": "0010202", "tons": "0.0"},
    ]}]}

checked = 0
assert f"{manifest['totalKg'] / 1000:.1f} t" in document[0].get_text()
for page_index, bay in enumerate(manifest["bays"], 1):
    page = document[page_index]
    words = page.get_text("words")
    cells = [d["rect"] for d in page.get_drawings()
             if 15 < d["rect"].width < 37 and 8 < d["rect"].height < 25
             and abs(d["width"] - .8) < .01]
    assert cells, "Sin rejilla"
    left = min(c.x0 for c in cells)
    top = min(c.y0 for c in cells)
    row_words = [w for w in words if w[4].isdigit() and w[1] < top
                 and w[0] >= left and w[1] > 50]
    tier_words = [w for w in words if w[4].isdigit() and w[2] < left
                  and w[1] >= top]
    for expected in bay["cells"]:
        position = expected["position"]
        row, tier = int(position[3:5]), int(position[5:7])
        row_word = next(w for w in row_words if int(w[4]) == row)
        tier_word = next(w for w in tier_words if int(w[4]) == tier)
        center = fitz.Point((row_word[0] + row_word[2]) / 2,
                            (tier_word[1] + tier_word[3]) / 2)
        rect = next(c for c in cells if center in c)
        inside = [w for w in words if fitz.Point((w[0]+w[2])/2, (w[1]+w[3])/2) in rect]
        weights = [w for w in inside if "." in w[4] and w[4].replace(".", "").isdigit()]
        assert [w[4] for w in weights] == ([] if expected["tons"] is None else [expected["tons"]]), position
        for word in inside:
            assert fitz.Rect(rect.x0-.5, rect.y0-.5, rect.x1+.5, rect.y1+.5).contains(fitz.Rect(word[:4])), "Texto fuera de celda"
        checked += 1

for index in {0, 1, max(range(1, len(manifest["bays"])+1), key=lambda i: len(manifest["bays"][i-1]["cells"]))}:
    document[index].get_pixmap(matrix=fitz.Matrix(2, 2)).save(str(pdf_path.with_suffix(f".page-{index+1}.png")))
print(f"PDF verificado: {checked} celdas, {len(document)} páginas, pesos y posiciones correctos, texto dentro de celda.")
