// T-99 · Autopruebas de los instrumentos de RNF-001, 003, 005 y 007 (Fase A).
// Usan textos sintéticos, nunca el corpus.
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/t99_capas.dart';
import '../tool/t99_codigo_compartido.dart';
import '../tool/t99_comun.dart';
import '../tool/t99_documentacion.dart';
import '../tool/t99_ram_resumen.dart';
import '../tool/t99_resumen.dart';
import '../tool/t99_sintetico.dart';

const _plantilla = "UNB+UNOA:2+T99+RECEP+260101:0000+REF1'\n"
    "UNH+1+BAPLIE:D:95B:UN:SMDG20'\n"
    "BGM++DOC1+9'\n"
    "TDT+20+V1+++NV2:172:20+++9000003:146:11:BUQUE PRUEBA'\n"
    "LOC+5+GTPBR:139:6'\n"
    "RFF+VON:V1'\n"
    "LOC+147+0010282::5'\nMEA+WT++KGM:20000'\nLOC+9+GTPBR:139:6'\nLOC+11+USHOU:139:6'\n"
    "EQD+CN+TSTU0000001+22G1+++5'\nNAD+CA+NV1:172:20'\n"
    "LOC+147+0020284::5'\nMEA+WT++KGM:25000'\nLOC+9+GTPBR:139:6'\nLOC+11+USHOU:139:6'\n"
    "EQD+CN+TSTU0000002+45G1+++5'\nNAD+CA+NV1:172:20'\n"
    "UNT+19+1'\nUNZ+1+REF1'\n";

int _col(String linea, String ident) => linea.indexOf(ident) + 1;

void main() {
  group('T99 capas', () {
    test('cuenta las dos reglas y aparta Hive del dominio', () {
      final r = revisarCapas({
        'lib/features/v/domain/a.dart':
            "import 'package:flutter/foundation.dart';\nimport '../data/x.dart';\n",
        'lib/features/v/domain/b.dart': "import 'package:hive_ce/hive.dart';\n",
        'lib/features/v/presentation/p.dart':
            "import '../data/repositories/r.dart';\nimport '../domain/a.dart';\n",
        'lib/features/v/data/d.dart': "import '../presentation/p.dart';\n",
      }, 'baystream');
      expect(r.violaciones.map((v) => v.regla), [
        '1 · dominio → Flutter',
        '1 · dominio → datos',
        '2 · presentación → datos',
      ]);
      expect(r.informativas, hasLength(1));
    });
  });

  group('T99 código compartido', () {
    test('las directivas condicionales eligen el archivo por cliente', () {
      final usos = clientesPorArchivo({
        'lib/main.dart': "import 'a.dart';\n",
        'lib/a.dart': "export 'a_web.dart' if (dart.library.io) 'a_io.dart';\n",
        'lib/a_web.dart': 'const x = 1;\n',
        'lib/a_io.dart': 'const x = 2;\n',
      }, 'baystream', 'lib/main.dart');
      expect(usos['lib/a.dart'], {'windows', 'android', 'web'});
      expect(usos['lib/a_io.dart'], {'windows', 'android'});
      expect(usos['lib/a_web.dart'], {'web'});
    });

    test('las ramas por plataforma cuentan sus líneas interiores', () {
      const s = 'void f() {\n'
          '  if (kIsWeb) {\n'
          '    a();\n'
          '    b();\n'
          '  } else {\n'
          '    c();\n'
          '  }\n'
          '  final x = kIsWeb ? 1 : 2;\n'
          '  if (y) {\n'
          '    d();\n'
          '  }\n'
          '  if (Platform.isAndroid) return;\n'
          '}\n';
      expect(lineasEnRamasDePlataforma(s), {2, 3, 5, 7, 11});
    });

    test('la plantilla de flutter create se descuenta línea por línea', () {
      expect(
          lineasDeLaPlantilla(
              ['int main() {', 'return 0;', 'propio();'], 'int main() {\n{{#x}}\nreturn {{y}};\n'),
          2);
      expect(esNativoContable('web/vendor/firebase/12.17.0/firebase-app.js'), isFalse);
      expect(esNativoContable('windows/runner/CMakeLists.txt'), isTrue);
      expect(lineasNativas('a.cpp', '// c\nint a = 1; /* b */\n\n"//no";\n'),
          ['int a = 1;', '"//no";']);
    });
  });

  group('T99 documentación', () {
    test('neutralizar no mueve columnas y respeta //// y /**/', () {
      const s = '/// Doc\nclass A {}\n//// no\n/** b */\n/**/\n';
      final n = neutralizarDocumentacion(s);
      expect(n.length, s.length);
      expect(n, '//  Doc\nclass A {}\n//// no\n/*  b */\n/**/\n');
    });

    test('clasifica lo que señala public_member_api_docs', () {
      const lineas = [
        '/// x',
        'class Foo {',
        '  Foo(this.a);',
        '  Foo.named() : a = 0;',
        '  final int a;',
        '  int get doble => a * 2;',
        '  void hacer() {}',
        '  static Foo crear() => Foo(1);',
        '}',
        'enum Color { rojo, verde }',
        'mixin M {}',
        'extension E on Foo {}',
        'void suelta() {}',
        'const valor = 1;',
        'typedef F = void Function();',
      ];
      final s = lineas.join('\n');
      String clase(int l, String ident) =>
          clasificarDeclaracion(s, l, _col(lineas[l - 1], ident));
      expect(clase(2, 'Foo'), 'clase');
      expect(clase(3, 'Foo'), 'constructor');
      expect(clase(4, 'named'), 'constructor');
      expect(clase(5, 'a;'), 'campo');
      expect(clase(6, 'doble'), 'getter');
      expect(clase(7, 'hacer'), 'metodo');
      expect(clase(8, 'crear'), 'metodo');
      expect(clase(10, 'Color'), 'enum');
      expect(clase(10, 'rojo'), 'constante_enum');
      expect(clase(11, 'M'), 'mixin');
      expect(clase(12, 'E'), 'extension');
      expect(clase(13, 'suelta'), 'funcion');
      expect(clase(14, 'valor'), 'variable');
      expect(clase(15, 'F'), 'typedef');
    });

    test('lee la salida máquina de dart analyze en Windows, con sus escapes', () {
      // Así la escribe dart analyze: la barra invertida va doble y `|`, escapada.
      final s = leerAnalisis(
          r'INFO|LINT|PUBLIC_MEMBER_API_DOCS|C:\\t\\copia\\lib\\a.dart|3|7|3|Missing documentation for a public member.'
          '\n'
          r'INFO|LINT|AVOID_PRINT|C:\\t\\copia\\lib\\a.dart|4|1|5|x \| y',
          r'C:\t\copia');
      expect(s.map((x) => x.clave), ['lib/a.dart:3:7']);
      expect(camposDeMaquina(r'a|b\|c|d\\e'), ['a', 'b|c', r'd\e']);
    });
  });

  group('T99 sintéticos', () {
    test('dígitos de control ISO 6346 e IMO', () {
      expect(digitoIso6346('CSQU305438'), 3);
      final id = idSintetico(42);
      expect(id, startsWith('SNTU000042'));
      expect(int.parse(id[10]), digitoIso6346(id.substring(0, 10)));
      expect(imoSintetico('900000'), '9000003');
    });

    test('el lector abre el sintético con la cuenta exacta', () {
      final g = generarSintetico(_plantilla, 500);
      final v = verificarConElLector(g.texto, 500);
      expect(v['cuenta_exacta'], isTrue);
      expect(v['posiciones_unicas'], 500);
      expect(v['geometria_propuesta_cubre_todo'], isTrue);
      expect(v['avisos_del_lector'], isEmpty, reason: 'Un sintético no debe disparar avisos de T-108');
      final viaje = BaplieParserService().parse(g.texto);
      expect(viaje.vessel.name, 'T99 SINTETICO 500');
      expect(viaje.containers.every((c) => c.containerId.startsWith('SNTU')), isTrue);
      expect(g.datos['de_20'], 250);
    });

    test('la geometría admite 10 000 con la mezcla de A01 y no más', () {
      final p = posicionesSinteticas(GeometriaSintetica(), 8690, 1310);
      expect(p.de40.toSet(), hasLength(8690));
      expect(p.de20.toSet(), hasLength(1310));
      expect(p.de40.every((x) => int.parse(x.substring(0, 3)).isEven), isTrue);
      expect(p.de20.every((x) => int.parse(x.substring(0, 3)).isOdd), isTrue);
      expect(() => posicionesSinteticas(GeometriaSintetica(), 10100, 0), throwsStateError);
    });

    test('las salidas solo van a %TEMP%', () {
      expect(() => exigirSalidaEnTemp('${Directory(carpetaTemporal()).parent.path}/t99_fuera'),
          throwsArgumentError);
      final temp = '${carpetaTemporal()}/t99_prueba';
      expect(() => exigirSalidaEnTemp(temp, repo: carpetaTemporal()), throwsArgumentError);
      exigirSalidaEnTemp(temp);
    });
  });

  group('T99 resúmenes', () {
    test('pares de eventos y percentil como TimelineSummary', () {
      final eventos = [
        {'name': 'Frame', 'ph': 'b', 'ts': 10},
        {'name': 'Frame', 'ph': 'e', 'ts': 30},
        {'name': 'Frame', 'ph': 'X', 'ts': 40, 'dur': 5},
      ];
      expect(paresDeEvento(eventos, 'Frame'), [(10, 30), (40, 45)]);
      expect(percentilComoTimelineSummary([for (var i = 1; i <= 10; i++) i], 90), 9);
    });

    test('latencia de la marca al raster del cuadro final', () {
      final eventos = [
        {'name': 't99_marca', 'ph': 'i', 'ts': 1000},
        {'name': 'Frame', 'ph': 'b', 'ts': 1500},
        {'name': 'Frame', 'ph': 'e', 'ts': 3000},
        {'name': 'GPURasterizer::Draw', 'ph': 'B', 'ts': 3100},
        {'name': 'GPURasterizer::Draw', 'ph': 'E', 'ts': 5000},
        {'name': 't99_fin', 'ph': 'i', 'ts': 6000},
        {'name': 'Frame', 'ph': 'b', 'ts': 7000},
        {'name': 'Frame', 'ph': 'e', 'ts': 7500},
      ];
      expect(latenciaMs(eventos), 4.0);
      expect(latenciaMs(eventos.where((e) => e['name'] != 't99_fin').toList()), isNull);
    });

    test('latencia sin traza con FrameTiming y cotejo de relojes', () {
      final sinTraza = {
        'marca_us': 1000,
        'fin_us': 6000,
        'cuadros': [
          {'build_inicio': 900, 'raster_fin': 950},
          {'build_inicio': 1500, 'raster_fin': 4000},
          {'build_inicio': 2500, 'raster_fin': 5000},
          {'build_inicio': 7000, 'raster_fin': 7500},
        ],
      };
      expect(latenciaSinTrazaMs(sinTraza), 4.0);
      expect(latenciaSinTrazaMs({'marca_us': 1000}), isNull);
      final eventos = [
        {'name': 'Animator::BeginFrame', 'ph': 'B', 'ts': 1503},
        {'name': 'Animator::BeginFrame', 'ph': 'E', 'ts': 1600},
        {'name': 'Animator::BeginFrame', 'ph': 'B', 'ts': 2495},
        {'name': 'Animator::BeginFrame', 'ph': 'E', 'ts': 2600},
      ];
      expect(desfaseDeRelojesUs(eventos, sinTraza['cuadros'] as List), 4);
    });

    test('la repetición 0 queda marcada como en frío', () {
      final filas = filasDeLaRespuesta({
        't99': {
          'medidas': [
            for (var r = 0; r < 2; r++)
              {
                'escenario': 'parseo', 'repeticion': r, 'cronometro_us': 2000,
                'eventos': [
                  {'name': 't99_parseo', 'ph': 'B', 'ts': 0},
                  {'name': 't99_parseo', 'ph': 'E', 'ts': 1500},
                ],
              }
          ]
        }
      });
      expect(filas.where((f) => f.metrica == 'duracion_ms').map((f) => f.valor), [1.5, 1.5]);
      expect(filas.first.descartada, isTrue);
      expect(filas.last.descartada, isFalse);
    });

    test('RAM: estable al volver a Lista y pico del escenario', () {
      final csv = StringBuffer('plataforma,archivo,corrida,paso,lectura,ts,bytes\n');
      var n = 0;
      for (final (paso, mb) in [('inicio', 900), ('cargar', 150), ('bahias', 210), ('lista', 180)]) {
        for (var i = 0; i < 5; i++) {
          csv.writeln('windows,A01,2,$paso,$i,t${n++},${(mb + i) * 1000000}');
        }
      }
      final r = resumirCorrida(leerLecturas(csv.toString()));
      expect(r.estable, 182);
      expect(r.pico, 214);
      expect(r.faltan, ['bay_plan', 'estadisticas', 'buscar']);
    });
  });
}
