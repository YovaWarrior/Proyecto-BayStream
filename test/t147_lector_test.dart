// T-147 · R2 y R3 (10.151, hallazgo 2): el plan trae «NO» donde no hay
// matrícula, y una matrícula puede venir en dos celdas.
//
// R2 · Un grupo cuyo EQD trae «NO» se lee como si el número viniera en
// blanco: una celda reservada con su tipo, sus puertos, su línea y su peso.
// Vale para cualquier otro texto sin forma de matrícula que se repita en más
// de una celda. El lector lo avisa una sola vez, con la cuenta.
// R3 · La misma matrícula, con forma de matrícula, en dos celdas se avisa
// con las dos celdas. La lectura no cambia.
//
// Solo datos sintéticos, con el orden de segmentos del caso A09: LOC+147,
// MEA+VGM, LOC+9, LOC+11, RFF+BM, EQD, NAD+CA y, después, TMP y DGS.
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/iso6346_check_digit.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t76_fixture.dart' show t76Movement;

const _cabecera = "UNB+UNOA:2+EMISOR+RECEPTOR+261118:2200+REF147'"
    "UNH+M147+BAPLIE:D:95B:UN:SMDG20'BGM++DOC147+9'"
    "DTM+137:2611182200:201'"
    "TDT+20+VIAJE147+++LNH:172:20+++9000147:146:11:BUQUE SINTETICO'"
    "LOC+5+GTSTC:139:6'LOC+61+COTRB:139:6'RFF+VON:VIAJE147'";
const _pie = "UNT+1+M147'UNZ+1+REF147'";

/// Un grupo con la forma del caso. [numero] va tal cual en el EQD.
String _grupo(String posicion, String numero,
        {String tipo = '45G1',
        String carga = 'GTSTC',
        String descarga = 'COTRB',
        String linea = 'LNH',
        int peso = 3800,
        String estado = '4',
        String despues = ''}) =>
    "LOC+147+$posicion::5'MEA+VGM++KGM:$peso'"
    "LOC+9+$carga:139:6'LOC+11+$descarga:139:6'RFF+BM:1'"
    "EQD+CN+$numero+$tipo+++$estado'NAD+CA+$linea:172:20'$despues";

/// Una matrícula sintética con su dígito de control correcto, para que el
/// único aviso de cada plan sea el que se prueba.
String _m(int n) {
  final base = 'TSTU${n.toString().padLeft(6, '0')}';
  for (var digito = 0; digito < 10; digito++) {
    if (Iso6346CheckDigit.isValid('$base$digito') ?? false) {
      return '$base$digito';
    }
  }
  throw StateError('Sin dígito de control para $base');
}

String _plan(Iterable<String> grupos) => '$_cabecera${grupos.join()}$_pie';

VesselVoyage _leer(String texto) => BaplieParserService().parse(texto);

/// Lo leído, sin el `id` de cada contenedor (un UUID nuevo en cada lectura).
Map<String, Object?> _lectura(VesselVoyage viaje) => {
      'contenedores': [
        for (final c in viaje.containers) c.toJson()..remove('id')
      ],
      'reservas': [for (final s in viaje.reservedSlots) s.toJson()],
    };

/// Los detalles del aviso de tipo [nombre], o nulo si el lector no lo dio.
/// Por su nombre: así la prueba también compila contra la 1.0.1.
List<String>? _aviso(VesselVoyage viaje, String nombre) => viaje.readNotices
    .where((aviso) => aviso.kind.name == nombre)
    .map((aviso) => aviso.details)
    .firstOrNull;

/// Un plan como el del caso, en pequeño: dos llenos con matrícula, un vacío
/// con matrícula y tres celdas con «NO», una de ellas refrigerada.
final _conNo = _plan([
  _grupo('0100282', _m(17), estado: '5', peso: 24300),
  _grupo('0100482', _m(22), estado: '5', peso: 18100),
  _grupo('0180082', _m(38)),
  _grupo('0180084', 'NO', tipo: '45R1', descarga: 'JMKIN', peso: 4700,
      despues: "TMP+2+-18:CEL'"),
  _grupo('0180284', 'NO'),
  _grupo('0190682', 'NO', tipo: '22G1', linea: 'LNJ', peso: 2100),
]);

/// El mismo plan con el número en blanco: el rodeo del piloto 4.
final _enBlanco = _conNo.replaceAll('EQD+CN+NO+', 'EQD+CN++');

void main() {
  group('R2 · «NO» es «sin número»', () {
    test('un plan con «NO» se lee igual que con el número en blanco', () {
      final viaje = _leer(_conNo);
      expect(viaje.totalContainers, 3);
      expect(viaje.totalReservedSlots, 3);
      expect(_lectura(viaje), _lectura(_leer(_enBlanco)));
      expect(viaje.containers.map((c) => c.containerId),
          isNot(contains('NO')));
    });

    test('la celda reservada conserva tipo, puertos, línea, peso y frío', () {
      final celda = _leer(_conNo).reservedSlots.firstWhere(
          (s) => s.stowagePosition.toIsoCode() == '0180084');
      expect(celda.isoSizeType, '45R1');
      expect(celda.portOfLoading, 'GTSTC');
      expect(celda.portOfDischarge, 'JMKIN');
      expect(celda.operatorCode, 'LNH');
      expect(celda.nominalWeight, 4700);
      expect(celda.status, ContainerStatus.empty);
      expect(celda.isReefer, isTrue);
      expect(celda.temperature, -18);
      expect(celda.key, 'R:0180084');
    });

    test('el lector lo avisa una sola vez, con la cuenta', () {
      final viaje = _leer(_conNo);
      expect(viaje.readNotices.map((aviso) => aviso.kind.name), ['noNumber']);
      expect(_aviso(viaje, 'noNumber'), ['«NO» en 3 celdas']);
      // Con el número en blanco no hay nada que avisar: es lo de siempre.
      expect(_leer(_enBlanco).readNotices, isEmpty);
    });

    test('vale en minúsculas, con espacios y para una sola celda', () {
      final viaje = _leer(_plan([
        _grupo('0100282', _m(17), estado: '5'),
        _grupo('0180084', 'no'),
        _grupo('0180284', ' No '),
      ]));
      expect(viaje.totalContainers, 1);
      expect(viaje.totalReservedSlots, 2);
      expect(_aviso(viaje, 'noNumber'), ['«NO» en 2 celdas']);
      final una = _leer(_plan([_grupo('0180084', 'NO')]));
      expect(una.totalContainers, 0);
      expect(una.totalReservedSlots, 1);
      expect(_aviso(una, 'noNumber'), ['«NO» en 1 celda']);
    });

    test('otro texto sin forma de matrícula, repetido en más de una celda, '
        'también es «sin número»', () {
      final viaje = _leer(_plan([
        _grupo('0100282', _m(17), estado: '5'),
        _grupo('0180084', 'TBA'),
        _grupo('0180284', 'TBA'),
        _grupo('0180484', 'NO'),
      ]));
      expect(viaje.containers.map((c) => c.containerId), [_m(17)]);
      expect(viaje.totalReservedSlots, 3);
      expect(
          _aviso(viaje, 'noNumber'), ['«NO» en 1 celda', '«TBA» en 2 celdas']);
    });

    test('un número sin forma de matrícula que viene una sola vez sigue '
        'siendo un contenedor (T-144: «EU876»)', () {
      final viaje = _leer(_plan([
        _grupo('0100282', 'EU876', estado: '5'),
        _grupo('0100482', _m(22), estado: '5'),
      ]));
      expect(viaje.containers.map((c) => c.containerId),
          ['EU876', _m(22)]);
      expect(viaje.totalReservedSlots, 0);
      expect(viaje.readNotices, isEmpty);
    });

    test('el aviso se guarda aparte: la 1.0.0 y la 1.0.1 siguen abriendo el '
        'viaje guardado', () {
      final viaje = _leer(_conNo);
      final json = viaje.toJson();
      // `readNotices` es lo único que lee la 1.0.0, y lanza con un tipo que
      // no conoce; la 1.0.1 lee también `extraReadNotices` y salta lo que no
      // conoce (T-144, 10.123).
      expect(json.containsKey('readNotices'), isFalse);
      expect(json['extraReadNotices'], [
        {
          'kind': 'noNumber',
          'details': ['«NO» en 3 celdas'],
        }
      ]);
      final otraVez = VesselVoyage.fromJson(json);
      expect(_aviso(otraVez, 'noNumber'), ['«NO» en 3 celdas']);
      expect(otraVez.totalReservedSlots, 3);
    });

    testWidgets('la tarjeta del viaje dice cuántas celdas traían «NO»',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 1600);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: _leer(_conNo))))));
      expect(find.text('3 contenedores · 3 celdas reservadas'), findsOneWidget);
      expect(
          find.text('Celdas sin matrícula en EQD: «NO» en 3 celdas · se '
              'leyeron como celdas reservadas'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('voyage-noNumber-notice')));
      await tester.pumpAndSettle();
      expect(
          find.textContaining('El archivo trae un texto donde va la matrícula'),
          findsOneWidget);
    });

    test('el BAPLIE de salida no escribe «NO»: la reserva asignada sale con '
        'su número y la que queda sin asignar no sale', () {
      final plan = _leer(_conNo).copyWith(portOfCall: 'GTSTC');
      final lista = ExportList(fileName: 'sintetico-t147.xlsx', rows: [
        ExportListRow(
            sheetRow: 6,
            order: 1,
            containerId: _m(41),
            status: ContainerStatus.empty,
            listType: '45G1',
            listPod: 'COTRB',
            listLine: 'LNH',
            tareKg: 3920),
      ]);
      final operacion = Operation(
          id: 'op',
          vesselName: plan.vessel.name,
          voyageNumber: plan.voyageNumber,
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026, 11, 18),
          sources: [
            OperationSource(
                kind: OperationSourceKind.loadingBaplie,
                fileName: 'carga.edi',
                content: _conNo),
          ]);
      final movimientos = [
        t76Movement(
            MovementDraft.assignEmpty('op', '0180284', _m(41), 3920,
                order: 1),
            1),
        for (final (i, c) in plan.containers.indexed)
          t76Movement(
              MovementDraft.loadFull(
                  'op', c.containerId, c.stowagePosition!.toIsoCode()),
              i + 2),
      ];
      final data = LoadingOperation.build(
          operationId: 'op', loading: plan, list: lista, movements: movimientos);
      expect(data.state.conflicts, isEmpty);
      final salida = const DepartureBaplieWriter().generate(
          operation: operacion,
          state: data.state,
          list: lista,
          movements: movimientos,
          now: DateTime.utc(2026, 11, 19));
      expect(salida.text, isNot(contains('EQD+CN+NO')));
      expect(salida.text, contains('EQD+CN+${_m(41)}+45G1'));
      expect(salida.text, isNot(contains('EQD+CN++')));
      // A bordo salen los tres con matrícula y el vacío asignado.
      expect(salida.containers, 4);
      expect(salida.pendingLoads, 2);
      expect('LOC+147+'.allMatches(salida.text), hasLength(4));
      expect(salida.text, isNot(contains('LOC+147+0180084')));
      expect(salida.text, isNot(contains('LOC+147+0190682')));
    });
  });

  group('R3 · una matrícula repetida se avisa', () {
    final repetida = _plan([
      _grupo('0100282', _m(17), estado: '5'),
      _grupo('0100484', _m(17), estado: '5'),
      _grupo('0100682', _m(22), estado: '5'),
    ]);

    test('la misma matrícula en dos celdas: el lector lo dice, con las dos',
        () {
      final viaje = _leer(repetida);
      expect(_aviso(viaje, 'duplicate'), ['${_m(17)}: 010-02-82 y 010-04-84']);
      // La lectura no cambia: los dos grupos siguen siendo contenedores.
      expect(viaje.containers.map((c) => c.containerId),
          [_m(17), _m(17), _m(22)]);
      expect(viaje.totalReservedSlots, 0);
    });

    test('en tres celdas, las tres; y cada matrícula repetida, su línea', () {
      final viaje = _leer(_plan([
        _grupo('0100282', _m(17), estado: '5'),
        _grupo('0100484', _m(17), estado: '5'),
        _grupo('0120282', _m(17), estado: '5'),
        _grupo('0100682', _m(22), estado: '5'),
        _grupo('0100882', _m(22), estado: '5'),
        _grupo('0101082', _m(38), estado: '5'),
      ]));
      expect(_aviso(viaje, 'duplicate'), [
        '${_m(17)}: 010-02-82, 010-04-84 y 012-02-82',
        '${_m(22)}: 010-06-82 y 010-08-82',
      ]);
    });

    test('sin matrículas repetidas no hay aviso', () {
      expect(_leer(_conNo).readNotices.map((a) => a.kind.name),
          isNot(contains('duplicate')));
      expect(
          _leer(_plan([_grupo('0100282', _m(17), estado: '5')]))
              .readNotices,
          isEmpty);
    });

    test('el aviso se guarda con el viaje, aparte de los de la 1.0.0', () {
      final json = _leer(repetida).toJson();
      expect(json.containsKey('readNotices'), isFalse);
      expect(
          _aviso(VesselVoyage.fromJson(json), 'duplicate'),
          ['${_m(17)}: 010-02-82 y 010-04-84']);
    });

    testWidgets('la tarjeta del viaje lo dice', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 1600);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: _leer(repetida))))));
      expect(
          find.text('Matrículas repetidas en EQD: 1 contenedor · revisa esas '
              'celdas con quien hizo el plan'),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('voyage-duplicate-notice')));
      await tester.pumpAndSettle();
      expect(find.text('${_m(17)}: 010-02-82 y 010-04-84'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('lo que la operación hace hoy con ellas no cambia: una sola pieza '
        '`C:<matrícula>`, en la última celda', () {
      final plan = _leer(repetida).copyWith(portOfCall: 'GTSTC');
      final piezas = OperationPlan.build(portOfCall: 'GTSTC', loading: plan);
      expect(piezas.loading.keys, ['C:${_m(17)}', 'C:${_m(22)}']);
      expect(piezas.loading['C:${_m(17)}']!.plannedPosition, '0100484');
      expect(piezas.loadingItemAt('0100282'), isNull);
    });
  });
}
