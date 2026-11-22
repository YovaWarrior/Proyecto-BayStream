"""T-120, entrega 2 · Resume las corridas del banco (build/t120/e2/windows y
build/t120/e2/web): por corrida, el programa que cargó la Web, los errores de
Flutter, los textos que no caben y lo que mide cada escenario. Solo lee.

    python -X utf8 tool/t120e2_resumen.py build/t120/e2/windows/final-977 ...
"""
import json
import sys
from pathlib import Path


def principal():
    for carpeta in map(Path, sys.argv[1:]):
        pasos = [json.loads(l) for l in (carpeta / 'pasos.jsonl').read_text(encoding='utf-8-sig').splitlines() if l.strip()]
        print(f'### {carpeta.parent.name}/{carpeta.name}')
        nav = carpeta / 'navegador.json'
        if nav.exists():
            prog = json.loads(nav.read_text(encoding='utf-8'))['programa']
            print(f"  programa: cargado {prog['cargado_sha256'][:12]} servido {prog['servido_sha256'][:12]} "
                  f"es_el_que_se_sirve={prog['es_el_que_se_sirve']}")
        errores = [p for p in pasos if p['paso'] in ('error', 'error-de-flutter')]
        capturas = [p for p in pasos if p['paso'] == 'captura']
        cortados = sorted({t for p in capturas for t in p.get('textos_que_no_caben', [])})
        print(f'  capturas {len(capturas)}; errores {len(errores)} {[e.get("detalle") for e in errores][:3]}; '
              f'textos que no caben {cortados}')
        ciclo = [p['estado'] for p in pasos if p['paso'] == 'ciclo-de-vida']
        if ciclo:
            print(f'  ciclo de vida: {ciclo}')
        for p in capturas:
            a = p['archivo']
            if 'o1204_cuadro1' in a or 'o1204_asentado' in a or 'd9_corta' in a:
                print(f"  {a}: título a {p.get('titulo_desde_arriba_de_la_vista')} dp, "
                      f"{p.get('desplazamiento')} de {p.get('tope')}, vista {p.get('alto_de_la_vista')}, "
                      f"tarjetas {p.get('tarjetas')}")
            if 'o1205' in a:
                print(f"  {a}: ver_las_3_cargas={p.get('ver_las_3_cargas')} "
                      f"chips={ {k: v is not None for k, v in (p.get('chips_de_carga') or {}).items()} }")
            if 'repetida_' in a and p.get('textos_de_la_tarjeta'):
                print(f"  {a}: {' | '.join(p['textos_de_la_tarjeta'][:8])}")
        for p in pasos:
            if p['paso'] in ('pellizco', 'foco', 'repetida', 'gesto', 'cargado'):
                datos = {k: v for k, v in p.items() if k not in ('paso', 'ts')}
                print(f"  {p['paso']}: {datos}")


if __name__ == '__main__':
    principal()
