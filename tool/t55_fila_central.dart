import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/container_unit.dart';
import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_geometry.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_profile.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';

/// T-55, punto 1: la fila 00 que `VesselGeometry.orderedRows` supone siempre.
///
/// Uso: `dart run tool/t55_fila_central.dart DIRECTORIO_CORPUS`.
/// No modifica `lib/`. Parte A es un caso controlado; parte B mira el corpus.
void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Indicar el directorio del corpus real');
  }
  final out = <String, dynamic>{
    'controlado': _controlledCase(),
    'corpus': _corpus(args.single),
  };
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(out));
}

const _dg = DangerousGoodsValidator();

ContainerUnit _unit(String id, String iso, String position, String un,
        String hazardClass) =>
    ContainerUnit(
      id: id,
      containerId: id,
      isoSizeType: iso,
      stowagePosition: IsoCoordinateParser.parse(position),
      isDangerous: true,
      imdgClass: hazardClass,
      unNumber: un,
      dangerousGoods: [DangerousGoods(unNumber: un, hazardClass: hazardClass)],
    );

/// Par de código 2 (UN1170 clase 3 / UN0012 clase 1.4S, §176.83(b)), los dos
/// de 40 pies en la misma bahía y nivel, solo cambia la fila.
Map<String, dynamic> _controlledCase() {
  // Geometría cualquiera: no existe parámetro para declarar «sin fila 00».
  const geometry = VesselGeometry(
      portRows: 6,
      starboardRows: 6,
      holdTiers: [2, 4, 6, 8],
      deckTiers: [82, 84, 86]);
  final rows = geometry.orderedRows;
  Map<String, dynamic> pair(String label, String posA, String posB) {
    final a = _unit('T55A', '45G1', posA, '1170', '3');
    final b = _unit('T55B', '45G1', posB, '0012', '1.4');
    final r = _dg.evaluatePair(
        a, a.dangerousGoods!.single, b, b.dangerousGoods!.single, geometry);
    final ra = a.stowagePosition!.row, rb = b.stowagePosition!.row;
    return {
      'caso': label,
      'posiciones': [posA, posB],
      'indicesEnOrderedRows': [rows.indexOf(ra), rows.indexOf(rb)],
      'lateralGapCalculado': (rows.indexOf(ra) - rows.indexOf(rb)).abs() - 1,
      'estado': r.status.name,
      'severidad': r.severity.name,
      'descripcion': r.description,
    };
  }

  return {
    'orderedRows': rows,
    'coversFila00SinDeclararla': geometry.covers(IsoCoordinateParser.parse('0020082')),
    'casos': [
      pair('cubierta 02/01: vecinas si el buque no tiene 00', '0020282', '0020182'),
      pair('cubierta 01/03: control, contiguas del mismo lado', '0020182', '0020382'),
      pair('cubierta 02/04: control, contiguas del mismo lado', '0020282', '0020482'),
      pair('cubierta 00/01: control, con la 00 ocupada', '0020082', '0020182'),
      pair('cubierta 02/03: una fila de por medio sin la 00', '0020282', '0020382'),
      pair('bodega 02/01: vecinas si el buque no tiene 00', '0020204', '0020104'),
      pair('bodega 01/03: control', '0020104', '0020304'),
    ],
  };
}

Map<String, dynamic> _corpus(String dir) {
  final result = <String, dynamic>{};
  for (var i = 1; i <= 6; i++) {
    final name = 'A0$i';
    final raw = File('$dir/CORPUS_$name.edi').readAsStringSync();
    final parsed = BaplieParserService().parse(raw);
    final profile = VesselProfile.proposeFrom(parsed);
    final geometry = profile.geometry;
    final voyage = parsed.withGeometry(geometry);

    // Ocupación física por hueco de 20 pies: un 40 en bahía par ocupa sus dos
    // impares vecinas (misma relación que neighborOccupiedSlots).
    final physical = <String>{}; // bahíaImpar|fila|nivel
    final byBayNumber = <String>{}; // bahía tal cual|fila|nivel
    final row00ByZone = {'cubierta': 0, 'bodega': 0};
    for (final c in voyage.containers) {
      final p = c.stowagePosition;
      if (p == null) continue;
      final zone = geometry.isDeckTier(p.tier) ? 'cubierta' : 'bodega';
      if (p.row == 0) row00ByZone[zone] = row00ByZone[zone]! + 1;
      byBayNumber.add('${p.bay}|${p.row}|${p.tier}');
      final bays = p.bay.isOdd ? [p.bay] : [p.bay - 1, p.bay + 1];
      for (final b in bays) {
        physical.add('$b|${p.row}|${p.tier}');
      }
    }
    int both01and02(Set<String> cells) {
      var n = 0;
      for (final cell in cells) {
        final parts = cell.split('|');
        if (parts[1] != '1') continue;
        if (cells.contains('${parts[0]}|2|${parts[2]}')) n++;
      }
      return n;
    }

    // ¿Hay pares de código 2 que salen satisfechos solo porque cruzan la 00?
    final dg = _dg.validate(voyage.containers, geometry);
    final crossing = dg
        .where((r) =>
            r.positions.length == 2 &&
            r.description.contains('Código 2: separación satisfecha') &&
            {r.positions[0].row, r.positions[1].row}.containsAll({1, 2}))
        .map((r) => {
              'estado': r.status.name,
              'posiciones': r.positions.map((p) => p.toIsoCode()).toList(),
              'contenedores': r.containerIds,
            })
        .toList();
    final code2 = dg
        .where((r) =>
            r.description.contains('Código 2') ||
            r.description.contains('código 2'))
        .length;

    result[name] = {
      'buque': voyage.vessel.name,
      'contenedores': voyage.containers.length,
      'orderedRows': geometry.orderedRows,
      'posicionesEnFila00': row00ByZone,
      'celdasMismaBahiaNivelCon01y02': both01and02(byBayNumber),
      'huecosFisicos20Con01y02': both01and02(physical),
      'resultadosSegregacion': dg.length,
      'resultadosQueMencionanCodigo2': code2,
      'paresCodigo2Satisfechos01y02': crossing,
      'estadosSegregacion': {
        for (final s in ValidationStatus.values)
          s.name: dg.where((r) => r.status == s).length,
      },
    };
  }
  return result;
}
