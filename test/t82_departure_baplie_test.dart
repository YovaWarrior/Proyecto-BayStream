import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/operation_state_deriver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t82_fixture.dart';

void main() {
  const writer = DepartureBaplieWriter();
  final clock = DateTime.utc(2026, 10, 11, 22);
  DepartureBaplie output(Iterable<Movement> moves,
          {Operation? operation, ExportList? list}) =>
      writer.generate(
          operation: operation ?? t82Operation,
          state: t82Derive(moves).state,
          list: list ?? t82List,
          movements: moves,
          now: clock);
  test(
      'T-82 conserva declaraciones del plan y carga con VGM, tara, puertos y dos ONU exactos',
      () {
    final result = output(t82Loads);
    final voyage = BaplieParserService().parse(result.text);
    expect(voyage.containers, hasLength(3));
    expect(result.text, contains(t82Transit.replaceAll("'", "'\n")));
    final full =
        voyage.containers.firstWhere((c) => c.containerId == 'TSTU0000014');
    expect(full.vgmWeight, 7266.59);
    expect(full.tareWeight, 3900);
    expect(full.isoSizeType, '22G1');
    expect(full.portOfLoading, 'GTSTC');
    expect(full.portOfDischarge, 'PAMIT');
    expect(full.status, ContainerStatus.full);
    expect(full.dangerousGoods!.map((d) => d.unNumber), ['3082', '3077']);
    final empty =
        voyage.containers.firstWhere((c) => c.containerId == 'TSTU0000020');
    expect(empty.stowagePosition!.toIsoCode(), '0030984');
    expect(empty.tareWeight, 2185);
    expect(empty.effectiveWeight, 2185);
    expect(empty.status, ContainerStatus.empty);
    expect(voyage.vessel.name, t82Loading.vessel.name);
    expect(voyage.voyageNumber, t82Loading.voyageNumber);
    final segments = result.text
        .split("'")
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final unh = segments.indexWhere((s) => s.startsWith('UNH+'));
    final unt = segments.indexWhere((s) => s.startsWith('UNT+'));
    expect(int.parse(segments[unt].split('+')[1]), unt - unh + 1);
    expect(segments[unt].split('+')[2], segments[unh].split('+')[1]);
    expect(segments.last, 'UNZ+1+${segments.first.split('+')[5]}');
    expect(result.text, isNot(contains('UNH+OLDM+')));
    expect(result.pendingLoads + result.pendingDischarges, 0);
  });
  test('T-82 pendientes fuera del EDI, descarga pendiente sigue a bordo', () {
    final result = output([]);
    expect(result.containers, 2);
    expect(result.pendingLoads, 2);
    expect(result.pendingDischarges, 1);
    expect(result.text, isNot(contains('EQD+CN+TSTU0000014+')));
    expect(result.text, contains('EQD+CN+TSTU0000110+'));
  });
  test('T-82 cancelado con motivo, annul lo devuelve a carga y vacía la lista',
      () {
    final cancel = t82Move(
        MovementDraft.cancelItem('op', 'C:TSTU0000014', 'No embarca'), 0);
    final result = output([cancel, ...t82Loads]);
    expect(result.text, isNot(contains('EQD+CN+TSTU0000014+')));
    expect(result.cancelledText, contains('OR 5 · TSTU0000014'));
    expect(result.cancelledText, contains('No embarca'));
    final restored = output([
      cancel,
      ...t82Loads,
      t82Move(MovementDraft.annul('op', cancel.id, 'Sí embarca'), 4)
    ]);
    expect(restored.text, contains('EQD+CN+TSTU0000014+'));
    expect(restored.cancelled, isEmpty);
  });
  test(
      'T-82 re-estiba conserva pesos y peligrosas de llegada en posición registrada',
      () {
    final moves = [
      ...t82Loads,
      t82Move(
          MovementDraft.discharge('op', 'TSTU0000105', '0010282', restow: true),
          4),
      t82Move(MovementDraft.loadFull('op', 'TSTU0000105', '0050282'), 5),
    ];
    final c = BaplieParserService()
        .parse(output(moves).text)
        .containers
        .firstWhere((c) => c.containerId == 'TSTU0000105');
    expect(c.stowagePosition!.toIsoCode(), '0050282');
    expect(c.vgmWeight, 7266.59);
    expect(c.dangerousGoods!.single.labels, ['9']);
  });
  test(
      'T-82 cambio vigente y corrects usan posición física; orden de recepción estable',
      () {
    final change = t82Move(
        MovementDraft.changePosition(
            'op',
            [const PositionChange('C:TSTU0000014', '0030282', '0050282')],
            'Otra celda'),
        0);
    final corrected = t82Move(
        MovementDraft.loadFull('op', 'TSTU0000014', '0050282',
            corrects: t82Loads[1].id, reason: 'Corrección'),
        4);
    final moves = [change, ...t82Loads, corrected];
    final result = output(moves);
    expect(output(moves.reversed).text, result.text);
    final c = BaplieParserService()
        .parse(result.text)
        .containers
        .firstWhere((c) => c.containerId == 'TSTU0000014');
    expect(c.stowagePosition!.toIsoCode(), '0050282');
  });
  test('T-82 generar leer generar permanece idéntico con reloj fijo', () {
    final first = output(t82Loads);
    final parsed = BaplieParserService().parse(first.text);
    final operation = t82Operation.copyWith(sources: [
      OperationSource(
          kind: OperationSourceKind.loadingBaplie,
          fileName: 'salida.edi',
          content: first.text),
      OperationSource(
          kind: OperationSourceKind.arrivalBaplie,
          fileName: 'salida.edi',
          content: first.text),
    ]);
    final state = const OperationStateDeriver().derive(
        OperationPlan.build(
            portOfCall: 'ZZZZZ', arrival: parsed, loading: parsed),
        []);
    expect(writer.generate(operation: operation, state: state, now: clock).text,
        first.text);
  });
  test(
      'T-82 sin fuente, versión 1/3/desconocida y separadores no reconocidos no generan',
      () {
    expect(() => output([], operation: t82Operation.copyWith(sources: [])),
        throwsStateError);
    for (final id in [
      'BAPLIE:1:911:UN:SMDG15',
      'BAPLIE:D:13B:UN:SMDG31',
      'BAPLIE:D:95B:UN:SMDG99'
    ]) {
      final op = t82Operation.copyWith(sources: [
        OperationSource(
            kind: OperationSourceKind.loadingBaplie,
            fileName: 'no.edi',
            content: t82LoadingEdi.replaceFirst('BAPLIE:D:95B:UN:SMDG20', id))
      ]);
      expect(() => output([], operation: op), throwsStateError);
    }
    expect(
        () => output([],
            operation: t82Operation.copyWith(sources: [
              const OperationSource(
                  kind: OperationSourceKind.loadingBaplie,
                  fileName: 'no.edi',
                  content: "UNA*;.! ~UNH~")
            ])),
        throwsStateError);
  });
  test('T-82 un cargado ausente del listado sale con el plan, sin inventar datos',
      () {
    // T-122, corrección 1 (10.57): antes se detenía; ahora el lleno va con su
    // grupo del plan de carga y el vacío asignado sigue exigiendo su fila.
    final sinListado = ExportList(fileName: 'vacío', rows: []);
    final result = output(t82Loads.take(2), list: sinListado);
    final full = BaplieParserService()
        .parse(result.text)
        .containers
        .firstWhere((c) => c.containerId == 'TSTU0000014');
    expect(full.grossWeight, 7200);
    expect(full.vgmWeight, isNull);
    expect(result.withoutRow, ['TSTU0000014']);
    expect(
        () => output(t82Loads, list: sinListado),
        throwsA(isA<StateError>().having((e) => e.message, 'message',
            contains('El vacío asignado TSTU0000020 no está en el listado'))));
  });
  test('T-82 prioriza el plan completo y respalda solo lo que no declara', () {
    final primary = t82LoadingEdi
        .replaceFirst('MEA+VGM++KGM:7266.59', 'MEA+WT++KGM:7200')
        .replaceFirst("MEA+T++KGM:3900'", '')
        .replaceFirst("LOC+9+HNPCR:139:6'", '')
        .replaceFirst('LOC+11+PAMIT:139:6', 'LOC+11+JMKIN:139:6')
        .replaceFirst('NAD+CA+TEST:172:20', 'NAD+CA+NEW:172:20')
        .replaceFirst('DGS+IMD+9+3077+++++++9:0:0', 'DGS+IMD+3+1993');
    final operation = t82Operation.copyWith(sources: [
      ...t82Operation.sources
          .where((s) => s.kind == OperationSourceKind.arrivalBaplie),
      OperationSource(
          kind: OperationSourceKind.loadingBaplie,
          fileName: 'vigente.edi',
          content: primary),
    ]);
    final c = BaplieParserService()
        .parse(output(t82Loads, operation: operation).text)
        .containers
        .firstWhere((c) => c.containerId == 'TSTU0000105');
    expect(c.grossWeight, 7200);
    expect(c.vgmWeight, isNull); // El VGM viejo no se impone al WT vigente.
    expect(c.tareWeight, 3900);
    expect(c.portOfLoading, 'HNPCR'); // Falta en plan: respaldo de llegada.
    expect(c.portOfDischarge, 'JMKIN');
    expect(c.operatorCode, 'NEW');
    expect(c.dangerousGoods!.single.unNumber, '1993');
    expect(c.dangerousGoods!.single.hazardClass, '3');
  });
  test('T-82 conserva el espacio reservado de UNA en la ida y vuelta', () {
    final operation = t82Operation.copyWith(sources: [
      ...t82Operation.sources
          .where((s) => s.kind == OperationSourceKind.arrivalBaplie),
      const OperationSource(
          kind: OperationSourceKind.loadingBaplie,
          fileName: 'una.edi',
          content: "UNA:+.? '$t82LoadingEdi"),
    ]);
    final first = output(t82Loads, operation: operation);
    expect(first.text, startsWith("UNA:+.? '\n"));
    final parsed = BaplieParserService().parse(first.text);
    final reparsed = operation.copyWith(sources: [
      OperationSource(
          kind: OperationSourceKind.loadingBaplie,
          fileName: 'salida.edi',
          content: first.text),
    ]);
    final state = const OperationStateDeriver()
        .derive(OperationPlan.build(portOfCall: 'ZZZZZ', loading: parsed), []);
    expect(writer.generate(operation: reparsed, state: state, now: clock).text,
        first.text);
  });
}
