// T-114 · Fase 2 del rediseño: los tokens, el tema y los formatos.
//
// El contraste se calcula aquí con la fórmula de WCAG 2, igual que en
// tool/rediseno_contraste.py, para que la paleta que entra al código sea la
// misma que la verificada en docs/rediseno/fase2/contraste.md.
import 'dart:math' as math;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/design/vistas_previas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _luminancia(Color color) {
  double canal(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * canal(color.r) + 0.7152 * canal(color.g) + 0.0722 * canal(color.b);
}

double _contraste(Color a, Color b) {
  final la = _luminancia(a);
  final lb = _luminancia(b);
  final alto = math.max(la, lb);
  final bajo = math.min(la, lb);
  return (alto + 0.05) / (bajo + 0.05);
}

void main() {
  group('el tema', () {
    test('claro y oscuro traen las tres extensiones y la marca del ícono', () {
      for (final tema in [BayStreamTema.claro(), BayStreamTema.oscuro()]) {
        expect(tema.useMaterial3, isTrue);
        expect(tema.extension<BsColoresSemanticos>(), isNotNull);
        expect(tema.extension<BsMedidas>(), isNotNull);
        expect(tema.extension<BsTextos>(), isNotNull);
        expect(tema.textTheme.bodyMedium?.fontFamily, BsFuentes.sans);
        expect(tema.textTheme.bodyMedium?.fontFamilyFallback, BsFuentes.respaldo);
      }
      expect(BayStreamTema.claro().colorScheme.primary, BsPaleta.claro.marca);
      expect(BayStreamTema.claro().colorScheme.surface, BsPaleta.claro.papel);
      expect(BayStreamTema.oscuro().brightness, Brightness.dark);
      expect(BayStreamTema.oscuro().colorScheme.primary, BsPaleta.oscuro.marca);
    });

    test('la densidad del muelle entra con el parámetro', () {
      expect(BayStreamTema.claro().extension<BsMedidas>()!.esMuelle, isFalse);
      expect(BayStreamTema.claro(muelle: true).extension<BsMedidas>()!.esMuelle,
          isTrue);
      expect(BayStreamTema.oscuro(muelle: true).extension<BsMedidas>()!.altoCelda,
          BsMedidas.muelle.altoCelda);
    });

    test('la tabla fija entra en la extensión semántica', () {
      final tema = BayStreamTema.claro(tablaFija: const {'GTSTC': 2});
      final semanticos = tema.extension<BsColoresSemanticos>()!;
      expect(semanticos.tablaFija['GTSTC'], 2);
      expect(semanticos.categorico('gtstc'), same(semanticos.categoricos[2]));
    });
  });

  group('el contraste de la paleta', () {
    for (final paleta in [BsPaleta.claro, BsPaleta.oscuro]) {
      final modo = paleta.brillo == Brightness.light ? 'claro' : 'oscuro';
      test('los pares de texto cumplen AA en $modo', () {
        final pares = <String, (Color, Color)>{
          'tinta sobre papel': (paleta.tinta, paleta.papel),
          'tinta sobre hoja': (paleta.tinta, paleta.hoja),
          'tinta sobre hoja alta': (paleta.tinta, paleta.hojaAlta),
          'tinta suave sobre papel': (paleta.tintaSuave, paleta.papel),
          'tinta suave sobre hoja': (paleta.tintaSuave, paleta.hoja),
          'marca sobre papel': (paleta.marca, paleta.papel),
          'sobre marca sobre marca': (paleta.sobreMarca, paleta.marca),
          'tinta sobre marca tenue': (paleta.tinta, paleta.marcaTenue),
          'tinta sobre acero tenue': (paleta.tinta, paleta.aceroTenue),
          'sobre acero sobre acero': (paleta.sobreAcero, paleta.acero),
          'grúa sobre papel': (paleta.grua, paleta.papel),
          'sobre grúa sobre grúa relleno': (paleta.sobreGrua, paleta.gruaRelleno),
        };
        for (final par in pares.entries) {
          expect(_contraste(par.value.$1, par.value.$2), greaterThanOrEqualTo(4.5),
              reason: par.key);
        }
        expect(_contraste(paleta.lineaFuerte, paleta.papel), greaterThanOrEqualTo(3),
            reason: 'línea fuerte sobre papel');
        expect(_contraste(paleta.grua, paleta.papel), greaterThanOrEqualTo(3),
            reason: 'contorno de grúa sobre papel');
      });
    }

    for (final (modo, semanticos, papel) in [
      ('claro', BsColoresSemanticos.claro(), BsPaleta.claro.papel),
      ('oscuro', BsColoresSemanticos.oscuro(), BsPaleta.oscuro.papel),
    ]) {
      test('los roles semánticos cumplen AA en $modo', () {
        final roles = <String, BsRol>{
          'pendiente': semanticos.pendiente,
          'hecho': semanticos.hecho,
          'cancelado': semanticos.cancelado,
          'revisar': semanticos.revisar,
          'error': semanticos.error,
          'peligrosa': semanticos.peligrosa,
          'refrigerado': semanticos.refrigerado,
          'oog': semanticos.oog,
          'de paso': semanticos.dePaso,
          'reservado': semanticos.reservado,
          'en movimiento': semanticos.enMovimiento,
          'cubierta': semanticos.cubierta,
          'bodega': semanticos.bodega,
        };
        for (final rol in roles.entries) {
          expect(_contraste(rol.value.texto, rol.value.relleno),
              greaterThanOrEqualTo(4.5),
              reason: '${rol.key}: texto sobre relleno');
          expect(_contraste(rol.value.contorno, papel), greaterThanOrEqualTo(3),
              reason: '${rol.key}: contorno sobre papel');
        }
      });

      test('las 24 ranuras categóricas cumplen AA en $modo', () {
        expect(semanticos.categoricos, hasLength(ranurasCategoricas));
        for (var k = 0; k < ranurasCategoricas; k++) {
          final rol = semanticos.categoricos[k];
          expect(_contraste(rol.texto, rol.relleno), greaterThanOrEqualTo(4.5),
              reason: 'ranura $k: texto sobre relleno');
          expect(_contraste(rol.contorno, papel), greaterThanOrEqualTo(3),
              reason: 'ranura $k: contorno sobre papel');
        }
      });
    }
  });

  group('la ranura categórica', () {
    test('es estable, va de 0 a 23 y no distingue mayúsculas', () {
      for (final codigo in ['GTSTC', 'USHOU', '45G1', 'L5G1', 'XXVSL', '']) {
        final ranura = ranuraCategorica(codigo);
        expect(ranura, inInclusiveRange(0, ranurasCategoricas - 1));
        expect(ranuraCategorica(codigo.toLowerCase()), ranura);
        expect(ranuraCategorica(' $codigo '), ranura);
      }
    });

    test('da lo mismo que la referencia de tool/rediseno_contraste.py', () {
      expect(fnv1a32(''), 0x811C9DC5);
      expect(ranuraCategorica('MXVER'), 21);
      expect(ranuraCategorica('PABLB'), 18);
      expect(ranuraCategorica('22P1'), 10);
    });

    test('la tabla fija manda sobre el cálculo', () {
      expect(ranuraCategorica('GTSTC', tablaFija: const {'GTSTC': 2}), 2);
      expect(ranuraCategorica('gtstc', tablaFija: const {'GTSTC': 2}), 2);
      expect(ranuraCategorica('GTSTC', tablaFija: const {'GTSTC': 26}), 2);
      expect(ranuraCategorica('USHOU', tablaFija: const {'GTSTC': 2}),
          ranuraCategorica('USHOU'));
    });
  });

  group('las medidas', () {
    test('nada que se toca baja de 48 dp y la celda del muelle mide 56 × 48', () {
      for (final medidas in [BsMedidas.oficina, BsMedidas.muelle]) {
        expect(medidas.objetivoTactil, 48);
        expect(medidas.altoCelda, greaterThanOrEqualTo(48));
        expect(medidas.alturaFila, greaterThanOrEqualTo(48));
        expect(medidas.alturaCampo, greaterThanOrEqualTo(48));
        expect(medidas.alturaBotonPrincipal, greaterThanOrEqualTo(48));
      }
      expect(BsMedidas.muelle.anchoCelda, 56);
      expect(BsMedidas.muelle.altoCelda, 48);
      expect(BsMedidas.muelle.alturaBotonPrincipal, 56);
      expect(BsMedidas.oficina.anchoCelda, 52);
    });

    test('la escala tipográfica no baja de 10 y el muelle no baja de 11', () {
      expect(BsEscala.celdaLinea2, greaterThanOrEqualTo(10));
      expect(BsEscala.celda, greaterThanOrEqualTo(BsEscala.rotuloMinimo));
      expect(BsEscala.rotuloMinimo, 11);
    });
  });

  group('los formatos', () {
    test('el número de contenedor se agrupa en propietario, serie y control', () {
      expect(formatearContenedor('MSCU1234567'), 'MSCU 123456 7');
      expect(formatearContenedor(' mscu 123456 7 '), 'MSCU 123456 7');
      expect(formatearContenedor('ABC'), 'ABC');
    });

    test('la posición se escribe como en el plano impreso', () {
      expect(formatearPosicion('0020182'), '002-01-82');
      expect(formatearPosicion('002-01-82'), '002-01-82');
      expect(formatearPosicion('002 01 82'), '002-01-82');
      expect(formatearPosicion('sin posición'), 'sin posición');
    });

    test('el peso va en toneladas con un decimal y los kilos agrupados', () {
      expect(formatearToneladas(28650), '28.7 t');
      expect(formatearToneladas(28640), '28.6 t');
      expect(formatearToneladas(-28650), '−28.7 t');
      expect(formatearKilos(28650), '28 650 kg');
      expect(formatearKilos(950), '950 kg');
      expect(formatearKilos(1234567), '1 234 567 kg');
      expect(formatearPorcentaje(0.91), '91 %');
      expect(formatearCuenta(1, 'contenedor', 'contenedores'), '1 contenedor');
      expect(formatearCuenta(3, 'contenedor', 'contenedores'), '3 contenedores');
    });
  });

  group('el movimiento', () {
    testWidgets('respeta la reducción de movimiento del sistema', (tester) async {
      Duration? conAnimaciones;
      Duration? sinAnimaciones;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          conAnimaciones = BsMovimiento.de(context, BsMovimiento.hoja);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: Builder(builder: (context) {
              sinAnimaciones = BsMovimiento.de(context, BsMovimiento.hoja);
              return const SizedBox();
            }),
          );
        }),
      ));
      expect(conAnimaciones, BsMovimiento.hoja);
      expect(sinAnimaciones, Duration.zero);
      expect(BsMovimiento.hoja, lessThanOrEqualTo(const Duration(milliseconds: 300)));
    });
  });

  group('las vistas previas', () {
    final previas = <String, Widget Function()>{
      'celdas': vistaPreviaCeldas,
      'celdas oscuro': vistaPreviaCeldasOscuro,
      'tira de bahías': vistaPreviaTiraDeBahias,
      'cartela': vistaPreviaCartela,
      'bandas': vistaPreviaBandas,
      'cifra': vistaPreviaCifra,
      'hoja de detalle': vistaPreviaHojaDeDetalle,
      'barra de operación': vistaPreviaBarraDeOperacion,
    };
    for (final previa in previas.entries) {
      testWidgets('${previa.key} se construye en claro y en oscuro',
          (tester) async {
        for (final tema in [
          BayStreamTema.claro(muelle: true),
          BayStreamTema.oscuro(muelle: true)
        ]) {
          await tester.pumpWidget(MaterialApp(
            theme: tema,
            home: Scaffold(body: previa.value()),
          ));
          expect(tester.takeException(), isNull);
        }
      });
    }
    test('el tema de las vistas previas es el de la dirección A', () {
      final datos = bsTemaDeVistaPrevia();
      expect(datos.materialLight?.colorScheme.primary, BsPaleta.claro.marca);
      expect(datos.materialDark?.brightness, Brightness.dark);
    });
  });
}
