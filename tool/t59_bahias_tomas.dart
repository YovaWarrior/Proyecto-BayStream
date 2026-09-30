import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/container_unit.dart';

/// T-59: qué impares cubre cada bahía par y en qué extremo del par van los
/// refrigerados de 20 pies, derivado solo de las posiciones reales.
///
/// Uso: `dart run tool/t59_bahias_tomas.dart DIRECTORIO_CORPUS`.
/// No modifica `lib/`. Las bahías se numeran de proa a popa (ISO), así que
/// la impar menor de un par es el extremo de proa y la mayor, el de popa.
void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Indicar el directorio del corpus real');
  }
  final out = <String, dynamic>{};
  for (var i = 1; i <= 6; i++) {
    final name = 'A0$i';
    final voyage = BaplieParserService()
        .parse(File('${args.single}/CORPUS_$name.edi').readAsStringSync());
    out[name] = _analyze(voyage.vessel.name, voyage.containers.toList());
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(out));
}

String _b(int bay) => bay.toString().padLeft(3, '0');

bool _is20(ContainerUnit c) =>
    c.sizeInFeet == 20 && (c.stowagePosition?.bay.isOdd ?? false);
bool _is40(ContainerUnit c) =>
    (c.sizeInFeet ?? 0) >= 40 && (c.stowagePosition?.bay.isEven ?? false);

Map<String, dynamic> _analyze(String vessel, List<ContainerUnit> all) {
  final twenties = all.where(_is20).toList();
  final forties = all.where(_is40).toList();
  final evenBays = forties.map((c) => c.stowagePosition!.bay).toSet().toList()
    ..sort();
  final oddBays = twenties.map((c) => c.stowagePosition!.bay).toSet();

  // Hueco físico ocupado por un 20: bahía impar, fila, nivel.
  final cells20 = {
    for (final c in twenties)
      '${c.stowagePosition!.bay}|${c.stowagePosition!.row}|${c.stowagePosition!.tier}',
  };

  // Tabla de correspondencia: cada par con sus dos impares vecinas y la
  // evidencia del archivo. Un «choque» es un 40 en la par y un 20 en la
  // impar en la misma fila y nivel: si ocurre, esa impar NO es parte del par.
  final pairs = <Map<String, dynamic>>[];
  for (final e in evenBays) {
    final here = forties.where((c) => c.stowagePosition!.bay == e);
    Map<String, dynamic> side(int odd) {
      final clashes = here
          .where((c) => cells20.contains(
              '$odd|${c.stowagePosition!.row}|${c.stowagePosition!.tier}'))
          .map((c) => c.stowagePosition!.toIsoCode())
          .toList();
      return {
        'bahia': _b(odd),
        'veintesEnElArchivo':
            twenties.where((c) => c.stowagePosition!.bay == odd).length,
        'choquesCon40': clashes.length,
        if (clashes.isNotEmpty) 'ejemplosChoque': clashes.take(3).toList(),
      };
    }

    pairs.add({
      'par': _b(e),
      'cuarentas': here.length,
      'modulo4': e % 4,
      'proa': side(e - 1),
      'popa': side(e + 1),
    });
  }

  // Impares reclamadas por dos pares con carga (por ejemplo 043 entre 042 y
  // 044), e impares con carga de 20 que ningún par con carga reclama.
  final claimed = <int, List<String>>{};
  for (final e in evenBays) {
    for (final o in [e - 1, e + 1]) {
      claimed.putIfAbsent(o, () => []).add(_b(e));
    }
  }
  final shared = {
    for (final entry in claimed.entries)
      if (entry.value.length > 1) _b(entry.key): entry.value,
  };
  final orphans = (oddBays.where((o) => !claimed.containsKey(o)).toList()
        ..sort())
      .map(_b)
      .toList();

  // Refrigerados de 20: ¿extremo de proa o de popa del par? El par se toma
  // del archivo: la par con carga vecina a esa impar; si hay dos, ambiguo.
  final reefer20 = twenties.where((c) => c.isReefer).toList();
  final ends = <String, int>{};
  final byPair = <String, Map<String, int>>{};
  for (final c in reefer20) {
    final b = c.stowagePosition!.bay;
    final owners = claimed[b] ?? const <String>[];
    final String end;
    final String pair;
    if (owners.length == 1) {
      pair = owners.single;
      end = int.parse(pair) > b ? 'proa' : 'popa';
    } else {
      pair = owners.isEmpty ? 'sin par con carga' : 'ambiguo ${owners.join('/')}';
      end = pair;
    }
    ends[end] = (ends[end] ?? 0) + 1;
    final key = '$pair (impar ${_b(b)})';
    byPair.putIfAbsent(key, () => {});
    byPair[key]![end] = (byPair[key]![end] ?? 0) + 1;
  }

  // ¿Hay celdas con refrigerado de 20 en los dos extremos a la vez (misma
  // fila y nivel)? Si las hay, esa celda tiene corriente en ambos extremos.
  final reeferCells = {
    for (final c in reefer20)
      '${c.stowagePosition!.bay}|${c.stowagePosition!.row}|${c.stowagePosition!.tier}',
  };
  final bothEnds = <String>[];
  for (final e in evenBays) {
    for (final c in reefer20.where((c) => c.stowagePosition!.bay == e - 1)) {
      final p = c.stowagePosition!;
      if (reeferCells.contains('${e + 1}|${p.row}|${p.tier}')) {
        bothEnds.add('${p.toIsoCode()} + ${_b(e + 1)}${p.rowPadded}${p.tierPadded}');
      }
    }
  }

  // Qué hay en la otra mitad de la misma celda (fila y nivel) de cada
  // refrigerado de 20: otro refrigerado, un 20 seco o nada.
  final otherHalf = <String, int>{};
  for (final c in reefer20) {
    final p = c.stowagePosition!;
    final owners = claimed[p.bay] ?? const <String>[];
    if (owners.length != 1) continue;
    final e = int.parse(owners.single);
    final other = e - 1 == p.bay ? e + 1 : e - 1;
    final unit = twenties.where((u) =>
        u.stowagePosition!.bay == other &&
        u.stowagePosition!.row == p.row &&
        u.stowagePosition!.tier == p.tier);
    final kind = unit.isEmpty
        ? 'vacía'
        : unit.first.isReefer
            ? 'refrigerado de 20'
            : '20 seco (${unit.first.isoSizeType})';
    otherHalf[kind] = (otherHalf[kind] ?? 0) + 1;
  }

  // Refrigerados de 40, para comparar: cuántos y en qué pares.
  final reefer40 = forties.where((c) => c.isReefer).toList();
  final reefer40Pairs = <String, int>{};
  for (final c in reefer40) {
    final k = _b(c.stowagePosition!.bay);
    reefer40Pairs[k] = (reefer40Pairs[k] ?? 0) + 1;
  }

  return {
    'buque': vessel,
    'contenedores': all.length,
    'veintesEnImpar': twenties.length,
    'cuarentasEnPar': forties.length,
    'fueraDePatronTamanoBahia': all.length - twenties.length - forties.length,
    'paresConCarga': evenBays.map(_b).toList(),
    'paresFueraDeMod4Igual2':
        evenBays.where((e) => e % 4 != 2).map(_b).toList(),
    'imparesCompartidasPorDosPares': shared,
    'imparesConVeintesSinParConCarga': orphans,
    'correspondencia': pairs,
    'reefers20': reefer20.length,
    'reefers20PorExtremo': ends,
    'reefers20PorPar': byPair,
    'celdasConReefer20EnAmbosExtremos': bothEnds,
    'otraMitadDeLaCeldaDelReefer20': otherHalf,
    'reefers40': reefer40.length,
    'reefers40PorPar': reefer40Pairs,
  };
}
