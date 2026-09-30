import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/container_unit.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_geometry.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_profile.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_voyage.dart';
import 'package:baystream/features/vessel/domain/services/reefer_socket_validator.dart';

/// T-55, punto 2: tomas de reefer y paridad de bahía.
///
/// Uso: `dart run tool/t55_tomas_paridad.dart DIRECTORIO_CORPUS`.
/// No modifica `lib/`. Los perfiles «declarados» de aquí son escenarios de
/// prueba construidos desde la propuesta del archivo, no datos de un buque.
void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Indicar el directorio del corpus real');
  }
  final dir = args.single;
  VesselVoyage load(String name) => BaplieParserService()
      .parse(File('$dir/CORPUS_$name.edi').readAsStringSync());
  final out = <String, dynamic>{
    'A01': _a01(load('A01')),
    'paridadDeLas40PorArchivo': {
      for (var i = 1; i <= 6; i++) 'A0$i': _evenBayPattern(load('A0$i')),
    },
    'ECO_A05_contra_A06': _crossVoyage(load('A05'), load('A06')),
    'ECO_A06_contra_A05': _crossVoyage(load('A06'), load('A05')),
  };
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(out));
}

const _validator = ReeferSocketValidator();

/// Huecos físicos de 20 pies que ocupa una posición: la impar es ella misma;
/// la par, sus dos impares vecinas (la relación de neighborOccupiedSlots).
Set<String> _physical(IsoCoordinate p) => {
      for (final b in p.bay.isOdd ? [p.bay] : [p.bay - 1, p.bay + 1])
        '${b.toString().padLeft(3, '0')}${p.rowPadded}${p.tierPadded}',
    };

String _size(ContainerUnit c) {
  final s = c.sizeInFeet, p = c.stowagePosition;
  if (s == null || p == null) return 'sin tamaño o posición';
  if (s == 20) return p.bay.isOdd ? '20 en bahía impar' : '20 en bahía par';
  return p.bay.isEven ? '$s en bahía par' : '$s en bahía impar';
}

Map<String, int> _histogram(Iterable<String> values) {
  final h = <String, int>{};
  for (final v in values) {
    h[v] = (h[v] ?? 0) + 1;
  }
  return h;
}

ContainerUnit _moved(ContainerUnit c, String iso, int bay) {
  final p = c.stowagePosition!;
  return c.copyWith(
    id: '${c.id}-t55-$bay',
    containerId: '${c.containerId}@${bay.toString().padLeft(3, '0')}',
    isoSizeType: iso,
    stowagePosition:
        IsoCoordinateParser.fromValues(bay: bay, row: p.row, tier: p.tier),
  );
}

Map<String, dynamic> _a01(VesselVoyage parsed) {
  final proposal = VesselProfile.proposeFrom(parsed);
  final voyage = parsed.withGeometry(proposal.geometry);
  final reefers = voyage.containers.where((c) => c.isReefer).toList();
  final declared = proposal.copyWith(
      reeferSlotsOrigin: VesselProfileOrigin.declaredByUser);

  // Mismo hueco físico, otro viaje: cada toma que vino de un 40 recibe un 20
  // en cada impar vecina; cada toma que vino de un 20 recibe un 40 en la par.
  final from40 = reefers.where((c) => (c.sizeInFeet ?? 0) >= 40).toList();
  final from20 = reefers.where((c) => c.sizeInFeet == 20).toList();
  final twenties = [
    for (final c in from40)
      for (final b in [c.stowagePosition!.bay - 1, c.stowagePosition!.bay + 1])
        _moved(c, '22R1', b),
  ];
  final forties = [
    for (final c in from20)
      _moved(c, '45R1', c.stowagePosition!.bay % 4 == 1
          ? c.stowagePosition!.bay + 1
          : c.stowagePosition!.bay - 1),
  ];
  List<StowageValidationResult> run(List<ContainerUnit> units) =>
      _validator.validate(units, declared);
  bool physicallyCovered(ContainerUnit c) => declared.reeferSlots.any((s) =>
      _physical(IsoCoordinateParser.parse(s))
          .intersection(_physical(c.stowagePosition!))
          .isNotEmpty);

  final alerts20 = run(twenties);
  final alerts40 = run(forties);
  return {
    'contenedoresReefer': reefers.length,
    'tomasPropuestas': proposal.reeferSlots.length,
    'origenDeLasTomasPorTamano': _histogram(reefers.map(_size)),
    'tomasPropuestasDesde40': from40
        .map((c) => c.stowagePosition!.toIsoCode())
        .toList()
      ..sort(),
    'tomasPropuestasDesde20': from20
        .map((c) => c.stowagePosition!.toIsoCode())
        .toList()
      ..sort(),
    'alertasConLaPropuestaTalCual': run(reefers).length,
    'escenario20EnHuellaDe40': {
      'reefers20Simulados': twenties.length,
      'alertas': alerts20.length,
      'porSeveridad': _histogram(alerts20.map((r) => r.severity.name)),
      'enHuecoFisicoConToma': twenties.where(physicallyCovered).length,
      'ejemplo': alerts20.isEmpty ? null : alerts20.first.description,
    },
    'escenario40SobreTomaDe20': {
      'reefers40Simulados': forties.length,
      'alertas': alerts40.length,
      'porSeveridad': _histogram(alerts40.map((r) => r.severity.name)),
      'enHuecoFisicoConToma': forties.where(physicallyCovered).length,
      'ejemplo': alerts40.isEmpty ? null : alerts40.first.description,
    },
  };
}

/// Las 40 del corpus, ¿llegan siempre en pares ≡ 2 (mód. 4): 002, 006, 010…?
Map<String, int> _evenBayPattern(VesselVoyage v) => _histogram(v.containers
    .where((c) =>
        (c.sizeInFeet ?? 0) >= 40 && (c.stowagePosition?.bay.isEven ?? false))
    .map((c) => 'bahía par mód 4 = ${c.stowagePosition!.bay % 4}'));

/// Inventario = tomas propuestas por el viaje `inventory`, marcadas como
/// declaradas; carga = refrigerados del viaje `cargo`. La geometría es la
/// unión de los dos, para que «fuera de geometría» no tape el efecto.
Map<String, dynamic> _crossVoyage(VesselVoyage inventory, VesselVoyage cargo) {
  final proposal = VesselProfile.proposeFrom(inventory);
  final geometry = VesselGeometry.proposeFrom(
      [...inventory.stowagePositions, ...cargo.stowagePositions]);
  final declared = proposal.copyWith(
      geometry: geometry,
      reeferSlotsOrigin: VesselProfileOrigin.declaredByUser);
  final reefers = cargo.containers.where((c) => c.isReefer).toList();
  final alerts = _validator.validate(reefers, declared);
  final flagged = alerts.expand((r) => r.containerIds).toSet();
  final flaggedUnits =
      reefers.where((c) => flagged.contains(c.containerId)).toList();
  final physicalSockets = {
    for (final s in declared.reeferSlots)
      ..._physical(IsoCoordinateParser.parse(s)),
  };
  final byParity = flaggedUnits
      .where((c) =>
          c.stowagePosition != null &&
          _physical(c.stowagePosition!)
              .intersection(physicalSockets)
              .isNotEmpty)
      .toList();
  return {
    'inventario': inventory.vessel.name,
    'claveInventario': proposal.key,
    'carga': cargo.vessel.name,
    'claveCarga': cargo.vessel.profileKey,
    'mismaClaveDePerfil': proposal.key == cargo.vessel.profileKey,
    'tomasDelInventario': declared.reeferSlots.length,
    'reefersEnLaCarga': reefers.length,
    'reefersConCodigoExactoEnElInventario': reefers
        .where((c) =>
            declared.reeferSlots.contains(c.stowagePosition?.toIsoCode()))
        .length,
    'alertas': alerts.length,
    'alertasPorSeveridad': _histogram(alerts.map((r) => r.severity.name)),
    'alertasCuyoHuecoFisicoSiTieneToma': byParity.length,
    'ejemplosPorParidad': byParity
        .take(6)
        .map((c) => {
              'contenedor': c.containerId,
              'tamano': c.sizeInFeet,
              'posicion': c.stowagePosition!.toIsoCode(),
              'tomasEnElMismoHuecoFisico': declared.reeferSlots
                  .where((s) => _physical(IsoCoordinateParser.parse(s))
                      .intersection(_physical(c.stowagePosition!))
                      .isNotEmpty)
                  .toList(),
            })
        .toList(),
  };
}
