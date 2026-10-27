"""T-122 · Corrección 2 (O2): ¿la Web lanza un error al arrancar?

Abre la Web servida en 127.0.0.1 en un perfil temporal de Chrome, sin tocar
nada, y recoge los `pageerror` y los `console.error` de los primeros segundos,
con su pila. Sirve para comparar el banco de T-122, el banco de T-99 en
`master` y el banco de T-99 en una copia de 7488321 (la 3.1.0).

python -X utf8 tool/t122_c2_error_web.py http://127.0.0.1:5902/ build/t122/c2/errores-t122.json
"""
import json
import sys
import time
from pathlib import Path

from playwright.sync_api import sync_playwright


def main(url, salida):
    errores = []
    with sync_playwright() as pw:
        nav = pw.chromium.launch(channel='chrome', headless=False, args=['--window-size=1960,1200'])
        ctx = nav.new_context(viewport={'width': 1920, 'height': 1080}, locale='es-GT')
        page = ctx.new_page()
        page.on('pageerror', lambda e: errores.append({'tipo': 'pageerror', 'mensaje': str(e.message), 'pila': e.stack}))
        page.on('console', lambda m: errores.append({'tipo': f'console.{m.type}', 'mensaje': m.text})
                if m.type in ('error', 'warning') else None)
        page.goto(url, wait_until='load')
        time.sleep(8)
        page.screenshot(path=str(Path(salida).with_suffix('.png')))
        ctx.close()
        nav.close()
    Path(salida).write_text(json.dumps({'url': url, 'errores': errores}, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'{len(errores)} errores/avisos en {url}')
    for e in errores:
        print('-', e['tipo'], e['mensaje'][:300])
        if e.get('pila'):
            print(e['pila'][:1500])
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv[1], sys.argv[2]))
