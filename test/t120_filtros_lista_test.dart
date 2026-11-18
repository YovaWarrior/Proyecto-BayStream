// T-120 · Los filtros de la Lista (DESIGN.md 18.1 y 18.2): la naviera, el
// destino y la carga especial, con sus cuentas cruzadas; el título, «Quitar
// filtros» y el chip elegido. Y la tarjeta y la hoja de la Lista (D1 y D8).
//
// Buque sintético (BUQUE LISTA, TSTU); sin nube ni almacén real.
import 'dart:math' as math;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/formatters/consulta_de_busqueda.dart';
import 'package:baystream/features/vessel/presentation/formatters/cuentas_de_los_filtros.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/containers_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t120_lista_support.dart';

/// Las cuentas a mano, contenedor por contenedor, para comparar.
int _aMano(List<ContainerUnit> todos, bool Function(ContainerUnit) pasa) =>
    todos.where(pasa).length;

List<String> _clavesDe(WidgetTester tester, String fila) => tester
    .widgetList<FilterChip>(find.byType(FilterChip))
    .map((c) => (c.key! as ValueKey<String>).value)
    .where((k) => k.startsWith('filtro-$fila-'))
    .toList();

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
}

void main() {
  final todos = t120Viaje().containers;

  group('las cuentas (CuentasDeLosFiltros)', () {
    test('sin filtros: cada chip cuenta el viaje, de más a menos, y «Sin '
        'destino» al final', () {
      final c = CuentasDeLosFiltros.de(todos, const FiltrosDeLaLista());
      expect(c.todosLosDestinos, todos.length);
      expect(c.todasLasNavieras, todos.length);
      expect(c.filtrados, hasLength(todos.length));
      expect(c.destinos.first.clave, 'GTSTC');
      expect(c.destinos.last.clave, FiltrosDeLaLista.sinDestino);
      final sinUltimo = c.destinos.take(c.destinos.length - 1).toList();
      for (var i = 1; i < sinUltimo.length; i++) {
        final a = sinUltimo[i - 1];
        final b = sinUltimo[i];
        expect(
            a.delViaje > b.delViaje ||
                (a.delViaje == b.delViaje && a.clave.compareTo(b.clave) < 0),
            isTrue,
            reason: '${a.clave} antes que ${b.clave}');
      }
      for (final f in c.destinos) {
        expect(f.cuenta, f.delViaje);
        expect(
            f.delViaje,
            _aMano(todos,
                (x) => FiltrosDeLaLista.claveDeDestino(x) == f.clave));
      }
      expect(c.navieras.map((f) => f.clave), ['LNA', 'LNB', 'LNC', 'LND']);
      expect(c.cargas.map((f) => f.clave), CargaEspecial.values);
    });

    test('las cuentas cruzadas: con una naviera, cada destino cuenta los de '
        'esa naviera, y al revés; el orden no cambia (10.147, punto 1)', () {
      final libre = CuentasDeLosFiltros.de(todos, const FiltrosDeLaLista());
      final c =
          CuentasDeLosFiltros.de(todos, const FiltrosDeLaLista(naviera: 'LND'));
      expect(c.destinos.map((f) => f.clave), libre.destinos.map((f) => f.clave));
      expect(c.navieras.map((f) => f.clave), libre.navieras.map((f) => f.clave));
      for (final f in c.destinos) {
        expect(
            f.cuenta,
            _aMano(
                todos,
                (x) =>
                    x.operatorCode == 'LND' &&
                    FiltrosDeLaLista.claveDeDestino(x) == f.clave),
            reason: f.clave);
      }
      expect(c.todosLosDestinos, _aMano(todos, (x) => x.operatorCode == 'LND'));
      // La fila de navieras no se filtra por sí misma.
      expect(c.todasLasNavieras, todos.length);

      final d = CuentasDeLosFiltros.de(
          todos, const FiltrosDeLaLista(destino: 'PAMIT'));
      for (final f in d.navieras) {
        expect(
            f.cuenta,
            _aMano(todos,
                (x) => x.portOfDischarge == 'PAMIT' && x.operatorCode == f.clave));
      }
      expect(d.navieras.map((f) => f.clave), libre.navieras.map((f) => f.clave));
    });

    test('un chip que queda en cero sigue en su lugar, con cero', () {
      final c = CuentasDeLosFiltros.de(
          todos, const FiltrosDeLaLista(destino: FiltrosDeLaLista.sinDestino));
      final ceros = c.navieras.where((f) => f.cuenta == 0);
      expect(ceros, isNotEmpty, reason: 'los sin destino no traen las cuatro');
      expect(c.navieras, hasLength(4));
    });

    test('la carga especial: cualquiera de ellas (D7), cruzada con lo demás',
        () {
      final c = CuentasDeLosFiltros.de(
          todos,
          const FiltrosDeLaLista(
              cargas: {CargaEspecial.refrigerado, CargaEspecial.peligrosa}));
      expect(c.filtrados,
          everyElement(predicate<ContainerUnit>((x) => x.isReefer || x.isDangerous)));
      expect(c.filtrados.length,
          _aMano(todos, (x) => x.isReefer || x.isDangerous));
      final g = CuentasDeLosFiltros.de(todos,
          const FiltrosDeLaLista(destino: 'GTSTC', naviera: 'LNA'));
      for (final f in g.cargas) {
        expect(
            f.cuenta,
            _aMano(
                todos,
                (x) =>
                    f.clave.en(x) &&
                    x.portOfDischarge == 'GTSTC' &&
                    x.operatorCode == 'LNA'));
      }
      expect(g.todasLasCargas,
          _aMano(todos, (x) => x.portOfDischarge == 'GTSTC' && x.operatorCode == 'LNA'));
    });

    test('«Sin destino»: sin LOC+11 o con el código en blanco', () {
      const blanco = ContainerUnit(
          id: 'b', containerId: 'TSTU9999991', portOfDischarge: '  ');
      const nulo = ContainerUnit(id: 'n', containerId: 'TSTU9999992');
      final c = CuentasDeLosFiltros.de(
          [blanco, nulo], const FiltrosDeLaLista(destino: ''));
      expect(c.destinos.single.clave, FiltrosDeLaLista.sinDestino);
      expect(c.destinos.single.cuenta, 2);
      expect(c.filtrados, hasLength(2));
      expect(c.cargas, isEmpty, reason: 'sin carga especial, la fila no sale');
    });

    test('los tres filtros a la vez son los que lista la Lista', () {
      const filtros = FiltrosDeLaLista(
          naviera: 'LNA', destino: 'GTSTC', cargas: {CargaEspecial.refrigerado});
      expect(filtros.activos, isTrue);
      expect(const FiltrosDeLaLista().activos, isFalse);
      final c = CuentasDeLosFiltros.de(todos, filtros);
      expect(c.filtrados, todos.where(filtros.coincide).toList());
      expect(c.filtrados, isNotEmpty);
    });
  });

  group('en la Lista', () {
    testWidgets('las tres filas, con «naviera» en minúscula', (tester) async {
      await t120Pump(tester);
      expect(find.text('Filtrar por naviera'), findsOneWidget);
      expect(find.text('Filtrar por Naviera'), findsNothing);
      expect(find.text('Filtrar por destino'), findsOneWidget);
      expect(find.text('Carga especial'), findsOneWidget);
      expect(find.text('Contenedores (120)'), findsOneWidget);
      expect(find.byKey(const ValueKey('quitar-filtros')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('elegir un destino filtra, el título lo dice y «Quitar '
        'filtros» lo suelta', (tester) async {
      final scope = await t120Pump(tester);
      await _tocar(tester, t120Chip('destino', 'PAMIT'));
      await tester.pumpAndSettle();
      final pamit = _aMano(todos, (x) => x.portOfDischarge == 'PAMIT');
      expect(find.text('Contenedores ($pamit), destino PAMIT'), findsOneWidget);
      expect(scope.read(filteredContainersProvider), hasLength(pamit));
      await tester.tap(find.byKey(const ValueKey('quitar-filtros')));
      await tester.pumpAndSettle();
      expect(find.text('Contenedores (120)'), findsOneWidget);
      expect(scope.read(selectedDischargePortProvider), isNull);
    });

    testWidgets('naviera y destino a la vez; el chip en cero se apaga',
        (tester) async {
      final scope = await t120Pump(tester);
      await _tocar(tester, t120Chip('naviera', 'LND'));
      await tester.pumpAndSettle();
      await _tocar(tester, t120Chip('destino', 'GTSTC'));
      await tester.pumpAndSettle();
      final n = _aMano(todos,
          (x) => x.operatorCode == 'LND' && x.portOfDischarge == 'GTSTC');
      expect(find.text('Contenedores ($n), naviera LND, destino GTSTC'),
          findsOneWidget);
      scope.read(selectedDischargePortProvider.notifier).select('');
      await tester.pumpAndSettle();
      final ceros = CuentasDeLosFiltros.de(
              todos, const FiltrosDeLaLista(destino: ''))
          .navieras
          .where((f) => f.cuenta == 0)
          .map((f) => f.clave);
      for (final clave in ceros) {
        final chip = tester.widget<FilterChip>(t120Chip('naviera', clave));
        expect(chip.onSelected, isNull, reason: clave);
      }
    });

    testWidgets('el orden de los chips no cambia al elegir el otro filtro',
        (tester) async {
      await t120Pump(tester);
      final antes = _clavesDe(tester, 'destino');
      final navierasAntes = _clavesDe(tester, 'naviera');
      await _tocar(tester, t120Chip('naviera', 'LND'));
      await tester.pumpAndSettle();
      expect(_clavesDe(tester, 'destino'), antes);
      await _tocar(tester, t120Chip('destino', 'USHOU'));
      await tester.pumpAndSettle();
      expect(_clavesDe(tester, 'naviera'), navierasAntes);
    });

    for (final oscuro in [false, true]) {
      testWidgets(
          'el elegido se distingue sin el color: borde de 2 dp en la tinta '
          'y cifra en negrita (${oscuro ? 'noche' : 'día'})', (tester) async {
        await t120Pump(tester, oscuro: oscuro);
        await _tocar(tester, t120Chip('destino', 'USHOU'));
        await tester.pumpAndSettle();
        final esquema =
            Theme.of(tester.element(t120Chip('destino', 'USHOU'))).colorScheme;
        final elegido = tester.widget<FilterChip>(t120Chip('destino', 'USHOU'));
        final otro = tester.widget<FilterChip>(t120Chip('destino', 'GTSTC'));
        expect(elegido.showCheckmark, isFalse);
        expect(elegido.side!.width, 2);
        expect(otro.side!.width, 1);
        expect(elegido.side!.color, esquema.onSurface);
        expect(elegido.side!.color, isNot(otro.side!.color));
        FontWeight? pesoDe(String clave) => tester
            .widgetList<Text>(find.descendant(
                of: t120Chip('destino', clave), matching: find.byType(Text)))
            .last
            .style
            ?.fontWeight;
        expect(pesoDe('USHOU'), FontWeight.w700);
        expect(pesoDe('GTSTC'), FontWeight.w500);
        expect(tester.takeException(), isNull);
      });
    }

    for (final oscuro in [false, true]) {
      testWidgets(
          'el texto de cada chip, elegido o no, pasa 4.5:1 contra su fondo '
          '(${oscuro ? 'noche' : 'día'}; visto en las capturas del banco)',
          (tester) async {
        await t120Pump(tester, oscuro: oscuro);
        await _tocar(tester, t120Chip('destino', 'USHOU'));
        await tester.pumpAndSettle();
        final chipTema =
            Theme.of(tester.element(t120Chip('destino', 'USHOU'))).chipTheme;
        double contraste(Color a, Color b) {
          final (x, y) = (a.computeLuminance(), b.computeLuminance());
          return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
        }

        var medidos = 0;
        for (final chip in tester.widgetList<FilterChip>(find.byType(FilterChip))) {
          if (chip.onSelected == null) continue;
          final fondo =
              chip.selected ? chipTema.selectedColor! : chipTema.backgroundColor!;
          final textos = find.descendant(
              of: find.byWidget(chip), matching: find.byType(RichText));
          for (final e in textos.evaluate()) {
            final dentroDeLaCaja = find
                .ancestor(
                    of: find.byWidget(e.widget),
                    matching: find.byType(BsCajaDeCodigo))
                .evaluate()
                .isNotEmpty;
            if (dentroDeLaCaja) continue;
            final parrafo = e.renderObject! as RenderParagraph;
            final color = parrafo.text.style!.color!;
            expect(contraste(color, fondo), greaterThanOrEqualTo(4.5),
                reason: '«${parrafo.text.toPlainText()}», '
                    '${chip.selected ? 'elegido' : 'sin elegir'}');
            medidos++;
          }
        }
        expect(medidos, greaterThan(10));
      });
    }

    testWidgets('el lector de pantalla oye el nombre y la cuenta, una vez',
        (tester) async {
      final semantica = tester.ensureSemantics();
      await t120Pump(tester);
      final ushou = _aMano(todos, (x) => x.portOfDischarge == 'USHOU');
      final nodo = tester.getSemantics(t120Chip('destino', 'USHOU'));
      expect(nodo.label, 'USHOU, $ushou contenedores');
      expect(RegExp('USHOU').allMatches('${nodo.label} ${nodo.tooltip}'),
          hasLength(1));
      await _tocar(tester, t120Chip('destino', 'USHOU'));
      await tester.pumpAndSettle();
      expect(tester.getSemantics(t120Chip('destino', 'USHOU')),
          containsSemantics(isSelected: true));
      semantica.dispose();
    });

    testWidgets('«Sin destino» filtra los que no traen puerto', (tester) async {
      final scope = await t120Pump(tester);
      await _tocar(tester, t120Chip('destino', 'sin-destino'));
      await tester.pumpAndSettle();
      final lista = scope.read(filteredContainersProvider);
      expect(lista, hasLength(1));
      expect(lista.single.portOfDischarge, isNull);
      expect(find.text('Contenedores (1), sin destino'), findsOneWidget);
    });

    testWidgets('la carga especial filtra cualquiera de las elegidas',
        (tester) async {
      final scope = await t120Pump(tester);
      await _tocar(tester, t120Chip('carga', 'refrigerado'));
      await tester.pumpAndSettle();
      await _tocar(tester, t120Chip('carga', 'fueraDeMedida'));
      await tester.pumpAndSettle();
      final n = _aMano(todos, (x) => x.isReefer || x.isOverDimension);
      expect(scope.read(filteredContainersProvider), hasLength(n));
      expect(find.text('Contenedores ($n), refrigerado o fuera de medida'),
          findsOneWidget);
    });

    testWidgets('sin resultados por los filtros, lo dice y ofrece quitarlos',
        (tester) async {
      final scope = await t120Pump(tester);
      scope.read(selectedCarrierProvider.notifier).select('NINGUNA');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
          find.text('Ningún contenedor coincide con estos filtros'), 200,
          scrollable: find.descendant(
              of: find.byKey(const ValueKey('lista-scroll')),
              matching: find.byType(Scrollable)));
      expect(find.text('Ningún contenedor coincide con estos filtros'),
          findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Quitar filtros').last);
      await tester.pumpAndSettle();
      expect(find.text('Contenedores (120)'), findsOneWidget);
    });
  });

  group('la tarjeta y la hoja de la Lista', () {
    Future<void> montar(WidgetTester tester, ContainerUnit c) async {
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.claro(),
        home: Scaffold(body: ContainersListView(containers: [c])),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('los chips de la tarjeta dicen los nombres del plano (D1)',
        (tester) async {
      await montar(
          tester,
          const ContainerUnit(
            id: 'x',
            containerId: 'TSTU0000011',
            isDangerous: true,
            imdgClass: '3',
            isReefer: true,
            isOverDimension: true,
          ));
      expect(find.text('Peligrosa IMDG'), findsOneWidget);
      expect(find.text('Refrigerado'), findsOneWidget);
      expect(find.text('Fuera de medida'), findsOneWidget);
      expect(find.text('IMDG'), findsNothing);
      expect(find.text('OOG'), findsNothing);
    });

    testWidgets('la hoja: las medidas del fuera de medida y la temperatura '
        'que falta, dicha con palabras (D8)', (tester) async {
      await montar(
          tester,
          const ContainerUnit(
            id: 'x',
            containerId: 'TSTU0000011',
            isReefer: true,
            isOverDimension: true,
            overLengthFront: 30,
            overHeight: 25,
          ));
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();
      expect(find.text('Frente 30${espacioDuro}cm · Alto 25${espacioDuro}cm'),
          findsOneWidget);
      expect(find.text('El archivo no trae temperatura'), findsOneWidget);
      expect(find.textContaining('N/A°'), findsNothing);
    });
  });
}
