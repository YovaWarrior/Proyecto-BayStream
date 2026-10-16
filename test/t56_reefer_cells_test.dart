import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/reefer_socket_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-56: la toma se busca por celda física con el código de siete dígitos tal
/// como está guardado, sin cambiar el perfil ni su JSON. Datos sintéticos.
void main() {
  const vessel = Vessel(id: 'v', name: 'PRUEBA T56');
  const geometry = VesselGeometry(
      portRows: 6,
      starboardRows: 6,
      holdTiers: [2, 4, 6, 8],
      deckTiers: [82, 84, 86]);
  var serial = 0;
  ContainerUnit reefer(String position, {String iso = '22R1'}) => ContainerUnit(
      id: 'id-${serial++}',
      containerId: 'T56U${serial.toString().padLeft(7, '0')}',
      isoSizeType: iso,
      isReefer: true,
      stowagePosition: IsoCoordinateParser.parse(position));
  VesselProfile profile(Set<String> slots,
          {VesselProfileOrigin origin = VesselProfileOrigin.declaredByUser}) =>
      VesselProfile(
          identity: vessel.profileIdentity,
          vesselName: vessel.name,
          geometry: geometry,
          reeferSlots: slots,
          reeferSlotsOrigin: origin,
          origin: VesselProfileOrigin.declaredByUser,
          updatedAt: DateTime.utc(2026));
  const validator = ReeferSocketValidator();
  List<StowageValidationResult> run(String position, Set<String> slots,
          {VesselProfileOrigin origin = VesselProfileOrigin.declaredByUser}) =>
      validator.validate([reefer(position)], profile(slots, origin: origin));

  group('T-56 un 40 en la par E', () {
    test('conforme con la toma de 021, 022 o 023', () {
      for (final socket in ['0210704', '0220704', '0230704']) {
        for (final origin in VesselProfileOrigin.values) {
          expect(run('0220704', {socket}, origin: origin), isEmpty,
              reason: '$socket, ${origin.name}');
        }
      }
    });
    test('sin ninguna: error con inventario declarado y aviso sin él', () {
      final declared = run('0220704', {'0200704', '0240704', '0220706'});
      expect(declared.single.severity, ValidationSeverity.error);
      expect(declared.single.status, ValidationStatus.nonConforming);
      expect(declared.single.description, contains('inventario declarado'));
      for (final origin in [
        VesselProfileOrigin.proposedFromFile,
        VesselProfileOrigin.template
      ]) {
        final r = run('0220704', {}, origin: origin).single;
        expect(r.severity, ValidationSeverity.warning);
        expect(r.status, ValidationStatus.notEvaluated);
      }
    });
  });

  group('T-56 un 20 en la impar b', () {
    test('conforme con la toma de 021', () {
      for (final origin in VesselProfileOrigin.values) {
        expect(run('0210704', {'0210704'}, origin: origin), isEmpty);
      }
    });
    test('con solo la 022, aviso de confirmar el extremo con el código', () {
      for (final origin in VesselProfileOrigin.values) {
        final r = run('0210704', {'0220704'}, origin: origin).single;
        expect(r.rule, StowageRule.reeferSocket);
        expect(r.severity, ValidationSeverity.warning, reason: origin.name);
        expect(r.status, ValidationStatus.notEvaluated);
        expect(r.description, contains('0220704'));
        expect(r.description,
            contains('La celda tiene toma, pero no consta en qué extremo: '
                'confírmalo.'));
        expect(r.positions.single.toIsoCode(), '0210704');
      }
    });
    test('se miran las dos vecinas: la 020 también avisa, sin calcular pares',
        () {
      expect(run('0210704', {'0200704'}).single.description,
          contains('consta la toma 0200704'));
      // Caso ALFA de T-55: la 044 cubre a la 043 y a la 045.
      for (final odd in ['0430704', '0450704']) {
        expect(run(odd, {'0440704'}).single.severity,
            ValidationSeverity.warning);
      }
      expect(run('0210704', {'0200704', '0220704'}).single.description,
          contains('constan las tomas 0200704 y 0220704'));
    });
    test('con solo la 023, la regla de hoy: error declarado, aviso sin él', () {
      final declared = run('0210704', {'0230704'}).single;
      expect(declared.severity, ValidationSeverity.error);
      expect(declared.status, ValidationStatus.nonConforming);
      final proposed = run('0210704', {'0230704'},
              origin: VesselProfileOrigin.proposedFromFile)
          .single;
      expect(proposed.severity, ValidationSeverity.warning);
      expect(proposed.description, contains('cota inferior'));
    });
    test('la 041 sola, conforme con la 041', () {
      for (final origin in VesselProfileOrigin.values) {
        expect(run('0410382', {'0410382'}, origin: origin), isEmpty);
      }
    });
    test('la bahía 001 no busca una 000 inexistente', () {
      expect(run('0010182', {}).single.severity, ValidationSeverity.error);
      expect(run('0010182', {'0020182'}).single.severity,
          ValidationSeverity.warning);
    });
    test('fuera de la geometría no cambia: no evaluado', () {
      final r = run('0211504', {'0221504'}).single;
      expect(r.status, ValidationStatus.notEvaluated);
      expect(r.description, contains('fuera de la geometría'));
    });
  });

  test(
      'T-56 escenario de T-55: 82 errores pasan a avisos de extremo y 9 a '
      'conformes', () {
    // 41 tomas de 40 en pares (ALFA: 002 a 038 de cuatro en cuatro y la 044),
    // en cubierta, y 9 tomas de 20 en la 021, en bodega, como en A01.
    const evenBays = [2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 44];
    final from40 = <IsoCoordinate>[
      for (final bay in evenBays)
        for (final row in [1, 2, 3, 4])
          IsoCoordinateParser.fromValues(bay: bay, row: row, tier: 82),
    ].take(41).toList();
    final from20 = [
      for (var row = 1; row <= 9; row++)
        IsoCoordinateParser.fromValues(bay: 21, row: row, tier: 4),
    ];
    final inventory = {...from40, ...from20}.map((p) => p.toIsoCode()).toSet();
    expect(inventory, hasLength(50));
    String code(int bay, IsoCoordinate p) =>
        IsoCoordinateParser.fromValues(bay: bay, row: p.row, tier: p.tier)
            .toIsoCode();
    final twenties = [
      for (final p in from40)
        for (final bay in [p.bay - 1, p.bay + 1]) reefer(code(bay, p)),
    ];
    final forties = [
      for (final p in from20) reefer(code(22, p), iso: '45R1'),
    ];
    // Antes de T-56 se buscaba el código exacto: las 91 eran errores.
    final exact = [...twenties, ...forties].where((c) =>
        !inventory.contains(c.stowagePosition!.toIsoCode()));
    expect(exact, hasLength(91));

    final declared = profile(inventory);
    final alerts20 = validator.validate(twenties, declared);
    expect(alerts20, hasLength(82));
    for (final r in alerts20) {
      expect(r.severity, ValidationSeverity.warning);
      expect(r.status, ValidationStatus.notEvaluated);
      expect(r.description, contains('no consta en qué extremo'));
    }
    expect(alerts20.where((r) => r.severity == ValidationSeverity.error),
        isEmpty);
    expect(validator.validate(forties, declared), isEmpty);
  });
}
