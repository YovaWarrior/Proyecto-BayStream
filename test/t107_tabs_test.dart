import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t91_toolbar_support.dart';

/// T-107, parte B · La observación del 17-oct: en la Web a 360 dp, tocar
/// «Estadísticas» desde «Lista» llevó a «Bay Plan». Se reproduce con la
/// página a 360×780 dp, con toque y con ratón. Desde la Fase 3 la navegación
/// es la barra inferior (`DESIGN.md` 8): el destino vive en
/// `destinoDelViajeProvider` y cada destino tiene su clave.

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

Future<void> _destino(
    WidgetTester tester, DestinoDelViaje destino, PointerDeviceKind kind) async {
  await tester.tap(find.byKey(ValueKey('destino-${destino.name}')), kind: kind);
  await tester.pumpAndSettle();
}

void main() {
  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    for (final from in [
      [DestinoDelViaje.lista],
      [DestinoDelViaje.plano, DestinoDelViaje.lista],
    ]) {
      testWidgets(
          'T-107 a 360×780 dp, ${kind.name}: ${from.map((d) => d.rotulo).join(' → ')} → '
          'Estadísticas abre Estadísticas', (tester) async {
        final scope = await pumpT91Plan(
            tester, _arrival, T91MemorySettings(), Brightness.light);
        tester.view.physicalSize = const Size(360, 780);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('barra-del-viaje')), findsOneWidget);
        final visited = <DestinoDelViaje>[];
        scope.listen(destinoDelViajeProvider, (previo, actual) => visited.add(actual));
        for (final destino in from) {
          await _destino(tester, destino, kind);
        }
        expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.lista);
        await _destino(tester, DestinoDelViaje.estadisticas, kind);
        expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.estadisticas,
            reason: 'destinos vistos: $visited');
        // T-121 (DESIGN.md 15.2): la protagonista de Estadísticas.
        expect(
            find.byKey(const ValueKey('estadisticas-protagonista')).hitTestable(),
            findsOneWidget);
        // «Más» no cambia de destino: abre la hoja y la deja cerrar.
        await _destino(tester, DestinoDelViaje.mas, kind);
        expect(find.byKey(const ValueKey('hoja-mas')), findsOneWidget);
        expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.estadisticas);
        await tester.tapAt(const Offset(8, 8));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('hoja-mas')), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
