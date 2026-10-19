// T-99 · Autopruebas del lector ligero de fuentes (tool/t99_fuente.dart).
import 'package:flutter_test/flutter_test.dart';

import '../tool/t99_fuente.dart';

void main() {
  test('T99 una URL en una cadena no es un comentario', () {
    const s = "final u = 'https://x.org/a'; // nota\nfinal v = 1;";
    final limpio = sinComentarios(s);
    expect(limpio, contains("'https://x.org/a'"));
    expect(limpio, isNot(contains('nota')));
    expect(limpio.length, s.length);
  });

  test('T99 comentarios anidados, cadenas triples, crudas e interpolación', () {
    const s = "/* a /* b */ c */ x\n"
        "final t = '''uno\n}{ dos''';\n"
        "final r = r'\\d{2}';\n"
        "final i = 'v=\${m['k'] ?? '}'}';\n"
        "void f() {}";
    final codigo = soloCodigo(s);
    expect(codigo.split('\n').first.trim(), 'x');
    // Ninguna llave de cadena o interpolación cuenta: solo las de f().
    expect('{'.allMatches(codigo).length, 1);
    expect('}'.allMatches(codigo).length, 1);
  });

  test('T99 líneas con código: sin comentarios ni líneas en blanco', () {
    const s = '/// doc\nclass A {\n\n  // solo comentario\n  int x = 1; // fin\n}\n';
    expect(contarLineasDeCodigo(s), 3);
  });

  test('T99 directivas, también condicionales, y las comentadas no', () {
    const s = "import 'package:flutter/material.dart';\n"
        "// import 'nada.dart';\n"
        "export 'a_web.dart'\n    if (dart.library.io) 'a_io.dart';\n";
    final d = directivasDart(s);
    expect(d.map((x) => x.uri), ['package:flutter/material.dart', 'a_web.dart']);
    expect(d.last.condicionales, [('dart.library.io', 'a_io.dart')]);
    expect(d.last.linea, 2);
  });

  test('T99 resolver URI relativas y del propio paquete', () {
    expect(resolverUri('lib/features/v/domain/a.dart', '../data/x.dart', 'baystream'),
        'lib/features/v/data/x.dart');
    expect(resolverUri('lib/a.dart', 'package:baystream/core/b.dart', 'baystream'),
        'lib/core/b.dart');
    expect(resolverUri('lib/a.dart', 'package:flutter/material.dart', 'baystream'), isNull);
    expect(resolverUri('lib/a.dart', 'dart:io', 'baystream'), isNull);
  });

  test('T99 lo generado se excluye', () {
    expect(esGenerado('lib/a.g.dart', ''), isTrue);
    expect(esGenerado('windows/flutter/generated_plugin_registrant.cc', ''), isTrue);
    expect(esGenerado('lib/a.dart', '// GENERATED CODE - DO NOT MODIFY BY HAND\n'), isTrue);
    expect(esGenerado('lib/a.dart', 'class A {}'), isFalse);
  });
}
