#!/usr/bin/env python3
"""Rehace todo el paquete de íconos e ilustraciones de BayStream desde sus fuentes, y lo verifica.

Uso, desde la raíz del repositorio:

    python -m pip install resvg-py==0.5.0 Pillow fonttools skia-pathops freetype-py
    python design/iconos/generar.py               # escribe todo y lo verifica
    python design/iconos/generar.py --verificar   # solo comprueba que lo escrito coincide con las fuentes
    python design/iconos/generar.py --salida X    # escribe en otra carpeta, con la misma estructura

Fuentes: design/iconos/fuentes/ (el DSL, los ayudantes, iconos.py con los 32 e insignias.py con las 4) y
design/ilustraciones/fuentes/ (el DSL de ilustraciones, plantilla.py y un archivo por ilustración).
Salidas: design/iconos/svg/, design/iconos/svg_insignias/, assets/fonts/bs_iconos/BayStreamIconos.ttf,
design/iconos/codigos.json, design/iconos/vista-previa.png, design/iconos/comprobacion-fuente.png,
design/ilustraciones/<nombre>_{claro,oscuro}.svg, <nombre>.json, design/ilustraciones/vista-previa.png y
design/iconos/LEEME.md (desde fuentes/LEEME.plantilla.md, con las tablas de comprobación y los SHA-256).
design/iconos/conceptos.png es la captura de la página de conceptos: no se regenera, solo se suma al LEEME.

Corriéndolo dos veces sobre una carpeta vacía salen archivos idénticos byte a byte (Python 3.13,
Pillow 12.3, resvg-py 0.5.0, fontTools 4.67, skia-pathops 0.8, freetype-py 2.13). Con otras versiones los
PNG pueden comprimirse distinto y cambiar su SHA-256 sin cambiar un píxel.
"""
import argparse, hashlib, importlib.util, os, shutil, sys, tempfile
from pathlib import Path

AQUI = Path(__file__).resolve().parent                 # design/iconos
RAIZ = AQUI.parent.parent                              # raíz del repositorio
FUENTES = AQUI / 'fuentes'
FUENTES_ILUS = RAIZ / 'design' / 'ilustraciones' / 'fuentes'
for p in (str(FUENTES), str(FUENTES_ILUS)):
    if p not in sys.path:
        sys.path.insert(0, p)

try:
    import resvg_py, PIL, fontTools, pathops, freetype  # noqa: F401
except ImportError as e:  # pragma: no cover
    sys.exit(f'Falta una dependencia ({e.name}). Instala con: python -m pip install resvg-py==0.5.0 Pillow fonttools skia-pathops freetype-py')

import fuente as modulo_fuente
import verificar_fuente, exportar_json, vista_previa
from dsl import cargar as cargar_iconos, REJILLA
from ilus import cargar as cargar_ilus

ILUSTRACIONES = ['inicio', 'vacio_recientes', 'vacio_busqueda', 'sin_conexion', 'descarga_completa', 'sin_alertas']
PAREJAS = ['contenedor_20:contenedor_40', 'contenedor_40:contenedor_45', 'contenedor_20:contenedor_45', 'vacio:contenedor_40',
           'refrigerado:contenedor_40', 'tanque:contenedor_40', 'plataforma:techo_abierto', 'fuera_de_medida:contenedor_40',
           'bahia:tapa_escotilla', 'peso_pila:limite_apilamiento', 'peso_pila:vgm', 'limite_apilamiento:vgm', 'bahia:buque',
           'descarga:carga', 'descarga:reestiba', 'carga:reestiba', 'descarga:baplie_salida', 'carga:baplie', 'pedir_cambio:reestiba',
           'grua:muelle', 'baplie:comparar_baplie', 'baplie:baplie_salida', 'comparar_baplie:baplie_salida', 'baplie:listado_agencia',
           'al_dia:solo_aqui',
           'oficina:muelle', 'oficina:bahia', 'oficina:baplie', 'oficina:al_dia', 'oficina:solo_aqui',
           'oficina:contenedor_40', 'oficina:plataforma', 'oficina:listado_agencia']
TTF = 'assets/fonts/bs_iconos/BayStreamIconos.ttf'
VERSION = '1.2'
# glifos que llegaron después de las insignias y toman los códigos siguientes (v3): los 35 anteriores no cambian
TRAS_INSIGNIAS = ['oficina']
# las 85 huellas SHA-256 del paquete v2 (23-oct), para demostrar en el LEEME qué no cambió en el v3
HUELLAS_V2 = {
    'assets/fonts/bs_iconos/BayStreamIconos.ttf': '8eec33ae80a6d3bd73f1214626fc20ebc90df77927107d75628b8d9a2b159147',
    'design/iconos/LEEME.md': '8297e2bcc0122cd5dd5e72fb5633a072df8378f6c66d4003f47c09e91f8b7272',
    'design/iconos/codigos.json': 'f726bc84f708ff74a8fe5773bd42b490e540d4c006e3e3803429d7c86d3ed51e',
    'design/iconos/comprobacion-fuente.png': 'c8179bd06ccb4b24bb39ecdeca36340d2b524ce8405eaf55fcc3301484f41500',
    'design/iconos/comprobacion-skia.md': '46b711568b518693f409ad4a4743afd416411175f413668392a7f614df782245',
    'design/iconos/comprobacion-skia.png': '097160d22609ec9c125dd883df3a54561b23674a6db61f942c86ab4763c5efbb',
    'design/iconos/conceptos.png': '2f3d0e3037ef8950cf939227bf60ab75509ffbb01aad90c860f8d9b61862db2d',
    'design/iconos/fuentes/LEEME.plantilla.md': '4e1fc39bd17b150986042fe635c8a82a0597a511b07a471cdc0184b3121e98be',
    'design/iconos/fuentes/ayudantes.py': 'b271e2814a92b030568ffc92f826be2e67d48601d7b7f2dbf87ca1650d73bb6d',
    'design/iconos/fuentes/comprobar_skia.js': '4feb12127319affa62e7543e67911cc2da61e19648110a3febddcd06ca05e656',
    'design/iconos/fuentes/comprobar_skia.py': '6717c5508ac63f26cd7b89d4fad978400eb41de6dcfac51aa8766b02b7d9d5d8',
    'design/iconos/fuentes/dsl.py': 'dd1a13a0ee0f345f4b46bbc6598fc53b9867f95c3fd8996f577718b71f838cfb',
    'design/iconos/fuentes/exportar_json.py': 'bc8ce5388a459901b4a9859f500736e67f984d39a42975a46353bafcbc64880a',
    'design/iconos/fuentes/fuente.py': '177933cfef240e7ba117ae8d5a6c31aaba15716c85d64674a84960e717a9480c',
    'design/iconos/fuentes/geom.py': 'b6d905a78b12d288bf6c398c12733d96329d814a8336452c2d136a93cfaa7529',
    'design/iconos/fuentes/iconos.py': '22102de9d77c3c8904839555c2308cf6bee807f39c96dbf9f4bab9147df2b787',
    'design/iconos/fuentes/insignias.py': '6810f972d0a7fc7848e04b217be13f44800ccb770b80906136a7beab25095dc7',
    'design/iconos/fuentes/parejas.py': '8da277c067e558a12872e9422bba1bcb5a9c1f6cbdc709bd165f6e9564f6ea5a',
    'design/iconos/fuentes/verificar_fuente.py': 'a69b7f7826ab3b81176735dfac6d78da74114133068185a15f9a6cc4ec9ade20',
    'design/iconos/fuentes/vista_previa.py': 'affb38a08196c08b3ec8abe09fda437891675f38f73529af862cb4eaeb9d9e23',
    'design/iconos/generar.py': '2532a6b0106cb8b7b7eda3c1dd72383c7d9fbcef1ef9d9f22f540d396122f9f9',
    'design/iconos/svg/al_dia.svg': '22a9637123c9670546b500400cd24a811122dc7d16815f0c498b858419fc01b6',
    'design/iconos/svg/bahia.svg': '9a8b6e6b9954ab46546157cb6ad84db782da00afbf16143ddba1714c04216808',
    'design/iconos/svg/baplie.svg': '0513e11727c0469bab491d5700727c1ef3c3056bd3e26866cc96ae668b6c40ed',
    'design/iconos/svg/baplie_salida.svg': 'd3ffdd439fea0a6c42b54c8e4a3216bda6a3fb815ddded7867bddb3a19319b0d',
    'design/iconos/svg/buque.svg': 'fc82753b5c888a4417805c6657596597d84424480a1e8e929ee54eaf2ce3ae2b',
    'design/iconos/svg/carga.svg': 'a6ec8a53684ce04b13d6332cd195c5444f7b751714282d4c4fa6fa79e8dfe066',
    'design/iconos/svg/comparar_baplie.svg': 'b14da614e0fcd2cabe691d4aa0db0bd98e4d37df625b6eb631946e8d1f3671e4',
    'design/iconos/svg/contenedor_20.svg': 'd28640992e28539b88ae5318ff6a6d5c82b17473153eaf627b20591ff19c9a0a',
    'design/iconos/svg/contenedor_40.svg': 'c19a4adf1456b9d515a6bd4ec8a22e9103e2ad3c37879430195092b4bff3b183',
    'design/iconos/svg/contenedor_45.svg': '93e301b450c33e83e53abbc55a58850dcb81168fb7cc221e2620a91bba9dcdfe',
    'design/iconos/svg/descarga.svg': 'b5d13ffd7169ac499f462ba0dc7c8bd5cbaa02d2d07e0eb7a83164970ffa7fc4',
    'design/iconos/svg/escala.svg': 'a00c79293eeee80e7bd653b0fcf2d0259f4a95f313829d5a8370212ebd8421c6',
    'design/iconos/svg/fuera_de_medida.svg': '00a5b867402285a8a7e346e280332cda6c8e8329cf9e2d198858ac329772e244',
    'design/iconos/svg/grua.svg': 'b23897b646de4f1feade75d1cb0dd8037ee06d0685db5fc2a91c4fd9497c19b7',
    'design/iconos/svg/limite_apilamiento.svg': '04d5afc4bc73d253c01c4c04e4978f4db9b1c7125f57643d6219d0db8be0c5f2',
    'design/iconos/svg/listado_agencia.svg': '312e5943ee8cfa13cf70a0dc0dd551c3807391dfaa847e6e838d03eeca38ffe7',
    'design/iconos/svg/muelle.svg': '06239e59338282b26a571a4d1bcc727d003edeca9849c5739ab0cdab2340e701',
    'design/iconos/svg/orden.svg': '1870f55e7a9cfd764954b45075a24f0ab778b45f96e7ffcda36a017d930ac6c1',
    'design/iconos/svg/pedir_cambio.svg': '76e47e7a2128ceb2a63229587431cc90065ab81184b32d35ef1cb1d37ef0a8be',
    'design/iconos/svg/peligrosa.svg': 'ab0fb8f2afa666e04ef75f2f77ed91b611531d27e515fa0fcd4944d931f7c551',
    'design/iconos/svg/peso_pila.svg': '8f68a719b52c006e5faa564960c58d2b94df5b01bb9e32d3ef860ad888e0efe2',
    'design/iconos/svg/plataforma.svg': 'a74d32d27ab10d4062446cf72d35c6bb8dd97ae607967c86cb104d99537452c1',
    'design/iconos/svg/reestiba.svg': 'd860291d21c2d9d9165d108b1722f983a8210fb02956703f14460c0aa9dabb8c',
    'design/iconos/svg/refrigerado.svg': 'a166d93a1528dfbb6fef82eef67277cead31293832ef1b53f74a8f66e7def3b6',
    'design/iconos/svg/segregacion.svg': 'c0f7f1de4f56899bcee3cab099ba5310df720dcd9803f0c551e2b0d45356a0fd',
    'design/iconos/svg/solo_aqui.svg': 'dc6d4ae7f02103523c5d2a2445dc05ebef998f15d21de1af4dd8ed288a6920d4',
    'design/iconos/svg/tanque.svg': '78e1af21aa0fdc9a2e357d19e3d376ac9f483baf45087e0cb722924ed41a18e4',
    'design/iconos/svg/tapa_escotilla.svg': 'c73200aa3a5e731012dc688e4673d125161d859164211d9c2ab2035ffd6697e0',
    'design/iconos/svg/techo_abierto.svg': '2d38c6f38ead85195757d3834bb721534d7b8794a8b4cdcb4bb856939361ad9c',
    'design/iconos/svg/vacio.svg': '49caf59f172edb0afbf74ead8543f804025fb613c5c5a2e742ddcf9bfb8deb86',
    'design/iconos/svg/vgm.svg': '9090a24771b435546d90b23420e464ba1052a25f46fa0f329805e3a23b989612',
    'design/iconos/svg_insignias/fuera_de_medida.svg': 'c7a3c7541fb3ded71b8fac61c7ee144320483b2e74a1e8cdbeaaab34b9e8d338',
    'design/iconos/svg_insignias/peligrosa.svg': '40a4e73433cdc4b169eaf6e856c7630b1ede5b053d3fb6d6fa1ec9be031fa195',
    'design/iconos/svg_insignias/refrigerado.svg': 'b4507f95c1a3375803b28ebf70cf2009b511bb8ff16e9119e1e20caf10ed7f0c',
    'design/iconos/svg_insignias/vacio.svg': '9bd8fa12915aee865a02721aa6478eb50cf1e7b7bea65d6228fbfbd3e1c3ee63',
    'design/iconos/vista-previa.png': 'a68c9b1a0200d01b956368cc5071cb39026b889c1511a68d81068c2f8dda0968',
    'design/ilustraciones/descarga_completa.json': 'fd986e230704e8961ea72881abaa9b5f1b3b54cc1d1f30d975571ebe010d1c84',
    'design/ilustraciones/descarga_completa_claro.svg': 'fdf6b176c0c65a4728444334f6cec50d5b806c401e3541b2f4c2f7e36c208156',
    'design/ilustraciones/descarga_completa_oscuro.svg': 'f0f1c8242ad9dc6d3acffcd0e34cddb9df98220e44a5f0239b4f3642d8080989',
    'design/ilustraciones/fuentes/descarga_completa.py': '9955a2c0901ee6368aa3a5e3fc1add6abfe4385c3a98adbd9d125fd60734fb8d',
    'design/ilustraciones/fuentes/geom.py': 'b6d905a78b12d288bf6c398c12733d96329d814a8336452c2d136a93cfaa7529',
    'design/ilustraciones/fuentes/ilus.py': '20c4875226a09c04fe1a1c53ada33fe9222be15fa92b9c3a4e573cac5b871580',
    'design/ilustraciones/fuentes/inicio.py': '4b374e5177353a139b897a19f2729ae9f56a9d5a763c671fe83da659957e05af',
    'design/ilustraciones/fuentes/plantilla.py': 'd3ce8cc1601ee9f980b0c94873dd4562512c3d6807c5395d82a9e1e043e120ea',
    'design/ilustraciones/fuentes/sin_alertas.py': '8207a185d9c8cff9cc026070a833eae31750d697f30ec44ce34483cc2785766b',
    'design/ilustraciones/fuentes/sin_conexion.py': 'f021215b8cbaea79bccd93f64415ce7127c89198d2a1800d615bf96da4be138b',
    'design/ilustraciones/fuentes/vacio_busqueda.py': '7bb47631a8499ac6c7d0cfc1af618db1b2f33a107b1b20614809c30055656f86',
    'design/ilustraciones/fuentes/vacio_recientes.py': '8ee0b41f70ffdbdb18dfdf7e0ec2c73d31f152c9a800a548b492f2cd98de6071',
    'design/ilustraciones/inicio.json': '8c332a5e7d5de83e7c897c185e68b0738048580fad08ff762e02f1686ddafb71',
    'design/ilustraciones/inicio_claro.svg': '5ce64222a2e3c66254c750330ddd78fe04aa8658b781e654ad28d0979798c10c',
    'design/ilustraciones/inicio_oscuro.svg': '3feeaa16a7490a696a43f429c6504bdcf0dc516b0d8a3cd3ebcfc85f06545799',
    'design/ilustraciones/sin_alertas.json': 'c62b199958e426b6281d46f2255c641629e62b5a3fb40e90f4929258b5dc5598',
    'design/ilustraciones/sin_alertas_claro.svg': 'f6ee7c859449bb10cb0b4a118b58eb0f08abee576874bb5a1826dc3e7873c88b',
    'design/ilustraciones/sin_alertas_oscuro.svg': '96220ad037ae7ede8896bf7909823f420483ed36a81eae8b3916b803beac7387',
    'design/ilustraciones/sin_conexion.json': 'd98c3a1dcb76c77367c1373389b6f7e90e619130f6a09190dfe4841df285f748',
    'design/ilustraciones/sin_conexion_claro.svg': 'c68cae697ed77043f57b147b20139977d78b1004535d6013c4627fc36856cdc2',
    'design/ilustraciones/sin_conexion_oscuro.svg': '21254aa5baf8dfa88f3d15d78bbe9a5a73c750bf46c8f81e11790fea5b302821',
    'design/ilustraciones/vacio_busqueda.json': '66ac232176ce34269c6685029893683dad1f887771e3107a35ec649891ad45c3',
    'design/ilustraciones/vacio_busqueda_claro.svg': 'd6b1889e931ba9558ce3a13e012d70dc4b1b0a3d4445d942fa753f8892de2c1a',
    'design/ilustraciones/vacio_busqueda_oscuro.svg': 'df4cc405cd7db79574f2210d15513534db5ebb5059c5708c96f6887482e604b2',
    'design/ilustraciones/vacio_recientes.json': 'deddb15ac9e7dd54812a362a9cae7240fa8bc08cbd9ab042f234df1f72406666',
    'design/ilustraciones/vacio_recientes_claro.svg': 'c0136029ea285266d5cc80b97c10291cf6f493032f868a6ae1567a2f73190d9d',
    'design/ilustraciones/vacio_recientes_oscuro.svg': '8a5e7bad076450f76b54f37fb56048dc76b6da3abf34edf8c850aacd1efbf5b0',
    'design/ilustraciones/vista-previa.png': 'e16763153cf69010d1619bef2771b7b95560a9ca21cc94caff1854d122c0585d',
}
# la salida de `generar.py --verificar` sobre el v3, tal cual, para el LEEME (se corre, se copia aquí y se vuelve a generar)
SALIDA_VERIFICAR = '85 de 85 comprobaciones correctas.'
# lo que cambia del v2 al v3; el bloque de Git del LEEME lista solo esto
CAMBIAN_V3 = ['assets/fonts/bs_iconos/BayStreamIconos.ttf', 'design/iconos/codigos.json', 'design/iconos/comprobacion-fuente.png',
              'design/iconos/comprobacion-skia.md', 'design/iconos/comprobacion-skia.png', 'design/iconos/fuentes/LEEME.plantilla.md',
              'design/iconos/fuentes/comprobar_skia.py', 'design/iconos/fuentes/fuente.py', 'design/iconos/fuentes/iconos.py',
              'design/iconos/generar.py', 'design/iconos/svg/oficina.svg', 'design/iconos/vista-previa.png', 'design/iconos/LEEME.md']


def _modulo(ruta):
    spec = importlib.util.spec_from_file_location(ruta.stem + '_mod', ruta)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def cargar_todo():
    iconos = cargar_iconos(str(FUENTES / 'iconos.py'))
    insignias = cargar_iconos(str(FUENTES / 'insignias.py'))
    ils = {}
    for n in ILUSTRACIONES:
        ils[n] = cargar_ilus(str(FUENTES_ILUS / f'{n}.py'))[n]
    return iconos, insignias, ils


def svg_insignia(ic) -> str:
    """La insignia se dibuja en la rejilla de 24; su SVG se entrega en una rejilla de 12 (coordenadas a la mitad)."""
    s = ic.svg(titulo=False)
    cuerpo = s[s.index('<g '):s.rindex('</g>') + 4]
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12">\n  <title>insignia {ic.nombre}</title>\n'
            f'  <g transform="scale(0.5)">\n  {cuerpo}\n  </g>\n</svg>\n')


def escribir_texto(ruta: Path, texto: str):
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with open(ruta, 'w', encoding='utf-8', newline='\n') as f:
        f.write(texto)


def generar(raiz: Path):
    iconos, insignias, ils = cargar_todo()
    di = raiz / 'design' / 'iconos'
    dil = raiz / 'design' / 'ilustraciones'
    escritos = []
    for n, ic in iconos.items():
        escribir_texto(di / 'svg' / f'{n}.svg', ic.svg()); escritos.append(f'design/iconos/svg/{n}.svg')
    for n, ic in insignias.items():
        escribir_texto(di / 'svg_insignias' / f'{n}.svg', svg_insignia(ic)); escritos.append(f'design/iconos/svg_insignias/{n}.svg')
    (raiz / TTF).parent.mkdir(parents=True, exist_ok=True)
    primeros = {n: ic for n, ic in iconos.items() if n not in TRAS_INSIGNIAS}
    despues = {n: iconos[n] for n in TRAS_INSIGNIAS}
    codigos, _ = modulo_fuente.construir(primeros, insignias, str(raiz / TTF), str(di / 'codigos.json'), VERSION, despues=despues)
    escritos += [TTF, 'design/iconos/codigos.json']
    todos = dict(primeros); todos.update({f'insignia_{k}': v for k, v in insignias.items()}); todos.update(despues)
    filas_fuente = verificar_fuente.verificar(todos, codigos, str(raiz / TTF), str(di / 'comprobacion-fuente.png'))
    escritos.append('design/iconos/comprobacion-fuente.png')
    redondeos = {}
    for n, il in ils.items():
        escribir_texto(dil / f'{n}_claro.svg', il.svg('claro')); escribir_texto(dil / f'{n}_oscuro.svg', il.svg('oscuro'))
        datos = exportar_json.escribir(il, str(dil / f'{n}.json'))
        redondeos[n] = exportar_json.comprobar(il, datos)
        escritos += [f'design/ilustraciones/{n}_claro.svg', f'design/ilustraciones/{n}_oscuro.svg', f'design/ilustraciones/{n}.json']
    vista_previa.iconos(iconos, insignias, str(di / 'vista-previa.png')); escritos.append('design/iconos/vista-previa.png')
    vista_previa.ilustraciones(ils, str(dil / 'vista-previa.png')); escritos.append('design/ilustraciones/vista-previa.png')
    # archivos que viajan tal cual: fuentes, generador y la captura de conceptos
    if raiz != RAIZ:
        (di / 'fuentes').mkdir(parents=True, exist_ok=True)
        (dil / 'fuentes').mkdir(parents=True, exist_ok=True)
        for p in sorted(FUENTES.glob('*')):
            if p.is_file() and p.suffix in ('.py', '.md', '.js'):
                shutil.copy(p, di / 'fuentes' / p.name)
        for p in sorted(FUENTES_ILUS.glob('*.py')):
            shutil.copy(p, dil / 'fuentes' / p.name)
        shutil.copy(AQUI / 'generar.py', di / 'generar.py')
    escritos += [f'design/iconos/fuentes/{p.name}' for p in sorted(FUENTES.glob('*')) if p.is_file() and p.suffix in ('.py', '.md', '.js')]
    escritos += [f'design/ilustraciones/fuentes/{p.name}' for p in sorted(FUENTES_ILUS.glob('*.py'))]
    escritos += ['design/iconos/generar.py']
    for extra in ('conceptos.png', 'comprobacion-skia.md', 'comprobacion-skia.png'):
        if raiz != RAIZ and (AQUI / extra).exists() and not (di / extra).exists():
            shutil.copy(AQUI / extra, di / extra)
        if (di / extra).exists():
            escritos.append(f'design/iconos/{extra}')
    leeme = leeme_texto(raiz, sorted(set(escritos)), filas_fuente, redondeos, codigos)
    escribir_texto(di / 'LEEME.md', leeme)
    return escritos, filas_fuente, redondeos


def sha256(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def tabla_fuente(filas):
    out = ['| Glifo | Código | Contorno 16 px (Δ medio · cambian) | FreeType 16 px (cambian · %) | Contorno 24 px | FreeType 24 px | Coincide |', '|---|---|---|---|---|---|---|']
    for f in filas:
        c16, f16, c24, f24 = f['contorno_16'], f['freetype_16'], f['contorno_24'], f['freetype_24']
        out.append(f"| `{f['nombre']}` | {f['codigo']} | {c16[0]} · {c16[1]} | {f16[1]} · {f16[3]} % | {c24[0]} · {c24[1]} | {f24[1]} · {f24[3]} % | {'sí' if f['ok'] else 'no'} |")
    return '\n'.join(out)


def tabla_sha(raiz, escritos):
    out = ['| Archivo | Bytes | SHA-256 |', '|---|---:|---|']
    for rel in escritos:
        p = raiz / rel
        if p.exists():
            out.append(f'| `{rel}` | {p.stat().st_size:,} | `{sha256(p)}` |'.replace(',', ' '))
    return '\n'.join(out)


def tabla_v2(raiz, escritos):
    """Frente al v2: qué archivos conservan su huella, cuáles cambian y cuáles son nuevos."""
    iguales, cambian, nuevos = [], [], []
    for rel in sorted(set(escritos) - {'design/iconos/LEEME.md'}):
        p = raiz / rel
        if not p.exists():
            continue
        h = sha256(p)
        if rel not in HUELLAS_V2:
            nuevos.append(rel)
        elif HUELLAS_V2[rel] == h:
            iguales.append((rel, h))
        else:
            cambian.append(rel)
    faltan = sorted(set(HUELLAS_V2) - set(e for e in escritos) - {'design/iconos/LEEME.md'})
    out = [f'{len(iguales)} archivos con la misma huella que en el v2, {len(cambian)} cambian, {len(nuevos)} nuevo'
           + ('s' if len(nuevos) != 1 else '') + (f', {len(faltan)} del v2 que ya no están' if faltan else '') + ' (`design/iconos/LEEME.md` cambia y no lleva huella).', '']
    out += ['Cambian: ' + ', '.join(f'`{r}`' for r in cambian) + '.', '', 'Nuevo: ' + ', '.join(f'`{r}`' for r in nuevos) + '.', '',
            '| Archivo igual al v2 | SHA-256 (la misma en v2 y v3) |', '|---|---|']
    out += [f'| `{r}` | `{h}` |' for r, h in iguales]
    return '\n'.join(out)


def tabla_codigos(codigos):
    out = ['| Glifo | Código |', '|---|---|']
    for n, c in codigos.items():
        out.append(f'| `{n}` | U+{c:04X} |')
    return '\n'.join(out)


def tabla_json(redondeos):
    out = ['| Ilustración | Claro: píxeles distintos (de los totales) · Δ máx | Oscuro |', '|---|---|---|']
    for n, r in redondeos.items():
        c, o = r['claro'], r['oscuro']
        out.append(f"| `{n}` | {c['distintos']} de {c['total']:,} · {c['max']} | {o['distintos']} de {o['total']:,} · {o['max']} |".replace(',', ' '))
    return '\n'.join(out)


def _alfa(ic, px):
    import io
    from PIL import Image
    png = resvg_py.svg_to_bytes(svg_string=ic.svg(color='#000000'), width=px, height=px)
    return Image.open(io.BytesIO(bytes(png))).convert('RGBA').getchannel('A').tobytes()


def peso16(ic):
    """Peso del ícono: el área de tinta expresada en píxeles de 16 (raster a 240 px / 225), que no depende de dónde caen los bordes."""
    return round(sum(_alfa(ic, 240)) / 255 / 225, 1)


def tabla_parejas(iconos):
    alfa = _alfa
    out = ['| Pareja | 16 px: píxeles que cambian de estado · % | 20 px | Se distinguen a 16 px |', '|---|---|---|---|']
    for par in PAREJAS:
        a, b = par.split(':')
        if a not in iconos or b not in iconos:
            continue
        celdas = []
        for px in (16, 20):
            A, B = alfa(iconos[a], px), alfa(iconos[b], px)
            e = sum(1 for x, y in zip(A, B) if (x >= 128) != (y >= 128))
            celdas.append((e, round(100 * e / (px * px), 1)))
        ok = celdas[0][0] >= 8 and celdas[0][1] >= 6
        out.append(f'| `{a}` · `{b}` | {celdas[0][0]} · {celdas[0][1]} % | {celdas[1][0]} · {celdas[1][1]} % | {"sí" if ok else "no (ver nota)"} |')
    return '\n'.join(out)


def bloque_dart(codigos):
    lineas = ['/// Iconos del dominio de BayStream (fuente BayStreamIconos, area de uso privado).',
              '/// Generado por design/iconos/generar.py a partir de design/iconos/codigos.json; no editar a mano.',
              "import 'package:flutter/widgets.dart';", '',
              'abstract final class BsIconos {', "  static const String familia = 'BayStreamIconos';", '']
    for n, c in codigos.items():
        partes = n.split('_')
        camel = partes[0] + ''.join(p.capitalize() for p in partes[1:])
        lineas.append(f'  static const IconData {camel} = IconData(0x{c:04X}, fontFamily: familia);')
    lineas.append('}')
    return '\n'.join('   ' + l if l else l for l in lineas)


def leeme_texto(raiz, escritos, filas_fuente, redondeos, codigos):
    plantilla = (FUENTES / 'LEEME.plantilla.md').read_text(encoding='utf-8')
    iconos, _, _ = cargar_todo()
    git = '```\n' + '\n'.join(f'git add -- {r}' for r in CAMBIAN_V3) + '\ngit commit -m "Suma el icono oficina (U+E023) al paquete de iconos, v3"\ngit push\n```'
    pesos = ', '.join(f'`{n}` {peso16(iconos[n])}' for n in ('oficina', 'muelle', 'baplie', 'bahia', 'al_dia'))
    skia_md = raiz / 'design' / 'iconos' / 'comprobacion-skia.md'
    skia = skia_md.read_text(encoding='utf-8').strip() if skia_md.exists() else '(no se corrió: necesita Node con Playwright y Chromium)'
    return (plantilla.replace('{{TABLA_CODIGOS}}', tabla_codigos(codigos))
            .replace('{{SKIA_TABLA}}', skia)
            .replace('{{GIT}}', git)
            .replace('{{TABLA_PAREJAS}}', tabla_parejas(iconos))
            .replace('{{PESOS}}', pesos)
            .replace('{{TABLA_V2}}', tabla_v2(raiz, escritos))
            .replace('{{VERIFICAR}}', SALIDA_VERIFICAR)
            .replace('{{DART}}', bloque_dart(codigos))
            .replace('{{TABLA_FUENTE}}', tabla_fuente(filas_fuente))
            .replace('{{TABLA_JSON}}', tabla_json(redondeos))
            .replace('{{TABLA_SHA}}', tabla_sha(raiz, [e for e in escritos if e != 'design/iconos/LEEME.md'])))


def verificar(raiz: Path):
    """Regenera en una carpeta temporal y compara byte a byte con lo que hay en raiz."""
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        escritos, filas, _ = generar(tmp)
        fallas = []
        for rel in sorted(set(escritos)) + ['design/iconos/LEEME.md']:
            a, b = raiz / rel, tmp / rel
            if not a.exists():
                fallas.append(f'{rel}: no existe'); continue
            if (rel.startswith('design/iconos/fuentes/') or rel.startswith('design/ilustraciones/fuentes/') or rel.endswith('generar.py')
                    or rel.endswith('conceptos.png') or 'comprobacion-skia' in rel):
                continue
            if a.read_bytes() != b.read_bytes():
                fallas.append(f'{rel}: distinto de lo que producen las fuentes')
        for f in filas:
            if not f['ok']:
                fallas.append(f"glifo {f['nombre']}: no coincide con su SVG")
        return fallas, len(set(escritos))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    ap.add_argument('--salida', type=Path, default=RAIZ)
    ap.add_argument('--verificar', action='store_true')
    a = ap.parse_args()
    if a.verificar:
        fallas, n = verificar(a.salida)
        for f in fallas:
            print(' ✗', f)
        print(f'\n{n - len(fallas)} de {n} comprobaciones correctas.')
        sys.exit(1 if fallas else 0)
    escritos, filas, redondeos = generar(a.salida)
    malos = [f['nombre'] for f in filas if not f['ok']]
    print(f'{len(set(escritos))} archivos escritos en {a.salida}')
    print(f"fuente: {len(filas) - len(malos)} de {len(filas)} glifos coinciden con su SVG" + (f' (revisar: {", ".join(malos)})' if malos else ''))
    for n, r in redondeos.items():
        print(f"json {n}: claro {r['claro']['distintos']} px distintos, oscuro {r['oscuro']['distintos']} px distintos")
    sys.exit(1 if malos else 0)


if __name__ == '__main__':
    main()
