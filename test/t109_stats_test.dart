// T-109 · Las estadísticas en el teléfono: las mismas cifras a 1280 dp y a
// 360 dp con la letra a 1.0, 1.45 y 2.0, sin desbordes y sin cifras cortadas.
// Desde T-121 (DESIGN.md 15) la vista es «El buque en corte»: la referencia
// de píxeles contra HEAD de la vista de T-109 ya no aplica (la vista cambió
// entera), y la etiqueta larga de una naviera envuelve en vez de abrir un
// diálogo. La política de privacidad con U+2011 sigue aquí.
import 'dart:io';

import 'package:baystream/core/constants/privacy_policy.dart';
import 'package:baystream/core/utils/privacy_policy_html.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_stats_view.dart';
import 'package:baystream/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/t98_support.dart';
import 'support/t117_oficina_support.dart';
import 'support/t121_estadisticas_support.dart';

VesselVoyage _fixture() {
  final voyage = BaplieParserService().parse(t98Message()
      .replaceFirst('22G1', '22R1')
      .replaceFirst('UNT+13+', "DGS+IMD+3+1993'NAD+CA+TEST:172:20'UNT+15+"));
  return voyage.withGeometry(VesselProfile.proposeFrom(voyage).geometry);
}

/// Los textos de la vista, ordenados: las cifras y los rótulos tienen que ser
/// los mismos en cualquier tamaño. Los rótulos del selector «Contenedores /
/// Peso» no cuentan: con poco ancho el selector va solo con los iconos y el
/// nombre en la descripción emergente (DESIGN.md 15.4); no son datos.
List<String> _textos(WidgetTester tester) => find
    .descendant(of: find.byType(VoyageStatsView), matching: find.byType(Text))
    .evaluate()
    .map((e) => (e.widget as Text).data ?? '')
    .where((text) => text.isNotEmpty && text != 'Contenedores' && text != 'Peso')
    .toList()
  ..sort();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final scale in [1.0, 1.45, 2.0]) {
    testWidgets('T109 360x780 dp letra $scale sin desbordes ni datos perdidos',
        (tester) async {
      final voyage = _fixture();
      await t121Pump(tester, voyage: voyage, tamano: const Size(1280, 780));
      final originales = _textos(tester);
      expect(tester.takeException(), isNull);
      await t121Pump(tester,
          voyage: voyage, tamano: const Size(360, 780), letra: scale, muelle: true);
      expect(tester.takeException(), isNull);
      expect(_textos(tester), originales,
          reason: 'Mismos textos y cifras de la vista completa a 1280 dp');
      await t121RecorrerLaPagina(tester, paso: 500);
      // Las cifras del producto llevan espacio duro (U+00A0) ante «t» y «%».
      final numeric = find.byWidgetPredicate((widget) =>
          widget is Text &&
          RegExp('^\\d+(\\.\\d+)?(\u00A0(t|%))?\$').hasMatch(widget.data ?? ''));
      expect(numeric, findsWidgets);
      for (final element in numeric.evaluate()) {
        final text = element.widget as Text;
        expect(text.overflow, isNot(TextOverflow.ellipsis));
        // Cada cifra en una sola línea, entera.
        final parrafo = tester.renderObject<RenderParagraph>(find.byWidget(text));
        expect(parrafo.getMaxIntrinsicWidth(double.infinity),
            lessThanOrEqualTo(parrafo.size.width + 0.5),
            reason: '«${text.data}» se parte');
      }
      t121NadaSeCorta(tester, find.byType(VoyageStatsView));
    });
  }

  testWidgets('T109 etiqueta larga completa, sin cortar y en accesibilidad',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      const label = 'NAVIERADEPRUEBACONNOMBREMUYLARGO';
      final base = _fixture();
      final voyage = base.copyWith(containers: [
        for (final c in base.containers) c.copyWith(operatorCode: label),
      ]).withFileBays();
      await t121Pump(tester,
          voyage: voyage, tamano: const Size(360, 780), letra: 2, muelle: true);
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      final barra = tester.widget<BsBarraDeMagnitud>(find.ancestor(
          of: find.text(label), matching: find.byType(BsBarraDeMagnitud)));
      expect(barra.etiqueta, startsWith('$label: '));
      expect(tester.getSemantics(find.byWidget(barra)).label, contains(label));
      expect(t117TextosCortados(tester, find.byType(VoyageStatsView)), isEmpty);
      // La etiqueta larga de una sola palabra se parte por fuerza: es la
      // excepción conocida (no hay dónde partirla); lo demás, entero.
      expect(t121PalabrasPartidas(tester, find.byType(VoyageStatsView)),
          everyElement(label));
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  test('T109 política con U+2011 y HTML generado desde la fuente', () {
    final source =
        File('lib/core/constants/privacy_policy.dart').readAsStringSync();
    expect(source, contains('re‑estibas'));
    expect(source, isNot(contains('re-estibas')));
    final text =
        kPrivacyPolicySections.expand((section) => section.items).join();
    expect(text, contains('re‑estibas'));
    expect(
        File('web/privacidad.html').readAsStringSync().replaceAll('\r\n', '\n'),
        privacyPolicyHtml());
  });
}
