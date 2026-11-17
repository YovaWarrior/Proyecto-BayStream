import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/container_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-146 · O-144-1 (10.126): el buscador encontraba «bysu 967» pero no
/// resaltaba la matrícula, porque comparaba la consulta con espacios contra
/// la matrícula sin ellos. El título se resalta ahora con la consulta sin
/// espacios; el puerto, como antes. Solo datos sintéticos (los de T-144).

final _tema = BayStreamTema.claro(muelle: true);

/// El contenedor de la corrección 1 de T-144: BYSU 9672095, de GTSTC a PAMIT,
/// de la naviera LINEA.
final ContainerUnit _contenedor = BaplieParserService()
    .parse("UNB+UNOA:2+TEST+TEST+261111:1200+T146'"
        "UNH+T146+BAPLIE:D:95B:UN:SMDG22'BGM++T146+9'"
        "TDT+20+V146+++TEST:172:20+++:::BUQUE PRUEBA'LOC+5+GTSTC:139:6'"
        "LOC+147+0020182::5'MEA+WT++KGM:20000'"
        "LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'"
        "EQD+CN+BYSU 9672095+22G1+++5'NAD+CA+LINEA:172:20'"
        "UNT+1+T146'UNZ+1+T146'")
    .containers
    .single;

Widget _buscador(String consulta) => ProviderScope(
      child: MaterialApp(
        theme: _tema,
        home: Scaffold(
          body: Consumer(builder: (context, ref, _) {
            final delegado =
                ContainerSearchDelegate(containers: [_contenedor], ref: ref)
                  ..query = consulta;
            return delegado.buildResults(context);
          }),
        ),
      ),
    );

/// Lo que va resaltado en cada texto del resultado: el texto completo y el
/// tramo con el fondo del resaltado, o `null` si no lleva ninguno.
Map<String, String?> _resaltados(WidgetTester tester) {
  final resultado = <String, String?>{};
  for (final texto in tester.widgetList<RichText>(find.descendant(
      of: find.byType(ListTile), matching: find.byType(RichText)))) {
    String? tramo;
    texto.text.visitChildren((span) {
      if (span is TextSpan &&
          span.text != null &&
          span.style?.backgroundColor ==
              _tema.colorScheme.tertiaryContainer) {
        tramo = span.text;
        return false;
      }
      return true;
    });
    resultado[texto.text.toPlainText()] = tramo;
  }
  return resultado;
}

Future<Map<String, String?>> _buscar(WidgetTester tester, String consulta) async {
  await tester.pumpWidget(_buscador(consulta));
  await tester.pumpAndSettle();
  expect(find.byType(ListTile), findsOneWidget, reason: consulta);
  expect(tester.takeException(), isNull);
  return _resaltados(tester);
}

void main() {
  testWidgets('«bysu 967» resalta BYSU967 en la matrícula', (tester) async {
    expect(_contenedor.containerId, 'BYSU9672095');
    expect(_contenedor.portOfDischarge, 'PAMIT');
    expect(_contenedor.operatorCode, 'LINEA');
    final resaltados = await _buscar(tester, 'bysu 967');
    expect(resaltados['BYSU9672095'], 'BYSU967');
  });

  testWidgets('«BYSU9672095» resalta la matrícula entera, como antes',
      (tester) async {
    final resaltados = await _buscar(tester, 'BYSU9672095');
    expect(resaltados['BYSU9672095'], 'BYSU9672095');
  });

  testWidgets('«967 2095» resalta 9672095', (tester) async {
    final resaltados = await _buscar(tester, '967 2095');
    expect(resaltados['BYSU9672095'], '9672095');
  });

  testWidgets('con el espacio duro y con la tabulación, resalta BYSU967',
      (tester) async {
    for (final consulta in ['bysu 967', 'bysu\t967']) {
      final resaltados = await _buscar(tester, consulta);
      expect(resaltados['BYSU9672095'], 'BYSU967', reason: consulta);
    }
  });

  testWidgets('«pamit» resalta el puerto y no la matrícula, como antes',
      (tester) async {
    final resaltados = await _buscar(tester, 'pamit');
    expect(resaltados['BYSU9672095'], isNull);
    expect(resaltados['POD: PAMIT'], 'PAMIT');
  });

  testWidgets('la etiqueta accesible lleva la matrícula entera',
      (tester) async {
    final semantica = tester.ensureSemantics();
    await _buscar(tester, 'bysu 967');
    final titulo = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == 'BYSU9672095');
    expect(titulo, findsOneWidget);
    expect(tester.getSemantics(titulo).label, contains('BYSU9672095'));
    semantica.dispose();
  });
}
