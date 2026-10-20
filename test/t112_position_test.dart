import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/core/utils/voyage_number.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-112 · La posición en español y el número de viaje ausente como «sin
/// número», sin cambiar el valor guardado.
const _withoutVoyage = "UNH+1+BAPLIE:D:95B:UN:SMDG22'"
    "TDT+20++++TST:172:20+++9000112:146:11:BUQUE PRUEBA'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0020182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU1120001+22G1+++5'";

void main() {
  test('T-112 la posición se lee en español: Bahía, Fila, Nivel', () {
    expect(IsoCoordinateParser.parse('0020182').displayFormat,
        'Bahía 002, Fila 01, Nivel 82');
    expect(IsoCoordinateParser.parse('0451284').displayFormat,
        'Bahía 045, Fila 12, Nivel 84');
  });

  test('T-112 sin número de viaje se guarda UNKNOWN y se muestra «sin número»', () {
    final voyage = BaplieParserService().parse(_withoutVoyage);
    // Lo guardado y la identidad del viaje no cambian.
    expect(voyage.voyageNumber, unknownVoyageNumber);
    expect(voyage.voyageNumber, 'UNKNOWN');
    expect(voyage.toJson()['voyageNumber'], 'UNKNOWN');
    expect(voyageNumberLabel(voyage.voyageNumber), 'sin número');
    expect(voyageNumberLabel('V112'), 'V112');
  });

  testWidgets('T-112 la tarjeta del viaje dice «Viaje: sin número», no UNKNOWN',
      (tester) async {
    final voyage = BaplieParserService().parse(_withoutVoyage);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(child: VoyageSummaryCard(voyage: voyage)))));
    await tester.pumpAndSettle();
    expect(find.text('Viaje: sin número'), findsOneWidget);
    expect(find.textContaining('UNKNOWN'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T-112 los avisos de lectura nombran su segmento y dicen qué hacer',
      (tester) async {
    final voyage = BaplieParserService().parse(_withoutVoyage).copyWith(readNotices: [
      BaplieReadNotice(BaplieReadNoticeKind.weight,
          ['TSTU1120001: WT en LBR convertido a 9072 kg']),
      BaplieReadNotice(BaplieReadNoticeKind.position, ['TSTU1120001: 00201X2']),
      BaplieReadNotice(BaplieReadNoticeKind.checkDigit, ['TSTU1120001']),
    ]);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(child: VoyageSummaryCard(voyage: voyage)))));
    await tester.pumpAndSettle();
    expect(find.text('Pesos revisados en MEA: 1 contenedor · revisa esos pesos antes de operar'),
        findsOneWidget);
    expect(find.text('Posiciones mal formadas en LOC+147: 1 contenedor · pide una '
            'exportación corregida'),
        findsOneWidget);
    expect(find.text('Dígito de control inválido en EQD: 1 contenedor · revisa esos '
            'números con la agencia'),
        findsOneWidget);
    // El detalle guardado no cambia.
    expect(voyage.readNotices.first.details.single,
        'TSTU1120001: WT en LBR convertido a 9072 kg');
  });
}
