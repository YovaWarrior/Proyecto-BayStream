// T-120 · RF-018 en el buscador (DESIGN.md 18.6): «reefer», «imo» y «oog»
// filtran los resultados (docs/entrega-7nov/fuentes/DOC2.md, la tabla
// «RF‑018»), con la línea de lo que se entendió, el motivo de cada resultado,
// el resaltado del resto y las sugerencias.
//
// Solo usa el buscador y textos, para correr también contra el código de
// antes, donde «reefer» no encontraba nada. Contenedores sintéticos (TSTU).
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/container_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ContainerUnit _c(
  String numero, {
  String? pod = 'GTSTC',
  String? pol = 'HNPCR',
  String? naviera = 'LNA',
  bool refrigerado = false,
  double? temperatura,
  List<DangerousGoods>? peligrosas,
  bool oog = false,
  double? frente,
  double? alto,
}) =>
    ContainerUnit(
      id: numero,
      containerId: numero,
      portOfDischarge: pod,
      portOfLoading: pol,
      operatorCode: naviera,
      isReefer: refrigerado,
      temperature: temperatura,
      temperatureUnit: temperatura == null ? null : 'C',
      isDangerous: peligrosas != null && peligrosas.isNotEmpty,
      dangerousGoods: peligrosas,
      imdgClass: peligrosas == null || peligrosas.isEmpty
          ? null
          : peligrosas.last.hazardClass,
      unNumber: peligrosas == null || peligrosas.isEmpty
          ? null
          : peligrosas.last.unNumber,
      isOverDimension: oog,
      overLengthFront: frente,
      overHeight: alto,
    );

final _frio = _c('TSTU0000011', refrigerado: true, temperatura: -18);
final _frioApagado = _c('TSTU0000022', refrigerado: true, pod: 'USHOU');
final _clase3 = _c('TSTU0000033',
    peligrosas: [DangerousGoods(hazardClass: '3', unNumber: '1993')]);
final _clase21 = _c('TSTU0000044',
    pod: 'USHOU',
    peligrosas: [DangerousGoods(hazardClass: '2.1', unNumber: '1950')]);
final _dosDeclaraciones = _c('TSTU0000055', pod: 'PAMIT', peligrosas: [
  DangerousGoods(hazardClass: '8', unNumber: '1760'),
  DangerousGoods(hazardClass: '3', unNumber: '1993'),
]);
final _fuera = _c('TSTU0000066', oog: true, frente: 30, alto: 25);
final _seco = _c('IMOU0000077', naviera: 'LNB');
final _todos = <ContainerUnit>[
  _frio,
  _frioApagado,
  _clase3,
  _clase21,
  _dosDeclaraciones,
  _fuera,
  _seco,
];

void main() {
  group('en el buscador', () {
    Future<void> abrir(WidgetTester tester, String consulta) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: BayStreamTema.claro(),
          home: Consumer(builder: (context, ref, _) {
            return Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showSearch<ContainerUnit?>(
                    context: context,
                    query: consulta,
                    delegate:
                        ContainerSearchDelegate(containers: _todos, ref: ref),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            );
          }),
        ),
      ));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('«reefer» lista los refrigerados con su línea y su motivo',
        (tester) async {
      await abrir(tester, 'reefer');
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('2 refrigerados'), findsOneWidget);
      expect(find.text('Refrigerado, $menos${'18'}$espacioDuro°C'),
          findsOneWidget);
      expect(find.text('Refrigerado, el archivo no trae temperatura'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('«imo» y «oog» filtran los resultados (el criterio de RF-018)',
        (tester) async {
      await abrir(tester, 'imo');
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.text('3 peligrosos'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await abrir(tester, 'oog');
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.textContaining('Fuera de medida: Frente 30'), findsOneWidget);
    });

    testWidgets('«reefer USHOU» resalta el puerto con el resto', (tester) async {
      await abrir(tester, 'reefer USHOU');
      expect(find.byType(ListTile), findsOneWidget);
      final resaltados = tester
          .widgetList<RichText>(find.byType(RichText))
          .map((r) => r.text)
          .whereType<TextSpan>()
          .expand((t) => t.children ?? const <InlineSpan>[])
          .whereType<TextSpan>()
          .where((s) => s.style?.backgroundColor != null)
          .map((s) => s.text)
          .toList();
      expect(resaltados, ['USHOU']);
    });

    testWidgets('una consulta de solo carga no resalta nada', (tester) async {
      await abrir(tester, 'imo');
      final resaltados = tester
          .widgetList<RichText>(find.byType(RichText))
          .map((r) => r.text)
          .whereType<TextSpan>()
          .expand((t) => t.children ?? const <InlineSpan>[])
          .whereType<TextSpan>()
          .where((s) => s.style?.backgroundColor != null && s.text != '');
      expect(resaltados, isEmpty);
    });

    testWidgets('sin escribir nada sugiere la carga especial con su cuenta',
        (tester) async {
      await abrir(tester, '');
      expect(find.text('Carga especial'), findsOneWidget);
      expect(find.text('Busca por matrícula, puerto, naviera o carga especial'),
          findsOneWidget);
      expect(find.text('Refrigerado 2'), findsOneWidget);
      expect(find.text('Peligrosa IMDG 3'), findsOneWidget);
      expect(find.text('Fuera de medida 1'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sugerencia-refrigerado')));
      await tester.pumpAndSettle();
      expect(find.text('2 refrigerados'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('el campo dice que también busca carga', (tester) async {
      await abrir(tester, '');
      expect(find.text('Buscar contenedor, puerto o carga…'), findsOneWidget);
    });
  });
}
