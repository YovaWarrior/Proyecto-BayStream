"""T-98 · censos de Timonel: lectura léxica de lib/ sin Flutter ni paquetes.

Lo comparten los tres censos (idioma, Material 3 y mensajes de error):

- un tokenizador de cadenas de Dart que entiende comentarios anidados, cadenas
  raw, triples e interpolaciones con cadenas dentro (`'${f('a')}'`), que el
  extractor léxico de `tool/t98_inventario.py` parte en trozos;
- el contexto de cada cadena: la llamada que la contiene, el argumento con
  nombre y la cadena de llamadas de arriba;
- el grafo de imports desde `lib/main.dart`, para saber qué archivos llegan
  al producto;
- el mismo extractor léxico de `tool/t98_inventario.py`, copiado tal cual,
  para conciliar con sus 4997 candidatos sin tocar el script de Codex.

Solo lee archivos. No ejecuta Flutter ni Dart.
"""
import hashlib
import re
from pathlib import Path

ID_START = re.compile(r'[A-Za-z_$]')
ID_CHAR = re.compile(r'[A-Za-z0-9_$]')

# Copia literal del patrón de tool/t98_inventario.py (Fase A de Codex).
CODEX_LITERALS = re.compile(
    r'//[^\n]*|/\*[\s\S]*?\*/|'
    r'(?P<string>r?"""[\s\S]*?"""|r?\x27\x27\x27[\s\S]*?\x27\x27\x27|'
    r'r?"(?:\\.|[^"\\])*"|r?\x27(?:\\.|[^\x27\\])*\x27)', re.MULTILINE)

# Copia literal de CONTROLS de tool/t98_inventario.py.
CODEX_CONTROLS = re.compile(
    r'\b(?:TextButton|FilledButton|ElevatedButton|OutlinedButton|IconButton|'
    r'FloatingActionButton|DropdownButton|DropdownMenu|PopupMenuButton|'
    r'Checkbox|Switch|Radio|Slider|RangeSlider|TextField|TextFormField|'
    r'FilterChip|ChoiceChip|ActionChip|InputChip|SegmentedButton|'
    r'NavigationBar|NavigationRail|NavigationDrawer|BottomNavigationBar|'
    r'TabBar|ListTile|CheckboxListTile|SwitchListTile|RadioListTile|'
    r'InkWell|GestureDetector|Draggable|DragTarget|InteractiveViewer|'
    r'MenuItemButton|SubmenuButton|SearchBar|SearchAnchor)\b(?:\.[\w]+)?\s*\(')


class Lit:
    """Un literal simple de Dart: comillas, prefijo raw e interpolaciones."""
    __slots__ = ('start', 'end', 'raw', 'quote', 'parts', 'parent', 'index', 'depth')

    def __init__(self, start, raw, quote, parent, depth):
        self.start = start
        self.end = None
        self.raw = raw
        self.quote = quote
        # ('t', texto) | ('e', código, inicio, fin) | ('v', identificador)
        self.parts = []
        self.parent = parent
        self.index = None
        self.depth = depth


class Lexer:
    def __init__(self, src):
        self.s = src
        self.n = len(src)
        self.lits = []
        self.comments = []

    def run(self):
        self._code(0, False, None, 0)
        for i, lit in enumerate(self.lits):
            lit.index = i
        return self

    def _string_start(self, i):
        s = self.s
        if s[i] in '\'"':
            return True
        if s[i] == 'r' and i + 1 < self.n and s[i + 1] in '\'"':
            return i == 0 or not ID_CHAR.match(s[i - 1])
        return False

    def _code(self, i, close, parent, depth):
        s, n = self.s, self.n
        brace = 0
        while i < n:
            if s.startswith('//', i):
                j = s.find('\n', i)
                j = n if j < 0 else j
                self.comments.append((i, j))
                i = j
                continue
            if s.startswith('/*', i):
                j = self._block_comment(i)
                self.comments.append((i, j))
                i = j
                continue
            if self._string_start(i):
                i = self._string(i, parent, depth)
                continue
            c = s[i]
            if c == '{':
                brace += 1
            elif c == '}':
                if close and brace == 0:
                    return i
                brace -= 1
            i += 1
        return i

    def _block_comment(self, i):
        s, n = self.s, self.n
        level = 0
        while i < n:
            if s.startswith('/*', i):
                level += 1
                i += 2
            elif s.startswith('*/', i):
                level -= 1
                i += 2
                if level == 0:
                    return i
            else:
                i += 1
        return i

    def _string(self, i, parent, depth):
        s, n = self.s, self.n
        start = i
        raw = s[i] == 'r'
        if raw:
            i += 1
        q = s[i]
        quote = q * 3 if s.startswith(q * 3, i) else q
        i += len(quote)
        lit = Lit(start, raw, quote, parent, depth)
        self.lits.append(lit)
        me = len(self.lits) - 1
        buf = []
        while i < n:
            if s.startswith(quote, i):
                i += len(quote)
                break
            c = s[i]
            if not raw and c == '\\' and i + 1 < n:
                buf.append(s[i:i + 2])
                i += 2
                continue
            if not raw and c == '$' and i + 1 < n:
                if s[i + 1] == '{':
                    if buf:
                        lit.parts.append(('t', ''.join(buf)))
                        buf = []
                    j = self._code(i + 2, True, me, depth + 1)
                    lit.parts.append(('e', s[i + 2:j], i + 2, j))
                    i = j + 1
                    continue
                if re.match(r'[A-Za-z_]', s[i + 1]):
                    if buf:
                        lit.parts.append(('t', ''.join(buf)))
                        buf = []
                    j = i + 1
                    while j < n and re.match(r'[A-Za-z0-9_]', s[j]):
                        j += 1
                    lit.parts.append(('v', s[i + 1:j]))
                    i = j
                    continue
            if len(quote) == 1 and c == '\n':
                break
            buf.append(c)
            i += 1
        if buf:
            lit.parts.append(('t', ''.join(buf)))
        lit.end = i
        return i


def masked(src, lexer):
    """El código con comentarios en blanco y el texto de las cadenas cambiado
    por «§»; las expresiones interpoladas quedan a la vista. Devuelve un
    `Codigo`, que conoce el par de cada paréntesis."""
    return Codigo(_masked(src, lexer))


def _masked(src, lexer):
    m = list(src)
    for lit in sorted(lexer.lits, key=lambda x: x.depth):
        for k in range(lit.start, lit.end):
            if m[k] != '\n':
                m[k] = '§'
        for part in lit.parts:
            if part[0] == 'e':
                for k in range(part[2], part[3]):
                    m[k] = src[k]
    for a, b in lexer.comments:
        for k in range(a, b):
            if m[k] != '\n':
                m[k] = ' '
    return ''.join(m)


class Codigo(str):
    """El código enmascarado con el par de cada cierre, para saltar grupos
    completos al recorrer hacia atrás (una sola pasada por archivo)."""

    def __new__(cls, texto):
        obj = super().__new__(cls, texto)
        pila, par = [], {}
        for k, ch in enumerate(texto):
            if ch in '([{':
                pila.append(k)
            elif ch in ')]}' and pila:
                par[k] = pila.pop()
        obj.par = par
        return obj


def _atras(m, i):
    """Retrocede desde i hasta el abridor sin cerrar; salta grupos con el par."""
    par = getattr(m, 'par', None)
    while i >= 0:
        ch = m[i]
        if ch in ')]}':
            if par is not None and i in par:
                i = par[i] - 1
                continue
            depth = 1
            i -= 1
            while i >= 0 and depth:
                if m[i] in ')]}':
                    depth += 1
                elif m[i] in '([{':
                    depth -= 1
                i -= 1
            continue
        if ch in '([{':
            return i
        i -= 1
    return i


def enclosing(m, pos):
    """El abridor sin cerrar a la izquierda de pos, la llamada que lo precede,
    la etiqueta del argumento con nombre y el segmento del argumento."""
    par = getattr(m, 'par', None)
    seg_start = None
    commas = 0
    i = pos - 1
    while i >= 0:
        c = m[i]
        if c in ')]}':
            if par is not None and i in par:
                i = par[i] - 1
                continue
            depth = 1
            i -= 1
            while i >= 0 and depth:
                if m[i] in ')]}':
                    depth += 1
                elif m[i] in '([{':
                    depth -= 1
                i -= 1
            continue
        elif c in '([{':
            break
        elif c == ',':
            commas += 1
            if seg_start is None:
                seg_start = i + 1
        elif seg_start is None and c == ';':
            # una sentencia anterior: el contexto es el bloque que la contiene
            seg_start = i + 1
            i = _atras(m, i)
            break
        i -= 1
    opener = m[i] if i >= 0 else ''
    if seg_start is None:
        seg_start = i + 1
    seg = m[seg_start:pos]
    label = None
    lm = re.match(r'\s*([A-Za-z_]\w*)\s*:(?!:)', seg)
    if lm and opener in '({':
        label = lm.group(1)
    callee = None
    if opener == '(':
        k = m[max(0, i - 300):i].rstrip()
        mm = re.search(
            r'([A-Za-z_$][\w$]*(?:\s*\??\.\s*[A-Za-z_$][\w$]*)*)\s*'
            r'(?:<[^()<>]*(?:<[^()<>]*>[^()<>]*)*>)?\s*$', k)
        if mm:
            callee = re.sub(r'\s+', '', mm.group(1)).replace('?.', '.')
    elif opener == '{':
        callee = '${' if i > 0 and m[i - 1] == '$' else '{'
    elif opener == '[':
        k = m[max(0, i - 300):i].rstrip()
        ultima = re.search(r'([A-Za-z_]\w*)$', k)
        clave = ultima.group(1) if ultima else ''
        if clave in ('const', 'return', 'in', 'case', 'else', 'yield', 'await', 'new',
                     'final', 'var', 'default'):
            callee = '['
        else:
            callee = 'subindice' if k and (k[-1].isalnum() or k[-1] in '_)]§!') else '['
    return i, opener, callee, label, seg, commas


def chain(m, pos, levels=5):
    """Llamadas que contienen la posición, de dentro hacia fuera."""
    out = []
    p = pos
    for _ in range(levels):
        op, opener, callee, label, seg, _ = enclosing(m, p)
        if op < 0:
            break
        out.append((callee, label))
        p = op
    return out


class Cadena:
    """Un literal de cadena de Dart (las partes adyacentes, unidas como hace
    el compilador)."""

    def __init__(self, archivo, lits, src, m, lineas, inicios):
        self.archivo = archivo
        self.lits = lits
        first, last = lits[0], lits[-1]
        self.start, self.end = first.start, last.end
        self.linea = _linea(inicios, self.start)
        self.linea_fin = _linea(inicios, self.end)
        self.fuente = src[self.start:self.end]
        self.parent = first.parent  # índice del Lit padre, si está anidada
        self.depth = first.depth
        texto, exprs = [], []
        for lit in lits:
            for part in lit.parts:
                if part[0] == 't':
                    texto.append(part[1])
                elif part[0] == 'v':
                    texto.append('{' + part[1] + '}')
                    exprs.append(part[1])
                else:
                    texto.append('{' + ' '.join(part[1].split()) + '}')
                    exprs.append(part[1])
        self.texto = ''.join(texto)
        self.exprs = exprs
        self.estatico = ''.join(p[1] for lit in lits for p in lit.parts if p[0] == 't')
        op, opener, callee, label, seg, commas = enclosing(m, self.start)
        self.arg = commas  # posición del argumento: 0 es el primero
        self.opener = opener
        self.callee = callee
        self.label = label
        self.seg = seg
        self.chain = chain(m, self.start)
        self.antes = m[max(0, self.start - 200):self.start]
        self.despues = m[self.end:self.end + 80]
        linea_src = lineas[self.linea - 1] if self.linea - 1 < len(lineas) else ''
        self.directiva = bool(re.match(r'^\s*(import|export|part)\b', linea_src))
        self.padre_cadena = None  # se completa después

    def clave(self):
        return f'{self.archivo}:{self.linea}'


def _linea(inicios, pos):
    """Número de línea (desde 1) de una posición, por búsqueda binaria."""
    lo, hi = 0, len(inicios) - 1
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if inicios[mid] <= pos:
            lo = mid
        else:
            hi = mid - 1
    return lo + 1


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sha256_lf(path):
    return hashlib.sha256(path.read_bytes().replace(b'\r\n', b'\n')).hexdigest()


def leer(path):
    return path.read_text(encoding='utf-8-sig')


def cadenas_de(root, rel):
    """Las cadenas de un archivo y el mapa literal → cadena."""
    src = leer(root / rel)
    lx = Lexer(src).run()
    m = masked(src, lx)
    grupos = []
    ultimo = {}
    for lit in lx.lits:
        prev = ultimo.get(lit.parent)
        ultimo[lit.parent] = lit
        if prev is not None and grupos and m[prev.end:lit.start].strip() == '' \
                and grupos[-1][-1] is prev:
            grupos[-1].append(lit)
        else:
            # el último grupo con el mismo padre puede no ser grupos[-1]
            hecho = False
            if prev is not None and m[prev.end:lit.start].strip() == '':
                for g in reversed(grupos):
                    if g[-1] is prev:
                        g.append(lit)
                        hecho = True
                        break
            if not hecho:
                grupos.append([lit])
    lineas = src.split('\n')
    inicios = [0]
    for linea in lineas[:-1]:
        inicios.append(inicios[-1] + len(linea) + 1)
    cadenas = [Cadena(rel, g, src, m, lineas, inicios) for g in grupos]
    de_lit = {}
    for c in cadenas:
        for lit in c.lits:
            de_lit[lit.index] = c
    for c in cadenas:
        if c.parent is not None:
            c.padre_cadena = de_lit[c.parent]
    return src, lx, m, cadenas


def candidatos_codex(src):
    """Los candidatos léxicos de tool/t98_inventario.py: (inicio, fin, texto)."""
    return [(mt.start(), mt.end(), mt.group()) for mt in CODEX_LITERALS.finditer(src)
            if mt.group('string') is not None]


def alcanzables(root):
    """Archivos de lib/ que llegan desde lib/main.dart por imports, exports,
    part e imports condicionales."""
    lib = (root / 'lib').resolve()
    name = re.search(r'^name:\s*(\S+)', (root / 'pubspec.yaml').read_text(encoding='utf-8'),
                     re.M).group(1)
    imp = re.compile(r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"](.*?);''', re.M | re.S)
    cond = re.compile(r'''if\s*\(([^)]*)\)\s*['"]([^'"]+)['"]''')
    graph = {}
    for p in sorted(lib.rglob('*.dart')):
        s = leer(p)
        deps = []
        for mt in imp.finditer(s):
            for t in [mt.group(1)] + [c.group(2) for c in cond.finditer(mt.group(2))]:
                if t.startswith('dart:'):
                    continue
                if t.startswith('package:'):
                    if not t.startswith(f'package:{name}/'):
                        continue
                    q = (lib / t[len(f'package:{name}/'):]).resolve()
                else:
                    q = (p.parent / t).resolve()
                deps.append(q)
        graph[p.resolve()] = deps
    seen = set()
    stack = [(lib / 'main.dart').resolve()]
    while stack:
        x = stack.pop()
        if x in seen:
            continue
        seen.add(x)
        stack.extend(graph.get(x, []))
    base = root.resolve()
    return {p.relative_to(base).as_posix(): p in seen for p in graph}


def archivos_lib(root):
    return sorted(p.relative_to(root).as_posix() for p in (root / 'lib').rglob('*.dart'))
