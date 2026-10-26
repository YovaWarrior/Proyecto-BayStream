// T-121 · Lo común a las pruebas de Estadísticas (DESIGN.md 15): el
// sintético de 977 contenedores en 72 bahías, la página suelta con el tema
// del muelle o de la oficina y las fuentes del producto.
//
// Buque y números sintéticos (BUQUE SINTETICO, SNTU con su dígito ISO 6346);
// nunca el corpus, la nube ni el almacén real.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_stats_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 't117_oficina_support.dart';

/// Las 72 bahías de la geometría sintética de T-99: las 24 de 40 (02, 06, …,
/// 94) y sus dos impares vecinas.
List<int> t121Bahias72() =>
    <int>[for (var b = 2; b <= 94; b += 4) ...<int>[b - 1, b, b + 1]];

/// El dígito de control ISO 6346 de diez caracteres (dueño, categoría y
/// serie), como en `tool/t99_sintetico.dart`.
int t121DigitoIso6346(String diez) {
  const valores = <String, int>{
    'A': 10, 'B': 12, 'C': 13, 'D': 14, 'E': 15, 'F': 16, 'G': 17, 'H': 18,
    'I': 19, 'J': 20, 'K': 21, 'L': 23, 'M': 24, 'N': 25, 'O': 26, 'P': 27,
    'Q': 28, 'R': 29, 'S': 30, 'T': 31, 'U': 32, 'V': 34, 'W': 35, 'X': 36,
    'Y': 37, 'Z': 38,
  };
  var suma = 0;
  for (var i = 0; i < 10; i++) {
    final c = diez[i];
    suma += (valores[c] ?? int.parse(c)) << i;
  }
  return suma % 11 % 10;
}

/// Los nueve puertos del sintético: siete a la vista y «Otros 2 puertos».
const t121Puertos = <String>[
  'GTSTC', 'USHOU', 'PAMIT', 'JMKIN', 'JMKCT', 'COSPC', 'JMKWL', 'PACCT',
  'GTPBR',
];

/// Las diez navieras del sintético: ocho a la vista y «Otras 2 navieras».
const t121Navieras = <String>[
  'SNA', 'SNB', 'SNC', 'SND', 'SNE', 'SNF', 'SNG', 'SNH', 'SNI', 'SNJ',
];

/// 977 contenedores repartidos en las 72 bahías, con nueve puertos, diez
/// navieras, llenos y vacíos, 20, 40 y 45 pies, refrigerados, peligrosas y
/// fuera de medida, y pesos de 8 a 30 t (VGM en los pares, bruto en los
/// impares). Es carga de prueba, no un viaje.
VesselVoyage t121Sintetico977() {
  final bahias = t121Bahias72();
  const filas = <int>[1, 2, 3, 4, 5, 6, 7];
  final contenedores = <ContainerUnit>[];
  for (var i = 0; i < 977; i++) {
    final bahia = bahias[i % bahias.length];
    final vuelta = i ~/ bahias.length; // 0 a 13
    final fila = filas[vuelta % filas.length];
    final nivel = vuelta < 7 ? 2 + 2 * vuelta : 82 + 2 * (vuelta - 7);
    final raw = '${bahia.toString().padLeft(3, '0')}'
        '${fila.toString().padLeft(2, '0')}${nivel.toString().padLeft(2, '0')}';
    final de20 = bahia.isOdd;
    final tipo = de20
        ? (i % 11 == 0 ? '22R1' : '22G1')
        // Las bahías pares caen en i ≡ 1 (mod 3): la condición del 45 pies
        // tiene que ser compatible con eso, o no sale ninguno.
        : (i % 9 == 1 ? 'L5G1' : (i % 4 == 0 ? '45G1' : '42G1'));
    final vacio = i % 5 == 0;
    final peso = vacio ? 2200.0 + (i % 3) * 100 : 12000.0 + (i % 19) * 1000;
    final r = i % 24;
    final puerto = r < 9
        ? t121Puertos[0]
        : r < 15
            ? t121Puertos[1]
            : r < 19
                ? t121Puertos[2]
                : r < 21
                    ? t121Puertos[3]
                    : r == 21
                        ? t121Puertos[4]
                        : r == 22
                            ? t121Puertos[5 + (i ~/ 24) % 2]
                            : t121Puertos[7 + (i ~/ 24) % 2];
    final s = i % 30;
    final naviera = s < 10
        ? t121Navieras[0]
        : s < 17
            ? t121Navieras[1]
            : s < 22
                ? t121Navieras[2]
                : s < 25
                    ? t121Navieras[3]
                    : s < 27
                        ? t121Navieras[4]
                        : s == 27
                            ? t121Navieras[5]
                            : s == 28
                                ? t121Navieras[6 + (i ~/ 30) % 2]
                                : t121Navieras[8 + (i ~/ 30) % 2];
    final diez = 'SNTU${i.toString().padLeft(6, '0')}';
    contenedores.add(ContainerUnit(
      id: 'sntu-$i',
      containerId: '$diez${t121DigitoIso6346(diez)}',
      isoSizeType: tipo,
      status: vacio ? ContainerStatus.empty : ContainerStatus.full,
      stowagePosition:
          IsoCoordinate(bay: bahia, row: fila, tier: nivel, rawCode: raw),
      grossWeight: i.isOdd ? peso : null,
      vgmWeight: i.isEven ? peso : null,
      portOfLoading: 'HNPCR',
      portOfDischarge: puerto,
      operatorCode: naviera,
      isReefer: tipo[2] == 'R',
      isDangerous: i % 50 == 7,
      isOverDimension: i % 200 == 13,
    ));
  }
  final viaje = VesselVoyage(
    id: 't121-sintetico-977',
    vessel: const Vessel(id: 'buque-sintetico', name: 'BUQUE SINTETICO'),
    voyageNumber: 'S977',
    portOfOrigin: 'HNPCR',
    containers: contenedores,
  );
  return viaje.withGeometry(VesselProfile.proposeFrom(viaje).geometry);
}

/// Las nueve bahías del plano de llegada de T-100 (`T100_LLEGADA.edi`): las
/// tres de 40 (02, 06 y 10) y sus impares vecinas.
const t121Bahias9 = <int>[1, 2, 3, 5, 6, 7, 9, 10, 11];

/// Un viaje corto de [cuantos] contenedores repartidos por igual en
/// [bahias], en bodega y en cubierta: 40 pies en las pares y 20 en las
/// impares, tres puertos y dos navieras. Con [t121Bahias9] es la forma del
/// plano de llegada (H1 de la aceptación, 10.53); es carga de prueba, no un
/// viaje.
VesselVoyage t121ViajeCorto(List<int> bahias, {int cuantos = 60}) {
  final contenedores = <ContainerUnit>[];
  for (var i = 0; i < cuantos; i++) {
    final bahia = bahias[i % bahias.length];
    final vuelta = i ~/ bahias.length;
    final fila = 1 + vuelta % 7;
    final nivel = vuelta < 4 ? 2 + 2 * vuelta : 82 + 2 * (vuelta - 4);
    final raw = '${bahia.toString().padLeft(3, '0')}'
        '${fila.toString().padLeft(2, '0')}${nivel.toString().padLeft(2, '0')}';
    final diez = 'SNTU${(500000 + i).toString().padLeft(6, '0')}';
    contenedores.add(ContainerUnit(
      id: 'corto-$i',
      containerId: '$diez${t121DigitoIso6346(diez)}',
      isoSizeType: bahia.isOdd ? '22G1' : '42G1',
      status: i % 10 == 3 ? ContainerStatus.empty : ContainerStatus.full,
      stowagePosition:
          IsoCoordinate(bay: bahia, row: fila, tier: nivel, rawCode: raw),
      grossWeight: 9000.0 + (i % 13) * 1500,
      portOfLoading: 'HNPCR',
      portOfDischarge: t121Puertos[i % 3],
      operatorCode: t121Navieras[i % 2],
    ));
  }
  final viaje = VesselVoyage(
    id: 't121-corto-${bahias.length}',
    vessel: const Vessel(id: 'buque-sintetico', name: 'BUQUE SINTETICO'),
    voyageNumber: 'S${bahias.length}',
    portOfOrigin: 'HNPCR',
    containers: contenedores,
  );
  return viaje.withGeometry(VesselProfile.proposeFrom(viaje).geometry);
}

/// La página de Estadísticas suelta, con el tema del muelle o de la oficina,
/// las fuentes del producto y un `ProviderScope` (la tabla se anota en
/// `cerrablesDeAtrasProvider`). Devuelve el contenedor de Riverpod.
Future<ProviderContainer> t121Pump(
  WidgetTester tester, {
  required VesselVoyage voyage,
  Size tamano = const Size(1920, 1000),
  double letra = 1.0,
  bool oscuro = false,
  bool muelle = false,
  ValueChanged<int>? onBahia,
}) async {
  await t117CargarFuentes();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamano;
  addTearDown(tester.view.reset);
  if (letra != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = letra;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final scope = ProviderContainer();
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: MaterialApp(
      theme: BayStreamTema.claro(muelle: muelle),
      darkTheme: BayStreamTema.oscuro(muelle: muelle),
      themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: VoyageStatsView(
          voyage: voyage,
          onBaySelected: onBahia ?? (int _) {},
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return scope;
}

/// La columna que se desplaza de la página.
ScrollableState t121Columna(WidgetTester tester) => tester.state<ScrollableState>(
    find
        .descendant(
            of: find.byKey(const ValueKey<String>('estadisticas-scroll')),
            matching: find.byType(Scrollable))
        .first);

/// El desplazamiento horizontal del buque en corte.
ScrollableState t121Buque(WidgetTester tester) => tester.state<ScrollableState>(
    find
        .descendant(
            of: find.byKey(const ValueKey<String>('buque-en-corte-scroll')),
            matching: find.byType(Scrollable))
        .first);

/// Los textos sin espacio normal (códigos, cifras, una sola palabra) que se
/// partieron en más de una línea dentro de [donde]: una palabra partida no es
/// un texto cortado con elipsis, pero tampoco se lee.
List<String> t121PalabrasPartidas(WidgetTester tester, Finder donde) {
  final partidas = <String>[];
  for (final elemento in donde.evaluate()) {
    void visitar(RenderObject r) {
      if (r is RenderBox && r.hasSize && r.size.isEmpty) return;
      if (r is RenderParagraph) {
        final texto = r.text.toPlainText();
        if (texto.isNotEmpty &&
            !texto.contains(' ') &&
            r.getMaxIntrinsicWidth(double.infinity) > r.size.width + 0.5) {
          partidas.add(texto);
        }
      }
      r.visitChildren(visitar);
    }

    final raiz = elemento.renderObject;
    if (raiz != null) visitar(raiz);
  }
  return partidas;
}

/// Nada cortado ni partido dentro de [donde].
void t121NadaSeCorta(WidgetTester tester, Finder donde, {String? razon}) {
  expect(t117TextosCortados(tester, donde), isEmpty,
      reason: 'textos cortados${razon == null ? '' : ' ($razon)'}');
  expect(t121PalabrasPartidas(tester, donde), isEmpty,
      reason: 'palabras partidas${razon == null ? '' : ' ($razon)'}');
}

/// La barra de desplazamiento del buque en corte: siempre a la vista y abajo.
void t121BarraVisible(WidgetTester tester) {
  final barra = tester.widget<Scrollbar>(find.descendant(
      of: find.byKey(const ValueKey<String>('estadisticas-buque')),
      matching: find.byType(Scrollbar)));
  expect(barra.thumbVisibility, isTrue);
  expect(barra.scrollbarOrientation, ScrollbarOrientation.bottom);
}

/// Recorre la página de arriba abajo a saltos de [paso] y falla si algo se
/// desborda o se corta en el camino.
Future<void> t121RecorrerLaPagina(WidgetTester tester,
    {double paso = 400}) async {
  final posicion = t121Columna(tester).position;
  for (var y = 0.0; y <= posicion.maxScrollExtent; y += paso) {
    posicion.jumpTo(y);
    await tester.pump();
    expect(tester.takeException(), isNull, reason: 'desplazada a $y');
    t121NadaSeCorta(tester, find.byType(VoyageStatsView), razon: 'desplazada a $y');
  }
  posicion.jumpTo(posicion.maxScrollExtent);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  posicion.jumpTo(0);
  await tester.pumpAndSettle();
}
