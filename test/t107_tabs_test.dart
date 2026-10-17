import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t91_toolbar_support.dart';

/// T-107, parte B · La observación del 17-oct: en la Web a 360 dp, tocar
/// «Estadísticas» desde «Lista» llevó a «Bay Plan». Se reproduce con la
/// página de las pestañas a 360×780 dp, con toque y con ratón.

/// El plano de llegada sintético de T-75: dos bahías, la 03 y la 14.
const _arrivalText = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
    "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0030282::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000011+22G1+++5'"
    "LOC+147+0030482::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000012+22G1+++5'"
    "LOC+147+0030202::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000013+22G1+++5'"
    "LOC+147+0140202::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000014+45G1+++5'"
    "LOC+147+0140282::5'LOC+9+HNPCR:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN+TEST0000015+45G1+++5'";

final _arrival = () {
  final voyage = BaplieParserService().parse(_arrivalText);
  return voyage.withGeometry(VesselProfile.proposeFrom(voyage).geometry,
      portOfCall: 'GTSTC');
}();

int _index(WidgetTester tester) =>
    tester.widget<TabBar>(find.byType(TabBar)).controller!.index;

Future<void> _tab(WidgetTester tester, String text, PointerDeviceKind kind) async {
  await tester.tap(find.widgetWithText(Tab, text), kind: kind);
  await tester.pumpAndSettle();
}

void main() {
  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    for (final from in [
      ['Lista'],
      ['Bay Plan', 'Lista'],
    ]) {
      testWidgets(
          'T-107 a 360×780 dp, ${kind.name}: ${from.join(' → ')} → '
          'Estadísticas abre Estadísticas', (tester) async {
        await pumpT91Plan(
            tester, _arrival, T91MemorySettings(), Brightness.light);
        tester.view.physicalSize = const Size(360, 780);
        await tester.pumpAndSettle();
        final visited = <int>[];
        tester
            .widget<TabBar>(find.byType(TabBar))
            .controller!
            .addListener(() => visited.add(_index(tester)));
        for (final text in from) {
          await _tab(tester, text, kind);
        }
        expect(_index(tester), 0);
        await _tab(tester, 'Estadísticas', kind);
        expect(_index(tester), 2, reason: 'índices vistos: $visited');
        expect(find.text('Total Contenedores').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
