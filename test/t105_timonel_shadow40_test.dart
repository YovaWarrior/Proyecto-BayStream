// Hallazgo de la aceptación cruzada de T-105 (Timonel, 16-oct): un 40 en una
// bahía par ocupa la misma fila y nivel en las dos impares vecinas, y review()
// no lo ve. Especificación para la corrección de Capitán (10.63). Autónoma: no
// usa fixtures; corre desde test/ o tool/. Datos sintéticos, PROVISIONALES.
//
// Hoy (7a06c5d) los cuatro casos de conflicto salen válidos y la prueba falla.
// Tras la corrección: rojo, el mismo mensaje en preview, move y request, y el
// mensaje nombra la celda de destino. Los dos controles siguen siendo válidos.
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/change_requests.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';

const _header =
    "UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20+T105TM+++TST:172:20+++9000015:146:11:PRUEBA T-105 TM'LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'";
String _cell(String id, String position, {String iso = '22G1'}) =>
    "LOC+147+$position::5'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'MEA+AAE+WT+KGM:5000'EQD+CN+$id+$iso+++5'";
const _geometry = VesselGeometry(
    portRows: 4,
    starboardRows: 3,
    holdTiers: [2, 4],
    deckTiers: [82, 84],
    centerRowOnDeck: true,
    centerRowInHold: true);

/// Bahía 003: TSTU0000011 (20) en 0030282. Bahía 005: TSTU0000015 (20) en 0050282.
/// Bahía 004: TSTU0000016 (45G1, 40) en 0040182, que ocupa 0030182 y 0050182.
LoadingOperation sombra40([List<Movement> movements = const []]) {
  final loading = BaplieParserService()
      .parse(_header +
          _cell('TSTU0000011', '0030282') +
          _cell('TSTU0000015', '0050282') +
          _cell('TSTU0000016', '0040182', iso: '45G1'))
      .withGeometry(_geometry, portOfCall: 'GTSTC');
  return LoadingOperation.build(
      operationId: 'op', loading: loading, movements: movements);
}

void main() {
  const office = Operator(uid: 'o', name: 'Oficina', role: OperatorRole.office);
  const dock = Operator(uid: 'd', name: 'Muelle', role: OperatorRole.dock);
  final operation = Operation(
      id: 'op',
      vesselName: 'PRUEBA T-105 TM',
      voyageNumber: 'T105TM',
      portOfCall: 'GTSTC',
      createdAt: DateTime.utc(2026),
      published: true);
  const service = ChangeRequests();
  final loaded40 = Movement(
      id: 'm1',
      operationId: 'op',
      type: MovementType.loadFull,
      target: 'C:TSTU0000016',
      payload: MovementDraft.loadFull('op', 'TSTU0000016', '0040182').payload,
      author: const MovementAuthor(name: 'Prueba', role: OperatorRole.dock),
      deviceId: 'test',
      sequence: 1,
      createdAt: DateTime.utc(2026));

  String? outcome(MovementDraft Function() save) {
    try {
      save();
      return null;
    } on StateError catch (e) {
      return e.message;
    }
  }

  final conflicts = <(String, LoadingOperation, PositionChange)>[
    ('20 de la 003 bajo la sombra del 40 pendiente', sombra40(),
        const PositionChange('C:TSTU0000011', '0030282', '0030182')),
    ('20 de la 005 bajo la sombra del 40 pendiente', sombra40(),
        const PositionChange('C:TSTU0000015', '0050282', '0050182')),
    ('40 pendiente sobre los dos 20 previstos en 0030282 y 0050282', sombra40(),
        const PositionChange('C:TSTU0000016', '0040182', '0040282')),
    ('20 bajo la sombra del 40 ya cargado a bordo', sombra40([loaded40]),
        const PositionChange('C:TSTU0000011', '0030282', '0030182')),
  ];
  for (final (name, data, change) in conflicts) {
    test('Sombra del 40, rojo en los tres caminos: $name', () {
      final p = service.preview(data, office, [change]);
      expect(p.valid, isFalse, reason: 'hoy sale válido');
      expect(service.preview(data, dock, [change]).error, p.error);
      expect(p.error, contains(change.to));
      expect(outcome(() => service.move(operation, office, data, [change], 'Motivo')),
          p.error);
      expect(outcome(() => service.request(operation, dock, data, [change], 'Motivo')),
          p.error);
    });
  }

  final controls = <(String, PositionChange)>[
    ('20 a 0030082, sin 40 vecino', const PositionChange('C:TSTU0000011', '0030282', '0030082')),
    ('40 a 0040082, con 0030082 y 0050082 libres',
        const PositionChange('C:TSTU0000016', '0040182', '0040082')),
  ];
  for (final (name, change) in controls) {
    test('Sombra del 40, control que sigue válido: $name', () {
      final data = sombra40();
      expect(service.preview(data, office, [change]).valid, isTrue);
      expect(outcome(() => service.move(operation, office, data, [change], 'Motivo')), isNull);
      expect(outcome(() => service.request(operation, dock, data, [change], 'Motivo')), isNull);
    });
  }
}
