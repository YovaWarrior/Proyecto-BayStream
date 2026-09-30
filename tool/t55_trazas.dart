import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_profile.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_voyage.dart';
import 'package:baystream/features/vessel/domain/services/container_stacking_validator.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';
import 'package:baystream/features/vessel/domain/services/reefer_socket_validator.dart';
import 'package:baystream/features/vessel/domain/services/stack_weight_validator.dart';

/// T-55, punto 4: un caso por validador, trazado sin el parser de la app.
///
/// Uso: `dart run tool/t55_trazas.dart DIRECTORIO_CORPUS`.
/// `_Raw` lee LOC+147, MEA+WT y EQD del texto crudo con expresiones propias;
/// lo que se compara es ese conteo contra la salida de los validadores.
void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Indicar el directorio del corpus real');
  }
  final dir = args.single;
  final out = <String, dynamic>{};
  for (final name in ['A01', 'A03']) {
    final text = File('$dir/CORPUS_$name.edi').readAsStringSync();
    final raw = _Raw.parse(text);
    final parsed = BaplieParserService().parse(text);
    final profile = VesselProfile.proposeFrom(parsed);
    final voyage = parsed.withGeometry(profile.geometry);
    out[name] = {
      'contenedoresCrudo': raw.length,
      'contenedoresApp': voyage.containers.length,
      'T38': _weight(raw, voyage, profile),
      'T39': _reefer(text, voyage, profile),
      'T40': _stacking(raw, voyage, profile),
      if (name == 'A03') 'T41': _segregation(voyage),
    };
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(out));
}

class _Raw {
  final String id, iso;
  final int bay, row, tier;
  final double? kg;
  const _Raw(this.id, this.iso, this.bay, this.row, this.tier, this.kg);

  int? get feet => switch (iso.isEmpty ? '' : iso[0]) {
        '2' => 20,
        '4' => 40,
        'L' || 'M' => 45,
        _ => null,
      };
  bool get deck => tier >= 80;

  /// Un grupo empieza en LOC+147 y termina en el siguiente LOC+147.
  static List<_Raw> parse(String text) {
    final segments = text
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .split("'")
        .map((s) => s.trim());
    final result = <_Raw>[];
    String? pos, id, iso;
    double? kg;
    void flush() {
      if (pos != null && id != null) {
        result.add(_Raw(id, iso ?? '', int.parse(pos.substring(0, 3)),
            int.parse(pos.substring(3, 5)), int.parse(pos.substring(5, 7)), kg));
      }
    }

    for (final s in segments) {
      final loc = RegExp(r'^LOC\+147\+(\d{7})').firstMatch(s);
      if (loc != null) {
        flush();
        pos = loc.group(1);
        id = null;
        iso = null;
        kg = null;
        continue;
      }
      final mea = RegExp(r'^MEA\+WT\+[^+]*\+KGM:([\d.]+)').firstMatch(s);
      if (mea != null && kg == null) kg = double.parse(mea.group(1)!);
      final eqd = RegExp(r'^EQD\+CN\+([^+]+)\+([^+:]*)').firstMatch(s);
      if (eqd != null && id == null) {
        id = eqd.group(1);
        iso = eqd.group(2);
      }
    }
    flush();
    return result;
  }
}

/// Peso por pila: suma cruda por (bahía tal cual, fila, zona), el mismo
/// criterio que declara T-38, contra la salida del validador. Además cuenta
/// las columnas físicas donde conviven 20 y 40, que ese criterio parte en dos.
Map<String, dynamic> _weight(
    List<_Raw> raw, VesselVoyage voyage, VesselProfile profile) {
  final byStack = <String, double>{};
  for (final c in raw) {
    final key = '${c.bay}|${c.row}|${c.deck}';
    byStack[key] = (byStack[key] ?? 0) + (c.kg ?? 0);
  }
  final checks = <String, dynamic>{};
  for (final limit in [75000.0, 62500.5]) {
    final app = const StackWeightValidator()
        .validate(voyage, profile.copyWith(stackWeightLimitKg: limit));
    checks['$limit'] = {
      'crudo': byStack.values.where((w) => w > limit).length,
      'app': app.length,
    };
  }
  final app = const StackWeightValidator()
      .validate(voyage, profile.copyWith(stackWeightLimitKg: 62500.5));
  final traced = app.where((r) =>
      r.positions.map((p) => p.toIsoCode()).join('/') ==
      '0020108/0020110/0020112');

  // Columna física: hueco impar de 20 pies, fila y zona.
  final columns = <String, Set<int>>{};
  for (final c in raw) {
    final bays = c.bay.isOdd ? [c.bay] : [c.bay - 1, c.bay + 1];
    for (final b in bays) {
      columns.putIfAbsent('$b|${c.row}|${c.deck}', () => {}).add(c.feet ?? 0);
    }
  }
  final mixed = columns.entries
      .where((e) => e.value.contains(20) && e.value.any((f) => f >= 40))
      .map((e) => e.key)
      .toList()
    ..sort();
  return {
    'pilasSobreElLimite': checks,
    'pila0020108_crudo': {
      for (final c in raw.where((c) => c.bay == 2 && c.row == 1 && !c.deck))
        '${c.id} ${c.bay.toString().padLeft(3, '0')}0${c.row}'
            '${c.tier.toString().padLeft(2, '0')}': c.kg,
    },
    'pila0020108_app': traced.map((r) => r.description).toList(),
    'columnasFisicasCon20y40': mixed.length,
    'ejemplosColumnasMixtas': mixed.take(8).toList(),
  };
}

/// Refrigerados: con las tomas propuestas del mismo archivo el panel muestra
/// cero; se traza el primer refrigerado del texto crudo hasta su toma.
Map<String, dynamic> _reefer(
    String text, VesselVoyage voyage, VesselProfile profile) {
  final reefers = voyage.containers.where((c) => c.isReefer).toList();
  final first = reefers.isEmpty ? null : reefers.first;
  return {
    'reefersApp': reefers.length,
    'tomasPropuestas': profile.reeferSlots.length,
    'alertasApp':
        const ReeferSocketValidator().validate(voyage.containers, profile).length,
    'segmentosTmpCrudo': RegExp(r"TMP\+").allMatches(text).length,
    'primerReefer': first == null
        ? null
        : {
            'contenedor': first.containerId,
            'iso': first.isoSizeType,
            'posicion': first.stowagePosition?.toIsoCode(),
            'temperatura': first.temperature,
            'tomaEnPerfil': profile
                .hasReeferSocket(first.stowagePosition?.toIsoCode() ?? ''),
          },
  };
}

/// 20 sobre 40: recalculado desde el crudo, por columna física y zona, con la
/// carga inferior más cercana. También se cuenta el caso inverso (40 sobre
/// 20), que la regla no señala, para ver que el conteo discrimina.
Map<String, dynamic> _stacking(
    List<_Raw> raw, VesselVoyage voyage, VesselProfile profile) {
  final columns = <String, List<_Raw>>{};
  for (final c in raw) {
    final bays = c.bay.isOdd ? [c.bay] : [c.bay - 1, c.bay + 1];
    for (final b in bays) {
      columns.putIfAbsent('$b|${c.row}|${c.deck}', () => []).add(c);
    }
  }
  var twentyOverForty = 0, fortyOverTwenty = 0;
  for (final stack in columns.values) {
    stack.sort((a, b) => a.tier.compareTo(b.tier));
    for (var i = 1; i < stack.length; i++) {
      final below = stack[i - 1], above = stack[i];
      if (above.feet == 20 && (below.feet ?? 0) >= 40) twentyOverForty++;
      if ((above.feet ?? 0) >= 40 && below.feet == 20) fortyOverTwenty++;
    }
  }
  return {
    'veinteSobreCuarentaCrudo': twentyOverForty,
    'cuarentaSobreVeinteCrudo': fortyOverTwenty,
    'alertasApp': const ContainerStackingValidator()
        .validate(voyage, profile.geometry)
        .length,
  };
}

/// Par 1 de A03 (§10.20): 0020386 / 0030586.
Map<String, dynamic> _segregation(VesselVoyage voyage) {
  final results =
      const DangerousGoodsValidator().validate(voyage.containers, voyage.geometry!);
  final pair = results.where((r) =>
      r.positions.map((p) => p.toIsoCode()).toSet().containsAll(
          {'0020386', '0030586'}));
  return {
    'totales': {
      for (final s in ValidationStatus.values)
        s.name: results.where((r) => r.status == s).length,
    },
    'par1': pair
        .map((r) => {
              'estado': r.status.name,
              'severidad': r.severity.name,
              'contenedores': r.containerIds,
              'descripcion': r.description,
              'referencias': r.references,
            })
        .toList(),
  };
}
