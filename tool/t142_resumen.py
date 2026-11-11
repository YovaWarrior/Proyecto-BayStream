"""T-142 · Resume un informe del recorrido (build/t142/flujo-<etiqueta>.json):
violaciones por directiva y recurso, y peticiones por tipo y origen."""
import collections
import json
import sys
from pathlib import Path

SALIDA = Path(__file__).resolve().parent.parent / 'build' / 't142'


def recurso(v):
    r = v['recurso']
    if r.startswith('http://127.0.0.1:5942'):
        r = r[len('http://127.0.0.1:5942'):].split('?')[0]
        partes = r.strip('/').split('/')
        return "'self' " + ('/' + partes[0] + ('/…' if len(partes) > 1 else '') if partes[0] else '/')
    return r[:60]


def main(etiqueta):
    d = json.loads((SALIDA / f'flujo-{etiqueta}.json').read_text(encoding='utf-8'))
    c = collections.Counter((v['directiva'], recurso(v), v['disposicion']) for v in d['violaciones'])
    print(f'## violaciones ({len(d["violaciones"])})')
    for (directiva, r, disp), n in sorted(c.items()):
        print(f'{n:4}  {directiva:16} {disp:8} {r}')
    t = collections.Counter()
    for p in d['peticiones']:
        u = p['url']
        origen = 'blob:' if u.startswith('blob:') else 'data:' if u.startswith('data:') else u.split('/')[2]
        t[(p['tipo'], origen, p['sw'])] += 1
    print(f'## peticiones ({len(d["peticiones"])})')
    for (tipo, origen, sw), n in sorted(t.items()):
        print(f'{n:4}  {tipo:10} {origen}{"  (del service worker)" if sw else ""}')
    print('## orígenes externos:', d['origenesExternos'] or 'ninguno')
    print('## fallidas:', len(d['fallidas']), '· errores de página:', len(d['erroresPagina']))
    print('## descargas:', [(x['archivo'], x['url'][:5], x['bytes']) for x in d['descargas']])


if __name__ == '__main__':
    main(sys.argv[1])
