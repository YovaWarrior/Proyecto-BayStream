import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/change_requests.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t76_fixture.dart';
import 't81_office_changes_test.dart' as f;

LoadingOperation t105Data([List<Movement> movements = const []]) =>
    LoadingOperation.build(
        operationId: 'op',
        loading: t76Loading.withGeometry(
            t76Loading.geometry!.copyWith(centerRowOnDeck: true),
            portOfCall: 'GTSTC'),
        list: t76List,
        movements: movements);

void main() {
  const service = ChangeRequests();
  const free = [PositionChange(f.key, '0030282', '0030082')];
  const swap = [
    PositionChange(f.key, '0030282', '0030682'),
    PositionChange('C:FULL0005678', '0030682', '0030282')
  ];
  final loaded = t105Data(
      [t76Movement(MovementDraft.loadFull('op', 'FULL0001234', '0030282'), 1)]);
  final cancelled = t105Data(
      [t76Movement(MovementDraft.cancelItem('op', f.key, 'No embarca'), 1)]);
  final cases = <(String, LoadingOperation, List<PositionChange>, bool)>[
    ('libre', t105Data(), free, true),
    ('intercambio', t105Data(), swap, true),
    ('cargado', loaded, free, false),
    ('cancelado', cancelled, free, false),
    (
      'ocupación de llegada',
      t76Operation(),
      [
        const PositionChange(f.key, '0030282', '0030482'),
        const PositionChange('R:0030482', '0030482', '0030282')
      ],
      false
    ),
    (
      '20 en par',
      t105Data(),
      [const PositionChange(f.key, '0030282', '0040282')],
      false
    ),
    (
      'fuera de geometría',
      t105Data(),
      [const PositionChange(f.key, '0030282', '0039882')],
      false
    ),
    (
      'origen cambió',
      t105Data(),
      [const PositionChange(f.key, '0030682', '0030082')],
      false
    ),
    ('falta contraparte', t105Data(), [swap.first], false),
    (
      'grupo de reservas',
      t105Data(),
      [
        const PositionChange('R:0030482', '0030482', '0030382'),
        const PositionChange('R:0030382', '0030382', '0030482')
      ],
      false
    ),
    ('lote vacío', t105Data(), [], false),
  ];
  for (final (name, data, changes, valid) in cases) {
    test('T-105 preview, move y request coinciden: $name', () {
      for (final actor in [f.office, f.dock]) {
        final result = service.preview(data, actor, changes);
        expect(result.valid, valid);
        MovementDraft save() => actor.role == OperatorRole.office
            ? service.move(f.operation, actor, data, changes, 'Motivo')
            : service.request(f.operation, actor, data, changes, 'Motivo');
        if (valid) {
          expect(save().validate(), isNull);
          expect(result.isSwap, changes.length == 2);
        } else {
          expect(
              save,
              throwsA(isA<StateError>().having(
                  (e) => e.message, 'mensaje de preview', result.error)));
        }
      }
    });
  }
  test('T-105 preview exige sesión autorizada sin mutar el plan', () {
    final data = t105Data();
    expect(service.preview(data, null, free).error, 'Inicia sesión para mover');
    expect(data.movements, isEmpty);
    expect(data.plan.loading[f.key]!.plannedPosition, '0030282');
  });
  test('T-105 un 40 en impar recibe el mensaje de review', () {
    final data = LoadingOperation.build(
        operationId: 'op',
        loading: t76Voyage(
            [t76Unit('FORTY', '0040282').copyWith(isoSizeType: '45G1')]));
    const changes = [PositionChange('C:FORTY', '0040282', '0030282')];
    expect(service.preview(data, f.office, changes).error,
        service.review(data, changes));
    expect(service.preview(data, f.office, changes).valid, isFalse);
  });
}
