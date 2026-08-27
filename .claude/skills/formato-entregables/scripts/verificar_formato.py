#!/usr/bin/env python3
"""
Verificador del formato academico UMG sobre un archivo .docx.

Comprueba mecanicamente las reglas de references/formato-academico.md leyendo el
XML del documento. NO necesita Word ni LibreOffice para la mayoria de las
comprobaciones, y por eso detecta defectos que un render de LibreOffice no
revela — en particular los dos que solo se veian abriendo Word:

  * la colision de numeracion (las vinetas consumian numeros de los titulos), y
  * el encabezado del indice (TOCHeading) quedandose con el "I.".

Uso:
    python verificar_formato.py documento.docx
    python verificar_formato.py documento.docx --render   (anade revision de
                                                           desbordes de margen)

Salida: una linea por comprobacion y codigo de salida 1 si alguna falla.
"""
import re
import sys
import zipfile
from collections import Counter

W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'

# ---- geometria esperada, en twips -----------------------------------------
PAGINA = (12240, 15840)          # carta vertical
MARGENES = {'left': 1984, 'right': 1417, 'top': 1701, 'bottom': 1701}
UTIL = PAGINA[0] - MARGENES['left'] - MARGENES['right']      # 8839
NIVEL_IND = {1: 425, 2: 850, 3: 1276, 4: 1276}
LINEA_15 = 360                    # interlineado 1.5
SANGRIA_1L = 357                  # 0.63 cm

_fallos, _avisos = [], []


def ok(msg):
    print(f"  \033[32mOK\033[0m    {msg}")


def fallo(msg):
    _fallos.append(msg)
    print(f"  \033[31mFALLA\033[0m {msg}")


def aviso(msg):
    _avisos.append(msg)
    print(f"  \033[33mAVISO\033[0m {msg}")


def cargar(ruta):
    z = zipfile.ZipFile(ruta)
    partes = {}
    for n in ('word/document.xml', 'word/styles.xml', 'word/numbering.xml'):
        try:
            partes[n] = z.read(n).decode('utf-8')
        except KeyError:
            partes[n] = ''
    return partes


# ---------------------------------------------------------------- 1. pagina
def check_pagina(doc):
    sizes = set(re.findall(r'<w:pgSz w:w="(\d+)" w:h="(\d+)"', doc))
    if not sizes:
        return fallo("no se encontro <w:pgSz>: el documento no declara tamano de pagina")
    if sizes != {(str(PAGINA[0]), str(PAGINA[1]))}:
        return fallo(f"tamano de pagina {sizes}, se esperaba carta vertical {PAGINA}")
    ok("papel carta vertical en todas las secciones")


def check_margenes(doc):
    mars = re.findall(r'<w:pgMar ([^/]*)/>', doc)
    if not mars:
        return fallo("no se encontro <w:pgMar>")
    malos = []
    for m in mars:
        v = dict(re.findall(r'w:(\w+)="(-?\d+)"', m))
        for k, esperado in MARGENES.items():
            if int(v.get(k, -1)) != esperado:
                malos.append(f"{k}={v.get(k)} (esperado {esperado})")
    if malos:
        return fallo("margenes fuera de especificacion: " + ", ".join(sorted(set(malos))))
    ok("margenes 3.5 / 2.5 / 3 / 3 cm en todas las secciones")


# ------------------------------------------------------- 2. fuente y cuerpo
def check_tipografia(doc, styles):
    fuentes = Counter(re.findall(r'w:ascii="([^"]+)"', doc))
    if not fuentes:
        return aviso("no hay fuentes declaradas en el cuerpo; se hereda del estilo")
    principal, _ = fuentes.most_common(1)[0]
    if principal != 'Arial':
        fallo(f"la fuente dominante del cuerpo es {principal!r}, se esperaba Arial")
    else:
        ok(f"Arial dominante en el cuerpo ({fuentes['Arial']} corridas)")
    # las celdas de tabla van a 10 pt por diseno: se excluyen del conteo
    sin_tablas = re.sub(r'<w:tbl>.*?</w:tbl>', '', doc, flags=re.S)
    tam = Counter(re.findall(r'<w:sz w:val="(\d+)"', sin_tablas))
    if tam and tam.most_common(1)[0][0] != '24':
        aviso(f"el tamano dominante del cuerpo es {int(tam.most_common(1)[0][0])/2} pt, "
              f"se esperaba 12 pt")
    elif tam:
        ok("cuerpo a 12 pt (las celdas de tabla van a 10 pt por diseno)")


def check_normal(styles):
    m = re.search(r'<w:style [^>]*w:styleId="Normal"[^>]*>.*?</w:style>', styles, re.S)
    if not m:
        return fallo("el estilo Normal no esta definido")
    blq = m.group(0)
    linea = re.search(r'<w:spacing[^>]*w:line="(\d+)"', blq)
    if not linea or int(linea.group(1)) != LINEA_15:
        fallo(f"interlineado de Normal = {linea.group(1) if linea else 'ausente'}, "
              f"se esperaba {LINEA_15} (1.5)")
    else:
        ok("interlineado 1.5 en el estilo Normal")
    ind = re.search(r'<w:ind[^>]*w:firstLine="(\d+)"', blq)
    if not ind or int(ind.group(1)) != SANGRIA_1L:
        aviso(f"sangria de primera linea de Normal = {ind.group(1) if ind else 'ausente'}, "
              f"se esperaba {SANGRIA_1L} (0.63 cm)")
    else:
        ok("sangria de primera linea 0.63 cm en Normal")


# ---------------------------------------------------- 3. marcadores sin usar
def check_marcadores(doc):
    txt = ' '.join(re.findall(r'<w:t[^>]*>([^<]*)</w:t>', doc))
    pend = re.findall(r'\[[A-ZÁÉÍÓÚÑ][A-ZÁÉÍÓÚÑ \-]{2,}\]', txt)
    if pend:
        return fallo(f"marcadores de plantilla sin reemplazar: {sorted(set(pend))}")
    ok("sin marcadores de plantilla pendientes")


# ------------------------------------------- 4. LOS DOS DEFECTOS DE WORD ----
def check_colision_numeracion(doc, styles):
    """Las vinetas no deben usar la numeracion de los titulos.

    Los numId de los titulos viven en styles.xml (Heading1..4) y NO deben
    aparecer nunca en document.xml. Si aparecen, Word numera esos parrafos
    dentro de la secuencia de titulos: las vinetas salen como I., II., III. y
    ademas desplazan la numeracion de los apartados. LibreOffice no reproduce
    el fallo, por eso esta comprobacion es estatica y no visual.
    """
    de_titulos = set()
    for m in re.finditer(r'<w:style [^>]*w:styleId="(Heading\d)"[^>]*>(.*?)</w:style>',
                         styles, re.S):
        de_titulos.update(re.findall(r'<w:numId w:val="(\d+)"', m.group(2)))
    en_cuerpo = set(re.findall(r'<w:numId w:val="(\d+)"', doc))
    choque = de_titulos & en_cuerpo
    if choque:
        return fallo(f"COLISION DE NUMERACION: document.xml usa el numId {sorted(choque)}, "
                     f"que pertenece a los titulos. Las listas robaran numeros a los "
                     f"apartados al abrirse en Word. Declara una numeracion propia.")
    ok(f"sin colision de numeracion (titulos: {sorted(de_titulos) or 'ninguno'}; "
       f"cuerpo: {sorted(en_cuerpo) or 'ninguno'})")


def check_tocheading(styles):
    """El encabezado que Word inserta con el indice no debe numerarse."""
    m = re.search(r'<w:style [^>]*w:styleId="TOCHeading"[^>]*>.*?</w:style>', styles, re.S)
    if not m:
        return aviso("el estilo TOCHeading no existe; Word usara uno propio al generar el indice")
    blq = m.group(0)
    basado = re.search(r'<w:basedOn w:val="([^"]+)"', blq)
    num = re.search(r'<w:numId w:val="(\d+)"', blq)
    if basado and basado.group(1).startswith('Heading') and (not num or num.group(1) != '0'):
        return fallo("TOCHeading hereda de Heading y NO tiene numId=0: al generar el "
                     "indice, el encabezado 'Contenido' se quedara con el 'I.' y "
                     "desplazara la numeracion de los apartados.")
    ok("TOCHeading sin numeracion")


# --------------------------------------------------------------- 5. tablas
def _tablas(doc):
    cuerpo = re.search(r'<w:body>(.*)</w:body>', doc, re.S)
    if not cuerpo:
        return []
    return re.findall(r'<w:tbl>.*?</w:tbl>', cuerpo.group(1), re.S)


def check_tablas(doc):
    tbls = _tablas(doc)
    if not tbls:
        return aviso("el documento no contiene tablas")
    problemas = []
    for i, t in enumerate(tbls):
        estilo = re.search(r'<w:tblStyle w:val="([^"]+)"', t)
        if not estilo:
            continue                      # tabla de maquetacion (p. ej. la caratula)
        grid = [int(x) for x in re.findall(r'<w:gridCol w:w="(\d+)"', t)]
        ind = re.search(r'<w:tblInd w:w="(\d+)"', t)
        indv = int(ind.group(1)) if ind else 0
        if not grid:
            problemas.append(f"tabla {i}: sin anchos en <w:tblGrid>")
            continue
        if len(set(grid)) == 1 and len(grid) > 1:
            problemas.append(f"tabla {i}: todas las columnas con el mismo ancho "
                             f"({grid[0]}); parece que no se fijo tblGrid")
        borde_der = indv - 108 + sum(grid)     # tblInd mide hasta el contenido
        if borde_der > UTIL + 5:
            problemas.append(f"tabla {i}: el borde derecho cae en {borde_der} twips, "
                             f"fuera del area util ({UTIL})")
        if indv and (indv - 108) not in NIVEL_IND.values():
            problemas.append(f"tabla {i}: sangria {indv - 108}, no coincide con "
                             f"ningun nivel {sorted(set(NIVEL_IND.values()))}")
        filas = re.findall(r'<w:tr[ >].*?</w:tr>', t, re.S)
        if filas and '<w:tblHeader' not in filas[0]:
            problemas.append(f"tabla {i}: la fila de encabezado no se repite entre paginas")
        sin_split = sum(1 for f in filas if '<w:cantSplit' not in f)
        if sin_split:
            problemas.append(f"tabla {i}: {sin_split} filas pueden partirse entre paginas")
    con_estilo = [t for t in tbls if '<w:tblStyle' in t]
    if problemas:
        for p in problemas:
            fallo(p)
    elif not con_estilo:
        aviso(f"hay {len(tbls)} tablas pero ninguna declara <w:tblStyle>: no se "
              f"pudieron comprobar anchos ni sangria")
    else:
        ok(f"{len(con_estilo)} tablas con anchos reales, alineadas al nivel y "
           f"dentro del area util")


def check_rotulos(doc):
    txt = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', doc)
    nums = [int(m.group(1)) for s in txt
            for m in [re.fullmatch(r'Tabla (\d+)\.', s.strip())] if m]
    if not nums:
        return aviso("no se encontraron rotulos con el formato 'Tabla N.'")
    if nums != sorted(nums):
        return fallo(f"los rotulos de tabla no van en orden de aparicion: {nums}")
    if nums != list(range(nums[0], nums[0] + len(nums))):
        return fallo(f"los rotulos de tabla no son consecutivos: {nums}")
    ok(f"rotulos Tabla {nums[0]}–{nums[-1]} consecutivos y en orden")


def check_fuentes_tabla(doc):
    txt = [t.strip() for t in re.findall(r'<w:t[^>]*>([^<]*)</w:t>', doc)]
    rot = sum(1 for s in txt if re.fullmatch(r'Tabla \d+\.', s))
    fue = sum(1 for s in txt if s.startswith('Fuente:'))
    if rot and fue < rot:
        return fallo(f"hay {rot} rotulos de tabla pero solo {fue} lineas 'Fuente:'")
    if rot:
        ok(f"cada una de las {rot} tablas declara su fuente")


# ------------------------------------------------------ 6. estructura final
def check_estructura(doc, styles):
    cuerpo = re.search(r'<w:body>(.*)</w:body>', doc, re.S)
    if not cuerpo:
        return
    paras = re.findall(r'<w:p [^>]*>.*?</w:p>|<w:p>.*?</w:p>', cuerpo.group(1), re.S)
    h1 = [''.join(re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)).strip()
          for p in paras if '<w:pStyle w:val="Heading1"/>' in p]
    if not h1:
        return aviso("no se encontraron titulos de nivel 1")
    if h1[0] != 'Introduccion' and h1[0] != 'Introducción':
        fallo(f"el primer titulo de nivel 1 es {h1[0]!r}; debe ser 'Introduccion' "
              f"(sin apartado Resumen ni nada numerado por delante)")
    else:
        ok("el primer titulo numerado es 'Introduccion'")
    if 'Referencias' in h1:
        i = [n for n, p in enumerate(paras)
             if 'Heading1' in p and 'Referencias' in p]
        if i:
            antes = ''.join(paras[max(0, i[0] - 2):i[0]])
            if 'w:type="page"' not in antes:
                aviso("no se detecto salto de pagina antes de Referencias")
            else:
                ok("Referencias empieza en pagina nueva")
    ok(f"jerarquia de nivel 1: {' · '.join(h1)}")


def check_guiones(doc):
    txt = ' '.join(re.findall(r'<w:t[^>]*>([^<]*)</w:t>', doc))
    sospechosos = set(re.findall(r'\b[A-Z]{1,3}-\d{1,3}\b', txt))
    sospechosos |= set(re.findall(r'\b\d{1,2}-[a-z]{3}\b', txt))
    if sospechosos:
        aviso(f"codigos con guion normal (pueden partirse al final de renglon; "
              f"usa U+2011): {sorted(sospechosos)[:6]}"
              f"{' …' if len(sospechosos) > 6 else ''}")
    else:
        ok("los codigos cortos usan guion de no separacion")


# ------------------------------------------------------------ 7. desbordes
def check_render(ruta):
    import shutil, subprocess, tempfile, glob, os
    if not shutil.which('soffice') or not shutil.which('pdftoppm'):
        return aviso("soffice/pdftoppm no disponibles: no se revisaron desbordes de margen")
    try:
        from PIL import Image
        import numpy as np
    except ImportError:
        return aviso("Pillow/numpy no disponibles: no se revisaron desbordes de margen")
    with tempfile.TemporaryDirectory() as d:
        subprocess.run(['soffice', '--headless', '--convert-to', 'pdf',
                        '--outdir', d, ruta], capture_output=True, timeout=180)
        pdfs = glob.glob(os.path.join(d, '*.pdf'))
        if not pdfs:
            return aviso("no se pudo convertir a PDF; sin revision de desbordes")
        subprocess.run(['pdftoppm', '-jpeg', '-r', '100', pdfs[0],
                        os.path.join(d, 'p')], capture_output=True, timeout=180)
        izq, der = MARGENES['left'] / 1440 * 100, (PAGINA[0] - MARGENES['right']) / 1440 * 100
        malas = []
        pags = sorted(glob.glob(os.path.join(d, 'p-*.jpg')))
        for f in pags:
            a = np.array(Image.open(f).convert('L'))
            nz = np.nonzero((a < 128).sum(axis=0))[0]
            if len(nz) and (nz[0] < izq - 3 or nz[-1] > der + 3):
                malas.append(os.path.basename(f))
        if malas:
            fallo(f"tinta fuera de los margenes en: {', '.join(malas)}")
        else:
            ok(f"ninguna de las {len(pags)} paginas desborda los margenes")


# ------------------------------------------------------------------- main
def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    render = '--render' in sys.argv
    if not args:
        print(__doc__)
        return 2
    ruta = args[0]
    print(f"\nVerificando formato UMG: {ruta}\n" + "-" * 66)
    p = cargar(ruta)
    doc, styles = p['word/document.xml'], p['word/styles.xml']
    if not doc:
        print("  FALLA no se pudo leer word/document.xml")
        return 1

    print("\n Geometria")
    check_pagina(doc); check_margenes(doc)
    print("\n Tipografia")
    check_tipografia(doc, styles); check_normal(styles)
    print("\n Plantilla")
    check_marcadores(doc)
    print("\n Numeracion  (los dos defectos que solo se ven en Word)")
    check_colision_numeracion(doc, styles); check_tocheading(styles)
    print("\n Tablas")
    check_tablas(doc); check_rotulos(doc); check_fuentes_tabla(doc)
    print("\n Estructura")
    check_estructura(doc, styles); check_guiones(doc)
    if render:
        print("\n Render")
        check_render(ruta)

    print("-" * 66)
    print(f" {len(_fallos)} fallas · {len(_avisos)} avisos")
    if _fallos:
        print("\n No entregues el documento hasta resolver:")
        for f in _fallos:
            print(f"   - {f}")
    return 1 if _fallos else 0


if __name__ == '__main__':
    sys.exit(main())
