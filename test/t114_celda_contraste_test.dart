// T-114 · Corrección de la Fase 2 (10.7, H1): el contraste de la celda medido
// sobre lo que se dibuja.
//
// Para cada estado, tema, densidad y fondo, compone con Color.alphaBlend el
// relleno sobre el fondo, el texto y los iconos sobre el relleno compuesto y
// el contorno sobre el relleno, y exige 4.5:1 para el texto y 3:1 para los
// iconos y el contorno. No usa textContrastGuideline: ese matcher busca el
// texto por la etiqueta de semántica, y la celda expone una etiqueta
// descriptiva distinta del código, así que no lo medía
// (docs/rediseno/fase2/aceptacion-codex.md). La etiqueta se conserva.
import 'dart:math' as math;

import 'package:baystream/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void _nada() {}

typedef _Estado = ({String nombre, bool esHueco, BsCelda Function(BsColoresSemanticos) celda});

/// Todos los estados de la celda (10.7, punto 1): normal, atenuada, cancelada,
/// de paso, reservada y en movimiento, más las otras marcas, las insignias, la
/// resaltada y el hueco, cada uno también atenuado.
List<_Estado> _estados() {
  final estados = <_Estado>[];
  void agrega(String nombre, BsCelda Function(BsColoresSemanticos) celda,
      {bool esHueco = false}) {
    estados.add((nombre: nombre, esHueco: esHueco, celda: celda));
  }

  for (var k = 0; k < ranurasCategoricas; k++) {
    for (final atenuada in [false, true]) {
      agrega(
        'ranura $k${atenuada ? ' atenuada' : ''}',
        (s) => BsCelda(
          codigo: 'R$k',
          linea2: '28.7',
          categoria: s.categoricos[k],
          atenuada: atenuada,
          etiqueta: 'ranura $k',
          onTap: _nada,
        ),
      );
    }
  }
  for (final marca in BsMarcaDeCelda.values) {
    if (marca == BsMarcaDeCelda.ninguna) continue;
    for (final atenuada in [false, true]) {
      agrega(
        'marca ${marca.name}${atenuada ? ' atenuada' : ''}',
        (s) => BsCelda(
          codigo: 'GTSTC',
          marca: marca,
          categoria: s.categorico('GTSTC'),
          atenuada: atenuada,
          etiqueta: 'marca ${marca.name}',
          onTap: _nada,
        ),
      );
    }
  }
  for (final insignia in BsInsigniaDeCelda.values) {
    if (insignia == BsInsigniaDeCelda.ninguna) continue;
    for (final atenuada in [false, true]) {
      agrega(
        'insignia ${insignia.name}${atenuada ? ' atenuada' : ''}',
        (s) => BsCelda(
          codigo: 'USHOU',
          insignia: insignia,
          categoria: s.categorico('USHOU'),
          atenuada: atenuada,
          etiqueta: 'insignia ${insignia.name}',
          onTap: _nada,
        ),
      );
    }
  }
  for (final atenuada in [false, true]) {
    agrega(
      'reservada${atenuada ? ' atenuada' : ''}',
      (s) => BsCelda(
        codigo: '45G1',
        reservada: true,
        atenuada: atenuada,
        etiqueta: 'reserva',
        onTap: _nada,
      ),
    );
    agrega(
      'resaltada${atenuada ? ' atenuada' : ''}',
      (s) => BsCelda(
        codigo: 'GTSTC',
        resaltada: true,
        categoria: s.categorico('GTSTC'),
        atenuada: atenuada,
        etiqueta: 'resaltada',
        onTap: _nada,
      ),
    );
    agrega(
      'hueco${atenuada ? ' atenuado' : ''}',
      (s) => BsCelda(codigo: '', atenuada: atenuada, etiqueta: 'hueco'),
      esHueco: true,
    );
  }
  agrega(
    'reservada resaltada',
    (s) => const BsCelda(
      codigo: '45G1',
      reservada: true,
      resaltada: true,
      etiqueta: 'reserva resaltada',
    ),
  );
  return estados;
}

/// Lo que la celda dibuja, compuesto sobre [fondo] como lo compone Flutter.
({Color fondoCompuesto, Color bordeCompuesto, int tintas}) _medir(
  WidgetTester tester,
  Color fondo,
  String donde,
) {
  final celda = find.byType(BsCelda);
  final contenedor = tester.widget<Container>(
      find.descendant(of: celda, matching: find.byType(Container)).first);
  final decoracion = contenedor.decoration! as BoxDecoration;
  final relleno = decoracion.color!;
  final borde = (decoracion.border! as Border).top;
  final fondoCompuesto = Color.alphaBlend(relleno, fondo);
  // El contorno se pinta encima del relleno, dentro de la caja.
  final bordeCompuesto = Color.alphaBlend(borde.color, fondoCompuesto);

  var tintas = 0;
  for (final rico in tester.widgetList<RichText>(
      find.descendant(of: celda, matching: find.byType(RichText)))) {
    final tramo = rico.text as TextSpan;
    final estilo = tramo.style!;
    final esIcono = estilo.fontFamily == 'MaterialIcons';
    if (!esIcono && tramo.toPlainText().isEmpty) continue;
    final compuesto = Color.alphaBlend(estilo.color!, fondoCompuesto);
    expect(
      _contraste(compuesto, fondoCompuesto),
      greaterThanOrEqualTo(esIcono ? 3.0 : 4.5),
      reason: '$donde: ${esIcono ? 'icono' : 'texto «${tramo.toPlainText()}»'} '
          '${compuesto.toARGB32().toRadixString(16)} sobre '
          '${fondoCompuesto.toARGB32().toRadixString(16)}',
    );
    tintas++;
  }
  return (
    fondoCompuesto: fondoCompuesto,
    bordeCompuesto: bordeCompuesto,
    tintas: tintas,
  );
}

void main() {
  for (final oscuro in [false, true]) {
    for (final muelle in [true, false]) {
      final modo = '${oscuro ? 'oscuro' : 'claro'}, '
          '${muelle ? 'muelle' : 'oficina'}';
      final tema = oscuro
          ? BayStreamTema.oscuro(muelle: muelle)
          : BayStreamTema.claro(muelle: muelle);

      testWidgets(
          'todos los estados de la celda cumplen 4.5:1 y 3:1 compuestos en $modo',
          (tester) async {
        final semanticos = tema.extension<BsColoresSemanticos>()!;
        // El papel y las dos zonas de la rejilla: la cubierta (hoja) y la
        // bodega (acero tenue).
        final fondos = <String, Color>{
          'papel': tema.colorScheme.surface,
          'cubierta': semanticos.cubierta.relleno,
          'bodega': semanticos.bodega.relleno,
        };
        var estadosMedidos = 0;
        var tintasMedidas = 0;
        for (final fondo in fondos.entries) {
          for (final estado in _estados()) {
            final donde = '${estado.nombre} sobre ${fondo.key} en $modo';
            await tester.pumpWidget(MaterialApp(
              theme: tema,
              home: Scaffold(
                body: ColoredBox(
                  color: fondo.value,
                  child: Center(child: estado.celda(semanticos)),
                ),
              ),
            ));
            expect(tester.takeException(), isNull, reason: donde);
            final medida = _medir(tester, fondo.value, donde);
            if (!estado.esHueco) {
              // El hueco lleva la línea de separación de 1 dp (DESIGN 4.3),
              // que no es un contorno esencial: no tiene nada dentro.
              expect(
                _contraste(medida.bordeCompuesto, fondo.value),
                greaterThanOrEqualTo(3.0),
                reason: '$donde: contorno '
                    '${medida.bordeCompuesto.toARGB32().toRadixString(16)} '
                    'sobre ${fondo.value.toARGB32().toRadixString(16)}',
              );
            }
            estadosMedidos++;
            tintasMedidas += medida.tintas;
          }
        }
        // 24 ranuras × 2 + 7 marcas × 2 + 3 insignias × 2 + 7 = 75 estados,
        // sobre tres fondos.
        expect(estadosMedidos, 225);
        expect(tintasMedidas, greaterThan(225));
      });
    }
  }

  group('H1 de la aceptación de Codex: la celda atenuada y tocable', () {
    for (final oscuro in [false, true]) {
      final modo = oscuro ? 'oscuro' : 'claro';
      final tema = oscuro
          ? BayStreamTema.oscuro(muelle: true)
          : BayStreamTema.claro(muelle: true);
      testWidgets('el código queda en 4.5:1 y la etiqueta se conserva en $modo',
          (tester) async {
        final semantica = tester.ensureSemantics();
        await tester.pumpWidget(MaterialApp(
          theme: tema,
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => BsCelda(
                  codigo: 'GTSTC',
                  etiqueta: 'Contenedor fuera del filtro',
                  categoria:
                      BsColoresSemanticos.de(context).categorico('GTSTC'),
                  atenuada: true,
                  onTap: _nada,
                ),
              ),
            ),
          ),
        ));
        final texto = tester.widget<Text>(find.text('GTSTC'));
        final contenedor = tester.widget<Container>(find
            .descendant(
                of: find.byType(BsCelda), matching: find.byType(Container))
            .first);
        final relleno = (contenedor.decoration! as BoxDecoration).color!;
        final fondo = Color.alphaBlend(relleno, tema.scaffoldBackgroundColor);
        final tinta = Color.alphaBlend(texto.style!.color!, fondo);
        expect(_contraste(tinta, fondo), greaterThanOrEqualTo(4.5));
        // El relleno sí baja: es el del rol al 35 % sobre el papel, opaco.
        final normal = tema.extension<BsColoresSemanticos>()!.categorico('GTSTC');
        expect(
            relleno,
            Color.alphaBlend(
                normal.relleno.withValues(alpha: BsCelda.alfaAtenuada),
                tema.colorScheme.surface));
        expect(relleno, isNot(normal.relleno));
        expect(relleno.a, 1.0, reason: 'compuesto en el tema, sin alfa');
        expect(texto.style!.color!.a, 1.0, reason: 'el texto no lleva alfa');
        expect(
          tester.getSemantics(find.byType(BsCelda)),
          matchesSemantics(
            label: 'Contenedor fuera del filtro',
            isButton: true,
            hasTapAction: true,
          ),
        );
        expect(find.byType(Opacity), findsNothing);
        semantica.dispose();
      });
    }
  });
}
