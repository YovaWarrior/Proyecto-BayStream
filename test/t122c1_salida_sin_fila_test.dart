// T-122 · Corrección 1 (SPRINT-4.md 10.57): con H4, un lleno cargado por su
// número sin fila en el listado dejaba la operación sin BAPLIE de salida
// (`DepartureBaplieWriter` exigía la fila de cada lleno cargado). Ahora sale
// en la celda donde quedó, con el grupo de segmentos del plan de carga, como
// lo que sigue a bordo; los que tienen fila salen como antes. Estaba en rojo
// antes del arreglo: `generate` lanzaba «no está en el listado».
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t82_fixture.dart';

void main() {
  const writer = DepartureBaplieWriter();
  final clock = DateTime.utc(2026, 10, 26, 20);
  DepartureBaplie salida(Iterable<Movement> moves, ExportList? list) {
    final data = LoadingOperation.build(
        operationId: 'op',
        arrival: t82Arrival,
        loading: t82Loading,
        list: list,
        movements: moves);
    return writer.generate(
        operation: t82Operation,
        state: data.state,
        list: list,
        movements: moves,
        now: clock);
  }

  /// El grupo de segmentos del contenedor en el texto generado.
  List<String> grupo(String text, String container) {
    final segments = text.split("'").map((s) => s.trim()).toList();
    final eqd = segments.indexWhere((s) => s.startsWith('EQD+CN+$container'));
    expect(eqd, greaterThan(0), reason: '$container va en la salida');
    final start = segments.lastIndexWhere((s) => s.startsWith('LOC+147+'), eqd);
    return segments.sublist(start, eqd + 1);
  }

  test('sin listado (H4), el lleno cargado por su número sale con los datos del plan',
      () {
    final moves = [
      t82Move(MovementDraft.discharge('op', 'TSTU0000110', '0030984'), 1),
      t82Move(MovementDraft.loadFull('op', 'TSTU0000014', '0030282'), 2),
    ];
    final result = salida(moves, null);
    expect(result.containers, 2);
    expect(result.withoutRow, ['TSTU0000014']);
    final segmentos = grupo(result.text, 'TSTU0000014');
    expect(segmentos.first, 'LOC+147+0030282::5');
    expect(segmentos, contains('MEA+WT++KGM:7200'),
        reason: 'el peso es el del plan, no uno inventado');
    expect(segmentos, contains('LOC+9+GTSTC:139:6'));
    expect(segmentos, contains('LOC+11+PAMIT:139:6'));
    expect(segmentos.last, 'EQD+CN+TSTU0000014+22G1+++5');
    final leida = BaplieParserService().parse(result.text);
    final lleno =
        leida.containers.firstWhere((c) => c.containerId == 'TSTU0000014');
    expect(lleno.stowagePosition!.toIsoCode(), '0030282');
    expect(lleno.grossWeight, 7200);
    expect(lleno.status, ContainerStatus.full);
    // El que sigue a bordo va como antes, con lo que el plan declaraba.
    expect(result.text, contains(t82Transit));
  });

  test('con listado al que le falta la fila, el lleno sale con el plan y los demás con el listado',
      () {
    final sinLaFila = ExportList(
        fileName: 'parcial.xlsx',
        rows: t82List.rows.where((r) => r.containerId != 'TSTU0000014'));
    final result = salida(t82Loads, sinLaFila);
    expect(result.containers, 3);
    expect(result.withoutRow, ['TSTU0000014']);
    final leida = BaplieParserService().parse(result.text);
    final lleno =
        leida.containers.firstWhere((c) => c.containerId == 'TSTU0000014');
    expect(lleno.stowagePosition!.toIsoCode(), '0030282');
    expect(lleno.grossWeight, 7200);
    expect(lleno.vgmWeight, isNull, reason: 'el plan no trae VGM: no se inventa');
    final vacio =
        leida.containers.firstWhere((c) => c.containerId == 'TSTU0000020');
    expect(vacio.stowagePosition!.toIsoCode(), '0030984');
    expect(vacio.tareWeight, 2185, reason: 'el vacío sigue saliendo del listado');
    expect(vacio.status, ContainerStatus.empty);
  });

  test('con la fila, el lleno sale como antes, con los datos exactos del listado',
      () {
    final result = salida(t82Loads, t82List);
    expect(result.withoutRow, isEmpty);
    final lleno = BaplieParserService()
        .parse(result.text)
        .containers
        .firstWhere((c) => c.containerId == 'TSTU0000014');
    expect(lleno.vgmWeight, 7267); // T-132: el VGM nuevo va al kilo.
    expect(lleno.tareWeight, 3900);
    expect(lleno.dangerousGoods!.map((d) => d.unNumber), ['3082', '3077']);
  });

  test('un vacío asignado sin fila sigue pidiendo el listado, con su aviso', () {
    final moves = [
      t82Move(MovementDraft.discharge('op', 'TSTU0000110', '0030984'), 1),
      t82Move(
          MovementDraft.assignEmpty('op', '0030984', 'TSTU0000020', 2185), 2),
    ];
    expect(
        () => salida(moves, null),
        throwsA(isA<StateError>().having((e) => e.message, 'message',
            contains('El vacío asignado TSTU0000020 no está en el listado'))));
  });

  test('un lleno cargado en otra celda que la planificada sale en la real', () {
    final moves = [
      t82Move(MovementDraft.discharge('op', 'TSTU0000110', '0030984'), 1),
      t82Move(
          MovementDraft.loadFull('op', 'TSTU0000014', '0030482',
              reason: 'Grúa'),
          2),
    ];
    final result = salida(moves, null);
    expect(grupo(result.text, 'TSTU0000014').first, 'LOC+147+0030482::5');
  });
}
